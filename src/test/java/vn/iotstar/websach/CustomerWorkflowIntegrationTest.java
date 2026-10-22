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
@ActiveProfiles("h2")
@Transactional
class CustomerWorkflowIntegrationTest {

    @Autowired private CartService cartService;
    @Autowired private CheckoutService checkoutService;
    @Autowired private CustomerOrderService customerOrderService;
    @Autowired private OrderService orderService;
    @Autowired private ReviewService reviewService;
    @Autowired private UserService userService;

    @Autowired private UserRepository userRepository;
    @Autowired private BookRepository bookRepository;
    @Autowired private BookCopyRepository bookCopyRepository;
    @Autowired private BranchRepository branchRepository;
    @Autowired private AppDiscountRepository appDiscountRepository;
    @Autowired private OrderRepository orderRepository;
    @Autowired private OrderItemRepository orderItemRepository;

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
                "Address", null, futureVoucher.getCode(), "COD", null))
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
                "Address", null, expiredVoucher.getCode(), "COD", null))
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
                "Address", null, highMinOrderVoucher.getCode(), "COD", null))
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
                "123 Võ Văn Ngân", null, null, "VNPAY", "Ghi chú đơn");

        // Phải tách thành 2 đơn riêng biệt
        assertThat(orders).hasSize(2);
        assertThat(orders.stream().map(o -> o.getBranch().getId()).toList())
                .containsExactlyInAnyOrder(b1.getId(), b2.getId());

        // Đơn hàng khởi tạo phải có trạng thái thanh toán PENDING (kể cả VNPAY)
        for (Order o : orders) {
            assertThat(o.getPaymentStatus()).isEqualTo(PaymentStatus.PENDING);
            assertThat(o.getOrderStatus()).isEqualTo(OrderStatus.NEW);
        }

        // Giỏ hàng phải được làm trống sau khi checkout
        assertThat(cartService.getCartItems(user)).isEmpty();
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
                "Address", null, null, "COD", null);
        Order order = orders.get(0);

        // 1. Không thể trả hàng khi đơn chưa DELIVERED
        assertThat(customerOrderService.requestReturnOrder(user, order.getId(), "Sách lỗi")).isFalse();

        // 2. Chuyển đơn sang DELIVERED
        orderService.updateOrderStatus(order.getId(), OrderStatus.CONFIRMED);
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
                "Address", null, null, "COD", null);
        Order order = orders.get(0);
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
        verify(emailService).sendOtpEmail(eq(email), otpCaptor.capture());
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
