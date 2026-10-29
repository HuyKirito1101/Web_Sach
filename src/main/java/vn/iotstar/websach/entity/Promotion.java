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

    @Column(length = 50)
    private String code;

    @Column(nullable = false, length = 150)
    private String title;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "branch_id")
    private Branch branch; // Nếu null là do Admin tạo (áp dụng mọi sách), ngược lại do Manager/Vendor tạo

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vendor_id")
    private User vendor; // Nếu null là do Admin/Manager tạo, nếu có là do Vendor tạo (áp dụng sản phẩm của vendor)

    @Column(nullable = false)
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

    public boolean isAdminPromotion() {
        return this.branch == null && this.vendor == null;
    }

    public boolean isManagerPromotion() {
        return this.branch != null && this.vendor == null;
    }

    public boolean isVendorPromotion() {
        return this.vendor != null;
    }

    public String getDisplayCode() {
        if (code != null && !code.isBlank()) {
            return code.trim().toUpperCase(java.util.Locale.ROOT);
        }
        if (isVendorPromotion()) {
            return "VD" + (vendor != null ? vendor.getId() : "") + (id != null ? "-" + id : "");
        }
        if (isManagerPromotion()) {
            return "CS" + (branch != null ? branch.getId() : "") + (id != null ? "-" + id : "");
        }
        return "AD" + (id != null ? id : "0");
    }

    public String getScopeLabel() {
        if (isAdminPromotion()) {
            return "Toàn sàn (Admin)";
        }
        if (isManagerPromotion()) {
            return "Toàn cơ sở: " + (branch != null ? branch.getName() : "Chi nhánh");
        }
        String vendorName = vendor != null ? (vendor.getFullName() != null && !vendor.getFullName().isBlank() ? vendor.getFullName() : vendor.getEmail()) : "Gian hàng";
        return "Gian hàng: " + vendorName;
    }

    @PrePersist
    @PreUpdate
    protected void onSave() {
        if (active == null) active = true;
        if (type == null) type = PromotionType.PRODUCT_PERCENT;
        if (code != null && !code.isBlank()) {
            code = code.trim().toUpperCase(java.util.Locale.ROOT);
        }
    }
}
