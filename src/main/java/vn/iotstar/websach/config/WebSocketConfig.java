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
import vn.iotstar.websach.repository.UserRepository;

import java.security.Principal;

@Configuration
@EnableWebSocketMessageBroker
@RequiredArgsConstructor
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    private final UserRepository userRepository;

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

    private void authorizeSubscription(String destination, Authentication authentication) {
        if (destination == null) {
            throw new AccessDeniedException("Kênh WebSocket không hợp lệ.");
        }
        if ("/topic/orders".equals(destination)) {
            requireAnyRole(authentication, "ROLE_ADMIN", "ROLE_MANAGER", "ROLE_VENDOR", "ROLE_SHIPPER");
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
        throw new AccessDeniedException("Không được phép đăng ký kênh WebSocket này.");
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
