package vn.iotstar.websach.security;

import org.springframework.stereotype.Component;

import java.time.Duration;
import java.time.Instant;
import java.util.Locale;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Giới hạn đơn giản theo tiến trình để chặn brute-force và spam OTP.
 * Khi triển khai nhiều máy chủ, thay bằng Redis/API gateway dùng chung.
 */
@Component
public class AuthRateLimiter {

    private final ConcurrentHashMap<String, AttemptWindow> attempts = new ConcurrentHashMap<>();

    public void checkAndRecord(String action, String identity, int maxAttempts, Duration window) {
        String key = action + ':' + normalize(identity);
        Instant now = Instant.now();
        AttemptWindow updated = attempts.compute(key, (ignored, current) -> {
            if (current == null || current.startedAt().plus(window).isBefore(now)) {
                return new AttemptWindow(1, now);
            }
            return new AttemptWindow(current.count() + 1, current.startedAt());
        });
        if (updated.count() > maxAttempts) {
            throw new IllegalStateException("Bạn đã thử quá nhiều lần. Vui lòng chờ rồi thử lại.");
        }
    }

    public void clear(String action, String identity) {
        attempts.remove(action + ':' + normalize(identity));
    }

    private String normalize(String value) {
        return value == null ? "unknown" : value.trim().toLowerCase(Locale.ROOT);
    }

    private record AttemptWindow(int count, Instant startedAt) {
    }
}
