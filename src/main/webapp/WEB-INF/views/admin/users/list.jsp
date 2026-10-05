<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="title" value="Quản Lý Người Dùng - Admin" scope="request" />
<jsp:include page="../../common/header.jsp" />

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp" />

    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp" />

        <div class="main-content container-fluid">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0"><i class="fa-solid fa-users-gear text-primary me-2"></i>Quản Lý Người Dùng & Phân Quyền</h3>
                
                <form action="/admin/users" method="get" class="d-flex gap-2">
                    <input type="text" name="keyword" class="form-control" placeholder="Tìm theo tên, email, sđt..." value="${keyword}" />
                    <button type="submit" class="btn btn-primary"><i class="fa-solid fa-magnifying-glass"></i></button>
                </form>
            </div>

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fa-solid fa-circle-check me-2"></i>${successMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-warning alert-dismissible fade show" role="alert">
                    <i class="fa-solid fa-triangle-exclamation me-2"></i>${errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

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
                                    <th>Quyền (Role)</th>
                                    <th>Chi Nhánh</th>
                                    <th>Trạng Thái</th>
                                    <th class="text-end">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="u" items="${users}">
                                    <tr>
                                        <td>${u.id}</td>
                                        <td class="fw-bold">${u.fullName}</td>
                                        <td>${u.email}</td>
                                        <td>${u.phone}</td>
                                        <td>
                                            <span class="badge ${u.role.name == 'ROLE_ADMIN' ? 'bg-danger' : (u.role.name == 'ROLE_MANAGER' ? 'bg-warning text-dark' : 'bg-primary')}">
                                                ${u.role.name}
                                            </span>
                                        </td>
                                        <td>${u.branch != null ? u.branch.name : '-'}</td>
                                        <td>
                                            <span class="badge ${u.status == 'ACTIVE' ? 'bg-success' : (u.status == 'LOCKED' ? 'bg-danger' : 'bg-secondary')}">
                                                ${u.status}
                                            </span>
                                        </td>
                                        <td class="text-end">
                                            <button class="btn btn-sm btn-outline-primary me-1" data-bs-toggle="modal" data-bs-target="#editModal${u.id}" title="Sửa quyền & chi nhánh">
                                                <i class="fa-solid fa-user-pen"></i> Sửa Role
                                            </button>
                                            <a href="/admin/users/toggle-lock/${u.id}" class="btn btn-sm ${u.status == 'LOCKED' ? 'btn-outline-success' : 'btn-outline-warning'} me-1" title="${u.status == 'LOCKED' ? 'Mở khóa tài khoản' : 'Khóa tài khoản'}">
                                                <i class="fa-solid ${u.status == 'LOCKED' ? 'fa-lock-open' : 'fa-lock'}"></i>
                                            </a>
                                            <c:choose>
                                                <c:when test="${u.email == pageContext.request.userPrincipal.name}">
                                                    <button type="button" class="btn btn-sm btn-outline-secondary" disabled title="Không thể tự xóa tài khoản đang đăng nhập">
                                                        <i class="fa-solid fa-user-shield me-1"></i>Đang dùng
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <form action="/admin/users/delete/${u.id}" method="post" class="d-inline" onsubmit="return confirm('Bạn có chắc chắn muốn xóa người dùng [${u.fullName}] khỏi hệ thống?')">
                                                        <button type="submit" class="btn btn-sm btn-outline-danger" title="Xóa người dùng">
                                                            <i class="fa-solid fa-trash me-1"></i>Xóa
                                                        </button>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>

                                    <!-- Edit User Modal -->
                                    <div class="modal fade" id="editModal${u.id}" tabindex="-1">
                                        <div class="modal-dialog">
                                            <div class="modal-content text-start">
                                                <form action="/admin/users/update-role-status" method="post">
                                                    <input type="hidden" name="userId" value="${u.id}" />
                                                    <div class="modal-header">
                                                        <h5 class="modal-title fw-bold">Cập Nhật Quyền & Chi Nhánh: ${u.fullName}</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="mb-3">
                                                            <label class="form-label">Chọn Role</label>
                                                            <select name="roleId" class="form-select">
                                                                <c:forEach var="r" items="${roles}">
                                                                    <option value="${r.id}" ${u.role.id == r.id ? 'selected' : ''}>${r.name}</option>
                                                                </c:forEach>
                                                            </select>
                                                        </div>

                                                        <div class="mb-3">
                                                            <label class="form-label">Chi Nhánh (Cho Manager/Shipper/Vendor)</label>
                                                            <select name="branchId" class="form-select">
                                                                <option value="">-- Không chọn --</option>
                                                                <c:forEach var="b" items="${branches}">
                                                                    <option value="${b.id}" ${u.branch != null && u.branch.id == b.id ? 'selected' : ''}>${b.name}</option>
                                                                </c:forEach>
                                                            </select>
                                                        </div>

                                                        <div class="mb-3">
                                                            <label class="form-label">Trạng Thái Tài Khoản</label>
                                                            <select name="status" class="form-select">
                                                                <option value="ACTIVE" ${u.status == 'ACTIVE' ? 'selected' : ''}>ACTIVE</option>
                                                                <option value="INACTIVE" ${u.status == 'INACTIVE' ? 'selected' : ''}>INACTIVE</option>
                                                                <option value="LOCKED" ${u.status == 'LOCKED' ? 'selected' : ''}>LOCKED</option>
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
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../../common/footer.jsp" />
