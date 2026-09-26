package vn.iotstar.websach.controller;

import lombok.RequiredArgsConstructor;
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
    public String home(Model model) {
        model.addAttribute("newBooks", customerBookService.getTop20NewBooks());
        model.addAttribute("bestSellers", customerBookService.getTop20BestSellers());
        model.addAttribute("topRated", customerBookService.getTop20TopRated());
        model.addAttribute("categories", categoryService.findAllCategories());

        return "customer/home";
    }
}
