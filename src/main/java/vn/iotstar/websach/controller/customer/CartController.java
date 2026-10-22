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

@Controller
@RequestMapping("/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;
    private final UserService userService;

    @GetMapping
    public String showCart(Authentication authentication, Model model) {
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
                            org.springframework.web.servlet.mvc.support.RedirectAttributes redirectAttributes,
                            Authentication authentication) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        try {
            cartService.addToCart(user, bookCopyId, quantity);
            redirectAttributes.addFlashAttribute("successMessage", "Đã thêm sản phẩm vào giỏ hàng thành công!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/cart";
    }

    @PostMapping("/update")
    public String updateQuantity(@RequestParam("cartItemId") Long cartItemId,
                                 @RequestParam("quantity") Integer quantity,
                                 org.springframework.web.servlet.mvc.support.RedirectAttributes redirectAttributes,
                                 Authentication authentication) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        try {
            cartService.updateCartItemQuantity(user, cartItemId, quantity);
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/cart";
    }

    @PostMapping("/delete")
    public String deleteCartItem(@RequestParam("cartItemId") Long cartItemId,
                                 Authentication authentication) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        cartService.removeCartItem(user, cartItemId);
        return "redirect:/cart";
    }
}
