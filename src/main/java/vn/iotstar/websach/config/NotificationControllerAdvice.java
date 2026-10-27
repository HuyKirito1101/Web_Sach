package vn.iotstar.websach.config;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;
import vn.iotstar.websach.service.NotificationService;

@ControllerAdvice
@RequiredArgsConstructor
public class NotificationControllerAdvice {

    private final NotificationService notificationService;

    @ModelAttribute
    public void addNotificationAttributes(Model model) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()
                || "anonymousUser".equals(authentication.getName())) {
            return;
        }
        model.addAllAttributes(notificationService.getNotificationAttributes(authentication.getName()));
    }
}
