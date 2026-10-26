package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import vn.iotstar.websach.service.EmailService;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailServiceImpl implements EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username:your_email@gmail.com}")
    private String fromEmail;

    @Override
    public void sendOtpEmail(String toEmail, String otpCode) {
        send(toEmail, otpCode, "[WebSachCu] Mã OTP Kích Hoạt Tài Khoản",
                "Mã OTP kích hoạt tài khoản của bạn là: ");
    }

    @Override
    public void sendPasswordResetOtpEmail(String toEmail, String otpCode) {
        send(toEmail, otpCode, "[WebSachCu] Mã OTP Đặt Lại Mật Khẩu",
                "Mã OTP đặt lại mật khẩu của bạn là: ");
    }

    private void send(String toEmail, String otpCode, String subject, String prefix) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setFrom(fromEmail);
            message.setTo(toEmail);
            message.setSubject(subject);
            message.setText(prefix + otpCode + "\n\nMã có hiệu lực trong 5 phút. Vui lòng không chia sẻ mã này cho ai.");
            mailSender.send(message);
            log.info("Đã gửi mã OTP thực tế tới Gmail: {}", toEmail);
        } catch (Exception e) {
            log.error("Không thể gửi OTP qua SMTP Gmail tới {}: {}", toEmail, e.getMessage());
            throw new IllegalStateException(
                    "Không thể gửi mã OTP. Vui lòng kiểm tra email hoặc cấu hình Gmail rồi thử lại.", e);
        }
    }
}
