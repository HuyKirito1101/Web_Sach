package vn.iotstar.websach.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

/**
 * Phat thong bao don hang theo pham vi du lieu thay vi dung mot kenh chung
 * cho moi chi nhanh. Admin nhan kenh toan he thong, nhan vien chi nhanh chi
 * nhan kenh cua chi nhanh minh.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class RealtimeNotificationService {

    private final SimpMessagingTemplate messagingTemplate;

    public void notifyOrder(Long branchId, String message) {
        if (message == null || message.isBlank()) {
            return;
        }
        try {
            messagingTemplate.convertAndSend("/topic/orders/admin", message);
            if (branchId != null) {
                messagingTemplate.convertAndSend("/topic/orders/branch/" + branchId, message);
            }
        } catch (RuntimeException ex) {
            log.debug("Khong gui duoc thong bao WebSocket don hang: {}", ex.getMessage());
        }
    }
}
