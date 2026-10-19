<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="title" value="Quản Lý Sản Phẩm - Admin" scope="request" />
<jsp:include page="../../common/header.jsp" />

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp" />
    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp" />
        <div class="main-content container-fluid">
            <h3 class="fw-bold mb-4"><i class="fa-solid fa-book-open text-primary me-2"></i>Sản Phẩm Toàn Hệ Thống</h3>

            <c:if test="${not empty successMessage}"><div class="alert alert-success">${successMessage}</div></c:if>
            <c:if test="${not empty errorMessage}"><div class="alert alert-danger">${errorMessage}</div></c:if>

            <form action="/admin/products" method="get" class="card border-0 shadow-sm mb-4">
                <div class="card-body row g-2">
                    <div class="col-lg-4"><input name="keyword" value="${keyword}" class="form-control" placeholder="Tên sách, ISBN hoặc email người bán"></div>
                    <div class="col-lg-3">
                        <select name="branchId" class="form-select">
                            <option value="">Tất cả chi nhánh</option>
                            <c:forEach var="b" items="${branches}"><option value="${b.id}" ${selectedBranch == b.id ? 'selected' : ''}>${b.name}</option></c:forEach>
                        </select>
                    </div>
                    <div class="col-lg-2">
                        <select name="condition" class="form-select">
                            <option value="">Mọi tình trạng</option>
                            <c:forEach var="item" items="${conditions}"><option value="${item}" ${selectedCondition == item ? 'selected' : ''}>${item}</option></c:forEach>
                        </select>
                    </div>
                    <div class="col-lg-2">
                        <select name="status" class="form-select">
                            <option value="">Mọi trạng thái</option>
                            <c:forEach var="item" items="${statuses}"><option value="${item}" ${selectedStatus == item ? 'selected' : ''}>${item}</option></c:forEach>
                        </select>
                    </div>
                    <div class="col-lg-1 d-grid"><button class="btn btn-primary"><i class="fa-solid fa-filter"></i></button></div>
                </div>
            </form>

            <div class="card border-0 shadow-sm">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light"><tr><th>Sản phẩm</th><th>Chi nhánh</th><th>Người bán</th><th>Tình trạng</th><th>Giá</th><th>SL</th><th>Trạng thái</th><th class="text-end">Thao tác</th></tr></thead>
                        <tbody>
                            <c:forEach var="p" items="${products}">
                                <tr>
                                    <td><div class="fw-bold">${p.book.title}</div><small class="text-muted">ISBN: ${p.book.isbn}</small></td>
                                    <td>${p.branch.name}</td>
                                    <td>${p.seller != null ? p.seller.email : '-'}</td>
                                    <td>${p.conditionRating}</td>
                                    <td class="fw-bold text-success"><fmt:formatNumber value="${p.sellingPrice}" pattern="#,##0 ₫" /></td>
                                    <td>${p.quantity}</td>
                                    <td><span class="badge ${p.status == 'AVAILABLE' ? 'bg-success' : 'bg-secondary'}">${p.status}</span></td>
                                    <td class="text-end text-nowrap">
                                        <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#editProduct${p.id}"><i class="fa-solid fa-pen"></i></button>
                                        <form action="/admin/products/${p.id}/toggle" method="post" class="d-inline">
                                            <button class="btn btn-sm btn-outline-warning" title="Đổi trạng thái"><i class="fa-solid fa-power-off"></i></button>
                                        </form>
                                    </td>
                                </tr>
                                <div class="modal fade" id="editProduct${p.id}" tabindex="-1">
                                    <div class="modal-dialog"><div class="modal-content">
                                        <form action="/admin/products/${p.id}/update" method="post">
                                            <div class="modal-header"><h5 class="modal-title fw-bold">Cập nhật ${p.book.title}</h5><button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
                                            <div class="modal-body">
                                                <div class="mb-3"><label class="form-label">Giá bán</label><input type="number" min="0" step="1000" name="sellingPrice" value="${p.sellingPrice}" class="form-control" required></div>
                                                <div class="mb-3"><label class="form-label">Số lượng</label><input type="number" min="0" name="quantity" value="${p.quantity}" class="form-control" required></div>
                                                <div class="mb-3"><label class="form-label">Trạng thái</label><select name="status" class="form-select"><c:forEach var="item" items="${statuses}"><option value="${item}" ${p.status == item ? 'selected' : ''}>${item}</option></c:forEach></select></div>
                                            </div>
                                            <div class="modal-footer"><button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button><button class="btn btn-primary">Lưu</button></div>
                                        </form>
                                    </div></div>
                                </div>
                            </c:forEach>
                            <c:if test="${empty products}"><tr><td colspan="8" class="text-center text-muted py-5">Không có sản phẩm phù hợp.</td></tr></c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
<jsp:include page="../../common/footer.jsp" />
