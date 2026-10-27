package vn.iotstar.websach.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import vn.iotstar.websach.service.CategoryService;
import vn.iotstar.websach.service.CustomerBookService;
import vn.iotstar.websach.service.UserService;

@Controller
@RequiredArgsConstructor
public class HomeController {

    private final CustomerBookService customerBookService;
    private final CategoryService categoryService;
    private final UserService userService;

    @GetMapping({"/", "/home"})
    public String home(Authentication authentication, Model model) {
        if (authentication != null && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getPrincipal())) {
            String landingPage = userService.getLandingPage(authentication.getName());
            if (!"/".equals(landingPage)) {
                return "redirect:" + landingPage;
            }
        }
        // Top 10 sản phẩm bán trên 10 cuốn hoặc bán chạy theo số lượng giảm dần (cho cả Guest)
        model.addAttribute("topBooks", customerBookService.getTop10BestSellers());
        // Top 20 theo các tiêu chí
        model.addAttribute("newBooks", customerBookService.getTop20NewBooks());
        model.addAttribute("bestSellers", customerBookService.getTop20BestSellers());
        model.addAttribute("topRated", customerBookService.getTop20TopRated());
        model.addAttribute("topFavorites", customerBookService.getTop20MostFavorite());
        model.addAttribute("categories", categoryService.findAllCategories());

        return "customer/home";
    }
}
