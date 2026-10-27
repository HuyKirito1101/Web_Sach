<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="currentUri" value="${not empty requestScope['jakarta.servlet.forward.request_uri'] ? requestScope['jakarta.servlet.forward.request_uri'] : pageContext.request.requestURI}" />
<c:set var="isHome" value="${currentUri == '/' || currentUri == '/home'}" />
<c:set var="isBooks" value="${currentUri.startsWith('/books')}" />
<c:set var="isSellBooks" value="${currentUri.startsWith('/sell-books')}" />
<c:set var="isCart" value="${currentUri.startsWith('/cart')}" />
<c:set var="isAdmin" value="${pageContext.request.isUserInRole('ADMIN')}" />
<c:set var="isManager" value="${pageContext.request.isUserInRole('MANAGER')}" />
<c:set var="isVendor" value="${pageContext.request.isUserInRole('VENDOR')}" />
<c:set var="isShipper" value="${pageContext.request.isUserInRole('SHIPPER')}" />
<c:set var="isStaff" value="${isAdmin || isManager || isVendor || isShipper}" />
<c:choose>
    <c:when test="${isAdmin}"><c:set var="roleHome" value="/admin/dashboard"/><c:set var="roleAreaLabel" value="QUẢN TRỊ HỆ THỐNG"/></c:when>
    <c:when test="${isManager}"><c:set var="roleHome" value="/manager/dashboard"/><c:set var="roleAreaLabel" value="QUẢN LÝ CHI NHÁNH"/></c:when>
    <c:when test="${isVendor}"><c:set var="roleHome" value="/vendor/dashboard"/><c:set var="roleAreaLabel" value="QUẢN LÝ GIAN HÀNG"/></c:when>
    <c:when test="${isShipper}"><c:set var="roleHome" value="/shipper/dashboard"/><c:set var="roleAreaLabel" value="KHU VỰC GIAO HÀNG"/></c:when>
    <c:otherwise><c:set var="roleHome" value="/"/><c:set var="roleAreaLabel" value=""/></c:otherwise>
</c:choose>

<style>
    .app-navbar .navbar-brand,
    .app-navbar .nav-main-link,
    .app-navbar .account-dropdown-link {
        white-space: nowrap;
    }

    .app-navbar .navbar-brand,
    .app-navbar .app-navbar-menu {
        flex-shrink: 0;
    }

    .app-navbar .customer-search-form {
        flex: 1 1 320px;
        min-width: 190px;
        max-width: 450px;
    }

    .app-navbar .app-navbar-menu {
        flex-wrap: nowrap;
        gap: .25rem !important;
    }

    .app-navbar .nav-main-link {
        display: flex;
        align-items: center;
        padding-left: .45rem;
        padding-right: .45rem;
    }

    @media (max-width: 1399.98px) and (min-width: 992px) {
        .app-navbar {
            padding-left: .75rem !important;
            padding-right: .75rem !important;
        }

        .app-navbar .navbar-brand {
            margin-right: .75rem !important;
        }

        .app-navbar .customer-search-form {
            max-width: 330px;
        }

        .app-navbar .nav-main-link {
            font-size: .92rem;
            padding-left: .3rem;
            padding-right: .3rem;
        }

        .app-navbar .account-name {
            display: inline-block;
            max-width: 180px;
            overflow: hidden;
            text-overflow: ellipsis;
            vertical-align: middle;
        }
    }

    @media (max-width: 991.98px) {
        .app-navbar .customer-search-form {
            max-width: none;
        }

        .app-navbar .app-navbar-menu {
            align-items: stretch !important;
            flex-wrap: wrap;
        }
    }
</style>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark border-bottom px-4 py-2 sticky-top shadow-sm app-navbar">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold text-warning d-flex align-items-center me-4" href="${roleHome}">
            <i class="fa-solid fa-book-journal-whills me-2 fs-4"></i>
            <span>Sách Cũ Việt</span>
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarContent">
            <c:choose>
                <c:when test="${isStaff}">
                    <div class="d-none d-lg-flex align-items-center gap-3 mx-auto text-light fw-semibold">
                        <i class="fa-solid fa-shield-halved text-warning me-2"></i>
                        <c:out value="${roleAreaLabel}"/>
                        <c:if test="${isVendor}">
                            <a href="/books" class="btn btn-sm btn-outline-warning rounded-pill px-3">
                                <i class="fa-solid fa-store me-1"></i>Khu mua sách
                            </a>
                        </c:if>
                    </div>
                </c:when>
                <c:otherwise>
                    <form class="d-flex my-2 my-lg-0 mx-auto customer-search-form" action="/books" method="GET">
                        <div class="input-group">
                            <input class="form-control border-end-0 rounded-start-pill ps-3" type="search" name="keyword" placeholder="Tìm tên sách, tác giả, ISBN..." value="<c:out value='${param.keyword}'/>">
                            <button class="btn btn-warning rounded-end-pill px-3" type="submit">
                                <i class="fa-solid fa-magnifying-glass"></i>
                            </button>
                        </div>
                    </form>
                </c:otherwise>
            </c:choose>

            <ul class="navbar-nav ms-auto align-items-center gap-2 mb-2 mb-lg-0 app-navbar-menu">
                <c:if test="${not isStaff}">
                <li class="nav-item">
                    <a class="nav-link nav-main-link ${isHome ? 'text-warning' : 'text-white'} fw-medium" href="/"><i class="fa-solid fa-house me-1"></i>Trang chủ</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link nav-main-link ${isBooks ? 'text-warning' : 'text-white'} fw-medium" href="/books"><i class="fa-solid fa-book me-1"></i>Sách Cũ</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link nav-main-link ${isSellBooks ? 'text-warning' : 'text-white'} fw-medium" href="/sell-books"><i class="fa-solid fa-hand-holding-dollar me-1"></i>Thu Mua Sách</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link nav-main-link ${isCart ? 'text-warning' : 'text-white'} fw-medium position-relative" href="/cart">
                        <i class="fa-solid fa-cart-shopping me-1 fs-5"></i>Giỏ hàng
                    </a>
                </li>
                <c:if test="${pageContext.request.userPrincipal != null}">
                    <li class="nav-item">
                        <a class="nav-link nav-main-link ${currentUri.startsWith('/chat/vendor') ? 'text-warning' : 'text-white'} fw-medium position-relative" href="/chat/vendor" title="Tin nhắn với Shop">
                            <i class="fa-solid fa-comments me-1 fs-5"></i>Tin nhắn
                            <c:if test="${userMessageBadge > 0}">
                                <span class="position-absolute top-1 start-100 translate-middle badge rounded-pill bg-danger border border-dark" style="font-size: 10px;">
                                    ${userMessageBadge}
                                </span>
                            </c:if>
                        </a>
                    </li>
                </c:if>
                </c:if>

                <c:choose>
                    <c:when test="${pageContext.request.userPrincipal != null}">
                        <%-- Chuông thông báo cho Vendor --%>
                        <c:if test="${pageContext.request.isUserInRole('VENDOR') && vTotalNotif > 0}">
                            <li class="nav-item dropdown me-1">
                                <a class="nav-link position-relative text-white px-2" href="#" id="vendorNotifBell" role="button" data-bs-toggle="dropdown" aria-expanded="false" title="Thông báo công việc cần lưu ý">
                                    <i class="fa-solid fa-bell fs-5 text-warning"></i>
                                    <span class="position-absolute top-1 start-100 translate-middle badge rounded-pill bg-danger border border-dark" style="font-size: 10px;">
                                        ${vTotalNotif}
                                    </span>
                                </a>
                                <ul class="dropdown-menu dropdown-menu-end shadow border-0 p-2" aria-labelledby="vendorNotifBell" style="min-width: 290px;">
                                    <li class="dropdown-header fw-bold text-dark d-flex justify-content-between align-items-center py-1">
                                        <span><i class="fa-solid fa-bell text-warning me-1"></i> Cần Lưu Ý Xử Lý</span>
                                        <span class="badge bg-danger rounded-pill">${vTotalNotif}</span>
                                    </li>
                                    <li><hr class="dropdown-divider my-1"></li>
                                    <c:if test="${vMessageBadge > 0}">
                                        <li>
                                            <a class="dropdown-item py-2 rounded d-flex justify-content-between align-items-center small" href="/vendor/messages">
                                                <div><i class="fa-solid fa-comments text-primary me-2"></i>Tin nhắn khách hàng</div>
                                                <span class="badge bg-danger rounded-pill">${vMessageBadge}</span>
                                            </a>
                                        </li>
                                    </c:if>
                                    <c:if test="${vOrderBadge > 0}">
                                        <li>
                                            <a class="dropdown-item py-2 rounded d-flex justify-content-between align-items-center small" href="/vendor/orders">
                                                <div><i class="fa-solid fa-box text-primary me-2"></i>Đơn hàng cần xử lý</div>
                                                <span class="badge bg-danger rounded-pill">${vOrderBadge}</span>
                                            </a>
                                        </li>
                                    </c:if>
                                    <c:if test="${vReturnBadge > 0}">
                                        <li>
                                            <a class="dropdown-item py-2 rounded d-flex justify-content-between align-items-center small" href="/vendor/returns">
                                                <div><i class="fa-solid fa-rotate-left text-warning me-2"></i>Đơn yêu cầu đổi trả</div>
                                                <span class="badge bg-warning text-dark fw-bold rounded-pill">${vReturnBadge}</span>
                                            </a>
                                        </li>
                                    </c:if>
                                    <c:if test="${vSellBadge > 0}">
                                        <li>
                                            <a class="dropdown-item py-2 rounded d-flex justify-content-between align-items-center small" href="/vendor/sell-requests">
                                                <div><i class="fa-solid fa-hand-holding-dollar text-info me-2"></i>Yêu cầu thu mua mới</div>
                                                <span class="badge bg-info text-dark fw-bold rounded-pill">${vSellBadge}</span>
                                            </a>
                                        </li>
                                    </c:if>
                                </ul>
                            </li>
                        </c:if>

                        <%-- Chuông thông báo cho Shipper --%>
                        <c:if test="${pageContext.request.isUserInRole('SHIPPER') && sTotalNotif > 0}">
                            <li class="nav-item dropdown me-1">
                                <a class="nav-link position-relative text-white px-2" href="#" id="shipperNotifBell" role="button" data-bs-toggle="dropdown" aria-expanded="false" title="Thông báo đơn hàng giao">
                                    <i class="fa-solid fa-bell fs-5 text-warning"></i>
                                    <span class="position-absolute top-1 start-100 translate-middle badge rounded-pill bg-danger border border-dark" style="font-size: 10px;">
                                        ${sTotalNotif}
                                    </span>
                                </a>
                                <ul class="dropdown-menu dropdown-menu-end shadow border-0 p-2" aria-labelledby="shipperNotifBell" style="min-width: 280px;">
                                    <li class="dropdown-header fw-bold text-dark d-flex justify-content-between align-items-center py-1">
                                        <span><i class="fa-solid fa-truck-fast text-warning me-1"></i> Đơn Giao Cần Xử Lý</span>
                                        <span class="badge bg-danger rounded-pill">${sTotalNotif}</span>
                                    </li>
                                    <li><hr class="dropdown-divider my-1"></li>
                                    <c:if test="${sAssignedBadge > 0}">
                                        <li>
                                            <a class="dropdown-item py-2 rounded d-flex justify-content-between align-items-center small" href="/shipper/orders">
                                                <div><i class="fa-solid fa-clipboard-check text-danger me-2"></i>Đơn mới chờ nhận</div>
                                                <span class="badge bg-danger rounded-pill">${sAssignedBadge}</span>
                                            </a>
                                        </li>
                                    </c:if>
                                    <c:if test="${sInProgressBadge > 0}">
                                        <li>
                                            <a class="dropdown-item py-2 rounded d-flex justify-content-between align-items-center small" href="/shipper/orders">
                                                <div><i class="fa-solid fa-truck-arrow-right text-primary me-2"></i>Đơn đang lấy &amp; giao</div>
                                                <span class="badge bg-primary rounded-pill">${sInProgressBadge}</span>
                                            </a>
                                        </li>
                                    </c:if>
                                </ul>
                            </li>
                        </c:if>

                        <li class="nav-item dropdown ms-1">
                            <a class="nav-link dropdown-toggle d-flex align-items-center gap-2 text-white fw-medium account-dropdown-link" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown">
                                <c:set var="fallbackAvatar" value="https://ui-avatars.com/api/?name=${pageContext.request.userPrincipal.name}&background=FFC107&color=000" />
                                <c:set var="navbarAvatar" value="${not empty currentUser.avatarUrl ? currentUser.avatarUrl : fallbackAvatar}" />
                                <img src="<c:out value='${navbarAvatar}'/>"
                                     onerror="this.onerror=null;this.src='<c:out value='${fallbackAvatar}'/>';"
                                     class="rounded-circle border border-warning"
                                     width="35" height="35" alt="Ảnh đại diện"
                                     style="object-fit: cover;">
                                <span class="account-name"><c:out value="${pageContext.request.userPrincipal.name}"/></span>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end shadow border-0" aria-labelledby="userDropdown">
                                <c:if test="${pageContext.request.isUserInRole('ADMIN')}">
                                    <li><a class="dropdown-item" href="/admin/dashboard"><i class="fa-solid fa-gauge-high me-2 text-danger"></i>Quản trị hệ thống</a></li>
                                </c:if>
                                <c:if test="${pageContext.request.isUserInRole('MANAGER')}">
                                    <li><a class="dropdown-item" href="/manager/dashboard"><i class="fa-solid fa-chart-line me-2 text-primary"></i>Quản lý chi nhánh</a></li>
                                </c:if>
                                <c:if test="${pageContext.request.isUserInRole('VENDOR')}">
                                    <li>
                                        <a class="dropdown-item d-flex align-items-center justify-content-between" href="/vendor/dashboard">
                                            <div><i class="fa-solid fa-store me-2 text-success"></i>Quản lý cửa hàng</div>
                                            <c:if test="${vTotalNotif > 0}">
                                                <span class="badge bg-danger rounded-pill" style="font-size: 11px;">${vTotalNotif}</span>
                                            </c:if>
                                        </a>
                                    </li>
                                </c:if>
                                <c:if test="${pageContext.request.isUserInRole('SHIPPER')}">
                                    <li>
                                        <a class="dropdown-item d-flex align-items-center justify-content-between" href="/shipper/dashboard">
                                            <div><i class="fa-solid fa-truck me-2 text-warning"></i>Trang giao hàng</div>
                                            <c:if test="${sTotalNotif > 0}">
                                                <span class="badge bg-danger rounded-pill" style="font-size: 11px;">${sTotalNotif}</span>
                                            </c:if>
                                        </a>
                                    </li>
                                </c:if>
                                <c:if test="${pageContext.request.isUserInRole('ADMIN') || pageContext.request.isUserInRole('MANAGER') || pageContext.request.isUserInRole('VENDOR') || pageContext.request.isUserInRole('SHIPPER')}">
                                    <li><hr class="dropdown-divider"></li>
                                </c:if>
                                <c:if test="${not isStaff || isVendor}">
                                    <li><a class="dropdown-item" href="/profile"><i class="fa-solid fa-user me-2 text-primary"></i>Hồ sơ cá nhân</a></li>
                                    <li>
                                        <a class="dropdown-item d-flex align-items-center justify-content-between" href="/chat/vendor">
                                            <div><i class="fa-solid fa-comments me-2 text-primary"></i>Tin nhắn người bán</div>
                                            <c:if test="${userMessageBadge > 0}">
                                                <span class="badge bg-danger rounded-pill" style="font-size: 11px;">${userMessageBadge}</span>
                                            </c:if>
                                        </a>
                                    </li>
                                    <li><a class="dropdown-item" href="/orders"><i class="fa-solid fa-receipt me-2 text-success"></i>Đơn hàng của tôi</a></li>
                                    <li><a class="dropdown-item" href="/sell-books"><i class="fa-solid fa-hand-holding-dollar me-2 text-warning"></i>Yêu cầu thu mua sách</a></li>
                                    <li><a class="dropdown-item" href="/favorites"><i class="fa-solid fa-heart me-2 text-danger"></i>Sách yêu thích</a></li>
                                    <li><a class="dropdown-item" href="/viewed-products"><i class="fa-solid fa-clock-rotate-left me-2 text-info"></i>Sách đã xem</a></li>
                                    <li><hr class="dropdown-divider"></li>
                                </c:if>
                                <li>
                                    <form action="/auth/logout" method="post" class="m-0">
                                        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}">
                                        <button type="submit" class="dropdown-item text-danger fw-bold">
                                            <i class="fa-solid fa-right-from-bracket me-2"></i>Đăng xuất
                                        </button>
                                    </form>
                                </li>
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
