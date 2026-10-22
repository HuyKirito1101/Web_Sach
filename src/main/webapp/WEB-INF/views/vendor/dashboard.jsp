<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="title" value="Dashboard Vendor" scope="request"/>
<jsp:include page="../common/header.jsp"/>
<div class="d-flex"><jsp:include page="../common/sidebar.jsp"/><div class="flex-grow-1"><jsp:include page="../common/navbar.jsp"/>
<main class="main-content container-fluid">
    <div class="d-flex justify-content-between align-items-start mb-4">
        <div><h3 class="fw-bold mb-1">Dashboard Vendor</h3><p class="text-muted mb-0"><c:out value="${shop != null ? shop.name : 'Bạn chưa đăng ký cửa hàng'}"/></p></div>
        <form class="d-flex gap-2" method="get"><input class="form-control" type="date" name="from" value="${from}"><input class="form-control" type="date" name="to" value="${to}"><button class="btn btn-primary">Lọc</button></form>
    </div>
    <c:if test="${shop == null}"><div class="alert alert-warning">Hãy <a href="/vendor/shop">đăng ký cửa hàng</a> để bắt đầu.</div></c:if>
    <c:if test="${shop != null && shop.status != 'ACTIVE'}"><div class="alert alert-info">Cửa hàng đang ở trạng thái <strong>${shop.status}</strong>. Chức năng kinh doanh mở sau khi được duyệt.</div></c:if>
    <div class="row g-3 mb-4">
        <div class="col-md-4 col-xl-2"><div class="card card-stat p-3"><span class="text-muted small">SẢN PHẨM</span><h3>${stats.totalProducts}</h3></div></div>
        <div class="col-md-4 col-xl-2"><div class="card card-stat p-3"><span class="text-muted small">TỒN KHO</span><h3>${stats.totalStock}</h3></div></div>
        <div class="col-md-4 col-xl-2"><div class="card card-stat p-3"><span class="text-muted small">ĐƠN MỚI</span><h3>${stats.newOrders}</h3></div></div>
        <div class="col-md-4 col-xl-2"><div class="card card-stat p-3"><span class="text-muted small">TỔNG ĐƠN</span><h3>${stats.totalOrders}</h3></div></div>
        <div class="col-md-4 col-xl-2"><div class="card card-stat p-3"><span class="text-muted small">DOANH THU</span><h5><fmt:formatNumber value="${stats.deliveredRevenue}" pattern="#,#00 ₫"/></h5></div></div>
        <div class="col-md-4 col-xl-2"><div class="card card-stat p-3"><span class="text-muted small">PHÍ APP</span><h5><fmt:formatNumber value="${stats.commission}" pattern="#,#00 ₫"/></h5></div></div>
    </div>
    <div class="card border-0 shadow-sm"><div class="card-header bg-white"><h5 class="mb-0">Top sản phẩm đã giao</h5></div><div class="table-responsive"><table class="table mb-0"><thead><tr><th>Sản phẩm</th><th>Số lượng</th><th>Doanh thu</th></tr></thead><tbody>
        <c:forEach var="p" items="${topProducts}"><tr><td><c:out value="${p.title}"/></td><td>${p.quantity}</td><td><fmt:formatNumber value="${p.revenue}" pattern="#,#00 ₫"/></td></tr></c:forEach>
        <c:if test="${empty topProducts}"><tr><td colspan="3" class="text-center text-muted py-4">Chưa có dữ liệu đơn đã giao</td></tr></c:if>
    </tbody></table></div></div>
</main></div></div><jsp:include page="../common/footer.jsp"/>
