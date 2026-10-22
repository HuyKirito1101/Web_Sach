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
import java.net.URI;
import java.net.URISyntaxException;

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
        if (comment.trim().length() > 2000) {
            throw new IllegalArgumentException("Nội dung đánh giá không được vượt quá 2000 ký tự!");
        }

        if (!canUserReviewBook(user, bookId)) {
            throw new IllegalStateException("Bạn chỉ có thể đánh giá những cuốn sách đã mua và nhận hàng thành công (trạng thái Đã giao)!");
        }

        Book book = bookRepository.findById(bookId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy sách!"));

        List<OrderItem> deliveredItems = orderItemRepository
                .findDeliveredOrderItemsByUserAndBook(user.getId(), bookId);
        OrderItem orderItem = orderItemId == null
                ? deliveredItems.stream().findFirst().orElse(null)
                : deliveredItems.stream()
                        .filter(item -> orderItemId.equals(item.getId()))
                        .findFirst()
                        .orElse(null);
        if (orderItem == null) {
            throw new IllegalArgumentException("Đơn hàng dùng để đánh giá không hợp lệ.");
        }

        int r = (rating != null && rating >= 1 && rating <= 5) ? rating : 5;

        Review review = Review.builder()
                .user(user)
                .book(book)
                .orderItem(orderItem)
                .rating(r)
                .comment(comment.trim())
                .imageUrl(validateMediaUrl(imageUrl))
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

    private String validateMediaUrl(String value) {
        if (value == null || value.isBlank()) return null;
        if (value.length() > 500) {
            throw new IllegalArgumentException("Đường dẫn ảnh/video quá dài.");
        }
        try {
            URI uri = new URI(value.trim());
            if (!"https".equalsIgnoreCase(uri.getScheme()) || uri.getHost() == null
                    || uri.getUserInfo() != null) {
                throw new IllegalArgumentException("Đường dẫn ảnh/video phải là URL HTTPS hợp lệ.");
            }
            return uri.toASCIIString();
        } catch (URISyntaxException ex) {
            throw new IllegalArgumentException("Đường dẫn ảnh/video không hợp lệ.");
        }
    }
}
