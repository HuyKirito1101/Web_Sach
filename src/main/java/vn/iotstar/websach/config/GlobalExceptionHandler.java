package vn.iotstar.websach.config;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.io.IOException;
import java.util.NoSuchElementException;

@ControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(SecurityException.class)
    public void forbidden(SecurityException exception, HttpServletRequest request,
                          HttpServletResponse response) throws IOException {
        log.warn("Từ chối truy cập {}", request.getRequestURI());
        response.sendError(HttpServletResponse.SC_FORBIDDEN);
    }

    @ExceptionHandler(NoSuchElementException.class)
    public void notFound(NoSuchElementException exception, HttpServletRequest request,
                         HttpServletResponse response) throws IOException {
        log.warn("Không tìm thấy tài nguyên tại {}", request.getRequestURI());
        response.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public void badRequest(IllegalArgumentException exception, HttpServletRequest request,
                           HttpServletResponse response) throws IOException {
        log.warn("Yêu cầu không hợp lệ tại {}", request.getRequestURI());
        response.sendError(HttpServletResponse.SC_BAD_REQUEST);
    }

    @ExceptionHandler(IllegalStateException.class)
    public void conflict(IllegalStateException exception, HttpServletRequest request,
                         HttpServletResponse response) throws IOException {
        log.warn("Trạng thái nghiệp vụ không hợp lệ tại {}", request.getRequestURI());
        response.sendError(HttpServletResponse.SC_CONFLICT);
    }
}
