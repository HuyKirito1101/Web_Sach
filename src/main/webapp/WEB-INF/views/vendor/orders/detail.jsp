<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="title" value="Chi tiết đơn Vendor" scope="request"/>
<jsp:include page="../../common/header.jsp"/>
<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp"/>
    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp"/>
        <main class="main-content container-fluid p-4">
            <a href="/vendor/orders" class="btn btn-link text-decoration-none px-0 mb-3">← Quay lại danh sách đơn hàng</a>
            <h3 class="fw-bold mb-4">Chi Tiết Đơn Hàng #${order.orderCode}</h3>

            <div class="row g-3">
                <div class="col-lg-4">
                    <div class="card border-0 shadow-sm rounded-3">
                        <div class="card-body p-4">
                            <h5 class="fw-bold mb-3 border-bottom pb-2"><i class="fa-solid fa-truck-ramp-box me-2 text-primary"></i>Thông tin giao hàng</h5>
                            <p class="mb-1"><strong>Người nhận:</strong> ${order.receiverName}</p>
                            <p class="mb-1"><strong>SĐT:</strong> ${order.receiverPhone}</p>
                            <p class="mb-3"><strong>Địa chỉ:</strong> ${order.shippingAddress}</p>

                            <hr>
                            <p class="mb-2"><strong>Phương thức giao:</strong></p>
                            <c:choose>
                                <c:when test="${order.shippingProvider != null}">
                                    <div class="fw-bold text-dark mb-1">${order.shippingProvider.name}</div>
                                    <c:choose>
                                        <c:when test="${order.shippingProvider.code == 'GHN_EXPRESS'}">
                                            <span class="badge bg-danger me-1"><i class="fa-solid fa-bolt me-1"></i>GHN Hỏa Tốc (Trong tỉnh)</span>
                                        </c:when>
                                        <c:when test="${order.shippingProvider.code == 'SPX_EXPRESS'}">
                                            <span class="badge bg-warning text-dark me-1"><i class="fa-solid fa-globe me-1"></i>SPX Express (Ngoại tỉnh)</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-primary me-1"><i class="fa-solid fa-house me-1"></i>GHN Tiêu Chuẩn (Trong tỉnh)</span>
                                        </c:otherwise>
                                    </c:choose>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-secondary">Mặc định</span>
                                </c:otherwise>
                            </c:choose>

                            <div class="mt-3">
                                <strong>Phí ship:</strong> <span class="fw-bold text-danger"><fmt:formatNumber value="${order.shippingFee}" pattern="#,#00 ₫"/></span>
                            </div>

                            <div class="mt-3">
                                <strong>Trạng thái đơn:</strong> <span class="badge bg-info text-dark ms-1">${order.orderStatus}</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-8">
                    <div class="card border-0 shadow-sm rounded-3">
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table align-middle mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Sản phẩm sách</th>
                                            <th>Tình trạng</th>
                                            <th>SL</th>
                                            <th>Đơn giá</th>
                                            <th>Thành tiền</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="i" items="${items}">
                                            <tr>
                                                <td class="fw-bold text-dark">${i.bookCopy.book.title}</td>
                                                <td><span class="badge bg-info text-dark">${i.bookCopy.conditionRating}</span></td>
                                                <td>${i.quantity}</td>
                                                <td><fmt:formatNumber value="${i.price}" pattern="#,#00 ₫"/></td>
                                                <td class="fw-bold text-danger"><fmt:formatNumber value="${i.price * i.quantity}" pattern="#,#00 ₫"/></td>
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
