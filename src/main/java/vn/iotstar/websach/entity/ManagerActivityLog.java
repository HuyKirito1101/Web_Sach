package vn.iotstar.websach.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Entity
@Table(name = "manager_activity_logs", indexes = {
        @Index(name = "idx_manager_activity_branch_created", columnList = "branch_id, created_at")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ManagerActivityLog {

    private static final DateTimeFormatter DISPLAY_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "branch_id", nullable = false)
    private Long branchId;

    @Column(name = "branch_name", nullable = false, length = 150)
    private String branchName;

    @Column(name = "manager_email", nullable = false, length = 150)
    private String managerEmail;

    @Column(name = "manager_name", nullable = false, length = 100)
    private String managerName;

    @Column(name = "event_type", nullable = false, length = 30)
    private String eventType;

    @Column(nullable = false, length = 255)
    private String description;

    @Column(name = "ip_address", length = 45)
    private String ipAddress;

    @Column(name = "user_agent", length = 255)
    private String userAgent;

    @Column(name = "failure_reason", length = 180)
    private String failureReason;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) createdAt = LocalDateTime.now();
    }

    public String getFormattedCreatedAt() {
        return createdAt == null ? "" : createdAt.format(DISPLAY_FORMAT);
    }
}
