package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import vn.iotstar.websach.dto.SellRequestSubmission;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.SellRequest;
import vn.iotstar.websach.entity.SellRequestItem;
import vn.iotstar.websach.entity.SellRequestQuote;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.BranchStatus;
import vn.iotstar.websach.entity.enums.SellRequestQuoteStatus;
import vn.iotstar.websach.entity.enums.SellRequestStatus;
import vn.iotstar.websach.repository.BranchRepository;
import vn.iotstar.websach.repository.SellRequestQuoteRepository;
import vn.iotstar.websach.repository.SellRequestRepository;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.service.CloudinaryService;
import vn.iotstar.websach.service.CustomerSellRequestService;
import vn.iotstar.websach.service.RealtimeNotificationService;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class CustomerSellRequestServiceImpl implements CustomerSellRequestService {

    private static final String DEFAULT_BOOK_IMAGE =
            "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500&q=80";

    private final SellRequestRepository sellRequestRepository;
    private final SellRequestQuoteRepository sellRequestQuoteRepository;
    private final BranchRepository branchRepository;
    private final UserRepository userRepository;
    private final CloudinaryService cloudinaryService;
    private final RealtimeNotificationService realtimeNotificationService;

    @Override
    public List<Branch> getActiveBranches() {
        return branchRepository.findAll().stream()
                .filter(branch -> branch.getStatus() == BranchStatus.ACTIVE)
                .toList();
    }

    @Override
    public User getCustomer(String email) {
        return requireCustomer(email);
    }

    @Override
    public List<SellRequest> getCustomerRequests(String email) {
        return sellRequestRepository.findByCustomerIdOrderByCreatedAtDesc(requireCustomer(email).getId());
    }

    @Override
    @Transactional
    public SellRequest submitRequest(String email, SellRequestSubmission submission) {
        User customer = requireCustomer(email);
        Branch branch = resolveBranch(submission.getBranchId());
        List<String> titles = submission.getBookTitles();
        if (titles == null || titles.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập ít nhất một cuốn sách cần bán!");
        }
        if (submission.getPickupAddress() == null || submission.getPickupAddress().isBlank()) {
            throw new IllegalArgumentException("Địa chỉ lấy sách không được để trống.");
        }
        if (submission.getPhone() == null || submission.getPhone().isBlank()) {
            throw new IllegalArgumentException("Số điện thoại liên hệ không được để trống.");
        }

        SellRequest request = SellRequest.builder()
                .customer(customer)
                .branch(branch)
                .status(SellRequestStatus.PENDING)
                .note(buildPickupNote(submission))
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        double totalExpected = 0.0;
        List<SellRequestItem> items = new ArrayList<>();
        for (int i = 0; i < titles.size(); i++) {
            String title = titles.get(i);
            if (title == null || title.isBlank()) {
                continue;
            }
            Double price = valueAt(submission.getExpectedPrices(), i, 0.0);
            if (price < 0) {
                throw new IllegalArgumentException("Giá mong muốn không được âm.");
            }
            String imageUrl = resolveImage(submission, i);
            SellRequestItem item = SellRequestItem.builder()
                    .sellRequest(request)
                    .bookTitle(title.trim())
                    .isbn(valueAt(submission.getIsbns(), i, null))
                    .conditionDescription(normalizeCondition(valueAt(submission.getConditions(), i, null)))
                    .expectedPrice(price)
                    .imageUrl(imageUrl)
                    .build();
            totalExpected += price;
            items.add(item);
        }
        if (items.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập thông tin hợp lệ của ít nhất một cuốn sách!");
        }

        request.setExpectedTotal(totalExpected);
        request.setItems(items);
        SellRequest saved = sellRequestRepository.save(request);
        notifyOrders(branch.getId(), "Khách hàng " + customer.getFullName() + " vừa gửi yêu cầu thu mua sách #"
                + saved.getId() + " (" + items.size() + " cuốn) tại cơ sở " + branch.getName());
        return saved;
    }

    @Override
    @Transactional
    public SellRequestQuote acceptQuote(String email, Long requestId, Long quoteId) {
        User customer = requireCustomer(email);
        SellRequest request = requireOwnedRequest(customer, requestId);
        SellRequestQuote selected = sellRequestQuoteRepository.findById(quoteId)
                .filter(quote -> Objects.equals(quote.getSellRequest().getId(), request.getId()))
                .orElseThrow(() -> new IllegalArgumentException("Báo giá của Shop không hợp lệ hoặc đã hết hạn!"));

        LocalDateTime now = LocalDateTime.now();
        for (SellRequestQuote quote : sellRequestQuoteRepository
                .findBySellRequestIdOrderByCreatedAtDesc(request.getId())) {
            quote.setStatus(Objects.equals(quote.getId(), selected.getId())
                    ? SellRequestQuoteStatus.ACCEPTED : SellRequestQuoteStatus.REJECTED);
            quote.setUpdatedAt(now);
            sellRequestQuoteRepository.save(quote);
        }

        request.setBuyerVendor(selected.getVendor());
        request.setBranch(selected.getBranch() != null ? selected.getBranch()
                : selected.getVendor().getBranch() != null ? selected.getVendor().getBranch() : request.getBranch());
        request.setOfferedTotal(selected.getOfferedPrice());
        request.setStaffNote(selected.getNote());
        request.setStatus(SellRequestStatus.ACCEPTED);
        request.setUpdatedAt(now);
        sellRequestRepository.save(request);

        notifyOrders(request.getBranch() == null ? null : request.getBranch().getId(),
                "Khách hàng " + customer.getFullName() + " đã chấp nhận bán sách cho Shop "
                + selected.getVendorName() + " (Yêu cầu #" + request.getId() + " - Giá: "
                + String.format("%,.0f đ", selected.getOfferedPrice()) + ")");
        return selected;
    }

    @Override
    @Transactional
    public SellRequest acceptOffer(String email, Long requestId) {
        User customer = requireCustomer(email);
        SellRequest request = requireOwnedRequest(customer, requestId);
        if (request.getStatus() != SellRequestStatus.QUOTED) {
            throw new IllegalStateException("Yêu cầu chưa có báo giá hợp lệ để chấp nhận.");
        }
        request.setStatus(SellRequestStatus.ACCEPTED);
        request.setUpdatedAt(LocalDateTime.now());
        if (request.getBuyerVendor() == null && request.getBranch() != null) {
            request.setBuyerVendor(request.getBranch().getOwner());
        }
        SellRequest saved = sellRequestRepository.save(request);
        notifyOrders(saved.getBranch() == null ? null : saved.getBranch().getId(),
                "Khách hàng đã đồng ý mức giá thu mua cho yêu cầu #" + saved.getId());
        return saved;
    }

    @Override
    @Transactional
    public SellRequest cancelRequest(String email, Long requestId) {
        User customer = requireCustomer(email);
        SellRequest request = requireOwnedRequest(customer, requestId);
        if (request.getStatus() == SellRequestStatus.COMPLETED) {
            throw new IllegalStateException("Không thể hủy yêu cầu đã hoàn tất.");
        }
        request.setStatus(SellRequestStatus.CANCELLED);
        request.setUpdatedAt(LocalDateTime.now());
        return sellRequestRepository.save(request);
    }

    private User requireCustomer(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy thông tin tài khoản"));
    }

    private SellRequest requireOwnedRequest(User customer, Long requestId) {
        return sellRequestRepository.findById(requestId)
                .filter(request -> Objects.equals(request.getCustomer().getId(), customer.getId()))
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy yêu cầu thu mua hợp lệ!"));
    }

    private Branch resolveBranch(Long branchId) {
        if (branchId != null) {
            Branch selected = branchRepository.findById(branchId).orElse(null);
            if (selected != null && selected.getStatus() == BranchStatus.ACTIVE) {
                return selected;
            }
        }
        return getActiveBranches().stream().findFirst()
                .orElseThrow(() -> new IllegalStateException("Hiện chưa có chi nhánh hoạt động để tiếp nhận sách."));
    }

    private String buildPickupNote(SellRequestSubmission submission) {
        String result = "Địa chỉ lấy sách tận nhà: " + submission.getPickupAddress().trim()
                + " (SĐT: " + submission.getPhone().trim() + ")";
        return submission.getNote() == null || submission.getNote().isBlank()
                ? result : result + " | Ghi chú: " + submission.getNote().trim();
    }

    private String resolveImage(SellRequestSubmission submission, int index) {
        MultipartFile file = valueAt(submission.getImageFiles(), index, null);
        if (file != null && !file.isEmpty()) {
            try {
                String uploaded = cloudinaryService.uploadFile(file);
                if (uploaded != null && !uploaded.isBlank()) {
                    return uploaded.trim();
                }
            } catch (RuntimeException ex) {
                log.warn("Không tải được ảnh sách lên Cloudinary, dùng URL dự phòng: {}", ex.getMessage());
            }
        }
        String url = valueAt(submission.getImageUrls(), index, null);
        return url == null || url.isBlank() ? DEFAULT_BOOK_IMAGE : url.trim();
    }

    private String normalizeCondition(String condition) {
        return condition == null || condition.isBlank() ? "Bìa còn nguyên, trang đủ" : condition.trim();
    }

    private <T> T valueAt(List<T> values, int index, T fallback) {
        return values != null && index >= 0 && index < values.size() && values.get(index) != null
                ? values.get(index) : fallback;
    }

    private void notifyOrders(Long branchId, String message) {
        realtimeNotificationService.notifyOrder(branchId, message);
    }
}
