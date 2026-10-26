<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="title" value="Tất Cả Đơn Hàng - Admin" scope="request" />
<jsp:include page="../../common/header.jsp" />

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp" />

    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp" />

        <div class="main-content container-fluid">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0"><i class="fa-solid fa-boxes-packing text-primary me-2"></i>Giám Sát Tất Cả Đơn Hàng Toàn Chuỗi</h3>
            </div>

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fa-solid fa-circle-check me-2"></i><c:out value="${successMessage}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-warning alert-dismissible fade show" role="alert">
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
                                    <th>Mã Đơn</th>
                                    <th>Người Nhận</th>
                                    <th>Địa Chỉ Giao</th>
                                    <th>Chi Nhánh Cửa Hàng</th>
                                    <th>Tổng Tiền</th>
                                    <th>Trạng Thái Đơn</th>
                                    <th class="text-end">Thao Tác / Phân Shipper</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="o" items="${orders}">
                                    <tr>
                                        <td class="fw-bold text-primary">${o.orderCode}</td>
                                        <td>
                                            <div class="fw-bold"><c:out value="${o.receiverName}"/></div>
                                            <span class="text-muted small">${o.receiverPhone}</span>
                                        </td>
                                        <td class="small" style="max-width: 200px;"><c:out value="${o.shippingAddress}"/></td>
                                        <td><span class="badge bg-secondary"><c:out value="${o.branch.name}"/></span></td>
                                        <td class="fw-bold text-dark"><fmt:formatNumber value="${o.finalAmount}" pattern="#,##0 ₫" /></td>
                                        <td>
                                            <form action="/admin/orders/update-status" method="post" class="d-inline">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                <input type="hidden" name="orderId" value="${o.id}" />
                                                <select name="status" class="form-select form-select-sm" onchange="this.form.submit()">
                                                    <option value="NEW" ${o.orderStatus == 'NEW' ? 'selected' : ''}>MỚI (NEW)</option>
                                                    <option value="CONFIRMED" ${o.orderStatus == 'CONFIRMED' ? 'selected' : ''}>ĐÃ XÁC NHẬN</option>
                                                    <option value="PACKING" ${o.orderStatus == 'PACKING' ? 'selected' : ''}>ĐANG ĐÓNG GÓI</option>
                                                    <option value="READY_FOR_PICKUP" ${o.orderStatus == 'READY_FOR_PICKUP' ? 'selected' : ''}>SẴN SÀNG LẤY</option>
                                                    <option value="SHIPPING" ${o.orderStatus == 'SHIPPING' ? 'selected' : ''}>ĐANG GIAO</option>
                                                    <option value="DELIVERED" ${o.orderStatus == 'DELIVERED' ? 'selected' : ''}>ĐÃ GIAO</option>
                                                    <option value="CANCELLED" ${o.orderStatus == 'CANCELLED' ? 'selected' : ''}>ĐÃ HỦY</option>
                                                </select>
                                            </form>
                                        </td>
                                        <td class="text-end">
                                            <c:choose>
                                                <c:when test="${o.orderStatus == 'CANCELLED'}">
                                                    <form action="/admin/orders/${o.id}/delete" method="post" class="d-inline"
                                                          onsubmit="return confirm('Xóa vĩnh viễn đơn hàng đã hủy ${o.orderCode}? Đơn sẽ biến mất khỏi lịch sử của người dùng.')">
                                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                        <button type="submit" class="btn btn-sm btn-danger">
                                                            <i class="fa-solid fa-trash-can me-1"></i>Xóa Đơn
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:when test="${o.orderStatus == 'READY_FOR_PICKUP' || o.orderStatus == 'RETURN_REQUESTED' || o.orderStatus == 'RETURNED'}">
                                                    <button class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#assignModal${o.id}">
                                                        <i class="fa-solid fa-truck-ramp-box me-1"></i> Gán Shipper
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-light text-secondary border">Chưa thể gán Shipper</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>

                                    <!-- Modal Assign Shipper -->
                                    <c:if test="${o.orderStatus == 'READY_FOR_PICKUP' || o.orderStatus == 'RETURN_REQUESTED' || o.orderStatus == 'RETURNED'}">
                                    <div class="modal fade" id="assignModal${o.id}" tabindex="-1">
                                        <div class="modal-dialog">
                                            <div class="modal-content text-start">
                                                <form action="/admin/orders/assign-shipper" method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                    <input type="hidden" name="orderId" value="${o.id}" />
                                                    <div class="modal-header">
                                                        <h5 class="modal-title fw-bold">Phân Công Shipper Giao Đơn: ${o.orderCode}</h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div class="mb-3">
                                                            <label class="form-label">Chọn Shipper Giao Hàng</label>
                                                            <select name="shipperId" class="form-select" required>
                                                                <c:forEach var="s" items="${shippers}">
                                                                    <option value="${s.id}"><c:out value="${s.fullName}"/> (<c:out value="${s.phone}"/>) - Chi Nhánh: <c:out value="${s.branch != null ? s.branch.name : 'Chung'}"/></option>
                                                                </c:forEach>
                                                            </select>
                                                        </div>

                                                        <div class="mb-3">
                                                            <label class="form-label">Ghi Chú Cho Shipper</label>
                                                            <textarea name="note" class="form-control" rows="2" placeholder="Ví dụ: Giao hàng giờ hành chính, gọi trước khi giao..."></textarea>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                                        <button type="submit" class="btn btn-primary">Xác Nhận Phân Công</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                    </c:if>
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
