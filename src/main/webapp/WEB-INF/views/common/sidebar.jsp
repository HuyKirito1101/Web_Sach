<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="sidebar p-3">
    <div class="d-flex align-items-center mb-4 px-2 text-nowrap">
        <i class="fa-solid fa-store fa-xl text-warning me-2"></i>
        <h5 class="fw-bold mb-0 text-white text-nowrap" style="letter-spacing: 0.5px;">HỆ THỐNG QUẢN LÝ</h5>
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
                <a href="/admin/products" class="nav-link ${pageContext.request.requestURI.contains('/admin/products') ? 'active' : ''}">
                    <i class="fa-solid fa-book-open"></i> Sản Phẩm Toàn Hệ Thống
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
                <a href="/admin/promotions" class="nav-link ${pageContext.request.requestURI.contains('/admin/promotions') ? 'active' : ''}">
                    <i class="fa-solid fa-percent"></i> Chương Trình Khuyến Mãi
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
                    <i class="fa-solid fa-receipt"></i> Giám Sát Đơn Hàng
                </a>
            </li>
            <li class="nav-item">
                <a href="/manager/messages" class="nav-link d-flex align-items-center justify-content-between ${pageContext.request.requestURI.contains('/manager/messages') ? 'active' : ''}">
                    <div><i class="fa-solid fa-comments"></i> Tin Nhắn Khách</div>
                    <c:if test="${managerMessageBadge > 0}">
                        <span class="badge bg-danger rounded-pill">${managerMessageBadge}</span>
                    </c:if>
                </a>
            </li>
            <li class="nav-item">
                <a href="/manager/transfers" class="nav-link ${pageContext.request.requestURI.contains('/manager/transfers') ? 'active' : ''}">
                    <i class="fa-solid fa-right-left"></i> Điều Chuyển Sách
                </a>
            </li>
            <li class="nav-item">
                <a href="/manager/staff" class="nav-link ${pageContext.request.requestURI.contains('/manager/staff') ? 'active' : ''}">
                    <i class="fa-solid fa-user-group"></i> Người Dùng Chi Nhánh
                </a>
            </li>
            <li class="nav-item"><a href="/manager/categories" class="nav-link ${pageContext.request.requestURI.contains('/manager/categories') ? 'active' : ''}"><i class="fa-solid fa-list-check"></i> Quản Lý Danh Mục</a></li>
            <li class="nav-item"><a href="/manager/settings" class="nav-link ${pageContext.request.requestURI.contains('/manager/settings') ? 'active' : ''}"><i class="fa-solid fa-sliders"></i> Chiết Khấu Chi Nhánh</a></li>
            <li class="nav-item"><a href="/manager/promotions" class="nav-link ${pageContext.request.requestURI.contains('/manager/promotions') ? 'active' : ''}"><i class="fa-solid fa-percent"></i> Chương Trình Khuyến Mãi</a></li>
            <li class="nav-item"><a href="/manager/shipping" class="nav-link ${pageContext.request.requestURI.contains('/manager/shipping') ? 'active' : ''}"><i class="fa-solid fa-truck-fast"></i> Nhà Vận Chuyển</a></li>
        </c:if>

        <c:if test="${pageContext.request.isUserInRole('ROLE_VENDOR') || pageContext.request.isUserInRole('VENDOR')}">
            <li class="nav-item"><a href="/vendor/dashboard" class="nav-link ${pageContext.request.requestURI.contains('/vendor/dashboard') ? 'active' : ''}"><i class="fa-solid fa-chart-pie"></i> Dashboard Vendor</a></li>
            <li class="nav-item"><a href="/vendor/shop" class="nav-link ${pageContext.request.requestURI.contains('/vendor/shop') ? 'active' : ''}"><i class="fa-solid fa-store"></i> Hồ Sơ Cửa Hàng</a></li>
            <li class="nav-item"><a href="/vendor/products" class="nav-link ${pageContext.request.requestURI.contains('/vendor/products') ? 'active' : ''}"><i class="fa-solid fa-book-open"></i> Sản Phẩm Sách Cũ</a></li>
            <li class="nav-item">
                <a href="/vendor/orders" class="nav-link d-flex align-items-center justify-content-between ${pageContext.request.requestURI.contains('/vendor/orders') ? 'active' : ''}">
                    <div><i class="fa-solid fa-box"></i> Đơn Hàng Shop</div>
                    <c:if test="${vOrderBadge > 0}">
                        <span class="badge bg-danger rounded-pill px-2 py-1" id="vendorSidebarOrderBadge" style="font-size: 11px;">${vOrderBadge}</span>
                    </c:if>
                </a>
            </li>
            <li class="nav-item">
                <a href="/vendor/returns" class="nav-link d-flex align-items-center justify-content-between ${pageContext.request.requestURI.contains('/vendor/returns') ? 'active' : ''}">
                    <div><i class="fa-solid fa-rotate-left"></i> Đổi Trả &amp; Hoàn Tiền</div>
                    <c:if test="${vReturnBadge > 0}">
                        <span class="badge bg-warning text-dark rounded-pill px-2 py-1 fw-bold" id="vendorSidebarReturnBadge" style="font-size: 11px;">${vReturnBadge}</span>
                    </c:if>
                </a>
            </li>
            <li class="nav-item">
                <a href="/vendor/messages" class="nav-link d-flex align-items-center justify-content-between ${pageContext.request.requestURI.contains('/vendor/messages') ? 'active' : ''}">
                    <div><i class="fa-solid fa-comments"></i> Tin Nhắn Khách</div>
                    <c:if test="${vMessageBadge > 0}">
                        <span class="badge bg-danger rounded-pill px-2 py-1" id="vendorSidebarMessageBadge" style="font-size: 11px;">${vMessageBadge}</span>
                    </c:if>
                </a>
            </li>
            <li class="nav-item"><a href="/vendor/promotions" class="nav-link ${pageContext.request.requestURI.contains('/vendor/promotions') ? 'active' : ''}"><i class="fa-solid fa-percent"></i> Khuyến Mãi</a></li>
            <li class="nav-item">
                <a href="/vendor/sell-requests" class="nav-link d-flex align-items-center justify-content-between ${pageContext.request.requestURI.contains('/vendor/sell-requests') ? 'active' : ''}">
                    <div><i class="fa-solid fa-hand-holding-dollar"></i> Thu Mua Sách Cũ</div>
                    <c:if test="${vSellBadge > 0}">
                        <span class="badge bg-info text-dark rounded-pill px-2 py-1 fw-bold" id="vendorSidebarSellBadge" style="font-size: 11px;">${vSellBadge}</span>
                    </c:if>
                </a>
            </li>
        </c:if>

        <c:if test="${pageContext.request.isUserInRole('ROLE_SHIPPER') || pageContext.request.isUserInRole('SHIPPER')}">
            <li class="nav-item"><a href="/shipper/dashboard" class="nav-link ${pageContext.request.requestURI.contains('/shipper/dashboard') ? 'active' : ''}"><i class="fa-solid fa-gauge"></i> Dashboard Shipper</a></li>
            <li class="nav-item">
                <a href="/shipper/orders" class="nav-link d-flex align-items-center justify-content-between ${pageContext.request.requestURI.contains('/shipper/orders') ? 'active' : ''}">
                    <div><i class="fa-solid fa-truck-fast"></i> Đơn Được Phân Công</div>
                    <c:if test="${sTotalNotif > 0}">
                        <span class="badge bg-danger rounded-pill px-2 py-1 fw-bold" id="shipperSidebarBadge" style="font-size: 11px;">${sTotalNotif}</span>
                    </c:if>
                </a>
            </li>
        </c:if>
    </ul>

    <div class="mt-auto pt-4 border-top border-secondary">
        <form action="/auth/logout" method="post" class="m-0">
            <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
            <button type="submit" class="nav-link text-danger border-0 bg-transparent w-100 text-start">
                <i class="fa-solid fa-arrow-right-from-bracket me-2"></i> Đăng Xuất
            </button>
        </form>
    </div>
</div>
