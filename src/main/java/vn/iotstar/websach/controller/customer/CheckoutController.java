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
        model.addAttribute("shippingProviders", shippingProviderService.findAllProviders());
        model.addAttribute("subtotal", subtotal);
        model.addAttribute("user", user);
        // Danh sách mã giảm giá có thể dùng
        model.addAttribute("availableDiscounts", appDiscountService.findAllDiscounts()
                .stream().filter(d -> Boolean.TRUE.equals(d.getActive())).toList());

        return "customer/checkout";
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
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        try {
            Order order = checkoutService.processCheckout(user, addressId, recipientName, phone, shippingAddress,
                    shippingProviderId, voucherCode, paymentMethod, note);

            if ("VNPAY".equalsIgnoreCase(paymentMethod)) {
                return "redirect:/checkout/vnpay-demo?orderId=" + order.getId();
            }

            if ("MOMO".equalsIgnoreCase(paymentMethod)) {
                return "redirect:/checkout/momo-demo?orderId=" + order.getId();
            }

            return "redirect:/orders/" + order.getId() + "?success=true";
        } catch (Exception e) {
            model.addAttribute("errorMessage", e.getMessage());
            return showCheckoutPage(authentication, model);
        }
    }

    @GetMapping("/vnpay-demo")
    public String vnpayDemo(@RequestParam("orderId") Long orderId, Model model) {
        model.addAttribute("orderId", orderId);
        return "customer/vnpay-demo";
    }

    @GetMapping("/momo-demo")
    public String momoDemo(@RequestParam("orderId") Long orderId, Model model) {
        model.addAttribute("orderId", orderId);
        return "customer/momo-demo";
    }
}
