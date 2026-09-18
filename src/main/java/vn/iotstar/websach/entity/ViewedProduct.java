package vn.iotstar.websach.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "viewed_products")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ViewedProduct {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "book_id", nullable = false)
    private Book book;

    private LocalDateTime viewedAt;

    @PrePersist
    @PreUpdate
    protected void onSave() {
        viewedAt = LocalDateTime.now();
    }
}
