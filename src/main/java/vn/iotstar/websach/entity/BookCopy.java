package vn.iotstar.websach.entity;

import jakarta.persistence.*;
import lombok.*;
import vn.iotstar.websach.entity.enums.BookCondition;
import vn.iotstar.websach.entity.enums.BookCopyStatus;

import java.time.LocalDateTime;

@Entity
@Table(name = "book_copies")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BookCopy {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "book_id", nullable = false)
    private Book book;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "branch_id", nullable = false)
    private Branch branch;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private BookCondition conditionRating; // LIKE_NEW, VERY_GOOD, GOOD, FAIR, POOR

    private Double purchasePrice; // Giá thu mua vào
    private Double sellingPrice;  // Giá bán ra cho khách

    private Integer quantity;

    @Enumerated(EnumType.STRING)
    @Column(length = 30, nullable = false)
    private BookCopyStatus status; // AVAILABLE, RESERVED, SOLD, TRANSFERRING

    @Column(columnDefinition = "TEXT")
    private String note; // Ghi chú về tình trạng vết ố, sờn bìa...

    @Column(length = 500)
    private String imageUrl; // Ảnh chụp thực tế sản phẩm cũ

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (status == null) status = BookCopyStatus.AVAILABLE;
        if (quantity == null) quantity = 1;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
