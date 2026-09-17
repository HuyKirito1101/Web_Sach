<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="title" value="Đơn Hàng Chi Nhánh - Manager" scope="request" />
<jsp:include page="../../common/header.jsp" />

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp" />

    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp" />

        <div class="main-content container-fluid">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0"><i class="fa-solid fa-receipt text-primary me-2"></i>Quản Lý Đơn Hàng Của Cửa Hàng</h3>
            </div>

            <div class="card border-0 shadow-sm rounded-3">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Mã Đơn</th>
                                    <th>Người Nhận</th>
                                    <th>Địa Chỉ Giao</th>
                                    <th>Tổng Tiền</th>
                                    <th>Trạng Thái Đơn</th>
                                    <th class="text-end">Phân Shipper Chi Nhánh</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="o" items="${orders}">
                                    <tr>
                                        <td class="fw-bold text-primary">${o.orderCode}</td>
                                        <td>
                                            <div class="fw-bold">${o.receiverName}</div>
                                            <span class="text-muted small">${o.receiverPhone}</span>
                                        </td>
                                        <td class="small">${o.shippingAddress}</td>
                                        <td class="fw-bold text-dark"><fmt:formatNumber value="${o.finalAmount}" pattern="#,##0 ₫" /></td>
                                        <td>
                                            <form action="/manager/orders/update-status" method="post" class="d-inline">
                                                <input type="hidden" name="orderId" value="${o.id}" />
                                                <select name="status" class="form-select form-select-sm" onchange="this.form.submit()">
                                                    <option value="NEW" ${o.orderStatus == 'NEW' ? 'selected' : ''}>NEW</option>
                                                    <option value="CONFIRMED" ${o.orderStatus == 'CONFIRMED' ? 'selected' : ''}>CONFIRMED</option>
                                                    <option value="PACKING" ${o.orderStatus == 'PACKING' ? 'selected' : ''}>PACKING</option>
                                                    <option value="READY_FOR_PICKUP" ${o.orderStatus == 'READY_FOR_PICKUP' ? 'selected' : ''}>READY_FOR_PICKUP</option>
                                                    <option value="SHIPPING" ${o.orderStatus == 'SHIPPING' ? 'selected' : ''}>SHIPPING</option>
                                                    <option value="DELIVERED" ${o.orderStatus == 'DELIVERED' ? 'selected' : ''}>DELIVERED</option>
                                                    <option value="CANCELLED" ${o.orderStatus == 'CANCELLED' ? 'selected' : ''}>CANCELLED</option>
                                                </select>
                                            </form>
                                        </td>
                                        <td class="text-end">
                                            <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#assignModal${o.id}">
                                                <i class="fa-solid fa-truck-fast me-1"></i> Phân Shipper
                                            </button>
                                        </td>
                                    </tr>

                                    <!-- Modal Assign Shipper -->
                                    <div class="modal fade" id="assignModal${o.id}" tabindex="-1">
                                        <div class="modal-dialog">
                                            <div class="modal-content text-start">
                                                <form action="/manager/orders/assign-shipper" method="post">
                                                    <input type="hidden" name="orderId" value="${o.id}" />
                                                    <div class="modal-header">
                                                        <h5 class="modal-title fw-bold">Phân Shipper Cho Đơn Hàng: ${o.orderCode}</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="mb-3">
                                                            <label class="form-label">Chọn Shipper Chi Nhánh</label>
                                                            <select name="shipperId" class="form-select" required>
                                                                <c:forEach var="s" items="${shippers}">
                                                                    <option value="${s.id}">${s.fullName} (${s.phone})</option>
                                                                </c:forEach>
                                                            </select>
                                                        </div>

                                                        <div class="mb-3">
                                                            <label class="form-label">Ghi Chú</label>
                                                            <textarea name="note" class="form-control" rows="2"></textarea>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                                        <button type="submit" class="btn btn-primary">Xác Nhận Phân Shipper</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../../common/footer.jsp" />
