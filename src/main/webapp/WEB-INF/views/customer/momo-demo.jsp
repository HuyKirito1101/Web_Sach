<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Cổng Thanh Toán MoMo Demo"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<div class="container py-5 text-center" style="max-width: 500px;">
    <div class="card border-0 shadow-sm rounded-3 p-5">
        <div class="mb-3">
            <!-- MoMo logo color circle -->
            <div class="rounded-circle d-inline-flex align-items-center justify-content-center text-white fw-bold"
                 style="width:70px;height:70px;background:#ae2070;font-size:28px;margin:0 auto;">M</div>
        </div>
        <h4 class="fw-bold mb-2" style="color:#ae2070;">Thanh Toán Đơn Hàng MoMo</h4>
        <p class="text-muted small mb-4">Quét mã QR bằng ứng dụng MoMo để hoàn tất đơn hàng mã <strong>#${orderId}</strong>.</p>

        <div class="bg-light p-3 rounded-3 mb-4 d-inline-block border" style="border-color:#ae2070!important;">
            <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=MOMO_DEMO_ORDER_${orderId}&color=ae2070"
                 alt="MoMo QR Code" class="img-fluid rounded">
        </div>

        <div class="alert alert-light border small text-start mb-4">
            <i class="fa-solid fa-circle-info me-1" style="color:#ae2070;"></i>
            Đây là trang thanh toán MoMo <strong>Demo</strong> (Sandbox). Trong môi trường thực tế, bạn sẽ được chuyển hướng đến app MoMo chính thức.
        </div>

        <div class="d-grid gap-2">
            <a href="/checkout/momo-callback?orderIds=${orderIds}&status=SUCCESS" class="btn btn-lg rounded-pill fw-bold text-white"
               style="background:#ae2070;">
                <i class="fa-solid fa-check-circle me-2"></i>Mô Phỏng Thanh Toán MoMo Thành Công (Callback)
            </a>
            <a href="/checkout/momo-callback?orderIds=${orderIds}&status=FAILED" class="btn btn-outline-danger rounded-pill">
                <i class="fa-solid fa-xmark me-2"></i>Mô Phỏng Hủy Thanh Toán MoMo (Thất Bại)
            </a>
            <a href="/orders" class="btn btn-outline-secondary rounded-pill">Quay lại danh sách đơn hàng</a>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp"/>
