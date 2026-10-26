package vn.iotstar.websach;

import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static org.junit.jupiter.api.Assertions.assertTrue;

class JspCsrfCoverageTest {

    private static final Path VIEW_ROOT = Path.of("src/main/webapp/WEB-INF/views");
    private static final Pattern PLAIN_POST_FORM = Pattern.compile(
            "<form(?!:)\\b(?=[^>]*\\bmethod\\s*=\\s*(?:[\\\"']\\s*)?post(?:\\s*[\\\"'])?)[^>]*>",
            Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern CSRF_FIELD = Pattern.compile(
            "_csrf\\.parameterName|name\\s*=\\s*[\\\"']_csrf[\\\"']|data-csrf-token",
            Pattern.CASE_INSENSITIVE);

    @Test
    void everyPlainPostFormContainsCsrfToken() throws IOException {
        List<String> missingTokens = new ArrayList<>();

        try (var paths = Files.walk(VIEW_ROOT)) {
            for (Path path : paths.filter(file -> file.toString().endsWith(".jsp")).toList()) {
                String content = Files.readString(path);
                Matcher matcher = PLAIN_POST_FORM.matcher(content);

                while (matcher.find()) {
                    int closingTag = content.toLowerCase(Locale.ROOT).indexOf("</form>", matcher.end());
                    if (closingTag < 0) {
                        missingTokens.add(path + ": form POST chưa đóng");
                        continue;
                    }

                    String formBody = content.substring(matcher.end(), closingTag);
                    if (!CSRF_FIELD.matcher(formBody).find()) {
                        long line = content.substring(0, matcher.start()).lines().count();
                        missingTokens.add(path + ":" + Math.max(1, line));
                    }
                }
            }
        }

        assertTrue(missingTokens.isEmpty(),
                "Các form POST sau chưa có CSRF token: " + String.join(", ", missingTokens));
    }

    @Test
    void managerOrderViewDoesNotDuplicateVendorOrderOperations() throws IOException {
        String managerOrders = Files.readString(VIEW_ROOT.resolve("manager/orders/list.jsp"));

        assertTrue(!managerOrders.contains("/manager/orders/update-status")
                        && !managerOrders.contains("/manager/orders/assign-shipper"),
                "Manager chỉ được giám sát, không được đổi trạng thái hoặc phân Shipper thay Vendor.");
    }
}
