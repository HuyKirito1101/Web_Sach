<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="title" value="Khuyến Mãi - Admin" scope="request" />
<jsp:include page="../../common/header.jsp" />
<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp" />
    <div class="flex-grow-1"><jsp:include page="../../common/navbar.jsp" />
        <div class="main-content container-fluid">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div><h3 class="fw-bold mb-1"><i class="fa-solid fa-percent text-primary me-2"></i>Khuyến Mãi Hệ Thống</h3><div class="text-muted">Giảm giá sản phẩm hoặc phí vận chuyển, áp dụng toàn hệ thống hay từng chi nhánh.</div></div>
                <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#promotionModal"><i class="fa-solid fa-plus me-1"></i>Tạo khuyến mãi</button>
            </div>
            <c:if test="${not empty successMessage}"><div class="alert alert-success"><c:out value="${successMessage}"/></div></c:if>
            <c:if test="${not empty errorMessage}"><div class="alert alert-danger"><c:out value="${errorMessage}"/></div></c:if>
            <div class="card border-0 shadow-sm"><div class="table-responsive"><table class="table table-hover align-middle mb-0">
                <thead class="table-light"><tr><th>Tên Chương Trình</th><th>Phạm vi</th><th>Loại</th><th>Mức giảm</th><th>Đơn tối thiểu</th><th>Thời gian</th><th>Trạng thái</th><th></th></tr></thead>
                <tbody>
                    <c:forEach var="p" items="${promotions}"><tr>
                        <td class="fw-bold"><c:out value="${p.title}"/><div class="mt-1"><span class="badge bg-light text-dark border font-monospace" style="font-size: 11px;"><i class="fa-solid fa-tag me-1 text-warning"></i>${p.displayCode}</span></div></td><td><c:out value="${p.branch == null ? 'Toàn hệ thống' : p.branch.name}"/></td>
                        <td><span class="badge bg-info text-dark">${p.type == 'SHIPPING_PERCENT' ? 'Phí vận chuyển' : 'Sản phẩm'}</span></td>
                        <td>${p.discountPercent}% <c:if test="${p.maxDiscountAmount != null}"><small class="text-muted">(tối đa <fmt:formatNumber value="${p.maxDiscountAmount}" pattern="#,##0 ₫" />)</small></c:if></td>
                        <td><fmt:formatNumber value="${p.minOrderValue}" pattern="#,##0 ₫" /></td><td>${p.startDate} → ${p.endDate}</td>
                        <td><span class="badge ${p.active ? 'bg-success' : 'bg-secondary'}">${p.active ? 'HOẠT ĐỘNG' : 'TẠM DỪNG'}</span></td>
                        <td class="text-end"><form action="/admin/promotions/${p.id}/delete" method="post" onsubmit="return confirm('Xóa chương trình này?')">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button class="btn btn-sm btn-outline-danger"><i class="fa-solid fa-trash"></i></button></form></td>
                    </tr></c:forEach>
                    <c:if test="${empty promotions}"><tr><td colspan="8" class="text-center text-muted py-5">Chưa có chương trình khuyến mãi.</td></tr></c:if>
                </tbody>
            </table></div></div>
        </div>
    </div>
</div>

<div class="modal fade" id="promotionModal" tabindex="-1"><div class="modal-dialog"><div class="modal-content">
    <form action="/admin/promotions/save" method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
        <div class="modal-header"><h5 class="modal-title fw-bold">Tạo chương trình khuyến mãi</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
        <div class="modal-body">
            <div class="mb-3"><label class="form-label">Tên chương trình</label><input name="title" class="form-control" required></div>
            <div class="mb-3"><label class="form-label">Mã khuyến mãi (Tùy chọn)</label><input name="code" class="form-control font-monospace" placeholder="VD: ALLSACH10 (để trống hệ thống tự tạo mã)"></div>
            <div class="mb-3"><label class="form-label">Phạm vi</label><select name="branchId" class="form-select"><option value="">Toàn hệ thống</option><c:forEach var="b" items="${branches}"><option value="${b.id}">${b.name}</option></c:forEach></select></div>
            <div class="mb-3"><label class="form-label">Loại giảm</label><select name="type" class="form-select"><c:forEach var="item" items="${types}"><option value="${item}">${item == 'SHIPPING_PERCENT' ? 'Giảm phí vận chuyển' : 'Giảm giá sản phẩm'}</option></c:forEach></select></div>
            <div class="row"><div class="col-6 mb-3"><label class="form-label">Phần trăm giảm</label><input type="number" min="0" max="100" step="0.1" name="discountPercent" value="10" class="form-control" required></div><div class="col-6 mb-3"><label class="form-label">Giảm tối đa</label><input type="number" min="0" name="maxDiscountAmount" class="form-control"></div></div>
            <div class="mb-3"><label class="form-label">Đơn tối thiểu</label><input type="number" min="0" name="minOrderValue" value="0" class="form-control"></div>
            <div class="row"><div class="col-6 mb-3"><label class="form-label">Ngày bắt đầu</label><input type="date" name="startDate" class="form-control" required></div><div class="col-6 mb-3"><label class="form-label">Ngày kết thúc</label><input type="date" name="endDate" class="form-control" required></div></div>
            <div class="form-check"><input type="checkbox" name="active" value="true" checked class="form-check-input" id="adminPromotionActive"><label for="adminPromotionActive" class="form-check-label">Kích hoạt ngay</label></div>
        </div>
        <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button><button class="btn btn-primary">Lưu</button></div>
    </form>
</div></div></div>
<jsp:include page="../../common/footer.jsp" />
