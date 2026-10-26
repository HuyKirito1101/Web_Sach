package vn.iotstar.websach.entity;

import jakarta.persistence.*;
import lombok.*;
import vn.iotstar.websach.entity.enums.SupportSenderType;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Entity
@Table(name = "support_messages")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SupportMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "conversation_id", nullable = false)
    private SupportConversation conversation;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private SupportSenderType senderType;

    @Column(nullable = false, length = 100)
    private String senderName;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
    }

    public String getFormattedCreatedAt() {
        if (createdAt == null) return "";
        return createdAt.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
    }
}
