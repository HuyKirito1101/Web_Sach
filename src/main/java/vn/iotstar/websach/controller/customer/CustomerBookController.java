package vn.iotstar.websach.controller.customer;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.iotstar.websach.entity.Book;
import vn.iotstar.websach.entity.BookCopy;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.BookCondition;
import vn.iotstar.websach.service.*;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class CustomerBookController {

    private final CustomerBookService customerBookService;
    private final CategoryService categoryService;
    private final BranchService branchService;
    private final UserService userService;
    private final FavoriteService favoriteService;
    private final ViewedProductService viewedProductService;
    private final ReviewService reviewService;

    @GetMapping("/books")
    public String listBooks(@RequestParam(value = "keyword", required = false) String keyword,
                            @RequestParam(value = "categoryId", required = false) Long categoryId,
                            @RequestParam(value = "branchId", required = false) Long branchId,
                            @RequestParam(value = "condition", required = false) BookCondition condition,
                            @RequestParam(value = "minPrice", required = false) Double minPrice,
                            @RequestParam(value = "maxPrice", required = false) Double maxPrice,
                            @RequestParam(value = "sortBy", required = false) String sortBy,
                            Model model) {

        List<Book> books = customerBookService.searchAndFilterBooks(keyword, categoryId, branchId, condition, minPrice, maxPrice, sortBy);

        model.addAttribute("books", books);
        model.addAttribute("categories", categoryService.findAllCategories());
        model.addAttribute("branches", branchService.findAllBranches());
        model.addAttribute("conditions", BookCondition.values());

        model.addAttribute("keyword", keyword);
        model.addAttribute("selectedCategory", categoryId);
        model.addAttribute("selectedBranch", branchId);
        model.addAttribute("selectedCondition", condition);
        model.addAttribute("minPrice", minPrice);
        model.addAttribute("maxPrice", maxPrice);
        model.addAttribute("sortBy", sortBy);

        return "customer/book-list";
    }

    @GetMapping("/books/{id}")
    public String bookDetail(@PathVariable("id") Long id, Authentication authentication, Model model) {
        Book book = customerBookService.getBookById(id);
        if (book == null) {
            return "redirect:/books";
        }

        User user = null;
        if (authentication != null && authentication.isAuthenticated()) {
            user = userService.findByEmail(authentication.getName()).orElse(null);
            if (user != null) {
                viewedProductService.recordView(user, id);
                model.addAttribute("isFavorite", favoriteService.isFavorite(user, id));
            }
        }

        List<BookCopy> copies = customerBookService.getAvailableBookCopies(id);
        Double avgRating = customerBookService.getAverageRating(id);
        Long reviewCount = customerBookService.getReviewCount(id);

        model.addAttribute("book", book);
        model.addAttribute("copies", copies);
        model.addAttribute("avgRating", avgRating);
        model.addAttribute("reviewCount", reviewCount);
        model.addAttribute("reviews", reviewService.getBookReviews(id));

        return "customer/book-detail";
    }

    @GetMapping("/search")
    public String search(@RequestParam("keyword") String keyword) {
        return "redirect:/books?keyword=" + keyword;
    }
}
