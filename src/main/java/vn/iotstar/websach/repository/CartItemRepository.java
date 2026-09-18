package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.BookCopy;
import vn.iotstar.websach.entity.CartItem;
import vn.iotstar.websach.entity.User;

import java.util.List;
import java.util.Optional;

@Repository
public interface CartItemRepository extends JpaRepository<CartItem, Long> {
    List<CartItem> findByUserOrderByCreatedAtDesc(User user);
    Optional<CartItem> findByUserAndBookCopy(User user, BookCopy bookCopy);
    Optional<CartItem> findByIdAndUser(Long id, User user);
    void deleteByUser(User user);
}
