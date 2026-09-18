package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.enums.OrderStatus;

import java.util.List;
import java.util.Optional;

@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    Optional<Order> findByOrderCode(String orderCode);
    List<Order> findByCustomerId(Long customerId);
    List<Order> findByBranchId(Long branchId);
    List<Order> findByBranchIdOrderByCreatedAtDesc(Long branchId);
    List<Order> findByBranchIdAndOrderStatus(Long branchId, OrderStatus orderStatus);
    List<Order> findByOrderStatus(OrderStatus orderStatus);
    long countByBranchId(Long branchId);
    long countByBranchIdAndOrderStatus(Long branchId, OrderStatus orderStatus);

    @Query("SELECT SUM(o.finalAmount) FROM Order o WHERE o.orderStatus = 'DELIVERED'")
    Double getTotalSystemRevenue();

    @Query("SELECT SUM(o.finalAmount) FROM Order o WHERE o.branch.id = :branchId AND o.orderStatus = 'DELIVERED'")
    Double getBranchRevenue(@Param("branchId") Long branchId);

    @Query("SELECT SUM(o.appCommissionAmount) FROM Order o WHERE o.orderStatus = 'DELIVERED'")
    Double getTotalAppCommission();
}
