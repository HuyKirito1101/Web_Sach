<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="title" value="Cửa hàng Vendor" scope="request"/><jsp:include page="../common/header.jsp"/>
<div class="d-flex"><jsp:include page="../common/sidebar.jsp"/><div class="flex-grow-1"><jsp:include page="../common/navbar.jsp"/><main class="main-content container-fluid">
<h3 class="fw-bold mb-4">${hasShop ? 'Hồ sơ cửa hàng' : 'Đăng ký cửa hàng'}</h3>
<c:if test="${not empty successMessage}"><div class="alert alert-success"><c:out value="${successMessage}"/></div></c:if><c:if test="${not empty errorMessage}"><div class="alert alert-danger"><c:out value="${errorMessage}"/></div></c:if>
<div class="card border-0 shadow-sm"><div class="card-body p-4">
    <c:if test="${hasShop}"><div class="alert alert-info">Trạng thái duyệt: <strong>${shop.status}</strong></div></c:if>
    <form method="post" action="/vendor/shop" enctype="multipart/form-data">
        <div class="row g-3"><div class="col-md-6"><label class="form-label">Tên cửa hàng</label><input class="form-control" name="name" value="<c:out value='${shop.name}'/>" required maxlength="150"></div>
        <div class="col-md-6"><label class="form-label">Email cửa hàng</label><input class="form-control" type="email" name="email" value="<c:out value='${shop.email}'/>"></div>
        <div class="col-md-6"><label class="form-label">Số điện thoại</label><input class="form-control" name="phone" value="<c:out value='${shop.phone}'/>" maxlength="20"></div>
        <div class="col-md-6"><label class="form-label">Địa chỉ</label><input class="form-control" name="address" value="<c:out value='${shop.address}'/>" required></div>
        <div class="col-12"><label class="form-label">Mô tả</label><textarea class="form-control" rows="4" name="description"><c:out value="${shop.description}"/></textarea></div>
        <div class="col-md-6"><label class="form-label">Logo (Cloudinary)</label><input class="form-control" type="file" name="logoFile" accept="image/*"><c:if test="${not empty shop.imageUrl}"><img src="<c:out value='${shop.imageUrl}'/>" class="mt-2 rounded" width="100" alt="Logo"></c:if></div>
        <div class="col-md-6"><label class="form-label">Ảnh bìa (Cloudinary)</label><input class="form-control" type="file" name="coverFile" accept="image/*"><c:if test="${not empty shop.coverUrl}"><img src="<c:out value='${shop.coverUrl}'/>" class="mt-2 rounded" width="180" alt="Ảnh bìa"></c:if></div></div>
        <button class="btn btn-primary mt-4"><i class="fa-solid fa-floppy-disk me-2"></i>${hasShop ? 'Cập nhật' : 'Gửi đăng ký'}</button>
    </form>
</div></div></main></div></div><jsp:include page="../common/footer.jsp"/>
