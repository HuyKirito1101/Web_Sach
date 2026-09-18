<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
                    <a class="nav-link text-white fw-medium" href="/"><i class="fa-solid fa-house me-1"></i>Trang chủ</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-white fw-medium" href="/books"><i class="fa-solid fa-book me-1"></i>Sách Cũ</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-warning fw-medium position-relative" href="/cart">
                        <i class="fa-solid fa-cart-shopping me-1 fs-5"></i>Giỏ hàng
                    </a>
                </li>

                <c:choose>
                    <c:when test="${pageContext.request.userPrincipal != null}">
                        <li class="nav-item dropdown ms-2">
                            <a class="nav-link dropdown-toggle d-flex align-items-center gap-2 text-white fw-medium" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown">
                                <img src="https://ui-avatars.com/api/?name=${pageContext.request.userPrincipal.name}&background=FFC107&color=000" class="rounded-circle border border-warning" width="35" height="35" alt="Avatar">
                                <span>${pageContext.request.userPrincipal.name}</span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow border-0" aria-labelledby="userDropdown">
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
