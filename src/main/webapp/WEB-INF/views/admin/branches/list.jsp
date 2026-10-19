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

            <c:if test="${not empty successMessage}"><div class="alert alert-success">${successMessage}</div></c:if>
            <c:if test="${not empty errorMessage}"><div class="alert alert-danger">${errorMessage}</div></c:if>

            <div class="row g-4">
                <c:forEach var="b" items="${branches}">
                    <div class="col-md-4">
                        <div class="card h-100 border-0 shadow-sm rounded-3">
                            <img src="${b.imageUrl != null ? b.imageUrl : 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=500&q=80'}" class="card-img-top" alt="Branch Image" style="height: 180px; object-fit: cover;">
                            <div class="card-body">
                                <span class="badge bg-success float-end">${b.status}</span>
                                <h5 class="fw-bold text-dark mb-2">${b.name}</h5>
                                <p class="text-muted small mb-1"><i class="fa-solid fa-location-dot me-2 text-danger"></i>${b.address}</p>
                                <p class="text-muted small mb-1"><i class="fa-solid fa-phone me-2 text-primary"></i>${b.phone}</p>
                                <p class="text-muted small mb-3"><i class="fa-solid fa-envelope me-2 text-info"></i>${b.email}</p>
                                <div class="pt-2 border-top">
                                    <form action="/admin/branches/${b.id}/commission" method="post" class="input-group input-group-sm mb-2">
                                        <span class="input-group-text">Chiết khấu App</span>
                                        <input type="number" min="0" max="100" step="0.1" name="appDiscountPercent" value="${b.appDiscountPercent}" class="form-control" required>
                                        <span class="input-group-text">%</span>
                                        <button class="btn btn-outline-primary" title="Lưu chiết khấu"><i class="fa-solid fa-floppy-disk"></i></button>
                                    </form>
                                    <div class="text-end">
                                    <div>
                                        <form action="/admin/branches/delete/${b.id}" method="post" class="d-inline" onsubmit="return confirm('Bạn có chắc chắn muốn xóa chi nhánh này?')"><button class="btn btn-sm btn-outline-danger"><i class="fa-solid fa-trash"></i></button></form>
                                    </div>
                                    </div>
                                </div>
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
                            <div class="modal-header">
                                <h5 class="modal-title fw-bold">Thêm / Sửa Chi Nhánh</h5>
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
