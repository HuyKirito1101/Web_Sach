package vn.iotstar.websach;

import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ActiveProfiles;
import vn.iotstar.websach.dto.RegisterRequest;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.UserStatus;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.service.EmailService;
import vn.iotstar.websach.service.UserService;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;

@SpringBootTest
@ActiveProfiles("h2")
class RegistrationFlowIntegrationTest {

    @Autowired private UserService userService;
    @Autowired private UserRepository userRepository;
    @MockBean private EmailService emailService;

    @Test
    void accountStaysInactiveUntilTheCorrectOtpIsEntered() {
        String email = "otp-flow@example.com";
        User registered = userService.register(registerRequest(email, "Người dùng OTP", "TestPass123!"));

        assertThat(registered.getStatus()).isEqualTo(UserStatus.INACTIVE);
        assertThat(userService.verifyOtp(email, "000000")).isFalse();
        assertThat(userRepository.findByEmail(email).orElseThrow().getStatus())
                .isEqualTo(UserStatus.INACTIVE);

        ArgumentCaptor<String> otpCaptor = ArgumentCaptor.forClass(String.class);
        verify(emailService).sendOtpEmail(eq(email), otpCaptor.capture());

        assertThat(userService.verifyOtp(email, otpCaptor.getValue())).isTrue();
        assertThat(userRepository.findByEmail(email).orElseThrow().getStatus())
                .isEqualTo(UserStatus.ACTIVE);
    }

    @Test
    void smtpFailureDoesNotLeaveAnUnverifiedAccountBehind() {
        String email = "smtp-failure@example.com";
        doThrow(new IllegalStateException("SMTP error"))
                .when(emailService).sendOtpEmail(eq(email), org.mockito.ArgumentMatchers.anyString());

        assertThatThrownBy(() -> userService.register(registerRequest(email, "SMTP lỗi", "TestPass123!")))
                .isInstanceOf(IllegalStateException.class);
        assertThat(userRepository.findByEmail(email)).isEmpty();
    }

    @Test
    void inactiveEmailCanRegisterAgainAndAdminCanDeleteIt() {
        String email = "retry-otp@example.com";
        User firstRegistration = userService.register(registerRequest(email, "Tên cũ", "TestPass123!"));
        User retriedRegistration = userService.register(registerRequest(email, "Tên mới", "AnotherPass456!"));

        assertThat(retriedRegistration.getId()).isEqualTo(firstRegistration.getId());
        assertThat(retriedRegistration.getFullName()).isEqualTo("Tên mới");
        assertThat(retriedRegistration.getStatus()).isEqualTo(UserStatus.INACTIVE);

        userService.deleteUser(retriedRegistration.getId());
        assertThat(userRepository.findByEmail(email)).isEmpty();
    }

    private RegisterRequest registerRequest(String email, String fullName, String password) {
        RegisterRequest request = new RegisterRequest();
        request.setEmail(email);
        request.setFullName(fullName);
        request.setPassword(password);
        request.setPhone("0900000000");
        return request;
    }
}
