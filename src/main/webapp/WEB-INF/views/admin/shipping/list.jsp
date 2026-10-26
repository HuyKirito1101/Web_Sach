<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="title" value="Nhà Vận Chuyển - Admin" scope="request" />
<jsp:include page="../../common/header.jsp" />

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp" />

    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp" />

        <div class="main-content container-fluid">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0"><i class="fa-solid fa-truck-fast text-primary me-2"></i>Quản Lý Nhà Vận Chuyển & Phí Giao Hàng</h3>
                <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addShippingModal">
                    <i class="fa-solid fa-plus me-1"></i> Thêm Nhà Vận Chuyển
                </button>
            </div>

            <c:if test="${not empty successMessage}"><div class="alert alert-success"><c:out value="${successMessage}"/></div></c:if>
            <c:if test="${not empty errorMessage}"><div class="alert alert-danger"><c:out value="${errorMessage}"/></div></c:if>

            <div class="card border-0 shadow-sm rounded-3">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Tên Nhà Vận Chuyển</th>
                                    <th>Mã</th>
                                    <th>Dịch Vụ</th>
                                    <th>Số Điện Thoại Hotline</th>
                                    <th>Phí Vận Chuyển Mặc Định</th>
                                    <th>Trạng Thái</th>
                                    <th class="text-end">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${providers}">
                                    <tr>
                                        <td>${p.id}</td>
                                        <td class="fw-bold text-dark"><c:out value="${p.name}"/></td>
                                        <td><code><c:out value="${p.code}"/></code></td>
                                        <td><c:out value="${p.serviceType}"/></td>
                                        <td><c:out value="${p.phone}"/></td>
                                        <td class="fw-bold text-success"><fmt:formatNumber value="${p.baseFee}" pattern="#,##0 ₫" /></td>
                                        <td><span class="badge ${p.active ? 'bg-success' : 'bg-secondary'}">${p.active ? 'HOẠT ĐỘNG' : 'TẠM DỪNG'}</span></td>
                                        <td class="text-end">
                                            <button type="button" class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#editShipping${p.id}"><i class="fa-solid fa-pen"></i></button>
                                            <form action="/admin/shipping/delete/${p.id}" method="post" class="d-inline" onsubmit="return confirm('Tạm dừng nhà vận chuyển này?')">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button class="btn btn-sm btn-outline-danger" title="Tạm dừng"><i class="fa-solid fa-ban"></i></button></form>
                                        </td>
                                    </tr>

                                    <div class="modal fade" id="editShipping${p.id}" tabindex="-1">
                                        <div class="modal-dialog"><div class="modal-content">
                                            <form action="/admin/shipping/save" method="post">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                <input type="hidden" name="id" value="${p.id}">
                                                <div class="modal-header"><h5 class="modal-title fw-bold">Sửa Nhà Vận Chuyển</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                                                <div class="modal-body">
                                                    <div class="mb-3"><label class="form-label">Tên đơn vị</label><input name="name" maxlength="150" class="form-control" value="<c:out value='${p.name}'/>" required></div>
                                                    <div class="row"><div class="col-6 mb-3"><label class="form-label">Mã</label><input name="code" maxlength="50" class="form-control" value="<c:out value='${p.code}'/>" required></div><div class="col-6 mb-3"><label class="form-label">Hotline</label><input name="phone" class="form-control" value="<c:out value='${p.phone}'/>"></div></div>
                                                    <div class="mb-3"><label class="form-label">Loại dịch vụ</label><input name="serviceType" maxlength="100" class="form-control" value="<c:out value='${p.serviceType}'/>"></div>
                                                    <div class="mb-3"><label class="form-label">Thời gian dự kiến</label><input name="estimatedDays" maxlength="100" class="form-control" value="<c:out value='${p.estimatedDays}'/>"></div>
                                                    <div class="mb-3"><label class="form-label">Phạm vi</label><input name="scopeDescription" maxlength="255" class="form-control" value="<c:out value='${p.scopeDescription}'/>"></div>
                                                    <div class="mb-3"><label class="form-label">Phí cơ bản</label><input type="number" min="0" name="baseFee" value="${p.baseFee}" class="form-control" required></div>
                                                    <div class="form-check"><input type="checkbox" name="active" value="true" ${p.active ? 'checked' : ''} class="form-check-input" id="shippingActive${p.id}"><label for="shippingActive${p.id}" class="form-check-label">Hoạt động</label></div>
                                                </div>
                                                <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button><button class="btn btn-primary">Lưu thay đổi</button></div>
                                            </form>
                                        </div></div>
                                    </div>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Modal Add Shipping Provider -->
            <div class="modal fade" id="addShippingModal" tabindex="-1">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <form action="/admin/shipping/save" method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                            <div class="modal-header">
                                <h5 class="modal-title fw-bold">Thêm Nhà Vận Chuyển</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="mb-3">
                                    <label class="form-label">Tên Đơn Vị Vận Chuyển</label>
                                    <input type="text" name="name" maxlength="150" class="form-control" placeholder="Giao Hàng Nhanh (GHN)" required />
                                </div>
                                <div class="mb-3"><label class="form-label">Mã dịch vụ</label><input type="text" name="code" maxlength="50" class="form-control" placeholder="GHN_STANDARD" required /></div>
                                <div class="mb-3">
                                    <label class="form-label">Hotline</label>
                                    <input type="text" name="phone" class="form-control" placeholder="0901234567" />
                                </div>
                                <div class="mb-3"><label class="form-label">Loại dịch vụ</label><input type="text" name="serviceType" maxlength="100" class="form-control" placeholder="Giao tiêu chuẩn" /></div>
                                <div class="mb-3"><label class="form-label">Thời gian dự kiến</label><input type="text" name="estimatedDays" maxlength="100" class="form-control" placeholder="2-4 ngày" /></div>
                                <div class="mb-3"><label class="form-label">Phạm vi</label><input type="text" name="scopeDescription" maxlength="255" class="form-control" placeholder="Nội thành TP.HCM" /></div>
                                <div class="mb-3">
                                    <label class="form-label">Cước Phí Cơ Bản (VNĐ)</label>
                                    <input type="number" min="0" name="baseFee" class="form-control" value="25000" required />
                                </div>
                                <div class="form-check"><input type="checkbox" name="active" value="true" checked class="form-check-input" id="adminShippingActive"><label for="adminShippingActive" class="form-check-label">Hoạt động</label></div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                <button type="submit" class="btn btn-primary">Lưu Nhà Vận Chuyển</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../../common/footer.jsp" />
