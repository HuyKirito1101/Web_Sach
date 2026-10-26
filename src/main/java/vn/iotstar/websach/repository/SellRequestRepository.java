package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import vn.iotstar.websach.entity.SellRequest;
import vn.iotstar.websach.entity.enums.SellRequestStatus;

import java.util.List;

public interface SellRequestRepository extends JpaRepository<SellRequest, Long> {
    List<SellRequest> findByBranchIdOrderByCreatedAtDesc(Long branchId);
    List<SellRequest> findByBranchIdAndStatusOrderByCreatedAtDesc(Long branchId, SellRequestStatus status);
    long countByBranchIdAndStatus(Long branchId, SellRequestStatus status);
    List<SellRequest> findByCustomerIdOrderByCreatedAtDesc(Long customerId);
    List<SellRequest> findByBuyerVendorIdAndStatus(Long buyerVendorId, SellRequestStatus status);

    // Mọi cơ sở/vendor đều thấy các yêu cầu đang mở (chưa ai mua thành công).
    // Khi có vendor đàm phán thành công (ACCEPTED, COMPLETED), CHỈ DUY NHẤT vendor mua mới thấy.
    // Các vendor khác (kể cả cùng chi nhánh) hoàn toàn độc lập và không thấy.
    @Query("SELECT r FROM SellRequest r WHERE " +
           "(r.status IN ('PENDING', 'INSPECTING') OR (r.status = 'QUOTED' AND (r.buyerVendor IS NULL OR r.buyerVendor.id = :vendorId))) OR " +
           "(r.status IN ('ACCEPTED', 'COMPLETED') AND r.buyerVendor.id = :vendorId) " +
           "ORDER BY r.createdAt DESC")
    List<SellRequest> findVisibleForVendor(@Param("vendorId") Long vendorId, @Param("branchId") Long branchId);

    @Query("SELECT r FROM SellRequest r WHERE " +
           "(((r.status IN ('PENDING', 'INSPECTING') OR (r.status = 'QUOTED' AND (r.buyerVendor IS NULL OR r.buyerVendor.id = :vendorId))) AND r.status = :status) OR " +
           "(r.status IN ('ACCEPTED', 'COMPLETED') AND r.status = :status AND r.buyerVendor.id = :vendorId)) " +
           "ORDER BY r.createdAt DESC")
    List<SellRequest> findVisibleForVendorAndStatus(@Param("vendorId") Long vendorId, @Param("branchId") Long branchId, @Param("status") SellRequestStatus status);
}
