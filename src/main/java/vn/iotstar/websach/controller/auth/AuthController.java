package vn.iotstar.websach.controller.auth;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import vn.iotstar.websach.dto.LoginRequest;
import vn.iotstar.websach.dto.OtpVerificationRequest;
import vn.iotstar.websach.dto.RegisterRequest;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.service.UserService;

@Controller
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;

    @GetMapping("/login")
    public String showLoginForm(Model model) {
        model.addAttribute("loginRequest", new LoginRequest());
        return "auth/login";
    }

    @PostMapping("/login")
    public String handleLogin(@Valid @ModelAttribute("loginRequest") LoginRequest request,
                              BindingResult bindingResult,
                              HttpServletResponse response,
                              Model model) {
        if (bindingResult.hasErrors()) {
            return "auth/login";
        }

        try {
            String token = userService.login(request);

            // Lưu JWT vào HttpOnly Cookie
            Cookie cookie = new Cookie("JWT_TOKEN", token);
            cookie.setHttpOnly(true);
            cookie.setPath("/");
            cookie.setMaxAge(86400); // 1 ngày
            response.addCookie(cookie);

            // Sau đăng nhập, mọi vai trò đều trở về trang chủ. Dashboard vẫn
            // được mở từ menu hoặc URL tương ứng khi người dùng cần quản trị.
            return "redirect:/";
        } catch (Exception e) {
            model.addAttribute("errorMessage", "Đăng nhập thất bại: " + e.getMessage());
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
            model.addAttribute("errorMessage", e.getMessage());
            return "auth/register";
        }
    }

    @PostMapping("/resend-otp")
    public String resendOtp(@RequestParam("email") String email, Model model) {
        model.addAttribute("email", email == null ? "" : email.trim().toLowerCase());
        model.addAttribute("otpRequest", new OtpVerificationRequest());
        try {
            userService.resendRegistrationOtp(email);
            model.addAttribute("successMessage", "Đã gửi mã OTP mới. Mã có hiệu lực trong 5 phút.");
        } catch (Exception e) {
            model.addAttribute("errorMessage", e.getMessage());
        }
        return "auth/verify-otp";
    }

    @PostMapping("/verify-otp")
    public String handleVerifyOtp(@ModelAttribute("otpRequest") OtpVerificationRequest request, Model model) {
        boolean isSuccess = userService.verifyOtp(request.getEmail(), request.getOtpCode());
        if (isSuccess) {
            model.addAttribute("successMessage", "Kích hoạt tài khoản thành công! Vui lòng đăng nhập.");
            model.addAttribute("loginRequest", new LoginRequest());
            return "auth/login";
        } else {
            model.addAttribute("errorMessage", "Mã OTP sai hoặc đã hết hạn!");
            model.addAttribute("email", request.getEmail());
            return "auth/verify-otp";
        }
    }

    @GetMapping("/logout")
    public String handleLogout(HttpServletResponse response) {
        Cookie cookie = new Cookie("JWT_TOKEN", null);
        cookie.setPath("/");
        cookie.setHttpOnly(true);
        cookie.setMaxAge(0);
        response.addCookie(cookie);
        SecurityContextHolder.clearContext();
        return "redirect:/auth/login?logout";
    }
}
