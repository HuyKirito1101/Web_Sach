<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="currentUri" value="${not empty requestScope['jakarta.servlet.forward.request_uri'] ? requestScope['jakarta.servlet.forward.request_uri'] : pageContext.request.requestURI}" />
<c:set var="isHome" value="${currentUri == '/' || currentUri == '/home'}" />
<c:set var="isBooks" value="${currentUri.startsWith('/books')}" />
<c:set var="isCart" value="${currentUri.startsWith('/cart')}" />

<nav class="navbar navbar-expand-lg navbar-dark bg-dark border-bottom px-4 py-2 sticky-top shadow-sm">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold text-warning d-flex align-items-center me-4" href="/">
            <i class="fa-solid fa-book-journal-whills me-2 fs-4"></i>
            <span>Sách Cũ Việt</span>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarContent">
            <!-- Search bar -->
            <form class="d-flex my-2 my-lg-0 mx-auto" action="/books" method="GET" style="max-width: 450px; width: 100%;">
                <div class="input-group">
                    <input class="form-control border-end-0 rounded-start-pill ps-3" type="search" name="keyword" placeholder="Tìm tên sách, tác giả, ISBN..." value="${param.keyword}">
                    <button class="btn btn-warning rounded-end-pill px-3" type="submit">
                        <i class="fa-solid fa-magnifying-glass"></i>
                    </button>
                </div>
            </form>

            <ul class="navbar-nav ms-auto align-items-center gap-2 mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link nav-main-link ${isHome ? 'text-warning' : 'text-white'} fw-medium" href="/"><i class="fa-solid fa-house me-1"></i>Trang chủ</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link nav-main-link ${isBooks ? 'text-warning' : 'text-white'} fw-medium" href="/books"><i class="fa-solid fa-book me-1"></i>Sách Cũ</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link nav-main-link ${isCart ? 'text-warning' : 'text-white'} fw-medium position-relative" href="/cart">
                        <i class="fa-solid fa-cart-shopping me-1 fs-5"></i>Giỏ hàng
                    </a>
                </li>

                <c:choose>
                    <c:when test="${pageContext.request.userPrincipal != null}">
                        <li class="nav-item dropdown ms-2">
                            <a class="nav-link dropdown-toggle d-flex align-items-center gap-2 text-white fw-medium" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown">
                                <c:set var="fallbackAvatar" value="https://ui-avatars.com/api/?name=${pageContext.request.userPrincipal.name}&background=FFC107&color=000" />
                                <c:set var="navbarAvatar" value="${not empty currentUser.avatarUrl ? currentUser.avatarUrl : fallbackAvatar}" />
                                <img src="<c:out value='${navbarAvatar}'/>"
                                     onerror="this.onerror=null;this.src='<c:out value='${fallbackAvatar}'/>';"
                                     class="rounded-circle border border-warning"
                                     width="35" height="35" alt="Ảnh đại diện"
                                     style="object-fit: cover;">
                                <span>${pageContext.request.userPrincipal.name}</span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow border-0" aria-labelledby="userDropdown">
                                <c:if test="${pageContext.request.isUserInRole('ADMIN')}">
                                    <li><a class="dropdown-item" href="/admin/dashboard"><i class="fa-solid fa-gauge-high me-2 text-danger"></i>Quản trị hệ thống</a></li>
                                </c:if>
                                <c:if test="${pageContext.request.isUserInRole('MANAGER')}">
                                    <li><a class="dropdown-item" href="/manager/dashboard"><i class="fa-solid fa-chart-line me-2 text-primary"></i>Quản lý chi nhánh</a></li>
                                </c:if>
                                <c:if test="${pageContext.request.isUserInRole('VENDOR')}">
                                    <li><a class="dropdown-item" href="/vendor/dashboard"><i class="fa-solid fa-store me-2 text-success"></i>Quản lý cửa hàng</a></li>
                                </c:if>
                                <c:if test="${pageContext.request.isUserInRole('SHIPPER')}">
                                    <li><a class="dropdown-item" href="/shipper/dashboard"><i class="fa-solid fa-truck me-2 text-warning"></i>Trang giao hàng</a></li>
                                </c:if>
                                <c:if test="${pageContext.request.isUserInRole('ADMIN') || pageContext.request.isUserInRole('MANAGER') || pageContext.request.isUserInRole('VENDOR') || pageContext.request.isUserInRole('SHIPPER')}">
                                    <li><hr class="dropdown-divider"></li>
                                </c:if>
                                <li><a class="dropdown-item" href="/profile"><i class="fa-solid fa-user me-2 text-primary"></i>Hồ sơ cá nhân</a></li>
                                <li><a class="dropdown-item" href="/orders"><i class="fa-solid fa-receipt me-2 text-success"></i>Đơn hàng của tôi</a></li>
                                <li><a class="dropdown-item" href="/favorites"><i class="fa-solid fa-heart me-2 text-danger"></i>Sách yêu thích</a></li>
                                <li><a class="dropdown-item" href="/viewed-products"><i class="fa-solid fa-clock-rotate-left me-2 text-info"></i>Sách đã xem</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger fw-bold" href="/auth/logout"><i class="fa-solid fa-right-from-bracket me-2"></i>Đăng xuất</a></li>
                            </ul>
                        </li>
                    </c:when>
                    <c:otherwise>
                        <li class="nav-item ms-2">
                            <a class="btn btn-outline-light btn-sm rounded-pill px-3" href="/auth/login"><i class="fa-solid fa-right-to-bracket me-1"></i>Đăng nhập</a>
                        </li>
                        <li class="nav-item">
                            <a class="btn btn-warning btn-sm rounded-pill px-3 text-dark fw-bold" href="/auth/register"><i class="fa-solid fa-user-plus me-1"></i>Đăng ký</a>
                        </li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</nav>

<script>
document.addEventListener("DOMContentLoaded", function() {
    const path = window.location.pathname;
    const links = document.querySelectorAll('.nav-main-link');
    
    links.forEach(link => {
        const href = link.getAttribute('href');
        let isActive = false;
        
        if (href === '/' || href === '/home') {
            isActive = (path === '/' || path === '/home');
        } else if (href) {
            isActive = (path === href || path.startsWith(href + '/') || path.startsWith(href + '?'));
        }
        
        if (isActive) {
            link.classList.add('text-warning');
            link.classList.remove('text-white');
        } else {
            link.classList.remove('text-warning');
            link.classList.add('text-white');
        }
    });
});
</script>
