package vn.iotstar.websach.service;

import vn.iotstar.websach.entity.Promotion;

import java.time.LocalDate;
import java.util.List;

public interface PromotionService {
    List<Promotion> findAllPromotions();
    List<Promotion> findByBranch(Long branchId);
    List<Promotion> findApplicablePromotions(Long branchId, LocalDate date, double subtotal);
    Promotion saveForAdmin(Promotion details, Long branchId);
    Promotion saveForBranch(Promotion details, Long branchId);
    void deleteForAdmin(Long id);
    void deleteForBranch(Long id, Long branchId);
}
