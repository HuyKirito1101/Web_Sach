<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Đặt Hàng - Sách Cũ Việt"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<div class="container py-4">
    <h3 class="fw-bold mb-4"><i class="fa-solid fa-credit-card text-warning me-2"></i>Đặt Hàng &amp; Thanh Toán</h3>

    <!-- Error message -->
    <c:if test="${errorMessage != null}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fa-solid fa-circle-exclamation me-2"></i><c:out value="${errorMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <form action="/checkout/place-order" method="POST">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
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
                                    <div class="form-check border rounded-3 p-3 mb-2 ${addr.isDefault ? 'border-warning bg-warning bg-opacity-10' : ''}">
                                        <input class="form-check-input mt-1" type="radio" name="addressId"
                                               id="addr_${addr.id}" value="${addr.id}" ${addr.isDefault ? 'checked' : ''}>
                                        <label class="form-check-label w-100 ms-2" for="addr_${addr.id}">
                                            <strong class="text-dark"><c:out value="${addr.recipientName}"/></strong> | <span class="text-muted"><c:out value="${addr.phone}"/></span>
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
                    <h6>Hoặc nhập địa chỉ mới:</h6>
                    <div class="row g-2">
                        <div class="col-md-6">
                            <input type="text" name="recipientName" class="form-control form-control-sm" placeholder="Họ tên người nhận" value="<c:out value='${user.fullName}'/>">
                        </div>
                        <div class="col-md-6">
                            <input type="text" name="phone" class="form-control form-control-sm" placeholder="Số điện thoại" value="<c:out value='${user.phone}'/>">
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
                            <input class="form-check-input mt-1" type="radio" name="shippingProviderId"
                                   id="sp_${sp.id}" value="${sp.id}"
                                   data-fee="${sp.baseFee != null ? sp.baseFee : 20000}"
                                   ${loop.first ? 'checked' : ''} onchange="updateShippingFeeInfo()">
                            <label class="form-check-label ms-2 w-100" for="sp_${sp.id}">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <strong class="text-dark"><c:out value="${sp.name}"/></strong>
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

                    <!-- COD -->
                    <div class="form-check border rounded-3 p-3 mb-2">
                        <input class="form-check-input" type="radio" name="paymentMethod" id="pm_cod" value="COD" checked>
                        <label class="form-check-label ms-2 w-100" for="pm_cod">
                            <div class="d-flex align-items-center gap-2">
                                <i class="fa-solid fa-money-bill-wave text-success fs-5"></i>
                                <div>
                                    <strong>Thanh toán khi nhận hàng (COD)</strong>
                                    <br><small class="text-muted">Trả tiền mặt khi nhận hàng</small>
                                </div>
                            </div>
                        </label>
                    </div>

                    <!-- VNPAY -->
                    <div class="form-check border rounded-3 p-3 mb-2">
                        <input class="form-check-input" type="radio" name="paymentMethod" id="pm_vnpay" value="VNPAY">
                        <label class="form-check-label ms-2 w-100" for="pm_vnpay">
                            <div class="d-flex align-items-center gap-2">
                                <i class="fa-solid fa-qrcode text-primary fs-5"></i>
                                <div>
                                    <strong>Thanh toán qua VNPAY</strong>
                                    <br><small class="text-muted">QR Code, ATM, Thẻ Visa/Master, Internet Banking</small>
                                </div>
                                <span class="badge bg-primary ms-auto">QR</span>
                            </div>
                        </label>
                    </div>

                    <!-- MOMO -->
                    <div class="form-check border rounded-3 p-3">
                        <input class="form-check-input" type="radio" name="paymentMethod" id="pm_momo" value="MOMO">
                        <label class="form-check-label ms-2 w-100" for="pm_momo">
                            <div class="d-flex align-items-center gap-2">
                                <span class="fw-bold text-white rounded-circle d-flex align-items-center justify-content-center" style="width:30px;height:30px;background-color:#ae2070;font-size:12px;">M</span>
                                <div>
                                    <strong>Thanh toán qua MOMO</strong>
                                    <br><small class="text-muted">Ví điện tử MOMO - Quét QR hoặc chuyển khoản</small>
                                </div>
                                <span class="badge ms-auto" style="background-color:#ae2070;">MoMo</span>
                            </div>
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
                                    <img src="<c:out value='${ci.bookCopy.book.coverUrl != null ? ci.bookCopy.book.coverUrl : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400"}'/>"
                                         width="40" height="50" class="rounded" style="object-fit: cover;"
                                         onerror="this.src='https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'">
                                    <div>
                                        <small class="fw-bold text-dark d-block text-truncate" style="max-width: 180px;"><c:out value="${ci.bookCopy.book.title}"/></small>
                                        <small class="text-muted">x${ci.quantity} (${ci.bookCopy.conditionRating})</small>
                                    </div>
                                </div>
                                <span class="fw-bold small">
                                    <fmt:formatNumber value="${ci.bookCopy.sellingPrice * ci.quantity}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </span>
                            </div>
                        </c:forEach>
                    </div>

                    <!-- Mã giảm giá / Voucher -->
                    <div class="mb-3">
                        <label class="form-label small fw-medium"><i class="fa-solid fa-tag text-warning me-1"></i>Mã Giảm Giá / Voucher</label>
                        <div class="input-group input-group-sm">
                            <input type="text" name="voucherCode" id="voucherCode" class="form-control" placeholder="Nhập mã voucher (nếu có)">
                            <button class="btn btn-warning text-dark fw-bold" type="button" onclick="applyVoucher()">Áp Dụng</button>
                        </div>
                        <div id="voucherMsg" class="small mt-1"></div>
                        <!-- Danh sách voucher gợi ý -->
                        <c:if test="${not empty availableDiscounts}">
                            <div class="mt-2">
                                <small class="text-muted fw-medium">Mã có thể dùng:</small>
                                <c:forEach var="disc" items="${availableDiscounts}">
                                    <div class="border rounded-2 p-2 mt-1 d-flex justify-content-between align-items-center voucher-option"
                                         style="cursor:pointer;background:#fffbea;" data-voucher-code="<c:out value='${disc.code}'/>">
                                        <div>
                                            <span class="badge bg-warning text-dark me-1"><c:out value="${disc.code}"/></span>
                                            <small class="text-dark">Giảm ${disc.discountPercent}%<c:if test="${disc.maxDiscountAmount != null}"> (tối đa <fmt:formatNumber value="${disc.maxDiscountAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>)</c:if></small>
                                        </div>
                                        <span class="text-danger small fw-bold">-${disc.discountPercent}%</span>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>
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
                    <div class="d-flex justify-content-between mb-2" id="discountRow" style="display:none!important;">
                        <span class="text-success">Giảm giá voucher:</span>
                        <span class="fw-bold text-success" id="displayDiscount">0đ</span>
                    </div>
                    <hr>
                    <div class="d-flex justify-content-between mb-4">
                        <span class="fw-bold fs-5">Tổng cộng:</span>
                        <span class="fw-bold fs-5 text-danger" id="displayTotal">
                            <fmt:formatNumber value="${subtotal + 20000}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                        </span>
                    </div>

                    <button type="submit" class="btn btn-warning w-100 btn-lg rounded-pill fw-bold text-dark shadow-sm">
                        Xác Nhận Đặt Hàng <i class="fa-solid fa-check-circle ms-2"></i>
                    </button>
                    <a href="/cart" class="btn btn-light w-100 rounded-pill fw-medium mt-2">
                        <i class="fa-solid fa-arrow-left me-1"></i>Quay lại Giỏ Hàng
                    </a>
                </div>
            </div>
        </div>
    </form>
</div>

<script>
    const subtotal = ${subtotal != null ? subtotal : 0};
    let discountAmount = 0;

    function formatVND(amount) {
        return new Intl.NumberFormat('vi-VN').format(Math.round(amount)) + 'đ';
    }

    function updateShippingFeeInfo() {
        const selectedRadio = document.querySelector('input[name="shippingProviderId"]:checked');
        let shipFee = 20000;
        if (selectedRadio) {
            shipFee = parseFloat(selectedRadio.getAttribute('data-fee')) || 20000;
        }
        document.getElementById('displayShipFee').textContent = formatVND(shipFee);
        const total = subtotal + shipFee - discountAmount;
        document.getElementById('displayTotal').textContent = formatVND(total);
    }

    function selectVoucher(code) {
        document.getElementById('voucherCode').value = code;
        applyVoucher();
    }

    function applyVoucher() {
        const code = document.getElementById('voucherCode').value.trim();
        const msgEl = document.getElementById('voucherMsg');
        if (!code) {
            msgEl.innerHTML = '';
            return;
        }
        // Demo: giảm 10% nếu nhập "SACH10"
        if (code.toUpperCase() === 'SACH10') {
            discountAmount = subtotal * 0.10;
            msgEl.innerHTML = '<span class="text-success"><i class="fa-solid fa-check me-1"></i>Đã áp dụng mã giảm 10%!</span>';
            document.getElementById('discountRow').style.display = 'flex';
            document.getElementById('displayDiscount').textContent = '-' + formatVND(discountAmount);
        } else {
            discountAmount = 0;
            msgEl.innerHTML = '<span class="text-danger"><i class="fa-solid fa-x me-1"></i>Mã không hợp lệ hoặc đã hết hạn</span>';
            document.getElementById('discountRow').style.display = 'none';
        }
        updateShippingFeeInfo();
    }

    document.addEventListener("DOMContentLoaded", function() {
        updateShippingFeeInfo();
        document.querySelectorAll('.voucher-option').forEach(function (option) {
            option.addEventListener('click', function () {
                selectVoucher(option.dataset.voucherCode);
            });
        });
    });
</script>

<jsp:include page="../common/footer.jsp"/>
