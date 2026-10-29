package vn.iotstar.websach.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "shipping_providers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ShippingProvider {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 150)
    private String name;

    @Column(nullable = false, length = 50, unique = true)
    private String code; // GHN_STANDARD, GHN_EXPRESS, SPX_EXPRESS

    @Column(length = 100)
    private String serviceType; // Trong tỉnh (Tiêu chuẩn), Trong tỉnh (Hỏa tốc), Ngoại tỉnh (Liên tỉnh)

    @Column(length = 100)
    private String estimatedDays; // 1-2 ngày, 2-4 giờ trong ngày, 2-4 ngày

    @Column(length = 255)
    private String scopeDescription; // Vận chuyển đơn mua trong tỉnh, Giao hàng siêu tốc trong tỉnh, Vận chuyển đơn mua ngoại tỉnh

    @Column(length = 20)
    private String phone;

    @Column(nullable = false)
    private Double baseFee;

    @Column(nullable = false)
    private Boolean active;

    @PrePersist
    protected void onCreate() {
        if (active == null) active = true;
        if (baseFee == null) baseFee = 25000.0;
    }
}
