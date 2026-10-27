package vn.iotstar.websach.service;

import vn.iotstar.websach.dto.PromotionEligibilityDTO;
import vn.iotstar.websach.dto.PromotionPreviewResult;
import vn.iotstar.websach.entity.Promotion;
import vn.iotstar.websach.entity.User;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface PromotionService {
    List<Promotion> findAllPromotions();
    List<Promotion> findByBranch(Long branchId);
    List<Promotion> findApplicablePromotions(Long branchId, LocalDate date, double subtotal);
    Promotion saveForAdmin(Promotion details, Long branchId);
    Promotion saveForBranch(Promotion details, Long branchId);
    void deleteForAdmin(Long id);
    void deleteForBranch(Long id, Long branchId);

    // Đánh giá mã giảm giá cho giỏ hàng của user (sáng nếu áp dụng được, tối nếu không đủ điều kiện)
    List<PromotionEligibilityDTO> evaluatePromotionsForCart(User user);

    // Xem trước và kiểm tra tính hợp lệ của mã giảm giá khi user nhập hoặc chọn
    PromotionPreviewResult previewPromotion(User user, String codeOrTitle);

    // Tìm kiếm promotion theo code, displayCode, title hoặc id
    Optional<Promotion> findByCodeOrTitle(String query);
}
