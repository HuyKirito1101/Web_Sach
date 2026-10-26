package vn.iotstar.websach.entity;

import jakarta.persistence.*;
import lombok.*;
import vn.iotstar.websach.entity.enums.SellRequestQuoteStatus;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Entity
@Table(name = "sell_request_quotes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SellRequestQuote {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sell_request_id", nullable = false)
    private SellRequest sellRequest;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "vendor_id", nullable = false)
    private User vendor;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "branch_id", nullable = true)
    private Branch branch;

    @Column(nullable = false)
    private Double offeredPrice;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private SellRequestQuoteStatus status;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @PrePersist
    void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = createdAt;
        if (status == null) status = SellRequestQuoteStatus.PENDING;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public String getFormattedCreatedAt() {
        if (createdAt == null) return "";
        return createdAt.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public String getFormattedUpdatedAt() {
        if (updatedAt == null) return "";
        return updatedAt.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public String getVendorName() {
        if (vendor != null && vendor.getFullName() != null && !vendor.getFullName().isBlank()) {
            return vendor.getFullName();
        }
        if (branch != null && branch.getName() != null) {
            return branch.getName();
        }
        return "Cửa hàng đối tác";
    }
}
