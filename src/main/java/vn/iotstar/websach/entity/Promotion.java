package vn.iotstar.websach.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.format.annotation.DateTimeFormat;
import vn.iotstar.websach.entity.enums.PromotionType;

import java.time.LocalDate;

@Entity
@Table(name = "promotions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Promotion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 150)
    private String title;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "branch_id")
    private Branch branch; // Nếu null là áp dụng toàn hệ thống, ngược lại áp dụng cho chi nhánh

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vendor_id")
    private User vendor; // Nếu null là do Manager/Admin tạo (áp dụng chung cho toàn cơ sở), nếu có là của riêng Vendor

    private Double discountPercent;

    @Enumerated(EnumType.STRING)
    @Column(length = 30)
    private PromotionType type;

    private Double maxDiscountAmount;

    private Double minOrderValue;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate startDate;

    @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
    private LocalDate endDate;

    private Boolean active;

    @PrePersist
    protected void onCreate() {
        if (active == null) active = true;
        if (type == null) type = PromotionType.PRODUCT_PERCENT;
    }
}
