package vn.iotstar.websach.service;

import vn.iotstar.websach.entity.Review;
import vn.iotstar.websach.entity.User;

import java.util.List;

public interface ReviewService {
    Review addReview(User user, Long bookId, Long orderItemId, Integer rating, String comment, String imageUrl);
    boolean canUserReviewBook(User user, Long bookId);
    List<Review> getBookReviews(Long bookId);
    List<Review> getUserReviews(User user);
}
