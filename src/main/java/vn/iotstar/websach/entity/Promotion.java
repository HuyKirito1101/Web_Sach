package vn.iotstar.websach.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name = "promotions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Promotion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 150)
    private String title;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "branch_id")
    private Branch branch; // Nếu null là áp dụng toàn hệ thống, ngược lại áp dụng cho chi nhánh

    private Double discountPercent;

    private LocalDate startDate;
    private LocalDate endDate;

    private Boolean active;

    @PrePersist
    protected void onCreate() {
        if (active == null) active = true;
    }
}
