package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.Book;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.ViewedProduct;

import java.util.List;
import java.util.Optional;

@Repository
public interface ViewedProductRepository extends JpaRepository<ViewedProduct, Long> {
    List<ViewedProduct> findByUserOrderByViewedAtDesc(User user);
    Optional<ViewedProduct> findByUserAndBook(User user, Book book);
}
