<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="title" value="Tin Nhắn Khách Hàng - Manager" scope="request" />
<jsp:include page="../../common/header.jsp" />

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp" />
    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp" />
        <div class="main-content container-fluid">
            <h3 class="fw-bold mb-4"><i class="fa-solid fa-comments text-primary me-2"></i>Tin Nhắn Khách Hàng</h3>

            <c:if test="${not empty successMessage}"><div class="alert alert-success"><c:out value="${successMessage}"/></div></c:if>
            <c:if test="${not empty errorMessage}"><div class="alert alert-danger"><c:out value="${errorMessage}"/></div></c:if>

            <div class="row g-3">
                <div class="col-lg-4">
                    <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
                        <div class="card-header bg-white fw-bold py-3">Hộp thư chi nhánh</div>
                        <div class="list-group list-group-flush" style="max-height: 650px; overflow-y: auto;">
                            <c:choose>
                                <c:when test="${empty conversations}">
                                    <div class="p-4 text-center text-muted"><i class="fa-regular fa-comment-dots fs-2 mb-2 d-block"></i>Chưa có tin nhắn.</div>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="conversation" items="${conversations}">
                                        <a href="/manager/messages?conversationId=${conversation.id}"
                                           class="list-group-item list-group-item-action py-3 ${selectedConversation != null && selectedConversation.id == conversation.id ? 'active' : ''}">
                                            <div class="d-flex justify-content-between gap-2">
                                                <strong><c:out value="${conversation.customerName}"/></strong>
                                                <c:if test="${conversation.managerUnread}"><span class="badge bg-danger rounded-pill">Mới</span></c:if>
                                            </div>
                                            <div class="small"><i class="fa-solid fa-phone me-1"></i><c:out value="${conversation.phone}"/></div>
                                            <div class="small opacity-75 mt-1"><c:out value="${conversation.formattedLastMessageAt}"/></div>
                                        </a>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <div class="col-lg-8">
                    <c:choose>
                        <c:when test="${empty selectedConversation}">
                            <div class="card border-0 shadow-sm rounded-3 text-center p-5 text-muted">
                                <i class="fa-solid fa-comments fs-1 mb-3"></i>
                                <h5>Chọn một hội thoại để xem và trả lời</h5>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
                                <div class="card-header bg-dark text-white py-3 d-flex align-items-center justify-content-between gap-3">
                                    <div>
                                        <strong><c:out value="${selectedConversation.customerName}"/></strong>
                                        <span class="ms-2 text-white-50"><c:out value="${selectedConversation.phone}"/></span>
                                    </div>
                                    <form action="/manager/messages/${selectedConversation.id}/delete" method="post"
                                          onsubmit="return confirm('Xóa toàn bộ lịch sử hội thoại này? Khách hàng cũng sẽ không xem lại được tin nhắn.');">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <button class="btn btn-sm btn-outline-danger" type="submit" title="Xóa lịch sử hội thoại">
                                            <i class="fa-solid fa-trash-can me-1"></i>Xóa lịch sử chat
                                        </button>
                                    </form>
                                </div>
                                <div class="card-body bg-light" style="height: 460px; overflow-y: auto;" id="managerMessageList">
                                    <c:forEach var="message" items="${messages}">
                                        <div class="d-flex mb-3 ${message.senderType == 'MANAGER' ? 'justify-content-end' : 'justify-content-start'}">
                                            <div class="rounded-4 px-3 py-2 shadow-sm ${message.senderType == 'MANAGER' ? 'bg-primary text-white' : 'bg-white border'}" style="max-width: 80%;">
                                                <div class="small fw-bold mb-1"><c:out value="${message.senderName}"/></div>
                                                <div style="white-space: pre-wrap; overflow-wrap: anywhere;"><c:out value="${message.content}"/></div>
                                                <div class="small opacity-75 mt-1 text-end"><c:out value="${message.formattedCreatedAt}"/></div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                                <div class="card-footer bg-white p-3">
                                    <form action="/manager/messages/${selectedConversation.id}/reply" method="post" class="d-flex gap-2">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <textarea name="content" class="form-control" rows="2" maxlength="1000" required placeholder="Nhập phản hồi cho khách..."></textarea>
                                        <button class="btn btn-primary px-4" type="submit"><i class="fa-solid fa-paper-plane me-1"></i>Gửi</button>
                                    </form>
                                </div>
                            </div>
                            <script>
                                const managerMessageList = document.getElementById('managerMessageList');
                                if (managerMessageList) managerMessageList.scrollTop = managerMessageList.scrollHeight;
                            </script>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../../common/footer.jsp" />
