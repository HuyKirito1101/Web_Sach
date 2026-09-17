package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import vn.iotstar.websach.service.EmailService;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailServiceImpl implements EmailService {

    private final JavaMailSender mailSender;

    @Override
    public void sendOtpEmail(String toEmail, String otpCode) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(toEmail);
            message.setSubject("[WebSachCu] Ma OTP Kich Hoat / Reset Mat Khau");
            message.setText("Ma OTP cua ban la: " + otpCode + ". Ma co hieu luc trong 5 phut. Vui long khong chia se ma nay cho ai.");
            mailSender.send(message);
            log.info("Gui OTP thanh cong toi email: {}", toEmail);
        } catch (Exception e) {
            log.error("Loi khi gui OTP email qua JavaMailSender: {}", e.getMessage());
            log.info("MOCK OTP MODE - Ma OTP cho email {}: {}", toEmail, otpCode);
        }
    }
}
