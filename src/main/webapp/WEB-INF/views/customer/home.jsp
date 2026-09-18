<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Sách Cũ Việt - Chuỗi Cửa Hàng Sách Cũ Trực Tuyến"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<!-- Hero Banner -->
<div class="bg-dark text-white py-5 mb-5 shadow-sm" style="background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);">
    <div class="container text-center py-4">
        <h1 class="display-4 fw-bold text-warning mb-3">Tìm Kiếm Sách Cũ Quý Hiếm & Giá Rẻ</h1>
        <p class="lead mb-4 text-light">Hàng ngàn đầu sách cũ, sách trước 1975, truyện tranh, giáo trình từ các chi nhánh cửa hàng trên toàn quốc.</p>
        <a href="/books" class="btn btn-warning btn-lg rounded-pill px-5 fw-bold text-dark shadow-sm">
            <i class="fa-solid fa-compass me-2"></i>Khám Phá Ngay
        </a>
    </div>
</div>

<div class="container mb-5">

    <!-- Categories section -->
    <div class="mb-5">
        <h3 class="fw-bold text-dark border-start border-4 border-warning ps-3 mb-4">Danh Mục Sách Cũ</h3>
        <div class="row g-3">
            <c:forEach var="cat" items="${categories}">
                <div class="col-6 col-md-4 col-lg-3">
                    <a href="/books?categoryId=${cat.id}" class="card h-100 border-0 shadow-sm text-decoration-none hover-shadow transition">
                        <div class="card-body text-center p-4">
                            <i class="fa-solid fa-bookmark text-warning mb-2 fs-2"></i>
                            <h6 class="fw-bold text-dark mb-0">${cat.name}</h6>
                        </div>
                    </a>
                </div>
            </c:forEach>
        </div>
    </div>

    <!-- Top 20 New Books -->
    <div class="mb-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="fw-bold text-dark border-start border-4 border-warning ps-3 mb-0">Top Sách Cũ Mới Cập Nhật</h3>
            <a href="/books" class="btn btn-outline-warning text-dark btn-sm rounded-pill fw-bold">Xem tất cả <i class="fa-solid fa-arrow-right ms-1"></i></a>
        </div>
        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-4 row-cols-lg-5 g-4">
            <c:forEach var="b" items="${newBooks}">
                <div class="col">
                    <div class="card h-100 border-0 shadow-sm rounded-3 overflow-hidden">
                        <img src="${b.coverUrl != null ? b.coverUrl : 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'}" class="card-img-top" alt="${b.title}" style="height: 220px; object-fit: cover;">
                        <div class="card-body d-flex flex-column p-3">
                            <span class="badge bg-secondary mb-2 align-self-start">${b.category != null ? b.category.name : 'Sách Cũ'}</span>
                            <h6 class="card-title fw-bold text-dark text-truncate mb-1" title="${b.title}">
                                <a href="/books/${b.id}" class="text-decoration-none text-dark">${b.title}</a>
                            </h6>
                            <small class="text-muted mb-2"><i class="fa-solid fa-feather me-1"></i>${b.author != null ? b.author.name : 'Nhiều tác giả'}</small>
                            <div class="mt-auto d-flex justify-content-between align-items-center">
                                <a href="/books/${b.id}" class="btn btn-warning btn-sm rounded-pill w-100 fw-bold text-dark">
                                    <i class="fa-solid fa-eye me-1"></i>Xem Chi Tiết
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>

</div>

<jsp:include page="../common/footer.jsp"/>
