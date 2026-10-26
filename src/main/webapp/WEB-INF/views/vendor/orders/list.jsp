<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="title" value="Đơn hàng Vendor" scope="request"/>
<jsp:include page="../../common/header.jsp"/>
<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp"/>
    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp"/>
        <main class="main-content container-fluid p-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0"><i class="fa-solid fa-boxes-packing text-warning me-2"></i>Đơn hàng cửa hàng</h3>
                <div class="d-flex align-items-center gap-2">
                    <a href="/vendor/returns" class="btn btn-sm btn-outline-warning rounded-pill fw-bold text-nowrap">
                        <i class="fa-solid fa-rotate-left me-1"></i> Quản lý Đổi Trả
                    </a>
                    <form class="d-flex align-items-center gap-2 mb-0">
                        <select name="status" class="form-select form-select-sm" onchange="this.form.submit()">
                            <option value="">Tất cả trạng thái</option>
                            <c:forEach var="s" items="${statuses}">
                                <option value="${s}" ${selectedStatus == s ? 'selected' : ''}>${s}</option>
                            </c:forEach>
                        </select>
                    </form>
                </div>
            </div>

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fa-solid fa-circle-check me-2"></i><c:out value="${successMessage}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <i class="fa-solid fa-circle-exclamation me-2"></i><c:out value="${errorMessage}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <div class="card border-0 shadow-sm rounded-3">
                <div class="table-responsive">
                    <table class="table align-middle table-hover mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Mã đơn</th>
                                <th>Người nhận / Khách hàng</th>
                                <th>Phương thức giao &amp; Đơn vị vận chuyển</th>
                                <th>Tổng tiền</th>
                                <th>Thanh toán</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="o" items="${orders}">
                                <c:set var="da" value="${assignments[o.id]}"/>
                                <tr>
                                    <td>
                                        <a href="/vendor/orders/${o.id}" class="fw-bold text-decoration-none text-primary">
                                            ${o.orderCode}
                                        </a>
                                        <c:if test="${o.orderStatus == 'RETURN_REQUESTED' || o.orderStatus == 'RETURNED' || o.orderStatus == 'REFUNDED'}">
                                            <div><span class="badge bg-warning text-dark" style="font-size: 10px;"><i class="fa-solid fa-rotate-left me-1"></i>Đổi trả</span></div>
                                        </c:if>
                                    </td>
                                    <td>
                                        <div class="fw-bold text-dark"><c:out value="${o.receiverName}"/></div>
                                        <div class="small text-muted"><i class="fa-solid fa-phone me-1"></i><c:out value="${o.receiverPhone}"/></div>
                                        <c:if test="${not empty o.returnAddress}">
                                            <div class="small text-danger mt-1"><i class="fa-solid fa-location-dot me-1"></i>Hoàn trả: <c:out value="${o.returnAddress}"/></div>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${o.shippingProvider != null}">
                                                <div class="fw-bold text-dark small mb-1"><c:out value="${o.shippingProvider.name}"/></div>
                                                <c:choose>
                                                    <c:when test="${o.shippingProvider.code == 'GHN_EXPRESS'}">
                                                        <span class="badge bg-danger"><i class="fa-solid fa-bolt me-1"></i>GHN Hỏa Tốc (Trong tỉnh)</span>
                                                    </c:when>
                                                    <c:when test="${o.shippingProvider.code == 'SPX_EXPRESS'}">
                                                        <span class="badge bg-warning text-dark"><i class="fa-solid fa-globe me-1"></i>SPX Express (Ngoại tỉnh)</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-primary"><i class="fa-solid fa-house me-1"></i>GHN Tiêu Chuẩn (Trong tỉnh)</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary">Mặc định</span>
                                            </c:otherwise>
                                        </c:choose>

                                        <%-- Thông tin Shipper / Đơn vị giao vận --%>
                                        <div class="mt-2">
                                            <c:choose>
                                                <%-- Đơn hàng chưa đến bước phân công (Mới đặt, Đang chuẩn bị, Đang đóng gói) --%>
                                                <c:when test="${o.orderStatus == 'NEW' || o.orderStatus == 'CONFIRMED' || o.orderStatus == 'PACKING'}">
                                                    <span class="badge bg-secondary text-white p-1" style="font-size: 11px;">
                                                        <i class="fa-solid fa-user-clock me-1"></i>Chưa phân công shipper
                                                    </span>
                                                </c:when>

                                                <%-- Shipper người cụ thể của chi nhánh --%>
                                                <c:when test="${not empty da && not empty da.shipper}">
                                                    <c:choose>
                                                        <c:when test="${da.status == 'ASSIGNED'}">
                                                            <span class="badge bg-warning text-dark p-1" style="font-size: 11px;">
                                                                <i class="fa-solid fa-clock me-1"></i>Chờ nhận: <c:out value="${da.shipper.fullName}"/>
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${da.status == 'ACCEPTED'}">
                                                            <span class="badge bg-info text-dark p-1" style="font-size: 11px;">
                                                                <i class="fa-solid fa-check me-1"></i>Đã nhận đơn: <c:out value="${da.shipper.fullName}"/>
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${da.status == 'PICKED_UP'}">
                                                            <span class="badge bg-primary text-white p-1" style="font-size: 11px;">
                                                                <i class="fa-solid fa-box me-1"></i>Đã lấy hàng: <c:out value="${da.shipper.fullName}"/>
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${da.status == 'SHIPPING'}">
                                                            <span class="badge bg-info text-dark p-1" style="font-size: 11px;">
                                                                <i class="fa-solid fa-motorcycle me-1"></i>Đang giao: <c:out value="${da.shipper.fullName}"/>
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${da.status == 'DELIVERED'}">
                                                            <span class="badge bg-success text-white p-1" style="font-size: 11px;">
                                                                <i class="fa-solid fa-circle-check me-1"></i>Giao xong: <c:out value="${da.shipper.fullName}"/>
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${da.status == 'CANCELLED'}">
                                                            <div class="alert alert-danger py-1 px-2 mb-1 text-start" style="font-size: 11px;">
                                                                <i class="fa-solid fa-triangle-exclamation text-danger me-1"></i><strong>Shipper ${da.shipper.fullName} từ chối:</strong>
                                                                <div><c:out value="${da.failureReason}"/></div>
                                                                <div class="mt-1 text-danger fw-bold">Cần phân công lại!</div>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary p-1" style="font-size: 11px;">${da.status}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary text-white p-1" style="font-size: 11px;">
                                                        <i class="fa-solid fa-user-clock me-1"></i>Chưa phân công shipper
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                    <td class="fw-bold text-danger">
                                        <fmt:formatNumber value="${o.finalAmount}" pattern="#,#00 ₫"/>
                                    </td>
                                    <td>
                                        <span class="badge bg-light text-dark border">${o.paymentMethod}</span>
                                        <div class="small text-muted mt-1">${o.paymentStatus}</div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${o.orderStatus == 'RETURN_REQUESTED'}">
                                                <span class="badge bg-warning text-dark"><i class="fa-solid fa-clock-rotate-left me-1"></i>Yêu cầu hoàn trả</span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'RETURNED'}">
                                                <span class="badge bg-info text-dark"><i class="fa-solid fa-warehouse me-1"></i>Đã về kho</span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'REFUNDED'}">
                                                <span class="badge bg-success"><i class="fa-solid fa-circle-check me-1"></i>Đã hoàn tiền</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-info text-dark">${o.orderStatus}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="d-flex flex-wrap gap-1 align-items-center">
                                            <c:if test="${o.orderStatus == 'NEW'}">
                                                <form method="post" action="/vendor/orders/${o.id}/status" class="d-inline">
                                                    <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                                    <button name="status" value="CONFIRMED" class="btn btn-sm btn-success rounded-pill fw-bold px-2">Xác nhận</button>
                                                    <button name="status" value="CANCELLED" class="btn btn-sm btn-outline-danger rounded-pill px-2">Hủy</button>
                                                </form>
                                            </c:if>

                                            <c:if test="${o.orderStatus == 'CONFIRMED'}">
                                                <form method="post" action="/vendor/orders/${o.id}/status" class="d-inline">
                                                    <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                                    <button name="status" value="PACKING" class="btn btn-sm btn-primary rounded-pill px-2">Chuẩn bị</button>
                                                    <button name="status" value="READY_FOR_PICKUP" class="btn btn-sm btn-warning rounded-pill px-2">Sẵn sàng lấy</button>
                                                </form>
                                            </c:if>

                                            <c:if test="${o.orderStatus == 'PACKING'}">
                                                <form method="post" action="/vendor/orders/${o.id}/status" class="d-inline">
                                                    <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                                    <button name="status" value="READY_FOR_PICKUP" class="btn btn-sm btn-warning rounded-pill px-2">Sẵn sàng lấy</button>
                                                </form>
                                            </c:if>

                                            <c:if test="${o.orderStatus == 'READY_FOR_PICKUP'}">
                                                <c:choose>
                                                    <c:when test="${not empty da && not empty da.shipper && da.status == 'CANCELLED'}">
                                                        <button type="button" class="btn btn-sm btn-danger rounded-pill px-2 fw-bold shadow-sm"
                                                                data-bs-toggle="modal" data-bs-target="#assignShipperModal${o.id}">
                                                            <i class="fa-solid fa-rotate-right me-1"></i>Phân lại Shipper
                                                        </button>
                                                    </c:when>
                                                    <c:when test="${not empty da && not empty da.shipper && da.status == 'ASSIGNED'}">
                                                        <button type="button" class="btn btn-sm btn-outline-secondary rounded-pill px-2 fw-bold"
                                                                data-bs-toggle="modal" data-bs-target="#assignShipperModal${o.id}">
                                                            <i class="fa-solid fa-user-pen me-1"></i>Đổi Shipper
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button type="button" class="btn btn-sm btn-primary rounded-pill px-2 fw-bold shadow-sm"
                                                                data-bs-toggle="modal" data-bs-target="#assignShipperModal${o.id}">
                                                            <i class="fa-solid fa-motorcycle me-1"></i>Phân Shipper
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:if>

                                            <c:if test="${o.orderStatus == 'RETURN_REQUESTED'}">
                                                <a href="/vendor/returns" class="btn btn-sm btn-warning rounded-pill px-2 fw-bold">
                                                    <i class="fa-solid fa-rotate-left me-1"></i>Xử lý đổi trả
                                                </a>
                                            </c:if>

                                            <c:if test="${o.orderStatus == 'RETURNED'}">
                                                <a href="/vendor/returns" class="btn btn-sm btn-info rounded-pill px-2 fw-bold text-dark">
                                                    <i class="fa-solid fa-hand-holding-dollar me-1"></i>Duyệt hoàn tiền
                                                </a>
                                            </c:if>
                                        </div>

                                        <!-- Form Thu Hồi Phân Công -->
                                        <form id="revokeForm${o.id}" method="post" action="/vendor/orders/${o.id}/revoke-shipper" onsubmit="return confirm('Bạn có chắc chắn muốn thu hồi phân công từ Shipper hiện tại? Đơn hàng sẽ trở về trạng thái chờ phân công.');">
                                            <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                            <input type="hidden" name="redirectUrl" value="/vendor/orders">
                                        </form>

                                        <!-- Modal Phân công Shipper -->
                                        <div class="modal fade" id="assignShipperModal${o.id}" tabindex="-1" aria-hidden="true">
                                            <div class="modal-dialog modal-dialog-centered text-start">
                                                <div class="modal-content border-0 shadow rounded-4">
                                                    <div class="modal-header border-0 bg-light">
                                                        <h5 class="modal-title fw-bold">
                                                            <i class="fa-solid fa-motorcycle text-primary me-2"></i>
                                                            <c:choose>
                                                                <c:when test="${not empty da && not empty da.shipper && da.status == 'CANCELLED'}">Phân Công Lại Shipper</c:when>
                                                                <c:when test="${not empty da && not empty da.shipper && da.status == 'ASSIGNED'}">Đổi Shipper / Điều Phối Lại</c:when>
                                                                <c:otherwise>Phân Công Giao Hàng</c:otherwise>
                                                            </c:choose>
                                                        </h5>
                                                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                    </div>
                                                    <form method="post" action="/vendor/orders/${o.id}/assign-shipper">
                                                        <c:if test="${not empty _csrf}">
                                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                        </c:if>
                                                        <input type="hidden" name="redirectUrl" value="/vendor/orders">
                                                        <div class="modal-body p-4">
                                                            <div class="alert alert-secondary border-0 small mb-3">
                                                                <div><strong>Mã đơn:</strong> ${o.orderCode}</div>
                                                                <div><strong>Khách hàng:</strong> <c:out value="${o.receiverName}"/> (${o.receiverPhone})</div>
                                                                <div>
                                                                    <strong>Đơn vị khách chọn:</strong>
                                                                    <span class="badge bg-primary text-white"><c:out value="${o.shippingProvider != null ? o.shippingProvider.name : 'Chưa chỉ định'}"/></span>
                                                                </div>
                                                                <c:choose>
                                                                    <c:when test="${o.orderStatus == 'RETURN_REQUESTED'}">
                                                                        <div class="mt-1"><strong>Địa chỉ lấy hàng hoàn:</strong> <span class="text-danger fw-bold"><c:out value="${not empty o.returnAddress ? o.returnAddress : o.shippingAddress}"/></span></div>
                                                                        <div><strong>Lý do hoàn trả:</strong> <c:out value="${not empty o.returnReason ? o.returnReason : o.note}"/></div>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <div class="mt-1"><strong>Địa chỉ giao:</strong> <c:out value="${o.shippingAddress}"/></div>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>

                                                            <!-- Thông tin phân công hiện tại -->
                                                            <c:if test="${not empty da && not empty da.shipper}">
                                                                <div class="card border ${da.status == 'CANCELLED' ? 'border-danger bg-danger bg-opacity-10' : (da.status == 'ASSIGNED' ? 'border-warning bg-warning bg-opacity-10' : 'border-info bg-info bg-opacity-10')} rounded-3 p-3 mb-3">
                                                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                                                        <span class="small fw-bold text-dark"><i class="fa-solid fa-user-tag me-1"></i>Trạng thái phân công:</span>
                                                                        <c:choose>
                                                                            <c:when test="${da.status == 'ASSIGNED'}">
                                                                                <span class="badge bg-warning text-dark"><i class="fa-solid fa-clock me-1"></i>Chờ Shipper xác nhận</span>
                                                                            </c:when>
                                                                            <c:when test="${da.status == 'CANCELLED'}">
                                                                                <span class="badge bg-danger"><i class="fa-solid fa-circle-xmark me-1"></i>Đã từ chối đơn</span>
                                                                            </c:when>
                                                                            <c:when test="${da.status == 'ACCEPTED'}">
                                                                                <span class="badge bg-info text-dark"><i class="fa-solid fa-check me-1"></i>Đã nhận đơn</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span class="badge bg-secondary">${da.status}</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </div>
                                                                    <div class="small text-dark">
                                                                        <strong>Nhân viên:</strong> <c:out value="${da.shipper.fullName}"/> (<c:out value="${da.shipper.phone}"/>) - <c:out value="${da.shipper.shippingProvider != null ? da.shipper.shippingProvider.name : 'Nội bộ'}"/>
                                                                    </div>
                                                                    <c:if test="${not empty da.failureReason}">
                                                                        <div class="small text-danger fw-semibold mt-1">
                                                                            <i class="fa-solid fa-circle-info me-1"></i><c:out value="${da.failureReason}"/>
                                                                        </div>
                                                                    </c:if>
                                                                    <c:if test="${da.status == 'ASSIGNED'}">
                                                                        <div class="mt-2 pt-2 border-top border-warning d-flex justify-content-between align-items-center">
                                                                            <span class="small text-muted">Hủy giao đơn cho shipper này:</span>
                                                                            <button type="submit" form="revokeForm${o.id}" class="btn btn-sm btn-outline-danger rounded-pill px-3 fw-bold">
                                                                                <i class="fa-solid fa-user-xmark me-1"></i>Thu Hồi Phân Công
                                                                            </button>
                                                                        </div>
                                                                    </c:if>
                                                                </div>
                                                            </c:if>

                                                            <div class="mb-3">
                                                                <label class="form-label small fw-bold">Chọn Shipper nhận đơn: <span class="text-danger">*</span></label>
                                                                <select name="shipperId" class="form-select" required>
                                                                    <option value="">-- Chọn đơn vị hoặc shipper --</option>
                                                                    <c:set var="isSpxOrder" value="${o.shippingProvider != null && o.shippingProvider.code == 'SPX_EXPRESS'}"/>
                                                                    <%-- Danh sách shipper nội bộ; đơn SPX cũ phải được xử lý bởi người thật thay vì mô phỏng. --%>
                                                                    <c:forEach var="shp" items="${shippers}">
                                                                        <c:set var="isMismatch" value="${!isSpxOrder && o.shippingProvider != null && shp.shippingProvider != null && o.shippingProvider.code != shp.shippingProvider.code}"/>
                                                                        <c:if test="${!isMismatch}">
                                                                            <c:set var="isRejected" value="${not empty da && da.hasShipperRejected(shp.id)}"/>
                                                                            <c:set var="isDisabled" value="${shp.busy || isRejected}"/>

                                                                            <option value="${shp.id}" ${isDisabled ? 'disabled' : ''} class="${isRejected ? 'text-danger fw-bold' : (shp.busy ? 'text-muted' : '')}">
                                                                                ${shp.fullName} (${shp.phone}) - ${shp.shippingProvider != null ? shp.shippingProvider.name : 'Chung'}
                                                                                <c:choose>
                                                                                    <c:when test="${isRejected}">
                                                                                        [❌ ĐÃ TỪ CHỐI ĐƠN NÀY]
                                                                                    </c:when>
                                                                                    <c:when test="${shp.busy}">
                                                                                        [⏳ ĐANG BẬN: Đơn #${shp.busyOrderCode}]
                                                                                    </c:when>
                                                                                    <c:otherwise>
                                                                                        [✅ Sẵn sàng nhận đơn]
                                                                                    </c:otherwise>
                                                                                </c:choose>
                                                                            </option>
                                                                        </c:if>
                                                                    </c:forEach>
                                                                </select>
                                                                <div class="form-text small text-muted mt-2">
                                                                    <i class="fa-solid fa-circle-info me-1"></i>Chỉ phân công cho nhân viên thuộc đơn vị vận chuyển khách đã chọn (<c:out value="${o.shippingProvider != null ? o.shippingProvider.name : 'Tiêu chuẩn'}"/>). Các shipper đã từ chối đơn này hoặc đang bận sẽ bị khóa tự động.
                                                                </div>
                                                            </div>
                                                            <div class="mb-3">
                                                                <label class="form-label small fw-bold">Ghi chú vận chuyển:</label>
                                                                <textarea name="note" class="form-control" rows="2">${o.orderStatus == 'RETURN_REQUESTED' ? 'Đến địa chỉ khách để nhận lại sách hoàn trả' : 'Đến lấy hàng tại chi nhánh'}</textarea>
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer border-0 bg-light">
                                                            <button type="button" class="btn btn-light rounded-pill" data-bs-dismiss="modal">Đóng</button>
                                                            <button type="submit" class="btn btn-primary rounded-pill fw-bold">
                                                                <i class="fa-solid fa-paper-plane me-1"></i>
                                                                <c:choose>
                                                                    <c:when test="${not empty da && not empty da.shipper && da.status == 'ASSIGNED'}">Xác Nhận Đổi Shipper</c:when>
                                                                    <c:when test="${not empty da && not empty da.shipper && da.status == 'CANCELLED'}">Xác Nhận Phân Lại</c:when>
                                                                    <c:otherwise>Xác Nhận Phân Công</c:otherwise>
                                                                </c:choose>
                                                            </button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty orders}">
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-5">
                                        <i class="fa-solid fa-box-open fs-2 mb-2 text-secondary d-block"></i>
                                        Không có đơn hàng nào
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>
<jsp:include page="../../common/footer.jsp"/>
