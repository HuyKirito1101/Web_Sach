<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quên Mật Khẩu - Hệ Thống Quản Lý Sách Cũ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" integrity="sha384-blOohCVdhjmtROpu8+CfTnUWham9nkX7P7OZQMst+RUnhtoY/9qemFAkIKOYxDI3" crossorigin="anonymous">
    <style>
        body {
            background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .forgot-card {
            width: 100%;
            max-width: 440px;
            padding: 35px;
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }
    </style>
</head>
<body>
    <div class="forgot-card">
        <div class="text-center mb-4">
            <i class="fa-solid fa-key fa-3x text-warning mb-2"></i>
            <h3 class="fw-bold">QUÊN MẬT KHẨU</h3>
            <p class="text-muted small">Nhập email của bạn để nhận mã OTP khôi phục mật khẩu</p>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-triangle-exclamation me-2"></i><c:out value="${errorMessage}"/>
            </div>
        </c:if>

        <c:if test="${not empty successMessage}">
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-circle-check me-2"></i><c:out value="${successMessage}"/>
            </div>
        </c:if>

        <form:form action="/auth/forgot-password" method="post" modelAttribute="forgotRequest">
            <div class="mb-4">
                <label class="form-label font-weight-bold">Email đăng ký tài khoản</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="fa-solid fa-envelope"></i></span>
                    <form:input path="email" type="email" class="form-control" placeholder="user@example.com" required="true" />
                </div>
                <form:errors path="email" cssClass="text-danger small mt-1" />
            </div>

            <button type="submit" class="btn btn-warning w-100 py-2 fw-bold rounded-3 text-dark">
                <i class="fa-solid fa-paper-plane me-2"></i> Gửi Mã OTP Qua Email
            </button>
        </form:form>

        <div class="mt-4 text-center border-top pt-3">
            <a href="/auth/login" class="text-decoration-none small fw-bold text-secondary">
                <i class="fa-solid fa-arrow-left me-1"></i> Quay lại Đăng Nhập
            </a>
        </div>
    </div>
</body>
</html>
