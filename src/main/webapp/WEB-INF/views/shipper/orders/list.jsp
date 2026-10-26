<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="title" value="Đơn Được Phân Công - Shipper" scope="request"/>
<jsp:include page="../../common/header.jsp"/>

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp"/>
    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp"/>
        <main class="main-content container-fluid py-4 px-lg-4">

            <!-- Header Section -->
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center mb-4 gap-3">
                <div>
                    <h3 class="fw-bold mb-1 text-dark">
                        <i class="fa-solid fa-boxes-packing text-primary me-2"></i>Đơn Được Phân Công
                    </h3>
                    <p class="text-muted mb-0 small">
                        Toàn bộ danh sách đơn hàng được điều phối và phân công giao nhận cho bạn
                    </p>
                </div>

                <form class="d-flex flex-wrap align-items-center gap-2 bg-white p-2 rounded-4 shadow-sm border" method="get">
                    <select class="form-select form-select-sm border-0 bg-light rounded-pill px-3" name="status" style="width: 175px;">
                        <option value="">Tất cả trạng thái</option>
                        <c:forEach var="s" items="${statuses}">
                            <option value="${s}" ${selectedStatus == s ? 'selected' : ''}>${s}</option>
                        </c:forEach>
                    </select>

                    <div class="input-group input-group-sm" style="width: 145px;">
                        <span class="input-group-text bg-light border-0 px-2"><i class="fa-regular fa-calendar"></i></span>
                        <input class="form-control form-control-sm border-0 px-1" type="date" name="from" value="${from}" title="Từ ngày">
                    </div>
                    <span class="text-muted small text-nowrap">đến</span>
                    <div class="input-group input-group-sm" style="width: 145px;">
                        <span class="input-group-text bg-light border-0 px-2"><i class="fa-regular fa-calendar"></i></span>
                        <input class="form-control form-control-sm border-0 px-1" type="date" name="to" value="${to}" title="Đến ngày">
                    </div>

                    <button class="btn btn-primary btn-sm rounded-pill px-3 fw-bold text-nowrap d-inline-flex align-items-center shadow-sm" type="submit">
                        <i class="fa-solid fa-filter me-1"></i>Lọc
                    </button>
                    <c:if test="${not empty selectedStatus || not empty from || not empty to}">
                        <a href="/shipper/orders" class="btn btn-light btn-sm rounded-pill text-muted text-nowrap">Đặt lại</a>
                    </c:if>
                </form>
            </div>

            <!-- Quick Status Filter Pills -->
            <div class="d-flex align-items-center gap-2 flex-wrap mb-4">
                <a href="/shipper/orders<c:if test='${not empty from || not empty to}'>?from=${from}&to=${to}</c:if>" 
                   class="btn btn-sm rounded-pill px-3 ${empty selectedStatus ? 'btn-primary shadow-sm fw-bold' : 'btn-outline-secondary bg-white'}">
                    Tất cả
                </a>
                <a href="/shipper/orders?status=ASSIGNED<c:if test='${not empty from || not empty to}'>&from=${from}&to=${to}</c:if>" 
                   class="btn btn-sm rounded-pill px-3 ${selectedStatus == 'ASSIGNED' ? 'btn-warning text-dark shadow-sm fw-bold' : 'btn-outline-warning text-dark bg-white'}">
                    <i class="fa-solid fa-clock me-1"></i>Chờ nhận
                </a>
                <a href="/shipper/orders?status=ACCEPTED<c:if test='${not empty from || not empty to}'>&from=${from}&to=${to}</c:if>" 
                   class="btn btn-sm rounded-pill px-3 ${selectedStatus == 'ACCEPTED' ? 'btn-info text-dark shadow-sm fw-bold' : 'btn-outline-info text-dark bg-white'}">
                    <i class="fa-solid fa-check me-1"></i>Đã nhận đơn
                </a>
                <a href="/shipper/orders?status=PICKED_UP<c:if test='${not empty from || not empty to}'>&from=${from}&to=${to}</c:if>" 
                   class="btn btn-sm rounded-pill px-3 ${selectedStatus == 'PICKED_UP' ? 'btn-primary shadow-sm fw-bold' : 'btn-outline-primary bg-white'}">
                    <i class="fa-solid fa-box me-1"></i>Đã lấy hàng
                </a>
                <a href="/shipper/orders?status=SHIPPING<c:if test='${not empty from || not empty to}'>&from=${from}&to=${to}</c:if>" 
                   class="btn btn-sm rounded-pill px-3 text-white ${selectedStatus == 'SHIPPING' ? 'shadow-sm fw-bold' : ''}"
                   style="background: ${selectedStatus == 'SHIPPING' ? '#0891b2' : '#06b6d4'};">
                    <i class="fa-solid fa-truck-fast me-1"></i>Đang vận chuyển
                </a>
                <a href="/shipper/orders?status=DELIVERED<c:if test='${not empty from || not empty to}'>&from=${from}&to=${to}</c:if>" 
                   class="btn btn-sm rounded-pill px-3 ${selectedStatus == 'DELIVERED' ? 'btn-success shadow-sm fw-bold' : 'btn-outline-success bg-white'}">
                    <i class="fa-solid fa-circle-check me-1"></i>Giao thành công
                </a>
                <a href="/shipper/orders?status=FAILED<c:if test='${not empty from || not empty to}'>&from=${from}&to=${to}</c:if>" 
                   class="btn btn-sm rounded-pill px-3 ${selectedStatus == 'FAILED' ? 'btn-danger shadow-sm fw-bold' : 'btn-outline-danger bg-white'}">
                    <i class="fa-solid fa-triangle-exclamation me-1"></i>Thất bại
                </a>
            </div>

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm rounded-4 mb-4" role="alert">
                    <i class="fa-solid fa-circle-check me-2"></i><c:out value="${successMessage}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm rounded-4 mb-4" role="alert">
                    <i class="fa-solid fa-circle-exclamation me-2"></i><c:out value="${errorMessage}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- Main Table Section (Bố trí bảng hiện đại, chi tiết chuẩn theo ý user) -->
            <div class="card border-0 shadow-sm rounded-4 overflow-hidden bg-white">
                <div class="card-header bg-white py-3 px-4 border-0 d-flex justify-content-between align-items-center">
                    <div>
                        <h5 class="fw-bold mb-0 text-dark">
                            <i class="fa-solid fa-list-check me-2 text-primary"></i>Danh Sách Đơn Được Phân Công
                        </h5>
                        <span class="text-muted small">Quản lý và cập nhật tiến trình các đơn giao nhận</span>
                    </div>
                    <span class="badge bg-light text-dark border px-3 py-2 rounded-pill fw-bold">
                        Tổng cộng: ${assignments != null ? assignments.size() : 0} đơn
                    </span>
                </div>

                <div class="table-responsive">
                    <table class="table align-middle table-hover mb-0">
                        <thead class="table-light text-secondary small text-uppercase">
                            <tr>
                                <th class="ps-4">Mã Đơn / Phân Loại</th>
                                <th>Khách Hàng / Người Nhận</th>
                                <th>Chi Nhánh / Cửa Hàng</th>
                                <th>Địa Chỉ Lấy &amp; Giao</th>
                                <th>Trạng Thái Giao</th>
                                <th class="text-center pe-4">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="a" items="${assignments}">
                                <c:set var="isSellReq" value="${a.forSellRequest}"/>
                                <c:set var="isReturn" value="${not isSellReq && (a.order.orderStatus == 'RETURN_REQUESTED' || a.order.orderStatus == 'RETURNED')}"/>
                                <tr>
                                    <td class="ps-4">
                                        <a href="/shipper/orders/${a.id}" class="fw-bold text-decoration-none text-primary">
                                            ${a.referenceCode}
                                        </a>
                                        <div class="mt-1">
                                            <c:choose>
                                                <c:when test="${isSellReq}">
                                                    <span class="badge text-white rounded-pill px-2 py-1" style="font-size: 11px; background-color: #6f42c1;">
                                                        <i class="fa-solid fa-hand-holding-dollar me-1"></i>Thu gom sách cũ
                                                    </span>
                                                </c:when>
                                                <c:when test="${isReturn}">
                                                    <span class="badge bg-warning text-dark rounded-pill" style="font-size: 11px;">
                                                        <i class="fa-solid fa-rotate-left me-1"></i>Thu hồi sách hoàn
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-light text-dark border rounded-pill" style="font-size: 11px;">
                                                        <i class="fa-solid fa-box me-1"></i>Giao sách mới
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="fw-bold text-dark"><c:out value="${a.customerName}"/></div>
                                        <div class="small text-muted"><i class="fa-solid fa-phone me-1"></i><c:out value="${a.customerPhone}"/></div>
                                    </td>
                                    <td>
                                        <div class="fw-semibold text-dark"><c:out value="${a.branchName}"/></div>
                                        <div class="small text-muted text-truncate" style="max-width: 200px;">
                                            <c:out value="${a.branchAddress}"/>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${isSellReq}">
                                                <div class="small text-primary fw-semibold">
                                                    <i class="fa-solid fa-location-dot me-1"></i>Lấy tại: <c:out value="${a.sellRequest.note}"/>
                                                </div>
                                                <div class="small text-muted">
                                                    <i class="fa-solid fa-warehouse me-1"></i>Giao về: <c:out value="${a.branchName}"/>
                                                </div>
                                            </c:when>
                                            <c:when test="${isReturn}">
                                                <div class="small text-danger fw-semibold">
                                                    <i class="fa-solid fa-location-dot me-1"></i>Lấy tại: <c:out value="${not empty a.order.returnAddress ? a.order.returnAddress : a.order.shippingAddress}"/>
                                                </div>
                                                <div class="small text-muted">
                                                    <i class="fa-solid fa-shop me-1"></i>Trả về: <c:out value="${a.branchName}"/>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="small text-muted">
                                                    <i class="fa-solid fa-shop me-1"></i>Lấy: <c:out value="${a.order.branch.name}"/>
                                                </div>
                                                <div class="small text-dark">
                                                    <i class="fa-solid fa-location-dot text-danger me-1"></i>Giao đến: <c:out value="${a.order.shippingAddress}"/>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${a.status == 'ASSIGNED'}">
                                                <span class="badge bg-warning text-dark px-3 py-2 rounded-pill">
                                                    <i class="fa-solid fa-clock me-1"></i>Chờ nhận
                                                </span>
                                            </c:when>
                                            <c:when test="${a.status == 'ACCEPTED'}">
                                                <span class="badge bg-info text-dark px-3 py-2 rounded-pill">
                                                    <i class="fa-solid fa-check me-1"></i>Đã nhận đơn
                                                </span>
                                            </c:when>
                                            <c:when test="${a.status == 'PICKED_UP'}">
                                                <span class="badge bg-primary px-3 py-2 rounded-pill">
                                                    <i class="fa-solid fa-box me-1"></i>Đã lấy hàng
                                                </span>
                                            </c:when>
                                            <c:when test="${a.status == 'SHIPPING'}">
                                                <span class="badge bg-info text-dark px-3 py-2 rounded-pill">
                                                    <i class="fa-solid fa-truck me-1"></i>Đang vận chuyển
                                                </span>
                                            </c:when>
                                            <c:when test="${a.status == 'DELIVERED'}">
                                                <span class="badge bg-success px-3 py-2 rounded-pill">
                                                    <i class="fa-solid fa-circle-check me-1"></i>Giao thành công
                                                </span>
                                            </c:when>
                                            <c:when test="${a.status == 'FAILED'}">
                                                <span class="badge bg-danger px-3 py-2 rounded-pill">
                                                    <i class="fa-solid fa-triangle-exclamation me-1"></i>Thất bại
                                                </span>
                                            </c:when>
                                            <c:when test="${a.status == 'CANCELLED'}">
                                                <span class="badge bg-secondary px-3 py-2 rounded-pill">
                                                    <i class="fa-solid fa-ban me-1"></i>Đã hủy
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary px-3 py-2 rounded-pill">${a.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center pe-4">
                                        <c:choose>
                                            <c:when test="${a.status == 'ASSIGNED'}">
                                                <div class="d-inline-flex align-items-center gap-1">
                                                    <form method="post" action="/shipper/orders/${a.id}/status" class="d-inline" onsubmit="return confirm('Xác nhận nhận đơn #${a.referenceCode}?');">
                                                        <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                                        <input type="hidden" name="status" value="ACCEPTED">
                                                        <button type="submit" class="btn btn-sm text-white rounded-pill px-3 py-1 fw-bold shadow-sm"
                                                                style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); border: none; font-size: 13px;">
                                                            <i class="fa-solid fa-circle-check me-1"></i>Nhận đơn
                                                        </button>
                                                    </form>
                                                    <button type="button" class="btn btn-sm btn-outline-danger rounded-pill px-2 py-1"
                                                            data-bs-toggle="modal" data-bs-target="#rejectModal${a.id}" title="Từ chối đơn">
                                                        <i class="fa-solid fa-xmark"></i>
                                                    </button>
                                                    <a href="/shipper/orders/${a.id}" class="btn btn-sm btn-outline-secondary rounded-pill px-2 py-1" title="Xem chi tiết">
                                                        <i class="fa-solid fa-eye"></i>
                                                    </a>
                                                </div>

                                                <!-- Modal Từ chối đơn -->
                                                <div class="modal fade" id="rejectModal${a.id}" tabindex="-1" aria-hidden="true">
                                                    <div class="modal-dialog modal-dialog-centered text-start">
                                                        <div class="modal-content border-0 shadow rounded-4">
                                                            <div class="modal-header border-0 bg-light">
                                                                <h5 class="modal-title fw-bold text-danger">
                                                                    <i class="fa-solid fa-circle-xmark me-2"></i>Từ Chối Nhận Đơn #${a.referenceCode}
                                                                </h5>
                                                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                            </div>
                                                            <form method="post" action="/shipper/orders/${a.id}/reject">
                                                                <c:if test="${not empty _csrf}">
                                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                                </c:if>
                                                                <div class="modal-body p-4">
                                                                    <div class="alert alert-secondary border-0 small mb-3">
                                                                        <div><strong>Mã đơn:</strong> ${a.referenceCode}</div>
                                                                        <div><strong>Loại đơn:</strong> ${isSellReq ? 'Thu gom sách cũ' : (isReturn ? 'Thu hồi sách hoàn' : 'Giao sách mới')}</div>
                                                                        <div><strong>Địa chỉ:</strong> <c:out value="${a.pickupAddress}"/></div>
                                                                    </div>
                                                                    <div class="mb-3">
                                                                        <label class="form-label small fw-bold">Lý do từ chối nhận đơn: <span class="text-danger">*</span></label>
                                                                        <textarea name="reason" class="form-control" rows="3" placeholder="Nhập lý do (xe hỏng, quá tải, ngoài giờ làm việc, quá xa...)" required></textarea>
                                                                        <div class="form-text small text-muted">
                                                                            <i class="fa-solid fa-circle-info me-1"></i>Lý do từ chối sẽ được gửi ngay cho cửa hàng để phân công shipper khác.
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="modal-footer border-0 bg-light">
                                                                    <button type="button" class="btn btn-light rounded-pill" data-bs-dismiss="modal">Hủy bỏ</button>
                                                                    <button type="submit" class="btn btn-danger rounded-pill fw-bold">
                                                                        <i class="fa-solid fa-ban me-1"></i> Xác Nhận Từ Chối
                                                                    </button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:when>
                                            <c:when test="${a.status == 'ACCEPTED'}">
                                                <div class="d-inline-flex align-items-center gap-1">
                                                    <a href="/shipper/orders/${a.id}" class="btn btn-sm text-white rounded-pill px-3 py-1 fw-bold shadow-sm"
                                                       style="background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); border: none; font-size: 13px;">
                                                        <i class="fa-solid fa-box me-1"></i>Lấy hàng <i class="fa-solid fa-angle-right ms-1"></i>
                                                    </a>
                                                    <button type="button" class="btn btn-sm btn-outline-danger rounded-pill px-2 py-1"
                                                            data-bs-toggle="modal" data-bs-target="#rejectModal${a.id}" title="Từ chối/hủy">
                                                        <i class="fa-solid fa-xmark"></i>
                                                    </button>
                                                </div>

                                                <!-- Modal Từ chối đơn khi đã accepted -->
                                                <div class="modal fade" id="rejectModal${a.id}" tabindex="-1" aria-hidden="true">
                                                    <div class="modal-dialog modal-dialog-centered text-start">
                                                        <div class="modal-content border-0 shadow rounded-4">
                                                            <div class="modal-header border-0 bg-light">
                                                                <h5 class="modal-title fw-bold text-danger">
                                                                    <i class="fa-solid fa-circle-xmark me-2"></i>Từ Chối Nhận Đơn #${a.referenceCode}
                                                                </h5>
                                                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                            </div>
                                                            <form method="post" action="/shipper/orders/${a.id}/reject">
                                                                <c:if test="${not empty _csrf}">
                                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                                </c:if>
                                                                <div class="modal-body p-4">
                                                                    <div class="alert alert-secondary border-0 small mb-3">
                                                                        <div><strong>Mã đơn:</strong> ${a.referenceCode}</div>
                                                                        <div><strong>Địa chỉ:</strong> <c:out value="${a.pickupAddress}"/></div>
                                                                    </div>
                                                                    <div class="mb-3">
                                                                        <label class="form-label small fw-bold">Lý do từ chối nhận đơn: <span class="text-danger">*</span></label>
                                                                        <textarea name="reason" class="form-control" rows="3" placeholder="Nhập lý do không thể tiếp tục nhận đơn..." required></textarea>
                                                                    </div>
                                                                </div>
                                                                <div class="modal-footer border-0 bg-light">
                                                                    <button type="button" class="btn btn-light rounded-pill" data-bs-dismiss="modal">Hủy bỏ</button>
                                                                    <button type="submit" class="btn btn-danger rounded-pill fw-bold">
                                                                        <i class="fa-solid fa-ban me-1"></i> Xác Nhận Từ Chối
                                                                    </button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:when>
                                            <c:when test="${a.status == 'PICKED_UP'}">
                                                <a href="/shipper/orders/${a.id}" class="btn btn-sm text-dark rounded-pill px-3 py-1 fw-bold shadow-sm"
                                                   style="background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%); border: none; font-size: 13px;">
                                                    <i class="fa-solid fa-motorcycle me-1"></i>Đi giao <i class="fa-solid fa-angle-right ms-1"></i>
                                                </a>
                                            </c:when>
                                            <c:when test="${a.status == 'SHIPPING'}">
                                                <a href="/shipper/orders/${a.id}" class="btn btn-sm text-white rounded-pill px-3 py-1 fw-bold shadow-sm"
                                                   style="background: linear-gradient(135deg, #06b6d4 0%, #0891b2 100%); border: none; font-size: 13px;">
                                                    <i class="fa-solid fa-truck-fast me-1"></i>Hoàn tất <i class="fa-solid fa-angle-right ms-1"></i>
                                                </a>
                                            </c:when>
                                            <c:when test="${a.status == 'DELIVERED'}">
                                                <a href="/shipper/orders/${a.id}" class="btn btn-sm btn-light border text-success rounded-pill px-3 py-1 fw-semibold" style="font-size: 12px;">
                                                    <i class="fa-solid fa-check me-1"></i>Chi tiết
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="/shipper/orders/${a.id}" class="btn btn-sm btn-light border text-muted rounded-pill px-3 py-1" style="font-size: 12px;">
                                                    Chi tiết <i class="fa-solid fa-angle-right ms-1"></i>
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty assignments}">
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="fa-solid fa-truck-ramp-box fs-2 mb-2 text-secondary d-block"></i>
                                        Không có đơn hàng nào phù hợp với bộ lọc hiện tại.
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
