<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="title" value="Nhà Vận Chuyển - Admin" scope="request" />
<jsp:include page="../../common/header.jsp" />

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp" />

    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp" />

        <div class="main-content container-fluid">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0"><i class="fa-solid fa-truck-fast text-primary me-2"></i>Quản Lý Nhà Vận Chuyển & Phí Giao Hàng</h3>
                <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addShippingModal">
                    <i class="fa-solid fa-plus me-1"></i> Thêm Nhà Vận Chuyển
                </button>
            </div>

            <div class="card border-0 shadow-sm rounded-3">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Tên Nhà Vận Chuyển</th>
                                    <th>Số Điện Thoại Hotline</th>
                                    <th>Phí Vận Chuyển Mặc Định</th>
                                    <th>Trạng Thái</th>
                                    <th class="text-end">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="p" items="${providers}">
                                    <tr>
                                        <td>${p.id}</td>
                                        <td class="fw-bold text-dark">${p.name}</td>
                                        <td>${p.phone}</td>
                                        <td class="fw-bold text-success"><fmt:formatNumber value="${p.baseFee}" pattern="#,##0 ₫" /></td>
                                        <td><span class="badge ${p.active ? 'bg-success' : 'bg-secondary'}">${p.active ? 'HOẠT ĐỘNG' : 'TẠM DỪNG'}</span></td>
                                        <td class="text-end">
                                            <form action="/admin/shipping/delete/${p.id}" method="post" class="d-inline" onsubmit="return confirm('Bạn có chắc chắn muốn xóa?')"><button class="btn btn-sm btn-outline-danger"><i class="fa-solid fa-trash"></i></button></form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Modal Add Shipping Provider -->
            <div class="modal fade" id="addShippingModal" tabindex="-1">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <form action="/admin/shipping/save" method="post">
                            <div class="modal-header">
                                <h5 class="modal-title fw-bold">Thêm Nhà Vận Chuyển</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="mb-3">
                                    <label class="form-label">Tên Đơn Vị Vận Chuyển</label>
                                    <input type="text" name="name" class="form-control" placeholder="Giao Hàng Nhanh (GHN)" required />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Hotline</label>
                                    <input type="text" name="phone" class="form-control" placeholder="19001234" />
                                </div>
                                <div class="mb-3">
                                    <label class="form-label">Cước Phí Cơ Bản (VNĐ)</label>
                                    <input type="number" name="baseFee" class="form-control" value="25000" required />
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                <button type="submit" class="btn btn-primary">Lưu Nhà Vận Chuyển</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../../common/footer.jsp" />
