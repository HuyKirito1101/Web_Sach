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
    @JoinColumn(name = "order_id", nullable = true)
    private Order order;

    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "sell_request_id", nullable = true)
    private SellRequest sellRequest;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "shipper_id", nullable = true)
    private User shipper;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "assigned_by")
    private User assignedBy;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private DeliveryStatus status;

    @Column(columnDefinition = "TEXT")
    private String note;

    private LocalDateTime assignedAt;
    private LocalDateTime pickedUpAt;
    private LocalDateTime deliveredAt;
    private LocalDateTime completedAt;

    public String getFormattedAssignedAt() {
        if (assignedAt == null) return "";
        return assignedAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public String getFormattedPickedUpAt() {
        if (pickedUpAt == null) return "";
        return pickedUpAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public String getFormattedDeliveredAt() {
        if (deliveredAt == null) return "";
        return deliveredAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    public String getFormattedCompletedAt() {
        if (completedAt == null) return "";
        return completedAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }

    @Column(length = 500)
    private String failureReason;

    @Column(name = "rejected_shipper_ids", length = 255)
    private String rejectedShipperIds;

    @Column(length = 100)
    private String trackingCode;

    public String getTrackingCode() {
        if (trackingCode != null && !trackingCode.isBlank()) {
            return trackingCode;
        }
        if (note != null) {
            String marker = "Mã vận đơn: ";
            if (note.contains(marker)) {
                try {
                    int start = note.indexOf(marker) + marker.length();
                    int end = note.indexOf(" |", start);
                    if (end == -1) end = note.length();
                    return note.substring(start, end).trim();
                } catch (Exception ignored) {}
            }
        }
        if (id != null) {
            return "VD" + String.format("%08d", id);
        }
        return null;
    }

    public boolean hasShipperRejected(Long shipperId) {
        if (shipperId == null) return false;
        if (rejectedShipperIds != null && rejectedShipperIds.contains("," + shipperId + ",")) {
            return true;
        }
        if (status == DeliveryStatus.CANCELLED && shipper != null && java.util.Objects.equals(shipper.getId(), shipperId)) {
            return true;
        }
        return false;
    }

    public void addRejectedShipper(Long shipperId) {
        if (shipperId == null) return;
        if (rejectedShipperIds == null || rejectedShipperIds.isBlank()) {
            rejectedShipperIds = "," + shipperId + ",";
        } else if (!rejectedShipperIds.contains("," + shipperId + ",")) {
            rejectedShipperIds = rejectedShipperIds + shipperId + ",";
        }
    }

    public boolean isForSellRequest() {
        return sellRequest != null;
    }

    public String getBranchName() {
        if (order != null && order.getBranch() != null) return order.getBranch().getName();
        if (sellRequest != null && sellRequest.getBranch() != null) return sellRequest.getBranch().getName();
        return "Chi nhánh";
    }

    public String getBranchAddress() {
        if (order != null && order.getBranch() != null) return order.getBranch().getAddress();
        if (sellRequest != null && sellRequest.getBranch() != null) return sellRequest.getBranch().getAddress();
        return "";
    }

    public String getReferenceCode() {
        if (order != null) return order.getOrderCode();
        if (sellRequest != null) return "SR-#" + sellRequest.getId();
        return "N/A";
    }

    public String getCustomerName() {
        if (order != null) return order.getReceiverName();
        if (sellRequest != null && sellRequest.getCustomer() != null) return sellRequest.getCustomer().getFullName();
        return "Khách hàng";
    }

    public String getCustomerPhone() {
        if (order != null) return order.getReceiverPhone();
        if (sellRequest != null && sellRequest.getCustomer() != null) return sellRequest.getCustomer().getPhone();
        return "";
    }

    public String getPickupAddress() {
        if (order != null) {
            return (order.getReturnAddress() != null && !order.getReturnAddress().isBlank())
                    ? order.getReturnAddress() : order.getShippingAddress();
        }
        if (sellRequest != null) {
            return sellRequest.getNote();
        }
        return "";
    }

    @PrePersist
    protected void onCreate() {
        assignedAt = LocalDateTime.now();
        if (status == null) status = DeliveryStatus.ASSIGNED;
    }
}
