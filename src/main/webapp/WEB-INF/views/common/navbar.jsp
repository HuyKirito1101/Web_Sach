<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<nav class="navbar navbar-expand-lg navbar-light bg-white border-bottom px-4 py-2 sticky-top shadow-sm">
    <div class="container-fluid">
        <span class="navbar-brand fw-bold text-primary">
            <i class="fa-solid fa-book-bookmark me-2"></i>SáchCũ ChainManager
        </span>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarContent">
            <ul class="navbar-row ms-auto d-flex align-items-center list-unstyled mb-0 gap-3">
                <li class="nav-item position-relative">
                    <a class="btn btn-light rounded-circle p-2" href="#" id="notificationBtn" title="Thông báo Real-time">
                        <i class="fa-regular fa-bell text-secondary"></i>
                        <span class="position-absolute top-0 start-100 translate-middle p-1 bg-danger border border-light rounded-circle" id="wsBadge" style="display:none;"></span>
                    </a>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle d-flex align-items-center gap-2 fw-medium" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown">
                        <img src="https://ui-avatars.com/api/?name=${pageContext.request.userPrincipal.name}&background=0D6EFD&color=fff" class="rounded-circle" width="35" height="35" alt="Avatar">
                        <span>${pageContext.request.userPrincipal != null ? pageContext.request.userPrincipal.name : 'Tài Khoản'}</span>
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end shadow-sm" aria-labelledby="userDropdown">
                        <li><a class="dropdown-menu-item dropdown-item" href="/auth/logout"><i class="fa-solid fa-right-from-bracket me-2 text-danger"></i>Đăng xuất</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>
