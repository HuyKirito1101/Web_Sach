package vn.iotstar.websach.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.ManagerActivityLog;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.repository.ManagerActivityLogRepository;
import vn.iotstar.websach.repository.UserRepository;

import java.util.List;
import java.util.Locale;

@Service
@RequiredArgsConstructor
public class ManagerActivityLogService {

    private final ManagerActivityLogRepository activityLogRepository;
    private final UserRepository userRepository;

    @Transactional
    public void record(String actorEmail, String eventType, String description, String ipAddress, String userAgent) {
        saveEvent(actorEmail, ManagerActivityLog.builder()
                .eventType(eventType)
                .description(description)
                .ipAddress(limit(clean(ipAddress), 45))
                .userAgent(limit(clean(userAgent), 255))
                .build());
    }

    @Transactional
    public void recordLoginAttempt(String email,
                                   boolean success,
                                   String ipAddress,
                                   String userAgent,
                                   String failureReason) {
        String normalizedEmail = email == null || email.isBlank()
                ? "Không xác định" : email.trim().toLowerCase(Locale.ROOT);
        String eventType = success ? "LOGIN_SUCCESS" : "LOGIN_FAILURE";
        saveEvent(normalizedEmail, ManagerActivityLog.builder()
                .eventType(eventType)
                .description(success ? "Đăng nhập thành công" : "Đăng nhập thất bại")
                .ipAddress(limit(clean(ipAddress), 45))
                .userAgent(limit(clean(userAgent), 255))
                .failureReason(success ? null : limit(clean(failureReason), 180))
                .build());
    }

    private void saveEvent(String actorEmail, ManagerActivityLog event) {
        String normalizedEmail = actorEmail == null || actorEmail.isBlank()
                ? "Không xác định" : actorEmail.trim().toLowerCase(Locale.ROOT);
        User actor = userRepository.findByEmail(normalizedEmail).orElse(null);
        Branch branch = actor == null ? null : actor.getBranch();

        // 0 là nhóm sự kiện toàn hệ thống; bảng không có FK tới branches.
        event.setBranchId(branch == null ? 0L : branch.getId());
        event.setBranchName(branch == null ? "Toàn hệ thống" : branch.getName());
        event.setManagerEmail(limit(normalizedEmail, 150));
        event.setManagerName(limit(actor == null ? "Tài khoản chưa xác định" : actor.getFullName(), 100));
        activityLogRepository.save(event);
    }

    private String clean(String value) {
        return value == null ? null : value.replaceAll("[\\r\\n\\t]", " ").trim();
    }

    private String limit(String value, int maxLength) {
        return value == null || value.length() <= maxLength ? value : value.substring(0, maxLength);
    }

    @Transactional(readOnly = true)
    public List<ManagerActivityLog> recentSystemHistory() {
        return activityLogRepository.findTop100ByOrderByCreatedAtDesc();
    }
}
