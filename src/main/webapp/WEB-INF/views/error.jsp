<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông Báo Lỗi - Hệ Thống Sách Cũ</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet" integrity="sha384-blOohCVdhjmtROpu8+CfTnUWham9nkX7P7OZQMst+RUnhtoY/9qemFAkIKOYxDI3" crossorigin="anonymous">
    <style>
        body {
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #f8fafc;
            font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
        }
        .error-card {
            background: #ffffff;
            color: #1e293b;
            border-radius: 16px;
            padding: 40px;
            max-width: 520px;
            width: 90%;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
            text-align: center;
        }
        .error-icon {
            font-size: 4rem;
            color: #ef4444;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="error-card">
        <div class="error-icon">
            <i class="fa-solid fa-triangle-exclamation"></i>
        </div>
        <h3 class="fw-bold mb-2">Đã Có Lỗi Xảy Ra</h3>
        <p class="text-muted mb-4">
            <c:choose>
                <c:when test="${not empty errorMessage}">
                    <c:out value="${errorMessage}" />
                </c:when>
                <c:when test="${status == 403}">
                    Bạn không có quyền truy cập hoặc phiên làm việc đã hết hạn (Lỗi 403 Forbidden).
                </c:when>
                <c:when test="${status == 404}">
                    Trang bạn đang tìm kiếm không tồn tại hoặc đã bị di chuyển (Lỗi 404 Not Found).
                </c:when>
                <c:otherwise>
                    Hệ thống không thể xử lý yêu cầu lúc này. Vui lòng thử lại sau.
                </c:otherwise>
            </c:choose>
        </p>

        <div class="d-flex justify-content-center gap-3">
            <a href="/" class="btn btn-primary px-4 py-2">
                <i class="fa-solid fa-house me-2"></i>Trang Chủ
            </a>
            <a href="/auth/login" class="btn btn-outline-secondary px-4 py-2">
                <i class="fa-solid fa-right-to-bracket me-2"></i>Đăng Nhập
            </a>
        </div>
    </div>
</body>
</html>
