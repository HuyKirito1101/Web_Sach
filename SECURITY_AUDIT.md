# Rà soát bảo mật WebSach theo OWASP Top 10:2025

Ngày rà soát: 22/10/2026.

Tài liệu này ghi lại các biện pháp đã áp dụng và các rủi ro còn lại. Đây không phải
chứng nhận hệ thống an toàn tuyệt đối. Trước khi triển khai công khai vẫn cần kiểm
thử xâm nhập, cấu hình HTTPS và quản lý bí mật trên môi trường chạy thật.

| Nhóm OWASP 2025 | Biện pháp đã áp dụng | Việc còn lại trước production |
|---|---|---|
| A01 Broken Access Control | Phân quyền URL theo vai trò; kiểm tra quyền sở hữu đánh giá, đơn hàng, địa chỉ, sản phẩm/chi nhánh; WebSocket kiểm tra quyền CONNECT/SUBSCRIBE; CSRF cho thao tác thay đổi dữ liệu | Thêm test quyền truy cập cho từng endpoint và từng vai trò; rà soát định kỳ mọi endpoint mới |
| A02 Security Misconfiguration | Tắt stack trace/exception ở response; CSP, `X-Frame-Options`, Referrer Policy, Permissions Policy; demo data tắt mặc định | Chạy sau reverse proxy HTTPS; loại `'unsafe-inline'` khỏi CSP sau khi chuyển JS/CSS nội tuyến sang file hoặc nonce |
| A03 Software Supply Chain Failures | Nâng Spring Boot/JJWT/Cloudinary; ghim phiên bản CDN và thêm SRI; thêm profile OWASP Dependency-Check | Chạy `mvn -Psecurity-audit verify` trong CI và xử lý báo cáo `target/dependency-check-report.html`; bật Dependabot/Renovate |
| A04 Cryptographic Failures | Mật khẩu và OTP dùng BCrypt; JWT secret bắt buộc từ môi trường, tối thiểu 32 ký tự; JWT nằm trong cookie HttpOnly/SameSite | HTTPS bắt buộc; xoay toàn bộ secret đã từng chia sẻ; cân nhắc JWT ngắn hạn + refresh/revocation |
| A05 Injection | JPA repository thay cho ghép SQL; encode dữ liệu động trong các màn hình trọng yếu; validation độ dài/định dạng/URL | Tiếp tục thay mọi EL xuất dữ liệu người dùng bằng `c:out`; có thể dùng template engine auto-escape cho phần mới |
| A06 Insecure Design | Bỏ callback thanh toán demo có thể tự khai `SUCCESS`; kiểm tra tài nguyên thuộc người dùng; rate limit đăng nhập/OTP | Tích hợp VNPAY/MoMo thật bằng IPN đã xác thực chữ ký và cơ chế idempotency; threat model luồng hoàn tiền |
| A07 Authentication Failures | Thông báo đăng nhập/quên mật khẩu không làm lộ tài khoản; giới hạn thử; độ dài mật khẩu 8–72; khóa tài khoản được tôn trọng | Rate limiter hiện chỉ ở RAM một máy; dùng Redis/API gateway khi chạy nhiều instance; thêm MFA cho Admin |
| A08 Software or Data Integrity Failures | SRI cho script/style CDN; trạng thái thanh toán không còn tin dữ liệu từ trình duyệt | Chữ ký webhook thanh toán và kiểm tra replay; bảo vệ nhánh Git/CI và ký artifact nếu triển khai thật |
| A09 Security Logging and Alerting Failures | Ghi log đăng nhập thất bại theo email/IP, không ghi token; lỗi JWT giảm xuống debug | Log tập trung, cảnh báo brute-force/403 tăng đột biến; che dữ liệu cá nhân và đặt thời hạn lưu log |
| A10 Mishandling of Exceptional Conditions | Response lỗi không lộ chi tiết; upload/OTP/thanh toán fail-closed; giới hạn kích thước file | Thêm trang lỗi 4xx/5xx riêng; timeout/circuit breaker cho SMTP, Cloudinary, thanh toán; kiểm thử lỗi hạ tầng |

## Các thay đổi bảo mật đáng chú ý

- CSRF được bật lại vì JWT được lưu trong cookie. Mọi form POST nhận token tự động.
- Cookie JWT dùng `HttpOnly`, `SameSite=Lax`; cờ `Secure` được bật khi request chạy qua HTTPS.
- Khóa JWT và thông tin DB/Mail/Cloudinary không có giá trị thật trong file Git.
- Dữ liệu mẫu và tài khoản mật khẩu mẫu chỉ bật ở profile H2; profile MySQL mặc định không tạo/reset tài khoản mẫu.
- OTP chỉ lưu bản băm BCrypt và chỉ token mới nhất chưa dùng được chấp nhận.
- Upload chỉ cho JPG/PNG/GIF/WEBP/MP4/WEBM, tối đa 10 MB, kiểm tra magic bytes, MIME và phần mở rộng, dùng tên ngẫu nhiên và không ghi đè.
- Review chỉ được tạo cho đúng sản phẩm trong đơn đã giao của chính người mua.
- Callback thanh toán demo không bao giờ tự đánh dấu `PAID`; thanh toán thật phải dùng callback server-to-server có chữ ký.

## Cấu hình bắt buộc khi chạy MySQL

Không commit các giá trị thật vào Git. Cấp chúng qua biến môi trường hoặc secret
manager của nền tảng triển khai:

- `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`
- `JWT_SECRET` (chuỗi ngẫu nhiên tối thiểu 32 ký tự)
- `MAIL_USERNAME`, `MAIL_PASSWORD`
- `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`
- `NVD_API_KEY` cho bước quét dependency trong CI (không bắt buộc khi chạy web)

Không bật `DEMO_DATA_ENABLED=true` trên database dùng thật. Các tài khoản mẫu đã
tồn tại từ lần chạy cũ phải được xóa, khóa hoặc đổi sang mật khẩu mạnh trước khi
đưa hệ thống lên Internet.

## Kiểm tra

```powershell
mvn test
mvn -Psecurity-audit verify
```

Lệnh thứ hai tải dữ liệu lỗ hổng NVD ở lần chạy đầu và có thể mất 20 phút hoặc
hơn nếu không có `NVD_API_KEY`. Build sẽ thất bại nếu phát hiện dependency có
CVSS từ 7 trở lên. Mạng phát triển hiện bị CISA KEV trả HTTP 403 nên analyzer KEV
được tắt; CI production nên dùng mirror được phép rồi bật lại. Báo cáo nằm trong
`target/dependency-check-report.html` và không nên coi việc quét dependency là
thay thế cho kiểm thử xâm nhập ứng dụng.
