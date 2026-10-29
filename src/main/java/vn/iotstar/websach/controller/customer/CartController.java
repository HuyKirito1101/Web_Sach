package vn.iotstar.websach.controller.customer;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.iotstar.websach.entity.CartItem;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.service.CartService;
import vn.iotstar.websach.service.UserService;

import java.util.List;
import vn.iotstar.websach.util.ExceptionMessages;

@Controller
@RequestMapping("/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;
    private final UserService userService;

    @GetMapping
    public String showCart(Authentication authentication, Model model) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/auth/login?error=unauthorized";
        }
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        List<CartItem> cartItems = cartService.getCartItems(user);
        Double total = cartService.getCartTotal(user);

        model.addAttribute("cartItems", cartItems);
        model.addAttribute("totalAmount", total);

        return "customer/cart";
    }

    @PostMapping("/add")
    public String addToCart(@RequestParam("bookCopyId") Long bookCopyId,
                            @RequestParam(value = "quantity", defaultValue = "1") Integer quantity,
                            @RequestParam(value = "buyNow", defaultValue = "false") Boolean buyNow,
                            org.springframework.web.servlet.mvc.support.RedirectAttributes redirectAttributes,
                            Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/auth/login?error=unauthorized";
        }
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        try {
            cartService.addToCart(user, bookCopyId, quantity);
            if (Boolean.TRUE.equals(buyNow)) {
                return "redirect:/checkout";
            }
            redirectAttributes.addFlashAttribute("successMessage", "Đã thêm sản phẩm vào giỏ hàng thành công!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/cart";
    }

    @PostMapping("/update")
    public String updateQuantity(@RequestParam("cartItemId") Long cartItemId,
                                 @RequestParam("quantity") Integer quantity,
                                 org.springframework.web.servlet.mvc.support.RedirectAttributes redirectAttributes,
                                 Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/auth/login?error=unauthorized";
        }
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        try {
            cartService.updateCartItemQuantity(user, cartItemId, quantity);
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/cart";
    }

    @PostMapping("/delete")
    public String deleteCartItem(@RequestParam("cartItemId") Long cartItemId,
                                 Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/auth/login?error=unauthorized";
        }
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        cartService.removeCartItem(user, cartItemId);
        return "redirect:/cart";
    }
}
