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
        <h1 class="display-4 fw-bold text-warning mb-3">Tìm Kiếm Sách Cũ Quý Hiếm &amp; Giá Rẻ</h1>
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
                <div class="col-6 col-md-4 col-lg-2">
                    <a href="/books?categoryId=${cat.id}" class="card h-100 border-0 shadow-sm text-decoration-none">
                        <div class="card-body text-center p-3">
                            <i class="fa-solid fa-bookmark text-warning mb-2 fs-4"></i>
                            <h6 class="fw-bold text-dark mb-0 small"><c:out value="${cat.name}"/></h6>
                        </div>
                    </a>
                </div>
            </c:forEach>
        </div>
    </div>

    <!-- Sản phẩm cho Guest: chỉ lấy sách đã bán trên 10 cuốn và sắp xếp giảm dần theo doanh số. -->
    <c:if test="${not empty topBooks}">
    <div class="mb-5">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="fw-bold text-dark border-start border-4 border-warning ps-3 mb-0">
                <i class="fa-solid fa-fire text-danger me-2"></i>Sách Đã Bán Trên 10 Cuốn
            </h3>
            <a href="/books" class="btn btn-outline-warning text-dark btn-sm rounded-pill fw-bold">Xem tất cả <i class="fa-solid fa-arrow-right ms-1"></i></a>
        </div>
        <div class="row row-cols-2 row-cols-sm-3 row-cols-md-4 row-cols-lg-5 g-3" id="topBooksGrid">
            <c:forEach var="b" items="${topBooks}">
                <div class="col">
                    <div class="card h-100 border-0 shadow-sm rounded-3 overflow-hidden">
                        <div class="position-relative">
                            <img src="<c:out value='${b.coverUrl != null ? b.coverUrl : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400"}'/>"
                                 class="card-img-top" alt="<c:out value='${b.title}'/>" style="height: 200px; object-fit: cover;"
                                 onerror="this.src='https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'">
                        </div>
                        <div class="card-body d-flex flex-column p-2">
                            <span class="badge bg-secondary mb-1 align-self-start" style="font-size:10px;"><c:out value="${b.category != null ? b.category.name : 'Sách Cũ'}"/></span>
                            <h6 class="card-title fw-bold text-dark mb-1 small" style="font-size:12px; display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;">
                                <a href="/books/${b.id}" class="text-decoration-none text-dark"><c:out value="${b.title}"/></a>
                            </h6>
                            <small class="text-muted mb-2" style="font-size:11px;"><i class="fa-solid fa-feather me-1"></i><c:out value="${b.author != null ? b.author.name : 'Nhiều tác giả'}"/></small>
                            <div class="mt-auto">
                                <a href="/books/${b.id}" class="btn btn-warning btn-sm rounded-pill w-100 fw-bold text-dark" style="font-size:11px;">
                                    <i class="fa-solid fa-eye me-1"></i>Xem Chi Tiết
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>
    </c:if>

    <div class="mb-4">
        <div class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center gap-3 mb-3">
            <div>
                <h3 class="fw-bold text-dark border-start border-4 border-warning ps-3 mb-1">
                    <i class="fa-solid fa-layer-group text-primary me-2"></i>Khám Phá Kho Sách
                </h3>
                <p class="text-muted mb-0 ps-3">Chọn một tiêu chí để xem, tránh lặp lại nhiều danh sách giống nhau trên trang.</p>
            </div>
            <div class="ranking-tabs d-flex flex-wrap gap-2" role="tablist" aria-label="Tiêu chí xếp hạng sách">
                <button type="button" class="btn btn-warning rounded-pill fw-semibold active"
                        onclick="showRankingSection('newBooksSection', this)">
                    <i class="fa-solid fa-sparkles me-1"></i>Mới cập nhật
                </button>
                <button type="button" class="btn btn-outline-secondary rounded-pill fw-semibold"
                        onclick="showRankingSection('bestSellersSection', this)">
                    <i class="fa-solid fa-chart-line me-1"></i>Bán chạy
                </button>
                <button type="button" class="btn btn-outline-secondary rounded-pill fw-semibold"
                        onclick="showRankingSection('topRatedSection', this)">
                    <i class="fa-solid fa-star me-1"></i>Đánh giá cao
                </button>
                <button type="button" class="btn btn-outline-secondary rounded-pill fw-semibold"
                        onclick="showRankingSection('favoritesSection', this)">
                    <i class="fa-solid fa-heart me-1"></i>Yêu thích
                </button>
            </div>
        </div>
    </div>

    <!-- Top 20 Sản phẩm mới (User) với lazy loading -->
    <div class="mb-5 home-ranking-section active" id="newBooksSection">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="fw-bold text-dark border-start border-4 border-warning ps-3 mb-0">
                <i class="fa-solid fa-sparkles text-warning me-2"></i>Sách Mới Cập Nhật
            </h3>
            <a href="/books?sortBy=newest" class="btn btn-outline-warning text-dark btn-sm rounded-pill fw-bold">Xem tất cả <i class="fa-solid fa-arrow-right ms-1"></i></a>
        </div>
        <div class="row row-cols-2 row-cols-sm-3 row-cols-md-4 row-cols-lg-5 g-3" id="newBooksGrid">
            <c:forEach var="b" items="${newBooks}" varStatus="status">
                <div class="col book-card-item ${status.index >= 10 ? 'lazy-hidden' : ''}">
                    <div class="card h-100 border-0 shadow-sm rounded-3 overflow-hidden">
                        <img src="<c:out value='${b.coverUrl != null ? b.coverUrl : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400"}'/>"
                             class="card-img-top" alt="<c:out value='${b.title}'/>" style="height: 200px; object-fit: cover;"
                             onerror="this.src='https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'">
                        <div class="card-body d-flex flex-column p-2">
                            <span class="badge bg-secondary mb-1 align-self-start" style="font-size:10px;"><c:out value="${b.category != null ? b.category.name : 'Sách Cũ'}"/></span>
                            <h6 class="card-title fw-bold text-dark mb-1 small" style="font-size:12px; display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;">
                                <a href="/books/${b.id}" class="text-decoration-none text-dark"><c:out value="${b.title}"/></a>
                            </h6>
                            <small class="text-muted mb-2" style="font-size:11px;"><i class="fa-solid fa-feather me-1"></i><c:out value="${b.author != null ? b.author.name : 'Nhiều tác giả'}"/></small>
                            <div class="mt-auto">
                                <a href="/books/${b.id}" class="btn btn-warning btn-sm rounded-pill w-100 fw-bold text-dark" style="font-size:11px;">
                                    <i class="fa-solid fa-eye me-1"></i>Xem Chi Tiết
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
        <c:if test="${newBooks.size() > 10}">
            <div class="text-center mt-3">
                <button class="btn btn-outline-warning rounded-pill fw-bold px-4 text-dark" onclick="loadMoreBooks('newBooksGrid', this)">
                    <i class="fa-solid fa-chevron-down me-1"></i>Xem thêm (${newBooks.size() - 10} sách)
                </button>
            </div>
        </c:if>
    </div>

    <!-- Top 20 Bán chạy -->
    <div class="mb-5 home-ranking-section" id="bestSellersSection">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="fw-bold text-dark border-start border-4 border-warning ps-3 mb-0">
                <i class="fa-solid fa-chart-line text-success me-2"></i>Sách Bán Chạy Nhất
            </h3>
            <a href="/books?sortBy=best_seller" class="btn btn-outline-warning text-dark btn-sm rounded-pill fw-bold">Xem tất cả <i class="fa-solid fa-arrow-right ms-1"></i></a>
        </div>
        <div class="row row-cols-2 row-cols-sm-3 row-cols-md-4 row-cols-lg-5 g-3" id="bestSellersGrid">
            <c:forEach var="b" items="${bestSellers}" varStatus="status">
                <div class="col book-card-item ${status.index >= 10 ? 'lazy-hidden' : ''}">
                    <div class="card h-100 border-0 shadow-sm rounded-3 overflow-hidden">
                        <img src="<c:out value='${b.coverUrl != null ? b.coverUrl : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400"}'/>"
                             class="card-img-top" alt="<c:out value='${b.title}'/>" style="height: 200px; object-fit: cover;"
                             onerror="this.src='https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'">
                        <div class="card-body d-flex flex-column p-2">
                            <span class="badge bg-danger mb-1 align-self-start" style="font-size:10px;"><i class="fa-solid fa-fire me-1"></i>Bán chạy</span>
                            <h6 class="card-title fw-bold text-dark mb-1 small" style="font-size:12px; display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;">
                                <a href="/books/${b.id}" class="text-decoration-none text-dark"><c:out value="${b.title}"/></a>
                            </h6>
                            <small class="text-muted mb-2" style="font-size:11px;"><i class="fa-solid fa-feather me-1"></i><c:out value="${b.author != null ? b.author.name : 'Nhiều tác giả'}"/></small>
                            <div class="mt-auto">
                                <a href="/books/${b.id}" class="btn btn-warning btn-sm rounded-pill w-100 fw-bold text-dark" style="font-size:11px;">
                                    <i class="fa-solid fa-eye me-1"></i>Xem Chi Tiết
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
        <c:if test="${bestSellers.size() > 10}">
            <div class="text-center mt-3">
                <button class="btn btn-outline-warning rounded-pill fw-bold px-4 text-dark" onclick="loadMoreBooks('bestSellersGrid', this)">
                    <i class="fa-solid fa-chevron-down me-1"></i>Xem thêm (${bestSellers.size() - 10} sách)
                </button>
            </div>
        </c:if>
    </div>

    <!-- Top 20 Đánh giá cao -->
    <div class="mb-5 home-ranking-section" id="topRatedSection">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="fw-bold text-dark border-start border-4 border-warning ps-3 mb-0">
                <i class="fa-solid fa-star text-warning me-2"></i>Sách Được Đánh Giá Cao
            </h3>
            <a href="/books?sortBy=top_rated" class="btn btn-outline-warning text-dark btn-sm rounded-pill fw-bold">Xem tất cả <i class="fa-solid fa-arrow-right ms-1"></i></a>
        </div>
        <div class="row row-cols-2 row-cols-sm-3 row-cols-md-4 row-cols-lg-5 g-3" id="topRatedGrid">
            <c:forEach var="b" items="${topRated}" varStatus="status">
                <div class="col book-card-item ${status.index >= 10 ? 'lazy-hidden' : ''}">
                    <div class="card h-100 border-0 shadow-sm rounded-3 overflow-hidden">
                        <img src="<c:out value='${b.coverUrl != null ? b.coverUrl : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400"}'/>"
                             class="card-img-top" alt="<c:out value='${b.title}'/>" style="height: 200px; object-fit: cover;"
                             onerror="this.src='https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'">
                        <div class="card-body d-flex flex-column p-2">
                            <span class="badge bg-warning text-dark mb-1 align-self-start" style="font-size:10px;"><i class="fa-solid fa-star me-1"></i>Top đánh giá</span>
                            <h6 class="card-title fw-bold text-dark mb-1 small" style="font-size:12px; display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;">
                                <a href="/books/${b.id}" class="text-decoration-none text-dark"><c:out value="${b.title}"/></a>
                            </h6>
                            <small class="text-muted mb-2" style="font-size:11px;"><i class="fa-solid fa-feather me-1"></i><c:out value="${b.author != null ? b.author.name : 'Nhiều tác giả'}"/></small>
                            <div class="mt-auto">
                                <a href="/books/${b.id}" class="btn btn-warning btn-sm rounded-pill w-100 fw-bold text-dark" style="font-size:11px;">
                                    <i class="fa-solid fa-eye me-1"></i>Xem Chi Tiết
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
        <c:if test="${topRated.size() > 10}">
            <div class="text-center mt-3">
                <button class="btn btn-outline-warning rounded-pill fw-bold px-4 text-dark" onclick="loadMoreBooks('topRatedGrid', this)">
                    <i class="fa-solid fa-chevron-down me-1"></i>Xem thêm (${topRated.size() - 10} sách)
                </button>
            </div>
        </c:if>
    </div>

    <!-- Top 20 Yêu thích -->
    <div class="mb-5 home-ranking-section" id="favoritesSection">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="fw-bold text-dark border-start border-4 border-warning ps-3 mb-0">
                <i class="fa-solid fa-heart text-danger me-2"></i>Sách Được Yêu Thích Nhất
            </h3>
            <a href="/books?sortBy=most_favorite" class="btn btn-outline-warning text-dark btn-sm rounded-pill fw-bold">Xem tất cả <i class="fa-solid fa-arrow-right ms-1"></i></a>
        </div>
        <div class="row row-cols-2 row-cols-sm-3 row-cols-md-4 row-cols-lg-5 g-3" id="favoriteGrid">
            <c:forEach var="b" items="${topFavorites}" varStatus="status">
                <div class="col book-card-item ${status.index >= 10 ? 'lazy-hidden' : ''}">
                    <div class="card h-100 border-0 shadow-sm rounded-3 overflow-hidden">
                        <img src="<c:out value='${b.coverUrl != null ? b.coverUrl : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400"}'/>"
                             class="card-img-top" alt="<c:out value='${b.title}'/>" style="height: 200px; object-fit: cover;"
                             onerror="this.src='https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'">
                        <div class="card-body d-flex flex-column p-2">
                            <span class="badge bg-danger mb-1 align-self-start" style="font-size:10px;"><i class="fa-solid fa-heart me-1"></i>Yêu thích</span>
                            <h6 class="card-title fw-bold text-dark mb-1 small" style="font-size:12px; display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;">
                                <a href="/books/${b.id}" class="text-decoration-none text-dark"><c:out value="${b.title}"/></a>
                            </h6>
                            <small class="text-muted mb-2" style="font-size:11px;"><i class="fa-solid fa-feather me-1"></i><c:out value="${b.author != null ? b.author.name : 'Nhiều tác giả'}"/></small>
                            <div class="mt-auto">
                                <a href="/books/${b.id}" class="btn btn-warning btn-sm rounded-pill w-100 fw-bold text-dark" style="font-size:11px;">
                                    <i class="fa-solid fa-eye me-1"></i>Xem Chi Tiết
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
            <c:if test="${empty topFavorites}">
                <div class="col-12">
                    <div class="alert alert-light text-center py-4">
                        <i class="fa-solid fa-heart text-muted fs-3 mb-2 d-block"></i>
                        <p class="text-muted mb-0">Chưa có dữ liệu yêu thích. Hãy thêm sách yêu thích của bạn!</p>
                    </div>
                </div>
            </c:if>
        </div>
        <c:if test="${topFavorites.size() > 10}">
            <div class="text-center mt-3">
                <button class="btn btn-outline-warning rounded-pill fw-bold px-4 text-dark" onclick="loadMoreBooks('favoriteGrid', this)">
                    <i class="fa-solid fa-chevron-down me-1"></i>Xem thêm (${topFavorites.size() - 10} sách)
                </button>
            </div>
        </c:if>
    </div>

</div>

<style>
.lazy-hidden { display: none !important; }
.book-card-item { transition: all 0.3s ease; }
.home-ranking-section { display: none; }
.home-ranking-section.active { display: block; }
.ranking-tabs .btn { min-width: 132px; }
#topBooksGrid .card,
#newBooksGrid .card,
#bestSellersGrid .card,
#topRatedGrid .card,
#favoriteGrid .card {
    transition: transform .2s ease, box-shadow .2s ease;
}
#topBooksGrid .card:hover,
#newBooksGrid .card:hover,
#bestSellersGrid .card:hover,
#topRatedGrid .card:hover,
#favoriteGrid .card:hover {
    transform: translateY(-5px);
    box-shadow: 0 .75rem 1.5rem rgba(15, 23, 42, .14) !important;
}
#topBooksGrid .card-img-top,
#newBooksGrid .card-img-top,
#bestSellersGrid .card-img-top,
#topRatedGrid .card-img-top,
#favoriteGrid .card-img-top {
    height: 230px !important;
    object-fit: contain !important;
    padding: 12px;
    background: linear-gradient(145deg, #fffdf7, #f1f5f9);
}
@media (max-width: 575.98px) {
    .ranking-tabs .btn { flex: 1 1 calc(50% - .5rem); min-width: 0; }
    #topBooksGrid .card-img-top,
    #newBooksGrid .card-img-top,
    #bestSellersGrid .card-img-top,
    #topRatedGrid .card-img-top,
    #favoriteGrid .card-img-top { height: 190px !important; }
}
</style>

<script>
function showRankingSection(sectionId, button) {
    document.querySelectorAll('.home-ranking-section').forEach(function(section) {
        section.classList.toggle('active', section.id === sectionId);
    });
    document.querySelectorAll('.ranking-tabs .btn').forEach(function(tab) {
        var active = tab === button;
        tab.classList.toggle('btn-warning', active);
        tab.classList.toggle('btn-outline-secondary', !active);
        tab.classList.toggle('active', active);
        tab.setAttribute('aria-selected', active ? 'true' : 'false');
    });
}

function loadMoreBooks(gridId, btn) {
    var grid = document.getElementById(gridId);
    var hidden = grid.querySelectorAll('.lazy-hidden');
    hidden.forEach(function(el) {
        el.classList.remove('lazy-hidden');
    });
    btn.closest('.text-center').style.display = 'none';
}
</script>

<jsp:include page="../common/footer.jsp"/>
