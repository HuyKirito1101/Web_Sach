<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="title" value="Khuyến Mãi Cửa Hàng" scope="request"/>
<jsp:include page="../../common/header.jsp"/>

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp"/>
    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp"/>
        <main class="main-content container-fluid py-4 px-lg-4">

            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold mb-1 text-dark">
                        <i class="fa-solid fa-percent text-warning me-2"></i>Chương Trình Khuyến Mãi
                    </h3>
                    <p class="text-muted mb-0 small">
                        Quản lý các chương trình giảm giá riêng của cửa hàng và các ưu đãi chung toàn cơ sở từ Quản lý chi nhánh
                    </p>
                </div>
                <button class="btn btn-primary rounded-pill fw-bold" data-bs-toggle="modal" data-bs-target="#promotionModal">
                    <i class="fa-solid fa-plus me-1"></i> Tạo Khuyến Mãi Riêng
                </button>
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

            <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                <div class="table-responsive">
                    <table class="table align-middle mb-0 table-hover">
                        <thead class="table-light text-secondary small text-uppercase">
                            <tr>
                                <th class="ps-3">Tên Chương Trình</th>
                                <th>Phạm Vi Áp Dụng</th>
                                <th>Loại Khuyến Mãi</th>
                                <th>Mức Giảm</th>
                                <th>Đơn Tối Thiểu</th>
                                <th>Thời Gian Hiệu Lực</th>
                                <th>Trạng Thái</th>
                                <th class="text-center" style="width: 140px;">Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${promotions}">
                                <tr>
                                    <td class="ps-3 fw-bold text-dark">
                                        <c:out value="${p.title}"/>
                                        <div class="mt-1">
                                            <span class="badge bg-light text-dark border font-monospace" style="font-size: 11px;">
                                                <i class="fa-solid fa-tag me-1 text-warning"></i>${p.displayCode}
                                            </span>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${empty p.vendor}">
                                                <span class="badge bg-primary px-2 py-1 rounded-pill">
                                                    <i class="fa-solid fa-building me-1"></i>Toàn cơ sở (Manager)
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-success px-2 py-1 rounded-pill">
                                                    <i class="fa-solid fa-store me-1"></i>Riêng cửa hàng
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <span class="badge ${p.type == 'SHIPPING_PERCENT' ? 'bg-info text-dark' : 'bg-warning text-dark'}">
                                            ${p.type == 'SHIPPING_PERCENT' ? 'Phí vận chuyển' : 'Sản phẩm'}
                                        </span>
                                    </td>
                                    <td class="fw-bold text-danger">
                                        ${p.discountPercent}%
                                        <c:if test="${not empty p.maxDiscountAmount && p.maxDiscountAmount > 0}">
                                            <div class="small text-muted" style="font-size: 11px;">Tối đa: ${p.maxDiscountAmount} đ</div>
                                        </c:if>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${not empty p.minOrderValue && p.minOrderValue > 0}">
                                                ${p.minOrderValue} đ
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-muted">Không giới hạn</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="small">
                                            <div>Từ: <strong>${p.startDate}</strong></div>
                                            <div>Đến: <strong>${p.endDate}</strong></div>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge ${p.active ? 'bg-success' : 'bg-secondary'} rounded-pill px-2 py-1">
                                            ${p.active ? 'ĐANG CHẠY' : 'TẠM DỪNG'}
                                        </span>
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${empty p.vendor}">
                                                <span class="text-muted small fst-italic" title="Khuyến mãi do Quản lý cơ sở tạo">
                                                    <i class="fa-solid fa-lock me-1"></i>Chung cơ sở
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <form method="post" action="/vendor/promotions/${p.id}/delete" onsubmit="return confirm('Bạn có chắc chắn muốn xóa chương trình khuyến mãi này?');">
                                                    <c:if test="${not empty _csrf}">
                                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                                                    </c:if>
                                                    <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-3">
                                                        <i class="fa-solid fa-trash me-1"></i> Xóa
                                                    </button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty promotions}">
                                <tr>
                                    <td colspan="8" class="text-center py-5 text-muted">
                                        <i class="fa-solid fa-ticket-simple fs-2 mb-2 text-secondary d-block"></i>
                                        Hiện tại chưa có chương trình khuyến mãi nào áp dụng cho cửa hàng.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Modal Tạo Khuyến Mãi Riêng -->
            <div class="modal fade" id="promotionModal" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <form class="modal-content border-0 shadow rounded-4" method="post" action="/vendor/promotions/save">
                        <c:if test="${not empty _csrf}">
                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
                        </c:if>
                        <div class="modal-header border-0 bg-light">
                            <h5 class="modal-title fw-bold">
                                <i class="fa-solid fa-tag text-primary me-2"></i>Tạo Khuyến Mãi Riêng Cho Shop
                            </h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body p-4">
                            <div class="mb-3">
                                <label class="form-label small fw-bold">Tên chương trình khuyến mãi: <span class="text-danger">*</span></label>
                                <input class="form-control" name="title" placeholder="VD: Giảm giá sách văn học cuối tuần..." required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small fw-bold">Mã khuyến mãi (Tùy chọn):</label>
                                <input class="form-control font-monospace" name="code" placeholder="VD: SHOPVIP10 (để trống hệ thống tự tạo mã)">
                            </div>
                            <div class="mb-3">
                                <label class="form-label small fw-bold">Loại khuyến mãi: <span class="text-danger">*</span></label>
                                <select name="type" class="form-select">
                                    <option value="PRODUCT_PERCENT">Giảm % giá sách (Sản phẩm)</option>
                                    <option value="SHIPPING_PERCENT">Giảm % phí vận chuyển</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label small fw-bold">Phần trăm giảm (%): <span class="text-danger">*</span></label>
                                <input class="form-control" type="number" name="discountPercent" min="0.01" max="100" step="0.01" placeholder="VD: 15" required>
                            </div>
                            <div class="row g-2 mb-3">
                                <div class="col-6">
                                    <label class="form-label small fw-bold">Đơn tối thiểu (₫):</label>
                                    <input class="form-control" type="number" min="0" name="minOrderValue" placeholder="VD: 100000">
                                </div>
                                <div class="col-6">
                                    <label class="form-label small fw-bold">Giảm tối đa (₫):</label>
                                    <input class="form-control" type="number" min="0" name="maxDiscountAmount" placeholder="VD: 50000">
                                </div>
                            </div>
                            <div class="row g-2 mb-3">
                                <div class="col-6">
                                    <label class="form-label small fw-bold">Ngày bắt đầu: <span class="text-danger">*</span></label>
                                    <input class="form-control" type="date" name="startDate" required>
                                </div>
                                <div class="col-6">
                                    <label class="form-label small fw-bold">Ngày kết thúc: <span class="text-danger">*</span></label>
                                    <input class="form-control" type="date" name="endDate" required>
                                </div>
                            </div>
                            <div class="form-check mt-3">
                                <input class="form-check-input" type="checkbox" name="active" value="true" id="promoActive" checked>
                                <label class="form-check-label small fw-bold" for="promoActive">Kích hoạt chương trình ngay</label>
                            </div>
                        </div>
                        <div class="modal-footer border-0 bg-light">
                            <button type="button" class="btn btn-light rounded-pill" data-bs-dismiss="modal">Đóng</button>
                            <button type="submit" class="btn btn-primary rounded-pill fw-bold">
                                <i class="fa-solid fa-save me-1"></i> Lưu Chương Trình
                            </button>
                        </div>
                    </form>
                </div>
            </div>

        </main>
    </div>
</div>

<jsp:include page="../../common/footer.jsp"/>
