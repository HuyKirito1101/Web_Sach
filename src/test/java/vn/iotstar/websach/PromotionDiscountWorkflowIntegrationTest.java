package vn.iotstar.websach;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.dto.PromotionEligibilityDTO;
import vn.iotstar.websach.dto.PromotionPreviewResult;
import vn.iotstar.websach.dto.VendorDashboardDTO;
import vn.iotstar.websach.dto.VendorRevenueAnalyticsDTO;
import vn.iotstar.websach.entity.*;
import vn.iotstar.websach.entity.enums.DeliveryStatus;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.entity.enums.PromotionType;
import vn.iotstar.websach.entity.enums.RoleName;
import vn.iotstar.websach.entity.enums.UserStatus;
import vn.iotstar.websach.repository.*;
import vn.iotstar.websach.service.*;

import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class PromotionDiscountWorkflowIntegrationTest {

    @Autowired private CartService cartService;
    @Autowired private CheckoutService checkoutService;
    @Autowired private PromotionService promotionService;
    @Autowired private UserRepository userRepository;
    @Autowired private BookCopyRepository bookCopyRepository;
    @Autowired private BranchRepository branchRepository;
    @Autowired private PromotionRepository promotionRepository;
    @Autowired private ShippingProviderRepository shippingProviderRepository;
    @Autowired private VendorService vendorService;
    @Autowired private ShipperService shipperService;
    @Autowired private OrderRepository orderRepository;
    @Autowired private DeliveryAssignmentRepository deliveryAssignmentRepository;

    @MockBean private EmailService emailService;

    @Test
    void adminPromotionAppliesToAllBooksAndAppearsBrightWhenEligible() {
        User customer = getOrCreateCustomer("admin-promo-user@example.com");
        cartService.clearCart(customer);

        BookCopy copy = bookCopyRepository.findAll().stream()
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0 && c.getSellingPrice() != null)
                .findFirst().orElseThrow();
        cartService.addToCart(customer, copy.getId(), 1);

        // Admin promotion (branch == null, vendor == null)
        Promotion adminPromo = promotionRepository.save(Promotion.builder()
                .title("Đại Tiệc Sách Admin")
                .code("ADMINALL10")
                .discountPercent(10.0)
                .minOrderValue(10000.0)
                .maxDiscountAmount(50000.0)
                .startDate(LocalDate.now().minusDays(1))
                .endDate(LocalDate.now().plusDays(5))
                .active(true)
                .type(PromotionType.PRODUCT_PERCENT)
                .build());

        List<PromotionEligibilityDTO> vouchers = promotionService.evaluatePromotionsForCart(customer);
        PromotionEligibilityDTO adminDto = vouchers.stream()
                .filter(v -> v.getId() != null && v.getId().equals(adminPromo.getId()))
                .findFirst().orElseThrow();

        // Hiện sáng và có thể chọn
        assertThat(adminDto.isApplicable()).isTrue();
        assertThat(adminDto.getScopeType()).isEqualTo("ADMIN");
        assertThat(adminDto.getReason()).isNull();
        assertThat(adminDto.getEstimatedDiscount()).isGreaterThan(0.0);

        // Preview hợp lệ
        PromotionPreviewResult preview = promotionService.previewPromotion(customer, adminPromo.getCode());
        assertThat(preview.isValid()).isTrue();
        assertThat(preview.getDiscountAmount()).isCloseTo(copy.getSellingPrice() * 0.1, org.assertj.core.data.Offset.offset(0.01));
    }

    @Test
    void managerPromotionAppliesOnlyToVendorsOfThatBranchAndDimmIfCartHasOtherBranchOnly() {
        User customer = getOrCreateCustomer("manager-promo-user@example.com");
        cartService.clearCart(customer);

        List<Branch> branches = branchRepository.findAll();
        assertThat(branches.size()).isGreaterThanOrEqualTo(2);
        Branch branch1 = branches.get(0);
        Branch branch2 = branches.get(1);

        // Copy thuộc branch 1
        BookCopy copyBranch1 = bookCopyRepository.findAll().stream()
                .filter(c -> c.getBranch() != null && c.getBranch().getId().equals(branch1.getId()))
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0 && c.getSellingPrice() != null)
                .findFirst().orElseThrow();

        // Copy thuộc branch 2
        BookCopy copyBranch2 = bookCopyRepository.findAll().stream()
                .filter(c -> c.getBranch() != null && c.getBranch().getId().equals(branch2.getId()))
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0 && c.getSellingPrice() != null)
                .findFirst().orElseThrow();

        // Promotion của Manager branch 1 (branch != null, vendor == null)
        Promotion managerPromoBranch1 = promotionRepository.save(Promotion.builder()
                .title("Khuyến Mãi Cơ Sở 1")
                .code("CS1SALE15")
                .branch(branch1)
                .discountPercent(15.0)
                .minOrderValue(10000.0)
                .maxDiscountAmount(30000.0)
                .startDate(LocalDate.now().minusDays(1))
                .endDate(LocalDate.now().plusDays(5))
                .active(true)
                .type(PromotionType.PRODUCT_PERCENT)
                .build());

        // Case A: Giỏ hàng chỉ có sách của branch 2 -> Mã của branch 1 phải HIỆN MỜ / TỐI (applicable = false)
        cartService.addToCart(customer, copyBranch2.getId(), 1);
        List<PromotionEligibilityDTO> vouchers = promotionService.evaluatePromotionsForCart(customer);
        PromotionEligibilityDTO dto = vouchers.stream()
                .filter(v -> v.getId() != null && v.getId().equals(managerPromoBranch1.getId()))
                .findFirst().orElseThrow();

        assertThat(dto.isApplicable()).isFalse();
        assertThat(dto.getReason()).contains("không có");

        assertThatThrownBy(() -> promotionService.previewPromotion(customer, managerPromoBranch1.getCode()))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("chỉ áp dụng cho các sản phẩm thuộc cơ sở");

        // Case B: Thêm sách của branch 1 vào giỏ -> Mã HIỆN SÁNG (applicable = true)
        cartService.addToCart(customer, copyBranch1.getId(), 1);
        vouchers = promotionService.evaluatePromotionsForCart(customer);
        dto = vouchers.stream()
                .filter(v -> v.getId() != null && v.getId().equals(managerPromoBranch1.getId()))
                .findFirst().orElseThrow();

        assertThat(dto.isApplicable()).isTrue();
        assertThat(dto.getScopeType()).isEqualTo("MANAGER");
        // Mức giảm chỉ tính trên giá của copyBranch1 (không giảm trên copyBranch2)
        double expectedDiscount = Math.min(copyBranch1.getSellingPrice() * 0.15, 30000.0);
        assertThat(dto.getEstimatedDiscount()).isCloseTo(expectedDiscount, org.assertj.core.data.Offset.offset(0.01));
    }

    @Test
    void vendorPromotionAppliesOnlyToProductsOfThatVendorAndDimmIfCartHasOtherVendorOnly() {
        User customer = getOrCreateCustomer("vendor-promo-user@example.com");
        cartService.clearCart(customer);

        List<BookCopy> copies = bookCopyRepository.findAll().stream()
                .filter(c -> c.getSeller() != null && c.getQuantity() != null && c.getQuantity() > 0 && c.getSellingPrice() != null)
                .toList();

        BookCopy copyVendor1 = copies.get(0);
        User vendor1 = copyVendor1.getSeller();

        BookCopy copyVendor2 = copies.stream()
                .filter(c -> !c.getSeller().getId().equals(vendor1.getId()))
                .findFirst().orElseThrow();

        // Promotion của riêng Vendor 1 (vendor != null)
        Promotion vendorPromo = promotionRepository.save(Promotion.builder()
                .title("Giảm Giá Cửa Hàng Vendor 1")
                .code("VD1SPECIAL")
                .branch(copyVendor1.getBranch())
                .vendor(vendor1)
                .discountPercent(20.0)
                .minOrderValue(10000.0)
                .maxDiscountAmount(40000.0)
                .startDate(LocalDate.now().minusDays(1))
                .endDate(LocalDate.now().plusDays(5))
                .active(true)
                .type(PromotionType.PRODUCT_PERCENT)
                .build());

        // Case A: Giỏ hàng chỉ có sách của vendor 2 -> Mã của vendor 1 phải HIỆN MỜ / TỐI (applicable = false)
        cartService.addToCart(customer, copyVendor2.getId(), 1);
        List<PromotionEligibilityDTO> vouchers = promotionService.evaluatePromotionsForCart(customer);
        PromotionEligibilityDTO dto = vouchers.stream()
                .filter(v -> v.getId() != null && v.getId().equals(vendorPromo.getId()))
                .findFirst().orElseThrow();

        assertThat(dto.isApplicable()).isFalse();
        assertThat(dto.getReason()).contains("không có sản phẩm");

        assertThatThrownBy(() -> promotionService.previewPromotion(customer, vendorPromo.getCode()))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("chỉ áp dụng cho sản phẩm do gian hàng");

        // Case B: Thêm sách của vendor 1 -> Mã HIỆN SÁNG (applicable = true)
        cartService.addToCart(customer, copyVendor1.getId(), 1);
        vouchers = promotionService.evaluatePromotionsForCart(customer);
        dto = vouchers.stream()
                .filter(v -> v.getId() != null && v.getId().equals(vendorPromo.getId()))
                .findFirst().orElseThrow();

        assertThat(dto.isApplicable()).isTrue();
        assertThat(dto.getScopeType()).isEqualTo("VENDOR");
        double expectedDiscount = Math.min(copyVendor1.getSellingPrice() * 0.20, 40000.0);
        assertThat(dto.getEstimatedDiscount()).isCloseTo(expectedDiscount, org.assertj.core.data.Offset.offset(0.01));
    }

    @Test
    void promotionDimmWhenMinOrderValueNotReachedWithExplicitReason() {
        User customer = getOrCreateCustomer("min-order-user@example.com");
        cartService.clearCart(customer);

        BookCopy copy = bookCopyRepository.findAll().stream()
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0 && c.getSellingPrice() != null)
                .findFirst().orElseThrow();
        cartService.addToCart(customer, copy.getId(), 1);

        // Voucher yêu cầu đơn tối thiểu rất cao: 50.000.000đ
        Promotion highMinPromo = promotionRepository.save(Promotion.builder()
                .title("Ưu Đãi Đơn Khủng")
                .code("VIP50TR")
                .discountPercent(50.0)
                .minOrderValue(50000000.0)
                .startDate(LocalDate.now().minusDays(1))
                .endDate(LocalDate.now().plusDays(5))
                .active(true)
                .type(PromotionType.PRODUCT_PERCENT)
                .build());

        List<PromotionEligibilityDTO> vouchers = promotionService.evaluatePromotionsForCart(customer);
        PromotionEligibilityDTO dto = vouchers.stream()
                .filter(v -> v.getId() != null && v.getId().equals(highMinPromo.getId()))
                .findFirst().orElseThrow();

        // Không áp dụng được do chưa đạt đơn tối thiểu -> Hiện mờ/tối
        assertThat(dto.isApplicable()).isFalse();
        assertThat(dto.getReason()).contains("Chưa đạt đơn tối thiểu");
    }

    @Test
    void checkoutProcessAppliesDiscountsCorrectlyForAdminManagerAndVendor() {
        User customer = getOrCreateCustomer("checkout-promo-user@example.com");
        cartService.clearCart(customer);

        List<BookCopy> copies = bookCopyRepository.findAll().stream()
                .filter(c -> c.getSeller() != null && c.getQuantity() != null && c.getQuantity() > 0 && c.getSellingPrice() != null)
                .toList();

        BookCopy copyVendor1 = copies.get(0);
        User vendor1 = copyVendor1.getSeller();

        Promotion vendorPromo = promotionRepository.save(Promotion.builder()
                .title("Vendor Special 50%")
                .code("VENDORSPECIAL50")
                .branch(copyVendor1.getBranch())
                .vendor(vendor1)
                .discountPercent(50.0)
                .minOrderValue(0.0)
                .maxDiscountAmount(10000.0)
                .startDate(LocalDate.now().minusDays(1))
                .endDate(LocalDate.now().plusDays(5))
                .active(true)
                .type(PromotionType.PRODUCT_PERCENT)
                .build());

        cartService.addToCart(customer, copyVendor1.getId(), 1);

        Long providerId = shippingProviderRepository.findByActiveTrue().getFirst().getId();

        List<Order> orders = checkoutService.processCheckout(customer, null, "Người nhận", "0912345678",
                "123 Đường Số 1", providerId, vendorPromo.getCode(), "COD", "Giao nhanh");

        assertThat(orders).hasSize(1);
        Order order = orders.get(0);
        double expectedDiscount = Math.min(copyVendor1.getSellingPrice() * 0.5, 10000.0);
        assertThat(order.getDiscountAmount()).isCloseTo(expectedDiscount, org.assertj.core.data.Offset.offset(0.01));
    }

    @Test
    void vendorRevenueDeductsProductPromotionAndShipperIncomeRemainsFixed() {
        User customer = getOrCreateCustomer("vendor-rev-product-user@example.com");
        cartService.clearCart(customer);

        List<BookCopy> copies = bookCopyRepository.findAll().stream()
                .filter(c -> c.getSeller() != null && c.getQuantity() != null && c.getQuantity() > 0 && c.getSellingPrice() != null)
                .toList();
        BookCopy copy = copies.get(0);
        User vendor = copy.getSeller();

        VendorDashboardDTO baseDashboard = vendorService.getDashboard(vendor.getEmail(), null, null);

        Promotion promo = promotionRepository.save(Promotion.builder()
                .title("Vendor Promo Deduct Test")
                .code("VENDORDEDUCT10K")
                .branch(copy.getBranch())
                .vendor(vendor)
                .discountPercent(50.0)
                .minOrderValue(0.0)
                .maxDiscountAmount(10000.0)
                .startDate(LocalDate.now().minusDays(1))
                .endDate(LocalDate.now().plusDays(5))
                .active(true)
                .type(PromotionType.PRODUCT_PERCENT)
                .build());

        cartService.addToCart(customer, copy.getId(), 1);
        Long providerId = shippingProviderRepository.findByActiveTrue().getFirst().getId();

        List<Order> orders = checkoutService.processCheckout(customer, null, "Người nhận", "0912345678",
                "123 Đường Số 1", providerId, promo.getCode(), "COD", "Giao nhanh");

        assertThat(orders).hasSize(1);
        Order order = orders.get(0);
        double discount = order.getDiscountAmount();
        assertThat(discount).isCloseTo(10000.0, org.assertj.core.data.Offset.offset(0.01));
        assertThat(order.getShippingFee()).isCloseTo(20000.0, org.assertj.core.data.Offset.offset(0.01));

        order.setOrderStatus(OrderStatus.DELIVERED);
        orderRepository.save(order);

        VendorDashboardDTO newDashboard = vendorService.getDashboard(vendor.getEmail(), null, null);
        double grossDiff = newDashboard.getGrossRevenue() - baseDashboard.getGrossRevenue();
        double discountDiff = newDashboard.getTotalDiscount() - baseDashboard.getTotalDiscount();
        double netDeliveredDiff = newDashboard.getDeliveredRevenue() - baseDashboard.getDeliveredRevenue();

        assertThat(grossDiff).isCloseTo(copy.getSellingPrice(), org.assertj.core.data.Offset.offset(0.01));
        assertThat(discountDiff).isCloseTo(10000.0, org.assertj.core.data.Offset.offset(0.01));
        assertThat(netDeliveredDiff).isCloseTo(copy.getSellingPrice() - 10000.0, org.assertj.core.data.Offset.offset(0.01));

        DeliveryAssignment da = DeliveryAssignment.builder()
                .order(order)
                .status(DeliveryStatus.DELIVERED)
                .build();
        double shipperIncome = shipperService.calculateAssignmentIncome(da);
        assertThat(shipperIncome).isCloseTo(20000.0, org.assertj.core.data.Offset.offset(0.01));
    }

    @Test
    void vendorRevenueDeductsShippingPromotionAndShipperIncomeRemainsFixed() {
        User customer = getOrCreateCustomer("vendor-rev-shipping-user@example.com");
        cartService.clearCart(customer);

        List<BookCopy> copies = bookCopyRepository.findAll().stream()
                .filter(c -> c.getSeller() != null && c.getQuantity() != null && c.getQuantity() > 0 && c.getSellingPrice() != null)
                .toList();
        BookCopy copy = copies.get(0);
        User vendor = copy.getSeller();

        VendorDashboardDTO baseDashboard = vendorService.getDashboard(vendor.getEmail(), null, null);

        Promotion shippingPromo = promotionRepository.save(Promotion.builder()
                .title("Freeship 100% Shipper Fixed")
                .code("FREESHIPVENDOR100")
                .branch(copy.getBranch())
                .vendor(vendor)
                .discountPercent(100.0)
                .minOrderValue(0.0)
                .maxDiscountAmount(20000.0)
                .startDate(LocalDate.now().minusDays(1))
                .endDate(LocalDate.now().plusDays(5))
                .active(true)
                .type(PromotionType.SHIPPING_PERCENT)
                .build());

        cartService.addToCart(customer, copy.getId(), 1);
        Long providerId = shippingProviderRepository.findByActiveTrue().getFirst().getId();

        List<Order> orders = checkoutService.processCheckout(customer, null, "Người nhận", "0912345678",
                "123 Đường Số 1", providerId, shippingPromo.getCode(), "COD", "Giao nhanh");

        assertThat(orders).hasSize(1);
        Order order = orders.get(0);
        assertThat(order.getShippingFee()).isCloseTo(20000.0, org.assertj.core.data.Offset.offset(0.01));
        assertThat(order.getDiscountAmount()).isCloseTo(20000.0, org.assertj.core.data.Offset.offset(0.01));
        assertThat(order.getFinalAmount()).isCloseTo(copy.getSellingPrice(), org.assertj.core.data.Offset.offset(0.01));

        order.setOrderStatus(OrderStatus.DELIVERED);
        orderRepository.save(order);

        VendorDashboardDTO newDashboard = vendorService.getDashboard(vendor.getEmail(), null, null);
        double grossDiff = newDashboard.getGrossRevenue() - baseDashboard.getGrossRevenue();
        double discountDiff = newDashboard.getTotalDiscount() - baseDashboard.getTotalDiscount();
        double netDeliveredDiff = newDashboard.getDeliveredRevenue() - baseDashboard.getDeliveredRevenue();

        assertThat(grossDiff).isCloseTo(copy.getSellingPrice(), org.assertj.core.data.Offset.offset(0.01));
        assertThat(discountDiff).isCloseTo(20000.0, org.assertj.core.data.Offset.offset(0.01));
        assertThat(netDeliveredDiff).isCloseTo(copy.getSellingPrice() - 20000.0, org.assertj.core.data.Offset.offset(0.01));

        DeliveryAssignment da = DeliveryAssignment.builder()
                .order(order)
                .status(DeliveryStatus.DELIVERED)
                .build();
        double shipperIncome = shipperService.calculateAssignmentIncome(da);
        assertThat(shipperIncome).isCloseTo(20000.0, org.assertj.core.data.Offset.offset(0.01));
    }

    private User getOrCreateCustomer(String email) {
        return userRepository.findByEmail(email).orElseGet(() -> {
            Role role = userRepository.findAll().stream()
                    .filter(u -> u.getRole() != null && u.getRole().getName() == RoleName.ROLE_USER)
                    .map(User::getRole).findFirst().orElseThrow();
            return userRepository.save(User.builder()
                    .email(email)
                    .fullName("Customer " + email)
                    .password("$2a$10$abcdefghijklmnopqrstuv")
                    .phone("0987654321")
                    .role(role)
                    .status(UserStatus.ACTIVE)
                    .build());
        });
    }
}
