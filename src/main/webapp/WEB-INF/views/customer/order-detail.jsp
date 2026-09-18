<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Chi Tiết Đơn Hàng #${order.orderCode}"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<div class="container py-4">
    <c:if test="${success}">
        <div class="alert alert-success alert-dismissible fade show rounded-3 mb-4 shadow-sm" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i><strong>Đặt hàng thành công!</strong> Cảm ơn bạn đã mua sách cũ tại hệ thống của chúng tôi.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3 class="fw-bold mb-0">Chi Tiết Đơn Hàng #${order.orderCode}</h3>
        <a href="/orders" class="btn btn-outline-secondary btn-sm rounded-pill"><i class="fa-solid fa-arrow-left me-1"></i>Quay lại danh sách</a>
    </div>

    <div class="row g-4">
        <div class="col-lg-8">
            <!-- Order Items -->
            <div class="card border-0 shadow-sm rounded-3 p-3 mb-4">
                <h5 class="fw-bold mb-3 border-bottom pb-2">Danh Sách Sách Đã Đặt</h5>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th>Sách Cũ</th>
                                <th>Đơn Giá</th>
                                <th>Số Lượng</th>
                                <th>Thành Tiền</th>
                                <th>Đánh Giá</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="item" items="${items}">
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <img src="${item.bookCopy.book.coverUrl != null ? item.bookCopy.book.coverUrl : 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'}" width="40" height="50" class="rounded" style="object-fit: cover;">
                                            <div>
                                                <h6 class="mb-0 text-dark fw-bold">${item.bookCopy.book.title}</h6>
                                                <small class="text-muted">Tình trạng: ${item.bookCopy.conditionRating}</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="fw-bold">
                                        <fmt:formatNumber value="${item.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </td>
                                    <td>${item.quantity}</td>
                                    <td class="fw-bold text-danger">
                                        <fmt:formatNumber value="${item.price * item.quantity}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </td>
                                    <td>
                                        <c:if test="${order.orderStatus == 'DELIVERED'}">
                                            <a href="/books/${item.bookCopy.book.id}" class="btn btn-warning btn-sm rounded-pill fw-bold">Viết Đánh Giá</a>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Actions -->
            <div class="card border-0 shadow-sm rounded-3 p-4">
                <h5 class="fw-bold mb-3">Thao Tác Đơn Hàng</h5>
                <c:choose>
                    <c:when test="${order.orderStatus == 'NEW' || order.orderStatus == 'CONFIRMED'}">
                        <form action="/orders/${order.id}/cancel" method="POST" onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn hàng này?');">
                            <div class="mb-2">
                                <label class="form-label small fw-medium">Lý do hủy đơn:</label>
                                <input type="text" name="reason" class="form-control form-control-sm" placeholder="Đổi ý, chọn nhầm sách..." required>
                            </div>
                            <button type="submit" class="btn btn-danger btn-sm rounded-pill fw-bold">Hủy Đơn Hàng</button>
                        </form>
                    </c:when>
                    <c:when test="${order.orderStatus == 'DELIVERED'}">
                        <form action="/orders/${order.id}/return" method="POST" onsubmit="return confirm('Gửi yêu cầu trả hàng/hoàn tiền cho đơn này?');">
                            <div class="mb-2">
                                <label class="form-label small fw-medium">Lý do yêu cầu trả hàng/hoàn tiền:</label>
                                <input type="text" name="reason" class="form-control form-control-sm" placeholder="Sách bị rách, sai tình trạng..." required>
                            </div>
                            <button type="submit" class="btn btn-warning btn-sm rounded-pill fw-bold">Yêu Cầu Trả Hàng / Hoàn Tiền</button>
                        </form>
                    </c:when>
                    <c:otherwise>
                        <p class="text-muted mb-0">Đơn hàng ở trạng thái <strong>${order.orderStatus}</strong> - không thể hủy hoặc thao tác thêm.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Right Col: Summary -->
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm rounded-3 p-4">
                <h5 class="fw-bold mb-3 border-bottom pb-2">Thông Tin Giao Hàng</h5>
                <p class="mb-1"><strong>Người nhận:</strong> ${order.receiverName}</p>
                <p class="mb-1"><strong>Điện thoại:</strong> ${order.receiverPhone}</p>
                <p class="mb-3"><strong>Địa chỉ:</strong> ${order.shippingAddress}</p>

                <hr>
                <p class="mb-1"><strong>Chi nhánh bán:</strong> ${order.branch.name}</p>
                <p class="mb-1"><strong>Nhà vận chuyển:</strong> ${order.shippingProvider != null ? order.shippingProvider.name : 'Giao hàng tiêu chuẩn'}</p>
                <p class="mb-1"><strong>Phương thức thanh toán:</strong> ${order.paymentMethod}</p>
                <p class="mb-3"><strong>Trạng thái thanh toán:</strong> <span class="badge bg-secondary">${order.paymentStatus}</span></p>

                <hr>
                <div class="d-flex justify-content-between mb-1">
                    <span>Tạm tính sách:</span>
                    <span><fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                </div>
                <div class="d-flex justify-content-between mb-1">
                    <span>Phí vận chuyển:</span>
                    <span><fmt:formatNumber value="${order.shippingFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                </div>
                <div class="d-flex justify-content-between mb-2 text-success">
                    <span>Giảm giá:</span>
                    <span>-<fmt:formatNumber value="${order.discountAmount != null ? order.discountAmount : 0}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                </div>
                <hr>
                <div class="d-flex justify-content-between">
                    <span class="fw-bold fs-5">Tổng thanh toán:</span>
                    <span class="fw-bold fs-5 text-danger"><fmt:formatNumber value="${order.finalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp"/>
