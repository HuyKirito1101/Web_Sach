<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="title" value="Cấu Hình Chi Nhánh - Manager" scope="request" /><jsp:include page="../common/header.jsp" />
<div class="d-flex"><jsp:include page="../common/sidebar.jsp" /><div class="flex-grow-1"><jsp:include page="../common/navbar.jsp" /><div class="main-content container-fluid">
    <h3 class="fw-bold mb-4"><i class="fa-solid fa-sliders text-primary me-2"></i>Cấu Hình Chi Nhánh</h3>
    <c:if test="${not empty successMessage}"><div class="alert alert-success"><c:out value="${successMessage}"/></div></c:if><c:if test="${not empty errorMessage}"><div class="alert alert-danger"><c:out value="${errorMessage}"/></div></c:if>
    <div class="row"><div class="col-lg-7"><div class="card border-0 shadow-sm"><div class="card-body p-4"><h5 class="fw-bold"><c:out value="${branch.name}"/></h5><p class="text-muted"><i class="fa-solid fa-location-dot me-2"></i><c:out value="${branch.address}"/></p><hr><form action="/manager/settings/commission" method="post">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"><label class="form-label fw-bold">Chiết khấu ứng dụng cho shop (%)</label><div class="input-group"><input type="number" min="0" max="100" step="0.1" name="appDiscountPercent" value="${branch.appDiscountPercent}" class="form-control" required><span class="input-group-text">%</span><button class="btn btn-primary">Cập nhật</button></div><div class="form-text">Tỷ lệ phí/chiết khấu mà hệ thống áp dụng cho chi nhánh này.</div></form></div></div></div></div>
</div></div></div><jsp:include page="../common/footer.jsp" />
