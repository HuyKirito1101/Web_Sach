package vn.iotstar.websach.controller.customer;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.iotstar.websach.entity.Address;
import vn.iotstar.websach.entity.CartItem;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.service.*;

import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.time.LocalDate;

@Controller
@RequestMapping("/checkout")
@RequiredArgsConstructor
public class CheckoutController {

    private final CartService cartService;
    private final CheckoutService checkoutService;
    private final CustomerProfileService profileService;
    private final ShippingProviderService shippingProviderService;
    private final UserService userService;
    private final AppDiscountService appDiscountService;

    @GetMapping
    public String showCheckoutPage(Authentication authentication, Model model) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/auth/login?error=unauthorized";
        }
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        List<CartItem> cartItems = cartService.getCartItems(user);
        if (cartItems.isEmpty()) {
            return "redirect:/cart";
        }

        List<Address> addresses = profileService.getUserAddresses(user);
        Double subtotal = cartService.getCartTotal(user);

        model.addAttribute("cartItems", cartItems);
        model.addAttribute("addresses", addresses);
        model.addAttribute("shippingProviders", shippingProviderService.findAllProviders().stream()
                .filter(provider -> Boolean.TRUE.equals(provider.getActive()))
                .toList());
        model.addAttribute("subtotal", subtotal);
        model.addAttribute("user", user);
        // Danh sách mã giảm giá có thể dùng
        model.addAttribute("availableDiscounts", appDiscountService.findAllDiscounts()
                .stream().filter(d -> Boolean.TRUE.equals(d.getActive()))
                .filter(d -> d.getStartDate() == null || !LocalDate.now().isBefore(d.getStartDate()))
                .filter(d -> d.getEndDate() == null || !LocalDate.now().isAfter(d.getEndDate()))
                .filter(d -> d.getMinOrderValue() == null || subtotal >= d.getMinOrderValue())
                .toList());

        return "customer/checkout";
    }

    @GetMapping("/voucher-preview")
    @ResponseBody
    public Map<String, Object> previewVoucher(@RequestParam String code, Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new SecurityException("Vui lòng đăng nhập.");
        }
        User user = userService.findByEmail(authentication.getName())
                .orElseThrow(() -> new SecurityException("Tài khoản không tồn tại."));
        double subtotal = cartService.getCartTotal(user);
        var discount = appDiscountService.findByCode(code == null ? "" : code.trim().toUpperCase(Locale.ROOT))
                .orElseThrow(() -> new IllegalArgumentException("Mã voucher không tồn tại hoặc đã bị khóa."));
        LocalDate today = LocalDate.now();
        if (discount.getStartDate() != null && today.isBefore(discount.getStartDate())) {
            throw new IllegalArgumentException("Mã voucher chưa có hiệu lực.");
        }
        if (discount.getEndDate() != null && today.isAfter(discount.getEndDate())) {
            throw new IllegalArgumentException("Mã voucher đã hết hạn.");
        }
        if (discount.getMinOrderValue() != null && subtotal < discount.getMinOrderValue()) {
            throw new IllegalArgumentException("Giỏ hàng chưa đạt giá trị tối thiểu của voucher.");
        }
        if (discount.getDiscountPercent() == null || discount.getDiscountPercent() <= 0
                || discount.getDiscountPercent() > 100) {
            throw new IllegalArgumentException("Cấu hình voucher không hợp lệ.");
        }
        double amount = subtotal * discount.getDiscountPercent() / 100.0;
        if (discount.getMaxDiscountAmount() != null) amount = Math.min(amount, discount.getMaxDiscountAmount());
        return Map.of("valid", true, "discountAmount", Math.max(0.0, amount), "code", discount.getCode());
    }

    @ExceptionHandler({IllegalArgumentException.class, SecurityException.class})
    @ResponseBody
    @ResponseStatus(org.springframework.http.HttpStatus.BAD_REQUEST)
    public Map<String, Object> checkoutRequestError(RuntimeException ex) {
        return Map.of("valid", false, "message", ex.getMessage());
    }

    @PostMapping("/place-order")
    public String placeOrder(@RequestParam(value = "addressId", required = false) Long addressId,
                             @RequestParam(value = "recipientName", required = false) String recipientName,
                             @RequestParam(value = "phone", required = false) String phone,
                             @RequestParam(value = "shippingAddress", required = false) String shippingAddress,
                             @RequestParam(value = "shippingProviderId", required = false) Long shippingProviderId,
                             @RequestParam(value = "voucherCode", required = false) String voucherCode,
                             @RequestParam(value = "paymentMethod", defaultValue = "COD") String paymentMethod,
                             @RequestParam(value = "note", required = false) String note,
                             Authentication authentication,
                             Model model) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/auth/login?error=unauthorized";
        }
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        try {
            List<Order> orders = checkoutService.processCheckout(user, addressId, recipientName, phone, shippingAddress,
                    shippingProviderId, voucherCode, paymentMethod, note);

            if (orders.size() == 1) {
                return "redirect:/orders/" + orders.get(0).getId() + "?success=true";
            }
            return "redirect:/orders?multiSuccess=" + orders.size();
        } catch (Exception e) {
            model.addAttribute("errorMessage", e.getMessage());
            return showCheckoutPage(authentication, model);
        }
    }

}
