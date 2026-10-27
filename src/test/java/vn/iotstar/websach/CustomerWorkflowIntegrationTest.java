package vn.iotstar.websach;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.*;
import vn.iotstar.websach.entity.enums.*;
import vn.iotstar.websach.repository.*;
import vn.iotstar.websach.service.*;

import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class CustomerWorkflowIntegrationTest {

    @Autowired private CartService cartService;
    @Autowired private CheckoutService checkoutService;
    @Autowired private CustomerOrderService customerOrderService;
    @Autowired private OrderService orderService;
    @Autowired private VendorService vendorService;
    @Autowired private ReviewService reviewService;
    @Autowired private UserService userService;
    @Autowired private CustomerBookService customerBookService;
    @Autowired private ViewedProductService viewedProductService;

    @Autowired private UserRepository userRepository;
    @Autowired private BookRepository bookRepository;
    @Autowired private BookCopyRepository bookCopyRepository;
    @Autowired private BranchRepository branchRepository;
    @Autowired private AppDiscountRepository appDiscountRepository;
    @Autowired private OrderRepository orderRepository;
    @Autowired private OrderItemRepository orderItemRepository;
    @Autowired private ShippingProviderRepository shippingProviderRepository;
    @Autowired private PromotionRepository promotionRepository;
    @Autowired private DeliveryAssignmentRepository deliveryAssignmentRepository;
    @Autowired private vn.iotstar.websach.controller.customer.CheckoutController checkoutController;
    @Autowired private vn.iotstar.websach.controller.customer.CustomerOrderController customerOrderController;

    @MockBean private EmailService emailService;

    @Test
    void cartBlocksPurchasingBeyondAvailableStock() {
        User user = getOrCreateCustomer("cart-stock-user@example.com");
        BookCopy copy = bookCopyRepository.findAll().stream()
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0)
                .findFirst().orElseThrow();

        int available = copy.getQuantity();

        // Thêm hợp lệ
        cartService.addToCart(user, copy.getId(), 1);

        // Thêm vượt quá tồn kho
        assertThatThrownBy(() -> cartService.addToCart(user, copy.getId(), available))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("vượt quá tồn kho");

        // Cập nhật số lượng giỏ hàng vượt quá tồn kho
        CartItem item = cartService.getCartItems(user).get(0);
        assertThatThrownBy(() -> cartService.updateCartItemQuantity(user, item.getId(), available + 5))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("vượt quá tồn kho");
    }

    @Test
    void voucherValidatesStartDateEndDateAndMinOrderValue() {
        User user = getOrCreateCustomer("voucher-user@example.com");
        BookCopy copy = bookCopyRepository.findAll().stream()
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0 && c.getSellingPrice() != null)
                .findFirst().orElseThrow();

        cartService.clearCart(user);
        cartService.addToCart(user, copy.getId(), 1);

        // 1. Voucher chưa đến ngày bắt đầu
        AppDiscount futureVoucher = appDiscountRepository.save(AppDiscount.builder()
                .code("FUTURE50")
                .discountPercent(10.0)
                .startDate(LocalDate.now().plusDays(2))
                .endDate(LocalDate.now().plusDays(10))
                .active(true)
                .build());

        assertThatThrownBy(() -> checkoutService.processCheckout(user, null, "Test", "0900000000",
                "Address", activeProviderId(), futureVoucher.getCode(), "COD", null))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("chưa có hiệu lực");

        // 2. Voucher đã hết hạn
        AppDiscount expiredVoucher = appDiscountRepository.save(AppDiscount.builder()
                .code("EXPIRED50")
                .discountPercent(10.0)
                .startDate(LocalDate.now().minusDays(10))
                .endDate(LocalDate.now().minusDays(1))
                .active(true)
                .build());

        assertThatThrownBy(() -> checkoutService.processCheckout(user, null, "Test", "0900000000",
                "Address", activeProviderId(), expiredVoucher.getCode(), "COD", null))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("hết hạn");

        // 3. Voucher yêu cầu đơn tối thiểu cao hơn giá trị giỏ hàng
        AppDiscount highMinOrderVoucher = appDiscountRepository.save(AppDiscount.builder()
                .code("MINORDER1M")
                .discountPercent(15.0)
                .minOrderValue(10000000.0)
                .startDate(LocalDate.now().minusDays(1))
                .endDate(LocalDate.now().plusDays(5))
                .active(true)
                .build());

        assertThatThrownBy(() -> checkoutService.processCheckout(user, null, "Test", "0900000000",
                "Address", activeProviderId(), highMinOrderVoucher.getCode(), "COD", null))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("chưa đạt giá trị tối thiểu");
    }

    @Test
    void checkoutSplitsOrdersByBranchWhenCartHasMultipleShops() {
        User user = getOrCreateCustomer("multi-vendor-user@example.com");
        List<Branch> branches = branchRepository.findAll();
        assertThat(branches.size()).isGreaterThanOrEqualTo(2);

        Branch b1 = branches.get(0);
        Branch b2 = branches.get(1);

        BookCopy copy1 = bookCopyRepository.findAll().stream()
                .filter(c -> c.getBranch() != null && c.getBranch().getId().equals(b1.getId()) && c.getQuantity() != null && c.getQuantity() > 0)
                .findFirst().orElseThrow();

        BookCopy copy2 = bookCopyRepository.findAll().stream()
                .filter(c -> c.getBranch() != null && c.getBranch().getId().equals(b2.getId()) && c.getQuantity() != null && c.getQuantity() > 0)
                .findFirst().orElseThrow();

        cartService.clearCart(user);
        cartService.addToCart(user, copy1.getId(), 1);
        cartService.addToCart(user, copy2.getId(), 1);

        List<Order> orders = checkoutService.processCheckout(user, null, "Người nhận", "0912345678",
                "123 Võ Văn Ngân", activeProviderId(), null, "COD", "Ghi chú đơn");

        // Phải tách thành 2 đơn riêng biệt
        assertThat(orders).hasSize(2);
        assertThat(orders.stream().map(o -> o.getBranch().getId()).toList())
                .containsExactlyInAnyOrder(b1.getId(), b2.getId());

        // Đơn COD khởi tạo phải chờ thanh toán khi giao thành công.
        for (Order o : orders) {
            assertThat(o.getPaymentStatus()).isEqualTo(PaymentStatus.PENDING);
            assertThat(o.getOrderStatus()).isEqualTo(OrderStatus.NEW);
        }

        // Giỏ hàng phải được làm trống sau khi checkout
        assertThat(cartService.getCartItems(user)).isEmpty();
    }

    @Test
    void checkoutRejectsUnsupportedOnlinePaymentMethod() {
        User user = getOrCreateCustomer("unsupported-payment@example.com");
        BookCopy copy = bookCopyRepository.findAll().stream()
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0)
                .findFirst().orElseThrow();
        cartService.clearCart(user);
        cartService.addToCart(user, copy.getId(), 1);

        assertThatThrownBy(() -> checkoutService.processCheckout(user, null, "Người nhận", "0912345678",
                "123 Võ Văn Ngân", activeProviderId(), null, "VNPAY", null))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("chỉ hỗ trợ COD hoặc MoMo demo");
    }

    @Test
    void momoDemoRequiresCustomerClaimThenVendorConfirmation() {
        User vendor = userRepository.findByEmail("vendor.thuduc1@websachcu.vn").orElseThrow();
        User user = getOrCreateCustomer("momo-demo-user@example.com");
        BookCopy copy = bookCopyRepository.findAll().stream()
                .filter(c -> c.getSeller() != null && c.getSeller().getId().equals(vendor.getId()))
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0)
                .findFirst().orElseThrow();

        cartService.clearCart(user);
        cartService.addToCart(user, copy.getId(), 1);
        Order order = checkoutService.processCheckout(user, null, "Người nhận", "0912345678",
                "123 Võ Văn Ngân", activeProviderId(), null, "MOMO", null).getFirst();

        assertThat(order.getPaymentMethod()).isEqualTo(PaymentMethod.MOMO);
        assertThat(order.getPaymentStatus()).isEqualTo(PaymentStatus.PENDING);
        assertThatThrownBy(() -> vendorService.confirmManualMomoPayment(vendor.getEmail(), order.getId()))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("chưa báo đã chuyển tiền");
        assertThatThrownBy(() -> orderService.updateOrderStatus(order.getId(), OrderStatus.CONFIRMED))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("chưa được xác nhận thanh toán");

        Order submitted = customerOrderService.markMomoTransferred(user, order.getId());
        assertThat(submitted.getPaymentStatus()).isEqualTo(PaymentStatus.AWAITING_CONFIRMATION);
        assertThat(submitted.getPaymentSubmittedAt()).isNotNull();

        User otherVendor = userRepository.findByEmail("vendor.thuduc2@websachcu.vn").orElseThrow();
        assertThatThrownBy(() -> vendorService.confirmManualMomoPayment(otherVendor.getEmail(), order.getId()))
                .isInstanceOf(SecurityException.class)
                .hasMessageContaining("không có sản phẩm của mình");

        Order paid = vendorService.confirmManualMomoPayment(vendor.getEmail(), order.getId());
        assertThat(paid.getPaymentStatus()).isEqualTo(PaymentStatus.PAID);
        assertThat(paid.getPaymentConfirmedAt()).isNotNull();
        assertThat(paid.getPaymentConfirmedBy()).isEqualTo(vendor.getEmail());
    }

    @Test
    void vendorCanConfirmOrderDirectlyWhenMomoAwaitingConfirmation() {
        User vendor = userRepository.findByEmail("vendor.thuduc1@websachcu.vn").orElseThrow();
        User user = getOrCreateCustomer("momo-auto-confirm@example.com");
        BookCopy copy = bookCopyRepository.findAll().stream()
                .filter(c -> c.getSeller() != null && c.getSeller().getId().equals(vendor.getId()))
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0)
                .findFirst().orElseThrow();

        cartService.clearCart(user);
        cartService.addToCart(user, copy.getId(), 1);
        Order order = checkoutService.processCheckout(user, null, "Người nhận", "0912345678",
                "123 Võ Văn Ngân", activeProviderId(), null, "MOMO", null).getFirst();

        // Khi PENDING, vendor bấm duyệt đơn sẽ báo lỗi rõ ràng
        assertThatThrownBy(() -> vendorService.updateOrderStatus(vendor.getEmail(), order.getId(), OrderStatus.CONFIRMED))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("chưa hoàn tất chuyển tiền");

        // Khách gửi thông tin đã chuyển
        customerOrderService.markMomoTransferred(user, order.getId());

        // Vendor bấm xác nhận đơn hàng -> hệ thống tự động xác nhận tiền MoMo & chuyển trạng thái CONFIRMED
        Order confirmed = vendorService.updateOrderStatus(vendor.getEmail(), order.getId(), OrderStatus.CONFIRMED);
        assertThat(confirmed.getOrderStatus()).isEqualTo(OrderStatus.CONFIRMED);
        assertThat(confirmed.getPaymentStatus()).isEqualTo(PaymentStatus.PAID);
        assertThat(confirmed.getPaymentConfirmedAt()).isNotNull();
        assertThat(confirmed.getPaymentConfirmedBy()).isEqualTo(vendor.getEmail());
    }

    @Test
    void managerCanClearOnlyCompletedOrdersWithoutDeletingCustomerHistory() {
        User manager = userRepository.findByEmail("manager@websachcu.vn").orElseThrow();
        User customer = getOrCreateCustomer("manager-order-history@example.com");
        BookCopy copy = bookCopyRepository.findAll().stream()
                .filter(c -> c.getBranch() != null && manager.getBranch() != null
                        && c.getBranch().getId().equals(manager.getBranch().getId()))
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0)
                .findFirst().orElseThrow();

        cartService.clearCart(customer);
        cartService.addToCart(customer, copy.getId(), 1);
        Order order = checkoutService.processCheckout(customer, null, "Người nhận", "0912345678",
                "123 Võ Văn Ngân", activeProviderId(), null, "COD", null).getFirst();
        orderService.updateOrderStatus(order.getId(), OrderStatus.CONFIRMED);
        orderService.updateOrderStatus(order.getId(), OrderStatus.PACKING);
        orderService.updateOrderStatus(order.getId(), OrderStatus.READY_FOR_PICKUP);
        orderService.updateOrderStatus(order.getId(), OrderStatus.SHIPPING);
        orderService.updateOrderStatus(order.getId(), OrderStatus.DELIVERED);

        int cleared = orderService.clearCompletedOrderHistory(manager.getEmail());
        assertThat(cleared).isGreaterThanOrEqualTo(1);
        assertThat(orderService.findOrdersByBranch(manager.getBranch().getId()))
                .extracting(Order::getId)
                .doesNotContain(order.getId());
        assertThat(orderRepository.findById(order.getId())).isPresent();
        assertThat(customerOrderService.getCustomerOrders(customer, null))
                .extracting(Order::getId)
                .contains(order.getId());

        assertThat(customerOrderService.requestReturnOrder(customer, order.getId(), "Cần hoàn trả")).isTrue();
        assertThat(orderService.findOrdersByBranch(manager.getBranch().getId()))
                .extracting(Order::getId)
                .contains(order.getId());
    }

    @Test
    void adminCannotDeleteAUserWhoStillHasOrders() {
        User user = getOrCreateCustomer("delete-blocked-by-order@example.com");
        BookCopy copy = bookCopyRepository.findAll().stream()
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0)
                .findFirst().orElseThrow();
        cartService.clearCart(user);
        cartService.addToCart(user, copy.getId(), 1);
        checkoutService.processCheckout(user, null, "Người nhận", "0912345678",
                "123 Võ Văn Ngân", activeProviderId(), null, "COD", null);

        assertThatThrownBy(() -> userService.deleteUser(user.getId()))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("đơn hàng mua (1)");
        assertThat(userRepository.findById(user.getId())).isPresent();
    }

    @Test
    void adminCanOnlyDeleteCancelledOrdersAndTheyDisappearFromCustomerHistory() {
        User user = getOrCreateCustomer("delete-cancelled-order@example.com");
        BookCopy copy = bookCopyRepository.findAll().stream()
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0)
                .findFirst().orElseThrow();
        cartService.clearCart(user);
        cartService.addToCart(user, copy.getId(), 1);
        Order order = checkoutService.processCheckout(user, null, "Người nhận", "0912345678",
                "123 Võ Văn Ngân", activeProviderId(), null, "COD", null).get(0);

        assertThatThrownBy(() -> orderService.deleteCancelledOrder(order.getId()))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("Chỉ được xóa đơn hàng đã hủy");
        assertThat(customerOrderService.cancelOrder(user, order.getId(), "Không còn nhu cầu")).isTrue();

        orderService.deleteCancelledOrder(order.getId());

        assertThat(orderRepository.findById(order.getId())).isEmpty();
        assertThat(orderItemRepository.findByOrderId(order.getId())).isEmpty();
        assertThat(customerOrderService.getCustomerOrders(user, null)).isEmpty();

        // Khi không còn dữ liệu liên quan, Admin có thể xóa luôn tài khoản.
        userService.deleteUser(user.getId());
        assertThat(userRepository.findById(user.getId())).isEmpty();
    }

    @Test
    void clearingViewedHistoryOnlyDeletesTheCurrentUsersHistory() {
        User firstUser = getOrCreateCustomer("clear-history-first@example.com");
        User secondUser = getOrCreateCustomer("clear-history-second@example.com");
        Long bookId = bookRepository.findAll().stream().findFirst().orElseThrow().getId();
        viewedProductService.recordView(firstUser, bookId);
        viewedProductService.recordView(secondUser, bookId);

        long deletedCount = viewedProductService.clearUserViewedProducts(firstUser);

        assertThat(deletedCount).isEqualTo(1);
        assertThat(viewedProductService.getUserViewedProducts(firstUser)).isEmpty();
        assertThat(viewedProductService.getUserViewedProducts(secondUser)).hasSize(1);
    }

    @Test
    void lowercaseVoucherCodeIsAcceptedAndMaxDiscountIsAppliedOnceForTheWholeCart() {
        User user = getOrCreateCustomer("case-voucher@example.com");
        List<Branch> branches = branchRepository.findAll();
        BookCopy copy1 = bookCopyRepository.findAll().stream()
                .filter(c -> c.getBranch() != null && c.getBranch().getId().equals(branches.get(0).getId()))
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0 && c.getSellingPrice() != null)
                .findFirst().orElseThrow();
        BookCopy copy2 = bookCopyRepository.findAll().stream()
                .filter(c -> c.getBranch() != null && !c.getBranch().getId().equals(copy1.getBranch().getId()))
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0 && c.getSellingPrice() != null)
                .findFirst().orElseThrow();
        cartService.clearCart(user);
        cartService.addToCart(user, copy1.getId(), 1);
        cartService.addToCart(user, copy2.getId(), 1);

        List<Promotion> promotions = promotionRepository.findAll();
        promotions.forEach(promotion -> promotion.setActive(false));
        promotionRepository.saveAll(promotions);

        AppDiscount voucher = appDiscountRepository.save(AppDiscount.builder()
                .code("CASEVOUCHER")
                .discountPercent(100.0)
                .maxDiscountAmount(5000.0)
                .minOrderValue(0.0)
                .startDate(LocalDate.now().minusDays(1))
                .endDate(LocalDate.now().plusDays(1))
                .active(true)
                .build());

        List<Order> orders = checkoutService.processCheckout(user, null, "Người nhận", "0912345678",
                "123 Võ Văn Ngân", activeProviderId(), voucher.getCode().toLowerCase(), "COD", null);

        double totalDiscount = orders.stream()
                .mapToDouble(order -> order.getDiscountAmount() == null ? 0.0 : order.getDiscountAmount())
                .sum();
        assertThat(orders).hasSize(2);
        assertThat(totalDiscount).isCloseTo(5000.0, org.assertj.core.data.Offset.offset(0.01));
    }

    @Test
    void bookSearchReturnsAtMostTwentyItemsPerServerPage() {
        var firstPage = customerBookService.searchAndFilterBooks(
                null, null, null, null, null, null, "newest", 0, 20);
        assertThat(firstPage.getSize()).isEqualTo(20);
        assertThat(firstPage.getContent()).hasSizeLessThanOrEqualTo(20);
    }

    @Test
    void returnWorkflowGoesThroughDeliveredToReturnRequestedThenReturnedAndRefunded() {
        User user = getOrCreateCustomer("return-flow-user@example.com");
        BookCopy copy = bookCopyRepository.findAll().stream()
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0)
                .findFirst().orElseThrow();

        cartService.clearCart(user);
        cartService.addToCart(user, copy.getId(), 1);
        List<Order> orders = checkoutService.processCheckout(user, null, "Test", "0900000000",
                "Address", activeProviderId(), null, "COD", null);
        Order order = orders.get(0);

        // 1. Không thể trả hàng khi đơn chưa DELIVERED
        assertThat(customerOrderService.requestReturnOrder(user, order.getId(), "Sách lỗi")).isFalse();

        // 2. Chuyển đơn sang DELIVERED
        orderService.updateOrderStatus(order.getId(), OrderStatus.CONFIRMED);
        orderService.updateOrderStatus(order.getId(), OrderStatus.PACKING);
        orderService.updateOrderStatus(order.getId(), OrderStatus.READY_FOR_PICKUP);
        orderService.updateOrderStatus(order.getId(), OrderStatus.SHIPPING);
        order = orderService.updateOrderStatus(order.getId(), OrderStatus.DELIVERED);
        assertThat(order.getOrderStatus()).isEqualTo(OrderStatus.DELIVERED);

        // 3. Khách hàng gửi yêu cầu trả hàng -> Phải chuyển sang RETURN_REQUESTED (không phải CANCELLED)
        boolean requested = customerOrderService.requestReturnOrder(user, order.getId(), "Sách bị rách gáy");
        assertThat(requested).isTrue();

        Order returnReqOrder = orderRepository.findById(order.getId()).orElseThrow();
        assertThat(returnReqOrder.getOrderStatus()).isEqualTo(OrderStatus.RETURN_REQUESTED);

        // 4. Quản lý nhận lại hàng -> RETURNED
        Order returnedOrder = orderService.updateOrderStatus(order.getId(), OrderStatus.RETURNED);
        assertThat(returnedOrder.getOrderStatus()).isEqualTo(OrderStatus.RETURNED);

        // 5. Duyệt hoàn tiền -> REFUNDED
        Order refundedOrder = orderService.updateOrderStatus(order.getId(), OrderStatus.REFUNDED);
        assertThat(refundedOrder.getOrderStatus()).isEqualTo(OrderStatus.REFUNDED);
        assertThat(refundedOrder.getPaymentStatus()).isEqualTo(PaymentStatus.REFUNDED);
    }

    @Test
    void reviewRequiresCompletedPurchaseAndMinimum50Characters() {
        User customer = getOrCreateCustomer("review-validator-user@example.com");
        Book book = bookRepository.findAll().get(0);

        // 1. Chưa mua sách mà đánh giá -> Bị chặn
        assertThat(reviewService.canUserReviewBook(customer, book.getId())).isFalse();
        assertThatThrownBy(() -> reviewService.addReview(customer, book.getId(), null, 5,
                "Sách này viết rất hay và rất bổ ích cho người đọc sách tại Việt Nam...", null))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("chỉ có thể đánh giá những cuốn sách đã mua");

        // 2. Mua sách và hoàn thành giao hàng
        BookCopy copy = bookCopyRepository.findByBookId(book.getId()).stream()
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0)
                .findFirst().orElseThrow();

        cartService.clearCart(customer);
        cartService.addToCart(customer, copy.getId(), 1);
        List<Order> orders = checkoutService.processCheckout(customer, null, "Buyer", "0900000000",
                "Address", activeProviderId(), null, "COD", null);
        Order order = orders.get(0);
        orderService.updateOrderStatus(order.getId(), OrderStatus.CONFIRMED);
        orderService.updateOrderStatus(order.getId(), OrderStatus.PACKING);
        orderService.updateOrderStatus(order.getId(), OrderStatus.READY_FOR_PICKUP);
        orderService.updateOrderStatus(order.getId(), OrderStatus.SHIPPING);
        orderService.updateOrderStatus(order.getId(), OrderStatus.DELIVERED);

        // Giờ đã đủ điều kiện mua hàng
        assertThat(reviewService.canUserReviewBook(customer, book.getId())).isTrue();

        // 3. Nội dung dưới 50 ký tự -> Bị chặn
        String shortComment = "Sách rất hay, đóng gói đẹp.";
        assertThat(shortComment.length()).isLessThan(50);
        assertThatThrownBy(() -> reviewService.addReview(customer, book.getId(), null, 5, shortComment, null))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("tối thiểu 50 ký tự");

        // 4. Nội dung >= 50 ký tự -> Thành công
        String validComment = "Cuốn sách này có nội dung cực kỳ sâu sắc và ý nghĩa, chất lượng sách cũ được bảo quản rất tốt và đóng gói cẩn thận!";
        assertThat(validComment.length()).isGreaterThanOrEqualTo(50);

        Review savedReview = reviewService.addReview(customer, book.getId(), null, 5, validComment, "https://cloudinary.test/sample.jpg");
        assertThat(savedReview.getId()).isNotNull();
        assertThat(savedReview.getComment()).isEqualTo(validComment);
        assertThat(savedReview.getImageUrl()).isEqualTo("https://cloudinary.test/sample.jpg");
    }

    @Test
    void forgotPasswordOtpSendsEmailAndResetsPassword() {
        String email = "forgot-pass-user@example.com";
        User user = getOrCreateCustomer(email);

        userService.sendForgotPasswordOtp(email);

        ArgumentCaptor<String> otpCaptor = ArgumentCaptor.forClass(String.class);
        verify(emailService).sendPasswordResetOtpEmail(eq(email), otpCaptor.capture());
        String otp = otpCaptor.getValue();
        assertThat(otp).hasSize(6);

        // Nhập sai OTP
        assertThatThrownBy(() -> userService.resetPasswordWithOtp(email, "999999", "newPassword123"))
                .isInstanceOf(IllegalArgumentException.class);

        // Nhập đúng OTP
        userService.resetPasswordWithOtp(email, otp, "newPassword123");

        // OTP không thể dùng lại lần thứ hai
        assertThatThrownBy(() -> userService.resetPasswordWithOtp(email, otp, "anotherPassword"))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void customerOrderDetailWithStandardShippingLoadsSuccessfully() {
        User customer = getOrCreateCustomer("std-order-customer@example.com");
        ShippingProvider standardProvider = shippingProviderRepository.findAll().stream()
                .filter(sp -> sp.getCode() != null && sp.getCode().contains("STANDARD"))
                .findFirst().orElseGet(() -> shippingProviderRepository.save(ShippingProvider.builder()
                        .name("Giao Hang Nhanh Standard")
                        .code("GHN_STANDARD")
                        .baseFee(20000.0)
                        .estimatedDays("2-3 ngay")
                        .build()));

        BookCopy copy = bookCopyRepository.findAll().stream()
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0)
                .findFirst().orElseThrow();

        cartService.clearCart(customer);
        cartService.addToCart(customer, copy.getId(), 1);

        List<Order> orders = checkoutService.processCheckout(customer, null, "Nguyen Van A", "0911222333",
                "123 Nguyen Hue", standardProvider.getId(), null, "COD", "Giao gio hanh chinh");

        assertThat(orders).isNotEmpty();
        Order order = orders.get(0);
        assertThat(order.getShippingProvider()).isNotNull();
        assertThat(order.getShippingProvider().getId()).isEqualTo(standardProvider.getId());

        // Táº¡o assignment kÃ¨m tracking code
        DeliveryAssignment assignment = deliveryAssignmentRepository.save(DeliveryAssignment.builder()
                .order(order)
                .status(DeliveryStatus.ASSIGNED)
                .trackingCode("GHN12345678VN")
                .note("Van chuyen GHN Standard")
                .build());

        assertThat(assignment.getTrackingCode()).isEqualTo("GHN12345678VN");

        // Gá»i controller orderDetail
        org.springframework.security.core.Authentication auth =
                new org.springframework.security.authentication.UsernamePasswordAuthenticationToken(
                        customer.getEmail(), null, List.of(new org.springframework.security.core.authority.SimpleGrantedAuthority("ROLE_USER")));
        org.springframework.ui.ConcurrentModel model = new org.springframework.ui.ConcurrentModel();

        String view = customerOrderController.orderDetail(order.getId(), true, auth, model);
        assertThat(view).isEqualTo("customer/order-detail");
        assertThat(model.getAttribute("order")).isEqualTo(order);
        assertThat(model.getAttribute("success")).isEqualTo(true);
        assertThat(model.getAttribute("assignment")).isNotNull();
    }

    @Test
    void outOfProvinceSpxShippingRemainsAvailableAtCheckout() {
        ShippingProvider spxProvider = shippingProviderRepository.findByActiveTrue().stream()
                .filter(provider -> "SPX_EXPRESS".equalsIgnoreCase(provider.getCode()))
                .findFirst().orElseThrow();
        User customer = getOrCreateCustomer("out-of-province-order@example.com");
        BookCopy copy = bookCopyRepository.findAll().stream()
                .filter(c -> c.getQuantity() != null && c.getQuantity() > 0)
                .findFirst().orElseThrow();

        cartService.clearCart(customer);
        cartService.addToCart(customer, copy.getId(), 1);

        org.springframework.security.core.Authentication auth =
                new org.springframework.security.authentication.UsernamePasswordAuthenticationToken(
                        customer.getEmail(), null,
                        List.of(new org.springframework.security.core.authority.SimpleGrantedAuthority("ROLE_USER")));
        org.springframework.ui.ConcurrentModel checkoutModel = new org.springframework.ui.ConcurrentModel();
        assertThat(checkoutController.showCheckoutPage(auth, checkoutModel)).isEqualTo("customer/checkout");
        @SuppressWarnings("unchecked")
        List<ShippingProvider> visibleProviders =
                (List<ShippingProvider>) checkoutModel.getAttribute("shippingProviders");
        assertThat(visibleProviders)
                .extracting(ShippingProvider::getCode)
                .contains("SPX_EXPRESS");

        Order order = checkoutService.processCheckout(customer, null, "Người nhận", "0912345678",
                "12 Trần Phú, Đà Nẵng", spxProvider.getId(), null, "COD", null).getFirst();

        assertThat(order.getShippingProvider()).isNotNull();
        assertThat(order.getShippingProvider().getCode()).isEqualTo("SPX_EXPRESS");
        assertThat(order.getShippingFee()).isEqualTo(spxProvider.getBaseFee());
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

    private Long activeProviderId() {
        return shippingProviderRepository.findByActiveTrue().stream()
                .filter(provider -> !"SPX_EXPRESS".equalsIgnoreCase(provider.getCode()))
                .findFirst()
                .orElseThrow()
                .getId();
    }
}
