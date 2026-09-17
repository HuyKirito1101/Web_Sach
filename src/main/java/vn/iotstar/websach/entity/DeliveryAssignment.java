package vn.iotstar.websach.entity;

import jakarta.persistence.*;
import lombok.*;
import vn.iotstar.websach.entity.enums.DeliveryStatus;

import java.time.LocalDateTime;

@Entity
@Table(name = "delivery_assignments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeliveryAssignment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "shipper_id", nullable = false)
    private User shipper;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private DeliveryStatus status;

    @Column(columnDefinition = "TEXT")
    private String note;

    private LocalDateTime assignedAt;
    private LocalDateTime completedAt;

    @PrePersist
    protected void onCreate() {
        assignedAt = LocalDateTime.now();
        if (status == null) status = DeliveryStatus.ASSIGNED;
    }
}
