package vn.iotstar.websach.controller.customer;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.service.CloudinaryService;
import vn.iotstar.websach.service.ReviewService;
import vn.iotstar.websach.service.UserService;

@Controller
@RequestMapping("/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;
    private final UserService userService;
    private final CloudinaryService cloudinaryService;

    @PostMapping("/add")
    public String addReview(@RequestParam("bookId") Long bookId,
                            @RequestParam(value = "orderItemId", required = false) Long orderItemId,
                            @RequestParam("rating") Integer rating,
                            @RequestParam("comment") String comment,
                            @RequestParam(value = "imageFile", required = false) MultipartFile imageFile,
                            @RequestParam(value = "imageUrl", required = false) String imageUrl,
                            @RequestParam(value = "videoUrl", required = false) String videoUrl,
                            Authentication authentication,
                            Model model) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        try {
            String mediaUrl = null;
            // 1. Ưu tiên upload file lên Cloudinary
            if (imageFile != null && !imageFile.isEmpty()) {
                mediaUrl = cloudinaryService.uploadFile(imageFile);
            }
            // 2. Nếu không upload file, dùng URL ảnh hoặc video cung cấp
            if (mediaUrl == null || mediaUrl.trim().isEmpty()) {
                if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                    mediaUrl = imageUrl.trim();
                } else if (videoUrl != null && !videoUrl.trim().isEmpty()) {
                    mediaUrl = videoUrl.trim();
                }
            }

            reviewService.addReview(user, bookId, orderItemId, rating, comment, mediaUrl);
            return "redirect:/books/" + bookId + "?reviewSuccess=true";
        } catch (Exception e) {
            return "redirect:/books/" + bookId + "?reviewError=" + java.net.URLEncoder.encode(e.getMessage(), java.nio.charset.StandardCharsets.UTF_8);
        }
    }
}
