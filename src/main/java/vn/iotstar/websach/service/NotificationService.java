package vn.iotstar.websach.service;

import java.util.Map;

public interface NotificationService {
    Map<String, Long> getNotificationAttributes(String email);
}
