package vn.iotstar.websach.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import vn.iotstar.websach.service.CategoryService;
import vn.iotstar.websach.service.CustomerBookService;

@Controller
@RequiredArgsConstructor
public class HomeController {

    private final CustomerBookService customerBookService;
    private final CategoryService categoryService;

    @GetMapping({"/", "/home"})
    public String home(Authentication authentication, Model model) {
        if (authentication != null && authentication.isAuthenticated()) {
            boolean isAdmin = authentication.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
            boolean isManager = authentication.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_MANAGER"));
            boolean isVendor = authentication.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_VENDOR"));
            boolean isShipper = authentication.getAuthorities().stream().anyMatch(a -> a.getAuthority().equals("ROLE_SHIPPER"));

            if (isAdmin) return "redirect:/admin/dashboard";
            if (isManager) return "redirect:/manager/dashboard";
            if (isVendor) return "redirect:/vendor/dashboard";
            if (isShipper) return "redirect:/shipper/dashboard";
        }

        model.addAttribute("newBooks", customerBookService.getTop20NewBooks());
        model.addAttribute("bestSellers", customerBookService.getTop20BestSellers());
        model.addAttribute("topRated", customerBookService.getTop20TopRated());
        model.addAttribute("categories", categoryService.findAllCategories());

        return "customer/home";
    }
}
