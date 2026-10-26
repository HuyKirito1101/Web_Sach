<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Sách Đã Xem - Sách Cũ Việt"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<div class="container py-4">
    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
        <h3 class="fw-bold mb-0"><i class="fa-solid fa-clock-rotate-left text-info me-2"></i>Lịch Sử Sách Đã Xem</h3>
        <c:if test="${not empty viewedProducts}">
            <form action="/viewed-products/clear" method="post"
                  onsubmit="return confirm('Bạn có chắc muốn xóa toàn bộ lịch sử xem sách?')">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                <button type="submit" class="btn btn-outline-danger rounded-pill px-3">
                    <i class="fa-solid fa-trash-can me-1"></i>Xóa Lịch Sử
                </button>
            </form>
        </c:if>
    </div>

    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i><c:out value="${successMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${not empty infoMessage}">
        <div class="alert alert-info alert-dismissible fade show" role="alert">
            <i class="fa-solid fa-circle-info me-2"></i><c:out value="${infoMessage}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <c:choose>
        <c:when test="${empty viewedProducts}">
            <div class="card border-0 shadow-sm text-center py-5 rounded-3">
                <i class="fa-solid fa-history fs-1 text-secondary mb-3"></i>
                <h5>Bạn chưa xem cuốn sách nào!</h5>
                <div class="mt-2">
                    <a href="/books" class="btn btn-warning rounded-pill fw-bold px-4">Khám Phá Sách Ngay</a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="row row-cols-1 row-cols-sm-2 row-cols-md-4 g-4">
                <c:forEach var="vp" items="${viewedProducts}">
                    <div class="col">
                        <div class="card h-100 border-0 shadow-sm rounded-3 overflow-hidden">
                            <img src="<c:out value='${vp.book.coverUrl != null ? vp.book.coverUrl : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400"}'/>" class="card-img-top" alt="<c:out value='${vp.book.title}'/>" style="height: 220px; object-fit: cover;">
                            <div class="card-body d-flex flex-column p-3">
                                <h6 class="card-title fw-bold text-dark text-truncate mb-1"><c:out value="${vp.book.title}"/></h6>
                                <small class="text-muted mb-2"><c:out value="${vp.book.author != null ? vp.book.author.name : 'Nhiều tác giả'}"/></small>
                                <div class="mt-auto">
                                    <a href="/books/${vp.book.id}" class="btn btn-warning btn-sm w-100 rounded-pill fw-bold text-dark">
                                        <i class="fa-solid fa-eye me-1"></i>Xem Chi Tiết
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="../common/footer.jsp"/>
