<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="title" value="Chiết Khấu & Voucher - Admin" scope="request" />
<jsp:include page="../../common/header.jsp" />

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp" />

    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp" />

        <div class="main-content container-fluid">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0"><i class="fa-solid fa-ticket text-primary me-2"></i>Quản Lý Chiết Khấu App & Voucher Hệ Thống</h3>
                <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addDiscountModal">
                    <i class="fa-solid fa-plus me-1"></i> Tạo Mã Voucher Mới
                </button>
            </div>

            <div class="card border-0 shadow-sm rounded-3">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Mã Code</th>
                                    <th>% Giảm</th>
                                    <th>Giảm Tối Đa</th>
                                    <th>Đơn Tối Thiểu</th>
                                    <th>Trạng Thái</th>
                                    <th class="text-end">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="d" items="${discounts}">
                                    <tr>
                                        <td>${d.id}</td>
                                        <td class="fw-bold text-primary"><code>${d.code}</code></td>
                                        <td class="fw-bold text-success">${d.discountPercent}%</td>
                                        <td><fmt:formatNumber value="${d.maxDiscountAmount}" pattern="#,##0 ₫" /></td>
                                        <td><fmt:formatNumber value="${d.minOrderValue}" pattern="#,##0 ₫" /></td>
                                        <td><span class="badge ${d.active ? 'bg-success' : 'bg-secondary'}">${d.active ? 'ĐANG ÁP DỤNG' : 'HẾT HẠN'}</span></td>
                                        <td class="text-end">
                                            <form action="/admin/discounts/delete/${d.id}" method="post" class="d-inline" onsubmit="return confirm('Bạn có chắc chắn muốn xóa mã này?')"><button class="btn btn-sm btn-outline-danger"><i class="fa-solid fa-trash"></i></button></form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Modal Add Discount -->
            <div class="modal fade" id="addDiscountModal" tabindex="-1">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <form action="/admin/discounts/save" method="post">
                            <div class="modal-header">
                                <h5 class="modal-title fw-bold">Tạo Mã Voucher / Chiết Khấu App</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="mb-3">
                                    <label class="form-label">Mã Code (Voucher)</label>
                                    <input type="text" name="code" class="form-control text-uppercase fw-bold" placeholder="SACHCU10" required />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">% Giảm Giá</label>
                                    <input type="number" step="0.1" name="discountPercent" class="form-control" value="10" required />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Số Tiền Giảm Tối Đa (VNĐ)</label>
                                    <input type="number" name="maxDiscountAmount" class="form-control" value="30000" />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Giá Trị Đơn Hàng Tối Thiểu (VNĐ)</label>
                                    <input type="number" name="minOrderValue" class="form-control" value="100000" />
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                <button type="submit" class="btn btn-primary">Tạo Mã Voucher</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../../common/footer.jsp" />
