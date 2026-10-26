<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Danh Sách Sách Cũ - Sách Cũ Việt"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<div class="container py-4">
    <div class="row">
        <!-- Sidebar Filter -->
        <div class="col-lg-3 mb-4">
            <div class="card border-0 shadow-sm rounded-3 p-3">
                <h5 class="fw-bold mb-3 border-bottom pb-2"><i class="fa-solid fa-filter text-warning me-2"></i>Bộ Lọc Sách Cũ</h5>
                <form action="/books" method="GET" id="filterForm">
                    <!-- Preserve sortBy -->
                    <input type="hidden" name="sortBy" value="<c:out value='${sortBy}'/>">

                    <!-- Keyword -->
                    <div class="mb-3">
                        <label class="form-label fw-medium small">Từ khóa</label>
                        <input type="text" name="keyword" class="form-control form-control-sm" placeholder="Tên, Tác giả, ISBN" value="<c:out value='${keyword}'/>">
                    </div>

                    <!-- Category -->
                    <div class="mb-3">
                        <label class="form-label fw-medium small">Danh mục</label>
                        <select name="categoryId" class="form-select form-select-sm">
                            <option value="">-- Tất cả danh mục --</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.id}" ${selectedCategory == cat.id ? 'selected' : ''}><c:out value="${cat.name}"/></option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Branch -->
                    <div class="mb-3">
                        <label class="form-label fw-medium small">Chi nhánh / Shop</label>
                        <select name="branchId" class="form-select form-select-sm">
                            <option value="">-- Tất cả chi nhánh --</option>
                            <c:forEach var="br" items="${branches}">
                                <option value="${br.id}" ${selectedBranch == br.id ? 'selected' : ''}><c:out value="${br.name}"/></option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Condition -->
                    <div class="mb-3">
                        <label class="form-label fw-medium small">Tình trạng sách cũ</label>
                        <select name="condition" class="form-select form-select-sm">
                            <option value="">-- Tất cả tình trạng --</option>
                            <c:forEach var="cond" items="${conditions}">
                                <option value="${cond}" ${selectedCondition == cond ? 'selected' : ''}>${cond}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Price Range -->
                    <div class="mb-3">
                        <label class="form-label fw-medium small">Khoảng giá (VNĐ)</label>
                        <div class="d-flex gap-2">
                            <input type="number" name="minPrice" class="form-control form-control-sm" placeholder="Từ" value="${minPrice}">
                            <input type="number" name="maxPrice" class="form-control form-control-sm" placeholder="Đến" value="${maxPrice}">
                        </div>
                    </div>

                    <button type="submit" class="btn btn-warning w-100 btn-sm fw-bold text-dark rounded-pill mt-2">
                        <i class="fa-solid fa-check me-1"></i>Áp Dụng Lọc
                    </button>
                    <a href="/books" class="btn btn-light w-100 btn-sm fw-medium rounded-pill mt-2">Xóa bộ lọc</a>
                </form>
            </div>
        </div>

        <!-- Book List -->
        <div class="col-lg-9">
            <!-- Sort Tabs -->
            <div class="d-flex flex-wrap gap-2 mb-3 align-items-center">
                <span class="fw-bold text-dark me-2">Sắp xếp:</span>
                <a href="/books?keyword=<c:out value='${keyword}'/>&categoryId=${selectedCategory}&branchId=${selectedBranch}&condition=${selectedCondition}&minPrice=${minPrice}&maxPrice=${maxPrice}&sortBy=newest"
                   class="btn btn-sm rounded-pill fw-bold ${sortBy == 'newest' ? 'btn-warning text-dark' : 'btn-outline-secondary'}">
                    <i class="fa-solid fa-sparkles me-1"></i>Mới nhất
                </a>
                <a href="/books?keyword=<c:out value='${keyword}'/>&categoryId=${selectedCategory}&branchId=${selectedBranch}&condition=${selectedCondition}&minPrice=${minPrice}&maxPrice=${maxPrice}&sortBy=best_seller"
                   class="btn btn-sm rounded-pill fw-bold ${sortBy == 'best_seller' ? 'btn-warning text-dark' : 'btn-outline-secondary'}">
                    <i class="fa-solid fa-fire me-1"></i>Bán chạy
                </a>
                <a href="/books?keyword=<c:out value='${keyword}'/>&categoryId=${selectedCategory}&branchId=${selectedBranch}&condition=${selectedCondition}&minPrice=${minPrice}&maxPrice=${maxPrice}&sortBy=top_rated"
                   class="btn btn-sm rounded-pill fw-bold ${sortBy == 'top_rated' ? 'btn-warning text-dark' : 'btn-outline-secondary'}">
                    <i class="fa-solid fa-star me-1"></i>Đánh giá cao
                </a>
                <a href="/books?keyword=<c:out value='${keyword}'/>&categoryId=${selectedCategory}&branchId=${selectedBranch}&condition=${selectedCondition}&minPrice=${minPrice}&maxPrice=${maxPrice}&sortBy=most_favorite"
                   class="btn btn-sm rounded-pill fw-bold ${sortBy == 'most_favorite' ? 'btn-warning text-dark' : 'btn-outline-secondary'}">
                    <i class="fa-solid fa-heart me-1"></i>Yêu thích
                </a>
                <a href="/books?keyword=<c:out value='${keyword}'/>&categoryId=${selectedCategory}&branchId=${selectedBranch}&condition=${selectedCondition}&minPrice=${minPrice}&maxPrice=${maxPrice}&sortBy=price_asc"
                   class="btn btn-sm rounded-pill fw-bold ${sortBy == 'price_asc' ? 'btn-warning text-dark' : 'btn-outline-secondary'}">
                    Giá thấp → cao
                </a>
                <a href="/books?keyword=<c:out value='${keyword}'/>&categoryId=${selectedCategory}&branchId=${selectedBranch}&condition=${selectedCondition}&minPrice=${minPrice}&maxPrice=${maxPrice}&sortBy=price_desc"
                   class="btn btn-sm rounded-pill fw-bold ${sortBy == 'price_desc' ? 'btn-warning text-dark' : 'btn-outline-secondary'}">
                    Giá cao → thấp
                </a>
            </div>

            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="fw-bold mb-0">Sách Cũ
                    <span class="badge bg-warning text-dark ms-2">${bookPage.totalElements} kết quả</span>
                </h5>
                <c:if test="${bookPage.totalElements > 0}">
                    <small class="text-muted">
                        Hiển thị ${bookPage.number * bookPage.size + 1}-${bookPage.number * bookPage.size + bookPage.numberOfElements}
                        trong ${bookPage.totalElements} sản phẩm
                    </small>
                </c:if>
            </div>

            <c:if test="${empty books}">
                <div class="alert alert-info text-center py-5 shadow-sm rounded-3">
                    <i class="fa-solid fa-box-open fs-1 mb-3 text-secondary"></i>
                    <h5>Không tìm thấy sách cũ phù hợp!</h5>
                    <p class="text-muted">Vui lòng thử tìm với từ khóa khác hoặc bỏ các điều kiện lọc.</p>
                </div>
            </c:if>

            <!-- Chỉ 20 sản phẩm của trang hiện tại được trả về từ server. -->
            <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-4">
                <c:forEach var="b" items="${books}">
                    <div class="col">
                        <div class="card h-100 border-0 shadow-sm rounded-3 overflow-hidden">
                            <img src="<c:out value='${b.coverUrl != null ? b.coverUrl : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400"}'/>"
                                 class="card-img-top" alt="<c:out value='${b.title}'/>" style="height: 220px; object-fit: cover;"
                                 onerror="this.src='https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'">
                            <div class="card-body d-flex flex-column p-3">
                                <span class="badge bg-secondary mb-2 align-self-start"><c:out value="${b.category != null ? b.category.name : 'Sách Cũ'}"/></span>
                                <h6 class="card-title fw-bold text-dark text-truncate mb-1" title="<c:out value='${b.title}'/>"><c:out value="${b.title}"/></h6>
                                <small class="text-muted mb-2"><i class="fa-solid fa-feather me-1"></i><c:out value="${b.author != null ? b.author.name : 'Nhiều tác giả'}"/></small>
                                <div class="mt-auto">
                                    <a href="/books/${b.id}" class="btn btn-warning btn-sm w-100 rounded-pill fw-bold text-dark">
                                        <i class="fa-solid fa-eye me-1"></i>Xem Chi Tiết & Mua
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- Pagination -->
            <c:if test="${bookPage.totalPages > 1}">
                <c:url var="previousPageUrl" value="/books">
                    <c:param name="keyword" value="${keyword}"/><c:param name="categoryId" value="${selectedCategory}"/>
                    <c:param name="branchId" value="${selectedBranch}"/><c:param name="condition" value="${selectedCondition}"/>
                    <c:param name="minPrice" value="${minPrice}"/><c:param name="maxPrice" value="${maxPrice}"/>
                    <c:param name="sortBy" value="${sortBy}"/><c:param name="page" value="${bookPage.number - 1}"/>
                </c:url>
                <c:url var="nextPageUrl" value="/books">
                    <c:param name="keyword" value="${keyword}"/><c:param name="categoryId" value="${selectedCategory}"/>
                    <c:param name="branchId" value="${selectedBranch}"/><c:param name="condition" value="${selectedCondition}"/>
                    <c:param name="minPrice" value="${minPrice}"/><c:param name="maxPrice" value="${maxPrice}"/>
                    <c:param name="sortBy" value="${sortBy}"/><c:param name="page" value="${bookPage.number + 1}"/>
                </c:url>
                <div class="d-flex justify-content-center align-items-center mt-4 gap-2">
                    <c:choose>
                        <c:when test="${bookPage.hasPrevious}">
                            <a class="btn btn-outline-warning text-dark rounded-pill px-3" href="${previousPageUrl}">
                                <i class="fa-solid fa-chevron-left"></i> Trước
                            </a>
                        </c:when>
                        <c:otherwise><span class="btn btn-outline-secondary rounded-pill px-3 disabled">Trước</span></c:otherwise>
                    </c:choose>
                    <span class="fw-bold text-dark">Trang ${bookPage.number + 1} / ${bookPage.totalPages}</span>
                    <c:choose>
                        <c:when test="${bookPage.hasNext}">
                            <a class="btn btn-outline-warning text-dark rounded-pill px-3" href="${nextPageUrl}">
                                Sau <i class="fa-solid fa-chevron-right"></i>
                            </a>
                        </c:when>
                        <c:otherwise><span class="btn btn-outline-secondary rounded-pill px-3 disabled">Sau</span></c:otherwise>
                    </c:choose>
                </div>
            </c:if>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp"/>
