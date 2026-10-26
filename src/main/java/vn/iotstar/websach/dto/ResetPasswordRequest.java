package vn.iotstar.websach.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ResetPasswordRequest {
    @NotBlank(message = "Email không được để trống")
    @Email(message = "Email không hợp lệ")
    private String email;

    @NotBlank(message = "Mã OTP không được để trống")
    @Pattern(regexp = "\\d{6}", message = "Mã OTP phải gồm đúng 6 chữ số")
    private String otpCode;

    @NotBlank(message = "Mật khẩu mới không được để trống")
    @Size(min = 8, max = 72, message = "Mật khẩu mới phải có từ 8 đến 72 ký tự")
    private String newPassword;

    @NotBlank(message = "Xác nhận mật khẩu không được để trống")
    @Size(max = 72, message = "Mật khẩu xác nhận không hợp lệ")
    private String confirmPassword;
}
