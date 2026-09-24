<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Đặt Hàng - Sách Cũ Việt"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<div class="container py-4">
    <h3 class="fw-bold mb-4"><i class="fa-solid fa-credit-card text-warning me-2"></i>Đặt Hàng & Thanh Toán</h3>

    <form action="/checkout/place-order" method="POST">
        <div class="row g-4">
            <!-- Left col: Address, Shipping, Payment -->
            <div class="col-lg-7">
                <!-- Address Section -->
                <div class="card border-0 shadow-sm rounded-3 p-4 mb-4">
                    <h5 class="fw-bold mb-3"><i class="fa-solid fa-location-dot text-danger me-2"></i>1. Chọn Địa Chỉ Nhận Hàng</h5>
                    <c:choose>
                        <c:when test="${not empty addresses}">
                            <div class="mb-3">
                                <c:forEach var="addr" items="${addresses}">
                                    <div class="form-check border rounded-3 p-3 mb-2">
                                        <input class="form-check-input mt-1" type="radio" name="addressId" id="addr_${addr.id}" value="${addr.id}" ${addr.isDefault ? 'checked' : ''}>
                                        <label class="form-check-label w-100 ms-2" for="addr_${addr.id}">
                                            <strong class="text-dark">${addr.recipientName}</strong> | <span class="text-muted">${addr.phone}</span>
                                            <c:if test="${addr.isDefault}">
                                                <span class="badge bg-warning text-dark ms-2">Mặc định</span>
                                            </c:if>
                                            <br>
                                            <small class="text-secondary">${addr.street}, ${addr.ward != null ? addr.ward : ''}, ${addr.district != null ? addr.district : ''}, ${addr.city}</small>
                                        </label>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <p class="text-muted small">Bạn chưa có địa chỉ lưu sẵn. Nhập trực tiếp bên dưới:</p>
                        </c:otherwise>
                    </c:choose>

                    <hr>
                    <h6>Hoặc nhập thông tin địa chỉ mới:</h6>
                    <div class="row g-2">
                        <div class="col-md-6">
                            <input type="text" name="recipientName" class="form-control form-control-sm" placeholder="Họ tên người nhận" value="${user.fullName}">
                        </div>
                        <div class="col-md-6">
                            <input type="text" name="phone" class="form-control form-control-sm" placeholder="Số điện thoại" value="${user.phone}">
                        </div>
                        <div class="col-12">
                            <input type="text" name="shippingAddress" class="form-control form-control-sm" placeholder="Địa chỉ giao hàng đầy đủ (Số nhà, Đường, Phường, Quận, Thành phố)">
                        </div>
                    </div>
                </div>

                <!-- Shipping Provider -->
                <div class="card border-0 shadow-sm rounded-3 p-4 mb-4">
                    <h5 class="fw-bold mb-3"><i class="fa-solid fa-truck text-primary me-2"></i>2. Phương Thức Vận Chuyển</h5>
                    <div class="alert alert-light border small text-dark mb-3">
                        <i class="fa-solid fa-circle-info text-info me-1"></i>
                        <strong>Vận chuyển Trong Tỉnh:</strong> Giao Hàng Nhanh - GHN (Tiêu chuẩn 20k / Hỏa tốc 40k).<br>
                        <i class="fa-solid fa-circle-info text-warning me-1"></i>
                        <strong>Vận chuyển Ngoại Tỉnh:</strong> SPX Express (Shopee Xpress 32k).
                    </div>
                    <c:forEach var="sp" items="${shippingProviders}" varStatus="loop">
                        <div class="form-check border rounded-3 p-3 mb-2 shipping-provider-card">
                            <input class="form-check-input mt-1" type="radio" name="shippingProviderId" id="sp_${sp.id}" value="${sp.id}" data-fee="${sp.baseFee != null ? sp.baseFee : 20000}" ${loop.first ? 'checked' : ''} onchange="updateShippingFeeInfo()">
                            <label class="form-check-label ms-2 w-100" for="sp_${sp.id}">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <strong class="text-dark">${sp.name}</strong>
                                        <c:choose>
                                            <c:when test="${sp.code == 'GHN_EXPRESS'}">
                                                <span class="badge bg-danger ms-1"><i class="fa-solid fa-bolt me-1"></i>Hỏa Tốc</span>
                                            </c:when>
                                            <c:when test="${sp.code == 'SPX_EXPRESS'}">
                                                <span class="badge bg-warning text-dark ms-1"><i class="fa-solid fa-globe me-1"></i>Ngoại Tỉnh</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-primary ms-1"><i class="fa-solid fa-house me-1"></i>Trong Tỉnh</span>
                                            </c:otherwise>
                                        </c:choose>
                                        <br>
                                        <small class="text-muted"><i class="fa-regular fa-clock me-1"></i>${sp.estimatedDays != null ? sp.estimatedDays : '1-2 ngày'} | ${sp.scopeDescription != null ? sp.scopeDescription : ''}</small>
                                    </div>
                                    <span class="fw-bold text-danger fs-6">
                                        <fmt:formatNumber value="${sp.baseFee != null ? sp.baseFee : 20000}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </span>
                                </div>
                            </label>
                        </div>
                    </c:forEach>
                </div>

                <!-- Payment Method -->
                <div class="card border-0 shadow-sm rounded-3 p-4 mb-4">
                    <h5 class="fw-bold mb-3"><i class="fa-solid fa-wallet text-success me-2"></i>3. Phương Thức Thanh Toán</h5>
                    <div class="form-check border rounded-3 p-3 mb-2">
                        <input class="form-check-input" type="radio" name="paymentMethod" id="pm_cod" value="COD" checked>
                        <label class="form-check-label fw-bold ms-2" for="pm_cod">
                            <i class="fa-solid fa-money-bill-wave text-success me-2"></i>Thanh toán khi nhận hàng (COD)
                        </label>
                    </div>
                    <div class="form-check border rounded-3 p-3">
                        <input class="form-check-input" type="radio" name="paymentMethod" id="pm_vnpay" value="VNPAY">
                        <label class="form-check-label fw-bold ms-2" for="pm_vnpay">
                            <i class="fa-solid fa-qrcode text-primary me-2"></i>Thanh toán qua VNPAY (Demo QR Sandbox)
                        </label>
                    </div>
                </div>

                <!-- Note -->
                <div class="card border-0 shadow-sm rounded-3 p-4">
                    <h5 class="fw-bold mb-2">Ghi chú cho đơn hàng</h5>
                    <textarea name="note" class="form-control" rows="2" placeholder="Ghi chú thêm về thời gian giao hàng, chỉ dẫn tìm nhà..."></textarea>
                </div>
            </div>

            <!-- Right col: Order Summary -->
            <div class="col-lg-5">
                <div class="card border-0 shadow-sm rounded-3 p-4 sticky-top" style="top: 90px;">
                    <h5 class="fw-bold mb-3 border-bottom pb-2">Đơn Hàng Của Bạn</h5>
                    <div class="mb-3" style="max-height: 250px; overflow-y: auto;">
                        <c:forEach var="ci" items="${cartItems}">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <div class="d-flex align-items-center gap-2">
                                    <img src="${ci.bookCopy.book.coverUrl != null ? ci.bookCopy.book.coverUrl : 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'}" width="40" height="50" class="rounded" style="object-fit: cover;">
                                    <div>
                                        <small class="fw-bold text-dark d-block text-truncate" style="max-width: 180px;">${ci.bookCopy.book.title}</small>
                                        <small class="text-muted">x${ci.quantity} (${ci.bookCopy.conditionRating})</small>
                                    </div>
                                </div>
                                <span class="fw-bold small">
                                    <fmt:formatNumber value="${ci.bookCopy.sellingPrice * ci.quantity}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </span>
                            </div>
                        </c:forEach>
                    </div>

                    <!-- Voucher -->
                    <div class="mb-3">
                        <label class="form-label small fw-medium">Mã Giảm Giá / Voucher</label>
                        <div class="input-group input-group-sm">
                            <input type="text" name="voucherCode" class="form-control" placeholder="Nhập mã voucher (nếu có)">
                        </div>
                    </div>

                    <hr>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Tạm tính sách:</span>
                        <span class="fw-bold"><fmt:formatNumber value="${subtotal}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                    </div>
                    <div class="d-flex justify-content-between mb-2">
                        <span>Phí giao hàng:</span>
                        <span class="fw-bold text-primary" id="displayShipFee">20.000đ</span>
                    </div>
                    <hr>
                    <div class="d-flex justify-content-between mb-4">
                        <span class="fw-bold fs-5">Tổng cộng:</span>
                        <span class="fw-bold fs-5 text-danger" id="displayTotal"><fmt:formatNumber value="${subtotal + 20000}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                    </div>

                    <button type="submit" class="btn btn-warning w-100 btn-lg rounded-pill fw-bold text-dark shadow-sm">
                        Xác Nhận Đặt Hàng <i class="fa-solid fa-check-circle ms-2"></i>
                    </button>
                </div>
            </div>
        </div>
    </form>
</div>

<script>
    const subtotal = ${subtotal != null ? subtotal : 0};

    function formatVND(amount) {
        return new Intl.NumberFormat('vi-VN').format(amount) + 'đ';
    }

    function updateShippingFeeInfo() {
        const selectedRadio = document.querySelector('input[name="shippingProviderId"]:checked');
        let shipFee = 20000;
        if (selectedRadio) {
            shipFee = parseFloat(selectedRadio.getAttribute('data-fee')) || 20000;
        }

        const displayShipFee = document.getElementById('displayShipFee');
        const displayTotal = document.getElementById('displayTotal');

        if (displayShipFee) displayShipFee.textContent = formatVND(shipFee);
        if (displayTotal) displayTotal.textContent = formatVND(subtotal + shipFee);
    }

    document.addEventListener("DOMContentLoaded", function() {
        updateShippingFeeInfo();
    });
</script>
</div>

<jsp:include page="../common/footer.jsp"/>
