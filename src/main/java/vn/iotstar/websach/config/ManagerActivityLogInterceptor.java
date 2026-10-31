package vn.iotstar.websach.config;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import vn.iotstar.websach.service.ManagerActivityLogService;

@Component
@RequiredArgsConstructor
@Slf4j
public class ManagerActivityLogInterceptor implements HandlerInterceptor {

    private final ManagerActivityLogService activityLogService;

    @Override
    public void afterCompletion(HttpServletRequest request,
                                HttpServletResponse response,
                                Object handler,
                                Exception exception) {
        String method = request.getMethod();
        boolean pageView = "GET".equalsIgnoreCase(method);
        boolean mutation = "POST".equalsIgnoreCase(method)
                || "PUT".equalsIgnoreCase(method)
                || "PATCH".equalsIgnoreCase(method)
                || "DELETE".equalsIgnoreCase(method);
        if (!pageView && !mutation) return;

        Authentication authentication = request.getUserPrincipal() instanceof Authentication auth ? auth : null;
        if (authentication == null || !authentication.isAuthenticated()) return;

        String path = request.getRequestURI();
        String label = describeRequest(method, path);
        String eventType = pageView ? "PAGE_VIEW" : "ACTION";
        String description = pageView ? "Mở trang " + label : "Thao tác: " + label;
        if (exception != null || response.getStatus() >= 400) {
            description = "Lỗi khi " + description.toLowerCase();
            eventType = "ERROR";
        }

        try {
            activityLogService.record(authentication.getName(), eventType, description,
                    request.getRemoteAddr(), safeUserAgent(request));
        } catch (RuntimeException loggingFailure) {
            log.warn("Không ghi được nhật ký hoạt động cho request {} {}", method, path, loggingFailure);
        }
    }

    private String safeUserAgent(HttpServletRequest request) {
        String value = request.getHeader("User-Agent");
        if (value == null) return "Không xác định";
        String sanitized = value.replaceAll("[\\r\\n\\t]", " ").trim();
        return sanitized.length() <= 180 ? sanitized : sanitized.substring(0, 180);
    }

    private String describePath(String path) {
        if (path == null) return "trang quản lý";
        if (path.startsWith("/admin/")) {
            if (path.contains("/users")) return "người dùng toàn hệ thống";
            if (path.contains("/branches")) return "chi nhánh";
            if (path.contains("/categories")) return "danh mục sách toàn hệ thống";
            if (path.contains("/products")) return "sản phẩm toàn hệ thống";
            if (path.contains("/discounts")) return "chiết khấu và voucher";
            if (path.contains("/shipping")) return "đơn vị vận chuyển toàn hệ thống";
            if (path.contains("/promotions")) return "chương trình khuyến mãi toàn hệ thống";
            if (path.contains("/orders")) return "đơn hàng toàn hệ thống";
            if (path.contains("/activity")) return "nhật ký hệ thống";
            if (path.contains("/dashboard")) return "bảng điều khiển Admin";
            return "khu vực quản trị hệ thống";
        }
        if (path.contains("/staff")) return "Vendor và Shipper chi nhánh";
        if (path.contains("/orders")) return "quản lý đơn hàng";
        if (path.contains("/messages")) return "tin nhắn khách hàng";
        if (path.contains("/books")) return "kho sách chi nhánh";
        if (path.contains("/categories")) return "danh mục sách";
        if (path.contains("/promotions")) return "chương trình khuyến mãi";
        if (path.contains("/shipping")) return "đơn vị vận chuyển";
        if (path.contains("/settings")) return "cài đặt chi nhánh";
        if (path.contains("/transfers")) return "điều chuyển sách";
        if (path.contains("/activity")) return "nhật ký hệ thống";
        if (path.contains("/dashboard")) return "bảng điều khiển";
        return "khu vực quản lý chi nhánh";
    }

    private String describeRequest(String method, String path) {
        if ("GET".equalsIgnoreCase(method)) return describePath(path);
        if (path.contains("clear-history")) return "dọn lịch sử đơn hàng";
        if (path.contains("toggle-lock")) return "khóa hoặc mở khóa nhân viên";
        if (path.endsWith("/delete")) return "xóa dữ liệu tại " + describePath(path);
        if (path.endsWith("/reply")) return "trả lời tin nhắn khách hàng";
        if (path.endsWith("/commission")) return "cập nhật chiết khấu chi nhánh";
        if (path.endsWith("/update-role-status")) return "cập nhật quyền hoặc trạng thái nhân viên";
        if (path.endsWith("/save")) return "lưu thông tin tại " + describePath(path);
        if (path.endsWith("/create")) return "tạo yêu cầu tại " + describePath(path);
        if (path.contains("/approve")) return "duyệt yêu cầu điều chuyển sách";
        if (path.contains("/reject")) return "từ chối yêu cầu điều chuyển sách";
        if (path.contains("/complete")) return "hoàn tất điều chuyển sách";
        return "yêu cầu tại " + describePath(path);
    }
}
