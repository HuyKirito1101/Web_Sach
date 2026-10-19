package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.Promotion;
import vn.iotstar.websach.entity.enums.PromotionType;
import vn.iotstar.websach.repository.BranchRepository;
import vn.iotstar.websach.repository.PromotionRepository;
import vn.iotstar.websach.service.PromotionService;

import java.time.LocalDate;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PromotionServiceImpl implements PromotionService {

    private final PromotionRepository promotionRepository;
    private final BranchRepository branchRepository;

    @Override
    public List<Promotion> findAllPromotions() {
        return promotionRepository.findAllByOrderByStartDateDesc();
    }

    @Override
    public List<Promotion> findByBranch(Long branchId) {
        return promotionRepository.findByBranchIdOrderByStartDateDesc(branchId);
    }

    @Override
    public List<Promotion> findApplicablePromotions(Long branchId, LocalDate date, double subtotal) {
        LocalDate effectiveDate = date == null ? LocalDate.now() : date;
        return promotionRepository.findAll().stream()
                .filter(p -> Boolean.TRUE.equals(p.getActive()))
                .filter(p -> p.getBranch() == null || Objects.equals(p.getBranch().getId(), branchId))
                .filter(p -> p.getStartDate() == null || !effectiveDate.isBefore(p.getStartDate()))
                .filter(p -> p.getEndDate() == null || !effectiveDate.isAfter(p.getEndDate()))
                .filter(p -> p.getMinOrderValue() == null || subtotal >= p.getMinOrderValue())
                .toList();
    }

    @Override
    @Transactional
    public Promotion saveForAdmin(Promotion details, Long branchId) {
        return save(details, branchId, true);
    }

    @Override
    @Transactional
    public Promotion saveForBranch(Promotion details, Long branchId) {
        return save(details, branchId, false);
    }

    private Promotion save(Promotion details, Long branchId, boolean allowGlobal) {
        validate(details);
        if (!allowGlobal && branchId == null) {
            throw new IllegalArgumentException("Manager phải thuộc một chi nhánh.");
        }

        Promotion promotion = details.getId() == null
                ? new Promotion()
                : promotionRepository.findById(details.getId())
                    .orElseThrow(() -> new IllegalArgumentException("Khuyến mãi không tồn tại."));

        if (!allowGlobal && promotion.getId() != null
                && (promotion.getBranch() == null || !Objects.equals(promotion.getBranch().getId(), branchId))) {
            throw new SecurityException("Không được sửa khuyến mãi của chi nhánh khác.");
        }

        Branch branch = branchId == null ? null : branchRepository.findById(branchId)
                .orElseThrow(() -> new IllegalArgumentException("Chi nhánh không tồn tại."));
        promotion.setTitle(details.getTitle().trim());
        promotion.setBranch(branch);
        promotion.setType(details.getType() == null ? PromotionType.PRODUCT_PERCENT : details.getType());
        promotion.setDiscountPercent(details.getDiscountPercent());
        promotion.setMaxDiscountAmount(details.getMaxDiscountAmount());
        promotion.setMinOrderValue(details.getMinOrderValue());
        promotion.setStartDate(details.getStartDate());
        promotion.setEndDate(details.getEndDate());
        promotion.setActive(details.getActive() == null || details.getActive());
        return promotionRepository.save(promotion);
    }

    private void validate(Promotion details) {
        if (details.getTitle() == null || details.getTitle().isBlank()) {
            throw new IllegalArgumentException("Tên chương trình không được để trống.");
        }
        if (details.getDiscountPercent() == null || details.getDiscountPercent() <= 0
                || details.getDiscountPercent() > 100) {
            throw new IllegalArgumentException("Phần trăm giảm phải lớn hơn 0 và không quá 100.");
        }
        if (details.getStartDate() == null || details.getEndDate() == null
                || details.getEndDate().isBefore(details.getStartDate())) {
            throw new IllegalArgumentException("Thời gian khuyến mãi không hợp lệ.");
        }
        if (details.getMaxDiscountAmount() != null && details.getMaxDiscountAmount() < 0) {
            throw new IllegalArgumentException("Mức giảm tối đa không được âm.");
        }
        if (details.getMinOrderValue() != null && details.getMinOrderValue() < 0) {
            throw new IllegalArgumentException("Giá trị đơn tối thiểu không được âm.");
        }
    }

    @Override
    @Transactional
    public void deleteForAdmin(Long id) {
        promotionRepository.deleteById(id);
    }

    @Override
    @Transactional
    public void deleteForBranch(Long id, Long branchId) {
        Promotion promotion = promotionRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Khuyến mãi không tồn tại."));
        if (promotion.getBranch() == null || !Objects.equals(promotion.getBranch().getId(), branchId)) {
            throw new SecurityException("Không được xóa khuyến mãi của chi nhánh khác.");
        }
        promotionRepository.delete(promotion);
    }
}
