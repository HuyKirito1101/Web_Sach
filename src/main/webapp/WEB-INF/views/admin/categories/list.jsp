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
                                        <td class="fw-bold text-primary">${c.name}</td>
                                        <td><code>${c.slug}</code></td>
                                        <td>${c.description}</td>
                                        <td><span class="badge ${c.active ? 'bg-success' : 'bg-secondary'}">${c.active ? 'HIỂN THỊ' : 'ẨN'}</span></td>
                                        <td class="text-end">
                                            <form action="/admin/categories/delete/${c.id}" method="post" class="d-inline" onsubmit="return confirm('Bạn có chắc chắn muốn xóa danh mục này?')"><button class="btn btn-sm btn-outline-danger"><i class="fa-solid fa-trash"></i></button></form>
                                        </td>
                                    </tr>
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
                            <div class="modal-header">
                                <h5 class="modal-title fw-bold">Thêm Danh Mục Sách Mới</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="mb-3">
                                    <label class="form-label">Tên Danh Mục</label>
                                    <input type="text" name="name" class="form-control" placeholder="Ví dụ: Truyện Tranh Cũ, Sách Trước 1975" required />
                                </div>
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
