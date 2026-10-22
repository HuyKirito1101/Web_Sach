<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="title" value="Nhân Viên Chi Nhánh - Manager" scope="request" />
<jsp:include page="../../common/header.jsp" />

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp" />

    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp" />

        <div class="main-content container-fluid">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div><h3 class="fw-bold mb-0"><i class="fa-solid fa-user-group text-primary me-2"></i>Người Dùng Chi Nhánh</h3><small class="text-muted"><c:out value="${branch.name}"/></small></div>
                <form action="/manager/staff" method="get" class="d-flex gap-2">
                    <input name="keyword" value="<c:out value='${keyword}'/>" class="form-control" placeholder="Tên, email, số điện thoại">
                    <button class="btn btn-primary"><i class="fa-solid fa-magnifying-glass"></i></button>
                </form>
            </div>

            <c:if test="${not empty successMessage}"><div class="alert alert-success"><c:out value="${successMessage}"/></div></c:if>
            <c:if test="${not empty errorMessage}"><div class="alert alert-danger"><c:out value="${errorMessage}"/></div></c:if>

            <div class="card border-0 shadow-sm rounded-3">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Họ và Tên</th>
                                    <th>Email</th>
                                    <th>Số Điện Thoại</th>
                                    <th>Quyền Hạn</th>
                                    <th>Trạng Thái</th>
                                    <th class="text-end">Thao Tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="s" items="${staffList}">
                                    <tr>
                                        <td>${s.id}</td>
                                        <td class="fw-bold text-dark"><c:out value="${s.fullName}"/></td>
                                        <td><c:out value="${s.email}"/></td>
                                        <td><c:out value="${s.phone}"/></td>
                                        <td><span class="badge bg-primary"><c:out value="${s.role.name}"/></span></td>
                                        <td><span class="badge ${s.status == 'ACTIVE' ? 'bg-success' : 'bg-secondary'}">${s.status}</span></td>
                                        <td class="text-end">
                                            <c:choose>
                                                <c:when test="${s.role.name == 'ROLE_ADMIN' || s.role.name == 'ROLE_MANAGER'}"><span class="text-muted small">Được bảo vệ</span></c:when>
                                                <c:otherwise><form action="/manager/staff/${s.id}/toggle-lock" method="post"><button class="btn btn-sm ${s.status == 'LOCKED' ? 'btn-outline-success' : 'btn-outline-warning'}"><i class="fa-solid ${s.status == 'LOCKED' ? 'fa-lock-open' : 'fa-lock'} me-1"></i>${s.status == 'LOCKED' ? 'Mở khóa' : 'Khóa'}</button></form></c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty staffList}"><tr><td colspan="7" class="text-center text-muted py-5">Không tìm thấy người dùng trong chi nhánh.</td></tr></c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../../common/footer.jsp" />
