<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="title" value="Đơn hàng Vendor" scope="request"/>
<jsp:include page="../../common/header.jsp"/>
<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp"/>
    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp"/>
        <main class="main-content container-fluid p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0"><i class="fa-solid fa-boxes-packing text-warning me-2"></i>Đơn hàng cửa hàng</h3>
                <form class="d-flex align-items-center gap-2">
                    <select name="status" class="form-select form-select-sm" onchange="this.form.submit()">
                        <option value="">Tất cả trạng thái</option>
                        <c:forEach var="s" items="${statuses}">
                            <option value="${s}" ${selectedStatus == s ? 'selected' : ''}>${s}</option>
                        </c:forEach>
                    </select>
                </form>
            </div>

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fa-solid fa-circle-check me-2"></i>${successMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fa-solid fa-circle-exclamation me-2"></i>${errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <div class="card border-0 shadow-sm rounded-3">
                <div class="table-responsive">
                    <table class="table align-middle table-hover mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Mã đơn</th>
                                <th>Người nhận</th>
                                <th>Phương thức giao</th>
                                <th>Tổng tiền</th>
                                <th>Thanh toán</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="o" items="${orders}">
                                <tr>
                                    <td>
                                        <a href="/vendor/orders/${o.id}" class="fw-bold text-decoration-none text-primary">
                                            ${o.orderCode}
                                        </a>
                                    </td>
                                    <td>
                                        <div class="fw-bold text-dark">${o.receiverName}</div>
                                        <div class="small text-muted"><i class="fa-solid fa-phone me-1"></i>${o.receiverPhone}</div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${o.shippingProvider != null}">
                                                <div class="fw-bold text-dark small mb-1">${o.shippingProvider.name}</div>
                                                <c:choose>
                                                    <c:when test="${o.shippingProvider.code == 'GHN_EXPRESS'}">
                                                        <span class="badge bg-danger"><i class="fa-solid fa-bolt me-1"></i>GHN Hỏa Tốc (Trong tỉnh)</span>
                                                    </c:when>
                                                    <c:when test="${o.shippingProvider.code == 'SPX_EXPRESS'}">
                                                        <span class="badge bg-warning text-dark"><i class="fa-solid fa-globe me-1"></i>SPX Express (Ngoại tỉnh)</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-primary"><i class="fa-solid fa-house me-1"></i>GHN Tiêu Chuẩn (Trong tỉnh)</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary">Mặc định</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="fw-bold text-danger">
                                        <fmt:formatNumber value="${o.finalAmount}" pattern="#,#00 ₫"/>
                                    </td>
                                    <td>
                                        <span class="badge bg-light text-dark border">${o.paymentMethod}</span>
                                        <div class="small text-muted mt-1">${o.paymentStatus}</div>
                                    </td>
                                    <td>
                                        <span class="badge bg-info text-dark">${o.orderStatus}</span>
                                    </td>
                                    <td>
                                        <form method="post" action="/vendor/orders/${o.id}/status" class="d-flex gap-1">
                                            <c:if test="${o.orderStatus == 'NEW'}">
                                                <button name="status" value="CONFIRMED" class="btn btn-sm btn-success rounded-pill fw-bold px-2">Xác nhận</button>
                                                <button name="status" value="CANCELLED" class="btn btn-sm btn-outline-danger rounded-pill px-2">Hủy</button>
                                            </c:if>
                                            <c:if test="${o.orderStatus == 'CONFIRMED'}">
                                                <button name="status" value="PACKING" class="btn btn-sm btn-primary rounded-pill px-2">Chuẩn bị</button>
                                                <button name="status" value="READY_FOR_PICKUP" class="btn btn-sm btn-warning rounded-pill px-2">Sẵn sàng lấy</button>
                                            </c:if>
                                            <c:if test="${o.orderStatus == 'PACKING'}">
                                                <button name="status" value="READY_FOR_PICKUP" class="btn btn-sm btn-warning rounded-pill px-2">Sẵn sàng lấy</button>
                                            </c:if>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty orders}">
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-5">
                                        <i class="fa-solid fa-box-open fs-2 mb-2 text-secondary d-block"></i>
                                        Không có đơn hàng nào
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>
<jsp:include page="../../common/footer.jsp"/>
