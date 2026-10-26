package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.Promotion;

import java.util.List;

@Repository
public interface PromotionRepository extends JpaRepository<Promotion, Long> {
    List<Promotion> findByBranchId(Long branchId);
    List<Promotion> findByBranchIdOrderByStartDateDesc(Long branchId);
    List<Promotion> findAllByOrderByStartDateDesc();

    @Query("SELECT p FROM Promotion p WHERE p.branch.id = :branchId AND (p.vendor.id = :vendorId OR p.vendor IS NULL) ORDER BY p.startDate DESC")
    List<Promotion> findApplicableForVendor(@Param("branchId") Long branchId, @Param("vendorId") Long vendorId);
}
