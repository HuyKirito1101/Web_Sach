<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Giỏ Hàng Của Bạn - Sách Cũ Việt"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<div class="container py-4">
    <h3 class="fw-bold mb-4"><i class="fa-solid fa-cart-shopping text-warning me-2"></i>Giỏ Hàng Của Bạn</h3>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show rounded-3 mb-4 shadow-sm" role="alert">
            <i class="fa-solid fa-triangle-exclamation me-2"></i><strong>Lỗi:</strong> ${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show rounded-3 mb-4 shadow-sm" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i>${successMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <c:choose>
        <c:when test="${empty cartItems}">
            <div class="card border-0 shadow-sm text-center py-5 rounded-3">
                <i class="fa-solid fa-cart-arrow-down fs-1 text-secondary mb-3"></i>
                <h5>Giỏ hàng của bạn đang trống!</h5>
                <p class="text-muted">Hãy tìm thêm các cuốn sách cũ ưa thích để thêm vào giỏ.</p>
                <div class="mt-2">
                    <a href="/books" class="btn btn-warning rounded-pill fw-bold px-4">Khám Phá Sách Ngay</a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="row g-4">
                <div class="col-lg-8">
                    <div class="card border-0 shadow-sm rounded-3 p-3">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead>
                                    <tr>
                                        <th>Sản Phẩm Sách Cũ</th>
                                        <th>Chi Nhánh</th>
                                        <th>Đơn Giá</th>
                                        <th>Số Lượng</th>
                                        <th>Thành Tiền</th>
                                        <th>Thao Tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="item" items="${cartItems}">
                                        <tr>
                                            <td>
                                                <div class="d-flex align-items-center gap-2">
                                                    <img src="${item.bookCopy.book.coverUrl != null ? item.bookCopy.book.coverUrl : 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'}" width="50" height="65" class="rounded" style="object-fit: cover;">
                                                    <div>
                                                        <h6 class="mb-0 text-dark fw-bold">${item.bookCopy.book.title}</h6>
                                                        <small class="badge bg-light text-dark border">Tình trạng: ${item.bookCopy.conditionRating}</small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="small fw-medium text-secondary">${item.bookCopy.branch.name}</td>
                                            <td class="fw-bold text-danger">
                                                <fmt:formatNumber value="${item.bookCopy.sellingPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                            </td>
                                            <td>
                                                <form action="/cart/update" method="POST" class="d-flex align-items-center gap-1">
                                                    <input type="hidden" name="cartItemId" value="${item.id}"/>
                                                    <input type="number" name="quantity" value="${item.quantity}" min="1" max="${item.bookCopy.quantity}" class="form-control form-control-sm text-center" style="width: 60px;" onchange="this.form.submit()">
                                                </form>
                                            </td>
                                            <td class="fw-bold text-dark">
                                                <fmt:formatNumber value="${item.bookCopy.sellingPrice * item.quantity}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                            </td>
                                            <td>
                                                <form action="/cart/delete" method="POST">
                                                    <input type="hidden" name="cartItemId" value="${item.id}"/>
                                                    <button type="submit" class="btn btn-outline-danger btn-sm rounded-circle" title="Xóa">
                                                        <i class="fa-solid fa-trash"></i>
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="card border-0 shadow-sm rounded-3 p-4">
                        <h5 class="fw-bold mb-3 border-bottom pb-2">Tóm Tắt Đơn Hàng</h5>
                        <div class="d-flex justify-content-between mb-2">
                            <span>Tạm tính:</span>
                            <span class="fw-bold text-dark">
                                <fmt:formatNumber value="${totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </span>
                        </div>
                        <div class="d-flex justify-content-between mb-3">
                            <span>Phí giao hàng:</span>
                            <span class="text-muted small">Tính tại bước Checkout</span>
                        </div>
                        <hr>
                        <div class="d-flex justify-content-between mb-4">
                            <span class="fw-bold fs-5">Tổng tiền:</span>
                            <span class="fw-bold fs-5 text-danger">
                                <fmt:formatNumber value="${totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </span>
                        </div>

                        <a href="/checkout" class="btn btn-warning w-100 btn-lg rounded-pill fw-bold text-dark shadow-sm">
                            Tiến Hành Thanh Toán <i class="fa-solid fa-arrow-right ms-2"></i>
                        </a>
                        <a href="/books" class="btn btn-light w-100 rounded-pill fw-medium mt-2">Tiếp tục mua hàng</a>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="../common/footer.jsp"/>
