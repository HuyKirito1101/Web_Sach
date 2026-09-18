<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Hồ Sơ Cá Nhân - Sách Cũ Việt"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<div class="container py-4">
    <h3 class="fw-bold mb-4"><i class="fa-solid fa-user text-warning me-2"></i>Hồ Sơ Cá Nhân & Địa Chỉ</h3>

    <div class="row g-4">
        <!-- Update Profile -->
        <div class="col-lg-6">
            <div class="card border-0 shadow-sm rounded-3 p-4">
                <h5 class="fw-bold mb-3 border-bottom pb-2">Thông Tin Cá Nhân</h5>
                <form action="/profile/update" method="POST">
                    <div class="mb-3">
                        <label class="form-label fw-medium small">Họ và tên</label>
                        <input type="text" name="fullName" class="form-control" value="${user.fullName}" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium small">Email (không thể thay đổi)</label>
                        <input type="email" class="form-control bg-light" value="${user.email}" readonly>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium small">Số điện thoại</label>
                        <input type="text" name="phone" class="form-control" value="${user.phone}">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium small">Link ảnh đại diện (Avatar URL)</label>
                        <input type="text" name="avatarUrl" class="form-control" value="${user.avatarUrl}" placeholder="https://...">
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
                            <div class="row g-2 mb-2">
                                <div class="col-md-6">
                                    <input type="text" name="recipientName" class="form-control form-control-sm" placeholder="Tên người nhận" required>
                                </div>
                                <div class="col-md-6">
                                    <input type="text" name="phone" class="form-control form-control-sm" placeholder="Số điện thoại" required>
                                </div>
                                <div class="col-12">
                                    <input type="text" name="street" class="form-control form-control-sm" placeholder="Số nhà, Tên đường" required>
                                </div>
                                <div class="col-md-4">
                                    <input type="text" name="ward" class="form-control form-control-sm" placeholder="Phường/Xã">
                                </div>
                                <div class="col-md-4">
                                    <input type="text" name="district" class="form-control form-control-sm" placeholder="Quận/Huyện">
                                </div>
                                <div class="col-md-4">
                                    <input type="text" name="city" class="form-control form-control-sm" placeholder="Tỉnh/Thành phố" required>
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
                                        <strong class="text-dark">${addr.recipientName}</strong> | <span class="text-muted">${addr.phone}</span>
                                        <c:if test="${addr.isDefault}">
                                            <span class="badge bg-warning text-dark ms-2">Mặc định</span>
                                        </c:if>
                                        <br>
                                        <small class="text-secondary">${addr.street}, ${addr.ward != null ? addr.ward : ''}, ${addr.district != null ? addr.district : ''}, ${addr.city}</small>
                                    </div>
                                    <div class="d-flex gap-1">
                                        <c:if test="${!addr.isDefault}">
                                            <form action="/profile/address/set-default" method="POST">
                                                <input type="hidden" name="addressId" value="${addr.id}"/>
                                                <button type="submit" class="btn btn-outline-warning text-dark btn-sm rounded-pill px-2">Đặt mặc định</button>
                                            </form>
                                        </c:if>
                                        <form action="/profile/address/delete" method="POST">
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

<jsp:include page="../common/footer.jsp"/>
