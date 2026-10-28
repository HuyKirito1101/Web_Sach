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
                <div>
                    <h3 class="fw-bold mb-1">Sản phẩm sách cũ gian hàng</h3>
                    <p class="text-muted small mb-0">Quản lý kho sách của gian hàng. Sản phẩm mới thêm sẽ ở trạng thái Chưa đăng bán cho đến khi bạn bấm Đăng bán.</p>
                </div>
                <div class="d-flex gap-2">
                    <button class="btn btn-success fw-bold shadow-sm" data-bs-toggle="modal" data-bs-target="#createMasterBookModal">
                        <i class="fa-solid fa-book-medical me-1"></i>Thêm Đầu Sách Mới
                    </button>
                    <button class="btn btn-primary fw-bold shadow-sm" onclick="openAddModal()">
                        <i class="fa-solid fa-plus me-1"></i>Đăng Bán Sách Cũ
                    </button>
                </div>
            </div>

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show rounded-3 mb-4 shadow-sm">
                    <i class="fa-solid fa-circle-check me-2"></i><c:out value="${successMessage}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show rounded-3 mb-4 shadow-sm">
                    <i class="fa-solid fa-triangle-exclamation me-2"></i><c:out value="${errorMessage}"/>
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
                                <th class="text-end pe-3">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${products}">
                                <tr>
                                    <td>
                                        <img src="<c:out value='${not empty p.imageUrl ? p.imageUrl : p.book.coverUrl}'/>" 
                                             width="48" height="64" class="rounded border shadow-xs" style="object-fit:cover" alt="Ảnh sách">
                                    </td>
                                    <td>
                                        <strong><c:out value="${p.book.title}"/></strong>
                                        <div class="small text-muted">ISBN: <c:out value="${p.book.isbn != null ? p.book.isbn : 'N/A'}"/></div>
                                    </td>
                                    <td>
                                        <span class="badge bg-info text-dark"><c:out value="${p.conditionRating}"/></span>
                                        <div class="small text-muted text-truncate" style="max-width: 250px;"><c:out value="${p.note}"/></div>
                                    </td>
                                    <td>
                                        <span class="fw-bold text-success"><fmt:formatNumber value="${p.sellingPrice}" pattern="#,##0"/> đ</span>
                                    </td>
                                    <td>
                                        <span class="fw-bold ${p.quantity > 0 ? 'text-dark' : 'text-danger'}">${p.quantity}</span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${p.status == 'AVAILABLE'}">
                                                <span class="badge bg-success px-2 py-1"><i class="fa-solid fa-circle-check me-1"></i>Đang bán</span>
                                            </c:when>
                                            <c:when test="${p.status == 'UNPUBLISHED'}">
                                                <span class="badge bg-secondary px-2 py-1"><i class="fa-solid fa-pause me-1"></i>Chưa đăng bán</span>
                                            </c:when>
                                            <c:when test="${p.status == 'RESERVED'}">
                                                <span class="badge bg-warning text-dark px-2 py-1"><i class="fa-solid fa-eye-slash me-1"></i>Tạm ẩn</span>
                                            </c:when>
                                            <c:when test="${p.status == 'SOLD'}">
                                                <span class="badge bg-dark px-2 py-1"><i class="fa-solid fa-box-archive me-1"></i>Hết hàng</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-info px-2 py-1">${p.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-end pe-3">
                                        <div class="d-flex justify-content-end align-items-center gap-1 flex-wrap">
                                            <!-- Đăng bán khi chưa đăng bán -->
                                            <c:if test="${p.status == 'UNPUBLISHED'}">
                                                <form method="post" action="/vendor/products/${p.id}/publish" class="d-inline m-0">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                    <button type="submit" class="btn btn-sm btn-success fw-bold px-2 py-1 shadow-xs" title="Đăng bán lên trang web">
                                                        <i class="fa-solid fa-cloud-arrow-up me-1"></i>Đăng bán
                                                    </button>
                                                </form>
                                            </c:if>

                                            <!-- Tạm ẩn / Hiện lại (Đóng băng tạm thời) -->
                                            <c:choose>
                                                <c:when test="${p.status == 'AVAILABLE'}">
                                                    <form method="post" action="/vendor/products/${p.id}/toggle" class="d-inline m-0">
                                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                        <button type="submit" class="btn btn-sm btn-outline-warning text-dark px-2 py-1" title="Tạm ẩn sản phẩm (không hiển thị lên web)">
                                                            <i class="fa-solid fa-eye-slash me-1"></i>Tạm ẩn
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:when test="${p.status == 'RESERVED'}">
                                                    <form method="post" action="/vendor/products/${p.id}/toggle" class="d-inline m-0">
                                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                        <button type="submit" class="btn btn-sm btn-outline-success px-2 py-1" title="Hiện lại sản phẩm lên trang web">
                                                            <i class="fa-solid fa-eye me-1"></i>Hiện lại
                                                        </button>
                                                    </form>
                                                </c:when>
                                            </c:choose>

                                            <!-- Nút Sửa -->
                                            <button type="button" class="btn btn-sm btn-outline-primary product-edit-button px-2 py-1"
                                                    data-product-id="${p.id}"
                                                    data-book-id="${p.book.id}"
                                                    data-book-title="<c:out value='${p.book.title}'/>"
                                                    data-book-isbn="<c:out value='${p.book.isbn}'/>"
                                                    data-condition="<c:out value='${p.conditionRating}'/>"
                                                    data-purchase-price="${p.purchasePrice != null ? p.purchasePrice : 0}"
                                                    data-selling-price="${p.sellingPrice}"
                                                    data-quantity="${p.quantity}"
                                                    data-status="<c:out value='${p.status}'/>"
                                                    data-note="<c:out value='${p.note}'/>"
                                                    data-image-url="<c:out value='${not empty p.imageUrl ? p.imageUrl : p.book.coverUrl}'/>">
                                                <i class="fa-solid fa-pen me-1"></i>Sửa
                                            </button>

                                            <!-- Nút Gỡ bán (Xóa vĩnh viễn) -->
                                            <button type="button" class="btn btn-sm btn-outline-danger px-2 py-1"
                                                    onclick="confirmDeleteProduct(${p.id}, '<c:out value="${p.book.title}"/>')"
                                                    title="Gỡ bán và xóa vĩnh viễn sản phẩm khỏi gian hàng">
                                                <i class="fa-solid fa-trash me-1"></i>Gỡ bán
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty products}">
                                <tr><td colspan="7" class="text-center text-muted py-5"><i class="fa-solid fa-inbox fa-3x mb-2 text-secondary opacity-50"></i><p class="mb-0">Chưa có sản phẩm sách cũ nào trong gian hàng</p></td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Modal Xác Nhận Gỡ Bán Vĩnh Viễn -->
            <div class="modal fade" id="deleteProductModal" tabindex="-1">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content">
                        <form id="deleteProductForm" method="post" action="">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                            <div class="modal-header bg-danger text-white">
                                <h5 class="modal-title fw-bold"><i class="fa-solid fa-triangle-exclamation me-2"></i>Xác Nhận Gỡ Bán Vĩnh Viễn</h5>
                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <p class="mb-2">Bạn có chắc chắn muốn <strong>gỡ bán và xóa vĩnh viễn</strong> sản phẩm này khỏi gian hàng không?</p>
                                <div class="alert alert-secondary py-2 mb-2">
                                    <i class="fa-solid fa-book text-primary me-2"></i><strong id="deleteProductTitle"></strong>
                                </div>
                                <p class="text-danger small mb-0"><i class="fa-solid fa-circle-exclamation me-1"></i>Hành động này sẽ xóa sản phẩm khỏi gian hàng của bạn và không thể khôi phục.</p>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                <button type="submit" class="btn btn-danger fw-bold"><i class="fa-solid fa-trash me-1"></i>Gỡ Bán Vĩnh Viễn</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Modal Create Master Book & Copy -->
            <div class="modal fade" id="createMasterBookModal" tabindex="-1">
                <div class="modal-dialog modal-lg">
                    <div class="modal-content">
                        <form action="/vendor/create-master-book?${_csrf.parameterName}=${_csrf.token}" method="post" enctype="multipart/form-data">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                            <div class="modal-header bg-success text-white">
                                <h5 class="modal-title fw-bold"><i class="fa-solid fa-book-medical me-2"></i>Thêm Đầu Sách Mới Vào Gian Hàng</h5>
                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="alert alert-info py-2 small mb-3">
                                    <i class="fa-solid fa-circle-info me-1"></i>
                                    Sách mới tạo sẽ được lưu trực tiếp vào gian hàng ở trạng thái <strong>Chưa đăng bán</strong>. Sách sẽ <strong>chưa hiển thị lên website</strong> cho đến khi bạn bấm <strong>Đăng bán</strong>.
                                </div>
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
                                
                                <h6 class="fw-bold text-success border-bottom pb-2 mt-4 mb-3">
                                    <i class="fa-solid fa-store me-1"></i>Thông Tin Bán Của Gian Hàng
                                </h6>
                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Giá Bán Ra (VNĐ) *</label>
                                        <input type="number" min="0" name="sellingPrice" class="form-control" placeholder="Ví dụ: 65000" required />
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Giá Mua Vào (VNĐ)</label>
                                        <input type="number" min="0" name="purchasePrice" class="form-control" placeholder="Ví dụ: 40000" />
                                    </div>
                                </div>
                                <div class="row g-3 mb-3">
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Tình Trạng Sách</label>
                                        <select class="form-select" name="conditionRating">
                                            <c:forEach var="c" items="${conditions}">
                                                <option value="${c}">${c}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold">Số Lượng Tồn Kho *</label>
                                        <input type="number" min="1" name="quantity" class="form-control" value="1" required />
                                    </div>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Ghi Chú Tình Trạng Thực Tế</label>
                                    <textarea name="note" class="form-control" rows="2" placeholder="Ghi chú về ố vàng, bìa sờn, gáy sách..."></textarea>
                                </div>
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Link Ảnh Bìa / Upload Ảnh Bìa</label>
                                    <input type="text" name="coverUrl" class="form-control mb-2" placeholder="https://..." />
                                    <input type="file" name="coverFile" class="form-control" accept="image/*" />
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                <button type="submit" class="btn btn-success fw-bold">
                                    <i class="fa-solid fa-floppy-disk me-1"></i>Lưu Vào Gian Hàng
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Modal Add / Edit Product Copy -->
            <div class="modal fade" id="productModal">
                <div class="modal-dialog modal-lg">
                    <form class="modal-content" method="post" action="/vendor/products/save?${_csrf.parameterName}=${_csrf.token}" enctype="multipart/form-data">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                        <input type="hidden" name="id" id="productId">
                        
                        <div class="modal-header">
                            <h5 class="modal-title fw-bold" id="modalTitle">Đăng Bán Sách Cũ</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <div class="row g-3">
                                <!-- Chế độ Thêm mới: Chọn đầu sách từ dropdown (mỗi đầu sách chỉ hiện 1 lần) -->
                                <div class="col-12" id="addBookSection">
                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                        <label class="form-label mb-0 fw-bold">Chọn Đầu Sách *</label>
                                        <small class="text-primary"><i class="fa-solid fa-plus-circle me-1"></i>Chưa thấy đầu sách bạn cần? <a href="#" data-bs-toggle="modal" data-bs-target="#createMasterBookModal" data-bs-dismiss="modal" class="fw-bold">Tạo đầu sách mới</a></small>
                                    </div>
                                    <select class="form-select" name="bookId" id="addBookId" onchange="checkExistingMatch()">
                                        <c:forEach var="b" items="${allBooks}">
                                            <option value="${b.id}" data-title="<c:out value='${b.title}'/>">${b.title} - ${b.isbn != null ? b.isbn : 'N/A'}</option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <!-- Chế độ Chỉnh sửa: Hiển thị sách cố định, không chọn đổi đầu sách khác -->
                                <div class="col-12" id="editBookSection" style="display: none;">
                                    <label class="form-label mb-1 fw-bold">Sản phẩm sách đang chỉnh sửa</label>
                                    <div class="p-2 border rounded bg-light d-flex align-items-center">
                                        <i class="fa-solid fa-book-open text-primary me-2 fa-lg"></i>
                                        <div>
                                            <div class="fw-bold text-dark" id="editBookTitleDisplay"></div>
                                            <div class="small text-muted" id="editBookIsbnDisplay"></div>
                                        </div>
                                    </div>
                                    <input type="hidden" name="bookId" id="editBookId" disabled />
                                </div>

                                <!-- Banner thông báo tự động điền & cộng dồn số lượng khi trùng đầu sách + tình trạng -->
                                <div class="col-12" id="duplicateNotice" style="display: none;">
                                    <div class="alert alert-warning py-2 px-3 small mb-0 rounded-3 shadow-xs border-warning">
                                        <div class="fw-bold mb-1"><i class="fa-solid fa-circle-info me-1"></i>Đã có sản phẩm này trong gian hàng!</div>
                                        <div id="duplicateNoticeText"></div>
                                    </div>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-bold">Tình trạng sách cũ *</label>
                                    <select class="form-select" name="conditionRating" id="conditionRating" onchange="if(!document.getElementById('productId').value) checkExistingMatch();" required>
                                        <c:forEach var="c" items="${conditions}">
                                            <option value="${c}">${c}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-bold">Trạng thái</label>
                                    <select class="form-select" name="status" id="status" onchange="if(!document.getElementById('productId').value) checkExistingMatch();">
                                        <option value="UNPUBLISHED">UNPUBLISHED (Chưa đăng bán - Chỉ hiện gian hàng)</option>
                                        <option value="AVAILABLE">AVAILABLE (Đang bán - Hiển thị lên web)</option>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-bold">Giá mua vào (VNĐ)</label>
                                    <input class="form-control" type="number" min="0" name="purchasePrice" id="purchasePrice">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-bold">Giá bán ra (VNĐ) *</label>
                                    <input class="form-control" type="number" min="0" name="sellingPrice" id="sellingPrice" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-bold">Số lượng tồn *</label>
                                    <input class="form-control" type="number" min="1" name="quantity" id="quantity" value="1" required>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-bold">Mô tả tình trạng thực tế *</label>
                                    <textarea class="form-control" name="note" id="note" required placeholder="Ghi chú về ố vàng, bìa sờn, gáy sách..."></textarea>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-bold">Ảnh sản phẩm (Bìa / Thực tế)</label>
                                    <div id="currentImagePreviewContainer" class="mb-2" style="display: none;">
                                        <span class="small text-muted d-block mb-1">Ảnh hiện tại của sách:</span>
                                        <img id="currentImagePreview" src="" width="60" height="80" class="rounded border shadow-xs" style="object-fit: cover;" alt="Ảnh hiện tại" />
                                    </div>
                                    <input class="form-control" type="file" name="imageFile" accept="image/*">
                                    <small class="text-muted">Tải ảnh mới để cập nhật ảnh sản phẩm hiển thị trên gian hàng và trang chủ</small>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                            <button class="btn btn-primary fw-bold" type="submit">
                                <i class="fa-solid fa-floppy-disk me-1"></i>Lưu Sản Phẩm
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <script>
            // Danh sách sản phẩm hiện tại trong gian hàng của vendor
            const existingVendorProducts = [
                <c:forEach var="p" items="${products}" varStatus="loop">
                {
                    id: ${p.id},
                    bookId: ${p.book.id},
                    bookTitle: '<c:out value="${p.book.title}"/>',
                    condition: '<c:out value="${p.conditionRating}"/>',
                    sellingPrice: ${p.sellingPrice != null ? p.sellingPrice : 0},
                    purchasePrice: ${p.purchasePrice != null ? p.purchasePrice : 0},
                    quantity: ${p.quantity != null ? p.quantity : 0},
                    note: '<c:out value="${p.note != null ? p.note : ''}" />',
                    imageUrl: '<c:out value="${not empty p.imageUrl ? p.imageUrl : p.book.coverUrl}" />',
                    status: '<c:out value="${p.status}"/>'
                }<c:if test="${!loop.last}">,</c:if>
                </c:forEach>
            ];

            // Kiểm tra trùng đầu sách + tình trạng khi ở chế độ Đăng Bán (Add)
            function checkExistingMatch() {
                const isAddMode = !document.getElementById('productId').value;
                if (!isAddMode) return;

                const bookIdEl = document.getElementById('addBookId');
                if (!bookIdEl || !bookIdEl.value) return;

                const selectedBookId = bookIdEl.value;
                const selectedCondition = document.getElementById('conditionRating').value;
                const selectedStatus = document.getElementById('status').value;
                const selectedOption = bookIdEl.options[bookIdEl.selectedIndex];
                const selectedTitle = selectedOption ? (selectedOption.getAttribute('data-title') || '').trim().toLowerCase() : '';

                // Tìm sản phẩm đang bán (AVAILABLE/RESERVED) và chờ đăng bán (UNPUBLISHED)
                const availableMatch = existingVendorProducts.find(p => 
                    (p.bookId == selectedBookId || (selectedTitle && p.bookTitle && p.bookTitle.trim().toLowerCase() === selectedTitle))
                    && p.condition === selectedCondition
                    && (p.status === 'AVAILABLE' || p.status === 'RESERVED')
                );

                const unpublishedMatch = existingVendorProducts.find(p => 
                    (p.bookId == selectedBookId || (selectedTitle && p.bookTitle && p.bookTitle.trim().toLowerCase() === selectedTitle))
                    && p.condition === selectedCondition
                    && p.status === 'UNPUBLISHED'
                );

                const noticeBox = document.getElementById('duplicateNotice');
                const noticeText = document.getElementById('duplicateNoticeText');

                if (selectedStatus === 'AVAILABLE') {
                    if (availableMatch) {
                        noticeBox.style.display = 'block';
                        noticeText.innerHTML = 'Đầu sách này với tình trạng <strong>' + selectedCondition + '</strong> đã có <strong>' + availableMatch.quantity + ' cuốn</strong> đang bán trên web (Giá bán: <strong>' + Number(availableMatch.sellingPrice).toLocaleString('vi-VN') + ' ₫</strong>). Giá và mô tả đã được tự động điền. Số lượng nhập sẽ được <strong>cộng thẳng vào sản phẩm đang bán</strong>.';
                        document.getElementById('sellingPrice').value = availableMatch.sellingPrice;
                        document.getElementById('purchasePrice').value = availableMatch.purchasePrice;
                        document.getElementById('note').value = availableMatch.note;
                        document.getElementById('quantity').value = 1;
                    } else {
                        noticeBox.style.display = 'none';
                    }
                } else if (selectedStatus === 'UNPUBLISHED') {
                    if (availableMatch || unpublishedMatch) {
                        noticeBox.style.display = 'block';
                        let infoStr = availableMatch ? ('Đang có <strong>' + availableMatch.quantity + ' cuốn</strong> đang bán trên web') : ('Đang có <strong>' + unpublishedMatch.quantity + ' cuốn</strong> đang chờ đăng bán');
                        noticeText.innerHTML = 'Đầu sách này (' + infoStr + '). Khi bạn chọn <strong>Chưa đăng bán</strong>, sản phẩm sẽ ở trạng thái chờ (chưa hiện lên web giống lúc nhập đầu sách mới). Khi bạn bấm <strong>Đăng bán</strong>, số lượng sẽ được <strong>cộng dồn</strong> vào sản phẩm đang bán.';
                        const ref = availableMatch || unpublishedMatch;
                        if (ref) {
                            document.getElementById('sellingPrice').value = ref.sellingPrice;
                            document.getElementById('purchasePrice').value = ref.purchasePrice;
                            document.getElementById('note').value = ref.note;
                        }
                        document.getElementById('quantity').value = 1;
                    } else {
                        noticeBox.style.display = 'none';
                    }
                } else {
                    noticeBox.style.display = 'none';
                }
            }

            // Mở modal thêm sách cũ
            function openAddModal() {
                document.getElementById('productId').value = '';
                document.getElementById('modalTitle').innerText = 'Đăng Bán Sách Cũ';
                
                // Hiển thị phần chọn đầu sách, ẩn phần sách cố định
                document.getElementById('addBookSection').style.display = 'block';
                document.getElementById('addBookId').disabled = false;
                document.getElementById('editBookSection').style.display = 'none';
                document.getElementById('editBookId').disabled = true;

                // Xóa option RESERVED nếu có từ lần sửa trước
                let reservedOpt = document.getElementById('status-opt-reserved');
                if (reservedOpt) {
                    reservedOpt.remove();
                }

                document.getElementById('currentImagePreviewContainer').style.display = 'none';
                document.getElementById('status').value = 'UNPUBLISHED';
                document.getElementById('quantity').value = '1';

                checkExistingMatch();

                var modal = new bootstrap.Modal(document.getElementById('productModal'));
                modal.show();
            }

            // Mở modal sửa sách cụ thể (khóa cố định đầu sách, không cho đổi)
            function openEditModal(id, bookId, bookTitle, bookIsbn, condition, purchasePrice, sellingPrice, quantity, status, note, imageUrl) {
                document.getElementById('productId').value = id;
                document.getElementById('modalTitle').innerText = 'Chỉnh Sửa Sản Phẩm Sách Cũ';

                // Ẩn dropdown chọn sách, hiển thị thông tin sách cố định
                document.getElementById('addBookSection').style.display = 'none';
                document.getElementById('addBookId').disabled = true;
                document.getElementById('editBookSection').style.display = 'block';
                document.getElementById('editBookId').disabled = false;
                document.getElementById('editBookId').value = bookId;
                document.getElementById('editBookTitleDisplay').innerText = bookTitle;
                document.getElementById('editBookIsbnDisplay').innerText = 'ISBN: ' + (bookIsbn || 'N/A');

                // Nếu sản phẩm đang sửa là RESERVED, thêm option tạm để hiển thị
                let reservedOpt = document.getElementById('status-opt-reserved');
                if (status === 'RESERVED') {
                    if (!reservedOpt) {
                        reservedOpt = document.createElement('option');
                        reservedOpt.id = 'status-opt-reserved';
                        reservedOpt.value = 'RESERVED';
                        reservedOpt.text = 'RESERVED (Tạm ẩn - Đang đóng băng)';
                        document.getElementById('status').appendChild(reservedOpt);
                    }
                } else if (reservedOpt) {
                    reservedOpt.remove();
                }

                // Hiển thị ảnh hiện tại nếu có
                const imgContainer = document.getElementById('currentImagePreviewContainer');
                const imgEl = document.getElementById('currentImagePreview');
                if (imageUrl && imageUrl.trim() !== '') {
                    imgEl.src = imageUrl;
                    imgContainer.style.display = 'block';
                } else {
                    imgContainer.style.display = 'none';
                }

                // Ẩn notice trùng
                document.getElementById('duplicateNotice').style.display = 'none';

                document.getElementById('conditionRating').value = condition;
                document.getElementById('purchasePrice').value = purchasePrice;
                document.getElementById('sellingPrice').value = sellingPrice;
                document.getElementById('quantity').value = quantity;
                document.getElementById('status').value = status;
                document.getElementById('note').value = note;

                var modal = new bootstrap.Modal(document.getElementById('productModal'));
                modal.show();
            }

            // Mở modal xác nhận gỡ bán vĩnh viễn
            function confirmDeleteProduct(productId, productTitle) {
                document.getElementById('deleteProductForm').action = '/vendor/products/' + productId + '/delete';
                document.getElementById('deleteProductTitle').innerText = productTitle;
                var modal = new bootstrap.Modal(document.getElementById('deleteProductModal'));
                modal.show();
            }

            // Gán sự kiện cho các nút Sửa trong bảng
            document.querySelectorAll('.product-edit-button').forEach(function (button) {
                button.addEventListener('click', function () {
                    openEditModal(
                        button.dataset.productId,
                        button.dataset.bookId,
                        button.dataset.bookTitle,
                        button.dataset.bookIsbn,
                        button.dataset.condition,
                        button.dataset.purchasePrice,
                        button.dataset.sellingPrice,
                        button.dataset.quantity,
                        button.dataset.status,
                        button.dataset.note,
                        button.dataset.imageUrl
                    );
                });
            });
            </script>
        </main>
    </div>
</div>
<jsp:include page="../../common/footer.jsp"/>
