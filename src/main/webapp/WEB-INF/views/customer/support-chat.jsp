<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Nhắn Tin Chi Nhánh - Sách Cũ Việt"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<div class="container py-5" style="max-width: 900px;">
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i><c:out value="${successMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fa-solid fa-triangle-exclamation me-2"></i><c:out value="${errorMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <c:choose>
        <c:when test="${empty conversation}">
            <div class="card border-0 shadow rounded-4 overflow-hidden">
                <div class="card-header bg-warning border-0 p-4">
                    <h3 class="fw-bold mb-1"><i class="fa-solid fa-comments me-2"></i>Nhắn Tin Với Chi Nhánh</h3>
                    <p class="mb-0">Chọn cửa hàng cần hỗ trợ, Manager của chi nhánh sẽ phản hồi tại đây.</p>
                </div>
                <div class="card-body p-4">
                    <form action="/support-chat/start" method="post">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Họ tên</label>
                                <input type="text" name="customerName" class="form-control" maxlength="100"
                                       value="<c:out value='${customerName}'/>" placeholder="Có thể để trống">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Số điện thoại <span class="text-danger">*</span></label>
                                <input type="tel" name="phone" class="form-control" maxlength="20" required
                                       pattern="(?:0[0-9]{9}|\+84[0-9]{9})"
                                       value="<c:out value='${customerPhone}'/>" placeholder="Ví dụ: 0376131883">
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-semibold">Chi nhánh cần hỗ trợ <span class="text-danger">*</span></label>
                                <select name="branchId" class="form-select" required>
                                    <option value="">-- Chọn chi nhánh --</option>
                                    <c:forEach var="branch" items="${branches}">
                                        <option value="${branch.id}"><c:out value="${branch.name}"/> — <c:out value="${branch.address}"/></option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-semibold">Nội dung cần hỗ trợ <span class="text-danger">*</span></label>
                                <textarea name="content" class="form-control" rows="5" maxlength="1000" required
                                          placeholder="Nhập câu hỏi của bạn..."></textarea>
                                <div class="form-text">Tối đa 1.000 ký tự. Không gửi mật khẩu hoặc mã OTP.</div>
                            </div>
                            <div class="col-12 d-grid d-sm-flex justify-content-sm-end">
                                <button type="submit" class="btn btn-warning fw-bold px-4 rounded-pill">
                                    <i class="fa-solid fa-paper-plane me-2"></i>Gửi Cho Manager
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="card border-0 shadow rounded-4 overflow-hidden">
                <div class="card-header bg-dark text-white p-3 d-flex justify-content-between align-items-center gap-2">
                    <div>
                        <div class="fw-bold"><i class="fa-solid fa-shop me-2 text-warning"></i><c:out value="${conversation.branch.name}"/></div>
                        <small class="text-white-50">Khách: <c:out value="${conversation.customerName}"/> — <c:out value="${conversation.phone}"/></small>
                    </div>
                    <a href="/support-chat" class="btn btn-sm btn-outline-warning">Tạo hội thoại mới</a>
                </div>
                <div class="card-body bg-light" style="min-height: 360px; max-height: 520px; overflow-y: auto;" id="messageList">
                    <c:forEach var="message" items="${messages}">
                        <div class="d-flex mb-3 ${message.senderType == 'CUSTOMER' ? 'justify-content-end' : 'justify-content-start'}">
                            <div class="rounded-4 px-3 py-2 shadow-sm ${message.senderType == 'CUSTOMER' ? 'bg-warning text-dark' : 'bg-white border'}" style="max-width: 78%;">
                                <div class="small fw-bold mb-1"><c:out value="${message.senderName}"/></div>
                                <div style="white-space: pre-wrap; overflow-wrap: anywhere;"><c:out value="${message.content}"/></div>
                                <div class="small opacity-75 mt-1 text-end"><c:out value="${message.formattedCreatedAt}"/></div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                <div class="card-footer bg-white p-3">
                    <form action="/support-chat/${conversation.publicToken}/send" method="post" class="d-flex gap-2">
                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                        <textarea name="content" class="form-control" rows="2" maxlength="1000" required placeholder="Nhập tin nhắn tiếp theo..."></textarea>
                        <button type="submit" class="btn btn-warning px-4"><i class="fa-solid fa-paper-plane"></i></button>
                    </form>
                    <div class="form-text mt-2">Hãy lưu địa chỉ trang này để quay lại xem phản hồi của Manager.</div>
                </div>
            </div>
            <script>
                const messageList = document.getElementById('messageList');
                if (messageList) messageList.scrollTop = messageList.scrollHeight;
            </script>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="../common/footer.jsp"/>
