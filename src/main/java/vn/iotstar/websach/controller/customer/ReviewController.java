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
                            @RequestParam(value = "videoUrl", required = false) String videoUrl,
                            Authentication authentication,
                            Model model) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        try {
            // Kết hợp imageUrl và videoUrl nếu cần
            String mediaUrl = imageUrl;
            if ((imageUrl == null || imageUrl.trim().isEmpty()) && videoUrl != null && !videoUrl.trim().isEmpty()) {
                mediaUrl = videoUrl;
            }
            reviewService.addReview(user, bookId, orderItemId, rating, comment, mediaUrl);
            return "redirect:/books/" + bookId + "?reviewSuccess=true";
        } catch (Exception e) {
            return "redirect:/books/" + bookId + "?reviewError=" + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8);
        }
    }
}
