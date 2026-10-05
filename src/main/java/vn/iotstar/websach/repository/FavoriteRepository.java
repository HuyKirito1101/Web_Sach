package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.Book;
import vn.iotstar.websach.entity.Favorite;
import vn.iotstar.websach.entity.User;

import java.util.List;
import java.util.Optional;

@Repository
public interface FavoriteRepository extends JpaRepository<Favorite, Long> {
    List<Favorite> findByUserOrderByCreatedAtDesc(User user);
    Optional<Favorite> findByUserAndBook(User user, Book book);
    boolean existsByUserAndBook(User user, Book book);
    long countByBook(Book book);

    @Query("SELECT f.book, COUNT(f) AS cnt FROM Favorite f GROUP BY f.book ORDER BY cnt DESC")
    List<Object[]> findTopFavoriteBooks();
}
