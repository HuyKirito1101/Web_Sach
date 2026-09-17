package vn.iotstar.websach.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "app_discounts")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AppDiscount {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String code; // Mã voucher, ví dụ: SACHCU10

    private Double discountPercent; // % giảm giá (vd: 10 = 10%)
    private Double maxDiscountAmount; // Số tiền giảm tối đa
    private Double minOrderValue; // Giá trị đơn hàng tối thiểu

    private LocalDate startDate;
    private LocalDate endDate;

    private Boolean active;

    @PrePersist
    protected void onCreate() {
        if (active == null) active = true;
    }
}
