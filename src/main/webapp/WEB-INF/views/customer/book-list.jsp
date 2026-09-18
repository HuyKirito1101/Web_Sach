<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
                <form action="/books" method="GET">

                    <!-- Keyword -->
                    <div class="mb-3">
                        <label class="form-label fw-medium small">Từ khóa</label>
                        <input type="text" name="keyword" class="form-control form-control-sm" placeholder="Tên, Tác giả, ISBN" value="${keyword}">
                    </div>

                    <!-- Category -->
                    <div class="mb-3">
                        <label class="form-label fw-medium small">Danh mục</label>
                        <select name="categoryId" class="form-select form-select-sm">
                            <option value="">-- Tất cả danh mục --</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.id}" ${selectedCategory == cat.id ? 'selected' : ''}>${cat.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Branch -->
                    <div class="mb-3">
                        <label class="form-label fw-medium small">Chi nhánh / Shop</label>
                        <select name="branchId" class="form-select form-select-sm">
                            <option value="">-- Tất cả chi nhánh --</option>
                            <c:forEach var="br" items="${branches}">
                                <option value="${br.id}" ${selectedBranch == br.id ? 'selected' : ''}>${br.name}</option>
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
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h4 class="fw-bold mb-0">Danh Sách Sách Cũ (${books.size()} kết quả)</h4>
            </div>

            <c:if test="${empty books}">
                <div class="alert alert-info text-center py-5 shadow-sm rounded-3">
                    <i class="fa-solid fa-box-open fs-1 mb-3 text-secondary"></i>
                    <h5>Không tìm thấy sách cũ phù hợp!</h5>
                    <p class="text-muted">Vui lòng thử tìm với từ khóa khác hoặc bỏ các điều kiện lọc.</p>
                </div>
            </c:if>

            <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 g-4">
                <c:forEach var="b" items="${books}">
                    <div class="col">
                        <div class="card h-100 border-0 shadow-sm rounded-3 overflow-hidden">
                            <img src="${b.coverUrl != null ? b.coverUrl : 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'}" class="card-img-top" alt="${b.title}" style="height: 220px; object-fit: cover;">
                            <div class="card-body d-flex flex-column p-3">
                                <span class="badge bg-secondary mb-2 align-self-start">${b.category != null ? b.category.name : 'Sách Cũ'}</span>
                                <h6 class="card-title fw-bold text-dark text-truncate mb-1" title="${b.title}">${b.title}</h6>
                                <small class="text-muted mb-2"><i class="fa-solid fa-feather me-1"></i>${b.author != null ? b.author.name : 'Nhiều tác giả'}</small>
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
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp"/>
