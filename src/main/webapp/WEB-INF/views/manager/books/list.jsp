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

                    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addCopyModal">
                        <i class="fa-solid fa-plus me-1"></i> Nhập Bản Sách Cũ
                    </button>
                </div>
            </div>

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
                                            <img src="${c.imageUrl != null ? c.imageUrl : c.book.coverUrl}" class="rounded" width="50" height="65" style="object-fit: cover;" alt="Book Cover">
                                        </td>
                                        <td>
                                            <div class="fw-bold text-dark">${c.book.title}</div>
                                            <span class="text-muted small">ISBN: ${c.book.isbn}</span>
                                        </td>
                                        <td>
                                            <span class="badge ${c.conditionRating == 'LIKE_NEW' ? 'bg-success' : (c.conditionRating == 'VERY_GOOD' ? 'bg-primary' : (c.conditionRating == 'GOOD' ? 'bg-info text-dark' : 'bg-warning text-dark'))}">
                                                ${c.conditionRating}
                                            </span>
                                            <div class="small text-muted mt-1">${c.note}</div>
                                        </td>
                                        <td class="text-muted"><fmt:formatNumber value="${c.purchasePrice}" pattern="#,##0 ₫" /></td>
                                        <td class="fw-bold text-success"><fmt:formatNumber value="${c.sellingPrice}" pattern="#,##0 ₫" /></td>
                                        <td class="fw-bold fs-6">${c.quantity}</td>
                                        <td><span class="badge ${c.status == 'AVAILABLE' ? 'bg-success' : 'bg-secondary'}">${c.status}</span></td>
                                        <td class="text-end">
                                            <a href="/manager/books/delete/${c.id}" class="btn btn-sm btn-outline-danger" onclick="return confirm('Bạn có chắc chắn muốn xóa?')"><i class="fa-solid fa-trash"></i></a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
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
                                    <label class="form-label">Chọn Đầu Sách</label>
                                    <select name="bookId" class="form-select" required>
                                        <c:forEach var="b" items="${allBooks}">
                                            <option value="${b.id}">${b.title} (ISBN: ${b.isbn})</option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label">Đánh Giá Tình Trạng Sách</label>
                                        <select name="conditionRating" class="form-select" required>
                                            <option value="LIKE_NEW">LIKE_NEW - Như mới (90-99%)</option>
                                            <option value="VERY_GOOD">VERY_GOOD - Rất tốt (80-89%)</option>
                                            <option value="GOOD" selected>GOOD - Tốt (70-79%)</option>
                                            <option value="FAIR">FAIR - Trung bình (50-69%)</option>
                                            <option value="POOR">POOR - Cũ/Kém chất lượng (<50%)</option>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">Số Lượng Nhập Kho</label>
                                        <input type="number" name="quantity" class="form-control" value="1" min="1" required />
                                    </div>
                                </div>

                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label">Giá Mua Vào (VNĐ)</label>
                                        <input type="number" name="purchasePrice" class="form-control" placeholder="30000" required />
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">Giá Bán Ra (VNĐ)</label>
                                        <input type="number" name="sellingPrice" class="form-control" placeholder="50000" required />
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Ghi Chú Về Tình Trạng Thực Tế</label>
                                    <textarea name="note" class="form-control" rows="2" placeholder="Ví dụ: Bìa hơi ố nhẹ góc trái, gáy sách chắc chắn..."></textarea>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Ảnh Chụp Thực Tế (Upload Cloudinary)</label>
                                    <input type="file" name="imageFile" class="form-control" accept="image/*" />
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                <button type="submit" class="btn btn-primary">Lưu Nhập Kho</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../../common/footer.jsp" />
