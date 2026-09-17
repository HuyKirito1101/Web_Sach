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

    @Column(length = 20)
    private String phone;

    private Double baseFee;

    private Boolean active;

    @PrePersist
    protected void onCreate() {
        if (active == null) active = true;
        if (baseFee == null) baseFee = 25000.0;
    }
}
