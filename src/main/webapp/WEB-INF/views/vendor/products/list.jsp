<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %><%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="title" value="Sản phẩm Vendor" scope="request"/><jsp:include page="../../common/header.jsp"/>
<div class="d-flex"><jsp:include page="../../common/sidebar.jsp"/><div class="flex-grow-1"><jsp:include page="../../common/navbar.jsp"/><main class="main-content container-fluid">
<div class="d-flex justify-content-between mb-4"><h3 class="fw-bold">Sản phẩm sách cũ</h3><button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#productModal"><i class="fa-solid fa-plus me-1"></i>Thêm sản phẩm</button></div>
<c:if test="${not empty successMessage}"><div class="alert alert-success">${successMessage}</div></c:if><c:if test="${not empty errorMessage}"><div class="alert alert-danger">${errorMessage}</div></c:if>
<div class="card border-0 shadow-sm"><div class="table-responsive"><table class="table table-hover align-middle mb-0"><thead><tr><th>Ảnh</th><th>Sách</th><th>Tình trạng</th><th>Giá</th><th>Tồn</th><th>Trạng thái</th><th></th></tr></thead><tbody>
<c:forEach var="p" items="${products}"><tr><td><img src="${not empty p.imageUrl ? p.imageUrl : p.book.coverUrl}" width="48" height="64" class="rounded" style="object-fit:cover" alt="Ảnh sách"></td><td><strong>${p.book.title}</strong><div class="small text-muted">${p.book.isbn}</div></td><td>${p.conditionRating}<div class="small text-muted">${p.note}</div></td><td><fmt:formatNumber value="${p.sellingPrice}" pattern="#,#00 ₫"/></td><td>${p.quantity}</td><td><span class="badge ${p.status == 'AVAILABLE' ? 'bg-success' : 'bg-secondary'}">${p.status}</span></td><td><div class="d-flex gap-1"><button class="btn btn-sm btn-outline-primary" onclick="openEditModal(${p.id}, ${p.book.id}, '${p.conditionRating}', ${p.purchasePrice != null ? p.purchasePrice : 0}, ${p.sellingPrice}, ${p.quantity}, '${p.status}', '${p.note != null ? p.note.replace("'", "\\'") : ''}')"><i class="fa-solid fa-pen me-1"></i>Sửa</button><form method="post" action="/vendor/products/${p.id}/toggle"><button class="btn btn-sm btn-outline-secondary">Ẩn/Hiện</button></form></div></td></tr></c:forEach>
<c:if test="${empty products}"><tr><td colspan="7" class="text-center text-muted py-4">Chưa có sản phẩm</td></tr></c:if></tbody></table></div></div>
<div class="modal fade" id="productModal"><div class="modal-dialog modal-lg"><form class="modal-content" method="post" action="/vendor/products/save" enctype="multipart/form-data"><input type="hidden" name="id" id="productId"><div class="modal-header"><h5 class="modal-title" id="modalTitle">Thêm sản phẩm sách cũ</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div><div class="modal-body"><div class="row g-3">
<div class="col-12"><label class="form-label">Đầu sách</label><select class="form-select" name="bookId" id="bookId" required><c:forEach var="b" items="${allBooks}"><option value="${b.id}">${b.title} - ${b.isbn}</option></c:forEach></select></div>
<div class="col-md-6"><label class="form-label">Tình trạng</label><select class="form-select" name="conditionRating" id="conditionRating" required><c:forEach var="c" items="${conditions}"><option value="${c}">${c}</option></c:forEach></select></div>
<div class="col-md-6"><label class="form-label">Trạng thái</label><select class="form-select" name="status" id="status"><option value="AVAILABLE">AVAILABLE</option><option value="RESERVED">HIDDEN/RESERVED</option></select></div>
<div class="col-md-4"><label class="form-label">Giá nhập</label><input class="form-control" type="number" min="0" name="purchasePrice" id="purchasePrice"></div><div class="col-md-4"><label class="form-label">Giá bán</label><input class="form-control" type="number" min="0" name="sellingPrice" id="sellingPrice" required></div><div class="col-md-4"><label class="form-label">Số lượng</label><input class="form-control" type="number" min="0" name="quantity" id="quantity" value="1" required></div>
<div class="col-12"><label class="form-label">Mô tả tình trạng thực tế</label><textarea class="form-control" name="note" id="note" required></textarea></div><div class="col-12"><label class="form-label">Ảnh thực tế</label><input class="form-control" type="file" name="imageFile" accept="image/*"></div>
</div></div><div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button><button class="btn btn-primary">Lưu</button></div></form></div></div>
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
</main></div></div><jsp:include page="../../common/footer.jsp"/>
