<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Xác Thực Mã OTP - Sách Cũ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .otp-card {
            width: 100%;
            max-width: 420px;
            padding: 35px;
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }
    </style>
</head>
<body>
    <div class="otp-card text-center">
        <i class="fa-solid fa-envelope-circle-check fa-3x text-primary mb-3"></i>
        <h3 class="fw-bold">XÁC THỰC MÃ OTP</h3>
        <p class="text-muted small">Mã 6 chữ số đã được gửi tới email <b>${email}</b></p>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger" role="alert">
                ${errorMessage}
            </div>
        </c:if>

        <c:if test="${not empty successMessage}">
            <div class="alert alert-success" role="alert">
                ${successMessage}
            </div>
        </c:if>

        <form action="/auth/verify-otp" method="post" class="mt-4">
            <input type="hidden" name="email" value="${email}" />

            <div class="mb-4">
                <input type="text" name="otpCode" class="form-control text-center fs-3 fw-bold tracking-widest" placeholder="123456" maxlength="6" required autofocus />
            </div>

            <button type="submit" class="btn btn-primary w-100 py-2 fw-bold rounded-3">
                <i class="fa-solid fa-check-circle me-2"></i> Kích Hoạt Tài Khoản
            </button>
        </form>

        <form action="/auth/resend-otp" method="post" class="mt-3">
            <input type="hidden" name="email" value="${email}" />
            <button type="submit" class="btn btn-link text-decoration-none">
                <i class="fa-solid fa-rotate me-1"></i> Gửi lại mã OTP
            </button>
        </form>
    </div>
</body>
</html>
