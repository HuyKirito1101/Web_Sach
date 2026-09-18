package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.Book;
import vn.iotstar.websach.entity.Review;
import vn.iotstar.websach.entity.User;

import java.util.List;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {
    List<Review> findByBookOrderByCreatedAtDesc(Book book);
    List<Review> findByUserOrderByCreatedAtDesc(User user);

    @Query("SELECT AVG(r.rating) FROM Review r WHERE r.book = :book")
    Double getAverageRatingForBook(@Param("book") Book book);

    @Query("SELECT COUNT(r) FROM Review r WHERE r.book = :book")
    Long countReviewsForBook(@Param("book") Book book);
}
