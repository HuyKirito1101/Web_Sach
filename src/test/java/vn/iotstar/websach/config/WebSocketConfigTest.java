package vn.iotstar.websach.config;

import org.junit.jupiter.api.Test;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.VendorConversation;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.repository.VendorConversationRepository;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class WebSocketConfigTest {

    private final UserRepository userRepository = mock(UserRepository.class);
    private final VendorConversationRepository conversationRepository = mock(VendorConversationRepository.class);
    private final WebSocketConfig config = new WebSocketConfig(userRepository, conversationRepository);

    @Test
    void onlyConversationParticipantsCanSubscribeToVendorChat() {
        User customer = User.builder().id(11L).email("customer@example.com").build();
        User vendor = User.builder().id(22L).email("vendor@example.com").build();
        User stranger = User.builder().id(33L).email("stranger@example.com").build();
        VendorConversation conversation = VendorConversation.builder()
                .id(99L).customer(customer).vendor(vendor).build();
        when(conversationRepository.findById(99L)).thenReturn(Optional.of(conversation));
        when(userRepository.findByEmail(customer.getEmail())).thenReturn(Optional.of(customer));
        when(userRepository.findByEmail(stranger.getEmail())).thenReturn(Optional.of(stranger));

        assertDoesNotThrow(() -> config.authorizeSubscription(
                "/topic/vendor-chat/99", authentication(customer.getEmail(), "ROLE_USER")));
        assertThrows(AccessDeniedException.class, () -> config.authorizeSubscription(
                "/topic/vendor-chat/99", authentication(stranger.getEmail(), "ROLE_USER")));
    }

    @Test
    void branchOrderChannelIsLimitedToTheUsersBranch() {
        Branch branch = Branch.builder().id(7L).build();
        User manager = User.builder().id(10L).email("manager@example.com").branch(branch).build();
        when(userRepository.findByEmail(manager.getEmail())).thenReturn(Optional.of(manager));

        assertDoesNotThrow(() -> config.authorizeSubscription(
                "/topic/orders/branch/7", authentication(manager.getEmail(), "ROLE_MANAGER")));
        assertThrows(AccessDeniedException.class, () -> config.authorizeSubscription(
                "/topic/orders/branch/8", authentication(manager.getEmail(), "ROLE_MANAGER")));
        assertThrows(AccessDeniedException.class, () -> config.authorizeSubscription(
                "/topic/orders/admin", authentication(manager.getEmail(), "ROLE_MANAGER")));
        assertDoesNotThrow(() -> config.authorizeSubscription(
                "/topic/orders/admin", authentication("admin@example.com", "ROLE_ADMIN")));
    }

    @Test
    void vendorNotificationChannelIsLimitedToItsOwner() {
        User vendor = User.builder().id(22L).email("vendor@example.com").build();
        when(userRepository.findByEmail(vendor.getEmail())).thenReturn(Optional.of(vendor));

        assertDoesNotThrow(() -> config.authorizeSubscription(
                "/topic/vendor/22/notifications", authentication(vendor.getEmail(), "ROLE_VENDOR")));
        assertThrows(AccessDeniedException.class, () -> config.authorizeSubscription(
                "/topic/vendor/23/notifications", authentication(vendor.getEmail(), "ROLE_VENDOR")));
    }

    private UsernamePasswordAuthenticationToken authentication(String email, String role) {
        return new UsernamePasswordAuthenticationToken(
                email, null, List.of(new SimpleGrantedAuthority(role)));
    }
}
