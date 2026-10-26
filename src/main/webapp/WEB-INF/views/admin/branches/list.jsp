<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="title" value="Quản Lý Chi Nhánh - Admin" scope="request" />
<jsp:include page="../../common/header.jsp" />

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp" />

    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp" />

        <div class="main-content container-fluid">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0"><i class="fa-solid fa-shop text-primary me-2"></i>Quản Lý Chi Nhánh Cửa Hàng Sách Cũ</h3>
                <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addBranchModal">
                    <i class="fa-solid fa-plus me-1"></i> Thêm Chi Nhánh Mới
                </button>
            </div>

            <c:if test="${not empty successMessage}"><div class="alert alert-success"><c:out value="${successMessage}"/></div></c:if>
            <c:if test="${not empty errorMessage}"><div class="alert alert-danger"><c:out value="${errorMessage}"/></div></c:if>

            <div class="row g-4">
                <c:forEach var="b" items="${branches}">
                    <div class="col-md-4">
                        <div class="card h-100 border-0 shadow-sm rounded-3">
                            <img src="<c:out value='${b.imageUrl != null ? b.imageUrl : "https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=500"}'/>" class="card-img-top" alt="Branch Image" style="height: 180px; object-fit: cover;">
                            <div class="card-body">
                                <span class="badge bg-success float-end">${b.status}</span>
                                <h5 class="fw-bold text-dark mb-2"><c:out value="${b.name}"/></h5>
                                <p class="text-muted small mb-1"><i class="fa-solid fa-location-dot me-2 text-danger"></i><c:out value="${b.address}"/></p>
                                <p class="text-muted small mb-1"><i class="fa-solid fa-phone me-2 text-primary"></i><c:out value="${b.phone}"/></p>
                                <p class="text-muted small mb-3"><i class="fa-solid fa-envelope me-2 text-info"></i><c:out value="${b.email}"/></p>
                                <div class="pt-2 border-top">
                                    <form action="/admin/branches/${b.id}/commission" method="post" class="input-group input-group-sm mb-2">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <span class="input-group-text">Chiết khấu App</span>
                                        <input type="number" min="0" max="100" step="0.1" name="appDiscountPercent" value="${b.appDiscountPercent}" class="form-control" required>
                                        <span class="input-group-text">%</span>
                                        <button class="btn btn-outline-primary" title="Lưu chiết khấu"><i class="fa-solid fa-floppy-disk"></i></button>
                                    </form>
                                    <div class="d-flex justify-content-end gap-2">
                                        <button type="button" class="btn btn-sm btn-outline-warning"
                                                data-bs-toggle="modal" data-bs-target="#editBranchModal${b.id}">
                                            <i class="fa-solid fa-pen-to-square me-1"></i>Chỉnh sửa
                                        </button>
                                        <form action="/admin/branches/delete/${b.id}" method="post" class="d-inline" onsubmit="return confirm('Bạn có chắc chắn muốn xóa chi nhánh này?')">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><button class="btn btn-sm btn-outline-danger"><i class="fa-solid fa-trash"></i></button></form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Modal Edit Branch -->
                    <div class="modal fade" id="editBranchModal${b.id}" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-lg">
                            <div class="modal-content">
                                <form action="/admin/branches/save" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                    <input type="hidden" name="id" value="${b.id}" />
                                    <div class="modal-header">
                                        <h5 class="modal-title fw-bold">
                                            <i class="fa-solid fa-pen-to-square text-warning me-2"></i>Chỉnh Sửa Chi Nhánh
                                        </h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                    </div>
                                    <div class="modal-body">
                                        <div class="row g-3">
                                            <div class="col-md-8">
                                                <label class="form-label">Tên Chi Nhánh</label>
                                                <input type="text" name="name" class="form-control" value="<c:out value='${b.name}'/>" required />
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label">Trạng Thái</label>
                                                <select name="status" class="form-select" required>
                                                    <c:forEach var="status" items="${branchStatuses}">
                                                        <option value="${status}" ${b.status == status ? 'selected' : ''}>${status}</option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label">Địa Chỉ</label>
                                                <input type="text" name="address" class="form-control" value="<c:out value='${b.address}'/>" required />
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">Số Điện Thoại</label>
                                                <input type="text" name="phone" class="form-control" value="<c:out value='${b.phone}'/>" />
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">Email</label>
                                                <input type="email" name="email" class="form-control" value="<c:out value='${b.email}'/>" />
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label">Mô Tả</label>
                                                <textarea name="description" class="form-control" rows="3"><c:out value="${b.description}"/></textarea>
                                            </div>
                                            <div class="col-md-5">
                                                <label class="form-label">Chiết Khấu Ứng Dụng (%)</label>
                                                <input type="number" min="0" max="100" step="0.1" name="appDiscountPercent"
                                                       class="form-control" value="${b.appDiscountPercent}" required />
                                            </div>
                                            <div class="col-md-7">
                                                <label class="form-label">Thay Ảnh Chi Nhánh</label>
                                                <input type="file" name="imageFile" class="form-control" accept="image/*" />
                                                <div class="form-text">Không chọn tệp nếu muốn giữ ảnh hiện tại.</div>
                                            </div>
                                            <c:if test="${not empty b.imageUrl}">
                                                <div class="col-12">
                                                    <div class="small text-muted mb-2">Ảnh hiện tại</div>
                                                    <img src="<c:out value='${b.imageUrl}'/>" alt="Ảnh chi nhánh <c:out value='${b.name}'/>" class="rounded border"
                                                         style="width: 180px; height: 100px; object-fit: cover;" />
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                        <button type="submit" class="btn btn-warning fw-bold">
                                            <i class="fa-solid fa-floppy-disk me-1"></i>Lưu Thay Đổi
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- Modal Add Branch -->
            <div class="modal fade" id="addBranchModal" tabindex="-1">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <form action="/admin/branches/save" method="post" enctype="multipart/form-data">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                            <div class="modal-header">
                                <h5 class="modal-title fw-bold">Thêm Chi Nhánh Mới</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="mb-3">
                                    <label class="form-label">Tên Chi Nhánh</label>
                                    <input type="text" name="name" class="form-control" placeholder="Sách Cũ Chi Nhánh Quận 3" required />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Địa Chỉ</label>
                                    <input type="text" name="address" class="form-control" placeholder="123 Nam Ky Khoi Nghia, Q3" required />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Số Điện Thoại</label>
                                    <input type="text" name="phone" class="form-control" placeholder="0901234567" />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Email</label>
                                    <input type="email" name="email" class="form-control" placeholder="q3@websach.com" />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Mô Tả</label>
                                    <textarea name="description" class="form-control" rows="3" placeholder="Thông tin giới thiệu chi nhánh"></textarea>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Trạng Thái</label>
                                    <select name="status" class="form-select" required>
                                        <c:forEach var="status" items="${branchStatuses}">
                                            <option value="${status}" ${status == 'ACTIVE' ? 'selected' : ''}>${status}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">% Chiết Khấu App Cho Cửa Hàng</label>
                                    <input type="number" step="0.1" name="appDiscountPercent" class="form-control" value="10.0" required />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Hình Ảnh (Upload Cloudinary)</label>
                                    <input type="file" name="imageFile" class="form-control" accept="image/*" />
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                <button type="submit" class="btn btn-primary">Lưu Chi Nhánh</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../../common/footer.jsp" />
