<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="title" value="Điều Chuyển Sách Cũ - Manager" scope="request" />
<jsp:include page="../../common/header.jsp" />

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp" />

    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp" />

        <div class="main-content container-fluid">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h3 class="fw-bold mb-1"><i class="fa-solid fa-right-left text-primary me-2"></i>Quản Lý Điều Chuyển Sách Giữa Các Chi Nhánh</h3>
                    <p class="text-muted small">Tạo và nhận yêu cầu điều chuyển các bản sách cũ trong hệ thống chuỗi cửa hàng</p>
                </div>
                <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createTransferModal">
                    <i class="fa-solid fa-plus me-1"></i> Tạo Yêu Cầu Điều Chuyển
                </button>
            </div>

            <div class="card border-0 shadow-sm rounded-3">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>Mã Lệnh</th>
                                    <th>Sách Điều Chuyển</th>
                                    <th>Từ Chi Nhánh (Nguồn)</th>
                                    <th>Đến Chi Nhánh (Đích)</th>
                                    <th>Số Lượng</th>
                                    <th>Trạng Thái</th>
                                    <th class="text-end">Thao Tác Duyệt / Nhận Hàng</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="t" items="${transfers}">
                                    <tr>
                                        <td class="fw-bold text-primary"><code>${t.transferCode}</code></td>
                                        <td>
                                            <div class="fw-bold">${t.bookCopy.book.title}</div>
                                            <span class="badge bg-secondary">${t.bookCopy.conditionRating}</span>
                                        </td>
                                        <td>${t.fromBranch.name}</td>
                                        <td>${t.toBranch.name}</td>
                                        <td class="fw-bold text-dark fs-6">${t.quantity}</td>
                                        <td>
                                            <span class="badge ${t.status == 'COMPLETED' ? 'bg-success' : (t.status == 'PENDING' ? 'bg-warning text-dark' : 'bg-info')}">
                                                ${t.status}
                                            </span>
                                        </td>
                                        <td class="text-end">
                                            <c:if test="${t.status == 'PENDING' && t.fromBranch.id == currentBranchId}">
                                                <a href="/manager/transfers/approve/${t.id}" class="btn btn-sm btn-success me-1"><i class="fa-solid fa-check me-1"></i> Duyệt Chuyển</a>
                                                <a href="/manager/transfers/reject/${t.id}" class="btn btn-sm btn-outline-danger"><i class="fa-solid fa-xmark"></i> Từ Chối</a>
                                            </c:if>
                                            <c:if test="${t.status == 'SHIPPING' && t.toBranch.id == currentBranchId}">
                                                <a href="/manager/transfers/complete/${t.id}" class="btn btn-sm btn-primary"><i class="fa-solid fa-box-open me-1"></i> Xác Nhận Nhận Sách</a>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Modal Create Transfer -->
            <div class="modal fade" id="createTransferModal" tabindex="-1">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <form action="/manager/transfers/create" method="post">
                            <input type="hidden" name="fromBranchId" value="${currentBranchId}" />
                            <div class="modal-header">
                                <h5 class="modal-title fw-bold">Tạo Yêu Cầu Điều Chuyển Sách</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="mb-3">
                                    <label class="form-label">Chọn Chi Nhánh Nhận (Đích)</label>
                                    <select name="toBranchId" class="form-select" required>
                                        <c:forEach var="b" items="${branches}">
                                            <c:if test="${b.id != currentBranchId}">
                                                <option value="${b.id}">${b.name}</option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Chọn Sách Cũ Điều Chuyển</label>
                                    <select name="bookCopyId" class="form-select" required>
                                        <c:forEach var="c" items="${copies}">
                                            <option value="${c.id}">${c.book.title} (Tình trạng: ${c.conditionRating} - Còn tồn: ${c.quantity})</option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Số Lượng Chuyển</label>
                                    <input type="number" name="quantity" class="form-control" value="1" min="1" required />
                                </div>

                                <div class="mb-3">
                                    <label class="form-label">Ghi Chú Lý Do Điều Chuyển</label>
                                    <textarea name="note" class="form-control" rows="2" placeholder="Ví dụ: Chi nhánh Q1 hết sách này, điều chuyển gấp 2 cuốn..."></textarea>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                <button type="submit" class="btn btn-primary">Gửi Yêu Cầu</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../../common/footer.jsp" />
