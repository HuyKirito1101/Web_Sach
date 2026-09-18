package vn.iotstar.websach.controller.customer;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.service.ReviewService;
import vn.iotstar.websach.service.UserService;

@Controller
@RequestMapping("/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;
    private final UserService userService;

    @PostMapping("/add")
    public String addReview(@RequestParam("bookId") Long bookId,
                            @RequestParam(value = "orderItemId", required = false) Long orderItemId,
                            @RequestParam("rating") Integer rating,
                            @RequestParam("comment") String comment,
                            @RequestParam(value = "imageUrl", required = false) String imageUrl,
                            Authentication authentication,
                            Model model) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        try {
            reviewService.addReview(user, bookId, orderItemId, rating, comment, imageUrl);
            return "redirect:/books/" + bookId + "?reviewSuccess=true";
        } catch (Exception e) {
            return "redirect:/books/" + bookId + "?reviewError=" + e.getMessage();
        }
    }
}
