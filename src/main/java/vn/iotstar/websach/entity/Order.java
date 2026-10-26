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

    @ManyToOne(fetch = FetchType.EAGER)
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

    @Column(length = 20)
    private String returnMethod; // "STORE" hoặc "SHIPPER"

    @Column(length = 255)
    private String returnAddress;

    @Column(length = 500)
    private String returnReason;

    private Double returnShippingFee; // Phí ship hoàn trả khách chịu (50% nếu SHIPPER, 0đ nếu STORE)

    private Double refundAmount; // Số tiền hoàn trả cho khách sau khi trừ phí ship hoàn trả (nếu có)

    @Column(columnDefinition = "TEXT")
    private String note;

    private LocalDateTime paymentSubmittedAt;
    private LocalDateTime paymentConfirmedAt;

    @Column(length = 255)
    private String paymentConfirmedBy;

    @Column(nullable = false)
    private Boolean managerArchived;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public String getFormattedCreatedAt() {
        if (createdAt == null) return "";
        return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (orderStatus == null) orderStatus = OrderStatus.NEW;
        if (paymentStatus == null) paymentStatus = PaymentStatus.PENDING;
        if (managerArchived == null) managerArchived = false;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
