<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="title" value="Dịch Vụ Thu Mua Sách Cũ Tận Nhà - Sách Cũ Việt" scope="request"/>
<jsp:include page="../../common/header.jsp"/>
<jsp:include page="../../common/navbar.jsp"/>

<div class="container py-4">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb mb-0">
            <li class="breadcrumb-item"><a href="/" class="text-decoration-none text-muted">Trang chủ</a></li>
            <li class="breadcrumb-item"><a href="/policies/sell-books" class="text-decoration-none text-muted">Chính sách</a></li>
            <li class="breadcrumb-item active text-dark fw-bold" aria-current="page">Dịch vụ thu mua sách cũ tận nhà</li>
        </ol>
    </nav>

    <!-- Alerts -->
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show rounded-3 shadow-sm border-0 mb-4" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i><c:out value="${successMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show rounded-3 shadow-sm border-0 mb-4" role="alert">
            <i class="fa-solid fa-circle-exclamation me-2"></i><c:out value="${errorMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- Hero Banner -->
    <div class="card border-0 shadow-sm rounded-4 text-white overflow-hidden mb-5"
         style="background: linear-gradient(135deg, #1e3a8a 0%, #0d9488 100%);">
        <div class="card-body p-4 p-md-5">
            <div class="row align-items-center">
                <div class="col-lg-8">
                    <span class="badge bg-warning text-dark px-3 py-2 rounded-pill fw-bold mb-3">
                        <i class="fa-solid fa-truck-ramp-box me-1"></i> Dịch vụ thu mua tận nhà
                    </span>
                    <h2 class="fw-bold display-6 mb-3">Thu Gom &amp; Hồi Sinh Sách Cũ</h2>
                    <p class="lead mb-4 text-light opacity-90" style="font-size: 1.05rem;">
                        Nhằm lan tỏa tình yêu sách và tối ưu hóa vòng đời của tri thức, <strong>Sách Cũ Việt</strong> triển khai dịch vụ thu mua sách cũ, sách xưa, sách sưu tầm và ngoại văn tận nơi. Định giá minh bạch – Nhân viên đến tận nhà nhận sách – Thanh toán chuyển khoản 100% ngay khi nhận sách.
                    </p>
                    <div class="d-flex flex-wrap gap-3">
                        <a href="#sellFormSection" class="btn btn-warning btn-lg fw-bold px-4 py-2 rounded-pill shadow">
                            <i class="fa-solid fa-paper-plane me-2"></i>Gửi Yêu Cầu Thu Mua Ngay
                        </a>
                        <a href="/policies/sell-books" class="btn btn-outline-light btn-lg px-4 py-2 rounded-pill">
                            <i class="fa-solid fa-circle-info me-2"></i>Xem Chi Tiết Quy Trình
                        </a>
                    </div>
                </div>
                <div class="col-lg-4 text-center mt-4 mt-lg-0 d-none d-lg-block">
                    <i class="fa-solid fa-hand-holding-dollar display-1 text-warning opacity-75"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- 4 Bước Quy Trình Thu Mua (Đúng như phần Hỗ Trợ Khách Hàng) -->
    <div class="text-center mb-4">
        <h3 class="fw-bold text-dark">Quy Trình 4 Bước Thu Mua Tận Nhà</h3>
        <p class="text-muted small">Nhanh chóng, thuận tiện và minh bạch tuyệt đối</p>
    </div>

    <div class="row g-4 mb-5">
        <div class="col-md-6 col-lg-3">
            <div class="card border-0 shadow-sm h-100 rounded-4 text-center p-3">
                <div class="card-body">
                    <div class="d-inline-flex align-items-center justify-content-center bg-primary bg-opacity-10 text-primary rounded-circle mb-3" style="width: 60px; height: 60px;">
                        <i class="fa-solid fa-clipboard-list fs-3"></i>
                    </div>
                    <h6 class="fw-bold text-dark">1. Cung Cấp Thông Tin</h6>
                    <p class="small text-muted mb-0">Quý khách gửi danh sách sách, mô tả tình trạng bìa/gáy và địa chỉ cần lấy sách tận nơi.</p>
                </div>
            </div>
        </div>
        <div class="col-md-6 col-lg-3">
            <div class="card border-0 shadow-sm h-100 rounded-4 text-center p-3">
                <div class="card-body">
                    <div class="d-inline-flex align-items-center justify-content-center bg-info bg-opacity-10 text-info rounded-circle mb-3" style="width: 60px; height: 60px;">
                        <i class="fa-solid fa-tags fs-3"></i>
                    </div>
                    <h6 class="fw-bold text-dark">2. Thẩm Định &amp; Báo Giá</h6>
                    <p class="small text-muted mb-0">Nhân viên phụ trách của Sách Cũ Việt liên hệ trong 24h để thẩm định và gửi mức giá đề nghị minh bạch.</p>
                </div>
            </div>
        </div>
        <div class="col-md-6 col-lg-3">
            <div class="card border-0 shadow-sm h-100 rounded-4 text-center p-3">
                <div class="card-body">
                    <div class="d-inline-flex align-items-center justify-content-center bg-warning bg-opacity-10 text-warning rounded-circle mb-3" style="width: 60px; height: 60px;">
                        <i class="fa-solid fa-truck-moving fs-3"></i>
                    </div>
                    <h6 class="fw-bold text-dark">3. Giao Nhận Sách</h6>
                    <p class="small text-muted mb-0">Đội ngũ nhân viên đến tận nhà đóng gói nhận sách tại TP.HCM, hoặc hỗ trợ chi phí gửi bưu điện nếu ở xa.</p>
                </div>
            </div>
        </div>
        <div class="col-md-6 col-lg-3">
            <div class="card border-0 shadow-sm h-100 rounded-4 text-center p-3">
                <div class="card-body">
                    <div class="d-inline-flex align-items-center justify-content-center bg-success bg-opacity-10 text-success rounded-circle mb-3" style="width: 60px; height: 60px;">
                        <i class="fa-solid fa-money-bill-wave fs-3"></i>
                    </div>
                    <h6 class="fw-bold text-dark">4. Thanh Toán Nhận Tiền</h6>
                    <p class="small text-muted mb-0">Thanh toán chuyển khoản hoặc tiền mặt 100% ngay khi nhân viên kiểm đếm đủ số lượng sách.</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Form Gửi Yêu Cầu Thu Mua -->
    <div class="row g-4 mb-5" id="sellFormSection">
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                <div class="card-header bg-warning bg-opacity-25 border-0 py-3 px-4">
                    <h5 class="fw-bold text-dark mb-0">
                        <i class="fa-solid fa-pen-to-square text-dark me-2"></i>Gửi Yêu Cầu Thu Mua Sách Cũ Tận Nhà
                    </h5>
                </div>
                <div class="card-body p-4">
                    <form method="post" action="/sell-books" id="sellBookForm" enctype="multipart/form-data">
                        <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>

                        <div class="row g-3 mb-4">
                            <div class="col-md-6">
                                <label class="form-label small fw-bold text-dark">Chọn chi nhánh tiếp nhận: <span class="text-danger">*</span></label>
                                <select class="form-select rounded-3" name="branchId" required>
                                    <c:forEach var="b" items="${branches}">
                                        <option value="${b.id}">${b.name} - ${b.address}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label small fw-bold text-dark">Số điện thoại liên hệ: <span class="text-danger">*</span></label>
                                <input type="tel" name="phone" class="form-control rounded-3" required
                                       value="<c:out value='${currentUser != null ? currentUser.phone : ""}'/>"
                                       placeholder="Số điện thoại của bạn...">
                            </div>
                            <div class="col-12">
                                <label class="form-label small fw-bold text-dark">Địa chỉ lấy sách tận nhà: <span class="text-danger">*</span></label>
                                <input type="text" name="pickupAddress" class="form-control rounded-3" required
                                       placeholder="Số nhà, tên đường, phường/xã, quận/huyện...">
                            </div>
                        </div>

                        <!-- Danh sách sách cần bán -->
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="fw-bold text-dark mb-0">
                                <i class="fa-solid fa-book text-primary me-2"></i>Danh Sách Sách Muốn Bán
                            </h6>
                            <button type="button" class="btn btn-sm btn-outline-primary rounded-pill fw-bold" onclick="addBookRow()">
                                <i class="fa-solid fa-plus me-1"></i> Thêm Sách Khác
                            </button>
                        </div>

                        <div id="bookItemsContainer">
                            <!-- Dòng sách 1 -->
                            <div class="card border rounded-3 p-3 mb-3 book-item-row bg-light bg-opacity-50">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <span class="badge bg-secondary">Cuốn #1</span>
                                    <button type="button" class="btn btn-sm btn-link text-danger p-0 text-decoration-none remove-btn d-none" onclick="removeBookRow(this)">
                                        <i class="fa-solid fa-trash me-1"></i>Xóa
                                    </button>
                                </div>
                                <div class="row g-2">
                                    <div class="col-md-6">
                                        <label class="form-label small text-muted mb-1">Tên sách / Tác phẩm: <span class="text-danger">*</span></label>
                                        <input type="text" name="bookTitle" class="form-control form-control-sm rounded-2" required placeholder="Ví dụ: Tắt Đèn (Bản cũ 1988)">
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label small text-muted mb-1">Mã ISBN (nếu có):</label>
                                        <input type="text" name="isbn" class="form-control form-control-sm rounded-2" placeholder="978604...">
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label small text-muted mb-1">Giá kỳ vọng (VNĐ):</label>
                                        <input type="number" min="0" step="5000" name="expectedPrice" class="form-control form-control-sm rounded-2" placeholder="Ví dụ: 50000">
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label small text-muted mb-1">Tình trạng sách (bìa, ruột, trang): <span class="text-danger">*</span></label>
                                        <input type="text" name="conditionDescription" class="form-control form-control-sm rounded-2" required placeholder="Bìa sờn nhẹ, trang đủ không rách, giấy ố vàng...">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small text-muted mb-1">
                                            <i class="fa-solid fa-camera text-primary me-1"></i>Tải ảnh bìa / gáy sách (JPG, PNG...):
                                        </label>
                                        <input type="file" name="imageFiles" accept="image/png, image/jpeg, image/jpg, image/webp" class="form-control form-control-sm rounded-2" onchange="previewBookImage(this)">
                                        <div class="image-preview mt-2 d-none align-items-center gap-2">
                                            <img src="" class="rounded border shadow-sm preview-thumb" style="width: 50px; height: 65px; object-fit: cover;">
                                            <span class="small text-muted preview-name text-truncate" style="max-width: 200px;"></span>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label small text-muted mb-1">Hoặc nhập link ảnh online (nếu có):</label>
                                        <input type="url" name="imageUrl" class="form-control form-control-sm rounded-2" placeholder="https://imgur.com/... hoặc để trống">
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label small fw-bold text-dark">Ghi chú thêm cho cửa hàng:</label>
                            <textarea name="note" class="form-control rounded-3" rows="2" placeholder="Ví dụ: Tôi rảnh vào buổi chiều từ 14h-17h, cần hỗ trợ thùng carton đóng gói..."></textarea>
                        </div>

                        <div class="d-grid">
                            <button type="submit" class="btn btn-warning btn-lg fw-bold rounded-pill shadow-sm py-3">
                                <i class="fa-solid fa-paper-plane me-2"></i>Gửi Yêu Cầu Thu Mua Sách Tận Nhà
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <!-- Hotline & Tiêu chí ưu tiên thu mua -->
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm rounded-4 p-4 mb-4 bg-light">
                <h6 class="fw-bold text-dark mb-3"><i class="fa-solid fa-headset text-warning me-2"></i>Liên Hệ Nhanh</h6>
                <p class="small text-muted">Nếu quý khách có số lượng sách lớn hoặc cần định giá ngay qua Zalo:</p>
                <div class="d-flex align-items-center mb-3">
                    <i class="fa-solid fa-phone-volume fs-4 text-primary me-3"></i>
                    <div>
                        <div class="small text-muted">Hotline / Zalo:</div>
                        <a href="tel:0376131883" class="fw-bold text-dark text-decoration-none fs-6">0376 131 883</a>
                    </div>
                </div>
                <div class="d-flex align-items-center mb-3">
                    <i class="fa-solid fa-envelope fs-4 text-danger me-3"></i>
                    <div>
                        <div class="small text-muted">Email thẩm định:</div>
                        <span class="fw-bold text-dark small">minhkhuyen779@gmail.com</span>
                    </div>
                </div>
            </div>

            <div class="card border-0 shadow-sm rounded-4 p-4">
                <h6 class="fw-bold text-dark mb-3"><i class="fa-solid fa-star text-warning me-2"></i>Danh Mục Ưu Tiên Thu Mua</h6>
                <ul class="small text-muted ps-3 mb-0">
                    <li class="mb-2">Sách văn học kinh điển, triết học, lịch sử, văn hóa.</li>
                    <li class="mb-2">Sách chuyên ngành y dược, kiến trúc, mỹ thuật, kinh tế.</li>
                    <li class="mb-2"><strong>Sách xuất bản trước năm 1975</strong>, sách quý hiếm, sách có chữ ký tác giả.</li>
                    <li>Sách ngoại văn, truyện tranh Manga nguyên bộ.</li>
                </ul>
            </div>
        </div>
    </div>

    <!-- Lịch Sử Yêu Cầu Thu Mua Của Khách Hàng -->
    <c:if test="${not empty myRequests}">
        <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-5 bg-white">
            <div class="card-header bg-white border-bottom py-3 px-4 d-flex flex-wrap justify-content-between align-items-center gap-2">
                <div>
                    <h5 class="fw-bold text-dark mb-0">
                        <i class="fa-solid fa-clock-rotate-left text-primary me-2"></i>Lịch Sử Yêu Cầu Thu Mua Của Bạn
                    </h5>
                    <div class="small text-muted mt-1">
                        Theo dõi thẩm định giá từ các Shop đối tác độc lập và chọn Shop có giá tốt nhất để bán sách.
                    </div>
                </div>
                <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill fw-bold fs-7">
                    ${myRequests.size()} Yêu Cầu
                </span>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table align-middle mb-0 table-hover">
                        <thead class="table-light small text-secondary">
                            <tr>
                                <th class="ps-4" style="width: 140px;">Mã &amp; Thời Gian</th>
                                <th style="width: 200px;">Chi Nhánh</th>
                                <th style="width: 220px;">Sách Cần Bán</th>
                                <th style="width: 110px;">Giá Kỳ Vọng</th>
                                <th>Báo Giá &amp; Chọn Shop Bán</th>
                                <th style="width: 130px;" class="text-center">Trạng Thái</th>
                                <th style="width: 90px;" class="text-center pe-4">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="req" items="${myRequests}">
                                <tr>
                                    <td class="ps-4">
                                        <div class="fw-bold text-primary fs-6">#SR-${req.id}</div>
                                        <div class="small text-muted" style="font-size: 11px;">
                                            <i class="fa-regular fa-clock me-1"></i>${req.formattedCreatedAt}
                                        </div>
                                    </td>
                                    <td>
                                        <div class="fw-bold small text-dark">${req.branch.name}</div>
                                        <div class="small text-muted text-truncate" style="font-size: 11px; max-width: 180px;">${req.branch.address}</div>
                                    </td>
                                    <td>
                                        <div class="fw-bold small text-dark">
                                            <i class="fa-solid fa-book-open text-primary me-1"></i>${req.items.size()} cuốn
                                        </div>
                                        <div class="small text-muted" style="font-size: 11px;">
                                            <c:forEach var="it" items="${req.items}" varStatus="loop">
                                                <span class="text-dark fw-semibold">${it.bookTitle}</span>${!loop.last ? ', ' : ''}
                                            </c:forEach>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="small fw-bold text-muted">
                                            <fmt:formatNumber value="${req.expectedTotal}" pattern="#,#00 ₫"/>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <%-- 1. Trạng thái QUOTED: Hiển thị các báo giá độc lập của các shop để khách chọn --%>
                                            <c:when test="${req.status == 'QUOTED'}">
                                                <c:choose>
                                                    <c:when test="${not empty req.quotes}">
                                                        <div class="d-flex flex-column gap-2 py-2" style="min-width: 300px;">
                                                            <div class="small fw-bold text-success">
                                                                <i class="fa-solid fa-tags me-1"></i>Có ${req.quotes.size()} Shop gửi báo giá (Hãy chọn Shop bạn muốn bán):
                                                            </div>
                                                            <c:forEach var="q" items="${req.quotes}">
                                                                <div class="p-2 rounded-3 border bg-light bg-opacity-50 shadow-sm">
                                                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                                                        <span class="fw-bold small text-dark">
                                                                            <i class="fa-solid fa-store text-primary me-1"></i><c:out value="${q.vendorName}"/>
                                                                        </span>
                                                                        <span class="badge text-white px-2 py-1 fw-bold fs-7" style="background: linear-gradient(135deg, #e11d48 0%, #be123c 100%);">
                                                                            <fmt:formatNumber value="${q.offeredPrice}" pattern="#,#00 ₫"/>
                                                                        </span>
                                                                    </div>
                                                                    <c:if test="${not empty q.note}">
                                                                        <div class="small text-muted fst-italic px-1" style="font-size: 11px;">
                                                                            "<c:out value="${q.note}"/>"
                                                                        </div>
                                                                    </c:if>
                                                                    <div class="d-flex justify-content-between align-items-center mt-2 pt-1 border-top">
                                                                        <span class="text-muted" style="font-size: 11px;">
                                                                            <i class="fa-regular fa-clock me-1"></i>${q.formattedCreatedAt}
                                                                        </span>
                                                                        <form method="post" action="/sell-books/${req.id}/accept-quote" class="d-inline"
                                                                              onsubmit="return confirm('Bạn đồng ý bán sách cho shop ${q.vendorName} với giá <fmt:formatNumber value="${q.offeredPrice}" pattern="#,#00 ₫"/>? Shop sẽ phân công shipper đến tận nhà để lấy sách.');">
                                                                            <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                                                            <input type="hidden" name="quoteId" value="${q.id}">
                                                                            <button type="submit" class="btn btn-sm text-white rounded-pill px-3 py-1 fw-bold shadow-sm"
                                                                                    style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); border: none; font-size: 11px;">
                                                                                <i class="fa-solid fa-handshake me-1"></i>Bán cho Shop này
                                                                            </button>
                                                                        </form>
                                                                    </div>
                                                                </div>
                                                            </c:forEach>
                                                        </div>
                                                    </c:when>
                                                    <c:when test="${not empty req.offeredTotal && req.offeredTotal > 0}">
                                                        <%-- Hỗ trợ dữ liệu báo giá đơn lẻ cũ --%>
                                                        <div class="p-2 rounded-3 border bg-white shadow-sm" style="min-width: 250px;">
                                                            <div class="d-flex justify-content-between align-items-center mb-1">
                                                                <span class="fw-bold small text-dark"><i class="fa-solid fa-store text-primary me-1"></i><c:out value="${req.buyerVendorName}"/></span>
                                                                <span class="badge text-white px-2 py-1 fw-bold fs-7" style="background: linear-gradient(135deg, #e11d48 0%, #be123c 100%);">
                                                                    <fmt:formatNumber value="${req.offeredTotal}" pattern="#,#00 ₫"/>
                                                                </span>
                                                            </div>
                                                            <c:if test="${not empty req.staffNote}">
                                                                <div class="small text-muted fst-italic" style="font-size: 11px;">"<c:out value="${req.staffNote}"/>"</div>
                                                            </c:if>
                                                            <div class="text-end mt-2 pt-1 border-top">
                                                                <form method="post" action="/sell-books/${req.id}/accept" class="d-inline"
                                                                      onsubmit="return confirm('Bạn đồng ý bán sách cho shop ${req.buyerVendorName} với mức giá <fmt:formatNumber value="${req.offeredTotal}" pattern="#,#00 ₫"/>?');">
                                                                    <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                                                    <button type="submit" class="btn btn-sm text-white rounded-pill px-3 py-1 fw-bold shadow-sm"
                                                                            style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); border: none; font-size: 11px;">
                                                                        <i class="fa-solid fa-handshake me-1"></i>Đồng ý bán cho Shop
                                                                    </button>
                                                                </form>
                                                            </div>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="small text-muted"><em>Đang cập nhật báo giá...</em></span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>

                                            <%-- 2. Trạng thái ACCEPTED: Khách hàng đã chọn shop bán thành công --%>
                                            <c:when test="${req.status == 'ACCEPTED'}">
                                                <div class="p-2 rounded-3 bg-success bg-opacity-10 border border-success-subtle text-success small" style="min-width: 250px;">
                                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                                        <span class="fw-bold text-dark"><i class="fa-solid fa-store text-success me-1"></i><c:out value="${req.buyerVendorName}"/></span>
                                                        <span class="badge bg-success text-white px-2 py-1 fs-7"><fmt:formatNumber value="${req.offeredTotal}" pattern="#,#00 ₫"/></span>
                                                    </div>
                                                    <div class="small text-dark mt-1">
                                                        <i class="fa-solid fa-truck-pickup text-primary me-1"></i>Shop đang phân công Shipper đến lấy sách tận nhà
                                                    </div>
                                                    <c:if test="${not empty req.staffNote}">
                                                        <div class="small text-muted fst-italic mt-1" style="font-size: 11px;">"<c:out value="${req.staffNote}"/>"</div>
                                                    </c:if>
                                                </div>
                                            </c:when>

                                            <%-- 3. Trạng thái COMPLETED: Đã nhận tiền thành công --%>
                                            <c:when test="${req.status == 'COMPLETED'}">
                                                <div class="p-2 rounded-3 bg-light border border-success-subtle small" style="min-width: 250px;">
                                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                                        <span class="fw-bold text-success"><i class="fa-solid fa-circle-check me-1"></i>Đã thanh toán</span>
                                                        <span class="badge bg-success text-white px-2 py-1 fs-7"><fmt:formatNumber value="${req.offeredTotal}" pattern="#,#00 ₫"/></span>
                                                    </div>
                                                    <div class="small text-muted"><i class="fa-solid fa-store me-1"></i>Shop: <c:out value="${req.buyerVendorName}"/></div>
                                                </div>
                                            </c:when>

                                            <%-- 4. Trạng thái PENDING / INSPECTING / CANCELLED --%>
                                            <c:otherwise>
                                                <div class="p-2 bg-light rounded-3 text-muted small" style="min-width: 220px;">
                                                    <i class="fa-solid fa-spinner fa-spin text-warning me-1"></i>
                                                    <em>Đang chờ các Shop thẩm định sách...</em>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${req.status == 'PENDING'}">
                                                <span class="badge bg-warning text-dark px-3 py-2 rounded-pill"><i class="fa-solid fa-clock me-1"></i>Chờ tiếp nhận</span>
                                            </c:when>
                                            <c:when test="${req.status == 'INSPECTING'}">
                                                <span class="badge bg-info text-dark px-3 py-2 rounded-pill"><i class="fa-solid fa-magnifying-glass me-1"></i>Đang thẩm định</span>
                                            </c:when>
                                            <c:when test="${req.status == 'QUOTED'}">
                                                <span class="badge bg-primary text-white px-3 py-2 rounded-pill shadow-sm"><i class="fa-solid fa-tags me-1"></i>Có báo giá</span>
                                            </c:when>
                                            <c:when test="${req.status == 'ACCEPTED'}">
                                                <span class="badge bg-success text-white px-3 py-2 rounded-pill shadow-sm"><i class="fa-solid fa-handshake me-1"></i>Đã chốt bán</span>
                                            </c:when>
                                            <c:when test="${req.status == 'COMPLETED'}">
                                                <span class="badge bg-success px-3 py-2 rounded-pill"><i class="fa-solid fa-circle-check me-1"></i>Hoàn tất</span>
                                            </c:when>
                                            <c:when test="${req.status == 'REJECTED'}">
                                                <span class="badge bg-danger px-3 py-2 rounded-pill"><i class="fa-solid fa-circle-xmark me-1"></i>Từ chối</span>
                                            </c:when>
                                            <c:when test="${req.status == 'CANCELLED'}">
                                                <span class="badge bg-secondary px-3 py-2 rounded-pill"><i class="fa-solid fa-ban me-1"></i>Đã hủy</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary px-3 py-2 rounded-pill">${req.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center pe-4">
                                        <c:if test="${req.status == 'PENDING' || req.status == 'INSPECTING' || req.status == 'QUOTED'}">
                                            <form method="post" action="/sell-books/${req.id}/cancel" class="d-inline"
                                                  onsubmit="return confirm('Bạn có chắc muốn hủy yêu cầu thu mua này?');">
                                                <c:if test="${not empty _csrf}"><input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" /></c:if>
                                                <button type="submit" class="btn btn-sm btn-outline-secondary rounded-pill px-2 py-1 small" title="Hủy yêu cầu">
                                                    <i class="fa-solid fa-xmark me-1"></i>Hủy
                                                </button>
                                            </form>
                                        </c:if>
                                        <c:if test="${req.status == 'ACCEPTED'}">
                                            <span class="badge bg-light text-muted border rounded-pill py-1 px-2" style="font-size: 11px;">
                                                <i class="fa-solid fa-lock me-1"></i>Đã chốt
                                            </span>
                                        </c:if>
                                        <c:if test="${req.status == 'COMPLETED'}">
                                            <i class="fa-solid fa-circle-check text-success fs-5"></i>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </c:if>
</div>

<!-- Script thêm/xóa dòng sách & xem trước ảnh -->
<script>
let bookIndex = 1;
function addBookRow() {
    bookIndex++;
    const container = document.getElementById('bookItemsContainer');
    const row = document.createElement('div');
    row.className = 'card border rounded-3 p-3 mb-3 book-item-row bg-light bg-opacity-50';
    row.innerHTML = `
        <div class="d-flex justify-content-between align-items-center mb-2">
            <span class="badge bg-secondary">Cuốn #${bookIndex}</span>
            <button type="button" class="btn btn-sm btn-link text-danger p-0 text-decoration-none remove-btn" onclick="removeBookRow(this)">
                <i class="fa-solid fa-trash me-1"></i>Xóa
            </button>
        </div>
        <div class="row g-2">
            <div class="col-md-6">
                <label class="form-label small text-muted mb-1">Tên sách / Tác phẩm: <span class="text-danger">*</span></label>
                <input type="text" name="bookTitle" class="form-control form-control-sm rounded-2" required placeholder="Ví dụ: Số Đỏ (Bản 1990)">
            </div>
            <div class="col-md-3">
                <label class="form-label small text-muted mb-1">Mã ISBN (nếu có):</label>
                <input type="text" name="isbn" class="form-control form-control-sm rounded-2" placeholder="978604...">
            </div>
            <div class="col-md-3">
                <label class="form-label small text-muted mb-1">Giá kỳ vọng (VNĐ):</label>
                <input type="number" min="0" step="5000" name="expectedPrice" class="form-control form-control-sm rounded-2" placeholder="Ví dụ: 40000">
            </div>
            <div class="col-12">
                <label class="form-label small text-muted mb-1">Tình trạng sách (bìa, ruột, trang): <span class="text-danger">*</span></label>
                <input type="text" name="conditionDescription" class="form-control form-control-sm rounded-2" required placeholder="Bìa cứng xưa, giấy ngả vàng, đầy đủ trang...">
            </div>
            <div class="col-md-6">
                <label class="form-label small text-muted mb-1">
                    <i class="fa-solid fa-camera text-primary me-1"></i>Tải ảnh bìa / gáy sách (JPG, PNG...):
                </label>
                <input type="file" name="imageFiles" accept="image/png, image/jpeg, image/jpg, image/webp" class="form-control form-control-sm rounded-2" onchange="previewBookImage(this)">
                <div class="image-preview mt-2 d-none align-items-center gap-2">
                    <img src="" class="rounded border shadow-sm preview-thumb" style="width: 50px; height: 65px; object-fit: cover;">
                    <span class="small text-muted preview-name text-truncate" style="max-width: 200px;"></span>
                </div>
            </div>
            <div class="col-md-6">
                <label class="form-label small text-muted mb-1">Hoặc nhập link ảnh online (nếu có):</label>
                <input type="url" name="imageUrl" class="form-control form-control-sm rounded-2" placeholder="https://imgur.com/... hoặc để trống">
            </div>
        </div>
    `;
    container.appendChild(row);
    updateRemoveButtons();
}

function removeBookRow(btn) {
    const row = btn.closest('.book-item-row');
    if (row) {
        row.remove();
        updateRemoveButtons();
    }
}

function updateRemoveButtons() {
    const rows = document.querySelectorAll('.book-item-row');
    rows.forEach((r, idx) => {
        const badge = r.querySelector('.badge');
        if (badge) badge.textContent = `Cuốn #${idx + 1}`;
        const removeBtn = r.querySelector('.remove-btn');
        if (removeBtn) {
            if (rows.length > 1) {
                removeBtn.classList.remove('d-none');
            } else {
                removeBtn.classList.add('d-none');
            }
        }
    });
}

function previewBookImage(input) {
    const row = input.closest('.row');
    if (!row) return;
    const previewDiv = input.parentElement.querySelector('.image-preview');
    const thumb = previewDiv.querySelector('.preview-thumb');
    const nameSpan = previewDiv.querySelector('.preview-name');

    if (input.files && input.files[0]) {
        const file = input.files[0];
        const reader = new FileReader();
        reader.onload = function(e) {
            thumb.src = e.target.result;
            nameSpan.textContent = file.name + ' (' + Math.round(file.size / 1024) + ' KB)';
            previewDiv.classList.remove('d-none');
            previewDiv.classList.add('d-flex');
        };
        reader.readAsDataURL(file);
    } else {
        previewDiv.classList.remove('d-flex');
        previewDiv.classList.add('d-none');
        thumb.src = '';
        nameSpan.textContent = '';
    }
}
</script>

<jsp:include page="../../common/footer.jsp"/>
