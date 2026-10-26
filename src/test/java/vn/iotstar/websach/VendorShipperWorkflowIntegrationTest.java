package vn.iotstar.websach;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.dto.AssignShipperRequest;
import vn.iotstar.websach.dto.RegisterRequest;
import vn.iotstar.websach.entity.*;
import vn.iotstar.websach.entity.enums.*;
import vn.iotstar.websach.repository.*;
import vn.iotstar.websach.controller.customer.CustomerSellRequestController;
import vn.iotstar.websach.service.EmailService;
import vn.iotstar.websach.service.OrderService;
import vn.iotstar.websach.service.ShipperService;
import vn.iotstar.websach.service.UserService;
import vn.iotstar.websach.service.VendorService;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class VendorShipperWorkflowIntegrationTest {

    private static final String VENDOR_EMAIL = "vendor.thuduc1@websachcu.vn";
    private static final String SHIPPER_EMAIL = "shipper.thuduc1@websachcu.vn";

    @Autowired private VendorService vendorService;
    @Autowired private ShipperService shipperService;
    @Autowired private OrderService orderService;
    @Autowired private UserService userService;
    @Autowired private UserRepository userRepository;
    @Autowired private OtpTokenRepository otpTokenRepository;
    @Autowired private SellRequestRepository sellRequestRepository;
    @Autowired private SellRequestQuoteRepository sellRequestQuoteRepository;
    @Autowired private BranchRepository branchRepository;
    @Autowired private DeliveryAssignmentRepository deliveryAssignmentRepository;
    @Autowired private CustomerSellRequestController customerSellRequestController;
    @MockBean private EmailService emailService;

    @Test
    void registrationOtpCanBeResentAndConsumedOnlyOnce() {
        String email = "otp.integration@websachcu.vn";
        RegisterRequest request = new RegisterRequest();
        request.setFullName("OTP Integration User");
        request.setEmail(email);
        request.setPassword("TestPass123!");
        request.setPhone("0900000000");

        User registered = userService.register(request);
        assertThat(registered.getStatus()).isEqualTo(UserStatus.INACTIVE);

        userService.resendRegistrationOtp(email);
        var currentTokens = otpTokenRepository.findAll().stream()
                .filter(token -> email.equals(token.getEmail()) && "REGISTER".equals(token.getType()))
                .toList();
        assertThat(currentTokens).hasSize(1);

        OtpToken currentToken = currentTokens.getFirst();
        ArgumentCaptor<String> otpCaptor = ArgumentCaptor.forClass(String.class);
        verify(emailService, times(2)).sendOtpEmail(eq(email), otpCaptor.capture());
        String latestOtp = otpCaptor.getAllValues().getLast();
        assertThat(currentToken.getOtpCode()).doesNotContain(latestOtp);
        assertThat(userService.verifyOtp(email, latestOtp)).isTrue();
        assertThat(userRepository.findByEmail(email).orElseThrow().getStatus()).isEqualTo(UserStatus.ACTIVE);
        assertThat(otpTokenRepository.findById(currentToken.getId()).orElseThrow().isUsed()).isTrue();
        assertThat(userService.verifyOtp(email, latestOtp)).isFalse();
    }

    @Test
    void vendorToShipperCodWorkflowIsScopedAndCompletes() {
        Order order = orderService.findByOrderCode("DH-DEMO-001").orElseThrow();

        vendorService.updateOrderStatus(VENDOR_EMAIL, order.getId(), OrderStatus.CONFIRMED);
        vendorService.updateOrderStatus(VENDOR_EMAIL, order.getId(), OrderStatus.PACKING);
        vendorService.updateOrderStatus(VENDOR_EMAIL, order.getId(), OrderStatus.READY_FOR_PICKUP);

        User shipper = userRepository.findByEmail(SHIPPER_EMAIL).orElseThrow();
        AssignShipperRequest request = new AssignShipperRequest();
        request.setOrderId(order.getId());
        request.setShipperId(shipper.getId());
        request.setNote("Giao trong giờ hành chính");
        DeliveryAssignment assignment = orderService.assignShipper(request, "manager@websachcu.vn");

        assertThat(assignment.getStatus()).isEqualTo(DeliveryStatus.ASSIGNED);
        assertThatThrownBy(() -> shipperService.getAssignment(VENDOR_EMAIL, assignment.getId()))
                .isInstanceOf(SecurityException.class);

        shipperService.updateStatus(SHIPPER_EMAIL, assignment.getId(), DeliveryStatus.ACCEPTED, null);
        shipperService.updateStatus(SHIPPER_EMAIL, assignment.getId(), DeliveryStatus.PICKED_UP, null);
        shipperService.updateStatus(SHIPPER_EMAIL, assignment.getId(), DeliveryStatus.SHIPPING, null);
        DeliveryAssignment delivered = shipperService.updateStatus(
                SHIPPER_EMAIL, assignment.getId(), DeliveryStatus.DELIVERED, null);

        Order completedOrder = orderService.findById(order.getId()).orElseThrow();
        assertThat(delivered.getDeliveredAt()).isNotNull();
        assertThat(completedOrder.getOrderStatus()).isEqualTo(OrderStatus.DELIVERED);
        assertThat(completedOrder.getPaymentStatus()).isEqualTo(PaymentStatus.PAID);
        assertThat(shipperService.getDashboard(SHIPPER_EMAIL, null, null).getDelivered()).isEqualTo(1);
    }

    @Test
    void failedDeliveryRequiresAReason() {
        Order order = orderService.findByOrderCode("DH-DEMO-001").orElseThrow();
        vendorService.updateOrderStatus(VENDOR_EMAIL, order.getId(), OrderStatus.CONFIRMED);
        vendorService.updateOrderStatus(VENDOR_EMAIL, order.getId(), OrderStatus.READY_FOR_PICKUP);

        User shipper = userRepository.findByEmail(SHIPPER_EMAIL).orElseThrow();
        AssignShipperRequest request = new AssignShipperRequest();
        request.setOrderId(order.getId());
        request.setShipperId(shipper.getId());
        DeliveryAssignment assignment = orderService.assignShipper(request, "manager@websachcu.vn");
        shipperService.updateStatus(SHIPPER_EMAIL, assignment.getId(), DeliveryStatus.PICKED_UP, null);

        assertThatThrownBy(() -> shipperService.updateStatus(
                SHIPPER_EMAIL, assignment.getId(), DeliveryStatus.FAILED, " "))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void multiVendorIndependentQuotesAndCustomerSelectionWorkflow() {
        Role customerRole = userRepository.findAll().stream()
                .filter(u -> u.getRole() != null && u.getRole().getName() == RoleName.ROLE_USER)
                .map(User::getRole).findFirst().orElseThrow();
        User customer = userRepository.findByEmail("customer.sellreq@websachcu.vn").orElseGet(() ->
                userRepository.save(User.builder()
                        .email("customer.sellreq@websachcu.vn")
                        .fullName("Nguyễn Khách Hàng")
                        .password("123456")
                        .phone("0987654321")
                        .role(customerRole)
                        .status(UserStatus.ACTIVE)
                        .build()));
        Branch branch = branchRepository.findAll().getFirst();

        // 1. Khách hàng tạo yêu cầu thu mua sách cũ
        SellRequest request = sellRequestRepository.save(SellRequest.builder()
                .customer(customer)
                .branch(branch)
                .expectedTotal(50000.0)
                .status(SellRequestStatus.PENDING)
                .note("Bán 2 cuốn sách cũ")
                .build());

        // 2. Vendor 1 thẩm định và gửi báo giá 50,000 đ
        vendorService.updateSellRequest("vendor.thuduc1@websachcu.vn", request.getId(),
                SellRequestStatus.QUOTED, 50000.0, "Shop Thủ Đức 1 đồng ý giá 50k");

        // 3. Vendor 2 thẩm định độc lập và gửi báo giá 45,000 đ
        vendorService.updateSellRequest("vendor.thuduc2@websachcu.vn", request.getId(),
                SellRequestStatus.QUOTED, 45000.0, "Shop Thủ Đức 2 gửi báo giá 45k");

        // 4. Kiểm tra tính độc lập & cách ly báo giá giữa các Vendor
        User v1 = userRepository.findByEmail("vendor.thuduc1@websachcu.vn").orElseThrow();
        User v2 = userRepository.findByEmail("vendor.thuduc2@websachcu.vn").orElseThrow();

        SellRequestQuote quoteV1 = sellRequestQuoteRepository.findBySellRequestIdAndVendorId(request.getId(), v1.getId()).orElseThrow();
        SellRequestQuote quoteV2 = sellRequestQuoteRepository.findBySellRequestIdAndVendorId(request.getId(), v2.getId()).orElseThrow();

        assertThat(quoteV1.getOfferedPrice()).isEqualTo(50000.0);
        assertThat(quoteV2.getOfferedPrice()).isEqualTo(45000.0);

        // 5. Khách hàng nhìn thấy cả 2 báo giá độc lập
        List<SellRequestQuote> allQuotes = sellRequestQuoteRepository.findBySellRequestIdOrderByCreatedAtDesc(request.getId());
        assertThat(allQuotes).hasSize(2);

        // 6. Khách hàng chọn Vendor 1 (50,000 đ)
        org.springframework.security.core.Authentication auth = new org.springframework.security.authentication.UsernamePasswordAuthenticationToken(
                customer.getEmail(), "password", List.of(new org.springframework.security.core.authority.SimpleGrantedAuthority("ROLE_CUSTOMER")));
        org.springframework.web.servlet.mvc.support.RedirectAttributesModelMap redirect = new org.springframework.web.servlet.mvc.support.RedirectAttributesModelMap();

        String result = customerSellRequestController.acceptQuote(auth, request.getId(), quoteV1.getId(), redirect);
        assertThat(result).isEqualTo("redirect:/sell-books");

        // 7. Xác minh sau khi chọn:
        SellRequest updatedReq = sellRequestRepository.findById(request.getId()).orElseThrow();
        assertThat(updatedReq.getStatus()).isEqualTo(SellRequestStatus.ACCEPTED);
        assertThat(updatedReq.getBuyerVendor().getId()).isEqualTo(v1.getId());
        assertThat(updatedReq.getOfferedTotal()).isEqualTo(50000.0);

        // Báo giá v1 ACCEPTED, báo giá v2 REJECTED
        assertThat(sellRequestQuoteRepository.findById(quoteV1.getId()).orElseThrow().getStatus())
                .isEqualTo(SellRequestQuoteStatus.ACCEPTED);
        assertThat(sellRequestQuoteRepository.findById(quoteV2.getId()).orElseThrow().getStatus())
                .isEqualTo(SellRequestQuoteStatus.REJECTED);

        // 8. Vendor 1 phân công Shipper lấy sách
        User shipper = userRepository.findByEmail(SHIPPER_EMAIL).orElseThrow();
        DeliveryAssignment da = vendorService.assignSellRequestShipper("vendor.thuduc1@websachcu.vn", updatedReq.getId(), shipper.getId(), "Lấy sách tại nhà");
        assertThat(da.getStatus()).isEqualTo(DeliveryStatus.ASSIGNED);

        // Vendor 2 KHÔNG được quyền phân công shipper cho đơn này (bảo mật tuyệt đối)
        assertThatThrownBy(() -> vendorService.assignSellRequestShipper("vendor.thuduc2@websachcu.vn", updatedReq.getId(), shipper.getId(), null))
                .isInstanceOf(SecurityException.class);
    }

    @Test
    void shipperEarningsGuaranteesStandardFeeForMultipleDeliveries() {
        User shipper = userRepository.findByEmail(SHIPPER_EMAIL).orElseThrow();

        // 1. Tạo 1 delivery hoàn tất cho đơn thu gom sách cũ (SellRequest)
        SellRequest req = sellRequestRepository.findAll().getFirst();
        deliveryAssignmentRepository.save(DeliveryAssignment.builder()
                .sellRequest(req)
                .shipper(shipper)
                .status(DeliveryStatus.DELIVERED)
                .assignedAt(java.time.LocalDateTime.now())
                .completedAt(java.time.LocalDateTime.now())
                .build());

        // 2. Tạo 1 delivery hoàn tất cho đơn bán hàng (Order) với phí ship được giảm còn 10,000đ
        Order order = orderService.findByOrderCode("DH-DEMO-001").orElseThrow();
        order.setShippingFee(10000.0); // Khách được mã giảm phí vận chuyển
        order.setOrderStatus(OrderStatus.DELIVERED);
        deliveryAssignmentRepository.save(DeliveryAssignment.builder()
                .order(order)
                .shipper(shipper)
                .status(DeliveryStatus.DELIVERED)
                .assignedAt(java.time.LocalDateTime.now())
                .completedAt(java.time.LocalDateTime.now())
                .build());

        // 3. Thu nhập của shipper giao 2 đơn phải đủ 20,000 + 20,000 = 40,000đ
        var dashboard = shipperService.getDashboard(SHIPPER_EMAIL, null, null);
        assertThat(dashboard.getDelivered()).isGreaterThanOrEqualTo(2);
        assertThat(dashboard.getShippingRevenue()).isGreaterThanOrEqualTo(40000.0);
    }
}
