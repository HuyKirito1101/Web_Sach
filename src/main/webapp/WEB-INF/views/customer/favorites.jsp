<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Sách Yêu Thích - Sách Cũ Việt"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<div class="container py-4">
    <h3 class="fw-bold mb-4"><i class="fa-solid fa-heart text-danger me-2"></i>Danh Sách Sách Yêu Thích</h3>

    <c:choose>
        <c:when test="${empty favorites}">
            <div class="card border-0 shadow-sm text-center py-5 rounded-3">
                <i class="fa-regular fa-heart fs-1 text-secondary mb-3"></i>
                <h5>Bạn chưa thêm cuốn sách nào vào danh sách yêu thích!</h5>
                <div class="mt-2">
                    <a href="/books" class="btn btn-warning rounded-pill fw-bold px-4">Khám Phá Sách Ngay</a>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <div class="row row-cols-1 row-cols-sm-2 row-cols-md-4 g-4">
                <c:forEach var="f" items="${favorites}">
                    <div class="col">
                        <div class="card h-100 border-0 shadow-sm rounded-3 overflow-hidden">
                            <img src="${f.book.coverUrl != null ? f.book.coverUrl : 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'}" class="card-img-top" alt="${f.book.title}" style="height: 220px; object-fit: cover;">
                            <div class="card-body d-flex flex-column p-3">
                                <h6 class="card-title fw-bold text-dark text-truncate mb-1">${f.book.title}</h6>
                                <small class="text-muted mb-2">${f.book.author != null ? f.book.author.name : 'Nhiều tác giả'}</small>
                                <div class="mt-auto">
                                    <a href="/books/${f.book.id}" class="btn btn-warning btn-sm w-100 rounded-pill fw-bold text-dark">
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
