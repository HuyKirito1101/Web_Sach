package vn.iotstar.websach.service;

public interface EmailService {
    void sendOtpEmail(String toEmail, String otpCode);
    void sendPasswordResetOtpEmail(String toEmail, String otpCode);
}
