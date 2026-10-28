<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="title" value="Quản Lý Thu Mua Sách Cũ - Vendor" scope="request"/>
<jsp:include page="../../common/header.jsp"/>

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp"/>

    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp"/>

        <main class="main-content container-fluid px-4 py-4">
            <!-- Header Section -->
            <div class="d-flex flex-wrap justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold text-dark mb-1">
                        <i class="fa-solid fa-hand-holding-dollar text-warning me-2"></i>Quản Lý Thu Mua Sách Cũ Tận Nhà
                    </h3>
                    <p class="text-muted small mb-0">
                        Thẩm định sách cũ khách đăng bán trên web, gửi báo giá đàm phán và điều phối Shipper tiêu chuẩn thu gom về kho
                    </p>
                </div>
                <div class="d-flex gap-2">
                    <a href="/vendor/dashboard" class="btn btn-outline-secondary rounded-pill btn-sm px-3">
                        <i class="fa-solid fa-gauge me-1"></i> Dashboard
                    </a>
                    <a href="/vendor/products" class="btn btn-outline-primary rounded-pill btn-sm px-3">
                        <i class="fa-solid fa-book me-1"></i> Kho Sách Bán
                    </a>
                </div>
            </div>

            <!-- Alerts -->
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show rounded-4 shadow-sm border-0 mb-4" role="alert">
                    <i class="fa-solid fa-circle-check me-2 fs-5"></i><c:out value="${successMessage}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show rounded-4 shadow-sm border-0 mb-4" role="alert">
                    <i class="fa-solid fa-circle-exclamation me-2 fs-5"></i><c:out value="${errorMessage}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <!-- Dashboard Summary Stat Cards -->
            <div class="row g-3 mb-4">
                <div class="col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-4 p-3 bg-white h-100">
                        <div class="d-flex align-items-center">
                            <div class="rounded-3 p-3 bg-primary bg-opacity-10 text-primary me-3">
                                <i class="fa-solid fa-boxes-stacked fs-4"></i>
                            </div>
                            <div>
                                <div class="text-muted small fw-semibold text-uppercase">Tổng Yêu Cầu Thu Mua</div>
                                <h3 class="fw-bold mb-0 text-dark">${totalCount != null ? totalCount : requests.size()}</h3>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-4 p-3 bg-white h-100">
                        <div class="d-flex align-items-center">
                            <div class="rounded-3 p-3 bg-warning bg-opacity-10 text-warning me-3">
                                <i class="fa-solid fa-magnifying-glass-dollar fs-4"></i>
                            </div>
                            <div>
                                <div class="text-muted small fw-semibold text-uppercase">Đang Thẩm Định / Báo Giá</div>
                                <h3 class="fw-bold mb-0 text-warning">${inspectingCount != null ? inspectingCount + (pendingCount != null ? pendingCount : 0) : 0}</h3>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-4 p-3 bg-white h-100">
                        <div class="d-flex align-items-center">
                            <div class="rounded-3 p-3 bg-info bg-opacity-10 text-info me-3">
                                <i class="fa-solid fa-truck-pickup fs-4"></i>
                            </div>
                            <div>
                                <div class="text-muted small fw-semibold text-uppercase">Chờ Shipper Lấy Sách</div>
                                <h3 class="fw-bold mb-0 text-info">${acceptedCount != null ? acceptedCount : 0}</h3>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="card border-0 shadow-sm rounded-4 p-3 bg-white h-100">
                        <div class="d-flex align-items-center">
                            <div class="rounded-3 p-3 bg-success bg-opacity-10 text-success me-3">
                                <i class="fa-solid fa-circle-check fs-4"></i>
                            </div>
                            <div>
                                <div class="text-muted small fw-semibold text-uppercase">Đã Nhập Kho Bán</div>
                                <h3 class="fw-bold mb-0 text-success">${completedCount != null ? completedCount : 0}</h3>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Filter Navigation Pills -->
            <div class="card border-0 shadow-sm rounded-4 p-2 mb-4 bg-white">
                <div class="d-flex flex-wrap gap-2 align-items-center justify-content-between p-2">
                    <div class="d-flex flex-wrap gap-2">
                        <a href="/vendor/sell-requests" class="btn btn-sm rounded-pill px-3 ${empty selectedStatus ? 'btn-primary fw-bold' : 'btn-light text-dark'}">
                            Tất cả (${totalCount != null ? totalCount : requests.size()})
                        </a>
                        <a href="/vendor/sell-requests?status=PENDING" class="btn btn-sm rounded-pill px-3 ${selectedStatus == 'PENDING' ? 'btn-warning text-dark fw-bold' : 'btn-light text-dark'}">
                            <i class="fa-solid fa-clock me-1"></i>Chờ tiếp nhận
                        </a>
                        <a href="/vendor/sell-requests?status=INSPECTING" class="btn btn-sm rounded-pill px-3 ${selectedStatus == 'INSPECTING' ? 'btn-info text-dark fw-bold' : 'btn-light text-dark'}">
                            <i class="fa-solid fa-magnifying-glass me-1"></i>Đang thẩm định
                        </a>
                        <a href="/vendor/sell-requests?status=QUOTED" class="btn btn-sm rounded-pill px-3 ${selectedStatus == 'QUOTED' ? 'btn-primary fw-bold' : 'btn-light text-dark'}">
                            <i class="fa-solid fa-tags me-1"></i>Đã báo giá
                        </a>
                        <a href="/vendor/sell-requests?status=ACCEPTED" class="btn btn-sm rounded-pill px-3 ${selectedStatus == 'ACCEPTED' ? 'btn-success fw-bold' : 'btn-light text-dark'}">
                            <i class="fa-solid fa-truck-pickup me-1"></i>Cần thu gom sách
                        </a>
                        <a href="/vendor/sell-requests?status=COMPLETED" class="btn btn-sm rounded-pill px-3 ${selectedStatus == 'COMPLETED' ? 'btn-success fw-bold' : 'btn-light text-dark'}">
                            <i class="fa-solid fa-check-double me-1"></i>Đã nhập kho
                        </a>
                    </div>
                    <div class="small text-muted fst-italic">
                        <i class="fa-solid fa-circle-info me-1 text-primary"></i>Đơn khách đã chốt bán chỉ hiển thị cho cửa hàng chốt đàm phán thành công.
                    </div>
                </div>
            </div>

            <!-- Danh sách các yêu cầu thu mua -->
            <div class="row g-4">
                <c:forEach var="r" items="${requests}">
                    <c:set var="da" value="${assignments[r.id]}" />
                    <div class="col-12">
                        <div class="card border-0 shadow-sm rounded-4 overflow-hidden bg-white">
                            <!-- Card Header -->
                            <div class="card-header bg-light bg-opacity-75 border-0 py-3 px-4 d-flex flex-wrap justify-content-between align-items-center">
                                <div class="d-flex align-items-center gap-2">
                                    <span class="badge bg-primary px-3 py-2 rounded-pill fs-7">
                                        <i class="fa-solid fa-receipt me-1"></i>Yêu cầu #${r.id}
                                    </span>
                                    <span class="text-muted small">
                                        <i class="fa-regular fa-clock me-1"></i><c:out value="${r.formattedCreatedAt}"/>
                                    </span>
                                    <c:if test="${r.buyerVendor != null && (r.status == 'ACCEPTED' || r.status == 'COMPLETED')}">
                                        <span class="badge bg-purple text-white px-2 py-1 rounded-pill small ms-2">
                                            <i class="fa-solid fa-shop me-1"></i>Shop mua: <c:out value="${r.buyerVendor.fullName}"/>
                                        </span>
                                    </c:if>
                                </div>
                                <div>
                                    <c:choose>
                                        <c:when test="${r.status == 'PENDING'}">
                                            <span class="badge bg-warning text-dark px-3 py-2 rounded-pill"><i class="fa-solid fa-clock me-1"></i>Chờ tiếp nhận</span>
                                        </c:when>
                                        <c:when test="${r.status == 'INSPECTING'}">
                                            <span class="badge bg-info text-dark px-3 py-2 rounded-pill"><i class="fa-solid fa-magnifying-glass me-1"></i>Đang thẩm định</span>
                                        </c:when>
                                        <c:when test="${r.status == 'QUOTED'}">
                                            <span class="badge bg-primary text-white px-3 py-2 rounded-pill"><i class="fa-solid fa-tags me-1"></i>Đã gửi báo giá</span>
                                        </c:when>
                                        <c:when test="${r.status == 'ACCEPTED'}">
                                            <span class="badge bg-success text-white px-3 py-2 rounded-pill"><i class="fa-solid fa-handshake me-1"></i>Khách đã đồng ý bán</span>
                                        </c:when>
                                        <c:when test="${r.status == 'COMPLETED'}">
                                            <span class="badge bg-success px-3 py-2 rounded-pill"><i class="fa-solid fa-circle-check me-1"></i>Đã nhập kho bán</span>
                                        </c:when>
                                        <c:when test="${r.status == 'REJECTED'}">
                                            <span class="badge bg-danger px-3 py-2 rounded-pill"><i class="fa-solid fa-circle-xmark me-1"></i>Từ chối thu mua</span>
                                        </c:when>
                                        <c:when test="${r.status == 'CANCELLED'}">
                                            <span class="badge bg-secondary px-3 py-2 rounded-pill"><i class="fa-solid fa-ban me-1"></i>Khách đã hủy</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-secondary px-3 py-2 rounded-pill">${r.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="card-body p-4">
                                <div class="row g-4">
                                    <!-- Cột trái: Thông tin khách hàng & Địa chỉ thu mua -->
                                    <div class="col-lg-5 border-end">
                                        <div class="d-flex align-items-center mb-3 pb-2 border-bottom">
                                            <div class="rounded-circle bg-primary bg-opacity-10 text-primary p-2 me-2 d-flex align-items-center justify-content-center" style="width: 36px; height: 36px;">
                                                <i class="fa-solid fa-user"></i>
                                            </div>
                                            <div>
                                                <h6 class="fw-bold text-dark mb-0"><c:out value="${r.customer.fullName}"/></h6>
                                                <small class="text-muted"><c:out value="${r.customer.email}"/></small>
                                            </div>
                                        </div>

                                        <div class="mb-3">
                                            <small class="text-muted d-block fw-semibold mb-1">
                                                <i class="fa-solid fa-phone text-primary me-1"></i>Số điện thoại khách:
                                            </small>
                                            <a href="tel:${r.customer.phone}" class="text-decoration-none fw-bold text-primary fs-6">
                                                <c:out value="${r.customer.phone}"/>
                                            </a>
                                        </div>

                                        <div class="mb-3">
                                            <small class="text-muted d-block fw-semibold mb-1">
                                                <i class="fa-solid fa-house-chimney text-danger me-1"></i>Địa chỉ lấy sách tận nhà:
                                            </small>
                                            <div class="p-2 bg-light rounded text-danger fw-bold small border border-danger-subtle">
                                                <c:out value="${r.note}"/>
                                            </div>
                                        </div>

                                        <!-- Hộp so sánh giá (Bảo mật độc lập: Vendor chỉ thấy báo giá của chính mình) -->
                                        <c:set var="myQuote" value="${myQuotes[r.id]}" />
                                        <div class="p-3 bg-light rounded-3 border">
                                            <div class="d-flex justify-content-between align-items-center mb-2">
                                                <span class="small text-muted">Giá khách kỳ vọng:</span>
                                                <span class="fw-bold text-dark"><fmt:formatNumber value="${r.expectedTotal}" pattern="#,##0"/> đ</span>
                                            </div>
                                            <div class="d-flex justify-content-between align-items-center pt-2 border-top">
                                                <span class="small text-muted">Báo giá của Shop bạn:</span>
                                                <span class="fw-bold text-danger fs-6">
                                                    <c:choose>
                                                        <c:when test="${not empty myQuote && myQuote.offeredPrice > 0}">
                                                            <fmt:formatNumber value="${myQuote.offeredPrice}" pattern="#,##0"/> đ
                                                            <span class="badge bg-success bg-opacity-10 text-success ms-1 small fw-normal">Đã gửi</span>
                                                        </c:when>
                                                        <c:when test="${r.status == 'ACCEPTED' && r.buyerVendor != null}">
                                                            <fmt:formatNumber value="${r.offeredTotal}" pattern="#,##0"/> đ
                                                        </c:when>
                                                        <c:otherwise><em class="text-muted small">Shop bạn chưa gửi báo giá</em></c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                            <c:if test="${not empty myQuote && not empty myQuote.note}">
                                                <div class="mt-2 pt-2 border-top small text-muted">
                                                    <strong class="text-dark">Ghi chú của Shop bạn:</strong> <c:out value="${myQuote.note}"/>
                                                </div>
                                            </c:if>
                                            <c:if test="${empty myQuote && not empty r.staffNote && r.status == 'ACCEPTED'}">
                                                <div class="mt-2 pt-2 border-top small text-muted">
                                                    <strong class="text-dark">Ghi chú đã chốt:</strong> <c:out value="${r.staffNote}"/>
                                                </div>
                                            </c:if>
                                        </div>
                                    </div>

                                    <!-- Cột phải: Danh sách sách khách gửi thu mua -->
                                    <div class="col-lg-7">
                                        <div class="d-flex justify-content-between align-items-center mb-3">
                                            <h6 class="fw-bold text-dark mb-0">
                                                <i class="fa-solid fa-book-open text-primary me-2"></i>Danh Sách Sách (${r.items.size()} cuốn)
                                            </h6>
                                            <span class="badge bg-light text-dark border small px-2 py-1">Tình trạng thực tế</span>
                                        </div>

                                        <div class="table-responsive mb-0">
                                            <table class="table table-bordered align-middle mb-0">
                                                <thead class="table-light small text-secondary">
                                                    <tr>
                                                        <th style="width: 70px;" class="text-center">Ảnh</th>
                                                        <th>Tác phẩm / Sách</th>
                                                        <th>Tình trạng</th>
                                                        <th class="text-end" style="width: 120px;">Giá kỳ vọng</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="it" items="${r.items}">
                                                        <tr>
                                                            <td class="text-center p-2">
                                                                <img src="<c:out value='${not empty it.imageUrl ? it.imageUrl : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500&q=80"}'/>"
                                                                     alt="Ảnh bìa" class="rounded border shadow-sm" style="width: 52px; height: 68px; object-fit: cover;"
                                                                     onerror="this.src='https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500&q=80'">
                                                            </td>
                                                            <td>
                                                                <div class="fw-bold text-dark"><c:out value="${it.bookTitle}"/></div>
                                                                <c:if test="${not empty it.isbn}">
                                                                    <div class="small text-muted">ISBN: <c:out value="${it.isbn}"/></div>
                                                                </c:if>
                                                            </td>
                                                            <td>
                                                                <span class="badge bg-light text-dark border small fw-normal"><c:out value="${it.conditionDescription}"/></span>
                                                            </td>
                                                            <td class="text-end fw-bold text-primary">
                                                                <fmt:formatNumber value="${it.expectedPrice}" pattern="#,##0"/> đ
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                    <c:if test="${empty r.items}">
                                                        <tr>
                                                            <td colspan="4" class="text-center text-muted py-3">Chưa có chi tiết sách</td>
                                                        </tr>
                                                    </c:if>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Card Footer: Quy trình xử lý theo từng giai đoạn -->
                            <div class="card-footer bg-light border-0 p-3 px-4">
                                <%-- GIAI ĐOẠN 1: PENDING / INSPECTING / QUOTED --%>
                                <c:if test="${r.status == 'PENDING' || r.status == 'INSPECTING' || r.status == 'QUOTED'}">
                                    <div class="d-flex flex-wrap justify-content-between align-items-center mb-2">
                                        <div class="small fw-bold text-dark">
                                            <i class="fa-solid fa-sliders text-warning me-1"></i>Thẩm Định &amp; Báo Giá Thu Mua
                                        </div>
                                        <div class="small text-muted">
                                            <i class="fa-solid fa-globe me-1 text-primary"></i>Mọi cơ sở đều có thể thẩm định trước khi khách chốt bán.
                                        </div>
                                    </div>
                                    <form method="post" action="/vendor/sell-requests/${r.id}/status">
                                        <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                        <div class="row g-2 align-items-end">
                                            <div class="col-md-3">
                                                <label class="form-label small text-muted mb-1">Cập nhật bước:</label>
                                                <select class="form-select form-select-sm" name="status" required>
                                                    <option value="INSPECTING" ${r.status == 'INSPECTING' ? 'selected' : ''}>1. Đang thẩm định sách</option>
                                                    <option value="QUOTED" ${r.status == 'QUOTED' ? 'selected' : ''}>2. Gửi giá đề nghị (Báo giá)</option>
                                                    <option value="REJECTED">Từ chối thu mua</option>
                                                </select>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label small text-muted mb-1">Giá đề nghị thu mua (VNĐ):</label>
                                                <input class="form-control form-control-sm" type="number" min="0" step="5000"
                                                       name="offeredTotal" value="${myQuote != null && myQuote.offeredPrice > 0 ? myQuote.offeredPrice : (r.expectedTotal != null ? r.expectedTotal : 50000)}"
                                                       placeholder="Ví dụ: 80000" required>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label small text-muted mb-1">Ghi chú gửi khách hàng:</label>
                                                <input class="form-control form-control-sm" name="staffNote" maxlength="500"
                                                       value="<c:out value='${myQuote != null ? myQuote.note : ""}'/>"
                                                       placeholder="Định giá dựa trên gáy/trang sách, shop đồng ý mua...">
                                            </div>
                                            <div class="col-md-2">
                                                <button type="submit" class="btn btn-sm btn-primary w-100 fw-bold shadow-sm">
                                                    <i class="fa-solid fa-paper-plane me-1"></i> Gửi Báo Giá
                                                </button>
                                            </div>
                                        </div>
                                    </form>
                                </c:if>

                                <%-- GIAI ĐOẠN 2: ACCEPTED (Khách hàng đã đồng ý bán cho Shop này) --%>
                                <c:if test="${r.status == 'ACCEPTED'}">
                                    <div class="alert alert-success border-0 py-2 px-3 small fw-bold mb-3 d-flex align-items-center">
                                        <i class="fa-solid fa-handshake fs-5 me-2 text-success"></i>
                                        <div>
                                            Khách hàng đã chấp thuận bán sách cho cửa hàng của bạn! Tiến hành điều phối <strong>Shipper Tiêu Chuẩn</strong> đến lấy sách tại nhà khách hàng.
                                        </div>
                                    </div>
                                    <div class="mb-3 px-3 py-2 bg-light bg-opacity-75 rounded-3 border small text-muted">
                                        <i class="fa-solid fa-coins text-warning me-1"></i>Chính sách thanh toán: Tiền mua sách (<strong class="text-danger"><fmt:formatNumber value="${r.offeredTotal != null ? r.offeredTotal : r.expectedTotal}" pattern="#,##0 ₫"/></strong>) và phí trả cho Shipper (<strong class="text-danger">20.000 ₫</strong>) sẽ <strong>trừ thẳng vào thu nhập của Shop</strong> sau khi nhận sách &amp; nhập kho bán thành công.
                                    </div>

                                    <div class="d-flex flex-wrap justify-content-between align-items-center bg-white p-3 rounded-3 border">
                                        <div>
                                            <span class="small fw-bold text-dark d-block mb-1">
                                                <i class="fa-solid fa-truck-ramp-box text-primary me-1"></i>Trạng thái điều phối thu gom sách:
                                            </span>
                                            <c:choose>
                                                <%-- Trường hợp chưa phân công hoặc bị từ chối --%>
                                                <c:when test="${empty da || empty da.shipper || da.status == 'CANCELLED'}">
                                                    <span class="badge bg-secondary text-white py-2 px-3 rounded-pill">
                                                        <i class="fa-solid fa-user-clock me-1"></i>Chưa phân công shipper
                                                    </span>
                                                    <c:if test="${not empty da && da.status == 'CANCELLED'}">
                                                        <span class="badge bg-danger ms-2 py-2 px-3 rounded-pill">
                                                            <i class="fa-solid fa-circle-xmark me-1"></i>Shipper ${da.shipper.fullName} đã từ chối
                                                        </span>
                                                        <c:if test="${not empty da.failureReason}">
                                                            <small class="text-danger d-block mt-1"><i class="fa-solid fa-circle-info me-1"></i><c:out value="${da.failureReason}"/></small>
                                                        </c:if>
                                                    </c:if>
                                                </c:when>

                                                <%-- Shipper đang thực hiện --%>
                                                <c:when test="${da.status == 'ASSIGNED'}">
                                                    <span class="badge bg-warning text-dark py-2 px-3 rounded-pill">
                                                        <i class="fa-solid fa-clock me-1"></i>Đã phân công: <strong>${da.shipper.fullName}</strong> (${da.shipper.phone}) - Chờ Shipper xác nhận
                                                    </span>
                                                </c:when>
                                                <c:when test="${da.status == 'ACCEPTED'}">
                                                    <span class="badge bg-info text-dark py-2 px-3 rounded-pill">
                                                        <i class="fa-solid fa-motorcycle me-1"></i>Shipper <strong>${da.shipper.fullName}</strong> đang trên đường đến lấy sách
                                                    </span>
                                                </c:when>
                                                <c:when test="${da.status == 'PICKED_UP'}">
                                                    <span class="badge bg-primary text-white py-2 px-3 rounded-pill">
                                                        <i class="fa-solid fa-box me-1"></i>Shipper <strong>${da.shipper.fullName}</strong> đã nhận sách từ khách
                                                    </span>
                                                </c:when>
                                                <c:when test="${da.status == 'SHIPPING'}">
                                                    <span class="badge bg-info text-dark py-2 px-3 rounded-pill">
                                                        <i class="fa-solid fa-truck-fast me-1"></i>Shipper <strong>${da.shipper.fullName}</strong> đang chuyển sách về kho chi nhánh
                                                    </span>
                                                </c:when>
                                                <c:when test="${da.status == 'DELIVERED'}">
                                                    <span class="badge bg-success text-white py-2 px-3 rounded-pill">
                                                        <i class="fa-solid fa-circle-check me-1"></i>Shipper <strong>${da.shipper.fullName}</strong> đã mang sách về đến kho an toàn!
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge bg-secondary py-2 px-3 rounded-pill">${da.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <div class="d-flex gap-2 mt-2 mt-md-0">
                                            <!-- Nếu chưa phân công hoặc shipper từ chối -> Nút Phân công Shipper -->
                                            <c:if test="${empty da || empty da.shipper || da.status == 'CANCELLED'}">
                                                <button type="button" class="btn btn-sm btn-primary rounded-pill px-3 fw-bold shadow-sm"
                                                        data-bs-toggle="modal" data-bs-target="#assignSellShipperModal${r.id}">
                                                    <i class="fa-solid fa-motorcycle me-1"></i>Phân Công Shipper Tiêu Chuẩn Đến Lấy
                                                </button>
                                            </c:if>

                                            <!-- Nếu đang ở ASSIGNED -> Nút Thu Hồi Phân Công hoặc Đổi Shipper -->
                                            <c:if test="${not empty da && not empty da.shipper && da.status == 'ASSIGNED'}">
                                                <button type="button" class="btn btn-sm btn-outline-secondary rounded-pill px-3 fw-bold"
                                                        data-bs-toggle="modal" data-bs-target="#assignSellShipperModal${r.id}">
                                                    <i class="fa-solid fa-user-pen me-1"></i>Đổi Shipper
                                                </button>
                                                <form method="post" action="/vendor/sell-requests/${r.id}/revoke-shipper" class="d-inline"
                                                      onsubmit="return confirm('Bạn có chắc chắn muốn thu hồi phân công từ Shipper hiện tại?');">
                                                    <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                                    <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-3 fw-bold">
                                                        <i class="fa-solid fa-user-xmark me-1"></i>Thu Hồi Phân Công
                                                    </button>
                                                </form>
                                            </c:if>

                                            <!-- Khi Shipper đã mang sách về kho (DELIVERED) -> Nút Xác nhận Nhận Sách & Nhập Kho Bán -->
                                            <c:if test="${not empty da && da.status == 'DELIVERED'}">
                                                <form method="post" action="/vendor/sell-requests/${r.id}/status" class="d-inline"
                                                      onsubmit="return confirm('Xác nhận đã nhận đủ sách từ Shipper và nhập toàn bộ vào kho của cửa hàng để đăng bán?');">
                                                    <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                                    <input type="hidden" name="status" value="COMPLETED">
                                                    <button type="submit" class="btn btn-sm btn-success rounded-pill px-3 fw-bold shadow-sm">
                                                        <i class="fa-solid fa-boxes-packing me-1"></i>Xác Nhận Nhận Sách &amp; Nhập Kho Bán
                                                    </button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:if>

                                <%-- GIAI ĐOẠN 3: COMPLETED (Đã nhập kho bán thành công) --%>
                                <c:if test="${r.status == 'COMPLETED'}">
                                    <div class="d-flex flex-wrap justify-content-between align-items-center p-3 rounded-3 bg-success bg-opacity-10 border border-success">
                                        <div class="d-flex align-items-center">
                                            <i class="fa-solid fa-circle-check fs-4 text-success me-3"></i>
                                            <div>
                                                <strong class="text-success">Đã hoàn tất thu mua &amp; nhập kho bán thành công!</strong>
                                                <div class="small text-muted">Hệ thống đã tự động tạo bản sao sách (`BookCopy`) trong kho của shop và sẵn sàng bán trên web.</div>
                                                <div class="small text-danger fw-semibold mt-1">
                                                    <i class="fa-solid fa-file-invoice-dollar me-1"></i>Đã trừ vào thu nhập của Shop: <fmt:formatNumber value="${(r.offeredTotal != null ? r.offeredTotal : r.expectedTotal) + 20000}" pattern="#,##0 ₫"/> (Tiền sách: <fmt:formatNumber value="${r.offeredTotal != null ? r.offeredTotal : r.expectedTotal}" pattern="#,##0 ₫"/> + Phí Shipper: 20.000 ₫)
                                                </div>
                                            </div>
                                        </div>
                                        <a href="/vendor/products" class="btn btn-sm btn-success rounded-pill px-3 fw-bold mt-2 mt-md-0">
                                            <i class="fa-solid fa-boxes-stacked me-1"></i>Xem Kho Sách
                                        </a>
                                    </div>
                                </c:if>

                                <%-- GIAI ĐOẠN 4: REJECTED HOẶC CANCELLED --%>
                                <c:if test="${r.status == 'REJECTED' || r.status == 'CANCELLED'}">
                                    <div class="small text-muted fst-italic">
                                        <i class="fa-solid fa-ban me-1 text-danger"></i>Yêu cầu này đã kết thúc với trạng thái: <strong>${r.status}</strong>.
                                    </div>
                                </c:if>
                            </div>
                        </div>

                        <!-- Modal Phân Công Shipper Tiêu Chuẩn Thu Gom Sách Cũ -->
                        <div class="modal fade" id="assignSellShipperModal${r.id}" tabindex="-1" aria-hidden="true">
                            <div class="modal-dialog modal-dialog-centered modal-lg text-start">
                                <div class="modal-content border-0 shadow-lg rounded-4 overflow-hidden">
                                    <div class="modal-header border-0 bg-primary text-white py-3 px-4">
                                        <h5 class="modal-title fw-bold fs-6">
                                            <i class="fa-solid fa-motorcycle me-2"></i>Phân Công Shipper Tiêu Chuẩn Lấy Sách Thu Mua
                                        </h5>
                                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                    </div>
                                    <form method="post" action="/vendor/sell-requests/${r.id}/assign-shipper">
                                        <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                        <div class="modal-body p-4 bg-light">
                                            <div class="row g-3">
                                                <!-- Cột trái: Thông tin yêu cầu lấy sách -->
                                                <div class="col-md-5">
                                                    <div class="card border-0 shadow-sm rounded-3 p-3 h-100 bg-white">
                                                        <div class="fw-bold text-dark mb-2 pb-2 border-bottom">
                                                            <i class="fa-solid fa-receipt text-primary me-2"></i>Thông tin thu gom
                                                        </div>
                                                        <div class="small mb-2">
                                                            <span class="text-muted d-block">Mã yêu cầu:</span>
                                                            <span class="fw-bold text-primary">#SR-${r.id} (${r.items.size()} cuốn)</span>
                                                        </div>
                                                        <div class="small mb-2">
                                                            <span class="text-muted d-block">Khách hàng:</span>
                                                            <span class="fw-bold text-dark"><c:out value="${r.customer.fullName}"/></span>
                                                            <span class="text-muted">(<c:out value="${r.customer.phone}"/>)</span>
                                                        </div>
                                                        <div class="small mb-2">
                                                            <span class="text-muted d-block">Địa chỉ lấy sách tại nhà:</span>
                                                            <span class="text-danger fw-bold"><c:out value="${r.note}"/></span>
                                                        </div>
                                                        <div class="small mb-2">
                                                            <span class="text-muted d-block">Số tiền trả cho khách:</span>
                                                            <span class="fw-bold text-success fs-6">
                                                                <fmt:formatNumber value="${r.offeredTotal != null ? r.offeredTotal : r.expectedTotal}" pattern="#,##0"/> đ
                                                            </span>
                                                        </div>
                                                        <div class="small mb-2">
                                                            <span class="text-muted d-block">Phí trả Shipper (trừ vào thu nhập Shop):</span>
                                                            <span class="fw-bold text-danger">20.000 ₫</span>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Cột phải: Chọn Shipper Tiêu Chuẩn -->
                                                <div class="col-md-7">
                                                    <div class="card border-0 shadow-sm rounded-3 p-3 h-100 bg-white">
                                                        <div class="mb-3">
                                                            <label class="form-label small fw-bold text-dark">
                                                                Chọn Shipper Tiêu Chuẩn nhận việc: <span class="text-danger">*</span>
                                                            </label>
                                                            <div class="alert alert-info py-2 px-3 small border-0 mb-2">
                                                                <i class="fa-solid fa-shield-halved me-1"></i>Chính sách thu gom: Chỉ phân công cho nhân viên <strong>Shipper Tiêu Chuẩn</strong> của chi nhánh.
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
                                                                <i class="fa-solid fa-lock me-1"></i>Hệ thống tự động khóa các shipper đang bận hoặc đã từ chối yêu cầu này.
                                                            </div>
                                                        </div>

                                                        <div class="mb-2">
                                                            <label class="form-label small fw-bold text-dark">Ghi chú cho Shipper:</label>
                                                            <textarea name="note" class="form-control form-control-sm" rows="2" placeholder="Ghi chú thêm...">Đến lấy sách cũ thu mua tại nhà khách hàng mang về kho chi nhánh</textarea>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="modal-footer border-0 bg-white py-3 px-4">
                                            <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">Đóng</button>
                                            <button type="submit" class="btn btn-primary rounded-pill px-4 fw-bold shadow-sm">
                                                <i class="fa-solid fa-paper-plane me-1"></i>Xác Nhận Phân Shipper
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty requests}">
                    <div class="col-12">
                        <div class="card border-0 shadow-sm rounded-4 p-5 text-center bg-white">
                            <i class="fa-solid fa-box-open fs-1 text-muted mb-3"></i>
                            <h5 class="fw-bold text-dark">Chưa có yêu cầu thu mua nào</h5>
                            <p class="text-muted small mb-0">Khi khách hàng đăng bán sách cũ trên website, thông tin sẽ hiển thị tại đây để cửa hàng xem và thẩm định.</p>
                        </div>
                    </div>
                </c:if>
            </div>
        </main>
    </div>
</div>

<jsp:include page="../../common/footer.jsp"/>
