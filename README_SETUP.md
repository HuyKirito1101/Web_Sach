# Hướng dẫn setup website Sách Cũ Việt

Tài liệu này rút gọn từ Chương 11 của báo cáo. Mỗi máy có cấu hình local riêng; **không commit mật khẩu MySQL, Gmail App Password, JWT secret hoặc Cloudinary API secret**.

## 1. Yêu cầu

- JDK 21.
- MySQL 8 đang chạy.
- Maven 3.9+ cài trên máy. Repository hiện **chưa có** `mvnw.cmd`, `mvnw` hoặc `.mvn/wrapper`, nên phải dùng lệnh `mvn`.
- Git.
- Gmail SMTP và Cloudinary chỉ cần cấu hình nếu muốn thử OTP hoặc tải ảnh/video.

Kiểm tra môi trường trong PowerShell:

```powershell
java -version
mvn -version
```

## 2. Tải mã nguồn

```powershell
git clone https://github.com/HuyKirito1101/Web_Sach.git
cd Web_Sach
```

Nếu thư mục đã có source:

```powershell
git status
git pull --rebase origin main
```

Trước khi pull, commit hoặc stash thay đổi local. Không dùng `git reset --hard` khi chưa sao lưu.

## 3. Tạo database MySQL

1. Mở MySQL Workbench và kết nối server MySQL local.
2. Tạo schema `web_sach_cu` nếu chưa có.
3. Mở `web_sach_cu.sql`, kiểm tra các câu lệnh `UPDATE`/`INSERT`, rồi Execute.
4. Cấu hình kết nối trên từng máy ở bước tiếp theo.

```sql
CREATE DATABASE IF NOT EXISTS web_sach_cu
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Script có thể khai báo lược đồ và dữ liệu mẫu. Ứng dụng hiện dùng `spring.jpa.hibernate.ddl-auto=update` để Hibernate đồng bộ một số bảng/cột khi chạy; hãy sao lưu dữ liệu trước khi nhập lại SQL và không xem `ddl-auto=update` là công cụ migration thay thế.

## 4. Cấu hình riêng cho máy

Sao chép file mẫu:

```powershell
Copy-Item src/main/resources/application-local.properties.example src/main/resources/application-local.properties
```

Mở `src/main/resources/application-local.properties` và thay các giá trị mẫu bằng thông tin riêng của máy:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/web_sach_cu?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Ho_Chi_Minh
spring.datasource.username=root
spring.datasource.password=<MAT_KHAU_MYSQL>

jwt.secret=<CHUOI_NGAU_NHIEN_TOI_THIEU_32_KY_TU>
spring.mail.username=<EMAIL_GUI_OTP>
spring.mail.password=<GMAIL_APP_PASSWORD>

cloudinary.cloud-name=<CLOUD_NAME>
cloudinary.api-key=<API_KEY>
cloudinary.api-secret=<API_SECRET>
```

`application-local.properties` đã được `.gitignore` bỏ qua. Mỗi thành viên cần tự tạo file này. Không dùng chung hoặc gửi các secret qua Git. Gmail cần App Password; mật khẩu đăng nhập Gmail thông thường không dùng được cho SMTP. JWT secret phải là chuỗi ngẫu nhiên dài ít nhất 32 ký tự.

Trong file mẫu, `app.demo-accounts.reset-passwords=false` theo mặc định. Chỉ chuyển thành `true` trên database local dùng để demo khi muốn đặt lại mật khẩu tài khoản demo lúc khởi động; không bật nếu cần giữ mật khẩu hiện tại.

## 5. Chạy ứng dụng

Ở thư mục chứa `pom.xml`, chạy:

```powershell
mvn spring-boot:run
```

Chờ log báo Spring khởi động thành công rồi mở [http://localhost:8080/](http://localhost:8080/). Ứng dụng mặc định dùng profile `mysql,local`, cổng 8080.

Để kiểm tra đóng gói trước khi nộp:

```powershell
mvn clean package
```

Nếu Maven báo không xóa được `target`, dừng tiến trình Java đang chạy rồi thử lại; không xóa file build khi một tiến trình đang giữ chúng.

## 6. OTP và ảnh

- OTP đăng ký/đặt lại mật khẩu cần cấu hình Gmail SMTP ở mục 4.
- Upload ảnh/video cần cấu hình đủ ba trường Cloudinary. Không để API secret rỗng hoặc ghi vào source code.
- MoMo của đồ án là quy trình demo QR/chuyển khoản và Vendor xác nhận thủ công; đây không phải cổng MoMo merchant tự đối soát giao dịch.
- Khi thiếu cấu hình dịch vụ ngoài, các chức năng phụ thuộc dịch vụ đó có thể không hoạt động dù trang web vẫn khởi động.

## 7. Dùng chung dữ liệu giữa nhiều máy

MySQL ở `localhost` là server riêng trên từng máy, không tự chia sẻ dữ liệu. Muốn nhiều máy dùng cùng database phải triển khai MySQL trên máy chủ/cloud có mở kết nối an toàn, tạo database/user riêng và cấu hình URL/credentials tương ứng trên từng máy. Không mở MySQL công khai ra Internet bằng tài khoản `root`.

## 8. Giao diện Bootstrap

Dự án dùng Bootstrap 5.3.2 CSS/JS qua CDN trong `common/header.jsp` và `common/footer.jsp`. Layout, sidebar theo role và CSS của website được nhóm tự xây dựng; mã nguồn hiện không khai báo một Bootstrap theme bên thứ ba có tên riêng.

