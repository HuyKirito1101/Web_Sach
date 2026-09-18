<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Đơn Hàng Của Tôi - Sách Cũ Việt"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<div class="container py-4">
    <h3 class="fw-bold mb-4"><i class="fa-solid fa-receipt text-warning me-2"></i>Lịch Sử Mua Hàng</h3>

    <!-- Status Tabs -->
    <ul class="nav nav-pills mb-4 bg-white p-2 rounded-3 shadow-sm gap-1">
        <li class="nav-item">
            <a class="nav-link ${selectedStatus == null ? 'active bg-warning text-dark fw-bold' : 'text-dark'}" href="/orders">Tất cả</a>
        </li>
        <c:forEach var="st" items="${statuses}">
            <li class="nav-item">
                <a class="nav-link ${selectedStatus == st ? 'active bg-warning text-dark fw-bold' : 'text-dark'}" href="/orders?status=${st}">${st}</a>
            </li>
        </c:forEach>
    </ul>

    <c:choose>
        <c:when test="${empty orders}">
            <div class="card border-0 shadow-sm text-center py-5 rounded-3">
                <i class="fa-solid fa-box-open fs-1 text-secondary mb-3"></i>
                <h5>Bạn chưa có đơn hàng nào trong mục này!</h5>
                <p class="text-muted">Hãy mua sắm các cuốn sách cũ ưa thích trên website.</p>
                <div class="mt-2">
                    <a href="/books" class="btn btn-warning rounded-pill fw-bold px-4">Khám Phá Sách Ngay</a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="d-flex flex-column gap-3">
                <c:forEach var="o" items="${orders}">
                    <div class="card border-0 shadow-sm rounded-3 p-3">
                        <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2">
                            <div>
                                <span class="fw-bold text-dark me-2">Mã đơn: #${o.orderCode}</span>
                                <small class="text-muted"><i class="fa-solid fa-store me-1"></i>${o.branch.name}</small>
                            </div>
                            <span class="badge ${o.orderStatus == 'NEW' ? 'bg-info' : o.orderStatus == 'DELIVERED' ? 'bg-success' : o.orderStatus == 'CANCELLED' ? 'bg-danger' : 'bg-warning'} text-dark fw-bold">${o.orderStatus}</span>
                        </div>
                        <div class="row align-items-center">
                            <div class="col-md-8">
                                <p class="mb-1 text-secondary small"><strong>Người nhận:</strong> ${o.receiverName} - ${o.receiverPhone}</p>
                                <p class="mb-1 text-secondary small"><strong>Địa chỉ:</strong> ${o.shippingAddress}</p>
                                <p class="mb-0 text-muted small"><strong>Thanh toán:</strong> ${o.paymentMethod} (${o.paymentStatus})</p>
                            </div>
                            <div class="col-md-4 text-md-end mt-2 mt-md-0">
                                <div class="mb-2">
                                    <span class="text-muted small me-2">Tổng tiền:</span>
                                    <span class="fw-bold fs-5 text-danger">
                                        <fmt:formatNumber value="${o.finalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </span>
                                </div>
                                <a href="/orders/${o.id}" class="btn btn-outline-warning text-dark btn-sm rounded-pill fw-bold px-3">
                                    Chi Tiết Đơn Hàng <i class="fa-solid fa-chevron-right ms-1"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="../common/footer.jsp"/>
