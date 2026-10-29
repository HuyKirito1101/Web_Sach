package vn.iotstar.websach.config;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.persistence.PersistenceException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.transaction.TransactionException;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import vn.iotstar.websach.util.ExceptionMessages;

import java.io.IOException;
import java.sql.SQLException;
import java.util.NoSuchElementException;

@ControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(DataIntegrityViolationException.class)
    public String databaseConstraintViolation(DataIntegrityViolationException exception,
                                              HttpServletRequest request,
                                              HttpServletResponse response,
                                              Model model) {
        return databaseError(exception, request, response, model, HttpServletResponse.SC_CONFLICT);
    }

    @ExceptionHandler({DataAccessException.class, PersistenceException.class,
            TransactionException.class, SQLException.class})
    public String databaseFailure(Exception exception, HttpServletRequest request,
                                  HttpServletResponse response, Model model) {
        return databaseError(exception, request, response, model, HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    }

    private String databaseError(Throwable exception, HttpServletRequest request,
                                 HttpServletResponse response, Model model, int status) {
        response.setStatus(status);
        model.addAttribute("status", status);
        model.addAttribute("errorMessage", ExceptionMessages.userMessage(exception));
        model.addAttribute("path", request.getRequestURI());
        return "error";
    }

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
