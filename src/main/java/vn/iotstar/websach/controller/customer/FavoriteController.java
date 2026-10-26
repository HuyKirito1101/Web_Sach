package vn.iotstar.websach.controller.customer;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.service.FavoriteService;
import vn.iotstar.websach.service.UserService;
import vn.iotstar.websach.service.ViewedProductService;

@Controller
@RequiredArgsConstructor
public class FavoriteController {

    private final FavoriteService favoriteService;
    private final ViewedProductService viewedProductService;
    private final UserService userService;

    @GetMapping("/favorites")
    public String listFavorites(Authentication authentication, Model model) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        model.addAttribute("favorites", favoriteService.getUserFavorites(user));
        return "customer/favorites";
    }

    @PostMapping("/favorites/toggle")
    public String toggleFavorite(@RequestParam("bookId") Long bookId, Authentication authentication) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user != null) {
            favoriteService.toggleFavorite(user, bookId);
        }
        return "redirect:/books/" + bookId;
    }

    @GetMapping("/viewed-products")
    public String listViewedProducts(Authentication authentication, Model model) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        model.addAttribute("viewedProducts", viewedProductService.getUserViewedProducts(user));
        return "customer/viewed-products";
    }

    @PostMapping("/viewed-products/clear")
    public String clearViewedProducts(Authentication authentication, RedirectAttributes redirectAttributes) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        long deletedCount = viewedProductService.clearUserViewedProducts(user);
        if (deletedCount > 0) {
            redirectAttributes.addFlashAttribute("successMessage",
                    "Đã xóa " + deletedCount + " mục khỏi lịch sử xem sách.");
        } else {
            redirectAttributes.addFlashAttribute("infoMessage", "Lịch sử xem sách đang trống.");
        }
        return "redirect:/viewed-products";
    }
}
