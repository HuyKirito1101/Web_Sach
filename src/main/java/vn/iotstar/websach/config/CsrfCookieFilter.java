package vn.iotstar.websach.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.web.csrf.CsrfToken;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * Filter đảm bảo rằng token CSRF được khởi tạo và ghi vào cookie XSRF-TOKEN
 * ngay trong quá trình xử lý request, trước khi response headers được commit ra JSP.
 */
public class CsrfCookieFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        CsrfToken csrfToken = (CsrfToken) request.getAttribute(CsrfToken.class.getName());
        if (csrfToken != null) {
            // Gọi getToken() để kích hoạt lưu cookie XSRF-TOKEN vào response
            csrfToken.getToken();
            request.setAttribute("_csrf", csrfToken);
        }
        filterChain.doFilter(request, response);
    }
}
