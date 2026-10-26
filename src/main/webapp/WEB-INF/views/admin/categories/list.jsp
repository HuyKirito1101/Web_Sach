<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="title" value="Quản Lý Danh Mục - Admin" scope="request" />
<jsp:include page="../../common/header.jsp" />

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp" />

    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp" />

        <div class="main-content container-fluid">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0"><i class="fa-solid fa-list-check text-primary me-2"></i>Quản Lý Danh Mục Sách</h3>
                <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addCategoryModal">
                    <i class="fa-solid fa-plus me-1"></i> Thêm Danh Mục Mới
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
                                    <th>Tên Danh Mục</th>
                                    <th>Slug</th>
                                    <th>Mô Tả</th>
                                    <th>Trạng Thái</th>
                                    <th class="text-end">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="c" items="${categories}">
                                    <tr>
                                        <td>${c.id}</td>
                                        <td class="fw-bold text-primary"><c:out value="${c.name}"/></td>
                                        <td><code>${c.slug}</code></td>
                                        <td><c:out value="${c.description}"/></td>
                                        <td><span class="badge ${c.active ? 'bg-success' : 'bg-secondary'}">${c.active ? 'HIỂN THỊ' : 'ẨN'}</span></td>
                                        <td class="text-end">
                                            <button type="button" class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#editCategory${c.id}"><i class="fa-solid fa-pen"></i></button>
                                            <form action="/admin/categories/delete/${c.id}" method="post" class="d-inline" onsubmit="return confirm('Ẩn danh mục này? Sách hiện có vẫn được giữ lại.')">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button class="btn btn-sm btn-outline-danger" title="Ẩn danh mục"><i class="fa-solid fa-eye-slash"></i></button></form>
                                        </td>
                                    </tr>

                                    <div class="modal fade" id="editCategory${c.id}" tabindex="-1"><div class="modal-dialog"><div class="modal-content">
                                        <form action="/admin/categories/save" method="post">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><input type="hidden" name="id" value="${c.id}">
                                            <div class="modal-header"><h5 class="modal-title fw-bold">Sửa Danh Mục</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                                            <div class="modal-body"><div class="mb-3"><label class="form-label">Tên danh mục</label><input type="text" maxlength="150" name="name" class="form-control" value="<c:out value='${c.name}'/>" required></div><div class="mb-3"><label class="form-label">Slug</label><input type="text" maxlength="150" name="slug" class="form-control" value="<c:out value='${c.slug}'/>"></div><div class="mb-3"><label class="form-label">Mô tả</label><textarea name="description" class="form-control" rows="3"><c:out value="${c.description}"/></textarea></div><div class="mb-3"><label class="form-label">Trạng thái</label><select name="active" class="form-select"><option value="true" ${c.active ? 'selected' : ''}>Hiển thị</option><option value="false" ${!c.active ? 'selected' : ''}>Ẩn</option></select></div></div>
                                            <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button><button class="btn btn-primary">Lưu thay đổi</button></div>
                                        </form>
                                    </div></div></div>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Modal Add Category -->
            <div class="modal fade" id="addCategoryModal" tabindex="-1">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <form action="/admin/categories/save" method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                            <div class="modal-header">
                                <h5 class="modal-title fw-bold">Thêm Danh Mục Sách Mới</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="mb-3">
                                    <label class="form-label">Tên Danh Mục</label>
                                    <input type="text" name="name" maxlength="150" class="form-control" placeholder="Ví dụ: Truyện Tranh Cũ, Sách Trước 1975" required />
                                </div>
                                <input type="hidden" name="active" value="true">
                                <div class="mb-3">
                                    <label class="form-label">Mô Tả Chi Tiết</label>
                                    <textarea name="description" class="form-control" rows="3"></textarea>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                <button type="submit" class="btn btn-primary">Lưu Danh Mục</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../../common/footer.jsp" />
