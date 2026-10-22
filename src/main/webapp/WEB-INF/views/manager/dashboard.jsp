<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="title" value="Dashboard Manager - Chi Nhánh Cửa Hàng" scope="request" />
<jsp:include page="../common/header.jsp" />

<div class="d-flex">
    <jsp:include page="../common/sidebar.jsp" />

    <div class="flex-grow-1">
        <jsp:include page="../common/navbar.jsp" />

        <div class="main-content container-fluid">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold mb-1"><i class="fa-solid fa-gauge-high text-primary me-2"></i>Báo Cáo Chi Nhánh: <c:out value="${stats.branchName}"/></h3>
                    <p class="text-muted small">Thống kê hoạt động kinh doanh sách cũ tại cửa hàng</p>
                </div>
            </div>

            <!-- Stat Cards -->
            <div class="row g-3 mb-4">
                <div class="col-md-3">
                    <div class="card card-stat bg-white p-3 border-start border-primary border-4">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <span class="text-muted small fw-medium">DOANH THU CHI NHÁNH</span>
                                <h4 class="fw-bold text-dark mt-1"><fmt:formatNumber value="${stats.totalBranchRevenue}" pattern="#,##0 ₫" /></h4>
                            </div>
                            <div class="bg-primary-subtle p-3 rounded-circle">
                                <i class="fa-solid fa-money-bill-wave fa-2x text-primary"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card card-stat bg-white p-3 border-start border-success border-4">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <span class="text-muted small fw-medium">TỒN KHO SÁCH CŨ</span>
                                <h4 class="fw-bold text-dark mt-1">${stats.totalCopiesInStock} cuốn</h4>
                            </div>
                            <div class="bg-success-subtle p-3 rounded-circle">
                                <i class="fa-solid fa-boxes-stacked fa-2x text-success"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card card-stat bg-white p-3 border-start border-warning border-4">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <span class="text-muted small fw-medium">ĐƠN HÀNG MỚI CHỜ DUYỆT</span>
                                <h4 class="fw-bold text-dark mt-1">${stats.pendingOrders} đơn</h4>
                            </div>
                            <div class="bg-warning-subtle p-3 rounded-circle">
                                <i class="fa-solid fa-clock-rotate-left fa-2x text-warning"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card card-stat bg-white p-3 border-start border-info border-4">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <span class="text-muted small fw-medium">TỔNG ĐƠN ĐÃ XỬ LÝ</span>
                                <h4 class="fw-bold text-dark mt-1">${stats.totalOrders} đơn</h4>
                            </div>
                            <div class="bg-info-subtle p-3 rounded-circle">
                                <i class="fa-solid fa-clipboard-check fa-2x text-info"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Table Recent Branch Orders -->
            <div class="card border-0 shadow-sm rounded-3">
                <div class="card-header bg-white py-3 border-0">
                    <h5 class="fw-bold mb-0"><i class="fa-solid fa-receipt me-2 text-primary"></i>Đơn Hàng Gần Đây Của Cửa Hàng</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table align-middle table-hover mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Mã Đơn</th>
                                    <th>Người Nhận</th>
                                    <th>Tổng Tiền</th>
                                    <th>Trạng Thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="o" items="${recentOrders}">
                                    <tr>
                                        <td class="fw-bold text-primary">${o.orderCode}</td>
                                        <td><c:out value="${o.receiverName}"/> (<c:out value="${o.receiverPhone}"/>)</td>
                                        <td class="fw-bold"><fmt:formatNumber value="${o.finalAmount}" pattern="#,##0 ₫" /></td>
                                        <td><span class="badge bg-info">${o.orderStatus}</span></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />
