<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="title" value="Tin Nhắn Khách Hàng - Vendor" scope="request" />
<jsp:include page="../../common/header.jsp" />

<style>
    .no-arrow::after { display: none !important; }
    .msg-bubble:hover .btn-delete-msg { opacity: 1 !important; }
    .btn-delete-msg { opacity: 0.6; transition: opacity 0.2s; }
    .btn-delete-msg:hover { opacity: 1 !important; color: #ff6b6b !important; }
</style>

<div class="d-flex">
    <jsp:include page="../../common/sidebar.jsp" />
    <div class="flex-grow-1">
        <jsp:include page="../../common/navbar.jsp" />
        <div class="main-content container-fluid py-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="fw-bold mb-0">
                    <i class="fa-solid fa-comments text-primary me-2"></i>Tin Nhắn &amp; Hỏi Mua Sách
                </h3>
                <span class="badge bg-primary rounded-pill px-3 py-2 fs-6">
                    ${conversations.size()} Cuộc trò chuyện
                </span>
            </div>

            <c:if test="${not empty successMessage}"><div class="alert alert-success alert-dismissible fade show"><i class="fa-solid fa-check me-2"></i><c:out value="${successMessage}"/><button type="button" class="btn-close" data-bs-dismiss="alert"></button></div></c:if>
            <c:if test="${not empty errorMessage}"><div class="alert alert-danger alert-dismissible fade show"><i class="fa-solid fa-triangle-exclamation me-2"></i><c:out value="${errorMessage}"/><button type="button" class="btn-close" data-bs-dismiss="alert"></button></div></c:if>

            <div class="row g-3">
                <!-- Cột trái: Hộp thư khách hàng -->
                <div class="col-lg-4 col-md-5">
                    <div class="card border-0 shadow-sm rounded-4 overflow-hidden h-100">
                        <div class="card-header bg-white fw-bold py-3 border-bottom d-flex justify-content-between align-items-center">
                            <span><i class="fa-solid fa-inbox text-warning me-2"></i>Hộp thư khách hàng</span>
                            <c:if test="${vMessageBadge > 0}">
                                <span class="badge bg-danger rounded-pill">${vMessageBadge} Mới</span>
                            </c:if>
                        </div>
                        <div class="list-group list-group-flush" style="max-height: 680px; overflow-y: auto;">
                            <c:choose>
                                <c:when test="${empty conversations}">
                                    <div class="p-4 text-center text-muted">
                                        <i class="fa-regular fa-comment-dots fs-1 mb-2 d-block text-secondary"></i>
                                        Chưa có tin nhắn nào từ khách hàng.
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="conv" items="${conversations}">
                                        <div class="list-group-item list-group-item-action p-0 position-relative border-bottom ${selectedConversation != null && selectedConversation.id == conv.id ? 'active' : ''}">
                                            <a href="/vendor/messages?conversationId=${conv.id}"
                                               class="d-block p-3 text-decoration-none ${selectedConversation != null && selectedConversation.id == conv.id ? 'text-white' : 'text-dark'}">
                                                <div class="d-flex justify-content-between align-items-start mb-1 pe-4">
                                                    <div class="fw-bold fs-6 text-truncate" style="max-width: 210px;">
                                                        <c:choose>
                                                            <c:when test="${conv.customer.fullName.startsWith('Khách')}">
                                                                <c:out value="${conv.customer.fullName}"/>
                                                            </c:when>
                                                            <c:otherwise>
                                                                Khách Hàng <c:out value="${conv.customer.fullName}"/>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <c:if test="${conv.vendorUnread}">
                                                        <span class="badge bg-danger rounded-pill px-2 py-1 ms-1">Mới</span>
                                                    </c:if>
                                                </div>
                                                <div class="small mb-1 ${selectedConversation != null && selectedConversation.id == conv.id ? 'text-white' : 'text-secondary'}">
                                                    <i class="fa-solid fa-phone me-1"></i><c:out value="${not empty conv.customer.phone ? conv.customer.phone : '0955555555'}"/>
                                                </div>
                                                <div class="small ${selectedConversation != null && selectedConversation.id == conv.id ? 'text-white-50' : 'text-muted'} mb-1" style="font-size: 12px;">
                                                    <c:out value="${conv.formattedLastMessageAt}"/>
                                                </div>
                                                <c:if test="${conv.bookCopy != null && conv.bookCopy.book != null}">
                                                    <div class="small text-truncate ${selectedConversation != null && selectedConversation.id == conv.id ? 'text-light' : 'text-primary'} fw-medium mt-1">
                                                        <i class="fa-solid fa-book me-1"></i><c:out value="${conv.bookCopy.book.title}"/>
                                                    </div>
                                                </c:if>
                                                <c:if test="${not empty conv.lastMessage}">
                                                    <div class="small text-truncate ${selectedConversation != null && selectedConversation.id == conv.id ? 'text-white-50' : 'text-muted'} mt-1" style="font-size: 12px;">
                                                        <c:out value="${conv.lastMessage}"/>
                                                    </div>
                                                </c:if>
                                            </a>
                                            <!-- Nút 3 chấm trên mỗi item để xóa lịch sử nhắn -->
                                            <div class="dropdown position-absolute top-0 end-0 mt-2 me-2" style="z-index: 5;">
                                                <button class="btn btn-sm btn-link ${selectedConversation != null && selectedConversation.id == conv.id ? 'text-white' : 'text-muted'} p-1 text-decoration-none dropdown-toggle no-arrow"
                                                        type="button" data-bs-toggle="dropdown" aria-expanded="false" title="Tùy chọn hội thoại">
                                                    <i class="fa-solid fa-ellipsis-vertical fs-6"></i>
                                                </button>
                                                <ul class="dropdown-menu dropdown-menu-end shadow border-0 rounded-3">
                                                    <li>
                                                        <button type="button" class="dropdown-item text-danger py-2 d-flex align-items-center" onclick="confirmDeleteConversation(${conv.id})">
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

                <!-- Cột phải: Khung chat và thông tin sản phẩm cần mua -->
                <div class="col-lg-8 col-md-7">
                    <c:choose>
                        <c:when test="${empty selectedConversation}">
                            <div class="card border-0 shadow-sm rounded-4 text-center p-5 text-muted h-100 d-flex flex-column justify-content-center align-items-center">
                                <i class="fa-solid fa-comments fs-1 mb-3 text-primary"></i>
                                <h5>Chọn một khách hàng để xem tin nhắn và trao đổi</h5>
                                <p class="small text-muted mb-0">Khi khách hàng có nhu cầu mua hoặc trao đổi về sản phẩm sách cũ, tin nhắn sẽ xuất hiện ở danh sách bên trái.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="card border-0 shadow-sm rounded-4 overflow-hidden d-flex flex-column h-100">
                                <!-- Header thông tin khách (Hộp tên) -->
                                <div class="card-header bg-dark text-white p-3 d-flex justify-content-between align-items-center">
                                    <div class="d-flex align-items-center gap-3">
                                        <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center fw-bold fs-5 shadow-sm" style="width: 44px; height: 44px;">
                                            ${selectedConversation.customer.fullName.substring(0,1).toUpperCase()}
                                        </div>
                                        <div>
                                            <div class="d-flex align-items-center gap-2">
                                                <span class="fw-bold fs-6">
                                                    <c:choose>
                                                        <c:when test="${selectedConversation.customer.fullName.startsWith('Khách')}">
                                                            <c:out value="${selectedConversation.customer.fullName}"/>
                                                        </c:when>
                                                        <c:otherwise>
                                                            Khách Hàng <c:out value="${selectedConversation.customer.fullName}"/>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </span>
                                                <!-- Nút 3 chấm bên cạnh hộp tên để xóa lịch sử nhắn -->
                                                <div class="dropdown d-inline">
                                                    <button class="btn btn-sm btn-link text-white-50 p-0 text-decoration-none dropdown-toggle no-arrow"
                                                            type="button" id="headerDropdownMenu" data-bs-toggle="dropdown" aria-expanded="false" title="Tùy chọn hội thoại">
                                                        <i class="fa-solid fa-ellipsis-vertical fs-5 px-1"></i>
                                                    </button>
                                                    <ul class="dropdown-menu dropdown-menu-dark dropdown-menu-end shadow border-0 rounded-3 py-2" aria-labelledby="headerDropdownMenu">
                                                        <li>
                                                            <button type="button" class="dropdown-item text-danger py-2 d-flex align-items-center" onclick="confirmDeleteConversation(${selectedConversation.id})">
                                                                <i class="fa-solid fa-trash-can me-2"></i>Xóa lịch sử nhắn
                                                            </button>
                                                        </li>
                                                    </ul>
                                                </div>
                                            </div>
                                            <small class="text-white-50 d-block mt-1">
                                                <i class="fa-solid fa-phone me-1"></i><c:out value="${not empty selectedConversation.customer.phone ? selectedConversation.customer.phone : '0955555555'}"/>
                                                <c:if test="${not empty selectedConversation.customer.email}">
                                                    • <i class="fa-solid fa-envelope me-1"></i><c:out value="${selectedConversation.customer.email}"/>
                                                </c:if>
                                            </small>
                                        </div>
                                    </div>
                                    <c:if test="${currentBookCopy != null && currentBookCopy.book != null}">
                                        <a href="/books/${currentBookCopy.book.id}" target="_blank" class="btn btn-sm btn-outline-warning rounded-pill">
                                            <i class="fa-solid fa-eye me-1"></i>Xem trang sách
                                        </a>
                                    </c:if>
                                </div>

                                <!-- Thẻ sản phẩm sách cũ khách hàng đang hỏi mua (Product Card Preview) -->
                                <c:if test="${currentBookCopy != null && currentBookCopy.book != null}">
                                    <div class="bg-light border-bottom p-3 d-flex align-items-center justify-content-between gap-3">
                                        <div class="d-flex align-items-center gap-3 flex-grow-1 overflow-hidden">
                                            <img src="<c:out value='${currentBookCopy.book.coverUrl != null ? currentBookCopy.book.coverUrl : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=100"}'/>"
                                                 class="rounded-3 border shadow-sm" style="width: 52px; height: 68px; object-fit: cover;"
                                                 alt="<c:out value='${currentBookCopy.book.title}'/>">
                                            <div class="overflow-hidden">
                                                <div class="fw-bold text-dark text-truncate" title="<c:out value='${currentBookCopy.book.title}'/>">
                                                    <span class="badge bg-warning text-dark me-1"><i class="fa-solid fa-tag me-1"></i>Sách khách đang hỏi</span>
                                                    <c:out value="${currentBookCopy.book.title}"/>
                                                </div>
                                                <div class="small d-flex align-items-center gap-2 mt-1 flex-wrap">
                                                    <span class="text-danger fw-bold fs-6">
                                                        <fmt:formatNumber value="${currentBookCopy.sellingPrice}" pattern="#,##0"/> đ
                                                    </span>
                                                    <span class="badge bg-info text-dark">Tình trạng: ${currentBookCopy.conditionRating}</span>
                                                    <span class="badge bg-success">Kho: ${currentBookCopy.quantity} cuốn</span>
                                                    <c:if test="${not empty currentBookCopy.note}">
                                                        <span class="text-muted text-truncate" style="max-width: 200px;">
                                                            <i class="fa-regular fa-note-sticky me-1"></i><c:out value="${currentBookCopy.note}"/>
                                                        </span>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:if>

                                <!-- Quick replies for vendor -->
                                <div class="bg-white px-3 pt-2 pb-1 border-bottom d-flex gap-2 overflow-auto" style="white-space: nowrap;">
                                    <span class="small text-muted align-self-center me-1"><i class="fa-solid fa-bolt text-warning me-1"></i>Phản hồi nhanh:</span>
                                    <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill py-0 px-2 quick-chip" onclick="insertVendorTemplate('Dạ chào bạn, cuốn sách này shop vẫn còn hàng sẵn bạn nhé!')">
                                        Còn hàng sẵn
                                    </button>
                                    <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill py-0 px-2 quick-chip" onclick="insertVendorTemplate('Dạ tình trạng sách thực tế đúng như mô tả và chụp ảnh trên web ạ.')">
                                        Đúng mô tả
                                    </button>
                                    <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill py-0 px-2 quick-chip" onclick="insertVendorTemplate('Bạn đặt hàng ngay shop sẽ đóng gói và giao sớm nhất cho bạn nhé!')">
                                        Sẽ giao sớm
                                    </button>
                                    <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill py-0 px-2 quick-chip" onclick="insertVendorTemplate('Cảm ơn bạn đã quan tâm đến gian hàng Sách Cũ của Shop!')">
                                        Cảm ơn khách
                                    </button>
                                </div>

                                <!-- Message thread list -->
                                <div class="card-body bg-light p-3" style="min-height: 380px; max-height: 480px; overflow-y: auto;" id="vendorMessageList">
                                    <c:choose>
                                        <c:when test="${empty messages}">
                                            <div class="text-center py-5 text-muted">
                                                <i class="fa-regular fa-comment-dots fs-1 mb-2 d-block"></i>
                                                <p class="mb-0">Chưa có tin nhắn trong cuộc trò chuyện này.</p>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="msg" items="${messages}">
                                                <c:set var="isVendorSender" value="${msg.sender.id == selectedConversation.vendor.id}" />
                                                <div id="vmsg-${msg.id}" data-message-id="${msg.id}" class="d-flex mb-3 ${isVendorSender ? 'justify-content-end' : 'justify-content-start'}">
                                                    <div class="rounded-4 px-3 py-2 shadow-sm position-relative msg-bubble ${isVendorSender ? 'bg-primary text-white' : 'bg-white border text-dark'}" style="max-width: 78%;">
                                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                                            <div class="small fw-bold ${isVendorSender ? 'text-white-50' : 'text-primary'}">
                                                                <c:choose>
                                                                    <c:when test="${isVendorSender}">
                                                                        <i class="fa-solid fa-store me-1"></i>Shop (Bạn)
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <i class="fa-solid fa-user me-1"></i><c:out value="${not empty msg.sender.fullName ? msg.sender.fullName : selectedConversation.customer.fullName}"/>
                                                                        <span class="badge bg-info text-dark font-monospace ms-1" style="font-size: 10px;">Khách hàng</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                            <!-- Nút xóa tin nhắn nếu gửi nhầm -->
                                                            <c:if test="${isVendorSender}">
                                                                <button type="button" class="btn btn-link text-white-50 p-0 ms-2 text-decoration-none btn-delete-msg" 
                                                                        onclick="confirmDeleteMessage(${msg.id})" title="Xóa tin nhắn (thu hồi nếu nhắn nhầm)">
                                                                    <i class="fa-regular fa-trash-can" style="font-size: 11px;"></i>
                                                                </button>
                                                            </c:if>
                                                        </div>

                                                        <!-- Đính kèm sản phẩm sách khách đang hỏi nếu có -->
                                                        <c:if test="${msg.bookCopy != null && msg.bookCopy.book != null}">
                                                            <div class="card mb-2 border-0 shadow-sm text-dark overflow-hidden" style="background: rgba(255, 255, 255, 0.95); border-radius: 12px;">
                                                                <div class="p-2 d-flex align-items-center gap-2">
                                                                    <img src="<c:out value='${msg.bookCopy.book.coverUrl != null ? msg.bookCopy.book.coverUrl : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=100"}'/>"
                                                                         style="width: 48px; height: 64px; object-fit: cover; border-radius: 8px; flex-shrink: 0;"
                                                                         alt="<c:out value='${msg.bookCopy.book.title}'/>">
                                                                    <div class="overflow-hidden flex-grow-1" style="min-width: 0;">
                                                                        <span class="badge bg-warning text-dark mb-1" style="font-size: 10px;">
                                                                            <i class="fa-solid fa-tag me-1"></i>Sách khách đang hỏi
                                                                        </span>
                                                                        <a href="/books/${msg.bookCopy.book.id}" target="_blank" class="text-decoration-none text-dark fw-bold d-block text-truncate small" title="<c:out value='${msg.bookCopy.book.title}'/>">
                                                                            <c:out value="${msg.bookCopy.book.title}"/>
                                                                        </a>
                                                                        <div class="d-flex align-items-center gap-2 mt-1 flex-wrap">
                                                                            <span class="text-danger fw-bold small">
                                                                                <fmt:formatNumber value="${msg.bookCopy.sellingPrice}" pattern="#,##0"/> đ
                                                                            </span>
                                                                            <span class="badge bg-info text-dark" style="font-size: 10px;">${msg.bookCopy.conditionRating}</span>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </c:if>

                                                        <div style="white-space: pre-wrap; overflow-wrap: anywhere;"><c:out value="${msg.content}"/></div>
                                                        <div class="small opacity-75 mt-1 text-end" style="font-size: 11px;">
                                                            <c:out value="${msg.formattedCreatedAt}"/>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <!-- Input footer -->
                                <div class="card-footer bg-white p-3 border-top">
                                    <form id="vendorChatForm" action="/vendor/messages/${selectedConversation.id}/reply" method="post" onsubmit="handleVendorSend(event)" class="d-flex gap-2">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <input type="hidden" name="conversationId" value="${selectedConversation.id}">
                                        <textarea name="content" id="vendorMessageInput" class="form-control rounded-3" rows="2" maxlength="2000"
                                                  placeholder="Nhập câu trả lời hoặc tư vấn cho khách hàng..." required
                                                  onkeydown="handleVendorKeydown(event)"></textarea>
                                        <button type="submit" class="btn btn-primary fw-bold px-4 rounded-3 d-flex align-items-center justify-content-center">
                                             <i class="fa-solid fa-paper-plane me-1"></i>Gửi
                                        </button>
                                    </form>
                                    <div class="d-flex justify-content-between align-items-center mt-1">
                                        <small class="text-muted" style="font-size: 12px;">Nhấn Enter để gửi phản hồi, Shift + Enter để xuống dòng.</small>
                                        <small class="text-muted" id="vendorCharCounter" style="font-size: 12px;">0/2000</small>
                                    </div>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
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
    const currentVendorId = ${selectedConversation != null && selectedConversation.vendor != null ? selectedConversation.vendor.id : 'null'};
    const customerFullName = "<c:out value='${selectedConversation != null && selectedConversation.customer != null ? selectedConversation.customer.fullName : \"Khách hàng\"}'/>";
    const vendorContainer = document.getElementById('vendorMessageList');

    // Lưu các message ID đã hiển thị để loại bỏ hoàn toàn trùng lặp
    const renderedVendorMessageIds = new Set();
    if (vendorContainer) {
        vendorContainer.querySelectorAll('[data-message-id]').forEach(el => {
            const mid = Number(el.getAttribute('data-message-id'));
            if (mid) renderedVendorMessageIds.add(mid);
        });
    }

    function scrollToBottom() {
        if (vendorContainer) {
            vendorContainer.scrollTop = vendorContainer.scrollHeight;
        }
    }
    scrollToBottom();

    function insertVendorTemplate(text) {
        const input = document.getElementById('vendorMessageInput');
        if (input) {
            input.value = text;
            input.focus();
            updateVendorCounter();
        }
    }

    function handleVendorKeydown(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            document.getElementById('vendorChatForm').requestSubmit();
        }
    }

    function updateVendorCounter() {
        const input = document.getElementById('vendorMessageInput');
        const counter = document.getElementById('vendorCharCounter');
        if (input && counter) {
            counter.textContent = input.value.length + '/2000';
        }
    }
    const vendorInputArea = document.getElementById('vendorMessageInput');
    if (vendorInputArea) {
        vendorInputArea.addEventListener('input', updateVendorCounter);
    }

    function getCookie(name) {
        const value = `; ${document.cookie}`;
        const parts = value.split(`; ${name}=`);
        if (parts.length === 2) return parts.pop().split(';').shift();
        return '';
    }

    async function handleVendorSend(e) {
        if (e) e.preventDefault();
        const input = document.getElementById('vendorMessageInput');
        if (!input) return;
        const content = input.value.trim();
        if (!content || !conversationId) return;

        const form = document.getElementById('vendorChatForm');
        const csrfInput = form ? form.querySelector('input[name="${_csrf.parameterName}"]') : null;
        const csrfToken = (csrfInput && csrfInput.value) ? csrfInput.value : getCookie('XSRF-TOKEN');

        const formData = new URLSearchParams();
        if (csrfToken) {
            formData.append('${_csrf.parameterName}', csrfToken);
        }
        formData.append('conversationId', conversationId);
        formData.append('content', content);

        const submitBtn = form ? form.querySelector('button[type="submit"]') : null;
        if (submitBtn) submitBtn.disabled = true;

        try {
            const resp = await fetch('/vendor/messages/api/send', {
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
                updateVendorCounter();
                const newMsg = await resp.json();
                appendVendorMessage(newMsg);
            } else {
                if (form) form.submit();
            }
        } catch (err) {
            console.error('Lỗi gửi tin nhắn vendor qua fetch:', err);
            if (form) form.submit();
        } finally {
            if (submitBtn) submitBtn.disabled = false;
        }
    }

    function appendVendorMessage(m) {
        if (!vendorContainer || !m || !m.id) return;
        const msgId = Number(m.id);
        // Ngăn chặn trùng lặp tin nhắn
        if (renderedVendorMessageIds.has(msgId) || document.getElementById('vmsg-' + msgId)) {
            return;
        }
        renderedVendorMessageIds.add(msgId);

        // Xóa thông báo trống nếu có
        const emptyNotice = vendorContainer.querySelector('.text-center.py-5');
        if (emptyNotice) {
            emptyNotice.remove();
        }

        const isMe = (currentVendorId && m.senderId === currentVendorId) || m.isMe || (m.senderRole === 'ROLE_VENDOR');
        const div = document.createElement('div');
        div.id = 'vmsg-' + msgId;
        div.setAttribute('data-message-id', msgId);
        div.className = 'd-flex mb-3 ' + (isMe ? 'justify-content-end' : 'justify-content-start');

        const bubbleClass = isMe ? 'bg-primary text-white' : 'bg-white border text-dark';
        const senderClass = isMe ? 'text-white-50' : 'text-primary';
        const displayName = m.senderName || (!isMe ? customerFullName : 'Shop');
        const senderHeader = isMe
            ? '<i class="fa-solid fa-store me-1"></i>Shop (Bạn)'
            : '<i class="fa-solid fa-user me-1"></i>' + escapeHtml(displayName) + ' <span class="badge bg-info text-dark font-monospace ms-1" style="font-size: 10px;">Khách hàng</span>';

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
                                <i class="fa-solid fa-tag me-1"></i>Sách khách đang hỏi
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
        vendorContainer.appendChild(div);
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
            const form = document.getElementById('vendorChatForm');
            const csrfInput = form ? form.querySelector('input[name="${_csrf.parameterName}"]') : null;
            const csrfToken = (csrfInput && csrfInput.value) ? csrfInput.value : getCookie('XSRF-TOKEN');

            const res = await fetch('/vendor/messages/api/message/' + messageId + '/delete', {
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
        const el = document.getElementById('vmsg-' + messageId);
        if (el) {
            el.style.transition = 'all 0.3s ease';
            el.style.opacity = '0';
            el.style.transform = 'translateY(-10px)';
            setTimeout(() => {
                el.remove();
                renderedVendorMessageIds.delete(Number(messageId));
            }, 300);
        }
    }

    // Xác nhận xóa lịch sử cuộc trò chuyện
    function confirmDeleteConversation(convId) {
        const form = document.getElementById('deleteConversationForm');
        if (form) {
            form.action = '/vendor/messages/' + convId + '/delete';
        }
        const modal = new bootstrap.Modal(document.getElementById('deleteConversationModal'));
        modal.show();
    }

    // Auto-polling 3 giây
    if (conversationId) {
        setInterval(async () => {
            try {
                const res = await fetch('/vendor/messages/api/messages/' + conversationId);
                if (res.ok) {
                    const messages = await res.json();
                    messages.forEach(m => appendVendorMessage(m));
                }
            } catch (err) {}
        }, 3000);

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
                            window.location.href = '/vendor/messages';
                            return;
                        }
                        appendVendorMessage(data);
                    } catch (e) {}
                });
            }, function(err) {});
        } catch (e) {}
    }
</script>

<jsp:include page="../../common/footer.jsp" />
