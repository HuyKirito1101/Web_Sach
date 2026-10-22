package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.Book;
import vn.iotstar.websach.entity.OrderItem;
import vn.iotstar.websach.entity.Review;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.repository.BookRepository;
import vn.iotstar.websach.repository.OrderItemRepository;
import vn.iotstar.websach.repository.ReviewRepository;
import vn.iotstar.websach.service.ReviewService;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class ReviewServiceImpl implements ReviewService {

    private final ReviewRepository reviewRepository;
    private final BookRepository bookRepository;
    private final OrderItemRepository orderItemRepository;

    @Override
    public boolean canUserReviewBook(User user, Long bookId) {
        if (user == null || bookId == null) return false;
        return orderItemRepository.hasUserPurchasedBook(user.getId(), bookId);
    }

    @Override
    public Review addReview(User user, Long bookId, Long orderItemId, Integer rating, String comment, String imageUrl) {
        if (user == null) throw new IllegalArgumentException("Vui lòng đăng nhập!");
        if (comment == null || comment.trim().length() < 50) {
            throw new IllegalArgumentException("Nội dung đánh giá phải có tối thiểu 50 ký tự!");
        }

        if (!canUserReviewBook(user, bookId)) {
            throw new IllegalStateException("Bạn chỉ có thể đánh giá những cuốn sách đã mua và nhận hàng thành công (trạng thái Đã giao)!");
        }

        Book book = bookRepository.findById(bookId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy sách!"));

        OrderItem orderItem = null;
        if (orderItemId != null) {
            orderItem = orderItemRepository.findById(orderItemId).orElse(null);
        } else {
            List<OrderItem> deliveredItems = orderItemRepository.findDeliveredOrderItemsByUserAndBook(user.getId(), bookId);
            if (!deliveredItems.isEmpty()) {
                orderItem = deliveredItems.get(0);
            }
        }

        int r = (rating != null && rating >= 1 && rating <= 5) ? rating : 5;

        Review review = Review.builder()
                .user(user)
                .book(book)
                .orderItem(orderItem)
                .rating(r)
                .comment(comment.trim())
                .imageUrl(imageUrl)
                .build();

        return reviewRepository.save(review);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Review> getBookReviews(Long bookId) {
        Book book = bookRepository.findById(bookId).orElse(null);
        if (book == null) return List.of();
        return reviewRepository.findByBookOrderByCreatedAtDesc(book);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Review> getUserReviews(User user) {
        if (user == null) return List.of();
        return reviewRepository.findByUserOrderByCreatedAtDesc(user);
    }
}
