package vn.iotstar.websach.controller.auth;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import vn.iotstar.websach.dto.ForgotPasswordRequest;
import vn.iotstar.websach.dto.LoginRequest;
import vn.iotstar.websach.dto.OtpVerificationRequest;
import vn.iotstar.websach.dto.RegisterRequest;
import vn.iotstar.websach.dto.ResetPasswordRequest;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.security.AuthRateLimiter;
import vn.iotstar.websach.service.UserService;

import java.time.Duration;
import vn.iotstar.websach.util.ExceptionMessages;

@Controller
@RequestMapping("/auth")
@RequiredArgsConstructor
@Slf4j
public class AuthController {

    private final UserService userService;
    private final AuthRateLimiter authRateLimiter;

    @GetMapping("/login")
    public String showLoginForm(Model model) {
        model.addAttribute("loginRequest", new LoginRequest());
        return "auth/login";
    }

    @PostMapping("/login")
    public String handleLogin(@Valid @ModelAttribute("loginRequest") LoginRequest request,
                              BindingResult bindingResult,
                              HttpServletRequest servletRequest,
                              HttpServletResponse response,
                              Model model) {
        if (bindingResult.hasErrors()) {
            return "auth/login";
        }

        String limitKey = request.getEmail() + '|' + servletRequest.getRemoteAddr();
        try {
            authRateLimiter.checkAndRecord("login", limitKey, 5, Duration.ofMinutes(15));
            String token = userService.login(request);

            ResponseCookie cookie = ResponseCookie.from("JWT_TOKEN", token)
                    .httpOnly(true)
                    .secure(servletRequest.isSecure())
                    .sameSite("Lax")
                    .path("/")
                    .maxAge(Duration.ofDays(1))
                    .build();
            response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
            authRateLimiter.clear("login", limitKey);

            return "redirect:" + userService.getLandingPage(request.getEmail());
        } catch (Exception e) {
            log.warn("Đăng nhập thất bại cho {} từ {}", request.getEmail(), servletRequest.getRemoteAddr());
            String message = ExceptionMessages.userMessage(e);
            if (ExceptionMessages.isDatabaseFailure(e)) {
                model.addAttribute("errorMessage", message);
                return "auth/login";
            }
            boolean rateLimited = e instanceof IllegalStateException
                    && message != null
                    && message.startsWith("Bạn đã thử quá nhiều");
            model.addAttribute("errorMessage", rateLimited
                    ? message
                    : "Email hoặc mật khẩu không đúng.");
            return "auth/login";
        }
    }

    @GetMapping("/register")
    public String showRegisterForm(Model model) {
        model.addAttribute("registerRequest", new RegisterRequest());
        return "auth/register";
    }

    @PostMapping("/register")
    public String handleRegister(@Valid @ModelAttribute("registerRequest") RegisterRequest request,
                                 BindingResult bindingResult,
                                 Model model) {
        if (bindingResult.hasErrors()) {
            return "auth/register";
        }

        try {
            User registeredUser = userService.register(request);
            model.addAttribute("email", registeredUser.getEmail());
            model.addAttribute("otpRequest", new OtpVerificationRequest());
            return "auth/verify-otp";
        } catch (Exception e) {
            model.addAttribute("errorMessage", ExceptionMessages.userMessage(e));
            if (e instanceof IllegalStateException
                    && "Email đã được đăng ký và kích hoạt trong hệ thống!".equals(ExceptionMessages.userMessage(e))) {
                model.addAttribute("accountExists", true);
            }
            return "auth/register";
        }
    }

    @PostMapping("/resend-otp")
    public String resendOtp(@RequestParam("email") String email,
                            HttpServletRequest servletRequest,
                            Model model) {
        model.addAttribute("email", email == null ? "" : email.trim().toLowerCase());
        model.addAttribute("otpRequest", new OtpVerificationRequest());
        try {
            authRateLimiter.checkAndRecord("resend-register-otp",
                    email + '|' + servletRequest.getRemoteAddr(), 3, Duration.ofMinutes(10));
            userService.resendRegistrationOtp(email);
            model.addAttribute("successMessage", "Đã gửi mã OTP mới. Mã có hiệu lực trong 5 phút.");
        } catch (Exception e) {
            model.addAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "auth/verify-otp";
    }

    @PostMapping("/verify-otp")
    public String handleVerifyOtp(@Valid @ModelAttribute("otpRequest") OtpVerificationRequest request,
                                  BindingResult bindingResult,
                                  HttpServletRequest servletRequest,
                                  Model model) {
        if (bindingResult.hasErrors()) {
            model.addAttribute("email", request.getEmail());
            return "auth/verify-otp";
        }
        String limitKey = request.getEmail() + '|' + servletRequest.getRemoteAddr();
        try {
            authRateLimiter.checkAndRecord("verify-register-otp", limitKey, 5, Duration.ofMinutes(10));
            boolean isSuccess = userService.verifyOtp(request.getEmail(), request.getOtpCode());
            if (isSuccess) {
                authRateLimiter.clear("verify-register-otp", limitKey);
                model.addAttribute("successMessage", "Kích hoạt tài khoản thành công! Vui lòng đăng nhập.");
                model.addAttribute("loginRequest", new LoginRequest());
                return "auth/login";
            }
            model.addAttribute("errorMessage", "Mã OTP sai, đã hết hạn hoặc đã được sử dụng!");
        } catch (RuntimeException e) {
            model.addAttribute("errorMessage", "Không thể xác thực OTP lúc này. Vui lòng gửi mã mới và thử lại.");
        }
        model.addAttribute("email", request.getEmail());
        model.addAttribute("otpRequest", request);
        return "auth/verify-otp";
    }

    @GetMapping("/forgot-password")
    public String showForgotPasswordForm(Model model) {
        model.addAttribute("forgotRequest", new ForgotPasswordRequest());
        return "auth/forgot-password";
    }

    @PostMapping("/forgot-password")
    public String handleForgotPassword(@Valid @ModelAttribute("forgotRequest") ForgotPasswordRequest request,
                                       BindingResult bindingResult,
                                       HttpServletRequest servletRequest,
                                       Model model) {
        if (bindingResult.hasErrors()) {
            return "auth/forgot-password";
        }
        try {
            authRateLimiter.checkAndRecord("forgot-password",
                    request.getEmail() + '|' + servletRequest.getRemoteAddr(), 3, Duration.ofMinutes(10));
            userService.sendForgotPasswordOtp(request.getEmail());
            return "redirect:/auth/reset-password?email=" + java.net.URLEncoder.encode(request.getEmail().trim(), java.nio.charset.StandardCharsets.UTF_8) + "&sent=true";
        } catch (Exception e) {
            model.addAttribute("errorMessage", ExceptionMessages.userMessage(e));
            return "auth/forgot-password";
        }
    }

    @GetMapping("/reset-password")
    public String showResetPasswordForm(@RequestParam(value = "email", required = false) String email,
                                        @RequestParam(value = "sent", required = false) Boolean sent,
                                        Model model) {
        ResetPasswordRequest req = new ResetPasswordRequest();
        if (email != null) {
            req.setEmail(email.trim());
        }
        model.addAttribute("resetRequest", req);
        if (Boolean.TRUE.equals(sent)) {
            model.addAttribute("successMessage",
                    "Yêu cầu đã được tiếp nhận. Nếu email tồn tại và đang hoạt động, "
                            + "mã OTP sẽ được gửi trong vài phút. Vui lòng kiểm tra cả thư rác.");
        }
        return "auth/reset-password";
    }

    @PostMapping("/reset-password")
    public String handleResetPassword(@Valid @ModelAttribute("resetRequest") ResetPasswordRequest request,
                                      BindingResult bindingResult,
                                      HttpServletRequest servletRequest,
                                      Model model) {
        if (bindingResult.hasErrors()) {
            return "auth/reset-password";
        }
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            model.addAttribute("errorMessage", "Mật khẩu xác nhận không khớp!");
            return "auth/reset-password";
        }
        try {
            String limitKey = request.getEmail() + '|' + servletRequest.getRemoteAddr();
            authRateLimiter.checkAndRecord("reset-password", limitKey, 5, Duration.ofMinutes(10));
            userService.resetPasswordWithOtp(request.getEmail(), request.getOtpCode(), request.getNewPassword());
            authRateLimiter.clear("reset-password", limitKey);
            model.addAttribute("successMessage", "Đặt lại mật khẩu thành công! Bạn có thể đăng nhập bằng mật khẩu mới.");
            model.addAttribute("loginRequest", new LoginRequest());
            return "auth/login";
        } catch (Exception e) {
            model.addAttribute("errorMessage", ExceptionMessages.userMessage(e));
            return "auth/reset-password";
        }
    }

    @PostMapping("/logout")
    public String handleLogout(HttpServletRequest request, HttpServletResponse response) {
        ResponseCookie cookie = ResponseCookie.from("JWT_TOKEN", "")
                .httpOnly(true)
                .secure(request.isSecure())
                .sameSite("Lax")
                .path("/")
                .maxAge(Duration.ZERO)
                .build();
        response.addHeader(HttpHeaders.SET_COOKIE, cookie.toString());
        SecurityContextHolder.clearContext();
        return "redirect:/auth/login?logout";
    }
}
