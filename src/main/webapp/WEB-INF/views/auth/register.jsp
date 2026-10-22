<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng Ký Tài Khoản - Sách Cũ</title>
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
        .register-card {
            width: 100%;
            max-width: 480px;
            padding: 35px;
            background: #ffffff;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }
    </style>
</head>
<body>
    <div class="register-card">
        <div class="text-center mb-4">
            <h3 class="fw-bold text-primary"><i class="fa-solid fa-user-plus me-2"></i>ĐĂNG KÝ TÀI KHOẢN</h3>
            <p class="text-muted small">Tạo tài khoản mới và nhận mã OTP kích hoạt qua Email</p>
        </div>

        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <c:out value="${errorMessage}"/>
            </div>
        </c:if>

        <form:form action="/auth/register" method="post" modelAttribute="registerRequest">
            <div class="mb-3">
                <label class="form-label">Họ và Tên</label>
                <form:input path="fullName" class="form-control" placeholder="Nguyen Van A" required="true" />
            </div>

            <div class="mb-3">
                <label class="form-label">Email (Sẽ nhận mã OTP kích hoạt)</label>
                <form:input path="email" type="email" class="form-control" placeholder="name@example.com" required="true" />
            </div>

            <div class="mb-3">
                <label class="form-label">Số điện thoại</label>
                <form:input path="phone" class="form-control" placeholder="0901234567" />
            </div>

            <div class="mb-4">
                <label class="form-label">Mật khẩu</label>
                <form:input path="password" type="password" class="form-control" placeholder="••••••••" required="true" />
            </div>

            <button type="submit" class="btn btn-primary w-100 py-2 fw-bold rounded-3">
                <i class="fa-solid fa-paper-plane me-2"></i> Đăng Ký & Nhận OTP
            </button>
        </form:form>

        <div class="mt-4 text-center">
            <p class="small text-muted mb-0">Đã có tài khoản? <a href="/auth/login" class="text-primary fw-bold">Đăng nhập</a></p>
        </div>
    </div>
</body>
</html>
