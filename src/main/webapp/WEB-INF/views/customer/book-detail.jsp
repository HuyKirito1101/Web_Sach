<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="${book.title} - Chi Tiết Sách Cũ"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<div class="container py-4">
    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="/">Trang chủ</a></li>
            <li class="breadcrumb-item"><a href="/books">Sách Cũ</a></li>
            <li class="breadcrumb-item active" aria-current="page">${book.title}</li>
        </ol>
    </nav>

    <div class="row g-4 mb-5">
        <!-- Book Cover -->
        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-2 text-center">
                <img src="${book.coverUrl != null ? book.coverUrl : 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'}" class="img-fluid rounded-3" style="max-height: 400px; object-fit: contain;" alt="${book.title}">
            </div>
        </div>

        <!-- Book Info -->
        <div class="col-md-8">
            <div class="card border-0 shadow-sm rounded-3 p-4">
                <h3 class="fw-bold mb-2">${book.title}</h3>
                <div class="d-flex align-items-center gap-3 mb-3">
                    <span class="text-warning fw-bold"><i class="fa-solid fa-star me-1"></i>${avgRating} / 5</span>
                    <span class="text-muted">(${reviewCount} đánh giá)</span>
                    <span class="badge bg-secondary">${book.category != null ? book.category.name : 'Sách Cũ'}</span>
                </div>

                <div class="row mb-3">
                    <div class="col-6"><p class="mb-1 text-muted"><strong>Tác giả:</strong> ${book.author != null ? book.author.name : 'Không rõ'}</p></div>
                    <div class="col-6"><p class="mb-1 text-muted"><strong>NXB:</strong> ${book.publisher != null ? book.publisher.name : 'Không rõ'}</p></div>
                    <div class="col-6"><p class="mb-1 text-muted"><strong>Năm xuất bản:</strong> ${book.publishYear != null ? book.publishYear : 'Không rõ'}</p></div>
                    <div class="col-6"><p class="mb-1 text-muted"><strong>Mã ISBN:</strong> ${book.isbn != null ? book.isbn : 'N/A'}</p></div>
                </div>

                <div class="mb-4">
                    <h6 class="fw-bold">Mô tả sản phẩm:</h6>
                    <p class="text-muted">${book.description != null ? book.description : 'Chưa có mô tả chi tiết cho cuốn sách này.'}</p>
                </div>

                <!-- Favorite Toggle Form -->
                <form action="/favorites/toggle" method="POST" class="d-inline mb-3">
                    <input type="hidden" name="bookId" value="${book.id}"/>
                    <button type="submit" class="btn ${isFavorite ? 'btn-danger' : 'btn-outline-danger'} btn-sm rounded-pill px-3">
                        <i class="fa-solid fa-heart me-1"></i>${isFavorite ? 'Đã yêu thích' : 'Thêm vào yêu thích'}
                    </button>
                </form>
            </div>
        </div>
    </div>

    <!-- Available Book Copies in Branches -->
    <div class="card border-0 shadow-sm rounded-3 p-4 mb-5">
        <h4 class="fw-bold mb-3 text-dark border-start border-4 border-warning ps-3">Các Bản Copy Sách Cũ Đang Có Tại Các Chi Nhánh</h4>
        <c:choose>
            <c:when test="${empty copies}">
                <div class="alert alert-warning text-center mb-0">
                    <i class="fa-solid fa-circle-exclamation me-2"></i>Hiện tại cuốn sách này tạm hết hàng ở tất cả các chi nhánh!
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Chi Nhánh & Vendor Bán</th>
                                <th>Tình Trạng Sách</th>
                                <th>Ghi Chú Vết Ô/Sờn</th>
                                <th>Giá Bán</th>
                                <th>Số Lượng Tồn</th>
                                <th>Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="cp" items="${copies}">
                                <tr>
                                    <td>
                                        <div class="fw-bold text-primary"><i class="fa-solid fa-store me-2"></i>${cp.branch.name}</div>
                                        <c:if test="${cp.seller != null}">
                                            <span class="badge bg-secondary font-monospace mt-1"><i class="fa-solid fa-user-tie me-1"></i>${cp.seller.fullName}</span>
                                        </c:if>
                                    </td>
                                    <td><span class="badge bg-info text-dark">${cp.conditionRating}</span></td>
                                    <td class="small text-muted">${cp.note != null ? cp.note : 'Không có'}</td>
                                    <td class="fw-bold text-danger">
                                        <fmt:formatNumber value="${cp.sellingPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </td>
                                    <td><span class="badge bg-success">${cp.quantity} cuốn</span></td>
                                    <td>
                                        <form action="/cart/add" method="POST" class="d-inline">
                                            <input type="hidden" name="bookCopyId" value="${cp.id}"/>
                                            <input type="hidden" name="quantity" value="1"/>
                                            <button type="submit" class="btn btn-warning btn-sm rounded-pill fw-bold px-3">
                                                <i class="fa-solid fa-cart-plus me-1"></i>Thêm Giỏ Hàng
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Reviews Section -->
    <div class="card border-0 shadow-sm rounded-3 p-4">
        <h4 class="fw-bold mb-3 text-dark border-start border-4 border-warning ps-3">Đánh Giá & Bình Luận Từ Người Mua</h4>

        <!-- Add Review Form -->
        <div class="bg-light p-3 rounded-3 mb-4">
            <h6 class="fw-bold mb-2">Viết Đánh Giá Sản Phẩm (Nội dung >= 10 ký tự)</h6>
            <form action="/reviews/add" method="POST">
                <input type="hidden" name="bookId" value="${book.id}"/>
                <div class="row g-2 mb-2">
                    <div class="col-md-3">
                        <select name="rating" class="form-select form-select-sm">
                            <option value="5">⭐⭐⭐⭐⭐ (5 sao)</option>
                            <option value="4">⭐⭐⭐⭐ (4 sao)</option>
                            <option value="3">⭐⭐⭐ (3 sao)</option>
                            <option value="2">⭐⭐ (2 sao)</option>
                            <option value="1">⭐ (1 sao)</option>
                        </select>
                    </div>
                    <div class="col-md-9">
                        <input type="text" name="comment" class="form-control form-control-sm" placeholder="Nhập cảm nhận của bạn về cuốn sách cũ này (tình trạng, chất lượng in...)" required minlength="10">
                    </div>
                </div>
                <button type="submit" class="btn btn-warning btn-sm rounded-pill fw-bold">Gửi Đánh Giá</button>
            </form>
        </div>

        <!-- Review List -->
        <c:forEach var="rev" items="${reviews}">
            <div class="border-bottom py-3">
                <div class="d-flex justify-content-between align-items-center mb-1">
                    <span class="fw-bold text-dark">${rev.user.fullName}</span>
                    <span class="text-warning small">${rev.rating} ⭐</span>
                </div>
                <p class="mb-1 text-secondary">${rev.comment}</p>
                <small class="text-muted"><fmt:parseDate value="${rev.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both"/><fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy HH:mm"/></small>
            </div>
        </c:forEach>
    </div>
</div>

<jsp:include page="../common/footer.jsp"/>
