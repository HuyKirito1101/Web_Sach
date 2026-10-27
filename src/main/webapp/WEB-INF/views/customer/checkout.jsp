<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Đặt Hàng - Sách Cũ Việt"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<style>
    .voucher-card-active {
        background-color: #ffffff;
        border: 1.5px solid #ffc107;
        transition: all 0.2s ease-in-out;
    }
    .voucher-card-active:hover {
        box-shadow: 0 4px 12px rgba(255, 193, 7, 0.25);
        transform: translateY(-1px);
        border-color: #ff9800;
    }
    .voucher-card-active.voucher-selected {
        background-color: #fff9e6 !important;
        border: 2px solid #198754 !important;
        box-shadow: 0 4px 12px rgba(25, 135, 84, 0.2) !important;
    }
    .voucher-card-disabled {
        background-color: #e9ecef !important;
        border: 1px dashed #adb5bd !important;
        opacity: 0.62;
        cursor: not-allowed;
        filter: grayscale(30%);
    }
    .voucher-card-disabled * {
        user-select: none;
    }
</style>

<div class="container py-4">
    <h3 class="fw-bold mb-4"><i class="fa-solid fa-credit-card text-warning me-2"></i>Đặt Hàng &amp; Thanh Toán</h3>

    <!-- Error message -->
    <c:if test="${errorMessage != null}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fa-solid fa-circle-exclamation me-2"></i><c:out value="${errorMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <form action="/checkout/place-order" method="POST" id="checkoutForm">
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
                        Chỉ các dịch vụ có shipper thật đang hoạt động mới được hiển thị. Phí giao hàng lấy trực tiếp từ cấu hình nhà vận chuyển.
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

                    <!-- MoMo demo: cửa hàng kiểm tra giao dịch và xác nhận thủ công -->
                    <div class="form-check border border-danger-subtle rounded-3 p-3 mb-2 bg-danger bg-opacity-10">
                        <input class="form-check-input" type="radio" name="paymentMethod" id="pm_momo" value="MOMO">
                        <label class="form-check-label ms-2 w-100" for="pm_momo">
                            <div class="d-flex align-items-center gap-2">
                                <i class="fa-solid fa-qrcode text-danger fs-5"></i>
                                <div>
                                    <strong>Chuyển khoản MoMo (Demo)</strong>
                                    <br><small class="text-muted">Quét QR sau khi đặt hàng và chờ Manager chi nhánh xác nhận</small>
                                </div>
                            </div>
                        </label>
                    </div>

                    <div class="alert alert-warning small mb-0">
                        <i class="fa-solid fa-triangle-exclamation me-1"></i>
                        Đây là quy trình xác nhận thủ công, không phải cổng thanh toán MoMo API tự động.
                    </div>
                </div>

                <!-- Note -->
                <div class="card border-0 shadow-sm rounded-3 p-4">
                    <h5 class="fw-bold mb-2">Ghi chú cho đơn hàng</h5>
                    <textarea name="note" class="form-control" rows="2" maxlength="1000" placeholder="Ghi chú thêm về thời gian giao hàng, chỉ dẫn tìm nhà..."></textarea>
                </div>
            </div>

            <!-- Right col: Order Summary -->
            <div class="col-lg-5">
                <div class="card border-0 shadow-sm rounded-3 p-4 sticky-top" style="top: 90px;">
                    <h5 class="fw-bold mb-3 border-bottom pb-2">Đơn Hàng Của Bạn</h5>
                    <div class="mb-3" style="max-height: 230px; overflow-y: auto;">
                        <c:forEach var="ci" items="${cartItems}">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <div class="d-flex align-items-center gap-2">
                                    <img src="<c:out value='${ci.bookCopy.book.coverUrl != null ? ci.bookCopy.book.coverUrl : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400"}'/>"
                                         width="40" height="50" class="rounded" style="object-fit: cover;"
                                         onerror="this.src='https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'">
                                    <div>
                                        <small class="fw-bold text-dark d-block text-truncate" style="max-width: 170px;"><c:out value="${ci.bookCopy.book.title}"/></small>
                                        <small class="text-muted">x${ci.quantity} (${ci.bookCopy.conditionRating})</small>
                                        <c:if test="${not empty ci.bookCopy.seller}">
                                            <small class="text-primary d-block" style="font-size: 11px;">
                                                <i class="fa-solid fa-store me-1"></i>${ci.bookCopy.seller.fullName}
                                            </small>
                                        </c:if>
                                    </div>
                                </div>
                                <span class="fw-bold small">
                                    <fmt:formatNumber value="${ci.bookCopy.sellingPrice * ci.quantity}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </span>
                            </div>
                        </c:forEach>
                    </div>

                    <!-- MÃ GIẢM GIÁ / KHUYẾN MÃI -->
                    <div class="border rounded-3 p-3 mb-3 bg-light bg-opacity-50">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <label class="form-label small fw-bold mb-0 text-dark">
                                <i class="fa-solid fa-ticket text-warning me-1"></i>Mã Giảm Giá / Khuyến Mãi
                            </label>
                            <c:if test="${applicableCount != null && applicableCount > 0}">
                                <span class="badge bg-success bg-opacity-10 text-success border border-success-subtle small">
                                    ${applicableCount} mã dùng được
                                </span>
                            </c:if>
                        </div>

                        <!-- Ô nhập mã và nút Áp dụng -->
                        <div class="input-group input-group-sm mb-2">
                            <input type="text" name="voucherCode" id="voucherCode" class="form-control font-monospace"
                                   placeholder="Nhập mã hoặc chọn bên dưới" autocomplete="off">
                            <button class="btn btn-warning text-dark fw-bold px-3" type="button" onclick="applyVoucher()">Áp Dụng</button>
                            <button class="btn btn-outline-secondary" type="button" id="btnClearVoucher" onclick="clearVoucher()" style="display: none;" title="Bỏ chọn mã">
                                <i class="fa-solid fa-xmark"></i>
                            </button>
                        </div>
                        <div id="voucherMsg" class="small mb-2"></div>

                        <!-- Danh sách mã giảm giá -->
                        <c:if test="${not empty allVouchers}">
                            <div class="voucher-list mt-2" style="max-height: 250px; overflow-y: auto; padding-right: 2px;">
                                <c:forEach var="v" items="${allVouchers}">
                                    <c:choose>
                                        <%-- 1. MÃ CÓ THỂ ÁP DỤNG: HIỆN SÁNG VÀ USER CÓ THỂ CHỌN --%>
                                        <c:when test="${v.applicable}">
                                            <div class="voucher-card voucher-card-active rounded-3 p-2 mb-2 shadow-sm"
                                                 style="cursor: pointer;"
                                                 data-voucher-code="<c:out value='${v.code}'/>"
                                                 onclick="selectVoucher('<c:out value="${v.code}"/>')">
                                                <div class="d-flex justify-content-between align-items-start">
                                                    <div style="max-width: 75%;">
                                                        <span class="badge ${v.scopeType == 'ADMIN' ? 'bg-danger' : (v.scopeType == 'MANAGER' ? 'bg-primary' : 'bg-success')} text-white me-1 mb-1" style="font-size: 10px;">
                                                            <i class="fa-solid ${v.scopeType == 'ADMIN' ? 'fa-crown' : (v.scopeType == 'MANAGER' ? 'fa-building' : 'fa-store')} me-1"></i>
                                                            <c:out value="${v.scopeName}"/>
                                                        </span>
                                                        <div class="fw-bold text-dark small">
                                                            <c:out value="${v.title}"/>
                                                            <span class="badge bg-light text-dark border ms-1 font-monospace" style="font-size: 10px;"><c:out value="${v.code}"/></span>
                                                        </div>
                                                        <div class="text-secondary small mt-1" style="font-size: 11px;">
                                                            Giảm <strong>${v.discountPercent}%</strong>
                                                            <c:if test="${v.maxDiscountAmount != null}">
                                                                (tối đa <fmt:formatNumber value="${v.maxDiscountAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>)
                                                            </c:if>
                                                            <c:if test="${v.minOrderValue != null && v.minOrderValue > 0}">
                                                                &bull; Đơn tối thiểu: <fmt:formatNumber value="${v.minOrderValue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                    <div class="text-end">
                                                        <span class="badge bg-warning text-dark fw-bold px-2 py-1">-${v.discountPercent}%</span>
                                                        <button type="button" class="btn btn-sm btn-outline-warning text-dark fw-bold rounded-pill mt-2 px-2 py-0 voucher-btn" style="font-size: 11px;">
                                                            Chọn
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:when>

                                        <%-- 2. MÃ KHÔNG ÁP DỤNG ĐƯỢC: HIỆN HƠI TỐI / MỜ, KHÔNG CHỌN ĐƯỢC --%>
                                        <c:otherwise>
                                            <div class="voucher-card voucher-card-disabled rounded-3 p-2 mb-2"
                                                 title="Mã này không đủ điều kiện áp dụng cho đơn hàng hiện tại">
                                                <div class="d-flex justify-content-between align-items-start">
                                                    <div style="max-width: 75%;">
                                                        <span class="badge bg-secondary text-white me-1 mb-1" style="font-size: 10px;">
                                                            <i class="fa-solid fa-lock me-1"></i><c:out value="${v.scopeName}"/>
                                                        </span>
                                                        <div class="fw-bold text-muted small">
                                                            <c:out value="${v.title}"/>
                                                            <span class="badge bg-secondary-subtle text-secondary border ms-1 font-monospace" style="font-size: 10px;"><c:out value="${v.code}"/></span>
                                                        </div>
                                                        <div class="text-muted small mt-1" style="font-size: 11px;">
                                                            Giảm ${v.discountPercent}%
                                                            <c:if test="${v.maxDiscountAmount != null}">
                                                                (tối đa <fmt:formatNumber value="${v.maxDiscountAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>)
                                                            </c:if>
                                                        </div>
                                                        <div class="small text-danger fw-medium mt-1" style="font-size: 11px;">
                                                            <i class="fa-solid fa-circle-exclamation me-1"></i><c:out value="${v.reason}"/>
                                                        </div>
                                                    </div>
                                                    <div class="text-end">
                                                        <span class="badge bg-secondary text-light px-2 py-1" style="font-size: 10px;">Không khả dụng</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
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
                        <span class="text-success"><i class="fa-solid fa-tag me-1"></i>Giảm giá voucher:</span>
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
    let selectedVoucherCode = "";

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
        const total = Math.max(0, subtotal + shipFee - discountAmount);
        document.getElementById('displayTotal').textContent = formatVND(total);
    }

    function selectVoucher(code) {
        if (!code) return;
        const inputEl = document.getElementById('voucherCode');
        // Nếu click lại vào mã đang chọn -> hủy chọn
        if (selectedVoucherCode === code && inputEl.value.trim().toUpperCase() === code.trim().toUpperCase()) {
            clearVoucher();
            return;
        }
        inputEl.value = code;
        applyVoucher();
    }

    function clearVoucher() {
        document.getElementById('voucherCode').value = '';
        selectedVoucherCode = "";
        discountAmount = 0;
        document.getElementById('voucherMsg').innerHTML = '';
        document.getElementById('discountRow').style.display = 'none';
        document.getElementById('btnClearVoucher').style.display = 'none';
        resetVoucherCards();
        updateShippingFeeInfo();
    }

    function resetVoucherCards() {
        document.querySelectorAll('.voucher-card-active').forEach(function(card) {
            card.classList.remove('voucher-selected');
            const btn = card.querySelector('.voucher-btn');
            if (btn) {
                btn.innerHTML = 'Chọn';
                btn.className = 'btn btn-sm btn-outline-warning text-dark fw-bold rounded-pill mt-2 px-2 py-0 voucher-btn';
            }
        });
    }

    async function applyVoucher() {
        const inputEl = document.getElementById('voucherCode');
        const code = inputEl.value.trim();
        const msgEl = document.getElementById('voucherMsg');
        const clearBtn = document.getElementById('btnClearVoucher');

        if (!code) {
            clearVoucher();
            return;
        }

        try {
            const response = await fetch('/checkout/voucher-preview?code=' + encodeURIComponent(code), {
                headers: {'Accept': 'application/json'}
            });
            const result = await response.json();
            if (!response.ok || !result.valid) {
                throw new Error(result.message || 'Mã giảm giá không hợp lệ.');
            }

            discountAmount = Number(result.discountAmount) || 0;
            selectedVoucherCode = result.code || code;
            inputEl.value = selectedVoucherCode;

            msgEl.innerHTML = '<span class="text-success fw-bold"><i class="fa-solid fa-circle-check me-1"></i>'
                + (result.message || ('Áp dụng thành công mã: ' + selectedVoucherCode)) + '</span>';
            document.getElementById('discountRow').style.display = 'flex';
            document.getElementById('displayDiscount').textContent = '-' + formatVND(discountAmount);
            clearBtn.style.display = 'block';

            // Highlight card
            resetVoucherCards();
            document.querySelectorAll('.voucher-card-active').forEach(function(card) {
                const cardCode = card.getAttribute('data-voucher-code');
                if (cardCode && (cardCode.toUpperCase() === selectedVoucherCode.toUpperCase() || cardCode.toUpperCase() === code.toUpperCase())) {
                    card.classList.add('voucher-selected');
                    const btn = card.querySelector('.voucher-btn');
                    if (btn) {
                        btn.innerHTML = '<i class="fa-solid fa-check me-1"></i>Đang dùng';
                        btn.className = 'btn btn-sm btn-success text-white fw-bold rounded-pill mt-2 px-2 py-0 voucher-btn';
                    }
                }
            });

        } catch (error) {
            discountAmount = 0;
            selectedVoucherCode = "";
            msgEl.innerHTML = '<span class="text-danger fw-bold"><i class="fa-solid fa-circle-xmark me-1"></i>' + (error.message || 'Không thể kiểm tra mã.') + '</span>';
            document.getElementById('discountRow').style.display = 'none';
            clearBtn.style.display = 'none';
            resetVoucherCards();
        }

        updateShippingFeeInfo();
    }

    document.addEventListener("DOMContentLoaded", function() {
        updateShippingFeeInfo();
    });
</script>

<jsp:include page="../common/footer.jsp"/>
