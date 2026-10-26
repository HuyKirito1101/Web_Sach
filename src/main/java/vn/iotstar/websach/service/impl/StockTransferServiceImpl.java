package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.dto.StockTransferRequest;
import vn.iotstar.websach.entity.BookCopy;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.StockTransfer;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.BookCopyStatus;
import vn.iotstar.websach.entity.enums.RoleName;
import vn.iotstar.websach.entity.enums.TransferStatus;
import vn.iotstar.websach.repository.BookCopyRepository;
import vn.iotstar.websach.repository.BranchRepository;
import vn.iotstar.websach.repository.StockTransferRepository;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.service.StockTransferService;

import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class StockTransferServiceImpl implements StockTransferService {

    private final StockTransferRepository stockTransferRepository;
    private final BranchRepository branchRepository;
    private final BookCopyRepository bookCopyRepository;
    private final UserRepository userRepository;
    private final SimpMessagingTemplate messagingTemplate;

    @Override
    @Transactional
    public StockTransfer createTransferRequest(StockTransferRequest request, String userEmail) {
        if (request == null || request.getFromBranchId() == null || request.getToBranchId() == null
                || request.getBookCopyId() == null || request.getQuantity() == null
                || request.getQuantity() <= 0) {
            throw new IllegalArgumentException("Thông tin điều chuyển không hợp lệ.");
        }
        if (request.getFromBranchId().equals(request.getToBranchId())) {
            throw new IllegalArgumentException("Chi nhánh nguồn và chi nhánh nhận phải khác nhau.");
        }
        User user = requireManager(userEmail);
        requireActorBranch(user, request.getFromBranchId(), "Bạn chỉ được tạo điều chuyển từ chi nhánh mình quản lý.");

        Branch fromBranch = branchRepository.findById(request.getFromBranchId())
                .orElseThrow(() -> new RuntimeException("Chi nhánh nguồn không tồn tại"));
        Branch toBranch = branchRepository.findById(request.getToBranchId())
                .orElseThrow(() -> new RuntimeException("Chi nhánh đích không tồn tại"));

        BookCopy copy = bookCopyRepository.findById(request.getBookCopyId())
                .orElseThrow(() -> new RuntimeException("Bản sách cũ không tồn tại"));

        if (copy.getBranch() == null || !fromBranch.getId().equals(copy.getBranch().getId())) {
            throw new SecurityException("Sản phẩm không thuộc chi nhánh nguồn.");
        }
        if (copy.getStatus() != BookCopyStatus.AVAILABLE) {
            throw new IllegalStateException("Chỉ được điều chuyển sản phẩm đang bán.");
        }

        if (copy.getQuantity() < request.getQuantity()) {
            throw new RuntimeException("Chi nhánh nguồn không đủ số lượng sách để điều chuyển!");
        }

        StockTransfer transfer = StockTransfer.builder()
                .transferCode("TRF-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase())
                .fromBranch(fromBranch)
                .toBranch(toBranch)
                .bookCopy(copy)
                .quantity(request.getQuantity())
                .requestedBy(user)
                .status(TransferStatus.PENDING)
                .note(request.getNote())
                .build();

        StockTransfer saved = stockTransferRepository.save(transfer);

        // WebSockets Notify Manager of target branch & Admin
        try {
            messagingTemplate.convertAndSend("/topic/transfers", "Yêu cầu điều chuyển sách mới: " + saved.getTransferCode());
        } catch (Exception ignored) {}

        return saved;
    }

    @Override
    public List<StockTransfer> findAllTransfers() {
        return stockTransferRepository.findAll();
    }

    @Override
    public List<StockTransfer> findTransfersByBranch(Long branchId) {
        return stockTransferRepository.findAllByBranchId(branchId);
    }

    @Override
    public Optional<StockTransfer> findById(Long id) {
        return stockTransferRepository.findById(id);
    }

    @Override
    @Transactional
    public StockTransfer approveTransfer(Long transferId, String userEmail) {
        StockTransfer transfer = stockTransferRepository.findByIdForUpdate(transferId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lệnh điều chuyển id: " + transferId));

        if (transfer.getStatus() != TransferStatus.PENDING) {
            throw new RuntimeException("Yêu cầu điều chuyển này đã được xử lý trước đó!");
        }

        User user = requireManager(userEmail);
        requireActorBranch(user, transfer.getFromBranch().getId(),
                "Chỉ Manager chi nhánh nguồn được duyệt xuất kho.");
        BookCopy sourceCopy = bookCopyRepository.findByIdForUpdate(transfer.getBookCopy().getId())
                .orElseThrow(() -> new IllegalStateException("Sản phẩm nguồn không còn tồn tại."));
        if (sourceCopy.getQuantity() == null || sourceCopy.getQuantity() < transfer.getQuantity()) {
            throw new IllegalStateException("Tồn kho hiện tại không đủ để duyệt điều chuyển.");
        }
        transfer.setApprovedBy(user);
        transfer.setStatus(TransferStatus.SHIPPING);

        // Trừ bớt tồn kho ở chi nhánh nguồn
        sourceCopy.setQuantity(sourceCopy.getQuantity() - transfer.getQuantity());
        if (sourceCopy.getQuantity() == 0) {
            sourceCopy.setStatus(BookCopyStatus.TRANSFERRING);
        }
        bookCopyRepository.save(sourceCopy);

        return stockTransferRepository.save(transfer);
    }

    @Override
    @Transactional
    public StockTransfer rejectTransfer(Long transferId, String userEmail) {
        StockTransfer transfer = stockTransferRepository.findByIdForUpdate(transferId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lệnh điều chuyển id: " + transferId));

        if (transfer.getStatus() != TransferStatus.PENDING) {
            throw new IllegalStateException("Chỉ yêu cầu đang chờ mới được từ chối.");
        }
        User user = requireManager(userEmail);
        requireActorBranch(user, transfer.getFromBranch().getId(),
                "Chỉ Manager chi nhánh nguồn được từ chối điều chuyển.");
        transfer.setApprovedBy(user);
        transfer.setStatus(TransferStatus.REJECTED);

        return stockTransferRepository.save(transfer);
    }

    @Override
    @Transactional
    public StockTransfer completeTransfer(Long transferId, String userEmail) {
        StockTransfer transfer = stockTransferRepository.findByIdForUpdate(transferId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy lệnh điều chuyển id: " + transferId));

        if (transfer.getStatus() != TransferStatus.SHIPPING) {
            throw new RuntimeException("Lệnh điều chuyển phải ở trạng thái đang vận chuyển!");
        }
        User user = requireManager(userEmail);
        requireActorBranch(user, transfer.getToBranch().getId(),
                "Chỉ Manager chi nhánh nhận được xác nhận đã nhận sách.");

        transfer.setStatus(TransferStatus.COMPLETED);

        // Cộng tồn kho vào chi nhánh nhận
        BookCopy sourceCopy = transfer.getBookCopy();
        List<BookCopy> existingTargetCopies = bookCopyRepository.findByBookIdAndBranchIdForUpdate(
                sourceCopy.getBook().getId(), transfer.getToBranch().getId());

        Optional<BookCopy> matchingTarget = existingTargetCopies.stream()
                .filter(target -> target.getConditionRating() == sourceCopy.getConditionRating())
                .filter(target -> Objects.equals(target.getSellingPrice(), sourceCopy.getSellingPrice()))
                .filter(target -> Objects.equals(
                        target.getSeller() == null ? null : target.getSeller().getId(),
                        sourceCopy.getSeller() == null ? null : sourceCopy.getSeller().getId()))
                .findFirst();

        if (matchingTarget.isPresent()) {
            BookCopy targetCopy = matchingTarget.get();
            targetCopy.setQuantity((targetCopy.getQuantity() == null ? 0 : targetCopy.getQuantity())
                    + transfer.getQuantity());
            targetCopy.setStatus(BookCopyStatus.AVAILABLE);
            bookCopyRepository.save(targetCopy);
        } else {
            // Tạo mới BookCopy tại chi nhánh đích với thông tin tương đương
            BookCopy targetCopy = BookCopy.builder()
                    .book(sourceCopy.getBook())
                    .branch(transfer.getToBranch())
                    .seller(sourceCopy.getSeller())
                    .conditionRating(sourceCopy.getConditionRating())
                    .purchasePrice(sourceCopy.getPurchasePrice())
                    .sellingPrice(sourceCopy.getSellingPrice())
                    .quantity(transfer.getQuantity())
                    .status(BookCopyStatus.AVAILABLE)
                    .note((sourceCopy.getNote() == null ? "" : sourceCopy.getNote())
                            + " (Điều chuyển từ " + transfer.getFromBranch().getName() + ")")
                    .imageUrl(sourceCopy.getImageUrl())
                    .build();
            bookCopyRepository.save(targetCopy);
        }

        return stockTransferRepository.save(transfer);
    }

    private User requireManager(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new SecurityException("Không tìm thấy tài khoản Manager."));
        if (user.getRole() == null || user.getRole().getName() != RoleName.ROLE_MANAGER
                || user.getBranch() == null) {
            throw new SecurityException("Tài khoản không được phân công quản lý chi nhánh.");
        }
        return user;
    }

    private void requireActorBranch(User user, Long branchId, String message) {
        if (user.getBranch() == null || !branchId.equals(user.getBranch().getId())) {
            throw new SecurityException(message);
        }
    }
}
