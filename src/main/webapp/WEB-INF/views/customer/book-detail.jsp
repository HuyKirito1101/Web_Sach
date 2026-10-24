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
            <c:if test="${book.category != null}">
                <li class="breadcrumb-item"><a href="/books?categoryId=${book.category.id}"><c:out value="${book.category.name}"/></a></li>
            </c:if>
            <li class="breadcrumb-item active" aria-current="page"><c:out value="${book.title}"/></li>
        </ol>
    </nav>

    <!-- Alert messages -->
    <c:if test="${param.reviewSuccess == 'true'}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fa-solid fa-check-circle me-2"></i>Đánh giá của bạn đã được gửi thành công!
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>
    <c:if test="${param.reviewError != null}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fa-solid fa-circle-exclamation me-2"></i><c:out value="${param.reviewError}"/>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="row g-4 mb-5">
        <!-- Book Cover -->
        <div class="col-md-4">
            <div class="card border-0 shadow-sm rounded-3 p-2 text-center">
                <img src="<c:out value='${book.coverUrl != null ? book.coverUrl : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400"}'/>"
                     class="img-fluid rounded-3" style="max-height: 420px; object-fit: contain;" alt="<c:out value='${book.title}'/>"
                     onerror="this.src='https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400'">
            </div>

            <!-- Nút yêu thích -->
            <form action="/favorites/toggle" method="POST" class="mt-3">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                <input type="hidden" name="bookId" value="${book.id}"/>
                <button type="submit" class="btn ${isFavorite ? 'btn-danger' : 'btn-outline-danger'} w-100 rounded-pill fw-bold">
                    <i class="fa-solid fa-heart me-1"></i>${isFavorite ? '❤️ Đã Yêu Thích' : '🤍 Thêm Vào Yêu Thích'}
                </button>
            </form>

            <!-- Thống kê nhanh -->
            <div class="card border-0 bg-light rounded-3 p-3 mt-3">
                <div class="d-flex justify-content-around text-center">
                    <div>
                        <div class="fw-bold text-warning fs-5">${avgRating}<i class="fa-solid fa-star ms-1 text-warning"></i></div>
                        <small class="text-muted">Đánh giá</small>
                    </div>
                    <div class="border-start"></div>
                    <div>
                        <div class="fw-bold text-primary fs-5">${reviewCount}</div>
                        <small class="text-muted">Bình luận</small>
                    </div>
                    <div class="border-start"></div>
                    <div>
                        <div class="fw-bold text-success fs-5">${copies.size()}</div>
                        <small class="text-muted">Còn hàng</small>
                    </div>
                </div>
            </div>
        </div>

        <!-- Book Info -->
        <div class="col-md-8">
            <div class="card border-0 shadow-sm rounded-3 p-4">
                <h3 class="fw-bold mb-2"><c:out value="${book.title}"/></h3>
                <div class="d-flex align-items-center gap-3 mb-3 flex-wrap">
                    <span class="text-warning fw-bold">
                        <c:forEach begin="1" end="${avgRating}"><i class="fa-solid fa-star"></i></c:forEach>
                        ${avgRating} / 5
                    </span>
                    <span class="text-muted">(${reviewCount} đánh giá)</span>
                    <span class="badge bg-secondary"><c:out value="${book.category != null ? book.category.name : 'Sách Cũ'}"/></span>
                </div>

                <div class="row mb-3">
                    <div class="col-6"><p class="mb-1 text-muted"><strong>Tác giả:</strong> <c:out value="${book.author != null ? book.author.name : 'Không rõ'}"/></p></div>
                    <div class="col-6"><p class="mb-1 text-muted"><strong>NXB:</strong> <c:out value="${book.publisher != null ? book.publisher.name : 'Không rõ'}"/></p></div>
                    <div class="col-6"><p class="mb-1 text-muted"><strong>Năm xuất bản:</strong> ${book.publishYear != null ? book.publishYear : 'Không rõ'}</p></div>
                    <div class="col-6"><p class="mb-1 text-muted"><strong>Mã ISBN:</strong> <c:out value="${book.isbn != null ? book.isbn : 'N/A'}"/></p></div>
                </div>

                <div class="mb-4">
                    <h6 class="fw-bold">Mô tả sản phẩm:</h6>
                    <p class="text-muted"><c:out value="${book.description != null ? book.description : 'Chưa có mô tả chi tiết cho cuốn sách này.'}"/></p>
                </div>

                <!-- Thêm vào giỏ hàng nhanh (nếu có copy) -->
                <c:if test="${!empty copies}">
                    <div class="alert alert-success border-0 p-2 mb-3">
                        <i class="fa-solid fa-circle-check me-1"></i>
                        <strong>Còn hàng!</strong> ${copies.size()} phiên bản đang có sẵn tại các chi nhánh.
                        <a href="#copies-section" class="alert-link ms-2">Xem & Thêm Vào Giỏ <i class="fa-solid fa-arrow-down ms-1"></i></a>
                    </div>
                </c:if>
                <c:if test="${empty copies}">
                    <div class="alert alert-warning border-0 p-2 mb-3">
                        <i class="fa-solid fa-circle-exclamation me-1"></i>Hiện tại sách này tạm hết hàng!
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <!-- Available Book Copies in Branches -->
    <div class="card border-0 shadow-sm rounded-3 p-4 mb-5" id="copies-section">
        <h4 class="fw-bold mb-3 text-dark border-start border-4 border-warning ps-3">Các Phiên Bản Sách Đang Có Tại Chi Nhánh</h4>
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
                                <th>Chi Nhánh &amp; Vendor Bán</th>
                                <th>Tình Trạng Sách</th>
                                <th>Ghi Chú</th>
                                <th>Giá Bán</th>
                                <th>Số Lượng Tồn</th>
                                <th>Thao Tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="cp" items="${copies}">
                                <tr>
                                    <td>
                                        <div class="fw-bold text-primary"><i class="fa-solid fa-store me-2"></i><c:out value="${cp.branch.name}"/></div>
                                        <c:if test="${cp.seller != null}">
                                            <span class="badge bg-secondary font-monospace mt-1"><i class="fa-solid fa-user-tie me-1"></i><c:out value="${cp.seller.fullName}"/></span>
                                        </c:if>
                                    </td>
                                    <td><span class="badge bg-info text-dark">${cp.conditionRating}</span></td>
                                    <td class="small text-muted"><c:out value="${cp.note != null ? cp.note : 'Không có'}"/></td>
                                    <td class="fw-bold text-danger">
                                        <fmt:formatNumber value="${cp.sellingPrice}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </td>
                                    <td><span class="badge bg-success">${cp.quantity} cuốn</span></td>
                                    <td>
                                        <form action="/cart/add" method="POST" class="d-inline">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
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

    <!-- Reviews & Comments Section -->
    <div class="card border-0 shadow-sm rounded-3 p-4">
        <h4 class="fw-bold mb-4 text-dark border-start border-4 border-warning ps-3">
            <i class="fa-solid fa-comments me-2"></i>Đánh Giá &amp; Bình Luận Từ Người Mua
        </h4>

        <!-- Star summary -->
        <div class="row mb-4 align-items-center">
            <div class="col-md-3 text-center">
                <div class="display-4 fw-bold text-warning">${avgRating}</div>
                <div class="text-warning mb-1">
                    <c:forEach begin="1" end="5" varStatus="s">
                        <c:choose>
                            <c:when test="${s.index <= avgRating}"><i class="fa-solid fa-star"></i></c:when>
                            <c:otherwise><i class="fa-regular fa-star"></i></c:otherwise>
                        </c:choose>
                    </c:forEach>
                </div>
                <small class="text-muted">${reviewCount} đánh giá</small>
            </div>
            <div class="col-md-9">
                <c:forEach begin="1" end="5" step="1" var="star">
                    <c:set var="displayStar" value="${6 - star}" />
                    <div class="d-flex align-items-center gap-2 mb-1">
                        <span class="small text-muted" style="width:15px;">${displayStar}</span>
                        <i class="fa-solid fa-star text-warning small"></i>
                        <div class="progress flex-grow-1" style="height:8px;">
                            <div class="progress-bar bg-warning" style="width:50%"></div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>

        <c:if test="${not empty param.reviewError}">
            <div class="alert alert-danger alert-dismissible fade show rounded-3 mb-4 shadow-sm" role="alert">
                <i class="fa-solid fa-triangle-exclamation me-2"></i><strong>Lỗi gửi đánh giá:</strong> <c:out value="${param.reviewError}"/>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>
        <c:if test="${not empty param.reviewSuccess}">
            <div class="alert alert-success alert-dismissible fade show rounded-3 mb-4 shadow-sm" role="alert">
                <i class="fa-solid fa-circle-check me-2"></i>Cảm ơn bạn đã gửi đánh giá cho cuốn sách này!
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <c:choose>
            <c:when test="${canReview}">
                <!-- Add Review Form -->
                <div class="bg-light p-4 rounded-3 mb-4 border">
                    <h6 class="fw-bold mb-3"><i class="fa-solid fa-pen-to-square me-2 text-warning"></i>Viết Đánh Giá &amp; Bình Luận (tối thiểu 50 ký tự)</h6>
                    <form action="/reviews/add" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                        <input type="hidden" name="bookId" value="${book.id}"/>

                        <!-- Star rating -->
                        <div class="mb-3">
                            <label class="form-label fw-medium small">Đánh giá của bạn:</label>
                            <div class="d-flex gap-2">
                                <c:forEach begin="1" end="5" var="s">
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="radio" name="rating" id="star${s}" value="${s}" ${s == 5 ? 'checked' : ''}>
                                        <label class="form-check-label text-warning" for="star${s}">
                                            <i class="fa-solid fa-star"></i>${s}
                                        </label>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>

                        <!-- Text comment -->
                        <div class="mb-3">
                            <label class="form-label fw-medium small">Nội dung đánh giá (tối thiểu 50 ký tự):</label>
                            <textarea name="comment" class="form-control" rows="4"
                                      placeholder="Chia sẻ cảm nhận của bạn về cuốn sách cũ này: tình trạng thực tế, chất lượng in ấn, nội dung hay dở, thời gian giao hàng... (tối thiểu 50 ký tự)"
                                      required minlength="50" maxlength="2000" id="reviewComment" onkeyup="updateCharCount()"></textarea>
                            <div class="d-flex justify-content-between mt-1">
                                <small class="text-muted">Tối thiểu 50 ký tự</small>
                                <small class="text-muted" id="charCount">0/2000</small>
                            </div>
                        </div>

                        <!-- Upload ảnh / video Cloudinary -->
                        <div class="mb-3">
                            <label class="form-label fw-medium small">
                                <i class="fa-solid fa-cloud-arrow-up me-1 text-primary"></i>Tải ảnh đánh giá (Upload Cloudinary):
                            </label>
                            <input type="file" name="imageFile" accept="image/*" class="form-control mb-1">
                            <div class="form-text">Chọn ảnh thực tế của sách để tải trực tiếp lên Cloudinary</div>
                        </div>

                        <!-- Image URL fallback -->
                        <div class="mb-3">
                            <label class="form-label fw-medium small">
                                <i class="fa-solid fa-image me-1 text-secondary"></i>Hoặc dán Link ảnh (URL):
                            </label>
                            <input type="text" name="imageUrl" class="form-control" placeholder="https://... (URL ảnh)">
                        </div>

                        <!-- Video URL -->
                        <div class="mb-3">
                            <label class="form-label fw-medium small">
                                <i class="fa-brands fa-youtube me-1 text-danger"></i>Link video đánh giá (YouTube, TikTok...):
                            </label>
                            <input type="text" name="videoUrl" class="form-control" placeholder="https://youtu.be/... hoặc https://www.tiktok.com/@...">
                        </div>

                        <button type="submit" class="btn btn-warning rounded-pill fw-bold px-4">
                            <i class="fa-solid fa-paper-plane me-1"></i>Gửi Đánh Giá
                        </button>
                    </form>
                </div>
            </c:when>
            <c:otherwise>
                <div class="alert alert-light border rounded-3 p-3 mb-4 text-muted">
                    <i class="fa-solid fa-circle-info me-2 text-primary"></i>
                    <strong>Chính sách đánh giá:</strong> Bạn cần đăng nhập, đặt mua cuốn sách này và nhận hàng thành công (trạng thái đơn <b>Đã giao</b>) thì mới có thể viết đánh giá &amp; bình luận.
                </div>
            </c:otherwise>
        </c:choose>

        <!-- Review List -->
        <c:choose>
            <c:when test="${empty reviews}">
                <div class="text-center py-4">
                    <i class="fa-regular fa-comment-dots fs-1 text-muted mb-3 d-block"></i>
                    <p class="text-muted">Chưa có đánh giá nào. Hãy là người đầu tiên đánh giá cuốn sách này!</p>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="rev" items="${reviews}">
                    <div class="border-bottom py-3">
                        <div class="d-flex align-items-start gap-3">
                            <div class="bg-warning rounded-circle d-flex align-items-center justify-content-center text-dark fw-bold" style="width:42px;height:42px;flex-shrink:0;">
                                ${rev.user.fullName.substring(0,1).toUpperCase()}
                            </div>
                            <div class="flex-grow-1">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <span class="fw-bold text-dark"><c:out value="${rev.user.fullName}"/></span>
                                    <span class="text-warning small">
                                        <c:forEach begin="1" end="${rev.rating}"><i class="fa-solid fa-star"></i></c:forEach>
                                        (${rev.rating}/5)
                                    </span>
                                </div>
                                <p class="mb-2 text-secondary"><c:out value="${rev.comment}"/></p>
                                <!-- Hình ảnh đính kèm -->
                                <c:if test="${rev.imageUrl != null && !rev.imageUrl.isEmpty()}">
                                    <div class="mb-2">
                                        <img src="<c:out value='${rev.imageUrl}'/>" alt="Ảnh đánh giá"
                                             class="rounded-3 border" style="max-height:200px; max-width:300px; object-fit:cover;"
                                             onerror="this.style.display='none'">
                                    </div>
                                </c:if>
                                <small class="text-muted">
                                    <i class="fa-regular fa-clock me-1"></i>
                                    <fmt:parseDate value="${rev.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both"/>
                                    <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy HH:mm"/>
                                </small>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<script>
function updateCharCount() {
    var txt = document.getElementById('reviewComment').value;
    document.getElementById('charCount').textContent = txt.length + '/2000';
}
</script>

<jsp:include page="../common/footer.jsp"/>
