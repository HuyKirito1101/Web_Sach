<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Nhắn Tin Với Người Bán - Sách Cũ Việt"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<style>
    .no-arrow::after { display: none !important; }
    .msg-bubble:hover .btn-delete-msg { opacity: 1 !important; }
    .btn-delete-msg { opacity: 0.6; transition: opacity 0.2s; }
    .btn-delete-msg:hover { opacity: 1 !important; color: #ff6b6b !important; }
</style>

<div class="container py-4" style="max-width: 1200px;">
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

    <div class="row g-3">
        <!-- Cột trái: Danh sách các cuộc trò chuyện với các Shop -->
        <div class="col-lg-4 col-md-5">
            <div class="card border-0 shadow-sm rounded-4 overflow-hidden h-100">
                <div class="card-header bg-dark text-white p-3 d-flex justify-content-between align-items-center">
                    <span class="fw-bold fs-6"><i class="fa-solid fa-comments text-warning me-2"></i>Hội thoại với Shop</span>
                    <span class="badge bg-secondary rounded-pill">${conversations.size()}</span>
                </div>
                <div class="list-group list-group-flush" style="max-height: 650px; overflow-y: auto;">
                    <c:choose>
                        <c:when test="${empty conversations}">
                            <div class="p-4 text-center text-muted">
                                <i class="fa-regular fa-comment-dots fs-1 mb-2 d-block text-secondary"></i>
                                <p class="mb-1 fw-bold">Chưa có tin nhắn nào</p>
                                <small>Khi xem sách cũ, hãy nhấn <b>"Chat với Shop"</b> để hỏi đáp và trao đổi trực tiếp với người bán!</small>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="c" items="${conversations}">
                                <div class="list-group-item list-group-item-action p-0 position-relative border-bottom ${selectedConversation != null && selectedConversation.id == c.id ? 'active' : ''}">
                                    <a href="/chat/vendor?conversationId=${c.id}"
                                       class="d-block p-3 text-decoration-none ${selectedConversation != null && selectedConversation.id == c.id ? 'text-white' : 'text-dark'}">
                                        <div class="d-flex justify-content-between align-items-center mb-1 pe-4">
                                            <div class="fw-bold text-truncate" style="max-width: 200px;">
                                                <i class="fa-solid fa-store me-1 text-warning"></i><c:out value="${c.vendor.fullName}"/>
                                            </div>
                                            <c:if test="${c.customerUnread}">
                                                <span class="badge bg-danger rounded-pill px-2 py-1 ms-1">Tin mới</span>
                                            </c:if>
                                        </div>
                                        <c:if test="${c.bookCopy != null && c.bookCopy.book != null}">
                                            <div class="small text-truncate ${selectedConversation != null && selectedConversation.id == c.id ? 'text-light' : 'text-primary'} fw-medium mb-1">
                                                <i class="fa-solid fa-book me-1"></i><c:out value="${c.bookCopy.book.title}"/>
                                            </div>
                                        </c:if>
                                        <div class="small ${selectedConversation != null && selectedConversation.id == c.id ? 'text-white-50' : 'text-muted'} text-truncate">
                                            <c:out value="${not empty c.lastMessage ? c.lastMessage : 'Bắt đầu cuộc trò chuyện...'}"/>
                                        </div>
                                        <div class="small ${selectedConversation != null && selectedConversation.id == c.id ? 'text-white-50' : 'text-muted'} text-end mt-1" style="font-size: 11px;">
                                            <c:out value="${c.formattedLastMessageAt}"/>
                                        </div>
                                    </a>
                                    <!-- Nút 3 chấm trên mỗi item để xóa lịch sử nhắn -->
                                    <div class="dropdown position-absolute top-0 end-0 mt-2 me-2" style="z-index: 5;">
                                        <button class="btn btn-sm btn-link ${selectedConversation != null && selectedConversation.id == c.id ? 'text-white' : 'text-muted'} p-1 text-decoration-none dropdown-toggle no-arrow"
                                                type="button" data-bs-toggle="dropdown" aria-expanded="false" title="Tùy chọn hội thoại">
                                            <i class="fa-solid fa-ellipsis-vertical fs-6"></i>
                                        </button>
                                        <ul class="dropdown-menu dropdown-menu-end shadow border-0 rounded-3">
                                            <li>
                                                <button type="button" class="dropdown-item text-danger py-2 d-flex align-items-center" onclick="confirmDeleteConversation(${c.id})">
                                                    <i class="fa-solid fa-trash-can me-2"></i>Xóa lịch sử nhắn
                                                </button>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <!-- Cột phải: Khung chat chi tiết -->
        <div class="col-lg-8 col-md-7">
            <c:choose>
                <c:when test="${empty selectedConversation}">
                    <div class="card border-0 shadow-sm rounded-4 text-center p-5 text-muted h-100 d-flex flex-column justify-content-center align-items-center">
                        <i class="fa-solid fa-comments fs-1 mb-3 text-warning"></i>
                        <h5>Chọn một cửa hàng để bắt đầu trao đổi</h5>
                        <p class="small text-muted mb-4">Bạn có thể nhắn tin hỏi về tình trạng sách cũ, ảnh chụp thực tế, hoặc trao đổi thêm về giá với người bán.</p>
                        <a href="/books" class="btn btn-warning rounded-pill px-4 fw-bold">
                            <i class="fa-solid fa-book me-1"></i>Khám Phá Sách Cũ
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="card border-0 shadow-sm rounded-4 overflow-hidden d-flex flex-column h-100">
                        <!-- Header chat -->
                        <div class="card-header bg-dark text-white p-3 d-flex justify-content-between align-items-center">
                            <div class="d-flex align-items-center gap-3">
                                <div class="bg-warning text-dark rounded-circle d-flex align-items-center justify-content-center fw-bold" style="width: 44px; height: 44px;">
                                    <i class="fa-solid fa-store fs-5"></i>
                                </div>
                                <div>
                                    <div class="d-flex align-items-center gap-2">
                                        <span class="fw-bold fs-6"><c:out value="${selectedConversation.vendor.fullName}"/></span>
                                        <!-- Nút 3 chấm bên cạnh tên Shop để xóa lịch sử nhắn -->
                                        <div class="dropdown d-inline">
                                            <button class="btn btn-sm btn-link text-white-50 p-0 text-decoration-none dropdown-toggle no-arrow"
                                                    type="button" id="customerHeaderDropdown" data-bs-toggle="dropdown" aria-expanded="false" title="Tùy chọn hội thoại">
                                                <i class="fa-solid fa-ellipsis-vertical fs-5 px-1"></i>
                                            </button>
                                            <ul class="dropdown-menu dropdown-menu-dark dropdown-menu-end shadow border-0 rounded-3 py-2" aria-labelledby="customerHeaderDropdown">
                                                <li>
                                                    <button type="button" class="dropdown-item text-danger py-2 d-flex align-items-center" onclick="confirmDeleteConversation(${selectedConversation.id})">
                                                        <i class="fa-solid fa-trash-can me-2"></i>Xóa lịch sử nhắn
                                                    </button>
                                                </li>
                                            </ul>
                                        </div>
                                    </div>
                                    <small class="text-white-50 d-block mt-1">
                                        <i class="fa-solid fa-shield-halved text-success me-1"></i>Người bán uy tín Sách Cũ Việt
                                    </small>
                                </div>
                            </div>
                            <c:if test="${currentBookCopy != null && currentBookCopy.book != null}">
                                <a href="/books/${currentBookCopy.book.id}" class="btn btn-sm btn-outline-warning rounded-pill">
                                    <i class="fa-solid fa-arrow-up-right-from-square me-1"></i>Xem trang sách
                                </a>
                            </c:if>
                        </div>

                        <!-- Thẻ thông tin sản phẩm sách đang trao đổi (Pinned Product Card) -->
                        <c:if test="${currentBookCopy != null && currentBookCopy.book != null}">
                            <div class="bg-light border-bottom p-3 d-flex align-items-center justify-content-between gap-3">
                                <div class="d-flex align-items-center gap-3 flex-grow-1 overflow-hidden">
                                    <img src="<c:out value='${currentBookCopy.book.coverUrl != null ? currentBookCopy.book.coverUrl : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=100"}'/>"
                                         class="rounded-3 border shadow-sm" style="width: 52px; height: 68px; object-fit: cover;"
                                         alt="<c:out value='${currentBookCopy.book.title}'/>">
                                    <div class="overflow-hidden">
                                        <div class="fw-bold text-dark text-truncate" title="<c:out value='${currentBookCopy.book.title}'/>">
                                            <c:out value="${currentBookCopy.book.title}"/>
                                        </div>
                                        <div class="small d-flex align-items-center gap-2 mt-1 flex-wrap">
                                            <span class="text-danger fw-bold fs-6">
                                                <fmt:formatNumber value="${currentBookCopy.sellingPrice}" pattern="#,##0"/> đ
                                            </span>
                                            <span class="badge bg-info text-dark">${currentBookCopy.conditionRating}</span>
                                            <span class="badge bg-secondary font-monospace"><c:out value="${currentBookCopy.branch.name}"/></span>
                                        </div>
                                    </div>
                                </div>
                                <div class="d-flex gap-2 flex-shrink-0">
                                    <form action="/cart/add" method="POST" class="d-inline">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <input type="hidden" name="bookCopyId" value="${currentBookCopy.id}"/>
                                        <input type="hidden" name="quantity" value="1"/>
                                        <button type="submit" class="btn btn-warning btn-sm rounded-pill fw-bold px-3">
                                            <i class="fa-solid fa-cart-plus me-1"></i>Thêm Giỏ
                                        </button>
                                    </form>
                                    <form action="/cart/add" method="POST" class="d-inline">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <input type="hidden" name="bookCopyId" value="${currentBookCopy.id}"/>
                                        <input type="hidden" name="quantity" value="1"/>
                                        <input type="hidden" name="buyNow" value="true"/>
                                        <button type="submit" class="btn btn-danger btn-sm rounded-pill fw-bold px-3">
                                            <i class="fa-solid fa-bolt me-1"></i>Mua Ngay
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </c:if>

                        <!-- Quick inquiry chips -->
                        <div class="bg-white px-3 pt-2 pb-1 border-bottom d-flex gap-2 overflow-auto" style="white-space: nowrap;">
                            <span class="small text-muted align-self-center me-1"><i class="fa-regular fa-lightbulb text-warning me-1"></i>Gợi ý:</span>
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill py-0 px-2 quick-chip" onclick="insertTemplate('Sách này còn hàng không shop?')">
                                Còn hàng không?
                            </button>
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill py-0 px-2 quick-chip" onclick="insertTemplate('Tình trạng sách thực tế thế nào ạ?')">
                                Tình trạng sách?
                            </button>
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill py-0 px-2 quick-chip" onclick="insertTemplate('Shop có thể gửi thêm ảnh thật sản phẩm được không?')">
                                Xin thêm ảnh thật
                            </button>
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill py-0 px-2 quick-chip" onclick="insertTemplate('Cuốn này có thể bớt giá một chút không shop?')">
                                Bớt giá được không?
                            </button>
                        </div>

                        <!-- Khung nội dung tin nhắn -->
                        <div class="card-body bg-light p-3" style="min-height: 380px; max-height: 480px; overflow-y: auto;" id="customerMessageList">
                            <c:choose>
                                <c:when test="${empty messages}">
                                    <div class="text-center py-5 text-muted">
                                        <i class="fa-regular fa-comment-dots fs-1 mb-2 d-block"></i>
                                        <p class="mb-0">Hãy gửi tin nhắn đầu tiên để bắt đầu trao đổi với shop về cuốn sách này!</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="m" items="${messages}">
                                        <c:set var="isCustomer" value="${m.sender.id == selectedConversation.customer.id}" />
                                        <div id="msg-${m.id}" data-message-id="${m.id}" class="d-flex mb-3 ${isCustomer ? 'justify-content-end' : 'justify-content-start'}">
                                            <div class="rounded-4 px-3 py-2 shadow-sm position-relative msg-bubble ${isCustomer ? 'bg-primary text-white' : 'bg-white border text-dark'}" style="max-width: 78%;">
                                                <div class="d-flex justify-content-between align-items-center mb-1">
                                                    <div class="small fw-bold ${isCustomer ? 'text-white-50' : 'text-primary'}">
                                                        <c:choose>
                                                            <c:when test="${isCustomer}">
                                                                <i class="fa-solid fa-user me-1"></i><c:out value="${m.sender.fullName}"/> <span class="badge bg-light text-dark ms-1" style="font-size: 10px;">Bạn</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <i class="fa-solid fa-store me-1"></i><c:out value="${m.sender.fullName}"/> <span class="badge bg-warning text-dark ms-1" style="font-size: 10px;">Shop</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <!-- Nút xóa tin nhắn nếu là người gửi gửi nhầm -->
                                                    <c:if test="${isCustomer}">
                                                        <button type="button" class="btn btn-link text-white-50 p-0 ms-2 text-decoration-none btn-delete-msg" 
                                                                onclick="confirmDeleteMessage(${m.id})" title="Xóa tin nhắn (thu hồi nếu nhắn nhầm)">
                                                            <i class="fa-regular fa-trash-can" style="font-size: 11px;"></i>
                                                        </button>
                                                    </c:if>
                                                </div>

                                                <c:if test="${m.bookCopy != null && m.bookCopy.book != null}">
                                                    <div class="card mb-2 border-0 shadow-sm text-dark overflow-hidden" style="background: rgba(255, 255, 255, 0.95); border-radius: 12px;">
                                                        <div class="p-2 d-flex align-items-center gap-2">
                                                            <img src="<c:out value='${m.bookCopy.book.coverUrl != null ? m.bookCopy.book.coverUrl : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=100"}'/>"
                                                                 style="width: 48px; height: 64px; object-fit: cover; border-radius: 8px; flex-shrink: 0;"
                                                                 alt="<c:out value='${m.bookCopy.book.title}'/>">
                                                            <div class="overflow-hidden flex-grow-1" style="min-width: 0;">
                                                                <span class="badge bg-warning text-dark mb-1" style="font-size: 10px;">
                                                                    <i class="fa-solid fa-tag me-1"></i>Sản phẩm đang hỏi
                                                                </span>
                                                                <a href="/books/${m.bookCopy.book.id}" target="_blank" class="text-decoration-none text-dark fw-bold d-block text-truncate small" title="<c:out value='${m.bookCopy.book.title}'/>">
                                                                    <c:out value="${m.bookCopy.book.title}"/>
                                                                </a>
                                                                <div class="d-flex align-items-center gap-2 mt-1 flex-wrap">
                                                                    <span class="text-danger fw-bold small">
                                                                        <fmt:formatNumber value="${m.bookCopy.sellingPrice}" pattern="#,##0"/> đ
                                                                    </span>
                                                                    <span class="badge bg-info text-dark" style="font-size: 10px;">${m.bookCopy.conditionRating}</span>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:if>

                                                <div style="white-space: pre-wrap; overflow-wrap: anywhere;"><c:out value="${m.content}"/></div>
                                                <div class="small opacity-75 mt-1 text-end" style="font-size: 11px;">
                                                    <c:out value="${m.formattedCreatedAt}"/>
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- Chat input footer -->
                        <div class="card-footer bg-white p-3 border-top">
                            <form id="chatForm" action="/chat/vendor/send" method="post" onsubmit="handleSendMessage(event)" class="d-flex gap-2">
                                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                <input type="hidden" name="conversationId" value="${selectedConversation.id}" id="conversationIdInput">
                                <c:if test="${currentBookCopy != null}">
                                    <input type="hidden" name="bookCopyId" value="${currentBookCopy.id}">
                                </c:if>
                                <textarea name="content" id="messageContentInput" class="form-control rounded-3" rows="2" maxlength="2000"
                                          placeholder="Nhập tin nhắn trao đổi với Shop (tối đa 2.000 ký tự)..." required
                                          onkeydown="handleTextareaKeydown(event)"></textarea>
                                <button type="submit" class="btn btn-warning fw-bold px-4 rounded-3 d-flex align-items-center justify-content-center">
                                    <i class="fa-solid fa-paper-plane me-1"></i>Gửi
                                </button>
                            </form>
                            <div class="d-flex justify-content-between align-items-center mt-1">
                                <small class="text-muted" style="font-size: 12px;">Nhấn Enter để gửi, Shift + Enter để xuống dòng.</small>
                                <small class="text-muted" id="charCounter" style="font-size: 12px;">0/2000</small>
                            </div>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- Modal xác nhận xóa lịch sử cuộc trò chuyện -->
<div class="modal fade" id="deleteConversationModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold text-danger">
                    <i class="fa-solid fa-triangle-exclamation me-2"></i>Xóa Lịch Sử Cuộc Trò Chuyện
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body py-3">
                <p class="mb-0">Bạn có chắc chắn muốn xóa toàn bộ lịch sử tin nhắn của cuộc trò chuyện này không? Toàn bộ tin nhắn sẽ bị xóa vĩnh viễn và không thể khôi phục.</p>
            </div>
            <div class="modal-footer border-0 pt-0">
                <button type="button" class="btn btn-secondary rounded-pill px-3" data-bs-dismiss="modal">Hủy</button>
                <form id="deleteConversationForm" method="POST" action="">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                    <button type="submit" class="btn btn-danger rounded-pill px-3 fw-bold">
                        <i class="fa-solid fa-trash-can me-1"></i>Xóa lịch sử
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
<script>
    const conversationId = "${selectedConversation != null ? selectedConversation.id : ''}";
    const currentCustomerId = ${selectedConversation != null && selectedConversation.customer != null ? selectedConversation.customer.id : 'null'};
    const customerFullName = "<c:out value='${selectedConversation != null && selectedConversation.customer != null ? selectedConversation.customer.fullName : \"Bạn\"}'/>";
    const messageContainer = document.getElementById('customerMessageList');

    // Lưu các message ID đã hiển thị để loại bỏ hoàn toàn trùng lặp
    const renderedMessageIds = new Set();
    if (messageContainer) {
        messageContainer.querySelectorAll('[data-message-id]').forEach(el => {
            const mid = Number(el.getAttribute('data-message-id'));
            if (mid) renderedMessageIds.add(mid);
        });
    }

    function scrollToBottom() {
        if (messageContainer) {
            messageContainer.scrollTop = messageContainer.scrollHeight;
        }
    }
    scrollToBottom();

    function insertTemplate(text) {
        const input = document.getElementById('messageContentInput');
        if (input) {
            input.value = text;
            input.focus();
            updateCounter();
        }
    }

    function handleTextareaKeydown(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            document.getElementById('chatForm').requestSubmit();
        }
    }

    function updateCounter() {
        const input = document.getElementById('messageContentInput');
        const counter = document.getElementById('charCounter');
        if (input && counter) {
            counter.textContent = input.value.length + '/2000';
        }
    }
    const inputArea = document.getElementById('messageContentInput');
    if (inputArea) {
        inputArea.addEventListener('input', updateCounter);
    }

    function getCookie(name) {
        const value = `; ${document.cookie}`;
        const parts = value.split(`; ${name}=`);
        if (parts.length === 2) return parts.pop().split(';').shift();
        return '';
    }

    // Gửi tin nhắn mượt mà qua AJAX
    async function handleSendMessage(e) {
        if (e) e.preventDefault();
        const input = document.getElementById('messageContentInput');
        if (!input) return;
        const content = input.value.trim();
        if (!content || !conversationId) return;

        const form = document.getElementById('chatForm');
        const csrfInput = form ? form.querySelector('input[name="${_csrf.parameterName}"]') : null;
        const csrfToken = (csrfInput && csrfInput.value) ? csrfInput.value : getCookie('XSRF-TOKEN');
        const bookCopyInput = form ? form.querySelector('input[name="bookCopyId"]') : null;
        const bookCopyId = (bookCopyInput && bookCopyInput.value) ? bookCopyInput.value.trim() : '';

        const formData = new URLSearchParams();
        if (csrfToken) {
            formData.append('${_csrf.parameterName}', csrfToken);
        }
        formData.append('conversationId', conversationId);
        formData.append('content', content);
        if (bookCopyId) {
            formData.append('bookCopyId', bookCopyId);
        }

        const submitBtn = form ? form.querySelector('button[type="submit"]') : null;
        if (submitBtn) submitBtn.disabled = true;

        try {
            const resp = await fetch('/chat/vendor/api/send', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    '${_csrf.headerName}': csrfToken,
                    'X-XSRF-TOKEN': csrfToken,
                    'X-CSRF-TOKEN': csrfToken
                },
                body: formData.toString()
            });

            if (resp.ok) {
                input.value = '';
                updateCounter();
                // Tin nhắn đầu về sản phẩm này đã được gửi kèm, xóa bookCopyId để các tin tiếp theo không đính kèm lặp lại
                if (bookCopyInput) {
                    bookCopyInput.value = '';
                }
                const newMsg = await resp.json();
                appendMessage(newMsg);
            } else {
                if (form) form.submit();
            }
        } catch (err) {
            console.error('Lỗi gửi tin nhắn qua fetch:', err);
            if (form) form.submit();
        } finally {
            if (submitBtn) submitBtn.disabled = false;
        }
    }

    function appendMessage(m) {
        if (!messageContainer || !m || !m.id) return;
        const msgId = Number(m.id);
        // Ngăn chặn triệt để tin nhắn bị trùng lặp hiển thị
        if (renderedMessageIds.has(msgId) || document.getElementById('msg-' + msgId)) {
            return;
        }
        renderedMessageIds.add(msgId);

        // Xóa thông báo trống nếu có
        const emptyNotice = messageContainer.querySelector('.text-center.py-5');
        if (emptyNotice) {
            emptyNotice.remove();
        }

        const isMe = (currentCustomerId && m.senderId === currentCustomerId) || m.isMe || (m.senderRole !== 'ROLE_VENDOR');
        const div = document.createElement('div');
        div.id = 'msg-' + msgId;
        div.setAttribute('data-message-id', msgId);
        div.className = 'd-flex mb-3 ' + (isMe ? 'justify-content-end' : 'justify-content-start');

        const bubbleClass = isMe ? 'bg-primary text-white' : 'bg-white border text-dark';
        const senderClass = isMe ? 'text-white-50' : 'text-primary';
        const displayName = m.senderName || (isMe ? customerFullName : 'Shop');
        const senderHeader = isMe
            ? '<i class="fa-solid fa-user me-1"></i>' + escapeHtml(displayName) + ' <span class="badge bg-light text-dark ms-1" style="font-size: 10px;">Bạn</span>'
            : '<i class="fa-solid fa-store me-1"></i>' + escapeHtml(displayName) + ' <span class="badge bg-warning text-dark ms-1" style="font-size: 10px;">Shop</span>';

        const deleteBtn = isMe
            ? `<button type="button" class="btn btn-link text-white-50 p-0 ms-2 text-decoration-none btn-delete-msg" onclick="confirmDeleteMessage(` + msgId + `)" title="Xóa tin nhắn (thu hồi nếu nhắn nhầm)"><i class="fa-regular fa-trash-can" style="font-size: 11px;"></i></button>`
            : '';

        let productCardHtml = '';
        if (m.bookCopyId && m.bookTitle) {
            const coverUrl = m.bookCoverUrl || 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=100';
            const priceFormatted = (m.bookPrice != null) ? Number(m.bookPrice).toLocaleString('vi-VN') + ' đ' : '';
            const bookLink = m.bookId ? ('/books/' + m.bookId) : '#';
            const conditionBadge = m.conditionRating ? '<span class="badge bg-info text-dark" style="font-size: 10px;">' + escapeHtml(m.conditionRating) + '</span>' : '';
            productCardHtml = `
                <div class="card mb-2 border-0 shadow-sm text-dark overflow-hidden" style="background: rgba(255, 255, 255, 0.95); border-radius: 12px;">
                    <div class="p-2 d-flex align-items-center gap-2">
                        <img src="` + escapeHtml(coverUrl) + `"
                             style="width: 48px; height: 64px; object-fit: cover; border-radius: 8px; flex-shrink: 0;"
                             alt="` + escapeHtml(m.bookTitle) + `">
                        <div class="overflow-hidden flex-grow-1" style="min-width: 0;">
                            <span class="badge bg-warning text-dark mb-1" style="font-size: 10px;">
                                <i class="fa-solid fa-tag me-1"></i>Sản phẩm đang hỏi
                            </span>
                            <a href="` + bookLink + `" target="_blank" class="text-decoration-none text-dark fw-bold d-block text-truncate small" title="` + escapeHtml(m.bookTitle) + `">
                                ` + escapeHtml(m.bookTitle) + `
                            </a>
                            <div class="d-flex align-items-center gap-2 mt-1 flex-wrap">
                                <span class="text-danger fw-bold small">` + priceFormatted + `</span>
                                ` + conditionBadge + `
                            </div>
                        </div>
                    </div>
                </div>
            `;
        }

        div.innerHTML = `
            <div class="rounded-4 px-3 py-2 shadow-sm position-relative msg-bubble ` + bubbleClass + `" style="max-width: 78%;">
                <div class="d-flex justify-content-between align-items-center mb-1">
                    <div class="small fw-bold ` + senderClass + `">
                        ` + senderHeader + `
                    </div>
                    ` + deleteBtn + `
                </div>
                ` + productCardHtml + `
                <div style="white-space: pre-wrap; overflow-wrap: anywhere;">` + escapeHtml(m.content) + `</div>
                <div class="small opacity-75 mt-1 text-end" style="font-size: 11px;">
                    ` + escapeHtml(m.formattedCreatedAt) + `
                </div>
            </div>
        `;
        messageContainer.appendChild(div);
        scrollToBottom();
    }

    function escapeHtml(text) {
        if (!text) return '';
        const d = document.createElement('div');
        d.textContent = text;
        return d.innerHTML;
    }

    // Xóa tin nhắn đơn lẻ khi người gửi nhắn nhầm
    async function confirmDeleteMessage(messageId) {
        if (!confirm('Bạn có chắc chắn muốn xóa tin nhắn này không?')) return;
        try {
            const form = document.getElementById('chatForm');
            const csrfInput = form ? form.querySelector('input[name="${_csrf.parameterName}"]') : null;
            const csrfToken = (csrfInput && csrfInput.value) ? csrfInput.value : getCookie('XSRF-TOKEN');

            const res = await fetch('/chat/vendor/api/message/' + messageId + '/delete', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    '${_csrf.headerName}': csrfToken,
                    'X-XSRF-TOKEN': csrfToken,
                    'X-CSRF-TOKEN': csrfToken
                }
            });

            if (res.ok) {
                removeMessageElement(messageId);
            } else {
                const err = await res.json().catch(() => ({}));
                alert(err.error || 'Không thể xóa tin nhắn.');
            }
        } catch (e) {
            console.error('Lỗi khi xóa tin nhắn:', e);
        }
    }

    function removeMessageElement(messageId) {
        const el = document.getElementById('msg-' + messageId);
        if (el) {
            el.style.transition = 'all 0.3s ease';
            el.style.opacity = '0';
            el.style.transform = 'translateY(-10px)';
            setTimeout(() => {
                el.remove();
                renderedMessageIds.delete(Number(messageId));
            }, 300);
        }
    }

    // Xác nhận xóa lịch sử cuộc trò chuyện
    function confirmDeleteConversation(convId) {
        const form = document.getElementById('deleteConversationForm');
        if (form) {
            form.action = '/chat/vendor/' + convId + '/delete';
        }
        const modal = new bootstrap.Modal(document.getElementById('deleteConversationModal'));
        modal.show();
    }

    // Auto-polling 3 giây lấy tin nhắn mới
    if (conversationId) {
        setInterval(async () => {
            try {
                const res = await fetch('/chat/vendor/api/messages/' + conversationId);
                if (res.ok) {
                    const messages = await res.json();
                    messages.forEach(m => appendMessage(m));
                }
            } catch (err) {}
        }, 3000);

        // Kết nối WebSocket STOMP
        try {
            const socket = new SockJS('/ws');
            const stompClient = Stomp.over(socket);
            stompClient.debug = null;
            stompClient.connect({}, function() {
                stompClient.subscribe('/topic/vendor-chat/' + conversationId, function(messageOutput) {
                    try {
                        const data = JSON.parse(messageOutput.body);
                        if (data.action === 'DELETE_MESSAGE') {
                            removeMessageElement(data.messageId);
                            return;
                        } else if (data.action === 'DELETE_CONVERSATION') {
                            window.location.href = '/chat/vendor';
                            return;
                        }
                        appendMessage(data);
                    } catch (e) {}
                });
            }, function(err) {});
        } catch (e) {}
    }
</script>

<jsp:include page="../common/footer.jsp"/>
