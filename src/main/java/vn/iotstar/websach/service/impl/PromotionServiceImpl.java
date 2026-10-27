package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.dto.PromotionEligibilityDTO;
import vn.iotstar.websach.dto.PromotionPreviewResult;
import vn.iotstar.websach.entity.AppDiscount;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.CartItem;
import vn.iotstar.websach.entity.Promotion;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.PromotionType;
import vn.iotstar.websach.repository.AppDiscountRepository;
import vn.iotstar.websach.repository.BranchRepository;
import vn.iotstar.websach.repository.PromotionRepository;
import vn.iotstar.websach.service.CartService;
import vn.iotstar.websach.service.PromotionService;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class PromotionServiceImpl implements PromotionService {

    private final PromotionRepository promotionRepository;
    private final BranchRepository branchRepository;
    private final AppDiscountRepository appDiscountRepository;
    private final CartService cartService;

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

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
    public List<PromotionEligibilityDTO> evaluatePromotionsForCart(User user) {
        List<CartItem> cartItems = user != null ? cartService.getCartItems(user) : Collections.emptyList();
        double totalCartSubtotal = cartItems.stream()
                .mapToDouble(ci -> (ci.getBookCopy() != null && ci.getBookCopy().getSellingPrice() != null ? ci.getBookCopy().getSellingPrice() : 0.0) * ci.getQuantity())
                .sum();

        LocalDate today = LocalDate.now();
        List<PromotionEligibilityDTO> results = new ArrayList<>();

        // 1. Duyệt qua tất cả Promotion (Admin, Manager, Vendor)
        List<Promotion> promotions = promotionRepository.findAllByOrderByStartDateDesc();
        for (Promotion p : promotions) {
            PromotionEligibilityDTO dto = new PromotionEligibilityDTO();
            dto.setId(p.getId());
            dto.setCode(p.getDisplayCode());
            dto.setTitle(p.getTitle());
            dto.setDiscountPercent(p.getDiscountPercent());
            dto.setMaxDiscountAmount(p.getMaxDiscountAmount());
            dto.setMinOrderValue(p.getMinOrderValue());
            dto.setStartDate(p.getStartDate());
            dto.setEndDate(p.getEndDate());
            dto.setType(p.getType() == null ? PromotionType.PRODUCT_PERCENT : p.getType());

            // Phân loại Scope:
            // Admin: branch == null && vendor == null -> áp dụng mọi sách
            // Manager: branch != null && vendor == null -> áp dụng cho tất cả vendor của cơ sở đó
            // Vendor: vendor != null -> chỉ áp dụng cho sản phẩm do vendor đó bán
            List<CartItem> eligibleItems;
            if (p.isAdminPromotion()) {
                dto.setScopeType("ADMIN");
                dto.setScopeName("Toàn sàn (Admin)");
                eligibleItems = cartItems;
            } else if (p.isManagerPromotion()) {
                dto.setScopeType("MANAGER");
                String branchName = p.getBranch() != null ? p.getBranch().getName() : "Toàn cơ sở";
                dto.setScopeName("Cơ sở: " + branchName);
                eligibleItems = cartItems.stream()
                        .filter(ci -> ci.getBookCopy() != null && ci.getBookCopy().getBranch() != null
                                && p.getBranch() != null && Objects.equals(ci.getBookCopy().getBranch().getId(), p.getBranch().getId()))
                        .toList();
            } else {
                dto.setScopeType("VENDOR");
                String vendorName = p.getVendor() != null
                        ? (p.getVendor().getFullName() != null && !p.getVendor().getFullName().isBlank() ? p.getVendor().getFullName() : p.getVendor().getEmail())
                        : "Gian hàng";
                dto.setScopeName("Shop: " + vendorName);
                eligibleItems = cartItems.stream()
                        .filter(ci -> ci.getBookCopy() != null && ci.getBookCopy().getSeller() != null
                                && p.getVendor() != null && Objects.equals(ci.getBookCopy().getSeller().getId(), p.getVendor().getId()))
                        .toList();
            }

            double eligibleSubtotal = eligibleItems.stream()
                    .mapToDouble(ci -> (ci.getBookCopy() != null && ci.getBookCopy().getSellingPrice() != null ? ci.getBookCopy().getSellingPrice() : 0.0) * ci.getQuantity())
                    .sum();

            // Kiểm tra điều kiện
            boolean applicable = true;
            String reason = null;

            if (!Boolean.TRUE.equals(p.getActive())) {
                applicable = false;
                reason = "Chương trình tạm dừng";
            } else if (p.getStartDate() != null && today.isBefore(p.getStartDate())) {
                applicable = false;
                reason = "Chưa đến đợt áp dụng (từ " + p.getStartDate().format(DATE_FMT) + ")";
            } else if (p.getEndDate() != null && today.isAfter(p.getEndDate())) {
                applicable = false;
                reason = "Chương trình đã kết thúc (ngày " + p.getEndDate().format(DATE_FMT) + ")";
            } else if (eligibleItems.isEmpty()) {
                applicable = false;
                if (p.isVendorPromotion()) {
                    reason = "Giỏ hàng không có sản phẩm nào của " + dto.getScopeName();
                } else if (p.isManagerPromotion()) {
                    reason = "Giỏ hàng không có sản phẩm nào thuộc " + dto.getScopeName();
                } else {
                    reason = "Giỏ hàng không có sản phẩm phù hợp";
                }
            } else if (p.getMinOrderValue() != null && eligibleSubtotal < p.getMinOrderValue()) {
                applicable = false;
                double needed = p.getMinOrderValue() - eligibleSubtotal;
                reason = "Chưa đạt đơn tối thiểu " + formatMoney(p.getMinOrderValue()) + " (Cần mua thêm " + formatMoney(needed) + " từ " + dto.getScopeName() + ")";
            }

            dto.setApplicable(applicable);
            dto.setReason(reason);

            if (applicable) {
                double baseAmount = (p.getType() == PromotionType.SHIPPING_PERCENT) ? 20000.0 : eligibleSubtotal;
                double discount = baseAmount * (p.getDiscountPercent() != null ? p.getDiscountPercent() : 0.0) / 100.0;
                if (p.getMaxDiscountAmount() != null) {
                    discount = Math.min(discount, p.getMaxDiscountAmount());
                }
                dto.setEstimatedDiscount(discount);
            } else {
                dto.setEstimatedDiscount(0.0);
            }

            results.add(dto);
        }

        // 2. Duyệt qua AppDiscount (nếu có)
        List<AppDiscount> appDiscounts = appDiscountRepository.findAll();
        for (AppDiscount d : appDiscounts) {
            PromotionEligibilityDTO dto = new PromotionEligibilityDTO();
            dto.setId(d.getId());
            dto.setCode(d.getCode());
            dto.setTitle("Voucher hệ thống " + d.getCode());
            dto.setDiscountPercent(d.getDiscountPercent());
            dto.setMaxDiscountAmount(d.getMaxDiscountAmount());
            dto.setMinOrderValue(d.getMinOrderValue());
            dto.setStartDate(d.getStartDate());
            dto.setEndDate(d.getEndDate());
            dto.setType(PromotionType.PRODUCT_PERCENT);
            dto.setScopeType("ADMIN");
            dto.setScopeName("Toàn sàn (Hệ thống)");

            boolean applicable = true;
            String reason = null;
            if (!Boolean.TRUE.equals(d.getActive())) {
                applicable = false;
                reason = "Voucher đang tạm dừng";
            } else if (d.getStartDate() != null && today.isBefore(d.getStartDate())) {
                applicable = false;
                reason = "Chưa đến đợt áp dụng (từ " + d.getStartDate().format(DATE_FMT) + ")";
            } else if (d.getEndDate() != null && today.isAfter(d.getEndDate())) {
                applicable = false;
                reason = "Voucher đã hết hạn";
            } else if (cartItems.isEmpty()) {
                applicable = false;
                reason = "Giỏ hàng đang trống";
            } else if (d.getMinOrderValue() != null && totalCartSubtotal < d.getMinOrderValue()) {
                applicable = false;
                double needed = d.getMinOrderValue() - totalCartSubtotal;
                reason = "Chưa đạt đơn tối thiểu " + formatMoney(d.getMinOrderValue()) + " (Cần mua thêm " + formatMoney(needed) + ")";
            }

            dto.setApplicable(applicable);
            dto.setReason(reason);
            if (applicable) {
                double discount = totalCartSubtotal * (d.getDiscountPercent() != null ? d.getDiscountPercent() : 0.0) / 100.0;
                if (d.getMaxDiscountAmount() != null) {
                    discount = Math.min(discount, d.getMaxDiscountAmount());
                }
                dto.setEstimatedDiscount(discount);
            } else {
                dto.setEstimatedDiscount(0.0);
            }
            results.add(dto);
        }

        // Sắp xếp: Mã áp dụng được (applicable = true) đưa lên đầu, sắp xếp theo mức giảm giảm dần;
        // sau đó là các mã không áp dụng được (applicable = false)
        results.sort((a, b) -> {
            if (a.isApplicable() != b.isApplicable()) {
                return a.isApplicable() ? -1 : 1;
            }
            if (a.isApplicable()) {
                return Double.compare(b.getEstimatedDiscount() != null ? b.getEstimatedDiscount() : 0.0,
                        a.getEstimatedDiscount() != null ? a.getEstimatedDiscount() : 0.0);
            }
            return 0;
        });

        return results;
    }

    @Override
    public PromotionPreviewResult previewPromotion(User user, String codeOrTitle) {
        if (codeOrTitle == null || codeOrTitle.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập hoặc chọn mã giảm giá.");
        }
        String query = codeOrTitle.trim();
        List<CartItem> cartItems = user != null ? cartService.getCartItems(user) : Collections.emptyList();
        if (cartItems.isEmpty()) {
            throw new IllegalArgumentException("Giỏ hàng của bạn đang trống.");
        }
        double totalCartSubtotal = cartItems.stream()
                .mapToDouble(ci -> (ci.getBookCopy() != null && ci.getBookCopy().getSellingPrice() != null ? ci.getBookCopy().getSellingPrice() : 0.0) * ci.getQuantity())
                .sum();

        LocalDate today = LocalDate.now();

        // 1. Thử tìm trong Promotion
        Optional<Promotion> promoOpt = findByCodeOrTitle(query);
        if (promoOpt.isPresent()) {
            Promotion p = promoOpt.get();
            if (!Boolean.TRUE.equals(p.getActive())) {
                throw new IllegalArgumentException("Chương trình khuyến mãi '" + p.getTitle() + "' đang tạm dừng.");
            }
            if (p.getStartDate() != null && today.isBefore(p.getStartDate())) {
                throw new IllegalArgumentException("Mã khuyến mãi '" + p.getTitle() + "' chưa có hiệu lực (bắt đầu từ " + p.getStartDate().format(DATE_FMT) + ").");
            }
            if (p.getEndDate() != null && today.isAfter(p.getEndDate())) {
                throw new IllegalArgumentException("Mã khuyến mãi '" + p.getTitle() + "' đã hết hạn.");
            }

            List<CartItem> eligibleItems;
            String scopeLabel;
            if (p.isAdminPromotion()) {
                scopeLabel = "Toàn sàn (Admin) - Mọi sách";
                eligibleItems = cartItems;
            } else if (p.isManagerPromotion()) {
                String branchName = p.getBranch() != null ? p.getBranch().getName() : "Cơ sở";
                scopeLabel = "Toàn cơ sở: " + branchName;
                eligibleItems = cartItems.stream()
                        .filter(ci -> ci.getBookCopy() != null && ci.getBookCopy().getBranch() != null
                                && p.getBranch() != null && Objects.equals(ci.getBookCopy().getBranch().getId(), p.getBranch().getId()))
                        .toList();
                if (eligibleItems.isEmpty()) {
                    throw new IllegalArgumentException("Mã giảm giá này chỉ áp dụng cho các sản phẩm thuộc cơ sở " + branchName + ".");
                }
            } else {
                String vendorName = p.getVendor() != null
                        ? (p.getVendor().getFullName() != null && !p.getVendor().getFullName().isBlank() ? p.getVendor().getFullName() : p.getVendor().getEmail())
                        : "Gian hàng";
                scopeLabel = "Gian hàng: " + vendorName;
                eligibleItems = cartItems.stream()
                        .filter(ci -> ci.getBookCopy() != null && ci.getBookCopy().getSeller() != null
                                && p.getVendor() != null && Objects.equals(ci.getBookCopy().getSeller().getId(), p.getVendor().getId()))
                        .toList();
                if (eligibleItems.isEmpty()) {
                    throw new IllegalArgumentException("Mã giảm giá này chỉ áp dụng cho sản phẩm do gian hàng " + vendorName + " bán.");
                }
            }

            double eligibleSubtotal = eligibleItems.stream()
                    .mapToDouble(ci -> (ci.getBookCopy() != null && ci.getBookCopy().getSellingPrice() != null ? ci.getBookCopy().getSellingPrice() : 0.0) * ci.getQuantity())
                    .sum();

            if (p.getMinOrderValue() != null && eligibleSubtotal < p.getMinOrderValue()) {
                throw new IllegalArgumentException("Đơn hàng chưa đạt giá trị tối thiểu " + formatMoney(p.getMinOrderValue())
                        + " của mã này (sản phẩm hợp lệ hiện tại: " + formatMoney(eligibleSubtotal) + ").");
            }

            if (p.getDiscountPercent() == null || p.getDiscountPercent() <= 0 || p.getDiscountPercent() > 100) {
                throw new IllegalArgumentException("Cấu hình khuyến mãi không hợp lệ.");
            }

            double baseAmount = (p.getType() == PromotionType.SHIPPING_PERCENT) ? 20000.0 : eligibleSubtotal;
            double discount = baseAmount * p.getDiscountPercent() / 100.0;
            if (p.getMaxDiscountAmount() != null) {
                discount = Math.min(discount, p.getMaxDiscountAmount());
            }

            return PromotionPreviewResult.builder()
                    .valid(true)
                    .discountAmount(Math.max(0.0, discount))
                    .code(p.getDisplayCode())
                    .title(p.getTitle())
                    .scopeLabel(scopeLabel)
                    .message("Áp dụng thành công: " + p.getTitle() + " (" + scopeLabel + ")")
                    .build();
        }

        // 2. Thử tìm trong AppDiscount
        Optional<AppDiscount> discountOpt = appDiscountRepository.findByCodeAndActiveTrue(query.toUpperCase(Locale.ROOT));
        if (discountOpt.isPresent()) {
            AppDiscount d = discountOpt.get();
            if (d.getStartDate() != null && today.isBefore(d.getStartDate())) {
                throw new IllegalArgumentException("Mã voucher '" + d.getCode() + "' chưa có hiệu lực.");
            }
            if (d.getEndDate() != null && today.isAfter(d.getEndDate())) {
                throw new IllegalArgumentException("Mã voucher '" + d.getCode() + "' đã hết hạn.");
            }
            if (d.getMinOrderValue() != null && totalCartSubtotal < d.getMinOrderValue()) {
                throw new IllegalArgumentException("Giỏ hàng chưa đạt giá trị tối thiểu " + formatMoney(d.getMinOrderValue()) + " của voucher.");
            }
            if (d.getDiscountPercent() == null || d.getDiscountPercent() <= 0 || d.getDiscountPercent() > 100) {
                throw new IllegalArgumentException("Cấu hình voucher không hợp lệ.");
            }
            double discount = totalCartSubtotal * d.getDiscountPercent() / 100.0;
            if (d.getMaxDiscountAmount() != null) {
                discount = Math.min(discount, d.getMaxDiscountAmount());
            }
            return PromotionPreviewResult.builder()
                    .valid(true)
                    .discountAmount(Math.max(0.0, discount))
                    .code(d.getCode())
                    .title("Voucher toàn sàn " + d.getCode())
                    .scopeLabel("Toàn sàn (Hệ thống)")
                    .message("Áp dụng thành công voucher toàn sàn: " + d.getCode())
                    .build();
        }

        throw new IllegalArgumentException("Mã giảm giá '" + query + "' không tồn tại hoặc đã bị khóa.");
    }

    @Override
    public Optional<Promotion> findByCodeOrTitle(String query) {
        if (query == null || query.isBlank()) return Optional.empty();
        String q = query.trim();

        // 1. Theo code
        Optional<Promotion> byCode = promotionRepository.findByCodeIgnoreCase(q);
        if (byCode.isPresent()) return byCode;

        // 2. Theo displayCode hoặc ID (ví dụ VD1-2, CS1-3, AD4, KM2, hoặc số nguyên 2)
        String idCandidate = q;
        if (idCandidate.toUpperCase().startsWith("KM") || idCandidate.toUpperCase().startsWith("AD")) {
            idCandidate = idCandidate.substring(2);
        } else if (idCandidate.toUpperCase().startsWith("CS") || idCandidate.toUpperCase().startsWith("VD")) {
            int dash = idCandidate.indexOf('-');
            if (dash > 0 && dash < idCandidate.length() - 1) {
                idCandidate = idCandidate.substring(dash + 1);
            } else {
                idCandidate = idCandidate.substring(2);
            }
        }
        try {
            Long id = Long.parseLong(idCandidate);
            Optional<Promotion> byId = promotionRepository.findById(id);
            if (byId.isPresent()) return byId;
        } catch (NumberFormatException ignored) {}

        // 3. Theo title exact hoặc case-insensitive
        List<Promotion> all = promotionRepository.findAll();
        for (Promotion p : all) {
            if (p.getTitle() != null && p.getTitle().equalsIgnoreCase(q)) {
                return Optional.of(p);
            }
        }
        return Optional.empty();
    }

    private String formatMoney(Double amount) {
        if (amount == null) return "0 đ";
        return String.format("%,.0f đ", amount);
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
        
        if (details.getCode() != null && !details.getCode().isBlank()) {
            promotion.setCode(details.getCode().trim().toUpperCase(Locale.ROOT));
        } else {
            promotion.setCode(null);
        }
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
