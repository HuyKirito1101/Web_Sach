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
                <h3 class="fw-bold mb-0"><i class="fa-solid fa-user-group text-primary me-2"></i>Danh Sách Nhân Viên & Shipper Chi Nhánh</h3>
            </div>

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
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="s" items="${staffList}">
                                    <tr>
                                        <td>${s.id}</td>
                                        <td class="fw-bold text-dark">${s.fullName}</td>
                                        <td>${s.email}</td>
                                        <td>${s.phone}</td>
                                        <td><span class="badge bg-primary">${s.role.name}</span></td>
                                        <td><span class="badge ${s.status == 'ACTIVE' ? 'bg-success' : 'bg-secondary'}">${s.status}</span></td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../../common/footer.jsp" />
