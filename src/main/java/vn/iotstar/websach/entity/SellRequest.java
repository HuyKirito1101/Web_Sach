package vn.iotstar.websach.entity;

import jakarta.persistence.*;
import lombok.*;
import vn.iotstar.websach.entity.enums.SellRequestStatus;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "sell_requests")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SellRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id", nullable = false)
    private User customer;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "branch_id", nullable = true)
    private Branch branch;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "buyer_vendor_id", nullable = true)
    private User buyerVendor;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private SellRequestStatus status;

    private Double expectedTotal;
    private Double offeredTotal;

    @Column(columnDefinition = "TEXT")
    private String note;

    @Column(columnDefinition = "TEXT")
    private String staffNote;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "sellRequest", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<SellRequestItem> items = new ArrayList<>();

    @OneToMany(mappedBy = "sellRequest", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.EAGER)
    @OrderBy("createdAt DESC")
    @Builder.Default
    private List<SellRequestQuote> quotes = new ArrayList<>();

    @PrePersist
    void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = createdAt;
        if (status == null) status = SellRequestStatus.PENDING;
    }

    @PreUpdate
    void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public String getFormattedCreatedAt() {
        if (createdAt == null) return "";
        return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public String getFormattedUpdatedAt() {
        if (updatedAt == null) return "";
        return updatedAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public boolean isNegotiated() {
        return status == SellRequestStatus.ACCEPTED || status == SellRequestStatus.COMPLETED;
    }

    public String getBuyerVendorName() {
        if (buyerVendor != null && buyerVendor.getFullName() != null) {
            return buyerVendor.getFullName();
        }
        if (branch != null && branch.getName() != null) {
            return branch.getName();
        }
        return "Cửa hàng đối tác";
    }

    public long getActiveQuoteCount() {
        if (quotes == null) return 0;
        return quotes.stream()
                .filter(q -> q.getStatus() == vn.iotstar.websach.entity.enums.SellRequestQuoteStatus.PENDING 
                          || q.getStatus() == vn.iotstar.websach.entity.enums.SellRequestQuoteStatus.ACCEPTED)
                .count();
    }
}
