package vn.iotstar.websach.entity;

import jakarta.persistence.*;
import lombok.*;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.entity.enums.PaymentMethod;
import vn.iotstar.websach.entity.enums.PaymentStatus;

import java.time.LocalDateTime;

@Entity
@Table(name = "orders")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String orderCode;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "customer_id", nullable = false)
    private User customer;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "branch_id", nullable = false)
    private Branch branch;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "shipping_provider_id")
    private ShippingProvider shippingProvider;

    @Column(length = 100)
    private String receiverName;

    @Column(length = 20)
    private String receiverPhone;

    @Column(length = 255)
    private String shippingAddress;

    private Double totalAmount;
    private Double shippingFee;
    private Double discountAmount;
    private Double appCommissionAmount; // Phí chiết khấu app được tính cho đơn hàng này
    private Double finalAmount;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private PaymentMethod paymentMethod;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private PaymentStatus paymentStatus;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private OrderStatus orderStatus;

    @Column(columnDefinition = "TEXT")
    private String note;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (orderStatus == null) orderStatus = OrderStatus.NEW;
        if (paymentStatus == null) paymentStatus = PaymentStatus.PENDING;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
