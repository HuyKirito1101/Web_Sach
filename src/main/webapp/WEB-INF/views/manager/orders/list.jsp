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
                <h3 class="fw-bold mb-0"><i class="fa-solid fa-receipt text-primary me-2"></i>Giám Sát Đơn Hàng Chi Nhánh</h3>
                <form action="/manager/orders/clear-history" method="post"
                      onsubmit="return confirm('Dọn các đơn ĐÃ GIAO, ĐÃ HỦY và ĐÃ HOÀN TIỀN khỏi danh sách Manager? Dữ liệu vẫn được giữ để thống kê và khách hàng vẫn xem được lịch sử.');">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <button type="submit" class="btn btn-outline-danger fw-bold">
                        <i class="fa-solid fa-broom me-1"></i>Clear Lịch Sử Đơn
                    </button>
                </form>
            </div>

            <c:if test="${not empty successMessage}"><div class="alert alert-success"><c:out value="${successMessage}"/></div></c:if>
            <c:if test="${not empty errorMessage}"><div class="alert alert-danger"><c:out value="${errorMessage}"/></div></c:if>

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
                                    <th>Thanh Toán</th>
                                    <th>Trạng Thái Đơn</th>
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
                                        <td class="small"><c:out value="${o.shippingAddress}"/></td>
                                        <td class="fw-bold text-dark"><fmt:formatNumber value="${o.finalAmount}" pattern="#,##0 ₫" /></td>
                                        <td>
                                            <div class="small fw-bold mb-1">${o.paymentMethod}</div>
                                            <c:choose>
                                                <c:when test="${o.paymentStatus == 'PAID'}">
                                                    <span class="badge bg-success"><i class="fa-solid fa-circle-check me-1"></i>Đã thanh toán</span>
                                                </c:when>
                                                <c:when test="${o.paymentMethod == 'MOMO' && o.paymentStatus == 'AWAITING_CONFIRMATION'}">
                                                    <span class="badge bg-warning text-dark">Chờ Vendor xác nhận</span>
                                                </c:when>
                                                <c:when test="${o.paymentMethod == 'MOMO' && o.paymentStatus == 'PENDING'}">
                                                    <span class="badge bg-secondary">Khách chưa báo chuyển</span>
                                                </c:when>
                                                <c:when test="${o.paymentStatus == 'FAILED'}">
                                                    <span class="badge bg-danger">Đã hủy / thất bại</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary">Chờ thu COD</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span class="badge bg-info text-dark"><c:out value="${o.orderStatus}"/></span>
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
</div>

<jsp:include page="../../common/footer.jsp" />
