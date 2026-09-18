package vn.iotstar.websach.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "sell_request_items")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SellRequestItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sell_request_id", nullable = false)
    private SellRequest sellRequest;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "book_id")
    private Book book;

    @Column(nullable = false, length = 255)
    private String bookTitle;
    @Column(length = 30)
    private String isbn;
    @Column(columnDefinition = "TEXT", nullable = false)
    private String conditionDescription;
    private Double expectedPrice;
    private Double offeredPrice;
    @Column(length = 500)
    private String imageUrl;
    @Column(columnDefinition = "TEXT")
    private String staffNote;
}
