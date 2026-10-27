<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="title" value="Quản Lý Người Dùng Chi Nhánh - Manager" scope="request" />
<jsp:include page="../../common/header.jsp" />

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp" />

    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp" />

        <div class="main-content container-fluid">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold mb-0"><i class="fa-solid fa-users-gear text-primary me-2"></i>Quản Lý Người Dùng Chi Nhánh</h3>
                    <small class="text-muted"><c:out value="${branch.name}"/> — gồm User, Vendor và Shipper thuộc hoặc đã mua hàng tại chi nhánh</small>
                </div>
                <form action="/manager/staff" method="get" class="d-flex gap-2">
                    <input name="keyword" value="<c:out value='${keyword}'/>" class="form-control" placeholder="Tên, email, số điện thoại">
                    <button class="btn btn-primary"><i class="fa-solid fa-magnifying-glass"></i></button>
                </form>
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
                                    <th>Họ và Tên</th>
                                    <th>Email</th>
                                    <th>Số Điện Thoại</th>
                                    <th>Quyền Hạn</th>
                                    <th>Trạng Thái</th>
                                    <th class="text-end">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="s" items="${staffList}">
                                    <tr>
                                        <td>${s.id}</td>
                                        <td class="fw-bold text-dark"><c:out value="${s.fullName}"/></td>
                                        <td><c:out value="${s.email}"/></td>
                                        <td><c:out value="${s.phone}"/></td>
                                        <td><span class="badge bg-primary"><c:out value="${s.role.name}"/></span></td>
                                        <td><span class="badge ${s.status == 'ACTIVE' ? 'bg-success' : 'bg-secondary'}">${s.status}</span></td>
                                        <td class="text-end">
                                            <button class="btn btn-sm btn-outline-primary me-1" type="button"
                                                    data-bs-toggle="modal" data-bs-target="#editModal${s.id}"
                                                    title="Sửa quyền và trạng thái">
                                                <i class="fa-solid fa-user-pen"></i> Sửa
                                            </button>
                                            <form action="/manager/staff/${s.id}/toggle-lock" method="post" class="d-inline">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                <button class="btn btn-sm ${s.status == 'LOCKED' ? 'btn-outline-success' : 'btn-outline-warning'} me-1"
                                                        title="${s.status == 'LOCKED' ? 'Mở khóa' : 'Khóa'} tài khoản">
                                                    <i class="fa-solid ${s.status == 'LOCKED' ? 'fa-lock-open' : 'fa-lock'}"></i>
                                                </button>
                                            </form>
                                            <form action="/manager/staff/${s.id}/delete" method="post" class="d-inline"
                                                  onsubmit="return confirm('Chỉ tài khoản không còn đơn hàng hoặc dữ liệu liên quan mới được xóa. Tiếp tục kiểm tra?')">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                <button class="btn btn-sm btn-outline-danger" title="Xóa nếu không còn dữ liệu liên quan">
                                                    <i class="fa-solid fa-trash"></i>
                                                </button>
                                            </form>
                                        </td>
                                    </tr>

                                </c:forEach>
                                <c:if test="${empty staffList}"><tr><td colspan="7" class="text-center text-muted py-5">Không tìm thấy người dùng trong chi nhánh.</td></tr></c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <c:forEach var="s" items="${staffList}">
                <div class="modal fade" id="editModal${s.id}" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content text-start">
                            <form action="/manager/staff/update-role-status" method="post">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <input type="hidden" name="userId" value="${s.id}">
                                <div class="modal-header">
                                    <h5 class="modal-title fw-bold">Cập Nhật: <c:out value="${s.fullName}"/></h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <div class="modal-body">
                                    <div class="alert alert-info py-2 small">
                                        Tài khoản luôn được giới hạn trong chi nhánh <strong><c:out value="${branch.name}"/></strong>.
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Quyền</label>
                                        <select name="roleId" class="form-select" required>
                                            <c:forEach var="r" items="${roles}">
                                                <option value="${r.id}" ${s.role.id == r.id ? 'selected' : ''}><c:out value="${r.name}"/></option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Trạng thái</label>
                                        <select name="status" class="form-select" required>
                                            <option value="ACTIVE" ${s.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                            <option value="INACTIVE" ${s.status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                                            <option value="LOCKED" ${s.status == 'LOCKED' ? 'selected' : ''}>LOCKED</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                    <button type="submit" class="btn btn-primary">Lưu Thay Đổi</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
</div>

<jsp:include page="../../common/footer.jsp" />
