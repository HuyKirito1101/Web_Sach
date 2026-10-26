<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="title" value="Dashboard Shipper" scope="request"/>
<jsp:include page="../common/header.jsp"/>

<div class="d-flex">
    <jsp:include page="../common/sidebar.jsp"/>
    <div class="flex-grow-1">
        <jsp:include page="../common/navbar.jsp"/>
        <main class="main-content container-fluid py-4 px-lg-4">

            <!-- Header Section -->
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center mb-4 gap-3">
                <div>
                    <h3 class="fw-bold mb-1 text-dark">
                        <i class="fa-solid fa-truck-fast text-primary me-2"></i>Bảng Điều Khiển Shipper
                    </h3>
                    <p class="text-muted mb-0 small">
                        Tổng hợp tiến độ giao hàng, thu nhập và các đơn hàng hoàn thành gần nhất
                    </p>
                </div>
                <form class="d-flex align-items-center flex-nowrap gap-2 bg-white p-2 rounded-4 shadow-sm border" method="get">
                    <div class="input-group input-group-sm" style="width: 145px;">
                        <span class="input-group-text bg-light border-0 px-2"><i class="fa-regular fa-calendar"></i></span>
                        <input class="form-control form-control-sm border-0 px-1" type="date" name="from" value="${from}" title="Từ ngày">
                    </div>
                    <span class="text-muted small text-nowrap">đến</span>
                    <div class="input-group input-group-sm" style="width: 145px;">
                        <span class="input-group-text bg-light border-0 px-2"><i class="fa-regular fa-calendar"></i></span>
                        <input class="form-control form-control-sm border-0 px-1" type="date" name="to" value="${to}" title="Đến ngày">
                    </div>
                    <button type="submit" class="btn btn-primary btn-sm rounded-pill px-3 fw-bold text-nowrap d-inline-flex align-items-center shadow-sm" style="white-space: nowrap;">
                        <i class="fa-solid fa-filter me-1"></i>Lọc
                    </button>
                    <c:if test="${not empty from || not empty to}">
                        <a href="/shipper/dashboard" class="btn btn-light btn-sm rounded-pill text-muted text-nowrap">Đặt lại</a>
                    </c:if>
                </form>
            </div>

            <!-- Metric Cards -->
            <div class="row g-3 mb-4">
                <div class="col-6 col-md-4 col-xl-2">
                    <div class="card border-0 shadow-sm rounded-4 p-3 bg-white h-100 position-relative overflow-hidden">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <span class="text-muted small fw-bold">TỔNG ĐƠN</span>
                            <div class="rounded-3 p-2 bg-primary bg-opacity-10 text-primary">
                                <i class="fa-solid fa-box-archive"></i>
                            </div>
                        </div>
                        <h2 class="fw-bold mb-0 text-dark">${stats.total}</h2>
                        <small class="text-muted mt-1">Được phân công</small>
                    </div>
                </div>

                <div class="col-6 col-md-4 col-xl-2">
                    <div class="card border-0 shadow-sm rounded-4 p-3 bg-white h-100 position-relative overflow-hidden">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <span class="text-muted small fw-bold">CHỜ NHẬN</span>
                            <div class="rounded-3 p-2 bg-warning bg-opacity-10 text-warning">
                                <i class="fa-solid fa-clock"></i>
                            </div>
                        </div>
                        <h2 class="fw-bold mb-0 text-warning">${stats.assigned}</h2>
                        <small class="text-muted mt-1">Cần xác nhận</small>
                    </div>
                </div>

                <div class="col-6 col-md-4 col-xl-2">
                    <div class="card border-0 shadow-sm rounded-4 p-3 bg-white h-100 position-relative overflow-hidden">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <span class="text-muted small fw-bold">ĐANG GIAO</span>
                            <div class="rounded-3 p-2 bg-info bg-opacity-10 text-info">
                                <i class="fa-solid fa-truck-fast"></i>
                            </div>
                        </div>
                        <h2 class="fw-bold mb-0 text-info">${stats.inProgress}</h2>
                        <small class="text-muted mt-1">Đang vận chuyển</small>
                    </div>
                </div>

                <div class="col-6 col-md-4 col-xl-2">
                    <div class="card border-0 shadow-sm rounded-4 p-3 bg-white h-100 position-relative overflow-hidden">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <span class="text-muted small fw-bold">THÀNH CÔNG</span>
                            <div class="rounded-3 p-2 bg-success bg-opacity-10 text-success">
                                <i class="fa-solid fa-circle-check"></i>
                            </div>
                        </div>
                        <h2 class="fw-bold mb-0 text-success">${stats.delivered}</h2>
                        <small class="text-muted mt-1">Đã hoàn thành</small>
                    </div>
                </div>

                <div class="col-6 col-md-4 col-xl-2">
                    <div class="card border-0 shadow-sm rounded-4 p-3 bg-white h-100 position-relative overflow-hidden">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <span class="text-muted small fw-bold">THẤT BẠI</span>
                            <div class="rounded-3 p-2 bg-danger bg-opacity-10 text-danger">
                                <i class="fa-solid fa-circle-xmark"></i>
                            </div>
                        </div>
                        <h2 class="fw-bold mb-0 text-danger">${stats.failed}</h2>
                        <small class="text-muted mt-1">Giao không thành</small>
                    </div>
                </div>

                <div class="col-6 col-md-4 col-xl-2">
                    <div class="card border-0 shadow-sm rounded-4 p-3 bg-white h-100 position-relative overflow-hidden">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <span class="text-muted small fw-bold">THU NHẬP</span>
                            <div class="rounded-3 p-2 bg-purple bg-opacity-10 text-purple" style="color: #8b5cf6; background: rgba(139,92,246,0.1);">
                                <i class="fa-solid fa-sack-dollar"></i>
                            </div>
                        </div>
                        <h5 class="fw-bold mb-0" style="color: #8b5cf6;">
                            <fmt:formatNumber value="${stats.shippingRevenue}" pattern="#,##0 ₫"/>
                        </h5>
                        <small class="text-muted mt-1">Thu nhập giao hàng</small>
                    </div>
                </div>
            </div>

            <!-- Biểu Đồ Thu Nhập Giao Hàng Của Shipper (Line Chart giống bên vendor) -->
            <div class="card border-0 shadow-sm rounded-4 mb-4 bg-white">
                <div class="card-body p-4">
                    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3 mb-3 pb-3 border-bottom">
                        <div>
                            <div class="d-flex align-items-center gap-2">
                                <div class="rounded-3 p-2 bg-primary bg-opacity-10 text-primary">
                                    <i class="fa-solid fa-chart-line fa-lg"></i>
                                </div>
                                <div>
                                    <h5 class="fw-bold mb-0 text-dark">Biểu Đồ Thu Nhập Giao Hàng</h5>
                                    <small class="text-muted" id="chartSubtitle">Thống kê chi tiết thu nhập của Shipper</small>
                                </div>
                            </div>
                        </div>
                        
                        <div class="d-flex align-items-center gap-2 flex-wrap">
                            <div class="d-flex align-items-center gap-1 bg-light p-1 rounded-3 border">
                                <button type="button" class="btn btn-sm btn-white shadow-none px-3 py-1 rounded-2 fw-medium active" id="viewModeDailyBtn">
                                    Theo ngày
                                </button>
                                <button type="button" class="btn btn-sm btn-transparent shadow-none px-3 py-1 rounded-2 fw-medium" id="viewModeYearlyBtn">
                                    Cả năm ${incomeAnalytics.selectedYear}
                                </button>
                            </div>
                            
                            <select class="form-select form-select-sm border rounded-3" id="incomeMonthSelect" style="width: auto; min-width: 140px;">
                                <c:forEach var="m" begin="1" end="12">
                                    <option value="${m}" ${m == incomeAnalytics.selectedMonth ? 'selected' : ''}>
                                        Tháng ${m} / ${incomeAnalytics.selectedYear}
                                    </option>
                                </c:forEach>
                            </select>

                            <div class="bg-success-subtle text-success border border-success-subtle px-3 py-1 rounded-3 small fw-bold">
                                Tổng năm: <fmt:formatNumber value="${incomeAnalytics.totalYearIncome != null ? incomeAnalytics.totalYearIncome : 0}" pattern="#,##0"/> ₫
                            </div>
                        </div>
                    </div>

                    <div style="position: relative; height: 320px; width: 100%;">
                        <canvas id="shipperIncomeLineChart"></canvas>
                    </div>
                </div>
            </div>

            <!-- 5 Đơn Hoàn Thành Gần Đây Nhất Table (Theo đúng yêu cầu người dùng) -->
            <div class="card border-0 shadow-sm rounded-4 overflow-hidden bg-white">
                <div class="card-header bg-white py-3 px-4 border-0 d-flex justify-content-between align-items-center">
                    <div>
                        <h5 class="fw-bold mb-0 text-dark">
                            <i class="fa-solid fa-circle-check me-2 text-success"></i>5 Đơn Hoàn Thành Gần Đây Nhất
                        </h5>
                        <span class="text-muted small">Các đơn hàng bạn đã giao nhận thành công gần nhất</span>
                    </div>
                    <a href="/shipper/orders" class="btn btn-outline-primary btn-sm rounded-pill px-3 fw-bold">
                        Xem tất cả đơn được phân công <i class="fa-solid fa-arrow-right ms-1"></i>
                    </a>
                </div>

                <div class="table-responsive">
                    <table class="table align-middle table-hover mb-0">
                        <thead class="table-light text-secondary small text-uppercase">
                            <tr>
                                <th class="ps-4">Mã Đơn / Phân Loại</th>
                                <th>Khách Hàng / Người Nhận</th>
                                <th>Chi Nhánh / Cửa Hàng</th>
                                <th>Địa Chỉ Lấy &amp; Giao</th>
                                <th>Trạng Thái Giao</th>
                                <th class="text-center pe-4">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="a" items="${recentCompletedAssignments}">
                                <c:set var="isSellReq" value="${a.forSellRequest}"/>
                                <c:set var="isReturn" value="${not isSellReq && (a.order.orderStatus == 'RETURN_REQUESTED' || a.order.orderStatus == 'RETURNED')}"/>
                                <tr>
                                    <td class="ps-4">
                                        <a href="/shipper/orders/${a.id}" class="fw-bold text-decoration-none text-primary">
                                            ${a.referenceCode}
                                        </a>
                                        <div class="mt-1">
                                            <c:choose>
                                                <c:when test="${isSellReq}">
                                                    <span class="badge text-white rounded-pill px-2 py-1" style="font-size: 11px; background-color: #6f42c1;">
                                                        <i class="fa-solid fa-hand-holding-dollar me-1"></i>Thu gom sách cũ
                                                    </span>
                                                </c:when>
                                                <c:when test="${isReturn}">
                                                    <span class="badge bg-warning text-dark rounded-pill" style="font-size: 11px;">
                                                        <i class="fa-solid fa-rotate-left me-1"></i>Thu hồi sách hoàn
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-light text-dark border rounded-pill" style="font-size: 11px;">
                                                        <i class="fa-solid fa-box me-1"></i>Giao sách mới
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="fw-bold text-dark"><c:out value="${a.customerName}"/></div>
                                        <div class="small text-muted"><i class="fa-solid fa-phone me-1"></i><c:out value="${a.customerPhone}"/></div>
                                    </td>
                                    <td>
                                        <div class="fw-semibold text-dark"><c:out value="${a.branchName}"/></div>
                                        <div class="small text-muted text-truncate" style="max-width: 200px;">
                                            <c:out value="${a.branchAddress}"/>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${isSellReq}">
                                                <div class="small text-primary fw-semibold">
                                                    <i class="fa-solid fa-location-dot me-1"></i>Lấy tại: <c:out value="${a.sellRequest.note}"/>
                                                </div>
                                                <div class="small text-muted">
                                                    <i class="fa-solid fa-warehouse me-1"></i>Giao về: <c:out value="${a.branchName}"/>
                                                </div>
                                            </c:when>
                                            <c:when test="${isReturn}">
                                                <div class="small text-danger fw-semibold">
                                                    <i class="fa-solid fa-location-dot me-1"></i>Lấy tại: <c:out value="${not empty a.order.returnAddress ? a.order.returnAddress : a.order.shippingAddress}"/>
                                                </div>
                                                <div class="small text-muted">
                                                    <i class="fa-solid fa-shop me-1"></i>Trả về: <c:out value="${a.branchName}"/>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="small text-muted">
                                                    <i class="fa-solid fa-shop me-1"></i>Lấy: <c:out value="${a.order.branch.name}"/>
                                                </div>
                                                <div class="small text-dark">
                                                    <i class="fa-solid fa-location-dot text-danger me-1"></i>Giao đến: <c:out value="${a.order.shippingAddress}"/>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="badge bg-success px-3 py-2 rounded-pill">
                                            <i class="fa-solid fa-circle-check me-1"></i>Giao thành công
                                        </span>
                                    </td>
                                    <td class="text-center pe-4">
                                        <a href="/shipper/orders/${a.id}" class="btn btn-sm btn-light border text-success rounded-pill px-3 py-1 fw-semibold" style="font-size: 12px;">
                                            <i class="fa-solid fa-check me-1"></i>Chi tiết
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty recentCompletedAssignments}">
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="fa-solid fa-circle-check fs-2 mb-2 text-secondary d-block"></i>
                                        Chưa có đơn hàng nào hoàn thành trong khoảng thời gian này.
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

<!-- Chart.js Script for Shipper Income Line Chart -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
(function() {
    // 1. Dữ liệu thu nhập cả năm (mảng 12 tháng)
    const yearlyData = [
        <c:forEach var="v" items="${incomeAnalytics.yearlyMonths}" varStatus="loop">
            ${v}<c:if test="${!loop.last}">,</c:if>
        </c:forEach>
    ];
    while (yearlyData.length < 12) {
        yearlyData.push(0);
    }

    const yearlyMonthsLabels = [
        'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
        'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];

    // 2. Dữ liệu thu nhập từng ngày trong từng tháng
    const monthlyDataMap = {
        <c:forEach var="entry" items="${incomeAnalytics.monthlyData}" varStatus="loop">
            ${entry.key}: [
                <c:forEach var="val" items="${entry.value}" varStatus="vLoop">
                    ${val}<c:if test="${!vLoop.last}">,</c:if>
                </c:forEach>
            ]<c:if test="${!loop.last}">,</c:if>
        </c:forEach>
    };

    const targetYear = ${incomeAnalytics.selectedYear != null && incomeAnalytics.selectedYear > 0 ? incomeAnalytics.selectedYear : 2026};
    const monthSelect = document.getElementById('incomeMonthSelect');
    
    // Khởi tạo tháng từ dropdown
    let currentSelectedMonth = monthSelect ? parseInt(monthSelect.value, 10) : ${incomeAnalytics.selectedMonth != null ? incomeAnalytics.selectedMonth : 10};
    let currentViewMode = 'daily'; // 'daily' hoặc 'yearly'
    let incomeChartInstance = null;

    function getDaysInMonth(year, month) {
        return new Date(year, month, 0).getDate();
    }

    function formatFullVND(val) {
        return new Intl.NumberFormat('vi-VN').format(val) + ' ₫';
    }

    function initOrUpdateChart() {
        const canvas = document.getElementById('shipperIncomeLineChart');
        if (!canvas) return;
        const ctx = canvas.getContext('2d');

        let labels = [];
        let data = [];
        let chartLabel = '';
        let totalDays = 31;

        if (currentViewMode === 'daily') {
            totalDays = getDaysInMonth(targetYear, currentSelectedMonth);
            const dailyIncomes = monthlyDataMap[currentSelectedMonth] || [];

            for (let d = 1; d <= totalDays; d++) {
                labels.push('Ngày ' + d);
                data.push(dailyIncomes[d - 1] || 0);
            }

            chartLabel = 'Thu nhập Tháng ' + currentSelectedMonth + ' / ' + targetYear + ' (VNĐ)';
            const subtitleEl = document.getElementById('chartSubtitle');
            if (subtitleEl) {
                subtitleEl.innerText = 'Thống kê chi tiết theo từng ngày trong Tháng ' + currentSelectedMonth + ' (tháng có ' + totalDays + ' ngày)';
            }
            if (monthSelect) monthSelect.style.visibility = 'visible';
        } else {
            labels = yearlyMonthsLabels;
            data = yearlyData;
            chartLabel = 'Thu nhập cả năm ' + targetYear + ' (VNĐ)';
            const subtitleEl = document.getElementById('chartSubtitle');
            if (subtitleEl) {
                subtitleEl.innerText = 'Tổng quan thu nhập đầy đủ 12 tháng của năm ' + targetYear;
            }
            if (monthSelect) monthSelect.style.visibility = 'hidden';
        }

        // Tạo dải màu gradient mượt mà dưới đường đồ thị
        const gradient = ctx.createLinearGradient(0, 0, 0, 300);
        gradient.addColorStop(0, 'rgba(37, 99, 235, 0.28)');
        gradient.addColorStop(1, 'rgba(37, 99, 235, 0.0)');

        const maxVal = Math.max(...data, 0);
        let dynamicYMax = 100000;
        if (maxVal > 0) {
            dynamicYMax = maxVal * 1.18;
        }

        if (incomeChartInstance) {
            incomeChartInstance.data.labels = labels;
            incomeChartInstance.data.datasets[0].label = chartLabel;
            incomeChartInstance.data.datasets[0].data = data;
            incomeChartInstance.options.scales.y.suggestedMax = dynamicYMax;
            incomeChartInstance.options.scales.x.ticks.callback = function(val, index) {
                if (currentViewMode === 'daily') {
                    const day = index + 1;
                    if (day === 1 || day % 5 === 0 || day === totalDays) {
                        return 'Ngày ' + day;
                    }
                    return '';
                }
                return yearlyMonthsLabels[index];
            };
            incomeChartInstance.update();
            return;
        }

        incomeChartInstance = new Chart(ctx, {
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
                                return ' Thu nhập: ' + formatFullVND(context.raw);
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
                                    if (day === 1 || day % 5 === 0 || day === totalDays) {
                                        return 'Ngày ' + day;
                                    }
                                    return '';
                                }
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
