<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng Nhập - Hệ Thống Quản Lý Sách Cũ</title>
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
        .login-card {
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
    <div class="login-card">
        <div class="text-center mb-4">
            <i class="fa-solid fa-book-bookmark fa-3x text-primary mb-2"></i>
            <h3 class="fw-bold">ĐĂNG NHẬP</h3>
            <p class="text-muted small">Website Quản Lý Chuỗi Cửa Hàng Sách Cũ</p>
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

        <form:form action="/auth/login" method="post" modelAttribute="loginRequest">
            <div class="mb-3">
                <label class="form-label font-weight-bold">Email tài khoản</label>
                <form:input path="email" type="email" class="form-control" placeholder="admin@websachcu.vn" required="true" />
            </div>

            <div class="mb-4">
                <div class="d-flex justify-content-between align-items-center mb-1">
                    <label class="form-label font-weight-bold mb-0">Mật khẩu</label>
                    <a href="/auth/forgot-password" class="small text-decoration-none text-muted">Quên mật khẩu?</a>
                </div>
                <form:input path="password" type="password" class="form-control" placeholder="••••••••" required="true" />
            </div>

            <button type="submit" class="btn btn-primary w-100 py-2 fw-bold rounded-3">
                <i class="fa-solid fa-right-to-bracket me-2"></i> Đăng Nhập
            </button>
        </form:form>

        <div class="mt-4 text-center">
            <p class="small text-muted mb-0">Chưa có tài khoản? <a href="/auth/register" class="text-primary fw-bold">Đăng ký ngay</a></p>
        </div>

        <div class="mt-3 text-center border-top pt-3">
            <span class="badge bg-secondary p-2">Dev Accounts:</span>
            <div class="small text-muted mt-1">
                Admin: <b>admin@websachcu.vn</b> / 123456<br>
                Manager: <b>manager@websachcu.vn</b> / 123456
            </div>
        </div>
    </div>
</body>
</html>
