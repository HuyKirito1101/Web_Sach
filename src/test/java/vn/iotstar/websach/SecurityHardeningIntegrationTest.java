package vn.iotstar.websach;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.redirectedUrl;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("h2")
class SecurityHardeningIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void stateChangingRequestWithoutCsrfTokenIsRejected() throws Exception {
        mockMvc.perform(post("/auth/logout"))
                .andExpect(status().isForbidden());
    }

    @Test
    void getLogoutRedirectsToLogin() throws Exception {
        mockMvc.perform(get("/auth/logout"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/auth/login?logout"));
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
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/auth/login?error=unauthorized"));
    }

    @Test
    void unauthenticatedCheckoutRedirectsToLogin() throws Exception {
        mockMvc.perform(get("/checkout"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/auth/login?error=unauthorized"));
    }
}
