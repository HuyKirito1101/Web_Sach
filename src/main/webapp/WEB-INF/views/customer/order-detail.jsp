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

    <c:if test="${param.paymentSuccess}">
        <div class="alert alert-success alert-dismissible fade show rounded-3 mb-4 shadow-sm" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i><strong>Thanh toán trực tuyến thành công!</strong> Đơn hàng đã được xác nhận thanh toán.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <c:if test="${param.paymentFailed}">
        <div class="alert alert-warning alert-dismissible fade show rounded-3 mb-4 shadow-sm" role="alert">
            <i class="fa-solid fa-triangle-exclamation me-2"></i><strong>Thanh toán chưa hoàn tất / đã bị hủy!</strong> Bạn có thể chọn thanh toán lại hoặc liên hệ hỗ trợ.
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
                                            <img src="<c:out value='${item.bookCopy.book.coverUrl != null ? item.bookCopy.book.coverUrl : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400"}'/>" width="40" height="50" class="rounded" style="object-fit: cover;">
                                            <div>
                                                <h6 class="mb-0 text-dark fw-bold"><c:out value="${item.bookCopy.book.title}"/></h6>
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
                            <c:if test="${not empty _csrf}">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                            </c:if>
                            <div class="mb-2">
                                <label class="form-label small fw-medium">Lý do hủy đơn:</label>
                                <input type="text" name="reason" class="form-control form-control-sm" placeholder="Đổi ý, chọn nhầm sách..." required>
                            </div>
                            <button type="submit" class="btn btn-danger btn-sm rounded-pill fw-bold">Hủy Đơn Hàng</button>
                        </form>
                    </c:when>

                    <c:when test="${order.orderStatus == 'DELIVERED'}">
                        <div class="alert alert-warning border-0 small mb-3">
                            <i class="fa-solid fa-rotate-left me-1"></i>
                            <strong>Chính sách đổi trả trong vòng 48h:</strong> Quý khách có thể chọn hoàn trả trực tiếp tại cơ sở chi nhánh (miễn phí ship) hoặc yêu cầu cửa hàng phân công Shipper đến tận nơi lấy sách (khách hàng chịu 50% phí ship).
                        </div>
                        <form action="/orders/${order.id}/return" method="POST" id="returnOrderForm" onsubmit="return confirm('Gửi yêu cầu trả hàng/hoàn tiền cho đơn này?');">
                            <c:if test="${not empty _csrf}">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                            </c:if>

                            <label class="form-label small fw-bold mb-2">Phương thức hoàn trả: <span class="text-danger">*</span></label>
                            <div class="row g-2 mb-3">
                                <div class="col-md-6">
                                    <div class="form-check p-2 border rounded-3 bg-light">
                                        <input class="form-check-input ms-1" type="radio" name="returnMethod" id="methodStore" value="STORE" checked onchange="toggleReturnAddress()">
                                        <label class="form-check-label ms-2 small fw-semibold" for="methodStore">
                                            <i class="fa-solid fa-store text-primary me-1"></i> Trả tại cơ sở chi nhánh
                                            <div class="text-success small fw-normal">Miễn phí ship (Hoàn 100% tiền đơn)</div>
                                        </label>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-check p-2 border rounded-3 bg-light">
                                        <input class="form-check-input ms-1" type="radio" name="returnMethod" id="methodShipper" value="SHIPPER" onchange="toggleReturnAddress()">
                                        <label class="form-check-label ms-2 small fw-semibold" for="methodShipper">
                                            <i class="fa-solid fa-truck text-warning me-1"></i> Shipper đến nhận tại nhà
                                            <div class="text-danger small fw-normal">Khách chịu 50% phí ship</div>
                                        </label>
                                    </div>
                                </div>
                            </div>

                            <!-- Chi tiết tính toán hoàn tiền -->
                            <div class="p-3 mb-3 rounded-3 border bg-light small">
                                <c:set var="baseShipping" value="${order.shippingFee != null && order.shippingFee > 0 ? order.shippingFee : 20000}" />
                                <c:set var="halfShipping" value="${baseShipping * 0.5}" />
                                <c:set var="storeRefund" value="${order.finalAmount}" />
                                <c:set var="shipperRefund" value="${order.finalAmount - halfShipping > 0 ? order.finalAmount - halfShipping : 0}" />
                                <div id="calcStoreInfo">
                                    <div class="mb-1"><strong>Cơ sở tiếp nhận:</strong> <c:out value="${order.branch != null ? order.branch.name : ''}"/> - <c:out value="${order.branch != null ? order.branch.address : ''}"/></div>
                                    <div class="d-flex justify-content-between align-items-center border-top pt-1 text-success fw-bold">
                                        <span>Số tiền được hoàn:</span>
                                        <span><fmt:formatNumber value="${storeRefund}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                                    </div>
                                </div>
                                <div id="calcShipperInfo" class="d-none">
                                    <div class="d-flex justify-content-between mb-1">
                                        <span>50% phí ship hoàn trả khách chịu:</span>
                                        <span class="text-danger fw-bold">-<fmt:formatNumber value="${halfShipping}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                                    </div>
                                    <div class="d-flex justify-content-between border-top pt-1 text-success fw-bold">
                                        <span>Số tiền hoàn lại dự kiến:</span>
                                        <span><fmt:formatNumber value="${shipperRefund}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                                    </div>
                                </div>
                            </div>

                            <div class="mb-3 d-none" id="returnAddressGroup">
                                <label class="form-label small fw-bold">Địa chỉ hoàn trả để Shipper đến lấy sách: <span class="text-danger">*</span></label>
                                <input type="text" name="returnAddress" id="returnAddressInput" class="form-control form-control-sm" value="<c:out value='${order.shippingAddress}'/>" placeholder="Nhập địa chỉ nhà bạn để Shipper đến lấy sách...">
                            </div>

                            <div class="mb-3">
                                <label class="form-label small fw-bold">Lý do yêu cầu trả hàng / hoàn tiền: <span class="text-danger">*</span></label>
                                <input type="text" name="reason" class="form-control form-control-sm" placeholder="Không ưng ý, sách sai tình trạng mô tả..." required>
                            </div>

                            <button type="submit" class="btn btn-warning btn-sm rounded-pill fw-bold px-4">
                                <i class="fa-solid fa-paper-plane me-1"></i> Gửi Yêu Cầu Hoàn Trả
                            </button>
                        </form>

                        <script>
                            function toggleReturnAddress() {
                                const isShipper = document.getElementById('methodShipper').checked;
                                const addrGroup = document.getElementById('returnAddressGroup');
                                const addrInput = document.getElementById('returnAddressInput');
                                const calcStore = document.getElementById('calcStoreInfo');
                                const calcShipper = document.getElementById('calcShipperInfo');
                                if (isShipper) {
                                    addrGroup.classList.remove('d-none');
                                    addrInput.setAttribute('required', 'required');
                                    calcStore.classList.add('d-none');
                                    calcShipper.classList.remove('d-none');
                                } else {
                                    addrGroup.classList.add('d-none');
                                    addrInput.removeAttribute('required');
                                    calcStore.classList.remove('d-none');
                                    calcShipper.classList.add('d-none');
                                }
                            }
                        </script>
                    </c:when>

                    <c:when test="${order.orderStatus == 'RETURN_REQUESTED'}">
                        <div class="alert alert-warning border-0 mb-0">
                            <h6 class="fw-bold mb-2">
                                <i class="fa-solid fa-clock-rotate-left me-1"></i> Yêu Cầu Hoàn Trả Đang Được Xử Lý
                            </h6>
                            <c:choose>
                                <c:when test="${order.returnMethod == 'STORE'}">
                                    <p class="small mb-2">Phương thức: <span class="badge bg-primary">Hoàn trả tại cơ sở</span> (Khách không mất phí ship).</p>
                                    <div class="small text-dark p-2 bg-white rounded border mb-2">
                                        <div><strong>Địa chỉ cơ sở nhận hoàn:</strong> <c:out value="${order.returnAddress}"/></div>
                                        <div><strong>Lý do:</strong> <c:out value="${order.returnReason}"/></div>
                                        <div class="text-success fw-bold mt-1">Số tiền được hoàn: <fmt:formatNumber value="${order.refundAmount != null ? order.refundAmount : order.finalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></div>
                                    </div>
                                    <div class="small text-muted fst-italic">Vui lòng mang sách đến cơ sở chi nhánh trong giờ làm việc để nhân viên kiểm tra và hoàn tiền.</div>
                                </c:when>
                                <c:otherwise>
                                    <p class="small mb-2">Phương thức: <span class="badge bg-warning text-dark">Shipper đến nhận tại nhà</span> (Khách chịu 50% phí ship: <fmt:formatNumber value="${order.returnShippingFee != null ? order.returnShippingFee : 10000}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>).</p>
                                    <div class="small text-dark p-2 bg-white rounded border mb-2">
                                        <div><strong>Địa chỉ lấy sách:</strong> <c:out value="${order.returnAddress != null ? order.returnAddress : order.shippingAddress}"/></div>
                                        <div><strong>Lý do:</strong> <c:out value="${order.returnReason}"/></div>
                                        <div class="text-success fw-bold mt-1">Số tiền hoàn dự kiến: <fmt:formatNumber value="${order.refundAmount != null ? order.refundAmount : order.finalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></div>
                                    </div>
                                    <div class="small text-muted fst-italic">Cửa hàng đang điều phối Shipper đến địa chỉ của bạn để nhận lại sách.</div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </c:when>

                    <c:when test="${order.orderStatus == 'RETURNED'}">
                        <div class="alert alert-info border-0 mb-0">
                            <h6 class="fw-bold mb-1"><i class="fa-solid fa-box-archive me-1"></i> Sách Đã Về Kho Chi Nhánh</h6>
                            <p class="small mb-1">Cửa hàng đã nhận lại sách hoàn trả. Đang tiến hành duyệt hoàn tiền cho bạn.</p>
                            <div class="small fw-bold text-dark">Số tiền hoàn trả: <fmt:formatNumber value="${order.refundAmount != null ? order.refundAmount : order.finalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></div>
                        </div>
                    </c:when>

                    <c:when test="${order.orderStatus == 'REFUNDED'}">
                        <div class="alert alert-success border-0 mb-0">
                            <h6 class="fw-bold mb-1"><i class="fa-solid fa-circle-check me-1"></i> Đã Hoàn Tiền Thành Công</h6>
                            <p class="small mb-1">Giao dịch trả hàng và hoàn tiền đã hoàn tất.</p>
                            <div class="small fw-bold text-success">Số tiền đã hoàn: <fmt:formatNumber value="${order.refundAmount != null ? order.refundAmount : order.finalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></div>
                        </div>
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
                <p class="mb-1"><strong>Người nhận:</strong> <c:out value="${order.receiverName}"/></p>
                <p class="mb-1"><strong>Điện thoại:</strong> <c:out value="${order.receiverPhone}"/></p>
                <p class="mb-2"><strong>Địa chỉ giao:</strong> <c:out value="${order.shippingAddress}"/></p>
                <c:if test="${not empty order.returnAddress}">
                    <p class="mb-3 text-warning"><strong>Địa chỉ hoàn trả:</strong> <c:out value="${order.returnAddress}"/></p>
                </c:if>

                <hr>
                <p class="mb-1"><strong>Chi nhánh bán:</strong> <c:out value="${order.branch != null ? order.branch.name : ''}"/></p>
                <p class="mb-1"><strong>Nhà vận chuyển:</strong> <c:out value="${order.shippingProvider != null ? order.shippingProvider.name : 'Giao hàng tiêu chuẩn'}"/></p>
                <c:if test="${not empty assignment && not empty assignment.trackingCode}">
                    <p class="mb-1"><strong>Mã vận đơn:</strong> <span class="badge bg-light text-dark border font-monospace px-2 py-1"><i class="fa-solid fa-barcode me-1 text-primary"></i><c:out value="${assignment.trackingCode}"/></span></p>
                </c:if>
                <c:if test="${not empty assignment && not empty assignment.shipper}">
                    <p class="mb-1"><strong>Shipper:</strong> <c:out value="${assignment.shipper.fullName}"/> (<c:out value="${assignment.shipper.phone}"/>)</p>
                </c:if>
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
