<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="sidebar p-3">
    <div class="d-flex align-items-center mb-4 px-2">
        <i class="fa-solid fa-store fa-xl text-warning me-2"></i>
        <h5 class="fw-bold mb-0 text-white">HỆ THỐNG QUẢN LÝ</h5>
    </div>
    <hr class="text-secondary my-2">
    
    <ul class="nav nav-pills flex-column mb-auto">
        <c:if test="${pageContext.request.isUserInRole('ROLE_ADMIN') || pageContext.request.isUserInRole('ADMIN')}">
            <li class="nav-item">
                <a href="/admin/dashboard" class="nav-link ${pageContext.request.requestURI.contains('/admin/dashboard') ? 'active' : ''}">
                    <i class="fa-solid fa-chart-line"></i> Dashboard Admin
                </a>
            </li>
            <li class="nav-item">
                <a href="/admin/users" class="nav-link ${pageContext.request.requestURI.contains('/admin/users') ? 'active' : ''}">
                    <i class="fa-solid fa-users-gear"></i> Quản Lý Người Dùng
                </a>
            </li>
            <li class="nav-item">
                <a href="/admin/branches" class="nav-link ${pageContext.request.requestURI.contains('/admin/branches') ? 'active' : ''}">
                    <i class="fa-solid fa-shop"></i> Quản Lý Chi Nhánh
                </a>
            </li>
            <li class="nav-item">
                <a href="/admin/categories" class="nav-link ${pageContext.request.requestURI.contains('/admin/categories') ? 'active' : ''}">
                    <i class="fa-solid fa-list-check"></i> Quản Lý Danh Mục
                </a>
            </li>
            <li class="nav-item">
                <a href="/admin/discounts" class="nav-link ${pageContext.request.requestURI.contains('/admin/discounts') ? 'active' : ''}">
                    <i class="fa-solid fa-ticket"></i> Chiết Khấu & Voucher
                </a>
            </li>
            <li class="nav-item">
                <a href="/admin/shipping" class="nav-link ${pageContext.request.requestURI.contains('/admin/shipping') ? 'active' : ''}">
                    <i class="fa-solid fa-truck-fast"></i> Nhà Vận Chuyển
                </a>
            </li>
            <li class="nav-item">
                <a href="/admin/orders" class="nav-link ${pageContext.request.requestURI.contains('/admin/orders') ? 'active' : ''}">
                    <i class="fa-solid fa-boxes-packing"></i> Tất Cả Đơn Hàng
                </a>
            </li>
        </c:if>

        <c:if test="${pageContext.request.isUserInRole('ROLE_MANAGER') || pageContext.request.isUserInRole('MANAGER')}">
            <li class="nav-item">
                <a href="/manager/dashboard" class="nav-link ${pageContext.request.requestURI.contains('/manager/dashboard') ? 'active' : ''}">
                    <i class="fa-solid fa-gauge-high"></i> Dashboard Chi Nhánh
                </a>
            </li>
            <li class="nav-item">
                <a href="/manager/books" class="nav-link ${pageContext.request.requestURI.contains('/manager/books') ? 'active' : ''}">
                    <i class="fa-solid fa-book"></i> Kho Sách Cũ Chi Nhánh
                </a>
            </li>
            <li class="nav-item">
                <a href="/manager/orders" class="nav-link ${pageContext.request.requestURI.contains('/manager/orders') ? 'active' : ''}">
                    <i class="fa-solid fa-receipt"></i> Đơn Hàng Chi Nhánh
                </a>
            </li>
            <li class="nav-item">
                <a href="/manager/transfers" class="nav-link ${pageContext.request.requestURI.contains('/manager/transfers') ? 'active' : ''}">
                    <i class="fa-solid fa-right-left"></i> Điều Chuyển Sách
                </a>
            </li>
            <li class="nav-item">
                <a href="/manager/staff" class="nav-link ${pageContext.request.requestURI.contains('/manager/staff') ? 'active' : ''}">
                    <i class="fa-solid fa-user-group"></i> Nhân Viên Chi Nhánh
                </a>
            </li>
        </c:if>
    </ul>

    <div class="mt-auto pt-4 border-top border-secondary">
        <a href="/auth/logout" class="nav-link text-danger">
            <i class="fa-solid fa-arrow-right-from-bracket me-2"></i> Đăng Xuất
        </a>
    </div>
</div>
