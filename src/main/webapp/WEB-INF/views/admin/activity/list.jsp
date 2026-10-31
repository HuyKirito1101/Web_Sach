<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="title" value="Nhật Ký Hệ Thống - Admin" scope="request" />
<jsp:include page="../../common/header.jsp" />

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp" />
    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp" />
        <main class="main-content container-fluid">
            <div class="mb-4">
                <h3 class="fw-bold mb-1"><i class="fa-solid fa-shield-halved text-primary me-2"></i>Nhật Ký Hệ Thống</h3>
                <div class="text-muted">100 sự kiện gần nhất: đăng nhập, truy cập trang quản trị và thao tác Admin/Manager.</div>
            </div>

            <div class="card border-0 shadow-sm rounded-3">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr>
                                <th>Thời gian</th>
                                <th>Tài khoản</th>
                                <th>Phạm vi</th>
                                <th>Sự kiện</th>
                                <th>Chi tiết</th>
                                <th>IP / Trình duyệt</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="activity" items="${activities}">
                                <tr>
                                    <td class="text-nowrap"><c:out value="${activity.formattedCreatedAt}"/></td>
                                    <td><div class="fw-semibold"><c:out value="${activity.managerName}"/></div><small class="text-muted"><c:out value="${activity.managerEmail}"/></small></td>
                                    <td><c:out value="${activity.branchName}"/></td>
                                    <td>
                                        <span class="badge ${activity.eventType == 'ERROR' || activity.eventType == 'LOGIN_FAILURE' ? 'bg-danger' : (activity.eventType == 'ACTION' || activity.eventType == 'LOGIN_SUCCESS' ? 'bg-primary' : 'bg-secondary')}">
                                            <c:choose>
                                                <c:when test="${activity.eventType == 'LOGIN_SUCCESS'}">Đăng nhập thành công</c:when>
                                                <c:when test="${activity.eventType == 'LOGIN_FAILURE'}">Đăng nhập thất bại</c:when>
                                                <c:when test="${activity.eventType == 'ACTION'}">Thao tác</c:when>
                                                <c:when test="${activity.eventType == 'ERROR'}">Lỗi</c:when>
                                                <c:otherwise>Xem trang</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </td>
                                    <td>
                                        <c:out value="${activity.description}"/>
                                        <c:if test="${not empty activity.failureReason}"><div class="small text-danger mt-1"><c:out value="${activity.failureReason}"/></div></c:if>
                                    </td>
                                    <td class="small">
                                        <c:if test="${not empty activity.ipAddress}"><div>IP: <c:out value="${activity.ipAddress}"/></div></c:if>
                                        <c:if test="${not empty activity.userAgent}"><div class="text-muted text-break" style="max-width: 360px;"><c:out value="${activity.userAgent}"/></div></c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty activities}">
                                <tr><td colspan="6" class="text-center text-muted py-5">Chưa có sự kiện nào được ghi nhận.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>

<jsp:include page="../../common/footer.jsp" />
