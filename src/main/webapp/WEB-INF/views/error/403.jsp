<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Không thể thực hiện yêu cầu - Sách Cũ Việt</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"
          integrity="sha384-T3c6CoIi6uLrA9TneNEoa7RxnatzjcDSCmG1MXxSR1GAsXEV/Dwwykc2MPK8M2HN" crossorigin="anonymous">
    <style>
        body { background: #f4f6f9; }
        .error-card { max-width: 560px; }
    </style>
</head>
<body class="min-vh-100 d-flex align-items-center justify-content-center p-3">
<main class="error-card card border-0 shadow-sm rounded-4 p-4 p-md-5 text-center">
    <div class="display-4 fw-bold text-warning mb-2">403</div>
    <h1 class="h3 fw-bold">Yêu cầu đã hết hiệu lực</h1>
    <p class="text-muted mb-4">
        Trang có thể đã mở quá lâu hoặc thông tin bảo mật vừa được làm mới.
        Hãy tải lại trang rồi thực hiện lại thao tác.
    </p>
    <div class="d-flex flex-column flex-sm-row justify-content-center gap-2">
        <button type="button" class="btn btn-warning fw-bold" onclick="window.location.reload()">Tải lại trang</button>
        <a href="/" class="btn btn-outline-secondary">Về trang chủ</a>
    </div>
</main>
</body>
</html>
