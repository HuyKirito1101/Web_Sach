<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Hồ Sơ Cá Nhân - Sách Cũ Việt"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<div class="container py-4">
    <h3 class="fw-bold mb-4"><i class="fa-solid fa-user text-warning me-2"></i>Hồ Sơ Cá Nhân & Địa Chỉ</h3>

    <c:if test="${not empty successMessage}"><div class="alert alert-success"><c:out value="${successMessage}"/></div></c:if>
    <c:if test="${not empty errorMessage}"><div class="alert alert-danger"><c:out value="${errorMessage}"/></div></c:if>

    <div class="row g-4">
        <!-- Update Profile -->
        <div class="col-lg-6">
            <div class="card border-0 shadow-sm rounded-3 p-4">
                <h5 class="fw-bold mb-3 border-bottom pb-2">Thông Tin Cá Nhân</h5>
                <form action="/profile/update" method="POST">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <div class="mb-3">
                        <label class="form-label fw-medium small">Họ và tên</label>
                        <input type="text" name="fullName" class="form-control" value="<c:out value='${user.fullName}'/>" required maxlength="100">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium small">Email (không thể thay đổi)</label>
                        <input type="email" class="form-control bg-light" value="<c:out value='${user.email}'/>" readonly>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium small">Số điện thoại</label>
                        <input type="text" name="phone" class="form-control" value="<c:out value='${user.phone}'/>" maxlength="20">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium small">Link ảnh đại diện (Avatar URL)</label>
                        <div class="d-flex align-items-center gap-3">
                            <c:set var="profileFallbackAvatar" value="https://ui-avatars.com/api/?name=${user.email}&background=FFC107&color=000" />
                            <img id="avatarPreview"
                                 src="<c:out value='${not empty user.avatarUrl ? user.avatarUrl : profileFallbackAvatar}'/>"
                                 data-fallback="<c:out value='${profileFallbackAvatar}'/>"
                                 class="rounded-circle border border-warning flex-shrink-0"
                                 width="64" height="64" alt="Xem trước ảnh đại diện"
                                 style="object-fit: cover;">
                            <input id="avatarUrl" type="url" name="avatarUrl" class="form-control" value="<c:out value='${user.avatarUrl}'/>" maxlength="500" pattern="https://.*" placeholder="https://...">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-warning rounded-pill fw-bold px-4">Cập Nhật Thông Tin</button>
                </form>
            </div>
        </div>

        <!-- Address List -->
        <div class="col-lg-6">
            <div class="card border-0 shadow-sm rounded-3 p-4">
                <div class="d-flex justify-content-between align-items-center mb-3 border-bottom pb-2">
                    <h5 class="fw-bold mb-0">Sổ Địa Chỉ Nhận Hàng</h5>
                    <button class="btn btn-warning btn-sm rounded-pill fw-bold" data-bs-toggle="collapse" data-bs-target="#addAddressForm">
                        <i class="fa-solid fa-plus me-1"></i>Thêm Địa Chỉ
                    </button>
                </div>

                <!-- Add Address Form -->
                <div class="collapse mb-4" id="addAddressForm">
                    <div class="bg-light p-3 rounded-3">
                        <h6 class="fw-bold mb-2">Thêm Địa Chỉ Mới</h6>
                        <form action="/profile/address/add" method="POST">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                            <div class="row g-2 mb-2">
                                <div class="col-md-6">
                                    <input type="text" name="recipientName" class="form-control form-control-sm" maxlength="100" placeholder="Tên người nhận" required>
                                </div>
                                <div class="col-md-6">
                                    <input type="text" name="phone" class="form-control form-control-sm" maxlength="20" placeholder="Số điện thoại" required>
                                </div>
                                <div class="col-12">
                                    <input type="text" name="street" class="form-control form-control-sm" maxlength="255" placeholder="Số nhà, Tên đường" required>
                                </div>
                                <div class="col-md-4">
                                    <input type="text" name="ward" class="form-control form-control-sm" maxlength="100" placeholder="Phường/Xã">
                                </div>
                                <div class="col-md-4">
                                    <input type="text" name="district" class="form-control form-control-sm" maxlength="100" placeholder="Quận/Huyện">
                                </div>
                                <div class="col-md-4">
                                    <input type="text" name="city" class="form-control form-control-sm" maxlength="100" placeholder="Tỉnh/Thành phố" required>
                                </div>
                            </div>
                            <div class="form-check mb-2">
                                <input type="checkbox" name="isDefault" value="true" class="form-check-input" id="isDefaultCheck">
                                <label class="form-check-label small" for="isDefaultCheck">Đặt làm địa chỉ mặc định</label>
                            </div>
                            <button type="submit" class="btn btn-warning btn-sm rounded-pill fw-bold">Lưu Địa Chỉ</button>
                        </form>
                    </div>
                </div>

                <!-- List of Addresses -->
                <c:choose>
                    <c:when test="${empty addresses}">
                        <p class="text-muted small">Bạn chưa thêm địa chỉ nào vào sổ địa chỉ.</p>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="addr" items="${addresses}">
                            <div class="border rounded-3 p-3 mb-2">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div>
                                        <strong class="text-dark"><c:out value="${addr.recipientName}"/></strong> | <span class="text-muted"><c:out value="${addr.phone}"/></span>
                                        <c:if test="${addr.isDefault}">
                                            <span class="badge bg-warning text-dark ms-2">Mặc định</span>
                                        </c:if>
                                        <br>
                                        <small class="text-secondary"><c:out value="${addr.street}"/>, <c:out value="${addr.ward != null ? addr.ward : ''}"/>, <c:out value="${addr.district != null ? addr.district : ''}"/>, <c:out value="${addr.city}"/></small>
                                    </div>
                                    <div class="d-flex gap-1">
                                        <c:if test="${!addr.isDefault}">
                                            <form action="/profile/address/set-default" method="POST">
                                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                                <input type="hidden" name="addressId" value="${addr.id}"/>
                                                <button type="submit" class="btn btn-outline-warning text-dark btn-sm rounded-pill px-2">Đặt mặc định</button>
                                            </form>
                                        </c:if>
                                        <form action="/profile/address/delete" method="POST">
                                            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                            <input type="hidden" name="addressId" value="${addr.id}"/>
                                            <button type="submit" class="btn btn-outline-danger btn-sm rounded-circle" title="Xóa"><i class="fa-solid fa-trash"></i></button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    const input = document.getElementById('avatarUrl');
    const preview = document.getElementById('avatarPreview');
    if (!input || !preview) return;

    preview.addEventListener('error', function () {
        preview.src = preview.dataset.fallback;
    });
    input.addEventListener('input', function () {
        preview.src = input.value.trim() || preview.dataset.fallback;
    });
});
</script>

<jsp:include page="../common/footer.jsp"/>
