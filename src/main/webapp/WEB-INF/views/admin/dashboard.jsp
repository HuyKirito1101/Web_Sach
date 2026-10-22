<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="title" value="Dashboard Admin - Quản Lý Chuỗi Sách Cũ" scope="request" />
<jsp:include page="../common/header.jsp" />

<div class="d-flex">
    <jsp:include page="../common/sidebar.jsp" />

    <div class="flex-grow-1">
        <jsp:include page="../common/navbar.jsp" />

        <div class="main-content container-fluid">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold mb-1"><i class="fa-solid fa-chart-pie text-primary me-2"></i>Tổng Quan Hệ Thống Chuỗi Sách Cũ</h3>
                    <p class="text-muted small">Báo cáo doanh thu, tồn kho và các chỉ số hoạt động toàn hệ thống</p>
                </div>
            </div>

            <!-- Stat Cards -->
            <div class="row g-3 mb-4">
                <div class="col-md-3">
                    <div class="card card-stat bg-white p-3 border-start border-primary border-4">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <span class="text-muted small fw-medium">TỔNG DOANH THU</span>
                                <h4 class="fw-bold text-dark mt-1"><fmt:formatNumber value="${stats.totalRevenue}" pattern="#,##0 ₫" /></h4>
                            </div>
                            <div class="bg-primary-subtle p-3 rounded-circle">
                                <i class="fa-solid fa-sack-dollar fa-2x text-primary"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card card-stat bg-white p-3 border-start border-success border-4">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <span class="text-muted small fw-medium">CHIẾT KHẤU APP THU VỀ</span>
                                <h4 class="fw-bold text-dark mt-1"><fmt:formatNumber value="${stats.totalAppCommission}" pattern="#,##0 ₫" /></h4>
                            </div>
                            <div class="bg-success-subtle p-3 rounded-circle">
                                <i class="fa-solid fa-coins fa-2x text-success"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card card-stat bg-white p-3 border-start border-warning border-4">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <span class="text-muted small fw-medium">SỐ CHI NHÁNH CỬA HÀNG</span>
                                <h4 class="fw-bold text-dark mt-1">${stats.totalBranches}</h4>
                            </div>
                            <div class="bg-warning-subtle p-3 rounded-circle">
                                <i class="fa-solid fa-shop fa-2x text-warning"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card card-stat bg-white p-3 border-start border-info border-4">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <span class="text-muted small fw-medium">TỔNG ĐẦU SÁCH & BẢN SÁCH</span>
                                <h4 class="fw-bold text-dark mt-1">${stats.totalBooks} / ${stats.totalBookCopies}</h4>
                            </div>
                            <div class="bg-info-subtle p-3 rounded-circle">
                                <i class="fa-solid fa-book-open fa-2x text-info"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Table Recent Orders -->
            <div class="card border-0 shadow-sm rounded-3">
                <div class="card-header bg-white py-3 border-0">
                    <h5 class="fw-bold mb-0"><i class="fa-solid fa-receipt me-2 text-primary"></i>Đơn Hàng Gần Đây Toàn Chuỗi</h5>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table align-middle table-hover mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Mã Đơn</th>
                                    <th>Khách Hàng</th>
                                    <th>Chi Nhánh Cửa Hàng</th>
                                    <th>Tổng Tiền</th>
                                    <th>Chiết Khấu App</th>
                                    <th>Trạng Thái</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="o" items="${recentOrders}">
                                    <tr>
                                        <td class="fw-bold text-primary">${o.orderCode}</td>
                                        <td><c:out value="${o.receiverName}"/> (<c:out value="${o.receiverPhone}"/>)</td>
                                        <td><span class="badge bg-secondary"><c:out value="${o.branch != null ? o.branch.name : 'Cửa Hàng'}"/></span></td>
                                        <td class="fw-bold"><fmt:formatNumber value="${o.finalAmount}" pattern="#,##0 ₫" /></td>
                                        <td class="text-success"><fmt:formatNumber value="${o.appCommissionAmount}" pattern="#,##0 ₫" /></td>
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
