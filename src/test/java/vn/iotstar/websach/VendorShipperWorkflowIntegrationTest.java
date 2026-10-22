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
import vn.iotstar.websach.entity.DeliveryAssignment;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.OtpToken;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.DeliveryStatus;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.entity.enums.PaymentStatus;
import vn.iotstar.websach.entity.enums.UserStatus;
import vn.iotstar.websach.repository.OtpTokenRepository;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.service.EmailService;
import vn.iotstar.websach.service.OrderService;
import vn.iotstar.websach.service.ShipperService;
import vn.iotstar.websach.service.UserService;
import vn.iotstar.websach.service.VendorService;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

@SpringBootTest
@ActiveProfiles("h2")
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
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("lý do");
    }
}
