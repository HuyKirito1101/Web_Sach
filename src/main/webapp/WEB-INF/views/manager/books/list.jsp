<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="title" value="Kho Sách Cũ - Manager" scope="request" />
<jsp:include page="../../common/header.jsp" />

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp" />

    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp" />

        <div class="main-content container-fluid">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0"><i class="fa-solid fa-book text-primary me-2"></i>Quản Lý Kho Sách Cũ Chi Nhánh</h3>
                
                <div class="d-flex gap-2">
                    <form action="/manager/books" method="get" class="d-flex gap-2">
                        <select name="condition" class="form-select" onchange="this.form.submit()">
                            <option value="">-- Tất Cả Tình Trạng --</option>
                            <c:forEach var="cond" items="${conditions}">
                                <option value="${cond}" ${selectedCondition == cond ? 'selected' : ''}>${cond}</option>
                            </c:forEach>
                        </select>
                    </form>

                    <button class="btn btn-success fw-bold" data-bs-toggle="modal" data-bs-target="#createMasterBookModal">
                        <i class="fa-solid fa-book-medical me-1"></i> Thêm Đầu Sách Mới
                    </button>

                    <button class="btn btn-primary fw-bold" data-bs-toggle="modal" data-bs-target="#addCopyModal">
                        <i class="fa-solid fa-plus me-1"></i> Nhập Bản Sách Cũ
                    </button>
                </div>
            </div>

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show rounded-3 mb-4">
                    <i class="fa-solid fa-circle-check me-2"></i><c:out value="${successMessage}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show rounded-3 mb-4">
                    <i class="fa-solid fa-triangle-exclamation me-2"></i><c:out value="${errorMessage}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <div class="card border-0 shadow-sm rounded-3">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Ảnh Thực Tế</th>
                                    <th>Tên Đầu Sách</th>
                                    <th>Tình Trạng Sách</th>
                                    <th>Giá Nhập</th>
                                    <th>Giá Bán</th>
                                    <th>Số Lượng Tồn</th>
                                    <th>Trạng Thái</th>
                                    <th class="text-end">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="c" items="${copies}">
                                    <tr>
                                        <td>
                                            <img src="<c:out value='${c.imageUrl != null ? c.imageUrl : c.book.coverUrl}'/>" class="rounded" width="50" height="65" style="object-fit: cover;" alt="Book Cover">
                                        </td>
                                        <td>
                                            <div class="fw-bold text-dark"><c:out value="${c.book.title}"/></div>
                                            <span class="text-muted small">ISBN: <c:out value="${c.book.isbn}"/></span>
                                        </td>
                                        <td>
                                            <span class="badge ${c.conditionRating == 'LIKE_NEW' ? 'bg-success' : (c.conditionRating == 'VERY_GOOD' ? 'bg-primary' : (c.conditionRating == 'GOOD' ? 'bg-info text-dark' : 'bg-warning text-dark'))}">
                                                ${c.conditionRating}
                                            </span>
                                            <div class="small text-muted mt-1"><c:out value="${c.note}"/></div>
                                        </td>
                                        <td class="text-muted"><fmt:formatNumber value="${c.purchasePrice}" pattern="#,##0 ₫" /></td>
                                        <td class="fw-bold text-success"><fmt:formatNumber value="${c.sellingPrice}" pattern="#,##0 ₫" /></td>
                                        <td class="fw-bold fs-6">${c.quantity}</td>
                                        <td><span class="badge ${c.status == 'AVAILABLE' ? 'bg-success' : 'bg-secondary'}">${c.status}</span></td>
                                        <td class="text-end">
                                            <form method="post" action="/manager/books/delete/${c.id}" class="d-inline"><button class="btn btn-sm btn-outline-danger" onclick="return confirm('Bạn có chắc chắn muốn xóa?')"><i class="fa-solid fa-trash"></i></button></form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Modal Create Master Book -->
            <div class="modal fade" id="createMasterBookModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <form action="/manager/books/create-master-book" method="post" enctype="multipart/form-data">
                            <div class="modal-header bg-success text-white">
                                <h5 class="modal-title fw-bold"><i class="fa-solid fa-book-medical me-2"></i>Thêm Đầu Sách Mới Vẫn Chưa Có Trực Tiếp Về Hệ Thống</h5>
                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Tên Đầu Sách *</label>
                                    <input type="text" name="title" class="form-control" placeholder="Nhập tên sách (ví dụ: Hoàng Tử Bé, Chí Phèo...)" required />
                                </div>
                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Mã ISBN</label>
                                        <input type="text" name="isbn" class="form-control" placeholder="978604xxxxxx" />
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Tác Giả</label>
                                        <input type="text" name="authorName" class="form-control" placeholder="Tên tác giả" />
                                    </div>
                                </div>
                                <div class="row g-3 mb-3">
                                    <div class="col-md-4">
                                        <label class="form-label fw-bold">Nhà Xuất Bản</label>
                                        <input type="text" name="publisherName" class="form-control" placeholder="NXB Trẻ, Kim Đồng..." />
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label fw-bold">Năm Xuất Bản</label>
                                        <input type="number" name="publishYear" class="form-control" placeholder="1995" />
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label fw-bold">Danh Mục Sách</label>
                                        <select name="categoryId" class="form-select">
                                            <option value="">-- Chọn danh mục --</option>
                                            <c:forEach var="cat" items="${categories}">
                                                <option value="${cat.id}"><c:out value="${cat.name}"/></option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Link Ảnh Bìa / Upload Ảnh Bìa Mẫu</label>
                                    <input type="text" name="coverUrl" class="form-control mb-2" placeholder="https://..." />
                                    <input type="file" name="coverFile" class="form-control" accept="image/*" />
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                <button type="submit" class="btn btn-success fw-bold">Lưu Đầu Sách Mới</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Modal Add Copy -->
            <div class="modal fade" id="addCopyModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <form action="/manager/books/save" method="post" enctype="multipart/form-data">
                            <div class="modal-header">
                                <h5 class="modal-title fw-bold">Nhập Bản Sách Cũ Vào Kho Chi Nhánh</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="mb-3">
                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                        <label class="form-label mb-0 fw-bold">Chọn Đầu Sách *</label>
                                        <small class="text-primary"><i class="fa-solid fa-plus-circle me-1"></i>Chưa thấy đầu sách bạn cần? <a href="#" data-bs-toggle="modal" data-bs-target="#createMasterBookModal" data-bs-dismiss="modal" class="fw-bold">Bấm vào đây để tạo đầu sách mới</a></small>
                                    </div>
                                    <select name="bookId" class="form-select" required>
                                        <c:forEach var="b" items="${allBooks}">
                                            <option value="${b.id}"><c:out value="${b.title}"/> (ISBN: <c:out value="${b.isbn != null ? b.isbn : 'N/A'}"/>)</option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Đánh Giá Tình Trạng Sách</label>
                                        <select name="conditionRating" class="form-select" required>
                                            <option value="LIKE_NEW">LIKE_NEW - Như mới (90-99%)</option>
                                            <option value="VERY_GOOD">VERY_GOOD - Rất tốt (80-89%)</option>
                                            <option value="GOOD" selected>GOOD - Tốt (70-79%)</option>
                                            <option value="FAIR">FAIR - Trung bình (50-69%)</option>
                                            <option value="POOR">POOR - Cũ/Kém chất lượng (<50%)</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Số Lượng Nhập Kho</label>
                                        <input type="number" name="quantity" class="form-control" value="1" min="1" required />
                                    </div>
                                </div>

                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Giá Mua Vào (VNĐ)</label>
                                        <input type="number" name="purchasePrice" class="form-control" placeholder="30000" required />
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Giá Bán Ra (VNĐ)</label>
                                        <input type="number" name="sellingPrice" class="form-control" placeholder="50000" required />
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label fw-bold">Ghi Chú Về Tình Trạng Thực Tế</label>
                                    <textarea name="note" class="form-control" rows="2" placeholder="Ví dụ: Bìa hơi ố nhẹ góc trái, gáy sách chắc chắn..."></textarea>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label fw-bold">Ảnh Chụp Thực Tế (Upload Cloudinary)</label>
                                    <input type="file" name="imageFile" class="form-control" accept="image/*" />
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                <button type="submit" class="btn btn-primary fw-bold">Lưu Nhập Kho</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../../common/footer.jsp" />
