package vn.iotstar.websach.controller.customer;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.iotstar.websach.dto.PromotionEligibilityDTO;
import vn.iotstar.websach.dto.PromotionPreviewResult;
import vn.iotstar.websach.entity.Address;
import vn.iotstar.websach.entity.CartItem;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.service.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
    private final PromotionService promotionService;

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

        // Đánh giá tất cả khuyến mãi (Admin: mọi sách, Manager: toàn cơ sở, Vendor: riêng shop)
        List<PromotionEligibilityDTO> allVouchers = promotionService.evaluatePromotionsForCart(user);
        long applicableCount = allVouchers.stream().filter(PromotionEligibilityDTO::isApplicable).count();

        model.addAttribute("cartItems", cartItems);
        model.addAttribute("addresses", addresses);
        model.addAttribute("shippingProviders", shippingProviderService.findAllProviders().stream()
                .filter(provider -> Boolean.TRUE.equals(provider.getActive()))
                .toList());
        model.addAttribute("subtotal", subtotal);
        model.addAttribute("user", user);

        model.addAttribute("allVouchers", allVouchers);
        model.addAttribute("applicableCount", applicableCount);
        model.addAttribute("availableDiscounts", allVouchers.stream().filter(PromotionEligibilityDTO::isApplicable).toList());

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

        PromotionPreviewResult result = promotionService.previewPromotion(user, code);
        Map<String, Object> response = new HashMap<>();
        response.put("valid", result.isValid());
        response.put("discountAmount", result.getDiscountAmount());
        response.put("code", result.getCode());
        response.put("title", result.getTitle() != null ? result.getTitle() : "");
        response.put("scopeLabel", result.getScopeLabel() != null ? result.getScopeLabel() : "");
        response.put("message", result.getMessage() != null ? result.getMessage() : "");
        return response;
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
            model.addAttribute("recipientName", recipientName);
            model.addAttribute("phone", phone);
            model.addAttribute("shippingAddress", shippingAddress);
            model.addAttribute("selectedShippingProviderId", shippingProviderId);
            model.addAttribute("selectedPaymentMethod", paymentMethod);
            model.addAttribute("note", note);
            return showCheckoutPage(authentication, model);
        }
    }

}
