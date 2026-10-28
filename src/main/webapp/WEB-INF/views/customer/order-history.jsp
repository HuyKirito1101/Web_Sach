<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Đơn Hàng Của Tôi - Sách Cũ Việt"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<div class="container py-4">
    <h3 class="fw-bold mb-4"><i class="fa-solid fa-receipt text-warning me-2"></i>Lịch Sử Mua Hàng</h3>

    <c:if test="${not empty param.multiSuccess}">
        <div class="alert alert-success alert-dismissible fade show rounded-3 mb-4 shadow-sm" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i><strong>Đặt hàng thành công!</strong> Giỏ hàng đã được tách thành <strong>${param.multiSuccess}</strong> đơn hàng theo từng cửa hàng/chi nhánh tương ứng.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show rounded-3 mb-4 shadow-sm" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i><c:out value="${successMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- Status Tabs - hiển thị đầy đủ 7 trạng thái -->
    <div class="card border-0 shadow-sm rounded-3 p-2 mb-4">
        <div class="d-flex flex-wrap gap-1 justify-content-start">
            <a class="btn btn-sm rounded-pill fw-medium ${selectedStatus == null ? 'btn-warning text-dark' : 'btn-light text-dark'}" href="/orders">
                <i class="fa-solid fa-list me-1"></i>Tất cả
            </a>
            <!-- Đơn hàng mới -->
            <a class="btn btn-sm rounded-pill fw-medium ${selectedStatus == 'NEW' ? 'btn-info text-dark' : 'btn-light text-dark'}" href="/orders?status=NEW">
                <i class="fa-solid fa-clock me-1"></i>Chờ xác nhận
            </a>
            <!-- Đã xác nhận -->
            <a class="btn btn-sm rounded-pill fw-medium ${selectedStatus == 'CONFIRMED' ? 'btn-primary text-white' : 'btn-light text-dark'}" href="/orders?status=CONFIRMED">
                <i class="fa-solid fa-circle-check me-1"></i>Đã xác nhận
            </a>
            <!-- Đang giao -->
            <a class="btn btn-sm rounded-pill fw-medium ${selectedStatus == 'SHIPPING' ? 'btn-warning text-dark' : 'btn-light text-dark'}" href="/orders?status=SHIPPING">
                <i class="fa-solid fa-truck me-1"></i>Đang giao
            </a>
            <!-- Đã giao -->
            <a class="btn btn-sm rounded-pill fw-medium ${selectedStatus == 'DELIVERED' ? 'btn-success text-white' : 'btn-light text-dark'}" href="/orders?status=DELIVERED">
                <i class="fa-solid fa-box-open me-1"></i>Đã giao
            </a>
            <!-- Hủy -->
            <a class="btn btn-sm rounded-pill fw-medium ${selectedStatus == 'CANCELLED' ? 'btn-danger text-white' : 'btn-light text-dark'}" href="/orders?status=CANCELLED">
                <i class="fa-solid fa-ban me-1"></i>Đã hủy
            </a>
            <!-- Trả hàng/Hoàn tiền -->
            <a class="btn btn-sm rounded-pill fw-medium ${selectedStatus == 'RETURN_REQUESTED' || selectedStatus == 'RETURNED' || selectedStatus == 'REFUNDED' ? 'btn-secondary text-white' : 'btn-light text-dark'}" href="/orders?status=RETURN_REQUESTED">
                <i class="fa-solid fa-rotate-left me-1"></i>Trả hàng/Hoàn tiền
            </a>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty orders}">
            <div class="card border-0 shadow-sm text-center py-5 rounded-3">
                <i class="fa-solid fa-box-open fs-1 text-secondary mb-3"></i>
                <h5>Bạn chưa có đơn hàng nào trong mục này!</h5>
                <p class="text-muted">Hãy mua sắm các cuốn sách cũ ưa thích trên website.</p>
                <div class="mt-2">
                    <a href="/books" class="btn btn-warning rounded-pill fw-bold px-4">Khám Phá Sách Ngay</a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="d-flex flex-column gap-3">
                <c:forEach var="o" items="${orders}">
                    <div class="card border-0 shadow-sm rounded-3 p-3">
                        <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2 flex-wrap gap-2">
                            <div>
                                <span class="fw-bold text-dark me-2">
                                    <i class="fa-solid fa-hashtag text-muted me-1"></i>${o.orderCode}
                                </span>
                                <small class="text-muted"><i class="fa-solid fa-store me-1"></i><c:out value="${o.branch.name}"/></small>
                            </div>
                            <!-- Status badge với màu theo trạng thái -->
                            <c:choose>
                                <c:when test="${o.orderStatus == 'NEW'}">
                                    <span class="badge bg-info text-dark fs-6 fw-bold px-3 py-2">
                                        <i class="fa-solid fa-clock me-1"></i>Chờ xác nhận
                                    </span>
                                </c:when>
                                <c:when test="${o.orderStatus == 'CONFIRMED'}">
                                    <span class="badge bg-primary fs-6 fw-bold px-3 py-2">
                                        <i class="fa-solid fa-circle-check me-1"></i>Đã xác nhận
                                    </span>
                                </c:when>
                                <c:when test="${o.orderStatus == 'PACKING'}">
                                    <span class="badge bg-warning text-dark fs-6 fw-bold px-3 py-2">
                                        <i class="fa-solid fa-box me-1"></i>Đang đóng gói
                                    </span>
                                </c:when>
                                <c:when test="${o.orderStatus == 'READY_FOR_PICKUP' || o.orderStatus == 'PICKED_UP'}">
                                    <span class="badge bg-warning text-dark fs-6 fw-bold px-3 py-2">
                                        <i class="fa-solid fa-truck-loading me-1"></i>Chờ shipper
                                    </span>
                                </c:when>
                                <c:when test="${o.orderStatus == 'SHIPPING'}">
                                    <span class="badge bg-warning text-dark fs-6 fw-bold px-3 py-2">
                                        <i class="fa-solid fa-truck me-1"></i>Đang giao hàng
                                    </span>
                                </c:when>
                                <c:when test="${o.orderStatus == 'DELIVERED'}">
                                    <span class="badge bg-success fs-6 fw-bold px-3 py-2">
                                        <i class="fa-solid fa-box-open me-1"></i>Đã giao thành công
                                    </span>
                                </c:when>
                                <c:when test="${o.orderStatus == 'CANCELLED'}">
                                    <span class="badge bg-danger fs-6 fw-bold px-3 py-2">
                                        <i class="fa-solid fa-ban me-1"></i>Đã hủy đơn
                                    </span>
                                </c:when>
                                <c:when test="${o.orderStatus == 'RETURN_REQUESTED'}">
                                    <span class="badge bg-secondary fs-6 fw-bold px-3 py-2">
                                        <i class="fa-solid fa-rotate-left me-1"></i>Đang xét trả hàng
                                    </span>
                                </c:when>
                                <c:when test="${o.orderStatus == 'RETURNED' || o.orderStatus == 'REFUNDED'}">
                                    <span class="badge bg-secondary fs-6 fw-bold px-3 py-2">
                                        <i class="fa-solid fa-money-bill-transfer me-1"></i>Đã hoàn tiền
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-light text-dark border fs-6 fw-bold px-3 py-2">${o.orderStatus}</span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Order progress bar -->
                        <c:if test="${o.orderStatus != 'CANCELLED' && o.orderStatus != 'RETURN_REQUESTED' && o.orderStatus != 'RETURNED' && o.orderStatus != 'REFUNDED'}">
                            <div class="d-flex align-items-center gap-1 mb-3 small text-center" style="overflow-x:auto;">
                                <div class="d-flex flex-column align-items-center" style="min-width:60px;">
                                    <div class="rounded-circle d-flex align-items-center justify-content-center ${o.orderStatus == 'NEW' || o.orderStatus == 'CONFIRMED' || o.orderStatus == 'PACKING' || o.orderStatus == 'READY_FOR_PICKUP' || o.orderStatus == 'PICKED_UP' || o.orderStatus == 'SHIPPING' || o.orderStatus == 'DELIVERED' ? 'bg-warning' : 'bg-light border'}" style="width:28px;height:28px;"><i class="fa-solid fa-clock" style="font-size:12px;"></i></div>
                                    <span style="font-size:10px;" class="mt-1">Đặt hàng</span>
                                </div>
                                <div class="flex-grow-1 border-top border-warning" style="height:2px;margin-bottom:18px;"></div>
                                <div class="d-flex flex-column align-items-center" style="min-width:60px;">
                                    <div class="rounded-circle d-flex align-items-center justify-content-center ${o.orderStatus == 'CONFIRMED' || o.orderStatus == 'PACKING' || o.orderStatus == 'READY_FOR_PICKUP' || o.orderStatus == 'PICKED_UP' || o.orderStatus == 'SHIPPING' || o.orderStatus == 'DELIVERED' ? 'bg-primary text-white' : 'bg-light border'}" style="width:28px;height:28px;"><i class="fa-solid fa-check" style="font-size:12px;"></i></div>
                                    <span style="font-size:10px;" class="mt-1">Xác nhận</span>
                                </div>
                                <div class="flex-grow-1 border-top ${o.orderStatus == 'SHIPPING' || o.orderStatus == 'DELIVERED' ? 'border-warning' : 'border-light'}" style="height:2px;margin-bottom:18px;"></div>
                                <div class="d-flex flex-column align-items-center" style="min-width:60px;">
                                    <div class="rounded-circle d-flex align-items-center justify-content-center ${o.orderStatus == 'SHIPPING' || o.orderStatus == 'DELIVERED' ? 'bg-warning' : 'bg-light border'}" style="width:28px;height:28px;"><i class="fa-solid fa-truck" style="font-size:12px;"></i></div>
                                    <span style="font-size:10px;" class="mt-1">Đang giao</span>
                                </div>
                                <div class="flex-grow-1 border-top ${o.orderStatus == 'DELIVERED' ? 'border-success' : 'border-light'}" style="height:2px;margin-bottom:18px;"></div>
                                <div class="d-flex flex-column align-items-center" style="min-width:60px;">
                                    <div class="rounded-circle d-flex align-items-center justify-content-center ${o.orderStatus == 'DELIVERED' ? 'bg-success text-white' : 'bg-light border'}" style="width:28px;height:28px;"><i class="fa-solid fa-box-open" style="font-size:12px;"></i></div>
                                    <span style="font-size:10px;" class="mt-1">Đã giao</span>
                                </div>
                            </div>
                        </c:if>

                        <div class="row align-items-center">
                            <div class="col-md-8">
                                <p class="mb-1 text-secondary small"><strong>Người nhận:</strong> <c:out value="${o.receiverName}"/> - <c:out value="${o.receiverPhone}"/></p>
                                <p class="mb-1 text-secondary small"><strong>Địa chỉ:</strong> <c:out value="${o.shippingAddress}"/></p>
                                <p class="mb-0 text-muted small"><strong>Thanh toán:</strong> ${o.paymentMethod}
                                    (<span class="${o.paymentStatus == 'PAID' ? 'text-success' : (o.paymentStatus == 'FAILED' ? 'text-danger' : 'text-warning')}">
                                        <c:choose>
                                            <c:when test="${o.paymentStatus == 'PAID'}">Đã thanh toán</c:when>
                                            <c:when test="${o.paymentStatus == 'AWAITING_CONFIRMATION'}">Chờ cửa hàng xác nhận</c:when>
                                            <c:when test="${o.paymentStatus == 'FAILED'}">Đã hủy / thất bại</c:when>
                                            <c:otherwise>Chưa thanh toán</c:otherwise>
                                        </c:choose>
                                    </span>)
                                </p>
                            </div>
                            <div class="col-md-4 text-md-end mt-2 mt-md-0">
                                <div class="mb-2">
                                    <span class="text-muted small me-2">Tổng tiền:</span>
                                    <span class="fw-bold fs-5 text-danger">
                                        <fmt:formatNumber value="${o.finalAmount}" pattern="#,##0"/> đ
                                    </span>
                                </div>
                                <a href="/orders/${o.id}" class="btn btn-outline-warning text-dark btn-sm rounded-pill fw-bold px-3">
                                    Chi Tiết <i class="fa-solid fa-chevron-right ms-1"></i>
                                </a>
                                <!-- Nút hủy nếu đơn mới -->
                                <c:if test="${o.orderStatus == 'NEW' && !(o.paymentMethod == 'MOMO' && o.paymentStatus == 'PAID')}">
                                    <form action="/orders/${o.id}/cancel" method="POST" class="d-inline ms-1"
                                          onsubmit="return confirm('Bạn có chắc muốn hủy đơn hàng này không?')">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <button type="submit" class="btn btn-outline-danger btn-sm rounded-pill fw-bold">
                                            <i class="fa-solid fa-ban me-1"></i>Hủy đơn
                                        </button>
                                    </form>
                                </c:if>
                                <!-- Nút trả hàng nếu đã giao -->
                                <c:if test="${o.orderStatus == 'DELIVERED'}">
                                    <button class="btn btn-outline-secondary btn-sm rounded-pill fw-bold ms-1"
                                            data-bs-toggle="modal" data-bs-target="#returnModal${o.id}">
                                        <i class="fa-solid fa-rotate-left me-1"></i>Trả hàng
                                    </button>
                                    <!-- Modal trả hàng -->
                                    <div class="modal fade" id="returnModal${o.id}" tabindex="-1">
                                        <div class="modal-dialog">
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <h6 class="modal-title fw-bold">Yêu Cầu Trả Hàng - Hoàn Tiền</h6>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <form action="/orders/${o.id}/return" method="POST">
                                                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                    <div class="modal-body">
                                                        <label class="form-label fw-medium small">Lý do trả hàng:</label>
                                                        <textarea name="reason" class="form-control" rows="3" required
                                                                  placeholder="Mô tả lý do trả hàng: sách bị hư hỏng, không đúng mô tả..."></textarea>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Hủy</button>
                                                        <button type="submit" class="btn btn-warning fw-bold">Gửi Yêu Cầu</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="../common/footer.jsp"/>
