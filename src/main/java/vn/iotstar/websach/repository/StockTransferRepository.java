package vn.iotstar.websach.repository;

import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.StockTransfer;
import vn.iotstar.websach.entity.enums.TransferStatus;

import java.util.List;
import java.util.Optional;

@Repository
public interface StockTransferRepository extends JpaRepository<StockTransfer, Long> {
    List<StockTransfer> findByFromBranchIdOrToBranchId(Long fromBranchId, Long toBranchId);
    List<StockTransfer> findByStatus(TransferStatus status);

    @Query("SELECT st FROM StockTransfer st WHERE st.fromBranch.id = :branchId OR st.toBranch.id = :branchId")
    List<StockTransfer> findAllByBranchId(@Param("branchId") Long branchId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT st FROM StockTransfer st WHERE st.id = :id")
    Optional<StockTransfer> findByIdForUpdate(@Param("id") Long id);
}
