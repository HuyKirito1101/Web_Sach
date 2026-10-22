<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đặt Lại Mật Khẩu - Hệ Thống Quản Lý Sách Cũ</title>
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
        .reset-card {
            width: 100%;
            max-width: 450px;
            padding: 35px;
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }
    </style>
</head>
<body>
    <div class="reset-card">
        <div class="text-center mb-4">
            <i class="fa-solid fa-lock-open fa-3x text-primary mb-2"></i>
            <h3 class="fw-bold">ĐẶT LẠI MẬT KHẨU</h3>
            <p class="text-muted small">Nhập mã OTP 6 số nhận được qua email và thiết lập mật khẩu mới</p>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-triangle-exclamation me-2"></i>${errorMessage}
            </div>
        </c:if>

        <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-circle-check me-2"></i>${successMessage}
            </div>
        </c:if>

        <form:form action="/auth/reset-password" method="post" modelAttribute="resetRequest">
            <div class="mb-3">
                <label class="form-label font-weight-bold">Email tài khoản</label>
                <form:input path="email" type="email" class="form-control" readonly="true" />
            </div>

            <div class="mb-3">
                <label class="form-label font-weight-bold">Mã OTP (6 chữ số)</label>
                <form:input path="otpCode" type="text" maxlength="6" class="form-control text-center fs-4 fw-bold tracking-widest" placeholder="123456" required="true" autofocus="true" />
                <form:errors path="otpCode" cssClass="text-danger small mt-1" />
            </div>

            <div class="mb-3">
                <label class="form-label font-weight-bold">Mật khẩu mới</label>
                <form:input path="newPassword" type="password" class="form-control" placeholder="Tối thiểu 6 ký tự" required="true" />
                <form:errors path="newPassword" cssClass="text-danger small mt-1" />
            </div>

            <div class="mb-4">
                <label class="form-label font-weight-bold">Xác nhận mật khẩu mới</label>
                <form:input path="confirmPassword" type="password" class="form-control" placeholder="Nhập lại mật khẩu mới" required="true" />
                <form:errors path="confirmPassword" cssClass="text-danger small mt-1" />
            </div>

            <button type="submit" class="btn btn-primary w-100 py-2 fw-bold rounded-3">
                <i class="fa-solid fa-shield-halved me-2"></i> Xác Nhận Đổi Mật Khẩu
            </button>
        </form:form>

        <div class="mt-4 text-center border-top pt-3">
            <a href="/auth/forgot-password" class="text-decoration-none small text-muted me-3">
                <i class="fa-solid fa-rotate-right me-1"></i> Gửi lại OTP
            </a>
            <a href="/auth/login" class="text-decoration-none small fw-bold text-primary">
                Đăng nhập
            </a>
        </div>
    </div>
</body>
</html>
