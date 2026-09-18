<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="title" value="Sản phẩm Vendor" scope="request"/>
<jsp:include page="../../common/header.jsp"/>

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp"/>
    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp"/>
        <main class="main-content container-fluid">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0">Sản phẩm sách cũ gian hàng</h3>
                <div class="d-flex gap-2">
                    <button class="btn btn-success fw-bold" data-bs-toggle="modal" data-bs-target="#createMasterBookModal">
                        <i class="fa-solid fa-book-medical me-1"></i>Thêm Đầu Sách Mới
                    </button>
                    <button class="btn btn-primary fw-bold" data-bs-toggle="modal" data-bs-target="#productModal">
                        <i class="fa-solid fa-plus me-1"></i>Đăng Bán Sách Cũ
                    </button>
                </div>
            </div>

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show rounded-3 mb-4">
                    <i class="fa-solid fa-circle-check me-2"></i>${successMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show rounded-3 mb-4">
                    <i class="fa-solid fa-triangle-exclamation me-2"></i>${errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <div class="card border-0 shadow-sm rounded-3">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Ảnh</th>
                                <th>Sách</th>
                                <th>Tình trạng</th>
                                <th>Giá Bán</th>
                                <th>Tồn Kho</th>
                                <th>Trạng thái</th>
                                <th class="text-end">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${products}">
                                <tr>
                                    <td><img src="${not empty p.imageUrl ? p.imageUrl : p.book.coverUrl}" width="48" height="64" class="rounded" style="object-fit:cover" alt="Ảnh sách"></td>
                                    <td><strong>${p.book.title}</strong><div class="small text-muted">ISBN: ${p.book.isbn}</div></td>
                                    <td><span class="badge bg-info text-dark">${p.conditionRating}</span><div class="small text-muted">${p.note}</div></td>
                                    <td><span class="fw-bold text-success"><fmt:formatNumber value="${p.sellingPrice}" pattern="#,#00 ₫"/></span></td>
                                    <td><span class="fw-bold">${p.quantity}</span></td>
                                    <td><span class="badge ${p.status == 'AVAILABLE' ? 'bg-success' : 'bg-secondary'}">${p.status}</span></td>
                                    <td class="text-end">
                                        <div class="d-flex justify-content-end gap-1">
                                            <button class="btn btn-sm btn-outline-primary" onclick="openEditModal(${p.id}, ${p.book.id}, '${p.conditionRating}', ${p.purchasePrice != null ? p.purchasePrice : 0}, ${p.sellingPrice}, ${p.quantity}, '${p.status}', '${p.note != null ? p.note.replace("'", "\\'") : ''}')"><i class="fa-solid fa-pen me-1"></i>Sửa</button>
                                            <form method="post" action="/vendor/products/${p.id}/toggle"><button class="btn btn-sm btn-outline-secondary">Ẩn/Hiện</button></form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty products}">
                                <tr><td colspan="7" class="text-center text-muted py-4">Chưa có sản phẩm sách cũ nào</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Modal Create Master Book -->
            <div class="modal fade" id="createMasterBookModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <form action="/vendor/create-master-book" method="post" enctype="multipart/form-data">
                            <div class="modal-header bg-success text-white">
                                <h5 class="modal-title fw-bold"><i class="fa-solid fa-book-medical me-2"></i>Thêm Đầu Sách Mới Vẫn Chưa Có Trực Tiếp Về Hệ Thống</h5>
                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Tên Đầu Sách *</label>
                                    <input type="text" name="title" class="form-control" placeholder="Nhập tên sách..." required />
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
                                                <option value="${cat.id}">${cat.name}</option>
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

            <!-- Modal Add Product Copy -->
            <div class="modal fade" id="productModal">
                <div class="modal-dialog modal-lg">
                    <form class="modal-content" method="post" action="/vendor/products/save" enctype="multipart/form-data">
                        <input type="hidden" name="id" id="productId">
                        <div class="modal-header">
                            <h5 class="modal-title fw-bold" id="modalTitle">Đăng Bán Sản Phẩm Sách Cũ</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row g-3">
                                <div class="col-12">
                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                        <label class="form-label mb-0 fw-bold">Chọn Đầu Sách *</label>
                                        <small class="text-primary"><i class="fa-solid fa-plus-circle me-1"></i>Chưa thấy đầu sách bạn cần? <a href="#" data-bs-toggle="modal" data-bs-target="#createMasterBookModal" data-bs-dismiss="modal" class="fw-bold">Bấm vào đây để tạo đầu sách mới</a></small>
                                    </div>
                                    <select class="form-select" name="bookId" id="bookId" required>
                                        <c:forEach var="b" items="${allBooks}">
                                            <option value="${b.id}">${b.title} - ${b.isbn != null ? b.isbn : 'N/A'}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-bold">Tình trạng sách cũ</label>
                                    <select class="form-select" name="conditionRating" id="conditionRating" required>
                                        <c:forEach var="c" items="${conditions}">
                                            <option value="${c}">${c}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-bold">Trạng thái</label>
                                    <select class="form-select" name="status" id="status">
                                        <option value="AVAILABLE">AVAILABLE (Đang bán)</option>
                                        <option value="RESERVED">HIDDEN/RESERVED (Tạm ẩn)</option>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-bold">Giá mua vào (VNĐ)</label>
                                    <input class="form-control" type="number" min="0" name="purchasePrice" id="purchasePrice">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-bold">Giá bán ra (VNĐ)</label>
                                    <input class="form-control" type="number" min="0" name="sellingPrice" id="sellingPrice" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-bold">Số lượng tồn</label>
                                    <input class="form-control" type="number" min="0" name="quantity" id="quantity" value="1" required>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-bold">Mô tả tình trạng thực tế</label>
                                    <textarea class="form-control" name="note" id="note" required placeholder="Ghi chú về ố vàng, bìa sờn, gáy sách..."></textarea>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-bold">Ảnh thực tế sản phẩm</label>
                                    <input class="form-control" type="file" name="imageFile" accept="image/*">
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                            <button class="btn btn-primary fw-bold">Lưu Đăng Bán</button>
                        </div>
                    </form>
                </div>
            </div>

            <script>
            function openEditModal(id, bookId, condition, purchasePrice, sellingPrice, quantity, status, note) {
                document.getElementById('productId').value = id;
                document.getElementById('modalTitle').innerText = 'Chỉnh sửa sản phẩm sách cũ';
                document.getElementById('bookId').value = bookId;
                document.getElementById('conditionRating').value = condition;
                document.getElementById('purchasePrice').value = purchasePrice;
                document.getElementById('sellingPrice').value = sellingPrice;
                document.getElementById('quantity').value = quantity;
                document.getElementById('status').value = status;
                document.getElementById('note').value = note;
                var modal = new bootstrap.Modal(document.getElementById('productModal'));
                modal.show();
            }
            </script>
        </main>
    </div>
</div>
<jsp:include page="../../common/footer.jsp"/>
