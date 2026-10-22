<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Cổng Thanh Toán VNPAY Demo"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<div class="container py-5 text-center" style="max-width: 500px;">
    <div class="card border-0 shadow-sm rounded-3 p-4">
        <div class="mb-3">
            <img src="https://vnpay.vn/s1/stores/3b5f7bfa-c529-4d6d-8951-404aef7ef35b/vnpay-qr-logo.png" style="height: 50px;" alt="VNPAY Logo">
        </div>
        <h4 class="fw-bold mb-2">Thanh Toán Đơn Hàng VNPAY Sandbox</h4>
        <p class="text-muted small mb-4">Quét mã QR bằng ứng dụng Ngân hàng / ví VNPAY để hoàn tất đơn hàng mã #${orderId}.</p>

        <div class="bg-light p-3 rounded-3 mb-4 d-inline-block">
            <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=VNPAY_DEMO_ORDER_${orderId}" alt="VNPAY QR Code" class="img-fluid rounded">
        </div>

        <div class="d-grid gap-2">
            <a href="/checkout/vnpay-callback?orderIds=${orderIds}&status=SUCCESS" class="btn btn-success btn-lg rounded-pill fw-bold">
                <i class="fa-solid fa-check-circle me-2"></i>Mô Phỏng Thanh Toán VNPAY Thành Công (Callback)
            </a>
            <a href="/checkout/vnpay-callback?orderIds=${orderIds}&status=FAILED" class="btn btn-outline-danger rounded-pill">
                <i class="fa-solid fa-xmark me-2"></i>Mô Phỏng Hủy Thanh Toán VNPAY (Thất Bại)
            </a>
            <a href="/orders" class="btn btn-outline-secondary rounded-pill">Quay lại danh sách đơn hàng</a>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp"/>
