<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="title" value="Đơn hàng Cửa hàng - Vendor" scope="request"/>
<jsp:include page="../../common/header.jsp"/>

<style>
    .order-stat-card {
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        box-shadow: 0 2px 6px rgba(15, 23, 42, 0.04);
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        text-decoration: none;
        color: inherit;
        background: #ffffff;
        position: relative;
        overflow: hidden;
        display: block;
        padding: 12px 16px;
        height: 100%;
    }
    .order-stat-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 16px rgba(15, 23, 42, 0.08);
        color: inherit;
        border-color: #cbd5e1;
    }
    .order-stat-card.active-filter {
        border: 2px solid #2563eb;
        background: linear-gradient(180deg, #f0f7ff 0%, #ffffff 100%);
        box-shadow: 0 4px 14px rgba(37, 99, 235, 0.12);
    }
    .order-stat-card .stat-label {
        font-size: 12.5px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        color: #475569;
    }
    .order-stat-card .stat-number {
        font-size: 1.55rem;
        font-weight: 800;
        line-height: 1.2;
        letter-spacing: -0.5px;
        margin-top: 3px;
        margin-bottom: 2px;
    }
    .order-stat-card .stat-sub {
        font-size: 12.5px;
        line-height: 1.3;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .order-stat-card .stat-icon {
        width: 38px;
        height: 38px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 16px;
        flex-shrink: 0;
        transition: transform 0.2s ease;
    }
    .order-stat-card:hover .stat-icon {
        transform: scale(1.08);
    }
    .stat-icon.icon-all {
        background: rgba(37, 99, 235, 0.1);
        color: #2563eb;
    }
    .stat-icon.icon-pending {
        background: rgba(245, 158, 11, 0.12);
        color: #d97706;
    }
    .stat-icon.icon-processing {
        background: rgba(6, 182, 212, 0.12);
        color: #0891b2;
    }
    .stat-icon.icon-shipping {
        background: rgba(99, 102, 241, 0.12);
        color: #4f46e5;
    }
    .stat-icon.icon-success {
        background: rgba(16, 185, 129, 0.12);
        color: #059669;
    }
    .stat-icon.icon-return {
        background: rgba(239, 68, 68, 0.12);
        color: #dc2626;
    }
    .btn-returns-header {
        background: linear-gradient(135deg, #f97316, #ea580c);
        color: #ffffff !important;
        border: none;
        border-radius: 50rem;
        padding: 8px 20px;
        font-weight: 700;
        font-size: 14.5px;
        box-shadow: 0 3px 10px rgba(234, 88, 12, 0.28);
        display: inline-flex;
        align-items: center;
        gap: 8px;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        text-decoration: none;
    }
    .btn-returns-header:hover {
        background: linear-gradient(135deg, #ea580c, #c2410c);
        transform: translateY(-1px);
        box-shadow: 0 6px 16px rgba(234, 88, 12, 0.38);
        color: #ffffff !important;
    }
    .btn-returns-header .badge-counter {
        background: #ffffff;
        color: #dc2626;
        font-size: 12px;
        font-weight: 800;
        padding: 2px 8px;
        border-radius: 50rem;
    }
    .badge-momo {
        background: linear-gradient(135deg, #a50064, #d82d8b);
        color: #ffffff;
        font-weight: 600;
        letter-spacing: 0.3px;
        box-shadow: 0 2px 6px rgba(165, 0, 100, 0.25);
    }
    .pulse-dot {
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background-color: #ffc107;
        display: inline-block;
        animation: pulseAnimation 1.5s infinite;
    }
    @keyframes pulseAnimation {
        0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(255, 193, 7, 0.7); }
        70% { transform: scale(1.2); box-shadow: 0 0 0 6px rgba(255, 193, 7, 0); }
        100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(255, 193, 7, 0); }
    }
    .table-container {
        border-radius: 16px;
        background: #fff;
        box-shadow: 0 4px 20px rgba(0,0,0,0.05);
        overflow: hidden;
    }
    .order-table thead th {
        background-color: #f8fafc;
        color: #334155;
        font-size: 13.5px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        padding: 16px 18px;
        border-bottom: 1.5px solid #cbd5e1;
    }
    .order-table tbody td {
        padding: 16px 18px;
        vertical-align: middle;
        border-bottom: 1px solid #f1f5f9;
        font-size: 14.5px;
    }
    .order-table tbody tr:hover {
        background-color: #f8fafc;
    }
    .order-code-badge {
        font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
        font-weight: 700;
        color: #0d6efd;
        font-size: 14px;
        white-space: nowrap !important;
        display: inline-flex;
        align-items: center;
    }
    .btn-action-confirm {
        background: linear-gradient(135deg, #198754, #20c997);
        color: white;
        border: none;
        box-shadow: 0 3px 8px rgba(25, 135, 84, 0.25);
        transition: all 0.2s;
    }
    .btn-action-confirm:hover {
        background: linear-gradient(135deg, #157347, #1aa179);
        color: white;
        transform: translateY(-1px);
        box-shadow: 0 5px 12px rgba(25, 135, 84, 0.35);
    }
    .order-time {
        font-size: 13px;
        color: #64748b;
    }
    .customer-name {
        font-size: 15.5px;
        font-weight: 700;
        color: #1e293b;
    }
    .customer-phone {
        font-size: 14px;
        color: #475569;
    }
    .customer-address {
        font-size: 13.5px;
        color: #64748b;
        max-width: 250px;
    }
    .order-amount {
        font-size: 1.15rem;
        font-weight: 800;
        color: #dc2626;
        letter-spacing: -0.3px;
        white-space: nowrap !important;
        display: inline-block;
    }
    .btn-view-detail {
        width: 36px;
        height: 36px;
        padding: 0;
        background-color: #f8fafc;
        border-color: #cbd5e1 !important;
        transition: all 0.2s ease;
    }
    .btn-view-detail:hover {
        background-color: #e2e8f0;
        color: #0d6efd;
        border-color: #94a3b8 !important;
        transform: translateY(-1px);
    }
    .shipping-badge {
        font-size: 12.5px;
        font-weight: 600;
        padding: 3px 10px;
        border-radius: 50rem;
    }
    .shipper-info-badge {
        font-size: 12.5px;
        font-weight: 600;
        border-radius: 8px;
        display: inline-block;
        max-width: 235px;
        white-space: normal;
        vertical-align: middle;
        line-height: 1.35;
    }
    .payment-badge {
        font-size: 13px;
        font-weight: 600;
        padding: 4px 11px;
        border-radius: 50rem;
    }
    .payment-status-text {
        font-size: 13.5px;
        font-weight: 600;
    }
    .payment-time {
        font-size: 12px;
        color: #64748b;
    }
    .order-status-pill {
        font-size: 13.5px;
        font-weight: 700;
        padding: 6px 14px;
        border-radius: 50rem;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
    .btn-order-action {
        font-size: 13.5px;
        font-weight: 700;
        padding: 6px 14px;
        border-radius: 50rem;
        display: inline-flex;
        align-items: center;
        gap: 5px;
    }
</style>

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp"/>
    <div class="flex-grow-1 bg-light">
        <jsp:include page="../../common/navbar.jsp"/>
        <main class="main-content container-fluid p-4">

            <!-- Tiêu đề & Nút chuyển trang -->
            <div class="d-flex flex-wrap justify-content-between align-items-center mb-3 gap-3">
                <div>
                    <h3 class="fw-bold mb-1 text-dark">
                        <i class="fa-solid fa-boxes-packing text-warning me-2"></i>Quản Lý Đơn Hàng Cửa Hàng
                    </h3>
                    <p class="text-muted small mb-0">Theo dõi, kiểm tra thanh toán MoMo/COD và xử lý quy trình giao nhận đơn hàng</p>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <a href="/vendor/returns" class="btn-returns-header">
                        <i class="fa-solid fa-arrow-rotate-left"></i>
                        <span>Quản lý Đổi Trả</span>
                        <c:if test="${returnsCount > 0}">
                            <span class="badge-counter">${returnsCount}</span>
                        </c:if>
                    </a>
                </div>
            </div>

            <!-- Thông báo thành công / Thất bại -->
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm rounded-4 d-flex align-items-center mb-3" role="alert">
                    <div class="me-3 fs-4 text-success"><i class="fa-solid fa-circle-check"></i></div>
                    <div class="flex-grow-1">
                        <strong class="d-block">Thành công!</strong>
                        <span><c:out value="${successMessage}"/></span>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm rounded-4 d-flex align-items-center mb-3" role="alert">
                    <div class="me-3 fs-4 text-danger"><i class="fa-solid fa-triangle-exclamation"></i></div>
                    <div class="flex-grow-1">
                        <strong class="d-block">Không thể thực hiện!</strong>
                        <span><c:out value="${errorMessage}"/></span>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- Thống kê trạng thái đơn hàng (Metric Cards) -->
            <div class="row g-2 mb-3">
                <div class="col-6 col-md-4 col-xl-2">
                    <a href="/vendor/orders" class="order-stat-card ${empty selectedStatus ? 'active-filter' : ''}">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <span class="stat-label">Tất cả đơn</span>
                            <div class="stat-icon icon-all">
                                <i class="fa-solid fa-layer-group"></i>
                            </div>
                        </div>
                        <div class="stat-number text-dark">${totalCount}</div>
                        <span class="stat-sub text-muted">Toàn bộ đơn hàng</span>
                    </a>
                </div>

                <div class="col-6 col-md-4 col-xl-2">
                    <a href="/vendor/orders?status=NEW" class="order-stat-card ${selectedStatus == 'NEW' ? 'active-filter' : ''}">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <span class="stat-label">Chờ duyệt</span>
                            <div class="stat-icon icon-pending">
                                <i class="fa-solid fa-hourglass-start"></i>
                            </div>
                        </div>
                        <div class="stat-number text-warning-emphasis">${newCount}</div>
                        <c:choose>
                            <c:when test="${awaitingMomoCount > 0}">
                                <div class="stat-sub">
                                    <span class="badge bg-danger rounded-pill px-2 py-0.5" style="font-size: 10px;">
                                        <span class="pulse-dot me-1"></span>${awaitingMomoCount} MoMo cần duyệt
                                    </span>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <span class="stat-sub text-muted">Đơn hàng mới</span>
                            </c:otherwise>
                        </c:choose>
                    </a>
                </div>

                <div class="col-6 col-md-4 col-xl-2">
                    <a href="/vendor/orders?status=CONFIRMED" class="order-stat-card ${selectedStatus == 'CONFIRMED' || selectedStatus == 'PACKING' ? 'active-filter' : ''}">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <span class="stat-label">Đang xử lý</span>
                            <div class="stat-icon icon-processing">
                                <i class="fa-solid fa-box-archive"></i>
                            </div>
                        </div>
                        <div class="stat-number text-info-emphasis">${processingCount}</div>
                        <span class="stat-sub text-muted">Đã duyệt &amp; đóng gói</span>
                    </a>
                </div>

                <div class="col-6 col-md-4 col-xl-2">
                    <a href="/vendor/orders?status=READY_FOR_PICKUP" class="order-stat-card ${selectedStatus == 'READY_FOR_PICKUP' ? 'active-filter' : ''}">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <span class="stat-label">Chờ lấy hàng</span>
                            <div class="stat-icon icon-shipping">
                                <i class="fa-solid fa-motorcycle"></i>
                            </div>
                        </div>
                        <div class="stat-number text-primary">${readyForPickupCount}</div>
                        <span class="stat-sub text-muted">Cần gán shipper</span>
                    </a>
                </div>

                <div class="col-6 col-md-4 col-xl-2">
                    <a href="/vendor/orders?status=DELIVERED" class="order-stat-card ${selectedStatus == 'DELIVERED' ? 'active-filter' : ''}">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <span class="stat-label">Thành công</span>
                            <div class="stat-icon icon-success">
                                <i class="fa-solid fa-circle-check"></i>
                            </div>
                        </div>
                        <div class="stat-number text-success">${deliveredCount}</div>
                        <span class="stat-sub text-muted">Đã giao tới khách</span>
                    </a>
                </div>

                <div class="col-6 col-md-4 col-xl-2">
                    <a href="/vendor/returns" class="order-stat-card">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <span class="stat-label">Đổi trả</span>
                            <div class="stat-icon icon-return">
                                <i class="fa-solid fa-arrow-rotate-left"></i>
                            </div>
                        </div>
                        <div class="stat-number text-danger">${returnsCount}</div>
                        <span class="stat-sub text-muted">Yêu cầu hoàn trả</span>
                    </a>
                </div>
            </div>

            <!-- Thanh Tìm Kiếm & Bộ Lọc Nhanh -->
            <div class="card border-0 shadow-sm rounded-4 mb-3">
                <div class="card-body p-3">
                    <div class="row g-2 align-items-center">
                        <div class="col-md-5 col-lg-4">
                            <div class="input-group">
                                <span class="input-group-text bg-white border-end-0 text-muted ps-3">
                                    <i class="fa-solid fa-magnifying-glass"></i>
                                </span>
                                <input type="text" id="orderSearchInput" class="form-control border-start-0 ps-1" style="font-size: 14.5px;"
                                       placeholder="Tìm theo mã đơn, người nhận, SĐT..." onkeyup="filterOrdersTable()">
                                <button type="button" class="btn btn-light border border-start-0 text-muted" onclick="clearSearchInput()" title="Xóa tìm kiếm">
                                    <i class="fa-solid fa-xmark"></i>
                                </button>
                            </div>
                        </div>
                        <div class="col-md-7 col-lg-8 d-flex justify-content-md-end align-items-center gap-2 flex-wrap">
                            <span class="text-muted fw-semibold d-none d-lg-inline" style="font-size: 14px;">Lọc trạng thái:</span>
                            <form class="d-flex align-items-center mb-0">
                                <select name="status" class="form-select rounded-pill px-3 fw-semibold shadow-sm border-secondary-subtle" style="font-size: 14px; padding-top: 6px; padding-bottom: 6px;" onchange="this.form.submit()">
                                    <option value="" ${empty selectedStatus ? 'selected' : ''}>Tất cả trạng thái (${totalCount})</option>
                                    <c:forEach var="s" items="${statuses}">
                                        <option value="${s}" ${selectedStatus == s ? 'selected' : ''}>
                                            <c:choose>
                                                <c:when test="${s == 'NEW'}">Đơn mới</c:when>
                                                <c:when test="${s == 'CONFIRMED'}">Đã duyệt</c:when>
                                                <c:when test="${s == 'PACKING'}">Đang đóng gói</c:when>
                                                <c:when test="${s == 'READY_FOR_PICKUP'}">Chờ lấy hàng</c:when>
                                                <c:when test="${s == 'PICKED_UP'}">Đã lấy hàng</c:when>
                                                <c:when test="${s == 'SHIPPING'}">Đang giao hàng</c:when>
                                                <c:when test="${s == 'DELIVERED'}">Giao thành công</c:when>
                                                <c:when test="${s == 'CANCELLED'}">Đã hủy</c:when>
                                                <c:when test="${s == 'RETURN_REQUESTED'}">Yêu cầu hoàn trả</c:when>
                                                <c:when test="${s == 'RETURNED'}">Đã về kho</c:when>
                                                <c:when test="${s == 'REFUNDED'}">Đã hoàn tiền</c:when>
                                                <c:otherwise>${s}</c:otherwise>
                                            </c:choose> (${s})
                                        </option>
                                    </c:forEach>
                                </select>
                            </form>
                            <c:if test="${not empty selectedStatus}">
                                <a href="/vendor/orders" class="btn btn-outline-secondary rounded-pill px-3" style="font-size: 14px; padding-top: 5px; padding-bottom: 5px;">
                                    <i class="fa-solid fa-xmark me-1"></i>Bỏ lọc
                                </a>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Bảng Danh Sách Đơn Hàng -->
            <div class="table-container">
                <div class="table-responsive">
                    <table class="table order-table align-middle mb-0" id="ordersTable">
                        <thead>
                            <tr>
                                <th style="min-width: 185px; white-space: nowrap;">Mã đơn &amp; Thời gian</th>
                                <th style="min-width: 195px; max-width: 215px;">Khách hàng</th>
                                <th style="min-width: 225px; max-width: 250px;">Vận chuyển &amp; Shipper</th>
                                <th style="min-width: 125px; white-space: nowrap;" class="text-nowrap">Tổng tiền</th>
                                <th style="min-width: 170px;">Thanh toán</th>
                                <th style="min-width: 135px;">Trạng thái</th>
                                <th style="min-width: 220px; white-space: nowrap;" class="text-center">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="o" items="${orders}">
                                <c:set var="da" value="${assignments[o.id]}"/>
                                <tr class="order-row" data-code="${o.orderCode}" data-name="${o.receiverName}" data-phone="${o.receiverPhone}" data-status="${o.orderStatus}">
                                    <!-- Mã đơn & Ngày tạo -->
                                    <td class="text-nowrap">
                                        <div class="d-flex align-items-center gap-1.5 flex-nowrap">
                                            <a href="/vendor/orders/${o.id}" class="order-code-badge text-decoration-none text-nowrap" title="Xem chi tiết đơn #${o.orderCode}">
                                                ${o.orderCode}
                                                <i class="fa-solid fa-arrow-up-right-from-square small ms-1 text-muted" style="font-size: 11px;"></i>
                                            </a>
                                        </div>
                                        <div class="order-time mt-1 text-nowrap">
                                            <i class="fa-regular fa-clock me-1"></i>${not empty o.formattedCreatedAt ? o.formattedCreatedAt : o.createdAt}
                                        </div>
                                        <c:if test="${o.orderStatus == 'RETURN_REQUESTED' || o.orderStatus == 'RETURNED' || o.orderStatus == 'REFUNDED'}">
                                            <div class="mt-1">
                                                <span class="badge bg-warning text-dark px-2 py-1" style="font-size: 11.5px;">
                                                    <i class="fa-solid fa-rotate-left me-1"></i>Đơn đổi trả
                                                </span>
                                            </div>
                                        </c:if>
                                    </td>

                                    <!-- Khách hàng / Người nhận -->
                                    <td>
                                        <div class="customer-name"><c:out value="${o.receiverName}"/></div>
                                        <div class="customer-phone mt-1">
                                            <i class="fa-solid fa-phone me-1 text-secondary"></i><c:out value="${o.receiverPhone}"/>
                                        </div>
                                        <c:choose>
                                            <c:when test="${not empty o.returnAddress}">
                                                <div class="small text-danger mt-1 p-1.5 rounded bg-danger bg-opacity-10" style="font-size: 12px; line-height: 1.35;">
                                                    <c:choose>
                                                        <c:when test="${fn:contains(o.returnAddress, ' - ')}">
                                                            <div>
                                                                <i class="fa-solid fa-location-dot me-1"></i><strong>Lấy hoàn:</strong> <c:out value="${fn:substringBefore(o.returnAddress, ' - ')}"/> -
                                                            </div>
                                                            <div class="text-muted ms-3">
                                                                <c:out value="${fn:substringAfter(o.returnAddress, ' - ')}"/>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div><i class="fa-solid fa-location-dot me-1"></i><strong>Lấy hoàn:</strong> <c:out value="${o.returnAddress}"/></div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="customer-address mt-1" style="font-size: 12.5px; color: #64748b; line-height: 1.35;" title="${o.shippingAddress}">
                                                    <c:choose>
                                                        <c:when test="${fn:contains(o.shippingAddress, ' - ')}">
                                                            <div><i class="fa-solid fa-location-dot me-1 text-secondary"></i><c:out value="${fn:substringBefore(o.shippingAddress, ' - ')}"/> -</div>
                                                            <div class="text-muted text-truncate ms-3"><c:out value="${fn:substringAfter(o.shippingAddress, ' - ')}"/></div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="text-truncate"><i class="fa-solid fa-location-dot me-1 text-secondary"></i><c:out value="${o.shippingAddress}"/></div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Phương thức giao & Shipper -->
                                    <td>
                                        <c:choose>
                                            <c:when test="${o.shippingProvider != null}">
                                                <div class="mb-1">
                                                    <c:choose>
                                                        <c:when test="${o.shippingProvider.code == 'GHN_EXPRESS'}">
                                                            <span class="badge shipping-badge bg-danger"><i class="fa-solid fa-bolt me-1"></i>GHN Hỏa Tốc</span>
                                                        </c:when>
                                                        <c:when test="${o.shippingProvider.code == 'SPX_EXPRESS'}">
                                                            <span class="badge shipping-badge bg-warning text-dark"><i class="fa-solid fa-globe me-1"></i>SPX Express</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge shipping-badge bg-primary"><i class="fa-solid fa-house me-1"></i>GHN Tiêu Chuẩn</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge shipping-badge bg-secondary mb-1">Mặc định</span>
                                            </c:otherwise>
                                        </c:choose>

                                        <!-- Thông tin Shipper / Đơn vị giao vận -->
                                        <div class="mt-1">
                                            <c:choose>
                                                <c:when test="${o.orderStatus == 'NEW' || o.orderStatus == 'CONFIRMED' || o.orderStatus == 'PACKING'}">
                                                    <span class="badge shipper-info-badge bg-light text-muted border px-2.5 py-1">
                                                        <i class="fa-solid fa-user-clock me-1"></i>Chưa cần shipper
                                                    </span>
                                                </c:when>
                                                <c:when test="${o.shippingProvider != null && o.shippingProvider.code == 'SPX_EXPRESS' && o.orderStatus == 'READY_FOR_PICKUP'}">
                                                    <span class="badge shipper-info-badge bg-warning text-dark px-2.5 py-1" title="SPX Express không phân Shipper nội bộ">
                                                        <i class="fa-solid fa-globe me-1"></i>SPX chờ lấy hàng
                                                    </span>
                                                </c:when>
                                                <c:when test="${o.shippingProvider != null && o.shippingProvider.code == 'SPX_EXPRESS' && o.orderStatus == 'SHIPPING'}">
                                                    <span class="badge shipper-info-badge bg-info text-dark px-2.5 py-1" title="Trạng thái giao SPX được cửa hàng cập nhật">
                                                        <i class="fa-solid fa-truck-fast me-1"></i>SPX đang giao
                                                    </span>
                                                </c:when>
                                                <c:when test="${o.shippingProvider != null && o.shippingProvider.code == 'SPX_EXPRESS' && o.orderStatus == 'DELIVERED'}">
                                                    <span class="badge shipper-info-badge bg-success text-white px-2.5 py-1" title="Đơn SPX đã được Vendor xác nhận giao xong">
                                                        <i class="fa-solid fa-circle-check me-1"></i>SPX giao xong
                                                    </span>
                                                </c:when>
                                                <c:when test="${not empty da && not empty da.shipper}">
                                                    <c:choose>
                                                        <c:when test="${fn:contains(da.shipper.fullName, ' - ')}">
                                                            <c:set var="shipperTeam" value="${fn:substringBefore(da.shipper.fullName, ' - ')}"/>
                                                            <c:set var="shipperDriver" value="${fn:substringAfter(da.shipper.fullName, ' - ')}"/>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:set var="shipperTeam" value="${da.shipper.fullName}"/>
                                                            <c:set var="shipperDriver" value=""/>
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <c:choose>
                                                        <c:when test="${da.status == 'ASSIGNED'}">
                                                            <span class="badge shipper-info-badge bg-warning text-dark text-start d-inline-block px-2.5 py-1.5" title="Chờ nhận: ${da.shipper.fullName}">
                                                                <div><i class="fa-solid fa-clock me-1"></i><c:out value="${shipperTeam}"/><c:if test="${not empty shipperDriver}"> -</c:if></div>
                                                                <c:if test="${not empty shipperDriver}">
                                                                    <div class="ps-3 fw-bold" style="font-size: 12.5px;"><c:out value="${shipperDriver}"/></div>
                                                                </c:if>
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${da.status == 'ACCEPTED'}">
                                                            <span class="badge shipper-info-badge bg-info text-dark text-start d-inline-block px-2.5 py-1.5" title="Đã nhận đơn: ${da.shipper.fullName}">
                                                                <div><i class="fa-solid fa-check me-1"></i><c:out value="${shipperTeam}"/><c:if test="${not empty shipperDriver}"> -</c:if></div>
                                                                <c:if test="${not empty shipperDriver}">
                                                                    <div class="ps-3 fw-bold" style="font-size: 12.5px;"><c:out value="${shipperDriver}"/></div>
                                                                </c:if>
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${da.status == 'PICKED_UP'}">
                                                            <span class="badge shipper-info-badge bg-primary text-white text-start d-inline-block px-2.5 py-1.5" title="Đã lấy hàng: ${da.shipper.fullName}">
                                                                <div><i class="fa-solid fa-box me-1"></i><c:out value="${shipperTeam}"/><c:if test="${not empty shipperDriver}"> -</c:if></div>
                                                                <c:if test="${not empty shipperDriver}">
                                                                    <div class="ps-3 fw-bold" style="font-size: 12.5px;"><c:out value="${shipperDriver}"/></div>
                                                                </c:if>
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${da.status == 'SHIPPING'}">
                                                            <span class="badge shipper-info-badge bg-info text-dark text-start d-inline-block px-2.5 py-1.5" title="Đang giao: ${da.shipper.fullName}">
                                                                <div><i class="fa-solid fa-motorcycle me-1"></i><c:out value="${shipperTeam}"/><c:if test="${not empty shipperDriver}"> -</c:if></div>
                                                                <c:if test="${not empty shipperDriver}">
                                                                    <div class="ps-3 fw-bold" style="font-size: 12.5px;"><c:out value="${shipperDriver}"/></div>
                                                                </c:if>
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${da.status == 'DELIVERED' && (o.orderStatus == 'RETURN_REQUESTED' || o.orderStatus == 'RETURNED' || o.orderStatus == 'REFUNDED') && not empty da.note && (fn:contains(fn:toLowerCase(da.note), 'hoàn trả') || fn:contains(fn:toLowerCase(da.note), 'thu hồi'))}">
                                                            <span class="badge shipper-info-badge bg-success text-white text-start d-inline-block px-2.5 py-1.5" title="Đã nhận hàng hoàn từ Shipper ${da.shipper.fullName}">
                                                                <div><i class="fa-solid fa-box-open me-1"></i>Đã nhận hàng hoàn</div>
                                                                <div class="ps-3 fw-bold" style="font-size: 12.5px;"><c:out value="${shipperTeam}"/><c:if test="${not empty shipperDriver}"> - <c:out value="${shipperDriver}"/></c:if></div>
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${da.status == 'DELIVERED' && o.orderStatus == 'RETURN_REQUESTED' && (empty da.note || (!fn:contains(fn:toLowerCase(da.note), 'hoàn trả') && !fn:contains(fn:toLowerCase(da.note), 'thu hồi')))}">
                                                            <span class="badge shipper-info-badge bg-success text-white text-start d-inline-block px-2.5 py-1.5" title="Shipper đã giao đơn hàng ban đầu: ${da.shipper.fullName}">
                                                                <div><i class="fa-solid fa-circle-check me-1"></i>Đã giao đơn ban đầu</div>
                                                                <div class="ps-3 fw-bold" style="font-size: 12.5px;"><c:out value="${shipperTeam}"/><c:if test="${not empty shipperDriver}"> - <c:out value="${shipperDriver}"/></c:if></div>
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${da.status == 'DELIVERED'}">
                                                            <span class="badge shipper-info-badge bg-success text-white text-start d-inline-block px-2.5 py-1.5" title="Giao xong: ${da.shipper.fullName}">
                                                                <div><i class="fa-solid fa-circle-check me-1"></i><c:out value="${shipperTeam}"/><c:if test="${not empty shipperDriver}"> -</c:if></div>
                                                                <c:if test="${not empty shipperDriver}">
                                                                    <div class="ps-3 fw-bold" style="font-size: 12.5px;"><c:out value="${shipperDriver}"/></div>
                                                                </c:if>
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${da.status == 'CANCELLED'}">
                                                            <span class="badge shipper-info-badge bg-danger text-white text-start d-inline-block px-2.5 py-1.5" title="${da.shipper.fullName} từ chối">
                                                                <div><i class="fa-solid fa-ban me-1"></i><c:out value="${shipperTeam}"/><c:if test="${not empty shipperDriver}"> -</c:if></div>
                                                                <c:if test="${not empty shipperDriver}">
                                                                    <div class="ps-3 fw-bold" style="font-size: 12.5px;"><c:out value="${shipperDriver}"/></div>
                                                                </c:if>
                                                            </span>
                                                            <c:if test="${not empty da.failureReason}">
                                                                <div class="text-truncate text-danger small mt-0.5" style="max-width: 225px; font-size: 11.5px;" title="${da.failureReason}">
                                                                    <i class="fa-solid fa-triangle-exclamation me-1"></i><c:out value="${da.failureReason}"/>
                                                                </div>
                                                            </c:if>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge shipper-info-badge bg-secondary text-start d-inline-block px-2.5 py-1.5" title="${da.shipper.fullName}">
                                                                <div><c:out value="${shipperTeam}"/><c:if test="${not empty shipperDriver}"> -</c:if></div>
                                                                <c:if test="${not empty shipperDriver}">
                                                                    <div class="ps-3 fw-bold" style="font-size: 12.5px;"><c:out value="${shipperDriver}"/></div>
                                                                </c:if>
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge shipper-info-badge bg-warning bg-opacity-25 text-dark border border-warning px-2.5 py-1">
                                                        <i class="fa-solid fa-user-clock me-1 text-warning"></i>Chờ phân shipper
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>

                                    <!-- Tổng tiền -->
                                    <td class="text-nowrap">
                                        <div class="order-amount">
                                            <fmt:formatNumber value="${o.finalAmount}" pattern="#,##0 ₫"/>
                                        </div>
                                    </td>

                                    <!-- Thanh toán -->
                                    <td>
                                        <div class="d-flex align-items-center gap-1 mb-1">
                                            <c:choose>
                                                <c:when test="${o.paymentMethod == 'MOMO'}">
                                                    <span class="badge payment-badge badge-momo">
                                                        <i class="fa-solid fa-wallet me-1"></i>Ví MoMo
                                                    </span>
                                                </c:when>
                                                <c:when test="${o.paymentMethod == 'VNPAY'}">
                                                    <span class="badge payment-badge bg-primary">
                                                        <i class="fa-solid fa-qrcode me-1"></i>VNPay
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge payment-badge bg-light text-dark border">
                                                        <i class="fa-solid fa-money-bill-wave text-success me-1"></i>COD
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <!-- Trạng thái thanh toán -->
                                        <c:choose>
                                            <c:when test="${o.paymentStatus == 'PAID'}">
                                                <div class="payment-status-text text-success">
                                                    <i class="fa-solid fa-circle-check me-1"></i>Đã thanh toán
                                                </div>
                                                <c:if test="${not empty o.paymentConfirmedAt}">
                                                    <div class="payment-time mt-0.5">
                                                        <i class="fa-regular fa-clock me-1"></i>${not empty o.formattedPaymentConfirmedAt ? o.formattedPaymentConfirmedAt : o.paymentConfirmedAt}
                                                    </div>
                                                </c:if>
                                            </c:when>
                                            <c:when test="${o.paymentMethod == 'MOMO' && o.paymentStatus == 'AWAITING_CONFIRMATION'}">
                                                <span class="badge bg-warning text-dark border border-warning rounded-pill py-1 px-2.5 fw-bold" style="font-size: 12.5px;">
                                                    <span class="pulse-dot me-1"></span>Khách báo đã chuyển!
                                                </span>
                                                <c:if test="${not empty o.paymentSubmittedAt}">
                                                    <div class="payment-time mt-1">
                                                        <i class="fa-regular fa-clock me-1"></i>${not empty o.formattedPaymentSubmittedAt ? o.formattedPaymentSubmittedAt : o.paymentSubmittedAt}
                                                    </div>
                                                </c:if>
                                            </c:when>
                                            <c:when test="${o.paymentStatus == 'PENDING'}">
                                                <span class="badge bg-secondary bg-opacity-25 text-secondary border rounded-pill px-2.5 py-1" style="font-size: 12.5px;">
                                                    <i class="fa-regular fa-hourglass-half me-1"></i>Chờ thanh toán
                                                </span>
                                            </c:when>
                                            <c:when test="${o.paymentStatus == 'REFUNDED'}">
                                                <span class="badge bg-info bg-opacity-25 text-dark border rounded-pill px-2.5 py-1" style="font-size: 12.5px;">
                                                    <i class="fa-solid fa-rotate-left me-1"></i>Đã hoàn tiền
                                                </span>
                                            </c:when>
                                            <c:when test="${o.paymentStatus == 'FAILED'}">
                                                <span class="badge bg-danger bg-opacity-25 text-danger border rounded-pill px-2.5 py-1" style="font-size: 12.5px;">
                                                    <i class="fa-solid fa-circle-xmark me-1"></i>Thất bại
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-light text-muted border rounded-pill px-2.5 py-1" style="font-size: 12.5px;">${o.paymentStatus}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Trạng thái Đơn hàng -->
                                    <td>
                                        <c:choose>
                                            <c:when test="${o.orderStatus == 'NEW'}">
                                                <span class="badge order-status-pill bg-primary bg-opacity-10 text-primary border border-primary border-opacity-25">
                                                    <i class="fa-solid fa-sparkles me-1"></i>Đơn mới
                                                </span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'CONFIRMED'}">
                                                <span class="badge order-status-pill bg-info bg-opacity-10 text-info-emphasis border border-info border-opacity-25">
                                                    <i class="fa-solid fa-clipboard-check me-1"></i>Đã duyệt
                                                </span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'PACKING'}">
                                                <span class="badge order-status-pill bg-warning bg-opacity-10 text-dark border border-warning border-opacity-25">
                                                    <i class="fa-solid fa-box-open me-1 text-warning"></i>Đang đóng gói
                                                </span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'READY_FOR_PICKUP'}">
                                                <span class="badge order-status-pill bg-primary bg-opacity-10 text-primary border border-primary border-opacity-25">
                                                    <i class="fa-solid fa-dolly me-1"></i>Chờ lấy hàng
                                                </span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'PICKED_UP'}">
                                                <span class="badge order-status-pill bg-secondary bg-opacity-10 text-secondary border border-secondary border-opacity-25">
                                                    <i class="fa-solid fa-box me-1"></i>Đã lấy hàng
                                                </span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'SHIPPING'}">
                                                <span class="badge order-status-pill bg-info bg-opacity-10 text-primary border border-info border-opacity-25">
                                                    <i class="fa-solid fa-motorcycle me-1"></i>Đang giao
                                                </span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'DELIVERED'}">
                                                <span class="badge order-status-pill bg-success bg-opacity-10 text-success border border-success border-opacity-25">
                                                    <i class="fa-solid fa-circle-check me-1"></i>Giao thành công
                                                </span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'CANCELLED'}">
                                                <span class="badge order-status-pill bg-danger bg-opacity-10 text-danger border border-danger border-opacity-25">
                                                    <i class="fa-solid fa-ban me-1"></i>Đã hủy
                                                </span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'RETURN_REQUESTED'}">
                                                <span class="badge order-status-pill bg-warning text-dark">
                                                    <i class="fa-solid fa-rotate-left me-1"></i>Yêu cầu hoàn trả
                                                </span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'RETURNED'}">
                                                <span class="badge order-status-pill bg-info text-dark">
                                                    <i class="fa-solid fa-warehouse me-1"></i>Đã về kho
                                                </span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'REFUNDED'}">
                                                <span class="badge order-status-pill bg-success text-white">
                                                    <i class="fa-solid fa-hand-holding-dollar me-1"></i>Đã hoàn tiền
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge order-status-pill bg-secondary">${o.orderStatus}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <!-- Thao tác Hành Động -->
                                    <td class="text-center text-nowrap">
                                        <div class="d-flex flex-nowrap justify-content-center align-items-center gap-2">

                                            <!-- Đơn hàng MỚI (NEW) -->
                                            <c:if test="${o.orderStatus == 'NEW'}">
                                                <c:choose>
                                                    <%-- Trường hợp 1: MoMo khách đã báo chuyển tiền -> Nút xác nhận nhận tiền & duyệt đơn 1 chạm --%>
                                                    <c:when test="${o.paymentMethod == 'MOMO' && o.paymentStatus == 'AWAITING_CONFIRMATION'}">
                                                        <fmt:formatNumber var="momoConfirmAmount" value="${o.finalAmount}" pattern="#,##0 ₫"/>
                                                        <form method="post" action="/vendor/orders/${o.id}/status" class="d-inline m-0 p-0 flex-shrink-0"
                                                              onsubmit="return confirm('Bạn xác nhận đã kiểm tra MoMo, nhận đủ ${momoConfirmAmount} và duyệt đơn #${o.orderCode}?');">
                                                            <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                                            <button type="submit" name="status" value="CONFIRMED" class="btn btn-success btn-order-action shadow-sm flex-shrink-0"
                                                                    title="Xác nhận nhận đủ tiền MoMo và duyệt đơn">
                                                                <i class="fa-solid fa-check"></i>
                                                                <span>Xác nhận</span>
                                                            </button>
                                                        </form>
                                                    </c:when>

                                                    <%-- Trường hợp 2: MoMo nhưng khách chưa bấm xác nhận chuyển tiền --%>
                                                    <c:when test="${o.paymentMethod == 'MOMO' && o.paymentStatus == 'PENDING'}">
                                                        <button type="button" class="btn btn-order-action btn-outline-secondary flex-shrink-0" disabled
                                                                title="Khách hàng chưa gửi xác nhận đã chuyển tiền MoMo. Vui lòng chờ khách chuyển hoặc liên hệ khách.">
                                                            <i class="fa-solid fa-clock-rotate-left me-1"></i>Chờ khách MoMo
                                                        </button>
                                                    </c:when>

                                                    <%-- Trường hợp 3: COD hoặc đã thanh toán trước --%>
                                                    <c:otherwise>
                                                        <form method="post" action="/vendor/orders/${o.id}/status" class="d-inline m-0 p-0 flex-shrink-0"
                                                              onsubmit="return confirm('Bạn có chắc chắn muốn xác nhận duyệt đơn hàng #${o.orderCode}?');">
                                                            <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                                            <button type="submit" name="status" value="CONFIRMED" class="btn btn-success btn-order-action shadow-sm flex-shrink-0">
                                                                <i class="fa-solid fa-check"></i>
                                                                <span>Xác nhận</span>
                                                            </button>
                                                        </form>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:if>

                                            <!-- Đơn hàng ĐÃ DUYỆT (CONFIRMED) -->
                                            <c:if test="${o.orderStatus == 'CONFIRMED'}">
                                                <form method="post" action="/vendor/orders/${o.id}/status" class="d-inline-flex gap-1.5 align-items-center m-0 p-0 flex-shrink-0">
                                                    <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                                    <button type="submit" name="status" value="PACKING" class="btn btn-primary btn-order-action shadow-sm flex-shrink-0" title="Bắt đầu đóng gói sách">
                                                        <i class="fa-solid fa-box-archive me-1"></i>Chuẩn bị
                                                    </button>
                                                    <button type="submit" name="status" value="READY_FOR_PICKUP" class="btn btn-warning text-dark btn-order-action shadow-sm flex-shrink-0" title="Đã gói xong, gọi shipper">
                                                        <i class="fa-solid fa-truck-ramp-box me-1"></i>Sẵn sàng lấy
                                                    </button>
                                                </form>
                                            </c:if>

                                            <!-- Đơn hàng ĐANG ĐÓNG GÓI (PACKING) -->
                                            <c:if test="${o.orderStatus == 'PACKING'}">
                                                <form method="post" action="/vendor/orders/${o.id}/status" class="d-inline m-0 p-0 flex-shrink-0">
                                                    <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                                    <button type="submit" name="status" value="READY_FOR_PICKUP" class="btn btn-warning text-dark btn-order-action shadow-sm flex-shrink-0" title="Hoàn tất đóng gói, chuyển sang chờ lấy">
                                                        <i class="fa-solid fa-truck-ramp-box me-1"></i>Sẵn sàng lấy
                                                    </button>
                                                </form>
                                            </c:if>

                                            <!-- Đơn hàng SẴN SÀNG LẤY HÀNG (READY_FOR_PICKUP) -->
                                            <c:if test="${o.orderStatus == 'READY_FOR_PICKUP'}">
                                                <c:choose>
                                                    <c:when test="${o.shippingProvider != null && o.shippingProvider.code == 'SPX_EXPRESS'}">
                                                        <form method="post" action="/vendor/orders/${o.id}/status" class="d-inline m-0 p-0 flex-shrink-0"
                                                              onsubmit="return confirm('Bắt đầu cập nhật trạng thái giao SPX cho đơn hàng #${o.orderCode}? Đơn này không dùng Shipper nội bộ.');">
                                                            <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                                            <button type="submit" name="status" value="SHIPPING" class="btn btn-warning text-dark btn-order-action shadow-sm flex-shrink-0" title="Cập nhật trạng thái SPX đang giao">
                                                                <i class="fa-solid fa-globe me-1"></i>Bắt đầu giao SPX
                                                            </button>
                                                        </form>
                                                    </c:when>
                                                    <c:when test="${not empty da && not empty da.shipper && da.status == 'CANCELLED'}">
                                                        <button type="button" class="btn btn-danger btn-order-action shadow-sm flex-shrink-0"
                                                                data-bs-toggle="modal" data-bs-target="#assignShipperModal${o.id}">
                                                            <i class="fa-solid fa-rotate-right me-1"></i>Phân lại Shipper
                                                        </button>
                                                    </c:when>
                                                    <c:when test="${not empty da && not empty da.shipper && da.status == 'ASSIGNED'}">
                                                        <button type="button" class="btn btn-outline-secondary btn-order-action flex-shrink-0"
                                                                data-bs-toggle="modal" data-bs-target="#assignShipperModal${o.id}">
                                                            <i class="fa-solid fa-user-pen me-1"></i>Đổi Shipper
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button type="button" class="btn btn-primary btn-order-action shadow-sm flex-shrink-0"
                                                                data-bs-toggle="modal" data-bs-target="#assignShipperModal${o.id}">
                                                            <i class="fa-solid fa-motorcycle me-1"></i>Phân Shipper
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:if>

                                            <c:if test="${o.orderStatus == 'SHIPPING' && o.shippingProvider != null && o.shippingProvider.code == 'SPX_EXPRESS'}">
                                                <form method="post" action="/vendor/orders/${o.id}/status" class="d-inline m-0 p-0 flex-shrink-0"
                                                      onsubmit="return confirm('Xác nhận SPX đã giao thành công đơn hàng #${o.orderCode}?');">
                                                    <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                                    <button type="submit" name="status" value="DELIVERED" class="btn btn-success btn-order-action shadow-sm flex-shrink-0" title="Xác nhận SPX giao hoàn tất">
                                                        <i class="fa-solid fa-check me-1"></i>Xác nhận SPX đã giao
                                                    </button>
                                                </form>
                                            </c:if>

                                            <!-- Đơn hàng ĐỔI TRẢ -->
                                            <c:if test="${o.orderStatus == 'RETURN_REQUESTED'}">
                                                <a href="/vendor/returns" class="btn btn-warning text-dark btn-order-action shadow-sm flex-shrink-0">
                                                    <i class="fa-solid fa-rotate-left me-1"></i>Xử lý đổi trả
                                                </a>
                                            </c:if>

                                            <c:if test="${o.orderStatus == 'RETURNED'}">
                                                <a href="/vendor/returns" class="btn btn-info text-dark btn-order-action shadow-sm flex-shrink-0">
                                                    <i class="fa-solid fa-hand-holding-dollar me-1"></i>Duyệt hoàn tiền
                                                </a>
                                            </c:if>

                                            <!-- Nút Xem chi tiết đơn -->
                                            <a href="/vendor/orders/${o.id}" class="btn btn-view-detail border rounded-circle flex-shrink-0 d-inline-flex align-items-center justify-content-center" title="Xem chi tiết đơn hàng">
                                                <i class="fa-solid fa-eye text-secondary" style="font-size: 14.5px;"></i>
                                            </a>
                                        </div>

                                        <!-- Form Thu Hồi Phân Công (ẩn) -->
                                        <form id="revokeForm${o.id}" method="post" action="/vendor/orders/${o.id}/revoke-shipper" onsubmit="return confirm('Bạn có chắc chắn muốn thu hồi phân công từ Shipper hiện tại? Đơn hàng sẽ trở về trạng thái chờ phân công.');">
                                            <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                            <input type="hidden" name="redirectUrl" value="/vendor/orders">
                                        </form>

                                        <!-- Modal Phân công Shipper -->
                                        <c:if test="${o.shippingProvider == null || o.shippingProvider.code != 'SPX_EXPRESS'}">
                                        <div class="modal fade" id="assignShipperModal${o.id}" tabindex="-1" aria-hidden="true">
                                            <div class="modal-dialog modal-dialog-centered text-start">
                                                <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden">
                                                    <div class="modal-header border-0 bg-primary text-white py-3 px-4">
                                                        <h5 class="modal-title fw-bold mb-0">
                                                            <i class="fa-solid fa-motorcycle me-2"></i>
                                                            <c:choose>
                                                                <c:when test="${not empty da && not empty da.shipper && da.status == 'CANCELLED'}">Phân Công Lại Shipper</c:when>
                                                                <c:when test="${not empty da && not empty da.shipper && da.status == 'ASSIGNED'}">Đổi Shipper / Điều Phối Lại</c:when>
                                                                <c:otherwise>Phân Công Giao Hàng</c:otherwise>
                                                            </c:choose>
                                                        </h5>
                                                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <form method="post" action="/vendor/orders/${o.id}/assign-shipper">
                                                        <c:if test="${not empty _csrf}">
                                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                        </c:if>
                                                        <input type="hidden" name="redirectUrl" value="/vendor/orders">
                                                        <div class="modal-body p-4">
                                                            <div class="alert alert-secondary border-0 small mb-3 rounded-3">
                                                                <div><strong>Mã đơn:</strong> <span class="order-code-badge">${o.orderCode}</span></div>
                                                                <div><strong>Khách hàng:</strong> <c:out value="${o.receiverName}"/> (<c:out value="${o.receiverPhone}"/>)</div>
                                                                <div>
                                                                    <strong>Đơn vị khách chọn:</strong>
                                                                    <span class="badge bg-primary text-white"><c:out value="${o.shippingProvider != null ? o.shippingProvider.name : 'Chưa chỉ định'}"/></span>
                                                                </div>
                                                                <c:choose>
                                                                    <c:when test="${o.orderStatus == 'RETURN_REQUESTED'}">
                                                                        <div class="mt-1"><strong>Địa chỉ lấy hàng hoàn:</strong> <span class="text-danger fw-bold"><c:out value="${not empty o.returnAddress ? o.returnAddress : o.shippingAddress}"/></span></div>
                                                                        <div><strong>Lý do hoàn trả:</strong> <c:out value="${not empty o.returnReason ? o.returnReason : o.note}"/></div>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <div class="mt-1"><strong>Địa chỉ giao:</strong> <c:out value="${o.shippingAddress}"/></div>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>

                                                            <!-- Thông tin phân công hiện tại -->
                                                            <c:if test="${not empty da && not empty da.shipper}">
                                                                <div class="card border ${da.status == 'CANCELLED' ? 'border-danger bg-danger bg-opacity-10' : (da.status == 'ASSIGNED' ? 'border-warning bg-warning bg-opacity-10' : 'border-info bg-info bg-opacity-10')} rounded-3 p-3 mb-3">
                                                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                                                        <span class="small fw-bold text-dark"><i class="fa-solid fa-user-tag me-1"></i>Trạng thái phân công:</span>
                                                                        <c:choose>
                                                                            <c:when test="${da.status == 'ASSIGNED'}">
                                                                                <span class="badge bg-warning text-dark"><i class="fa-solid fa-clock me-1"></i>Chờ Shipper xác nhận</span>
                                                                            </c:when>
                                                                            <c:when test="${da.status == 'CANCELLED'}">
                                                                                <span class="badge bg-danger"><i class="fa-solid fa-circle-xmark me-1"></i>Đã từ chối đơn</span>
                                                                            </c:when>
                                                                            <c:when test="${da.status == 'ACCEPTED'}">
                                                                                <span class="badge bg-info text-dark"><i class="fa-solid fa-check me-1"></i>Đã nhận đơn</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span class="badge bg-secondary">${da.status}</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </div>
                                                                    <div class="small text-dark">
                                                                        <strong>Nhân viên:</strong> <c:out value="${da.shipper.fullName}"/> (<c:out value="${da.shipper.phone}"/>) - <c:out value="${da.shipper.shippingProvider != null ? da.shipper.shippingProvider.name : 'Nội bộ'}"/>
                                                                    </div>
                                                                    <c:if test="${not empty da.failureReason}">
                                                                        <div class="small text-danger fw-semibold mt-1">
                                                                            <i class="fa-solid fa-circle-info me-1"></i><c:out value="${da.failureReason}"/>
                                                                        </div>
                                                                    </c:if>
                                                                    <c:if test="${da.status == 'ASSIGNED'}">
                                                                        <div class="mt-2 pt-2 border-top border-warning d-flex justify-content-between align-items-center">
                                                                            <span class="small text-muted">Hủy giao đơn cho shipper này:</span>
                                                                            <button type="submit" form="revokeForm${o.id}" class="btn btn-sm btn-outline-danger rounded-pill px-3 fw-bold">
                                                                                <i class="fa-solid fa-user-xmark me-1"></i>Thu Hồi Phân Công
                                                                            </button>
                                                                        </div>
                                                                    </c:if>
                                                                </div>
                                                            </c:if>

                                                            <div class="mb-3">
                                                                <label class="form-label small fw-bold">Chọn Shipper nhận đơn: <span class="text-danger">*</span></label>
                                                                <select name="shipperId" class="form-select" required>
                                                                    <option value="">-- Chọn đơn vị hoặc shipper --</option>
                                                                    <c:forEach var="shp" items="${shippers}">
                                                                        <c:set var="isMismatch" value="${o.shippingProvider != null && shp.shippingProvider != null && o.shippingProvider.code != shp.shippingProvider.code}"/>
                                                                        <c:if test="${!isMismatch}">
                                                                            <c:set var="isRejected" value="${not empty da && da.hasShipperRejected(shp.id)}"/>
                                                                            <c:set var="isDisabled" value="${shp.busy || isRejected}"/>

                                                                            <option value="${shp.id}" ${isDisabled ? 'disabled' : ''} class="${isRejected ? 'text-danger fw-bold' : (shp.busy ? 'text-muted' : '')}">
                                                                                ${shp.fullName} (${shp.phone}) - ${shp.shippingProvider != null ? shp.shippingProvider.name : 'Chung'}
                                                                                <c:choose>
                                                                                    <c:when test="${isRejected}">
                                                                                        [❌ ĐÃ TỪ CHỐI ĐƠN NÀY]
                                                                                    </c:when>
                                                                                    <c:when test="${shp.busy}">
                                                                                        [⏳ ĐANG BẬN: Đơn #${shp.busyOrderCode}]
                                                                                    </c:when>
                                                                                    <c:otherwise>
                                                                                        [✅ Sẵn sàng nhận đơn]
                                                                                    </c:otherwise>
                                                                                </c:choose>
                                                                            </option>
                                                                        </c:if>
                                                                    </c:forEach>
                                                                </select>
                                                                <div class="form-text small text-muted mt-2">
                                                                    <i class="fa-solid fa-circle-info me-1"></i>Chỉ phân công cho nhân viên thuộc đơn vị vận chuyển khách đã chọn (<c:out value="${o.shippingProvider != null ? o.shippingProvider.name : 'Tiêu chuẩn'}"/>). Các shipper đã từ chối đơn này hoặc đang bận sẽ bị khóa tự động.
                                                                </div>
                                                            </div>
                                                            <div class="mb-3">
                                                                <label class="form-label small fw-bold">Ghi chú vận chuyển:</label>
                                                                <textarea name="note" class="form-control" rows="2">${o.orderStatus == 'RETURN_REQUESTED' ? 'Đến địa chỉ khách để nhận lại sách hoàn trả' : 'Đến lấy hàng tại chi nhánh'}</textarea>
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer border-0 bg-light py-3 px-4">
                                                            <button type="button" class="btn btn-light rounded-pill px-3" data-bs-dismiss="modal">Đóng</button>
                                                            <button type="submit" class="btn btn-primary rounded-pill px-4 fw-bold shadow-sm">
                                                                <i class="fa-solid fa-paper-plane me-1"></i>
                                                                <c:choose>
                                                                    <c:when test="${not empty da && not empty da.shipper && da.status == 'ASSIGNED'}">Xác Nhận Đổi Shipper</c:when>
                                                                    <c:when test="${not empty da && not empty da.shipper && da.status == 'CANCELLED'}">Xác Nhận Phân Lại</c:when>
                                                                    <c:otherwise>Xác Nhận Phân Công</c:otherwise>
                                                                </c:choose>
                                                            </button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty orders}">
                                <tr id="noOrdersRow">
                                    <td colspan="7" class="text-center text-muted py-5">
                                        <i class="fa-solid fa-box-open fs-1 mb-3 text-secondary d-block"></i>
                                        <h6 class="fw-bold text-secondary">Không có đơn hàng nào phù hợp</h6>
                                        <p class="small text-muted mb-0">Vui lòng chọn trạng thái khác hoặc xóa tìm kiếm</p>
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

<script>
    // Tìm kiếm tức thời trên bảng đơn hàng (Client-side instant filter)
    function filterOrdersTable() {
        const input = document.getElementById("orderSearchInput");
        if (!input) return;
        const filter = input.value.trim().toLowerCase();
        const rows = document.querySelectorAll("#ordersTable tbody tr.order-row");
        let visibleCount = 0;

        rows.forEach(row => {
            const code = (row.getAttribute("data-code") || "").toLowerCase();
            const name = (row.getAttribute("data-name") || "").toLowerCase();
            const phone = (row.getAttribute("data-phone") || "").toLowerCase();
            const fullText = row.innerText.toLowerCase();

            if (code.includes(filter) || name.includes(filter) || phone.includes(filter) || fullText.includes(filter)) {
                row.style.display = "";
                visibleCount++;
            } else {
                row.style.display = "none";
            }
        });

        // Xử lý khi không có kết quả tìm kiếm
        let emptySearchRow = document.getElementById("emptySearchRow");
        if (visibleCount === 0 && rows.length > 0) {
            if (!emptySearchRow) {
                const tbody = document.querySelector("#ordersTable tbody");
                emptySearchRow = document.createElement("tr");
                emptySearchRow.id = "emptySearchRow";
                emptySearchRow.innerHTML = '<td colspan="7" class="text-center text-muted py-4"><i class="fa-solid fa-magnifying-glass me-2"></i>Không tìm thấy đơn hàng phù hợp với từ khóa "' + filter + '"</td>';
                tbody.appendChild(emptySearchRow);
            } else {
                emptySearchRow.style.display = "";
                emptySearchRow.querySelector("td").innerHTML = '<i class="fa-solid fa-magnifying-glass me-2"></i>Không tìm thấy đơn hàng phù hợp với từ khóa "' + filter + '"';
            }
        } else if (emptySearchRow) {
            emptySearchRow.style.display = "none";
        }
    }

    function clearSearchInput() {
        const input = document.getElementById("orderSearchInput");
        if (!input) return;
        input.value = "";
        filterOrdersTable();
        input.focus();
    }
</script>

<jsp:include page="../../common/footer.jsp"/>
