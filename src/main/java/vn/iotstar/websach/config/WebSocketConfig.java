package vn.iotstar.websach.config;

import lombok.RequiredArgsConstructor;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.repository.VendorConversationRepository;

import java.security.Principal;

@Configuration
@EnableWebSocketMessageBroker
@RequiredArgsConstructor
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    private final UserRepository userRepository;
    private final VendorConversationRepository vendorConversationRepository;

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/topic", "/queue");
        config.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws").withSockJS();
    }

    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        registration.interceptors(new ChannelInterceptor() {
            @Override
            public Message<?> preSend(Message<?> message, MessageChannel channel) {
                StompHeaderAccessor accessor = StompHeaderAccessor.wrap(message);
                StompCommand command = accessor.getCommand();
                if (command == StompCommand.CONNECT || command == StompCommand.SUBSCRIBE) {
                    Principal principal = accessor.getUser();
                    if (!(principal instanceof Authentication authentication)
                            || !authentication.isAuthenticated()) {
                        throw new AccessDeniedException("WebSocket yêu cầu đăng nhập.");
                    }
                    if (command == StompCommand.SUBSCRIBE) {
                        authorizeSubscription(accessor.getDestination(), authentication);
                    }
                }
                return message;
            }
        });
    }

    void authorizeSubscription(String destination, Authentication authentication) {
        if (destination == null) {
            throw new AccessDeniedException("Kênh WebSocket không hợp lệ.");
        }
        if ("/topic/orders".equals(destination) || "/topic/orders/admin".equals(destination)) {
            requireAnyRole(authentication, "ROLE_ADMIN");
            return;
        }
        if (destination.startsWith("/topic/orders/branch/")) {
            if (hasRole(authentication, "ROLE_ADMIN")) {
                return;
            }
            requireAnyRole(authentication, "ROLE_MANAGER", "ROLE_VENDOR", "ROLE_SHIPPER");
            Long requestedBranchId = parseIdAfterPrefix(destination, "/topic/orders/branch/",
                    "Kenh don hang chi nhanh khong hop le.");
            User currentUser = requireCurrentUser(authentication);
            if (currentUser.getBranch() == null
                    || !requestedBranchId.equals(currentUser.getBranch().getId())) {
                throw new AccessDeniedException("Khong duoc theo doi don hang cua chi nhanh khac.");
            }
            return;
        }
        if ("/topic/transfers".equals(destination)) {
            requireAnyRole(authentication, "ROLE_ADMIN", "ROLE_MANAGER");
            return;
        }
        if (destination.startsWith("/topic/shipper/")) {
            if (hasRole(authentication, "ROLE_ADMIN")) {
                return;
            }
            requireAnyRole(authentication, "ROLE_SHIPPER");
            Long requestedId;
            try {
                requestedId = Long.valueOf(destination.substring("/topic/shipper/".length()));
            } catch (NumberFormatException ex) {
                throw new AccessDeniedException("Kênh shipper không hợp lệ.");
            }
            boolean ownsChannel = userRepository.findByEmail(authentication.getName())
                    .map(user -> requestedId.equals(user.getId()))
                    .orElse(false);
            if (!ownsChannel) {
                throw new AccessDeniedException("Không được theo dõi thông báo của shipper khác.");
            }
            return;
        }
        if (destination.startsWith("/topic/support/branch/")) {
            requireAnyRole(authentication, "ROLE_MANAGER");
            Long requestedBranchId;
            try {
                requestedBranchId = Long.valueOf(destination.substring("/topic/support/branch/".length()));
            } catch (NumberFormatException ex) {
                throw new AccessDeniedException("Kênh hỗ trợ chi nhánh không hợp lệ.");
            }
            boolean managesBranch = userRepository.findByEmail(authentication.getName())
                    .filter(user -> user.getBranch() != null)
                    .map(user -> requestedBranchId.equals(user.getBranch().getId()))
                    .orElse(false);
            if (!managesBranch) {
                throw new AccessDeniedException("Không được theo dõi tin nhắn của chi nhánh khác.");
            }
            return;
        }
        if (destination.startsWith("/topic/vendor-chat/")) {
            Long conversationId = parseIdAfterPrefix(destination, "/topic/vendor-chat/",
                    "Kenh hoi thoai khong hop le.");
            if (hasRole(authentication, "ROLE_ADMIN")) {
                return;
            }
            Long currentUserId = requireCurrentUser(authentication).getId();
            boolean isParticipant = vendorConversationRepository.findById(conversationId)
                    .map(conversation -> currentUserId.equals(conversation.getCustomer().getId())
                            || currentUserId.equals(conversation.getVendor().getId()))
                    .orElse(false);
            if (!isParticipant) {
                throw new AccessDeniedException("Khong duoc theo doi hoi thoai cua nguoi khac.");
            }
            return;
        }
        if (destination.startsWith("/topic/vendor/")) {
            if (hasRole(authentication, "ROLE_ADMIN")) {
                return;
            }
            requireAnyRole(authentication, "ROLE_VENDOR");
            String prefix = "/topic/vendor/";
            String suffix = "/notifications";
            if (!destination.endsWith(suffix)) {
                throw new AccessDeniedException("Kenh thong bao Vendor khong hop le.");
            }
            String idPart = destination.substring(prefix.length(), destination.length() - suffix.length());
            Long requestedVendorId = parseId(idPart, "Kenh thong bao Vendor khong hop le.");
            if (!requestedVendorId.equals(requireCurrentUser(authentication).getId())) {
                throw new AccessDeniedException("Khong duoc theo doi thong bao cua Vendor khac.");
            }
            return;
        }
        throw new AccessDeniedException("Không được phép đăng ký kênh WebSocket này.");
    }

    private Long parseIdAfterPrefix(String destination, String prefix, String errorMessage) {
        return parseId(destination.substring(prefix.length()), errorMessage);
    }

    private Long parseId(String value, String errorMessage) {
        try {
            return Long.valueOf(value);
        } catch (NumberFormatException ex) {
            throw new AccessDeniedException(errorMessage);
        }
    }

    private User requireCurrentUser(Authentication authentication) {
        return userRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new AccessDeniedException("Khong tim thay tai khoan WebSocket."));
    }

    private void requireAnyRole(Authentication authentication, String... roles) {
        for (String role : roles) {
            if (hasRole(authentication, role)) {
                return;
            }
        }
        throw new AccessDeniedException("Không có quyền theo dõi kênh WebSocket này.");
    }

    private boolean hasRole(Authentication authentication, String role) {
        return authentication.getAuthorities().stream()
                .anyMatch(authority -> role.equals(authority.getAuthority()));
    }
}
