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
        // Top 10 sản phẩm sắp xếp giá cao → thấp (cho cả Guest)
        model.addAttribute("topBooks", customerBookService.getTop10ByPriceDesc());
        // Top 20 theo các tiêu chí
        model.addAttribute("newBooks", customerBookService.getTop20NewBooks());
        model.addAttribute("bestSellers", customerBookService.getTop20BestSellers());
        model.addAttribute("topRated", customerBookService.getTop20TopRated());
        model.addAttribute("topFavorites", customerBookService.getTop20MostFavorite());
        model.addAttribute("categories", categoryService.findAllCategories());

        return "customer/home";
    }
}
