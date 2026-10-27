package vn.iotstar.websach;

import jakarta.servlet.http.Cookie;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import vn.iotstar.websach.config.JwtUtils;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.repository.UserRepository;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class SecurityHardeningIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JwtUtils jwtUtils;

    @Autowired
    private UserRepository userRepository;

    @Test
    void stateChangingRequestWithoutCsrfTokenIsRejected() throws Exception {
        mockMvc.perform(post("/auth/logout"))
                .andExpect(status().isForbidden());
    }

    @Test
    void getLogoutIsNotAllowed() throws Exception {
        mockMvc.perform(get("/auth/logout"))
                .andExpect(status().isMethodNotAllowed());
    }

    @Test
    void publicPagesReturnBrowserSecurityHeaders() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(header().string("X-Frame-Options", "DENY"))
                .andExpect(header().string("Referrer-Policy", "strict-origin-when-cross-origin"))
                .andExpect(header().string("Permissions-Policy", "camera=(), microphone=(), geolocation=(), payment=()"))
                .andExpect(header().string("Content-Security-Policy",
                        org.hamcrest.Matchers.containsString("object-src 'none'")));
    }

    @Test
    void unauthenticatedAddToCartRedirectsToLogin() throws Exception {
        mockMvc.perform(post("/cart/add")
                        .param("bookCopyId", "1")
                        .param("quantity", "1"))
                .andExpect(status().isForbidden());
    }

    @Test
    void unauthenticatedCheckoutRedirectsToLogin() throws Exception {
        mockMvc.perform(get("/checkout"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/auth/login?error=unauthorized"));
    }

    @Test
    void authenticatedAdminPostWithoutCsrfTokenIsRejected() throws Exception {
        User admin = userRepository.findByEmail("admin@websachcu.vn").orElseThrow();
        String token = jwtUtils.generateJwtToken(admin.getEmail(), admin.getRole().getName().name());

        mockMvc.perform(post("/admin/users/toggle-lock/999999")
                        .cookie(new Cookie("JWT_TOKEN", token)))
                .andExpect(status().isForbidden());
    }

    @Test
    void guestCanOpenSupportChatButCannotPostWithoutCsrfToken() throws Exception {
        mockMvc.perform(get("/support-chat"))
                .andExpect(status().isOk());

        mockMvc.perform(post("/support-chat/start")
                        .param("phone", "0901234567")
                        .param("branchId", "1")
                        .param("content", "Tôi cần hỗ trợ"))
                .andExpect(status().isForbidden());
    }

    @Test
    void internalRolesOpeningStorefrontRootAreRedirectedToTheirDashboards() throws Exception {
        assertRootRedirect("admin@websachcu.vn", "/admin/dashboard");
        assertRootRedirect("manager@websachcu.vn", "/manager/dashboard");
        assertRootRedirect("vendor.thuduc1@websachcu.vn", "/vendor/dashboard");
        assertRootRedirect("shipper.thuduc1@websachcu.vn", "/shipper/dashboard");
    }

    @Test
    void customerCanStillOpenStorefrontRoot() throws Exception {
        User user = userRepository.findByEmail("user@websachcu.vn").orElseThrow();
        String token = jwtUtils.generateJwtToken(user.getEmail(), user.getRole().getName().name());

        mockMvc.perform(get("/").cookie(new Cookie("JWT_TOKEN", token)))
                .andExpect(status().isOk());
    }

    private void assertRootRedirect(String email, String expectedUrl) throws Exception {
        User user = userRepository.findByEmail(email).orElseThrow();
        String token = jwtUtils.generateJwtToken(user.getEmail(), user.getRole().getName().name());

        mockMvc.perform(get("/").cookie(new Cookie("JWT_TOKEN", token)))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl(expectedUrl));
    }
}
