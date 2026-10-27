package vn.iotstar.websach.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PromotionPreviewResult {
    private boolean valid;
    private double discountAmount;
    private String code;
    private String title;
    private String scopeLabel;
    private String message;
}
