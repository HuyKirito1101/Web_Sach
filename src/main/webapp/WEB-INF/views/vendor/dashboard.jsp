<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="title" value="Dashboard Vendor - Tổng Quan Kinh Doanh" scope="request"/>
<jsp:include page="../common/header.jsp"/>

<style>
    .vendor-dashboard {
        padding: 24px;
        background-color: #f8fafc;
        min-height: calc(100vh - 65px);
    }
    
    .card-stat-modern {
        border-radius: 14px;
        border: none;
        background: #ffffff;
        box-shadow: 0 2px 12px rgba(15, 23, 42, 0.05);
        transition: all 0.25s ease;
        overflow: hidden;
    }
    .card-stat-modern:hover {
        transform: translateY(-3px);
        box-shadow: 0 10px 20px rgba(15, 23, 42, 0.09);
    }
    
    .stat-icon-box {
        width: 38px;
        height: 38px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1rem;
        flex-shrink: 0;
    }
    
    .stat-label {
        font-size: 0.72rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        color: #64748b;
        margin-bottom: 4px;
    }
    
    .stat-number {
        font-size: 1.35rem;
        font-weight: 700;
        line-height: 1.2;
        letter-spacing: -0.2px;
    }
    
    .stat-subtext {
        font-size: 0.75rem;
        color: #94a3b8;
        margin-top: 6px;
    }
    
    .badge-pulse {
        display: inline-block;
        width: 8px;
        height: 8px;
        border-radius: 50%;
        background-color: #ef4444;
        margin-right: 4px;
        animation: pulse 1.5s infinite;
    }
    
    @keyframes pulse {
        0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(239, 68, 68, 0.7); }
        70% { transform: scale(1.1); box-shadow: 0 0 0 6px rgba(239, 68, 68, 0); }
        100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(239, 68, 68, 0); }
    }

    .table-modern thead th {
        background-color: #f8fafc;
        color: #475569;
        font-size: 0.78rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        font-weight: 700;
        padding-top: 12px;
        padding-bottom: 12px;
        border-bottom: 1px solid #e2e8f0;
    }
    .table-modern tbody td {
        padding-top: 13px;
        padding-bottom: 13px;
        vertical-align: middle;
        font-size: 0.88rem;
        border-bottom: 1px solid #f1f5f9;
    }
</style>

<div class="d-flex">
    <jsp:include page="../common/sidebar.jsp"/>
    
    <div class="flex-grow-1" style="min-width: 0;">
        <jsp:include page="../common/navbar.jsp"/>
        
        <main class="vendor-dashboard container-fluid">
            <!-- Header Banner Section (Bắt mắt, chuyên nghiệp) -->
            <div class="card border-0 shadow-sm rounded-4 mb-4 bg-white">
                <div class="card-body p-4">
                    <div class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center gap-3">
                        <div class="d-flex align-items-center gap-3">
                            <c:choose>
                                <c:when test="${shop != null && not empty shop.imageUrl}">
                                    <img src="<c:out value='${shop.imageUrl}'/>" class="rounded-circle shadow-sm border border-warning" style="width: 58px; height: 58px; object-fit: cover; flex-shrink: 0;" alt="Logo Shop">
                                </c:when>
                                <c:otherwise>
                                    <div class="rounded-circle bg-warning bg-opacity-10 text-warning d-flex align-items-center justify-content-center shadow-sm" style="width: 58px; height: 58px; flex-shrink: 0;">
                                        <i class="fa-solid fa-store fa-2x"></i>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            <div>
                                <div class="d-flex align-items-center gap-2 flex-wrap">
                                    <h3 class="fw-bold text-dark mb-0">
                                        <c:out value="${shop != null ? shop.name : 'Bạn chưa đăng ký cửa hàng'}"/>
                                    </h3>
                                    <c:choose>
                                        <c:when test="${shop != null && shop.status == 'ACTIVE'}">
                                            <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3 py-1">
                                                <i class="fa-solid fa-circle-check me-1"></i>Đang hoạt động
                                            </span>
                                        </c:when>
                                        <c:when test="${shop != null && shop.status == 'PENDING'}">
                                            <span class="badge bg-warning-subtle text-warning border border-warning-subtle rounded-pill px-3 py-1">
                                                <i class="fa-solid fa-clock me-1"></i>Chờ duyệt
                                            </span>
                                        </c:when>
                                        <c:when test="${shop != null}">
                                            <span class="badge bg-secondary-subtle text-secondary rounded-pill px-3 py-1">${shop.status}</span>
                                        </c:when>
                                    </c:choose>
                                </div>
                                <div class="text-muted small mt-1 d-flex flex-wrap align-items-center gap-3">
                                    <c:if test="${shop != null && not empty shop.address}">
                                        <span><i class="fa-solid fa-location-dot text-danger me-1"></i><c:out value="${shop.address}"/></span>
                                    </c:if>
                                    <c:if test="${shop != null && not empty shop.phone}">
                                        <span><i class="fa-solid fa-phone text-primary me-1"></i><c:out value="${shop.phone}"/></span>
                                    </c:if>
                                    <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill px-2 py-1">
                                        <i class="fa-solid fa-handshake me-1"></i>Chiết khấu app: 
                                        <fmt:formatNumber value="${shop != null && shop.appDiscountPercent != null ? shop.appDiscountPercent : 10}" pattern="#,##0"/>%
                                    </span>
                                </div>
                            </div>
                        </div>

                        <!-- Date Filter Form (Đã bỏ nút Thêm Sách theo yêu cầu) -->
                        <div class="d-flex flex-wrap align-items-center gap-2">
                            <form class="d-flex align-items-center gap-2 flex-wrap" method="get">
                                <div class="input-group input-group-sm" style="width: 145px;">
                                    <span class="input-group-text bg-light text-muted border-end-0"><i class="fa-regular fa-calendar"></i></span>
                                    <input class="form-control border-start-0 ps-1" type="date" name="from" value="${from}" title="Từ ngày">
                                </div>
                                <span class="text-muted small">&rarr;</span>
                                <div class="input-group input-group-sm" style="width: 145px;">
                                    <span class="input-group-text bg-light text-muted border-end-0"><i class="fa-regular fa-calendar"></i></span>
                                    <input class="form-control border-start-0 ps-1" type="date" name="to" value="${to}" title="Đến ngày">
                                </div>
                                <button class="btn btn-sm btn-primary rounded-pill px-3 fw-medium shadow-sm" type="submit">
                                    <i class="fa-solid fa-filter me-1"></i>Lọc
                                </button>
                                <c:if test="${not empty from || not empty to}">
                                    <a href="/vendor/dashboard" class="btn btn-sm btn-outline-secondary rounded-pill px-2" title="Xóa bộ lọc">
                                        <i class="fa-solid fa-rotate-left"></i>
                                    </a>
                                </c:if>
                            </form>
                        </div>
                    </div>
                </div>
            </div>

            <c:if test="${shop == null}">
                <div class="alert alert-warning border-0 shadow-sm rounded-3 mb-4 d-flex align-items-center gap-3">
                    <i class="fa-solid fa-triangle-exclamation fa-2x text-warning"></i>
                    <div>
                        <h6 class="fw-bold mb-1">Bạn chưa đăng ký thông tin cửa hàng</h6>
                        <p class="mb-0 small text-muted">Vui lòng vào mục <a href="/vendor/shop" class="fw-bold text-decoration-underline text-warning">Hồ Sơ Cửa Hàng</a> để thiết lập thông tin trước khi bắt đầu kinh doanh.</p>
                    </div>
                </div>
            </c:if>
            <c:if test="${shop != null && shop.status != 'ACTIVE'}">
                <div class="alert alert-info border-0 shadow-sm rounded-3 mb-4 d-flex align-items-center gap-3">
                    <i class="fa-solid fa-circle-info fa-2x text-info"></i>
                    <div>
                        <h6 class="fw-bold mb-1">Cửa hàng đang ở trạng thái: <strong>${shop.status}</strong></h6>
                        <p class="mb-0 small text-muted">Hệ thống đang xét duyệt hồ sơ cửa hàng của bạn. Chức năng kinh doanh sẽ hoạt động sau khi được phê duyệt.</p>
                    </div>
                </div>
            </c:if>

            <!-- 6 KPI Stat Cards (Đồng bộ kích thước & viền màu phân biệt) -->
            <div class="row g-3 mb-4">
                <!-- 1. Sản Phẩm -->
                <div class="col-sm-6 col-md-4 col-xl-2">
                    <div class="card card-stat-modern h-100 p-3 border-top border-4 border-primary">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="stat-label">SẢN PHẨM</span>
                            <div class="stat-icon-box bg-primary-subtle text-primary">
                                <i class="fa-solid fa-book-bookmark"></i>
                            </div>
                        </div>
                        <div class="d-flex align-items-baseline">
                            <span class="stat-number text-dark">${stats.totalProducts}</span>
                            <span class="text-muted small ms-1">đầu sách</span>
                        </div>
                        <div class="stat-subtext">Đang mở bán</div>
                    </div>
                </div>

                <!-- 2. Tồn Kho -->
                <div class="col-sm-6 col-md-4 col-xl-2">
                    <div class="card card-stat-modern h-100 p-3 border-top border-4 border-info">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="stat-label">TỒN KHO</span>
                            <div class="stat-icon-box bg-info-subtle text-info">
                                <i class="fa-solid fa-boxes-stacked"></i>
                            </div>
                        </div>
                        <div class="d-flex align-items-baseline">
                            <span class="stat-number text-dark">${stats.totalStock}</span>
                            <span class="text-muted small ms-1">cuốn</span>
                        </div>
                        <div class="stat-subtext">Sách trong kho</div>
                    </div>
                </div>

                <!-- 3. Đơn Mới -->
                <div class="col-sm-6 col-md-4 col-xl-2">
                    <div class="card card-stat-modern h-100 p-3 border-top border-4 border-warning">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="stat-label">ĐƠN MỚI</span>
                            <div class="stat-icon-box bg-warning-subtle text-warning">
                                <i class="fa-solid fa-bell"></i>
                            </div>
                        </div>
                        <div class="d-flex align-items-baseline">
                            <span class="stat-number text-dark">${stats.newOrders}</span>
                            <span class="text-muted small ms-1">đơn</span>
                        </div>
                        <div class="stat-subtext">
                            <c:choose>
                                <c:when test="${stats.newOrders > 0}">
                                    <span class="text-danger fw-semibold"><span class="badge-pulse"></span>Chờ xử lý</span>
                                </c:when>
                                <c:otherwise>Không có đơn tồn</c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- 4. Tổng Đơn -->
                <div class="col-sm-6 col-md-4 col-xl-2">
                    <div class="card card-stat-modern h-100 p-3 border-top border-4 border-secondary">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="stat-label">TỔNG ĐƠN</span>
                            <div class="stat-icon-box bg-secondary-subtle text-secondary">
                                <i class="fa-solid fa-receipt"></i>
                            </div>
                        </div>
                        <div class="d-flex align-items-baseline">
                            <span class="stat-number text-dark">${stats.totalOrders}</span>
                            <span class="text-muted small ms-1">đơn</span>
                        </div>
                        <div class="stat-subtext">Đơn toàn thời gian</div>
                    </div>
                </div>

                <!-- 5. Thu Nhập -->
                <div class="col-sm-6 col-md-4 col-xl-2">
                    <div class="card card-stat-modern h-100 p-3 border-top border-4 border-success">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="stat-label">THU NHẬP</span>
                            <div class="stat-icon-box bg-success-subtle text-success">
                                <i class="fa-solid fa-sack-dollar"></i>
                            </div>
                        </div>
                        <div class="d-flex align-items-baseline">
                            <span class="stat-number ${stats.netRevenue < 0 ? 'text-danger' : 'text-success'} text-truncate" title="<fmt:formatNumber value='${stats.netRevenue}' pattern='#,##0 ₫'/>">
                                <fmt:formatNumber value="${stats.netRevenue}" pattern="#,##0 ₫"/>
                            </span>
                        </div>
                        <div class="stat-subtext">Thu nhập thực nhận</div>
                    </div>
                </div>

                <!-- 6. Phí App -->
                <div class="col-sm-6 col-md-4 col-xl-2">
                    <div class="card card-stat-modern h-100 p-3 border-top border-4 border-danger">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="stat-label">PHÍ APP</span>
                            <div class="stat-icon-box bg-danger-subtle text-danger">
                                <i class="fa-solid fa-hand-holding-dollar"></i>
                            </div>
                        </div>
                        <div class="d-flex align-items-baseline">
                            <span class="stat-number text-danger text-truncate" title="<fmt:formatNumber value='${stats.commission}' pattern='#,##0 ₫'/>">
                                <fmt:formatNumber value="${stats.commission}" pattern="#,##0 ₫"/>
                            </span>
                        </div>
                        <div class="stat-subtext">Chiết khấu sàn (<fmt:formatNumber value="${shop != null && shop.appDiscountPercent != null ? shop.appDiscountPercent : 10}" pattern="#,##0"/>%)</div>
                    </div>
                </div>
            </div>

            <!-- Spotlight Card: Thu Nhập Của Cửa Hàng -->
            <div class="card border-0 shadow-sm rounded-4 mb-4" style="background: linear-gradient(135deg, #f0fdf4 0%, #ecfdf5 50%, #d1fae5 100%); border-left: 5px solid #10b981 !important;">
                <div class="card-body p-3 p-md-4">
                    <div class="row align-items-center g-3">
                        <div class="col-md-7 col-lg-8">
                            <div class="d-flex align-items-center mb-1">
                                <span class="badge bg-success text-white rounded-pill px-3 py-1 me-2"><i class="fa-solid fa-wallet me-1"></i>Thu nhập ròng thực nhận</span>
                                <h5 class="fw-bold mb-0 text-dark">Thu Nhập Của Cửa Hàng</h5>
                            </div>
                            <p class="text-muted small mb-0 mt-1">
                                Số tiền thực tế shop nhận được sau khi khấu trừ phí dịch vụ sàn (<fmt:formatNumber value="${shop != null && shop.appDiscountPercent != null ? shop.appDiscountPercent : 10}" pattern="#,##0"/>%), <strong class="text-danger">toàn bộ chi phí thu mua sách cũ</strong> và <strong class="text-danger">phí trả Shipper khi hoàn tất đổi trả</strong>.
                            </p>
                            <c:if test="${stats.totalAcquisitionExpense > 0 || stats.returnShippingCost > 0 || stats.refundedAmount > 0}">
                                <div class="d-flex flex-wrap gap-3 small mt-2 pt-2 border-top border-success-subtle text-muted">
                                    <c:if test="${stats.bookAcquisitionCost > 0}">
                                        <span><i class="fa-solid fa-book text-warning me-1"></i>Tiền trả khách mua sách: <strong class="text-danger">-<fmt:formatNumber value="${stats.bookAcquisitionCost}" pattern="#,##0 ₫"/></strong></span>
                                    </c:if>
                                    <c:if test="${stats.shippingAcquisitionCost > 0}">
                                        <span><i class="fa-solid fa-motorcycle text-primary me-1"></i>Tiền trả Shipper thu gom: <strong class="text-danger">-<fmt:formatNumber value="${stats.shippingAcquisitionCost}" pattern="#,##0 ₫"/></strong></span>
                                    </c:if>
                                    <c:if test="${stats.totalAcquisitionExpense > 0}">
                                        <span><i class="fa-solid fa-calculator text-dark me-1"></i>Tổng chi phí thu mua: <strong class="text-danger">-<fmt:formatNumber value="${stats.totalAcquisitionExpense}" pattern="#,##0 ₫"/></strong></span>
                                    </c:if>
                                    <c:if test="${stats.returnShippingCost > 0}">
                                        <span><i class="fa-solid fa-truck-ramp-box text-danger me-1"></i>Phí trả Shipper hoàn trả: <strong class="text-danger">-<fmt:formatNumber value="${stats.returnShippingCost}" pattern="#,##0 ₫"/></strong></span>
                                    </c:if>
                                    <c:if test="${stats.refundedAmount > 0}">
                                        <span><i class="fa-solid fa-rotate-left text-secondary me-1"></i>Đã hoàn tiền cho khách: <strong class="text-muted"><fmt:formatNumber value="${stats.refundedAmount}" pattern="#,##0 ₫"/></strong></span>
                                    </c:if>
                                </div>
                            </c:if>
                        </div>
                        <div class="col-md-5 col-lg-4 text-md-end">
                            <div class="text-muted small">Thực nhận sau khi trừ mọi chi phí</div>
                            <div class="display-6 fw-bold ${stats.netRevenue < 0 ? 'text-danger' : 'text-success'} mb-0" style="letter-spacing: -0.5px;">
                                <fmt:formatNumber value="${stats.netRevenue}" pattern="#,##0 ₫"/>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Biểu Đồ Doanh Thu Đường (Line Chart) Theo Tháng & Cả Năm -->
            <div class="card border-0 shadow-sm rounded-4 mb-4 bg-white">
                <div class="card-body p-4">
                    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-3 pb-3 border-bottom">
                        <div>
                            <div class="d-flex align-items-center gap-2">
                                <div class="stat-icon-box bg-primary bg-opacity-10 text-primary">
                                    <i class="fa-solid fa-chart-line"></i>
                                </div>
                                <div>
                                    <h5 class="fw-bold mb-0 text-dark">Biểu Đồ Doanh Thu Cửa Hàng</h5>
                                    <small class="text-muted" id="chartSubtitle">Thống kê theo từng ngày trong tháng</small>
                                </div>
                            </div>
                        </div>
                        
                        <div class="d-flex align-items-center gap-2 flex-wrap">
                            <div class="d-flex align-items-center gap-1 bg-light p-1 rounded-3 border">
                                <button type="button" class="btn btn-sm btn-white shadow-none px-3 py-1 rounded-2 fw-medium active" id="viewModeDailyBtn">
                                    Theo ngày
                                </button>
                                <button type="button" class="btn btn-sm btn-transparent shadow-none px-3 py-1 rounded-2 fw-medium" id="viewModeYearlyBtn">
                                    Cả năm ${revenueAnalytics.selectedYear}
                                </button>
                            </div>
                            
                            <select class="form-select form-select-sm border rounded-3" id="revenueMonthSelect" style="width: auto; min-width: 140px;">
                                <c:forEach var="m" begin="1" end="12">
                                    <option value="${m}" ${m == revenueAnalytics.selectedMonth ? 'selected' : ''}>
                                        Tháng ${m} / ${revenueAnalytics.selectedYear}
                                    </option>
                                </c:forEach>
                            </select>

                            <!-- Tổng năm mặc định 0 ₫ nếu chưa có dữ liệu -->
                            <div class="bg-success-subtle text-success border border-success-subtle px-3 py-1 rounded-3 small fw-bold">
                                Tổng năm: <fmt:formatNumber value="${revenueAnalytics.totalYearRevenue != null ? revenueAnalytics.totalYearRevenue : 0}" pattern="#,##0"/> ₫
                            </div>
                        </div>
                    </div>

                    <div style="position: relative; height: 320px; width: 100%;">
                        <canvas id="vendorRevenueLineChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- Top Sản Phẩm Đã Bán -->
            <div class="card border-0 shadow-sm rounded-4 bg-white overflow-hidden">
                <div class="card-header bg-white border-0 py-3 px-4 d-flex justify-content-between align-items-center">
                    <div class="d-flex align-items-center gap-2">
                        <div class="stat-icon-box bg-success bg-opacity-10 text-success">
                            <i class="fa-solid fa-trophy"></i>
                        </div>
                        <div>
                            <h5 class="fw-bold mb-0 text-dark">Top Sản Phẩm Đã Bán</h5>
                            <small class="text-muted">Các đầu sách bán chạy nhất của gian hàng</small>
                        </div>
                    </div>
                    <span class="badge bg-light text-muted border px-2 py-1">Top ${topProducts != null ? topProducts.size() : 0}</span>
                </div>
                
                <div class="table-responsive">
                    <table class="table table-modern table-hover align-middle mb-0">
                        <thead>
                            <tr>
                                <th class="ps-4" style="width: 60px;">#</th>
                                <th>Sản phẩm</th>
                                <th class="text-center" style="width: 160px;">Số lượng đã bán</th>
                                <th class="text-end pe-4" style="width: 200px;">Tổng doanh thu</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${topProducts}" varStatus="status">
                                <tr>
                                    <td class="ps-4">
                                        <c:choose>
                                            <c:when test="${status.index == 0}">
                                                <span class="badge bg-warning rounded-circle d-inline-flex align-items-center justify-content-center" style="width: 26px; height: 26px; font-size: 12px;">1</span>
                                            </c:when>
                                            <c:when test="${status.index == 1}">
                                                <span class="badge bg-secondary rounded-circle d-inline-flex align-items-center justify-content-center" style="width: 26px; height: 26px; font-size: 12px;">2</span>
                                            </c:when>
                                            <c:when test="${status.index == 2}">
                                                <span class="badge bg-danger rounded-circle d-inline-flex align-items-center justify-content-center" style="width: 26px; height: 26px; font-size: 12px;">3</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted fw-bold ps-2">${status.index + 1}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="fw-semibold text-dark"><c:out value="${p.title}"/></div>
                                    </td>
                                    <td class="text-center">
                                        <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill px-3 py-1 fw-bold">
                                            ${p.quantity} cuốn
                                        </span>
                                    </td>
                                    <td class="text-end pe-4 fw-bold text-success">
                                        <fmt:formatNumber value="${p.revenue}" pattern="#,##0 ₫"/>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty topProducts}">
                                <tr>
                                    <td colspan="4" class="text-center text-muted py-5">
                                        <i class="fa-solid fa-inbox fa-3x mb-2 text-secondary opacity-50"></i>
                                        <p class="mb-0">Chưa có dữ liệu đơn hàng đã giao trong khoảng thời gian này</p>
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

<jsp:include page="../common/footer.jsp"/>

<!-- Chart.js Script for Revenue Line Chart -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
(function() {
    // 1. Dữ liệu doanh thu cả năm (mảng 12 tháng)
    const yearlyData = [
        <c:forEach var="v" items="${revenueAnalytics.yearlyMonths}" varStatus="loop">
            ${v}<c:if test="${!loop.last}">,</c:if>
        </c:forEach>
    ];
    while (yearlyData.length < 12) {
        yearlyData.push(0);
    }

    // Nhãn 12 tháng đầy đủ cho chế độ Cả Năm
    const yearlyMonthsLabels = [
        'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
        'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];

    // 2. Dữ liệu doanh thu từng ngày trong từng tháng
    const monthlyDataMap = {
        <c:forEach var="entry" items="${revenueAnalytics.monthlyData}" varStatus="loop">
            ${entry.key}: [
                <c:forEach var="val" items="${entry.value}" varStatus="vLoop">
                    ${val}<c:if test="${!vLoop.last}">,</c:if>
                </c:forEach>
            ]<c:if test="${!loop.last}">,</c:if>
        </c:forEach>
    };

    const targetYear = ${revenueAnalytics.selectedYear != null && revenueAnalytics.selectedYear > 0 ? revenueAnalytics.selectedYear : 2026};
    const monthSelect = document.getElementById('revenueMonthSelect');
    
    // Đảm bảo tháng khởi tạo luôn khớp 100% với giá trị hiển thị trên dropdown
    let currentSelectedMonth = monthSelect ? parseInt(monthSelect.value, 10) : ${revenueAnalytics.selectedMonth != null ? revenueAnalytics.selectedMonth : 10};
    let currentViewMode = 'daily'; // 'daily' hoặc 'yearly'
    let revenueChartInstance = null;

    // Hàm lấy số ngày thực tế trong tháng theo năm (chuẩn xác kể cả năm nhuận)
    function getDaysInMonth(year, month) {
        return new Date(year, month, 0).getDate();
    }

    // Định dạng tiền tệ đầy đủ cho tooltip
    function formatFullVND(val) {
        return new Intl.NumberFormat('vi-VN').format(val) + ' ₫';
    }

    function initOrUpdateChart() {
        const canvas = document.getElementById('vendorRevenueLineChart');
        if (!canvas) return;
        const ctx = canvas.getContext('2d');

        let labels = [];
        let data = [];
        let chartLabel = '';
        let totalDays = 31;

        if (currentViewMode === 'daily') {
            totalDays = getDaysInMonth(targetYear, currentSelectedMonth);
            const dailyRevenues = monthlyDataMap[currentSelectedMonth] || [];

            for (let d = 1; d <= totalDays; d++) {
                labels.push('Ngày ' + d);
                data.push(dailyRevenues[d - 1] || 0);
            }

            chartLabel = 'Doanh thu Tháng ' + currentSelectedMonth + ' / ' + targetYear + ' (VNĐ)';
            document.getElementById('chartSubtitle').innerText = 'Thống kê chi tiết theo từng ngày trong Tháng ' + currentSelectedMonth + ' (tháng có ' + totalDays + ' ngày)';
            if (monthSelect) monthSelect.style.visibility = 'visible';
        } else {
            labels = yearlyMonthsLabels;
            data = yearlyData;
            chartLabel = 'Doanh thu cả năm ' + targetYear + ' (VNĐ)';
            document.getElementById('chartSubtitle').innerText = 'Tổng quan doanh thu đầy đủ 12 tháng của năm ' + targetYear;
            if (monthSelect) monthSelect.style.visibility = 'hidden';
        }

        // Tạo dải màu gradient mượt mà dưới đường đồ thị
        const gradient = ctx.createLinearGradient(0, 0, 0, 300);
        gradient.addColorStop(0, 'rgba(37, 99, 235, 0.28)');
        gradient.addColorStop(1, 'rgba(37, 99, 235, 0.0)');

        // Thang đo linh hoạt cho trục Y: dù doanh thu là 0, hàng nghìn, hàng triệu hay hàng trăm triệu đều hiển thị thoáng và rõ ràng
        const maxVal = Math.max(...data, 0);
        let dynamicYMax = 100000;
        if (maxVal > 0) {
            dynamicYMax = maxVal * 1.18;
        }

        if (revenueChartInstance) {
            revenueChartInstance.data.labels = labels;
            revenueChartInstance.data.datasets[0].label = chartLabel;
            revenueChartInstance.data.datasets[0].data = data;
            revenueChartInstance.options.scales.y.suggestedMax = dynamicYMax;
            revenueChartInstance.options.scales.x.ticks.callback = function(val, index) {
                if (currentViewMode === 'daily') {
                    const day = index + 1;
                    // Hiển thị ngày 1, 5, 10, 15, 20, 25, 30 và ngày cuối cùng của tháng
                    if (day === 1 || day % 5 === 0 || day === totalDays) {
                        return 'Ngày ' + day;
                    }
                    return '';
                }
                // Chế độ cả năm: hiển thị đủ cả 12 tháng
                return yearlyMonthsLabels[index];
            };
            revenueChartInstance.update();
            return;
        }

        revenueChartInstance = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: chartLabel,
                    data: data,
                    borderColor: '#2563eb',
                    backgroundColor: gradient,
                    borderWidth: 2.5,
                    fill: true,
                    tension: 0.32,
                    pointBackgroundColor: '#2563eb',
                    pointBorderColor: '#ffffff',
                    pointBorderWidth: 2,
                    pointRadius: currentViewMode === 'daily' ? 3 : 4,
                    pointHoverRadius: 6,
                    pointHoverBackgroundColor: '#1d4ed8',
                    pointHoverBorderColor: '#ffffff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                interaction: {
                    mode: 'index',
                    intersect: false
                },
                plugins: {
                    legend: {
                        display: true,
                        position: 'top',
                        labels: {
                            boxWidth: 14,
                            font: { size: 12, weight: '500' }
                        }
                    },
                    tooltip: {
                        backgroundColor: 'rgba(15, 23, 42, 0.92)',
                        padding: 10,
                        titleFont: { size: 13, weight: '600' },
                        bodyFont: { size: 12 },
                        cornerRadius: 8,
                        callbacks: {
                            title: function(context) {
                                return context[0].label;
                            },
                            label: function(context) {
                                return ' Doanh thu: ' + formatFullVND(context.raw);
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        grid: {
                            display: false
                        },
                        ticks: {
                            font: { size: 11 },
                            autoSkip: false,
                            maxRotation: 0,
                            callback: function(val, index) {
                                if (currentViewMode === 'daily') {
                                    const day = index + 1;
                                    // Hiển thị ngày 1, 5, 10, 15, 20, 25, 30 và ngày cuối tháng
                                    if (day === 1 || day % 5 === 0 || day === totalDays) {
                                        return 'Ngày ' + day;
                                    }
                                    return '';
                                }
                                // Chế độ cả năm: hiển thị đầy đủ 12 tháng
                                return yearlyMonthsLabels[index];
                            }
                        }
                    },
                    y: {
                        beginAtZero: true,
                        suggestedMax: dynamicYMax,
                        grid: {
                            color: 'rgba(226, 232, 240, 0.6)'
                        },
                        ticks: {
                            font: { size: 11 },
                            precision: 0,
                            // Định dạng thông minh cho trục Y: không bị rối mắt với mọi mức doanh thu
                            callback: function(val) {
                                if (val === 0) return '0 ₫';
                                if (val >= 1000000000) {
                                    return (val / 1000000000).toLocaleString('vi-VN', { maximumFractionDigits: 1 }) + ' tỷ ₫';
                                }
                                if (val >= 1000000) {
                                    return (val / 1000000).toLocaleString('vi-VN', { maximumFractionDigits: 1 }) + ' tr ₫';
                                }
                                if (val >= 1000) {
                                    return (val / 1000).toLocaleString('vi-VN', { maximumFractionDigits: 0 }) + ' k ₫';
                                }
                                return val.toLocaleString('vi-VN') + ' ₫';
                            }
                        }
                    }
                }
            }
        });
    }

    document.addEventListener("DOMContentLoaded", function() {
        initOrUpdateChart();

        const dailyBtn = document.getElementById('viewModeDailyBtn');
        const yearlyBtn = document.getElementById('viewModeYearlyBtn');

        if (monthSelect) {
            monthSelect.addEventListener('change', function() {
                currentSelectedMonth = parseInt(this.value, 10);
                currentViewMode = 'daily';
                if (dailyBtn && yearlyBtn) {
                    dailyBtn.classList.add('active');
                    yearlyBtn.classList.remove('active');
                }
                initOrUpdateChart();
            });
        }

        if (dailyBtn) {
            dailyBtn.addEventListener('click', function() {
                currentViewMode = 'daily';
                dailyBtn.classList.add('active');
                if (yearlyBtn) yearlyBtn.classList.remove('active');
                initOrUpdateChart();
            });
        }

        if (yearlyBtn) {
            yearlyBtn.addEventListener('click', function() {
                currentViewMode = 'yearly';
                yearlyBtn.classList.add('active');
                if (dailyBtn) dailyBtn.classList.remove('active');
                initOrUpdateChart();
            });
        }
    });
})();
</script>
