<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="title" value="Quản lý Đổi Trả & Hoàn Tiền" scope="request"/>
<jsp:include page="../../common/header.jsp"/>

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp"/>
    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp"/>
        <main class="main-content container-fluid py-4 px-lg-4">

            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold mb-1 text-dark">
                        <i class="fa-solid fa-rotate-left text-warning me-2"></i>Quản Lý Đổi Trả &amp; Hoàn Tiền
                    </h3>
                    <p class="text-muted mb-0 small">
                        Tiếp nhận và xử lý yêu cầu đổi trả sách của cửa hàng theo chính sách 48h linh hoạt
                    </p>
                </div>
                <div>
                    <a href="/vendor/orders" class="btn btn-outline-secondary rounded-pill btn-sm">
                        <i class="fa-solid fa-arrow-left me-1"></i> Tất cả đơn hàng
                    </a>
                </div>
            </div>

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm" role="alert">
                    <i class="fa-solid fa-circle-check me-2"></i><c:out value="${successMessage}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm" role="alert">
                    <i class="fa-solid fa-circle-exclamation me-2"></i><c:out value="${errorMessage}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <c:set var="reqCount" value="0"/>
            <c:set var="returnedCount" value="0"/>
            <c:set var="refundedCount" value="0"/>
            <c:forEach var="o" items="${orders}">
                <c:if test="${o.orderStatus == 'RETURN_REQUESTED'}"><c:set var="reqCount" value="${reqCount + 1}"/></c:if>
                <c:if test="${o.orderStatus == 'RETURNED'}"><c:set var="returnedCount" value="${returnedCount + 1}"/></c:if>
                <c:if test="${o.orderStatus == 'REFUNDED'}"><c:set var="refundedCount" value="${refundedCount + 1}"/></c:if>
            </c:forEach>

            <!-- Stat Summary Cards -->
            <div class="row g-3 mb-4">
                <div class="col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-4 p-3 bg-white h-100">
                        <div class="d-flex align-items-center">
                            <div class="rounded-3 p-3 bg-primary bg-opacity-10 text-primary me-3">
                                <i class="fa-solid fa-boxes-packing fs-4"></i>
                            </div>
                            <div>
                                <div class="text-muted small fw-semibold">TỔNG YÊU CẦU</div>
                                <h3 class="fw-bold mb-0 text-dark">${orders.size()}</h3>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-4 p-3 bg-white h-100">
                        <div class="d-flex align-items-center">
                            <div class="rounded-3 p-3 bg-warning bg-opacity-10 text-warning me-3">
                                <i class="fa-solid fa-clock-rotate-left fs-4"></i>
                            </div>
                            <div>
                                <div class="text-muted small fw-semibold">CHỜ LẤY &amp; NHẬN SÁCH</div>
                                <h3 class="fw-bold mb-0 text-warning">${reqCount}</h3>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-4 p-3 bg-white h-100">
                        <div class="d-flex align-items-center">
                            <div class="rounded-3 p-3 bg-info bg-opacity-10 text-info me-3">
                                <i class="fa-solid fa-warehouse fs-4"></i>
                            </div>
                            <div>
                                <div class="text-muted small fw-semibold">ĐÃ VỀ KHO SHOP</div>
                                <h3 class="fw-bold mb-0 text-info">${returnedCount}</h3>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-4 p-3 bg-white h-100">
                        <div class="d-flex align-items-center">
                            <div class="rounded-3 p-3 bg-success bg-opacity-10 text-success me-3">
                                <i class="fa-solid fa-hand-holding-dollar fs-4"></i>
                            </div>
                            <div>
                                <div class="text-muted small fw-semibold">ĐÃ HOÀN TIỀN</div>
                                <h3 class="fw-bold mb-0 text-success">${refundedCount}</h3>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Table of Return Orders -->
            <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                <div class="card-header bg-white py-3 border-0 d-flex justify-content-between align-items-center">
                    <h5 class="fw-bold mb-0 text-dark">
                        <i class="fa-solid fa-list-check me-2 text-primary"></i>Danh Sách Đơn Đổi Trả Của Cửa Hàng
                    </h5>
                    <span class="badge bg-light text-dark border px-3 py-2 rounded-pill">
                        Tổng: <strong>${orders.size()}</strong> đơn
                    </span>
                </div>
                <div class="table-responsive">
                    <table class="table align-middle mb-0 table-hover">
                        <thead class="table-light text-secondary small text-uppercase">
                            <tr>
                                <th class="ps-3">Mã Đơn / Ngày Đặt</th>
                                <th>Khách Hàng</th>
                                <th>Phương Thức &amp; Địa Chỉ</th>
                                <th>Lý Do Hoàn Trả</th>
                                <th>Số Tiền Hoàn</th>
                                <th>Trạng Thái</th>
                                <th class="text-center" style="min-width: 220px;">Thao Tác Của Shop</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="o" items="${orders}">
                                <c:set var="da" value="${assignments[o.id]}" />
                                <tr>
                                    <td class="ps-3">
                                        <a href="/vendor/orders/${o.id}" class="fw-bold text-decoration-none text-primary">
                                            ${o.orderCode}
                                        </a>
                                        <div class="small text-muted">
                                            <c:out value="${o.formattedCreatedAt}"/>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="fw-bold text-dark"><c:out value="${o.receiverName}"/></div>
                                        <div class="small text-muted"><i class="fa-solid fa-phone me-1"></i><c:out value="${o.receiverPhone}"/></div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${o.returnMethod == 'STORE'}">
                                                <span class="badge bg-primary text-white mb-1">
                                                    <i class="fa-solid fa-store me-1"></i>Trả tại cơ sở
                                                </span>
                                                <div class="small text-muted">Khách tự mang sách tới cơ sở</div>
                                                <div class="small text-secondary fw-semibold">
                                                    <i class="fa-solid fa-location-dot me-1 text-primary"></i><c:out value="${o.returnAddress}"/>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-warning text-dark mb-1">
                                                    <i class="fa-solid fa-truck me-1"></i>Shipper đến lấy
                                                </span>
                                                <div class="small text-danger fw-semibold">
                                                    Khách chịu 50% ship: <fmt:formatNumber value="${o.returnShippingFee != null ? o.returnShippingFee : 10000}" pattern="#,##0"/> đ
                                                </div>
                                                <div class="small text-danger">
                                                    <i class="fa-solid fa-location-dot me-1"></i><c:out value="${not empty o.returnAddress ? o.returnAddress : o.shippingAddress}"/>
                                                </div>
                                                <!-- Shipper info badge -->
                                                <div class="mt-1">
                                                    <c:choose>
                                                        <c:when test="${not empty da && not empty da.shipper}">
                                                            <c:choose>
                                                                <c:when test="${da.status == 'DELIVERED'}">
                                                                    <span class="badge bg-success text-white" style="font-size: 11px;">
                                                                        <i class="fa-solid fa-check-double me-1"></i>${da.shipper.fullName}: Đã giao về trụ sở
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${da.status == 'CANCELLED'}">
                                                                    <span class="badge bg-danger text-white" style="font-size: 11px;">
                                                                        <i class="fa-solid fa-circle-xmark me-1"></i>${da.shipper.fullName} đã từ chối
                                                                    </span>
                                                                    <c:if test="${not empty da.failureReason}">
                                                                        <div class="small text-danger fw-semibold mt-1" style="font-size: 11px;">
                                                                            <i class="fa-solid fa-triangle-exclamation me-1"></i><c:out value="${da.failureReason}"/>
                                                                        </div>
                                                                    </c:if>
                                                                </c:when>
                                                                <c:when test="${da.status == 'ASSIGNED'}">
                                                                    <span class="badge bg-warning text-dark" style="font-size: 11px;">
                                                                        <i class="fa-solid fa-clock me-1"></i>${da.shipper.fullName}: Chờ xác nhận
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${da.status == 'ACCEPTED'}">
                                                                    <span class="badge bg-info text-dark" style="font-size: 11px;">
                                                                        <i class="fa-solid fa-check me-1"></i>${da.shipper.fullName}: Đã nhận đơn
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${da.status == 'PICKED_UP'}">
                                                                    <span class="badge bg-primary text-white" style="font-size: 11px;">
                                                                        <i class="fa-solid fa-box me-1"></i>${da.shipper.fullName}: Đã lấy sách
                                                                    </span>
                                                                </c:when>
                                                                <c:when test="${da.status == 'SHIPPING'}">
                                                                    <span class="badge bg-info text-dark" style="font-size: 11px;">
                                                                        <i class="fa-solid fa-motorcycle me-1"></i>${da.shipper.fullName}: Đang chuyển về kho
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-secondary text-white" style="font-size: 11px;">
                                                                        <i class="fa-solid fa-motorcycle me-1"></i>${da.shipper.fullName} (${da.status})
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary text-white" style="font-size: 11px;">
                                                                <i class="fa-solid fa-user-clock me-1"></i>Chưa phân công shipper
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="p-2 bg-light rounded text-dark small border" style="max-width: 200px;">
                                            <i class="fa-solid fa-comment-dots text-warning me-1"></i>
                                            <c:out value="${not empty o.returnReason ? o.returnReason : (not empty o.note ? o.note : 'Khách không ưng ý sách')}"/>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="fw-bold text-success fs-6">
                                            <fmt:formatNumber value="${o.refundAmount != null ? o.refundAmount : o.finalAmount}" pattern="#,##0"/> đ
                                        </div>
                                        <c:if test="${o.returnMethod == 'SHIPPER'}">
                                            <small class="text-muted d-block" style="font-size: 11px;">(Đã trừ 50% ship)</small>
                                        </c:if>
                                        <div class="small mt-1">
                                            <span class="badge ${o.paymentStatus == 'REFUNDED' ? 'bg-success' : 'bg-secondary'}">
                                                ${o.paymentStatus}
                                            </span>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${o.orderStatus == 'RETURN_REQUESTED'}">
                                                <span class="badge bg-warning text-dark px-2 py-1 rounded-pill">
                                                    <i class="fa-solid fa-clock-rotate-left me-1"></i>Chờ nhận sách
                                                </span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'RETURNED'}">
                                                <span class="badge bg-info text-dark px-2 py-1 rounded-pill">
                                                    <i class="fa-solid fa-warehouse me-1"></i>Đã về kho
                                                </span>
                                            </c:when>
                                            <c:when test="${o.orderStatus == 'REFUNDED'}">
                                                <span class="badge bg-success px-2 py-1 rounded-pill">
                                                    <i class="fa-solid fa-circle-check me-1"></i>Đã hoàn tiền
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary px-2 py-1 rounded-pill">${o.orderStatus}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center align-middle">
                                        <div class="d-flex flex-column gap-1 align-items-center">
                                            <c:if test="${o.orderStatus == 'RETURN_REQUESTED'}">
                                                <c:choose>
                                                    <%-- TRƯỜNG HỢP 1: Hoàn trả tại cơ sở chi nhánh --%>
                                                    <c:when test="${o.returnMethod == 'STORE'}">
                                                        <form method="post" action="/vendor/orders/${o.id}/approve-refund" class="w-100"
                                                              onsubmit="return confirm('Xác nhận khách đã mang sách đến cơ sở chi nhánh? Hệ thống sẽ nhận sách về kho và hoàn tiền 100% cho khách.');">
                                                            <c:if test="${not empty _csrf}">
                                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                            </c:if>
                                                            <input type="hidden" name="redirectUrl" value="/vendor/returns">
                                                            <button type="submit" class="btn btn-sm btn-success rounded-pill w-100 fw-bold shadow-sm py-2">
                                                                <i class="fa-solid fa-box-archive me-1"></i> Xác Nhận Nhận Sách &amp; Hoàn Tiền
                                                            </button>
                                                        </form>
                                                    </c:when>

                                                    <%-- TRƯỜNG HỢP 2: Hoàn trả qua Shipper đến lấy tại nhà --%>
                                                    <c:otherwise>
                                                        <c:choose>
                                                             <%-- Giai đoạn 1: Chưa phân Shipper hoặc Shipper đã từ chối --%>
                                                             <c:when test="${empty da || empty da.shipper || da.status == 'CANCELLED'}">
                                                                 <button type="button" class="btn btn-sm ${not empty da && da.status == 'CANCELLED' ? 'btn-danger' : 'btn-primary'} rounded-pill w-100 fw-bold shadow-sm py-2"
                                                                         data-bs-toggle="modal" data-bs-target="#assignShipperModal${o.id}">
                                                                     <i class="fa-solid ${not empty da && da.status == 'CANCELLED' ? 'fa-rotate-right' : 'fa-motorcycle'} me-1"></i>
                                                                     ${not empty da && da.status == 'CANCELLED' ? 'Phân Lại Shipper' : 'Phân Shipper Đến Lấy'}
                                                                 </button>
                                                                 <div class="small text-muted mt-1" style="font-size: 11px;">
                                                                     <i class="fa-solid fa-lock me-1"></i>Cần Shipper giao sách về mới được hoàn tiền
                                                                 </div>
                                                             </c:when>

                                                             <%-- Giai đoạn 2: Đã phân Shipper nhưng Shipper đang trên đường (chưa giao về kho) --%>
                                                             <c:when test="${da.status != 'DELIVERED'}">
                                                                 <c:if test="${da.status == 'ASSIGNED'}">
                                                                     <button type="button" class="btn btn-sm btn-outline-secondary rounded-pill w-100 fw-bold mb-1"
                                                                             data-bs-toggle="modal" data-bs-target="#assignShipperModal${o.id}">
                                                                         <i class="fa-solid fa-user-pen me-1"></i> Đổi Shipper
                                                                     </button>
                                                                     <span class="badge bg-warning text-dark py-1 px-2 rounded-pill small w-100">
                                                                         <i class="fa-solid fa-clock me-1"></i>Chờ Shipper nhận đơn
                                                                     </span>
                                                                 </c:if>
                                                                 <c:if test="${da.status == 'ACCEPTED'}">
                                                                     <span class="badge bg-info text-dark py-2 px-2 rounded-pill small w-100">
                                                                         <i class="fa-solid fa-truck-moving me-1"></i>Shipper đang đến lấy
                                                                     </span>
                                                                 </c:if>
                                                                 <c:if test="${da.status == 'PICKED_UP'}">
                                                                     <span class="badge bg-primary text-white py-2 px-2 rounded-pill small w-100">
                                                                         <i class="fa-solid fa-box me-1"></i>Shipper đã lấy sách
                                                                     </span>
                                                                 </c:if>
                                                                 <c:if test="${da.status == 'SHIPPING'}">
                                                                     <span class="badge bg-info text-dark py-2 px-2 rounded-pill small w-100">
                                                                         <i class="fa-solid fa-motorcycle me-1"></i>Đang chuyển về kho
                                                                     </span>
                                                                 </c:if>
                                                                 <div class="small text-muted mt-1" style="font-size: 11px;">
                                                                     <i class="fa-solid fa-hourglass-half me-1"></i>Đang chờ sách về kho
                                                                 </div>
                                                             </c:when>

                                                             <%-- Giai đoạn 3: Shipper đã giao sách hoàn trả về đến trụ sở kho (da.status == 'DELIVERED') --%>
                                                             <c:otherwise>
                                                                 <div class="small text-success fw-bold mb-1">
                                                                     <i class="fa-solid fa-circle-check me-1"></i>Shipper đã giao sách về kho!
                                                                 </div>
                                                                 <form method="post" action="/vendor/orders/${o.id}/approve-refund" class="w-100"
                                                                       onsubmit="return confirm('Xác nhận sách hoàn đã về trụ sở an toàn? Hệ thống sẽ nhập kho sách, hoàn lại tiền cho khách (trừ 50% ship) và thanh toán phí ship cho Shipper.');">
                                                                     <c:if test="${not empty _csrf}">
                                                                         <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                                     </c:if>
                                                                     <input type="hidden" name="redirectUrl" value="/vendor/returns">
                                                                     <button type="submit" class="btn btn-sm btn-success rounded-pill w-100 fw-bold shadow-sm py-2">
                                                                         <i class="fa-solid fa-hand-holding-dollar me-1"></i> Xác Nhận Nhận Sách &amp; Hoàn Tiền
                                                                     </button>
                                                                 </form>
                                                             </c:otherwise>
                                                         </c:choose>
                                                     </c:otherwise>
                                                 </c:choose>
                                             </c:if>

                                             <c:if test="${o.orderStatus == 'RETURNED'}">
                                                 <form method="post" action="/vendor/orders/${o.id}/approve-refund" class="w-100"
                                                       onsubmit="return confirm('Xác nhận hoàn tiền cho khách hàng và thanh toán phí ship cho Shipper?');">
                                                     <c:if test="${not empty _csrf}">
                                                         <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                     </c:if>
                                                     <input type="hidden" name="redirectUrl" value="/vendor/returns">
                                                     <button type="submit" class="btn btn-sm btn-success rounded-pill w-100 fw-bold shadow-sm py-2">
                                                         <i class="fa-solid fa-hand-holding-dollar me-1"></i> Xác Nhận Hoàn Tiền
                                                     </button>
                                                 </form>
                                             </c:if>

                                             <c:if test="${o.orderStatus == 'REFUNDED'}">
                                                 <span class="badge bg-success py-2 px-3 rounded-pill fw-bold">
                                                     <i class="fa-solid fa-check-double me-1"></i> Hoàn tất đổi trả
                                                 </span>
                                             </c:if>
                                         </div>

                                         <form id="revokeReturnForm${o.id}" method="post" action="/vendor/orders/${o.id}/revoke-shipper" onsubmit="return confirm('Bạn có chắc chắn muốn thu hồi phân công từ Shipper hiện tại? Đơn hàng sẽ trở về trạng thái chờ phân công lại.');">
                                             <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                             <input type="hidden" name="redirectUrl" value="/vendor/returns">
                                         </form>

                                         <!-- Modal Phân công Shipper cho đơn này -->
                                         <div class="modal fade" id="assignShipperModal${o.id}" tabindex="-1" aria-hidden="true">
                                             <div class="modal-dialog modal-dialog-centered modal-lg text-start">
                                                 <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden">
                                                     <div class="modal-header border-0 bg-primary text-white py-3 px-4">
                                                         <h5 class="modal-title fw-bold fs-6">
                                                             <i class="fa-solid fa-truck-ramp-box me-2"></i>
                                                             <c:choose>
                                                                 <c:when test="${not empty da && not empty da.shipper && da.status == 'CANCELLED'}">Phân Công Lại Shipper Thu Hồi Sách</c:when>
                                                                 <c:when test="${not empty da && not empty da.shipper && da.status == 'ASSIGNED'}">Đổi Shipper Thu Hồi Sách</c:when>
                                                                 <c:otherwise>Phân Công Shipper Tiêu Chuẩn Thu Hồi Sách</c:otherwise>
                                                             </c:choose>
                                                         </h5>
                                                         <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                                     </div>
                                                     <form method="post" action="/vendor/orders/${o.id}/assign-shipper">
                                                         <c:if test="${not empty _csrf}">
                                                             <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                         </c:if>
                                                         <input type="hidden" name="redirectUrl" value="/vendor/returns">
                                                         <div class="modal-body p-4 bg-light">
                                                             <div class="row g-3">
                                                                 <!-- Cột trái: Thông tin đơn hàng hoàn trả -->
                                                                 <div class="col-md-5">
                                                                     <div class="card border-0 shadow-sm rounded-3 p-3 h-100 bg-white">
                                                                         <div class="fw-bold text-dark mb-2 pb-2 border-bottom">
                                                                             <i class="fa-solid fa-file-invoice text-primary me-2"></i>Thông tin đơn đổi trả
                                                                         </div>
                                                                         <div class="small mb-2">
                                                                             <span class="text-muted d-block">Mã đơn hàng:</span>
                                                                             <span class="fw-bold text-primary">${o.orderCode}</span>
                                                                         </div>
                                                                         <div class="small mb-2">
                                                                             <span class="text-muted d-block">Người yêu cầu:</span>
                                                                             <span class="fw-bold text-dark"><c:out value="${o.receiverName}"/></span>
                                                                             <span class="text-muted">(${o.receiverPhone})</span>
                                                                         </div>
                                                                         <div class="small mb-2">
                                                                             <span class="text-muted d-block">Địa chỉ lấy sách trả:</span>
                                                                             <span class="text-danger fw-bold"><c:out value="${not empty o.returnAddress ? o.returnAddress : o.shippingAddress}"/></span>
                                                                         </div>
                                                                         <div class="small mb-2">
                                                                             <span class="text-muted d-block">Hình thức hoàn trả:</span>
                                                                             <span class="badge bg-warning text-dark px-2 py-1"><i class="fa-solid fa-truck-pickup me-1"></i>Shipper đến lấy tận nơi</span>
                                                                         </div>
                                                                         <div class="small">
                                                                             <span class="text-muted d-block">Lý do đổi trả:</span>
                                                                             <div class="p-2 bg-light rounded text-dark mt-1 border">
                                                                                 <c:out value="${o.returnReason != null ? o.returnReason : o.note}"/>
                                                                             </div>
                                                                         </div>
                                                                     </div>
                                                                 </div>

                                                                 <!-- Cột phải: Phân công Shipper -->
                                                                 <div class="col-md-7">
                                                                     <div class="card border-0 shadow-sm rounded-3 p-3 h-100 bg-white">
                                                                         <!-- Thông tin phân công hiện tại nếu có -->
                                                                         <c:if test="${not empty da && not empty da.shipper}">
                                                                             <div class="card border ${da.status == 'CANCELLED' ? 'border-danger bg-danger bg-opacity-10' : (da.status == 'ASSIGNED' ? 'border-warning bg-warning bg-opacity-10' : 'border-info bg-info bg-opacity-10')} rounded-3 p-3 mb-3">
                                                                                 <div class="d-flex justify-content-between align-items-center mb-1">
                                                                                     <span class="small fw-bold text-dark"><i class="fa-solid fa-user-tag me-1"></i>Trạng thái:</span>
                                                                                     <c:choose>
                                                                                         <c:when test="${da.status == 'ASSIGNED'}">
                                                                                             <span class="badge bg-warning text-dark"><i class="fa-solid fa-clock me-1"></i>Chờ Shipper xác nhận</span>
                                                                                         </c:when>
                                                                                         <c:when test="${da.status == 'CANCELLED'}">
                                                                                             <span class="badge bg-danger"><i class="fa-solid fa-circle-xmark me-1"></i>Đã từ chối đơn</span>
                                                                                         </c:when>
                                                                                         <c:when test="${da.status == 'ACCEPTED'}">
                                                                                             <span class="badge bg-info text-dark"><i class="fa-solid fa-check me-1"></i>Đã nhận đơn</span>
                                                                                         </c:when>
                                                                                         <c:otherwise>
                                                                                             <span class="badge bg-secondary">${da.status}</span>
                                                                                         </c:otherwise>
                                                                                     </c:choose>
                                                                                 </div>
                                                                                 <div class="small text-dark">
                                                                                     <strong>Shipper:</strong> <c:out value="${da.shipper.fullName}"/> (<c:out value="${da.shipper.phone}"/>) - <c:out value="${da.shipper.shippingProvider != null ? da.shipper.shippingProvider.name : 'Nội bộ'}"/>
                                                                                 </div>
                                                                                 <c:if test="${not empty da.failureReason}">
                                                                                     <div class="small text-danger fw-semibold mt-1">
                                                                                         <i class="fa-solid fa-circle-info me-1"></i><c:out value="${da.failureReason}"/>
                                                                                     </div>
                                                                                 </c:if>
                                                                                 <c:if test="${da.status == 'ASSIGNED'}">
                                                                                     <div class="mt-2 pt-2 border-top border-warning d-flex justify-content-between align-items-center">
                                                                                         <span class="small text-muted">Hủy giao đơn cho người này:</span>
                                                                                         <button type="submit" form="revokeReturnForm${o.id}" class="btn btn-sm btn-outline-danger rounded-pill px-3 fw-bold">
                                                                                             <i class="fa-solid fa-user-xmark me-1"></i>Thu Hồi Phân Công
                                                                                         </button>
                                                                                     </div>
                                                                                 </c:if>
                                                                             </div>
                                                                         </c:if>

                                                                         <div class="mb-3">
                                                                             <label class="form-label small fw-bold text-dark">
                                                                                 Chọn Shipper Tiêu Chuẩn thu hồi sách: <span class="text-danger">*</span>
                                                                             </label>
                                                                             <div class="alert alert-info py-2 px-3 small border-0 mb-2">
                                                                                 <i class="fa-solid fa-shield-halved me-1"></i>Chính sách thu hồi: Phân công nhân viên <strong>Shipper Tiêu Chuẩn</strong> đến nhận sách.
                                                                             </div>
                                                                             <select name="shipperId" class="form-select form-select-sm" required>
                                                                                 <option value="">-- Chọn Shipper Tiêu Chuẩn --</option>
                                                                                 <c:forEach var="shp" items="${shippers}">
                                                                                     <c:set var="isStandard" value="${shp.shippingProvider != null && (shp.shippingProvider.code == 'GHN_STANDARD' || shp.shippingProvider.name.contains('Tiêu Chuẩn'))}"/>
                                                                                     <c:if test="${isStandard}">
                                                                                         <c:set var="isRejected" value="${not empty da && da.hasShipperRejected(shp.id)}"/>
                                                                                         <c:set var="isDisabled" value="${shp.busy || isRejected}"/>

                                                                                         <option value="${shp.id}" ${isDisabled ? 'disabled' : ''} class="${isRejected ? 'text-danger fw-bold' : (shp.busy ? 'text-muted' : '')}">
                                                                                             ${shp.fullName} (${shp.phone}) - ${shp.shippingProvider != null ? shp.shippingProvider.name : 'Tiêu Chuẩn'}
                                                                                             <c:choose>
                                                                                                 <c:when test="${isRejected}">
                                                                                                     [❌ ĐÃ TỪ CHỐI ĐƠN NÀY]
                                                                                                 </c:when>
                                                                                                 <c:when test="${shp.busy}">
                                                                                                     [⏳ ĐANG BẬN: Đơn #${shp.busyOrderCode}]
                                                                                                 </c:when>
                                                                                                 <c:otherwise>
                                                                                                     [✅ Sẵn sàng nhận đơn]
                                                                                                 </c:otherwise>
                                                                                             </c:choose>
                                                                                         </option>
                                                                                     </c:if>
                                                                                 </c:forEach>
                                                                             </select>
                                                                             <div class="form-text small text-muted mt-1">
                                                                                 <i class="fa-solid fa-lock me-1"></i>Tự động khóa shipper đang bận hoặc đã từ chối đơn này.
                                                                             </div>
                                                                         </div>

                                                                         <div class="mb-2">
                                                                             <label class="form-label small fw-bold text-dark">Ghi chú cho Shipper:</label>
                                                                             <textarea name="note" class="form-control form-control-sm" rows="2" placeholder="Ghi chú thêm cho shipper...">Đến địa chỉ của khách hàng để nhận lại sách hoàn trả</textarea>
                                                                         </div>
                                                                     </div>
                                                                 </div>
                                                             </div>
                                                         </div>
                                                         <div class="modal-footer border-0 bg-white py-3 px-4">
                                                             <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">Đóng</button>
                                                             <button type="submit" class="btn btn-primary rounded-pill px-4 fw-bold shadow-sm">
                                                                 <i class="fa-solid fa-paper-plane me-1"></i>
                                                                 <c:choose>
                                                                     <c:when test="${not empty da && not empty da.shipper && da.status == 'ASSIGNED'}">Xác Nhận Đổi Shipper</c:when>
                                                                     <c:when test="${not empty da && not empty da.shipper && da.status == 'CANCELLED'}">Xác Nhận Phân Lại</c:when>
                                                                     <c:otherwise>Xác Nhận Phân Shipper</c:otherwise>
                                                                 </c:choose>
                                                             </button>
                                                         </div>
                                                     </form>
                                                 </div>
                                             </div>
                                         </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty orders}">
                                <tr>
                                    <td colspan="7" class="text-center py-5 text-muted">
                                        <i class="fa-solid fa-box-open fs-2 mb-2 text-secondary d-block"></i>
                                        Hiện tại cửa hàng không có yêu cầu hoàn trả hoặc hoàn tiền nào.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

        </main>
    </div>
</div>

<jsp:include page="../../common/footer.jsp"/>