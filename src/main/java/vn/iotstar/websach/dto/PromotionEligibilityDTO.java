package vn.iotstar.websach.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import vn.iotstar.websach.entity.enums.PromotionType;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PromotionEligibilityDTO {
    private Long id;
    private String code;
    private String title;
    private Double discountPercent;
    private Double maxDiscountAmount;
    private Double minOrderValue;
    private LocalDate startDate;
    private LocalDate endDate;
    private PromotionType type;

    // "ADMIN", "MANAGER", "VENDOR"
    private String scopeType;
    private String scopeName;

    // true = hiện sáng, có thể chọn; false = hiện mờ / hơi tối, không chọn được
    private boolean applicable;
    private String reason; // Lý do không áp dụng được
    private Double estimatedDiscount; // Mức giảm ước tính
}
