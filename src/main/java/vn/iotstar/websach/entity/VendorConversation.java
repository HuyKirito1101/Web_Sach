package vn.iotstar.websach.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Entity
@Table(name = "vendor_conversations")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VendorConversation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "customer_id", nullable = false)
    private User customer;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "vendor_id", nullable = false)
    private User vendor;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "book_copy_id")
    private BookCopy bookCopy;

    @Column(columnDefinition = "TEXT")
    private String lastMessage;

    private LocalDateTime lastMessageAt;

    @Column(nullable = false)
    private Boolean customerUnread;

    @Column(nullable = false)
    private Boolean vendorUnread;

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = createdAt;
        if (lastMessageAt == null) lastMessageAt = createdAt;
        if (customerUnread == null) customerUnread = false;
        if (vendorUnread == null) vendorUnread = false;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public String getFormattedLastMessageAt() {
        if (lastMessageAt == null) return "";
        return lastMessageAt.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }
}
