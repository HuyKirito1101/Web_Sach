package vn.iotstar.websach.util;

import jakarta.persistence.PersistenceException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.transaction.TransactionException;

import java.sql.SQLException;
import java.util.Collections;
import java.util.IdentityHashMap;
import java.util.Set;

/** Maps persistence failures to safe messages while keeping the technical cause in server logs. */
@Slf4j
public final class ExceptionMessages {

    private static final String DATABASE_CONSTRAINT_MESSAGE =
            "Không thể lưu dữ liệu vì thông tin bị trùng hoặc đang được dữ liệu khác sử dụng. Vui lòng kiểm tra lại.";
    private static final String DATABASE_FAILURE_MESSAGE =
            "Hệ thống gặp sự cố khi xử lý dữ liệu. Dữ liệu có thể chưa được lưu; vui lòng tải lại trang và thử lại sau.";

    private ExceptionMessages() {
    }

    public static String userMessage(Throwable exception) {
        if (exception == null) {
            return "Không thể xử lý yêu cầu lúc này. Vui lòng thử lại sau.";
        }

        if (isDatabaseFailure(exception)) {
            log.error("Database operation failed", exception);
            return hasCause(exception, DataIntegrityViolationException.class)
                    ? DATABASE_CONSTRAINT_MESSAGE
                    : DATABASE_FAILURE_MESSAGE;
        }

        return exception.getMessage() == null || exception.getMessage().isBlank()
                ? "Không thể xử lý yêu cầu lúc này. Vui lòng thử lại sau."
                : exception.getMessage();
    }

    public static boolean isDatabaseFailure(Throwable exception) {
        return hasCause(exception, DataAccessException.class)
                || hasCause(exception, PersistenceException.class)
                || hasCause(exception, TransactionException.class)
                || hasCause(exception, SQLException.class);
    }

    public static HttpStatus httpStatus(Throwable exception) {
        if (hasCause(exception, DataIntegrityViolationException.class)) {
            return HttpStatus.CONFLICT;
        }
        return isDatabaseFailure(exception) ? HttpStatus.INTERNAL_SERVER_ERROR : HttpStatus.BAD_REQUEST;
    }

    private static boolean hasCause(Throwable exception, Class<? extends Throwable> type) {
        Set<Throwable> visited = Collections.newSetFromMap(new IdentityHashMap<>());
        Throwable current = exception;
        while (current != null && visited.add(current)) {
            if (type.isInstance(current)) {
                return true;
            }
            current = current.getCause();
        }
        return false;
    }
}
