package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.iotstar.websach.entity.SellRequest;
import vn.iotstar.websach.entity.enums.SellRequestStatus;

import java.util.List;

public interface SellRequestRepository extends JpaRepository<SellRequest, Long> {
    List<SellRequest> findByBranchIdOrderByCreatedAtDesc(Long branchId);
    List<SellRequest> findByBranchIdAndStatusOrderByCreatedAtDesc(Long branchId, SellRequestStatus status);
}
