<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="title" value="Chi tiết đơn hàng #${order.orderCode} - Vendor" scope="request"/>
<jsp:include page="../../common/header.jsp"/>

<style>
    .badge-momo {
        background: linear-gradient(135deg, #a50064, #d82d8b);
        color: #ffffff;
        font-weight: 600;
        box-shadow: 0 2px 6px rgba(165, 0, 100, 0.25);
    }
    .btn-action-confirm {
        background: linear-gradient(135deg, #198754, #20c997);
        color: white;
        border: none;
        box-shadow: 0 3px 8px rgba(25, 135, 84, 0.25);
    }
    .btn-action-confirm:hover {
        background: linear-gradient(135deg, #157347, #1aa179);
        color: white;
    }
</style>

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp"/>
    <div class="flex-grow-1 bg-light">
        <jsp:include page="../../common/navbar.jsp"/>
        <main class="main-content container-fluid p-4">

            <!-- Breadcrumb & Top Bar -->
            <div class="d-flex flex-wrap justify-content-between align-items-center mb-4 gap-3">
                <div>
                    <a href="/vendor/orders" class="btn btn-outline-secondary rounded-pill btn-sm px-3 mb-2">
                        <i class="fa-solid fa-arrow-left me-1"></i> Quay lại danh sách đơn hàng
                    </a>
                    <h3 class="fw-bold mb-0 text-dark">
                        Chi Tiết Đơn Hàng <span class="text-primary font-monospace">#${order.orderCode}</span>
                    </h3>
                    <div class="text-muted small mt-1">
                        <i class="fa-regular fa-calendar-check me-1"></i>Ngày đặt hàng: ${order.formattedCreatedAt}
                    </div>
                </div>

                <!-- Action Buttons on Top -->
                <div class="d-flex flex-wrap align-items-center gap-2">
                    <c:if test="${order.orderStatus == 'NEW'}">
                        <c:choose>
                            <c:when test="${order.paymentMethod == 'MOMO' && order.paymentStatus == 'AWAITING_CONFIRMATION'}">
                                <form method="post" action="/vendor/orders/${order.id}/status" class="d-inline"
                                      onsubmit="return confirm('Bạn xác nhận đã nhận đủ tiền MoMo và duyệt đơn #${order.orderCode}?');">
                                    <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                    <button type="submit" name="status" value="CONFIRMED" class="btn btn-success rounded-pill fw-bold px-4 py-2 shadow-sm d-inline-flex align-items-center gap-2">
                                        <i class="fa-solid fa-check"></i>
                                        <span>Xác Nhận</span>
                                    </button>
                                </form>
                            </c:when>
                            <c:when test="${order.paymentMethod == 'MOMO' && order.paymentStatus == 'PENDING'}">
                                <button type="button" class="btn btn-outline-secondary rounded-pill px-3 py-2" disabled
                                        title="Khách chưa gửi thông tin chuyển tiền MoMo">
                                    <i class="fa-solid fa-clock-rotate-left me-1"></i>Chờ khách chuyển MoMo
                                </button>
                            </c:when>
                            <c:otherwise>
                                <form method="post" action="/vendor/orders/${order.id}/status" class="d-inline"
                                      onsubmit="return confirm('Bạn có chắc chắn muốn duyệt đơn hàng #${order.orderCode}?');">
                                    <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                    <button type="submit" name="status" value="CONFIRMED" class="btn btn-success rounded-pill fw-bold px-4 py-2 shadow-sm d-inline-flex align-items-center gap-2">
                                        <i class="fa-solid fa-check"></i>
                                        <span>Xác Nhận</span>
                                    </button>
                                </form>
                            </c:otherwise>
                        </c:choose>
                    </c:if>

                    <c:if test="${order.orderStatus == 'CONFIRMED'}">
                        <form method="post" action="/vendor/orders/${order.id}/status" class="d-inline">
                            <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                            <button type="submit" name="status" value="PACKING" class="btn btn-primary rounded-pill px-3 py-2 fw-bold shadow-sm">
                                <i class="fa-solid fa-box-archive me-1"></i>Chuẩn Bị Đóng Gói
                            </button>
                            <button type="submit" name="status" value="READY_FOR_PICKUP" class="btn btn-warning text-dark rounded-pill px-3 py-2 fw-bold shadow-sm ms-2">
                                <i class="fa-solid fa-truck-ramp-box me-1"></i>Sẵn Sàng Giao Hàng
                            </button>
                        </form>
                    </c:if>

                    <c:if test="${order.orderStatus == 'PACKING'}">
                        <form method="post" action="/vendor/orders/${order.id}/status" class="d-inline">
                            <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                            <button type="submit" name="status" value="READY_FOR_PICKUP" class="btn btn-warning text-dark rounded-pill px-4 py-2 fw-bold shadow-sm">
                                <i class="fa-solid fa-truck-ramp-box me-1"></i>Đã Đóng Gói Xong, Sẵn Sàng Giao
                            </button>
                        </form>
                    </c:if>
                </div>
            </div>

            <!-- Banner Cảnh Báo Nếu MoMo Chờ Xác Nhận -->
            <c:if test="${order.paymentMethod == 'MOMO' && order.paymentStatus == 'AWAITING_CONFIRMATION'}">
                <div class="alert alert-warning border-0 shadow-sm rounded-4 p-4 mb-4 d-flex align-items-center">
                    <div class="fs-1 text-warning me-3"><i class="fa-solid fa-bell"></i></div>
                    <div class="flex-grow-1">
                        <h5 class="fw-bold mb-1 text-dark">Khách hàng đã báo hoàn tất chuyển tiền MoMo!</h5>
                        <p class="mb-0 text-secondary">
                            Số tiền cần nhận: <strong class="text-danger fs-6"><fmt:formatNumber value="${order.finalAmount}" pattern="#,##0 ₫"/></strong>.
                            Thời gian khách gửi xác nhận: <strong>${order.formattedPaymentSubmittedAt}</strong>.
                            Vui lòng kiểm tra ứng dụng MoMo của cửa hàng, sau đó bấm <strong>"Xác Nhận"</strong> để tiến hành giao sách.
                        </p>
                    </div>
                </div>
            </c:if>

            <div class="row g-4">
                <!-- Cột trái: Thông tin giao hàng & Thông tin thanh toán -->
                <div class="col-lg-4">
                    <!-- Card Thông tin người nhận & vận chuyển -->
                    <div class="card border-0 shadow-sm rounded-4 mb-4 overflow-hidden">
                        <div class="card-header bg-white border-0 py-3 px-4">
                            <h6 class="fw-bold mb-0 text-dark">
                                <i class="fa-solid fa-truck-fast text-primary me-2"></i>Thông Tin Giao Hàng
                            </h6>
                        </div>
                        <div class="card-body p-4 pt-0">
                            <div class="mb-3">
                                <span class="text-muted small d-block">Người nhận:</span>
                                <strong class="text-dark fs-6"><c:out value="${order.receiverName}"/></strong>
                            </div>
                            <div class="mb-3">
                                <span class="text-muted small d-block">Số điện thoại:</span>
                                <strong class="text-dark"><i class="fa-solid fa-phone me-1 text-secondary"></i><c:out value="${order.receiverPhone}"/></strong>
                            </div>
                            <div class="mb-3">
                                <span class="text-muted small d-block">Địa chỉ nhận hàng:</span>
                                <span class="text-dark"><i class="fa-solid fa-location-dot me-1 text-danger"></i><c:out value="${order.shippingAddress}"/></span>
                            </div>

                            <c:if test="${not empty order.returnAddress}">
                                <div class="mb-3 p-3 bg-danger bg-opacity-10 rounded-3">
                                    <span class="text-danger fw-bold small d-block"><i class="fa-solid fa-warehouse me-1"></i>Địa chỉ lấy hàng đổi trả:</span>
                                    <span class="text-dark small"><c:out value="${order.returnAddress}"/></span>
                                </div>
                            </c:if>

                            <hr class="text-muted my-3">

                            <div class="mb-3">
                                <span class="text-muted small d-block mb-1">Đơn vị vận chuyển:</span>
                                <c:choose>
                                    <c:when test="${order.shippingProvider != null}">
                                        <c:choose>
                                            <c:when test="${order.shippingProvider.code == 'GHN_EXPRESS'}">
                                                <span class="badge bg-danger rounded-pill px-3 py-2"><i class="fa-solid fa-bolt me-1"></i>GHN Hỏa Tốc (Trong tỉnh)</span>
                                            </c:when>
                                            <c:when test="${order.shippingProvider.code == 'SPX_EXPRESS'}">
                                                <span class="badge bg-warning text-dark rounded-pill px-3 py-2"><i class="fa-solid fa-globe me-1"></i>SPX Express (Ngoại tỉnh)</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-primary rounded-pill px-3 py-2"><i class="fa-solid fa-house me-1"></i>GHN Tiêu Chuẩn</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary rounded-pill px-3 py-2">Mặc định</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <c:if test="${not empty assignment && not empty assignment.shipper}">
                                <div class="p-3 bg-light rounded-3 mb-2">
                                    <div class="fw-bold small text-dark mb-1"><i class="fa-solid fa-id-badge me-1 text-primary"></i>Shipper phụ trách:</div>
                                    <div class="text-dark fw-semibold"><c:out value="${assignment.shipper.fullName}"/></div>
                                    <div class="text-muted small"><i class="fa-solid fa-phone me-1"></i><c:out value="${assignment.shipper.phone}"/></div>
                                    <div class="mt-2">
                                        <span class="badge bg-primary rounded-pill px-2 py-1" style="font-size: 11px;">Trạng thái: ${assignment.status}</span>
                                    </div>
                                </div>
                            </c:if>

                            <div class="d-flex justify-content-between align-items-center mt-3 pt-2 border-top">
                                <span class="text-muted small">Phí vận chuyển:</span>
                                <span class="fw-bold text-dark"><fmt:formatNumber value="${order.shippingFee}" pattern="#,##0 ₫"/></span>
                            </div>
                        </div>
                    </div>

                    <!-- Card Thông tin thanh toán -->
                    <div class="card border-0 shadow-sm rounded-4 mb-4 overflow-hidden">
                        <div class="card-header bg-white border-0 py-3 px-4">
                            <h6 class="fw-bold mb-0 text-dark">
                                <i class="fa-solid fa-wallet text-success me-2"></i>Chi Tiết Thanh Toán
                            </h6>
                        </div>
                        <div class="card-body p-4 pt-0">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="text-muted small">Phương thức:</span>
                                <c:choose>
                                    <c:when test="${order.paymentMethod == 'MOMO'}">
                                        <span class="badge badge-momo px-3 py-1 rounded-pill">
                                            <i class="fa-solid fa-wallet me-1"></i>Ví MoMo
                                        </span>
                                    </c:when>
                                    <c:when test="${order.paymentMethod == 'VNPAY'}">
                                        <span class="badge bg-primary px-3 py-1 rounded-pill">
                                            <i class="fa-solid fa-qrcode me-1"></i>VNPay
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-light text-dark border px-3 py-1 rounded-pill">
                                            <i class="fa-solid fa-money-bill-wave text-success me-1"></i>COD
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <span class="text-muted small">Trạng thái thanh toán:</span>
                                <c:choose>
                                    <c:when test="${order.paymentStatus == 'PAID'}">
                                        <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3 py-1">
                                            <i class="fa-solid fa-circle-check me-1"></i>Đã thanh toán
                                        </span>
                                    </c:when>
                                    <c:when test="${order.paymentMethod == 'MOMO' && order.paymentStatus == 'AWAITING_CONFIRMATION'}">
                                        <span class="badge bg-warning text-dark border border-warning rounded-pill px-3 py-1 fw-bold">
                                            <i class="fa-solid fa-bell me-1"></i>Chờ xác nhận tiền
                                        </span>
                                    </c:when>
                                    <c:when test="${order.paymentStatus == 'PENDING'}">
                                        <span class="badge bg-secondary-subtle text-secondary rounded-pill px-3 py-1">
                                            <i class="fa-regular fa-clock me-1"></i>Chờ thanh toán
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-light text-dark border rounded-pill px-3 py-1">${order.paymentStatus}</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <c:if test="${not empty order.formattedPaymentSubmittedAt}">
                                <div class="d-flex justify-content-between align-items-center mb-2 small">
                                    <span class="text-muted">Khách chuyển lúc:</span>
                                    <span class="text-dark font-monospace">${order.formattedPaymentSubmittedAt}</span>
                                </div>
                            </c:if>

                            <c:if test="${not empty order.formattedPaymentConfirmedAt}">
                                <div class="d-flex justify-content-between align-items-center mb-2 small">
                                    <span class="text-muted">Duyệt tiền lúc:</span>
                                    <span class="text-dark font-monospace">${order.formattedPaymentConfirmedAt}</span>
                                </div>
                                <div class="d-flex justify-content-between align-items-center mb-2 small">
                                    <span class="text-muted">Người duyệt:</span>
                                    <span class="text-dark"><c:out value="${order.paymentConfirmedBy}"/></span>
                                </div>
                            </c:if>

                            <hr class="text-muted my-3">

                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="text-muted small">Tạm tính sách:</span>
                                <span class="fw-semibold text-dark"><fmt:formatNumber value="${order.totalAmount}" pattern="#,##0 ₫"/></span>
                            </div>
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="text-muted small">Phí vận chuyển (trả Shipper):</span>
                                <span class="fw-semibold text-dark"><fmt:formatNumber value="${order.shippingFee}" pattern="#,##0 ₫"/></span>
                            </div>
                            <c:if test="${order.discountAmount > 0}">
                                <div class="d-flex justify-content-between align-items-center mb-2 text-danger">
                                    <span class="small"><i class="fa-solid fa-tag me-1"></i>Khuyến mãi/Voucher (trừ vào vendor):</span>
                                    <span class="fw-semibold">-<fmt:formatNumber value="${order.discountAmount}" pattern="#,##0 ₫"/></span>
                                </div>
                            </c:if>
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <span class="text-muted small">Khách thanh toán:</span>
                                <span class="fw-bold text-dark"><fmt:formatNumber value="${order.finalAmount}" pattern="#,##0 ₫"/></span>
                            </div>
                            <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                                <span class="fw-bold text-dark fs-6">Doanh thu vendor thu về:</span>
                                <span class="fw-bold text-success fs-5"><fmt:formatNumber value="${order.totalAmount - (order.discountAmount != null ? order.discountAmount : 0)}" pattern="#,##0 ₫"/></span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Cột phải: Danh sách sản phẩm trong đơn -->
                <div class="col-lg-8">
                    <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                        <div class="card-header bg-white border-0 py-3 px-4 d-flex justify-content-between align-items-center">
                            <h6 class="fw-bold mb-0 text-dark">
                                <i class="fa-solid fa-book-bookmark text-primary me-2"></i>Sản Phẩm Trong Đơn Hàng (${items.size()})
                            </h6>
                            <span class="badge bg-primary bg-opacity-10 text-primary border border-primary border-opacity-25 rounded-pill px-3 py-1">
                                Trạng thái đơn: ${order.orderStatus}
                            </span>
                        </div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table align-middle mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th class="ps-4">Tên Sách</th>
                                            <th>Tình trạng</th>
                                            <th class="text-center">Số lượng</th>
                                            <th class="text-end">Đơn giá</th>
                                            <th class="text-end pe-4">Thành tiền</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="i" items="${items}">
                                            <tr>
                                                <td class="ps-4 py-3">
                                                    <div class="fw-bold text-dark fs-6"><c:out value="${i.bookCopy.book.title}"/></div>
                                                    <div class="small text-muted">
                                                        <c:if test="${not empty i.bookCopy.book.author}">
                                                            Tác giả: <c:out value="${i.bookCopy.book.author.name}"/>
                                                        </c:if>
                                                    </div>
                                                </td>
                                                <td>
                                                    <span class="badge bg-info bg-opacity-10 text-info-emphasis border border-info border-opacity-25 rounded-pill px-3 py-1">
                                                        ${i.bookCopy.conditionRating}
                                                    </span>
                                                </td>
                                                <td class="text-center fw-bold text-dark">${i.quantity}</td>
                                                <td class="text-end text-muted"><fmt:formatNumber value="${i.price}" pattern="#,##0 ₫"/></td>
                                                <td class="text-end pe-4 fw-bold text-danger">
                                                    <fmt:formatNumber value="${i.price * i.quantity}" pattern="#,##0 ₫"/>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </main>
    </div>
</div>
<jsp:include page="../../common/footer.jsp"/>
