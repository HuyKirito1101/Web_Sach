<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="title" value="Chi Tiết Đơn Giao Hàng - Shipper" scope="request"/>
<jsp:include page="../../common/header.jsp"/>

<c:set var="isSellReq" value="${assignment.forSellRequest}"/>
<c:set var="isReturn" value="${not isSellReq && (assignment.order.orderStatus == 'RETURN_REQUESTED' || assignment.order.orderStatus == 'RETURNED')}"/>

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp"/>
    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp"/>
        <main class="main-content container-fluid py-4 px-lg-4">

            <!-- Breadcrumb Navigation -->
            <div class="mb-3">
                <a href="/shipper/orders" class="btn btn-outline-secondary btn-sm rounded-pill px-3">
                    <i class="fa-solid fa-arrow-left me-1"></i> Quay lại danh sách đơn
                </a>
            </div>

            <!-- Page Title & Status Header -->
            <div class="card border-0 shadow-sm rounded-4 p-4 mb-4 bg-white">
                <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
                    <div>
                        <div class="d-flex align-items-center gap-2 mb-1">
                            <h3 class="fw-bold mb-0 text-dark">${assignment.referenceCode}</h3>
                            <c:choose>
                                <c:when test="${isSellReq}">
                                    <span class="badge text-white px-3 py-2 rounded-pill" style="background-color: #6f42c1;">
                                        <i class="fa-solid fa-hand-holding-dollar me-1"></i>ĐƠN THU GOM SÁCH CŨ TẬN NHÀ
                                    </span>
                                </c:when>
                                <c:when test="${isReturn}">
                                    <span class="badge bg-warning text-dark px-3 py-2 rounded-pill">
                                        <i class="fa-solid fa-rotate-left me-1"></i>ĐƠN THU HỒI / HOÀN TRẢ SÁCH
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-primary px-3 py-2 rounded-pill">
                                        <i class="fa-solid fa-box me-1"></i>ĐƠN GIAO SÁCH
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="text-muted small">
                            <i class="fa-regular fa-clock me-1"></i>Thời gian phân công:
                            <c:out value="${assignment.formattedAssignedAt}"/>
                        </div>
                    </div>
                    <div class="text-md-end">
                        <div class="text-muted small">Trạng thái vận chuyển hiện tại:</div>
                        <div>
                            <c:choose>
                                <c:when test="${assignment.status == 'ASSIGNED'}">
                                    <span class="badge bg-warning text-dark px-3 py-2 rounded-pill fs-6">
                                        <i class="fa-solid fa-clock me-1"></i>Chờ xác nhận nhận đơn
                                    </span>
                                </c:when>
                                <c:when test="${assignment.status == 'ACCEPTED'}">
                                    <span class="badge bg-info text-dark px-3 py-2 rounded-pill fs-6">
                                        <i class="fa-solid fa-check me-1"></i>Đã nhận phân công
                                    </span>
                                </c:when>
                                <c:when test="${assignment.status == 'PICKED_UP'}">
                                    <span class="badge bg-primary px-3 py-2 rounded-pill fs-6">
                                        <i class="fa-solid fa-box me-1"></i>Đã lấy hàng
                                    </span>
                                </c:when>
                                <c:when test="${assignment.status == 'SHIPPING'}">
                                    <span class="badge bg-info text-dark px-3 py-2 rounded-pill fs-6">
                                        <i class="fa-solid fa-truck me-1"></i>Đang vận chuyển
                                    </span>
                                </c:when>
                                <c:when test="${assignment.status == 'DELIVERED'}">
                                    <span class="badge bg-success px-3 py-2 rounded-pill fs-6">
                                        <i class="fa-solid fa-circle-check me-1"></i>Hoàn tất giao nhận
                                    </span>
                                </c:when>
                                <c:when test="${assignment.status == 'FAILED'}">
                                    <span class="badge bg-danger px-3 py-2 rounded-pill fs-6">
                                        <i class="fa-solid fa-triangle-exclamation me-1"></i>Giao nhận thất bại
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-secondary px-3 py-2 rounded-pill fs-6">${assignment.status}</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Alerts -->
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert">
                    <i class="fa-solid fa-circle-check me-2"></i><c:out value="${successMessage}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert">
                    <i class="fa-solid fa-circle-exclamation me-2"></i><c:out value="${errorMessage}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <c:if test="${isReturn}">
                <div class="alert alert-warning border-0 shadow-sm rounded-4 mb-4">
                    <h5 class="fw-bold mb-1">
                        <i class="fa-solid fa-rotate-left me-2"></i>Quy Trình Thu Hồi Sách Hoàn Trả:
                    </h5>
                    <p class="mb-0 small">
                        Khách hàng yêu cầu hoàn trả sách. Bạn vui lòng đến đúng <strong>địa chỉ của khách hàng</strong> để kiểm tra nhận lại sách, sau đó vận chuyển và bàn giao lại cho <strong>cửa hàng / chi nhánh</strong>.
                    </p>
                </div>
            </c:if>

            <div class="row g-4">
                <!-- Left: Delivery Information -->
                <div class="col-lg-7">
                    <div class="card border-0 shadow-sm rounded-4 p-4 bg-white h-100">
                        <h5 class="fw-bold mb-3 text-dark border-bottom pb-2">
                            <i class="fa-solid fa-route text-primary me-2"></i>Thông Tin Tuyến Đường &amp; Giao Nhận
                        </h5>

                        <dl class="row mb-0 gy-3">
                            <c:choose>
                                <c:when test="${isSellReq}">
                                    <dt class="col-sm-4 text-secondary"><i class="fa-solid fa-location-dot text-primary me-1"></i>Địa chỉ lấy sách tận nhà</dt>
                                    <dd class="col-sm-8 text-primary fw-bold fs-6">
                                        <c:out value="${assignment.sellRequest.note}"/>
                                    </dd>

                                    <dt class="col-sm-4 text-secondary"><i class="fa-solid fa-user me-1"></i>Khách hàng bán sách</dt>
                                    <dd class="col-sm-8 fw-semibold text-dark">
                                        <c:out value="${assignment.sellRequest.customer.fullName}"/>
                                    </dd>

                                    <dt class="col-sm-4 text-secondary"><i class="fa-solid fa-phone me-1"></i>SĐT liên hệ</dt>
                                    <dd class="col-sm-8">
                                        <a href="tel:${assignment.sellRequest.customer.phone}" class="fw-bold text-primary text-decoration-none">
                                            <c:out value="${assignment.sellRequest.customer.phone}"/>
                                        </a>
                                    </dd>

                                    <dt class="col-sm-4 text-secondary"><i class="fa-solid fa-book text-warning me-1"></i>Sách cần gom</dt>
                                    <dd class="col-sm-8 text-dark">
                                        <span class="badge bg-light text-dark border fw-bold me-2">${assignment.sellRequest.items.size()} cuốn sách</span>
                                        <c:forEach var="it" items="${assignment.sellRequest.items}">
                                            <div class="small text-muted mt-1">• <strong>${it.bookTitle}</strong> (${it.conditionDescription})</div>
                                        </c:forEach>
                                    </dd>

                                    <dt class="col-sm-4 text-secondary"><i class="fa-solid fa-warehouse text-success me-1"></i>Bàn giao về kho</dt>
                                    <dd class="col-sm-8 fw-semibold text-dark">
                                        <c:out value="${assignment.branchName}"/>
                                        <div class="small text-muted"><c:out value="${assignment.branchAddress}"/></div>
                                    </dd>
                                </c:when>

                                <c:when test="${isReturn}">
                                    <dt class="col-sm-4 text-secondary"><i class="fa-solid fa-location-dot text-danger me-1"></i>Địa chỉ lấy sách</dt>
                                    <dd class="col-sm-8 text-danger fw-bold fs-6">
                                        <c:out value="${not empty assignment.order.returnAddress ? assignment.order.returnAddress : assignment.order.shippingAddress}"/>
                                    </dd>

                                    <dt class="col-sm-4 text-secondary"><i class="fa-solid fa-user me-1"></i>Người gửi lại</dt>
                                    <dd class="col-sm-8 fw-semibold text-dark">
                                        <c:out value="${assignment.order.receiverName}"/>
                                    </dd>

                                    <dt class="col-sm-4 text-secondary"><i class="fa-solid fa-phone me-1"></i>SĐT liên hệ</dt>
                                    <dd class="col-sm-8">
                                        <a href="tel:${assignment.order.receiverPhone}" class="fw-bold text-primary text-decoration-none">
                                            <c:out value="${assignment.order.receiverPhone}"/>
                                        </a>
                                    </dd>

                                    <dt class="col-sm-4 text-secondary"><i class="fa-solid fa-comment-dots text-warning me-1"></i>Lý do hoàn trả</dt>
                                    <dd class="col-sm-8 text-dark p-2 bg-light rounded border">
                                        <c:out value="${not empty assignment.order.returnReason ? assignment.order.returnReason : (not empty assignment.order.note ? assignment.order.note : 'Khách không ưng ý sách')}"/>
                                    </dd>

                                    <dt class="col-sm-4 text-secondary"><i class="fa-solid fa-shop text-success me-1"></i>Bàn giao về</dt>
                                    <dd class="col-sm-8 fw-semibold text-dark">
                                        <c:out value="${assignment.order.branch.name}"/>
                                        <div class="small text-muted"><c:out value="${assignment.order.branch.address}"/></div>
                                    </dd>
                                </c:when>

                                <c:otherwise>
                                    <dt class="col-sm-4 text-secondary"><i class="fa-solid fa-shop text-primary me-1"></i>Cửa hàng lấy</dt>
                                    <dd class="col-sm-8 fw-semibold text-dark">
                                        <c:out value="${assignment.order.branch.name}"/>
                                        <div class="small text-muted"><c:out value="${assignment.order.branch.address}"/></div>
                                    </dd>

                                    <dt class="col-sm-4 text-secondary"><i class="fa-solid fa-user me-1"></i>Người nhận</dt>
                                    <dd class="col-sm-8 fw-semibold text-dark">
                                        <c:out value="${assignment.order.receiverName}"/>
                                    </dd>

                                    <dt class="col-sm-4 text-secondary"><i class="fa-solid fa-phone me-1"></i>Điện thoại</dt>
                                    <dd class="col-sm-8">
                                        <a href="tel:${assignment.order.receiverPhone}" class="fw-bold text-primary text-decoration-none">
                                            <c:out value="${assignment.order.receiverPhone}"/>
                                        </a>
                                    </dd>

                                    <dt class="col-sm-4 text-secondary"><i class="fa-solid fa-location-dot text-danger me-1"></i>Địa chỉ giao</dt>
                                    <dd class="col-sm-8 fw-bold text-dark">
                                        <c:out value="${assignment.order.shippingAddress}"/>
                                    </dd>
                                </c:otherwise>
                            </c:choose>

                            <dt class="col-sm-4 text-secondary"><i class="fa-solid fa-money-bill-wave text-success me-1"></i>Thu nhập nhận được</dt>
                            <dd class="col-sm-8 text-success fw-bold fs-6">
                                <fmt:formatNumber value="${assignment.forSellRequest ? 20000 : (assignment.order.shippingFee != null && assignment.order.shippingFee > 20000 ? assignment.order.shippingFee : 20000)}" pattern="#,#00 ₫"/>
                                <span class="badge bg-success bg-opacity-10 text-success ms-1 small fw-normal">Phí giao nhận tiêu chuẩn</span>
                            </dd>

                            <dt class="col-sm-4 text-secondary"><i class="fa-solid fa-note-sticky me-1"></i>Ghi chú phân công</dt>
                            <dd class="col-sm-8 text-muted">
                                <c:out value="${not empty assignment.note ? assignment.note : 'Không có ghi chú thêm'}"/>
                            </dd>

                            <c:if test="${not empty assignment.failureReason}">
                                <dt class="col-sm-4 text-danger"><i class="fa-solid fa-circle-exclamation me-1"></i>Lý do thất bại</dt>
                                <dd class="col-sm-8 text-danger fw-semibold">
                                    <c:out value="${assignment.failureReason}"/>
                                </dd>
                            </c:if>
                        </dl>
                    </div>
                </div>

                <!-- Right: Action Center -->
                <div class="col-lg-5">
                    <div class="card border-0 shadow-sm rounded-4 p-4 bg-white h-100">
                        <h5 class="fw-bold mb-3 text-dark border-bottom pb-2">
                            <i class="fa-solid fa-sliders text-primary me-2"></i>Cập Nhật Tiến Độ Giao Nhận
                        </h5>

                        <c:if test="${assignment.status == 'ASSIGNED'}">
                            <p class="small text-muted mb-3">Bạn vừa được phân công đơn này. Vui lòng xác nhận tiếp nhận hoặc từ chối để cửa hàng điều phối:</p>
                            <div class="d-grid gap-3">
                                <form method="post" action="/shipper/orders/${assignment.id}/status" onsubmit="return confirm('Xác nhận tiếp nhận đơn giao #${assignment.referenceCode}?');">
                                    <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                    <input type="hidden" name="status" value="ACCEPTED">
                                    <button type="submit" class="btn text-white rounded-pill py-3 fw-bold w-100 shadow"
                                            style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); border: none; font-size: 16px; letter-spacing: 0.3px;">
                                        <i class="fa-solid fa-circle-check fs-5 me-2"></i>Xác Nhận Tiếp Nhận Đơn
                                    </button>
                                </form>
                                <button type="button" class="btn btn-outline-danger rounded-pill py-2 fw-semibold w-100"
                                        data-bs-toggle="modal" data-bs-target="#rejectDetailModal">
                                    <i class="fa-solid fa-ban me-2"></i>Từ Chối Nhận Đơn
                                </button>
                            </div>

                            <!-- Modal Từ chối nhận đơn -->
                            <div class="modal fade" id="rejectDetailModal" tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered text-start">
                                    <div class="modal-content border-0 shadow rounded-4">
                                        <div class="modal-header border-0 bg-light">
                                            <h5 class="modal-title fw-bold text-danger">
                                                <i class="fa-solid fa-circle-xmark me-2"></i>Từ Chối Nhận Đơn #${assignment.order.orderCode}
                                            </h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                        </div>
                                        <form method="post" action="/shipper/orders/${assignment.id}/reject">
                                            <c:if test="${not empty _csrf}">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                            </c:if>
                                            <div class="modal-body p-4">
                                                <div class="alert alert-secondary border-0 small mb-3">
                                                    <div><strong>Mã đơn:</strong> ${assignment.order.orderCode}</div>
                                                    <div><strong>Loại đơn:</strong> ${isReturn ? 'Thu hồi sách hoàn' : 'Giao sách mới'}</div>
                                                    <div><strong>Địa chỉ:</strong> <c:out value="${isReturn ? (not empty assignment.order.returnAddress ? assignment.order.returnAddress : assignment.order.shippingAddress) : assignment.order.shippingAddress}"/></div>
                                                </div>
                                                <div class="mb-3">
                                                    <label class="form-label small fw-bold">Lý do từ chối: <span class="text-danger">*</span></label>
                                                    <textarea name="reason" class="form-control" rows="3" placeholder="Nhập lý do (xe hỏng, ngoài giờ làm việc, quá xa, bận việc đột xuất...)" required></textarea>
                                                    <div class="form-text small text-muted">
                                                        <i class="fa-solid fa-circle-info me-1"></i>Lý do từ chối sẽ được thông báo ngay cho cửa hàng để phân công shipper khác.
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
                        </c:if>

                        <c:if test="${assignment.status == 'ACCEPTED'}">
                            <p class="small text-muted mb-3">Đơn đã nhận. Sau khi lấy sách, bấm cập nhật:</p>
                            <form method="post" action="/shipper/orders/${assignment.id}/status">
                                <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                <button name="status" value="PICKED_UP" class="btn text-white rounded-pill w-100 py-3 fw-bold shadow-sm"
                                        style="background: linear-gradient(135deg, #4f46e5 0%, #3730a3 100%); border: none;">
                                    <i class="fa-solid fa-box me-2"></i>${isReturn ? 'Đã nhận sách từ khách' : 'Đã lấy hàng tại cửa hàng'}
                                </button>
                            </form>
                        </c:if>

                        <c:if test="${assignment.status == 'PICKED_UP'}">
                            <p class="small text-muted mb-3">Sách đã trong tay bạn. Bắt đầu vận chuyển đến điểm đến:</p>
                            <form method="post" action="/shipper/orders/${assignment.id}/status" class="mb-3">
                                <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                <button name="status" value="SHIPPING" class="btn text-dark rounded-pill w-100 py-3 fw-bold shadow-sm"
                                        style="background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%); border: none;">
                                    <i class="fa-solid fa-motorcycle me-2"></i>${isReturn ? 'Bắt đầu mang về chi nhánh' : 'Bắt đầu đi giao cho khách'}
                                </button>
                            </form>
                        </c:if>

                        <c:if test="${assignment.status == 'SHIPPING'}">
                            <p class="small text-muted mb-3">Đang trên đường giao nhận. Khi hoàn tất:</p>
                            <form method="post" action="/shipper/orders/${assignment.id}/status" class="mb-3">
                                <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                <button name="status" value="DELIVERED" class="btn text-white rounded-pill w-100 py-3 fw-bold shadow"
                                        style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); border: none;">
                                    <i class="fa-solid fa-circle-check me-2"></i>${isReturn ? 'Đã bàn giao sách cho chi nhánh' : 'Giao thành công cho khách'}
                                </button>
                            </form>
                        </c:if>

                        <c:if test="${assignment.status == 'PICKED_UP' || assignment.status == 'SHIPPING'}">
                            <hr class="my-3">
                            <div class="card bg-light border-0 rounded-3 p-3">
                                <h6 class="fw-bold text-danger mb-2 small"><i class="fa-solid fa-triangle-exclamation me-1"></i>Báo cáo sự cố / Thất bại</h6>
                                <form method="post" action="/shipper/orders/${assignment.id}/status">
                                    <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                    <input type="hidden" name="status" value="FAILED">
                                    <label class="form-label small text-muted">Lý do giao/lấy không thành công:</label>
                                    <textarea class="form-control form-control-sm mb-2" name="failureReason" placeholder="Khách hẹn lại, không liên lạc được, khách đổi ý..." required></textarea>
                                    <button class="btn btn-outline-danger btn-sm rounded-pill w-100 fw-bold">
                                        <i class="fa-solid fa-ban me-1"></i>Báo giao nhận thất bại
                                    </button>
                                </form>
                            </div>
                        </c:if>

                        <c:if test="${assignment.status == 'DELIVERED' || assignment.status == 'FAILED' || assignment.status == 'CANCELLED'}">
                            <div class="alert alert-secondary rounded-4 mb-0 py-3 text-center">
                                <i class="fa-solid fa-flag-checkered fs-3 text-secondary d-block mb-2"></i>
                                <strong>Đơn giao đã kết thúc</strong>
                                <div class="small text-muted mt-1">Trạng thái cuối: <span class="badge bg-secondary">${assignment.status}</span></div>
                            </div>
                        </c:if>

                    </div>
                </div>
            </div>

        </main>
    </div>
</div>

<jsp:include page="../../common/footer.jsp"/>
