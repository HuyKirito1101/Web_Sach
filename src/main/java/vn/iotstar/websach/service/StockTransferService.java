package vn.iotstar.websach.service;

import vn.iotstar.websach.dto.StockTransferRequest;
import vn.iotstar.websach.entity.StockTransfer;

import java.util.List;
import java.util.Optional;

public interface StockTransferService {
    StockTransfer createTransferRequest(StockTransferRequest request, String userEmail);
    List<StockTransfer> findAllTransfers();
    List<StockTransfer> findTransfersByBranch(Long branchId);
    Optional<StockTransfer> findById(Long id);
    StockTransfer approveTransfer(Long transferId, String userEmail);
    StockTransfer rejectTransfer(Long transferId, String userEmail);
    StockTransfer completeTransfer(Long transferId, String userEmail);
}
