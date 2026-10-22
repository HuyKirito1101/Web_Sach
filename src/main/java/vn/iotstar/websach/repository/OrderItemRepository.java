package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.OrderItem;
import vn.iotstar.websach.entity.enums.OrderStatus;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

@Repository
public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {
    List<OrderItem> findByOrderId(Long orderId);
    List<OrderItem> findByOrderBranchIdAndOrderOrderStatus(Long branchId, OrderStatus status);

    @Query("SELECT COALESCE(SUM(oi.quantity), 0) FROM OrderItem oi WHERE oi.bookCopy.book.id = :bookId AND oi.order.orderStatus <> vn.iotstar.websach.entity.enums.OrderStatus.CANCELLED")
    Long getSoldQuantityByBookId(@Param("bookId") Long bookId);

    @Query("SELECT COUNT(oi) > 0 FROM OrderItem oi WHERE oi.order.customer.id = :userId AND oi.bookCopy.book.id = :bookId AND oi.order.orderStatus = vn.iotstar.websach.entity.enums.OrderStatus.DELIVERED")
    boolean hasUserPurchasedBook(@Param("userId") Long userId, @Param("bookId") Long bookId);

    @Query("SELECT oi FROM OrderItem oi WHERE oi.order.customer.id = :userId AND oi.bookCopy.book.id = :bookId AND oi.order.orderStatus = vn.iotstar.websach.entity.enums.OrderStatus.DELIVERED ORDER BY oi.id DESC")
    List<OrderItem> findDeliveredOrderItemsByUserAndBook(@Param("userId") Long userId, @Param("bookId") Long bookId);
}
