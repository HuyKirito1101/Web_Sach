-- ===================================================================
-- SCRIPT DATABASE VÀ DỮ LIỆU GỐC HỆ THỐNG WEB SÁCH CŨ
-- Database: MySQL 8.x
-- ===================================================================
-- LƯU Ý QUAN TRỌNG:
-- 1. Tất cả dữ liệu bạn thao tác trên giao diện Web (đặt hàng, phân shipper,
--    thu mua, đổi trả, tạo khuyến mãi...) ĐÃ ĐƯỢC LƯU VĨNH VIỄN VÀO MYSQL.
-- 2. KHÔNG CẦN ấn nút SẤM SÉT VÀNG (⚡) trong MySQL Workbench để "lưu".
-- 3. Nút sấm sét vàng là nút "Execute" (thực thi toàn bộ file script này).
--    File này đã được cấu hình "CREATE TABLE IF NOT EXISTS" và "INSERT IGNORE"
--    để BẢO VỆ DỮ LIỆU, tránh bị mất dữ liệu ngay cả khi lỡ ấn nút sấm sét!
-- 4. Cuối file có bước đồng bộ schema cũ với Entity: chỉ thêm cột/khóa còn thiếu
--    và chuẩn hóa kiểu cột; không DROP bảng hay xóa các dòng dữ liệu hiện có.
-- ===================================================================

CREATE DATABASE IF NOT EXISTS `web_sach_cu` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `web_sach_cu`;

SET FOREIGN_KEY_CHECKS = 0;

-- 1. BẢNG ROLES (Quyền hạn)
CREATE TABLE IF NOT EXISTS `roles` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(30) NOT NULL UNIQUE,
  `description` VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `roles` (`id`, `name`, `description`) VALUES
(1, 'ROLE_ADMIN', 'Quản trị viên toàn hệ thống chuỗi cửa hàng'),
(2, 'ROLE_MANAGER', 'Quản lý chi nhánh cửa hàng sách'),
(3, 'ROLE_VENDOR', 'Chủ gian hàng / Đối tác bán sách tại chi nhánh'),
(4, 'ROLE_SHIPPER', 'Nhân viên giao hàng của chi nhánh / đơn vị vận chuyển'),
(5, 'ROLE_USER', 'Khách hàng mua bán sách cũ');

-- 2. BẢNG CATEGORIES (Danh mục sách)
CREATE TABLE IF NOT EXISTS `categories` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `slug` VARCHAR(150) NOT NULL UNIQUE,
  `description` TEXT DEFAULT NULL,
  `active` BIT(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `categories` (`id`, `name`, `slug`, `description`, `active`) VALUES
(1, 'Văn Học Việt Nam', 'van-hoc-viet-nam', 'Các tác phẩm văn học nổi tiếng trong nước qua các thời kỳ', b'1'),
(2, 'Sách Trước 1975', 'sach-truoc-1975', 'Các ấn bản sách cũ, tài liệu quý hiếm phát hành trước 1975', b'1'),
(3, 'Kinh Tế - Kỹ Năng', 'kinh-te-ky-nang', 'Sách quản trị kinh doanh, tài chính và phát triển bản thân', b'1'),
(4, 'Truyện Tranh & Manga Cũ', 'truyen-tranh-manga', 'Bộ truyện tranh sưu tầm ngả màu thời gian', b'1'),
(5, 'Giáo Trình & Ngoại Ngữ', 'giao-trinh-ngoai-ngu', 'Giáo trình đại học và tài liệu luyện thi ngoại ngữ', b'1'),
(6, 'Sách Giáo Khoa & Tham Khảo', 'sgk-tham-khao', 'Bộ sách giáo khoa 1-12 và sách luyện thi cũ', b'1');

-- 3. BẢNG PUBLISHERS (Nhà xuất bản)
CREATE TABLE IF NOT EXISTS `publishers` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `address` VARCHAR(255) DEFAULT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `active` BIT(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `publishers` (`id`, `name`, `address`) VALUES
(1, 'NXB Kim Đồng', '55 Quang Trung, Hai Bà Trưng, Hà Nội'),
(2, 'NXB Văn Học', '18 Nguyễn Trường Tộ, Ba Đình, Hà Nội'),
(3, 'NXB Trẻ', '161B Lý Chính Thắng, P. Võ Thị Sáu, Q.3, TP.HCM'),
(4, 'NXB Lao Động', '175 Giảng Võ, Đống Đa, Hà Nội'),
(5, 'NXB Giáo Dục Việt Nam', '81 Trần Hưng Đạo, Hoàn Kiếm, Hà Nội'),
(6, 'NXB Hội Nhà Văn', 'Hà Nội'),
(7, 'NXB Thế Giới', 'Hà Nội'),
(8, 'First News - Trí Việt', 'TP.HCM');

-- 4. BẢNG AUTHORS (Tác giả)
CREATE TABLE IF NOT EXISTS `authors` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `bio` TEXT DEFAULT NULL,
  `birth_year` INT DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `authors` (`id`, `name`, `bio`) VALUES
(1, 'Tô Hoài', 'Nhà văn hiện thực xuất sắc của văn học hiện đại Việt Nam'),
(2, 'Vũ Trọng Phụng', 'Ông vua phóng sự đất Bắc, tác giả Số Đỏ'),
(3, 'Ngô Tất Tố', 'Nhà văn, nhà báo, nhà nghiên cứu văn học có ảnh hưởng sâu rộng'),
(4, 'Nguyễn Nhật Ánh', 'Nhà văn viết cho thanh thiếu niên được yêu mến hàng đầu'),
(5, 'Dale Carnegie (Bản dịch Nguyễn Hiến Lê)', 'Tác giả sách tự lực và phát triển bản thân nổi tiếng thế giới'),
(6, 'Nhiều Tác Giả (Bộ Giáo Dục)', 'Tập thể tác giả biên soạn sách giáo khoa'),
(7, 'Paulo Coelho', 'Nhà văn Brazil nổi tiếng với những tác phẩm giàu tính biểu tượng'),
(8, 'José Mauro de Vasconcelos', 'Nhà văn Brazil, tác giả Cây Cam Ngọt Của Tôi'),
(9, 'Rosie Nguyễn', 'Tác giả và blogger du lịch Việt Nam'),
(10, 'James Clear', 'Tác giả chuyên viết về thói quen và cải thiện bản thân'),
(11, 'Haruki Murakami', 'Tiểu thuyết gia đương đại nổi tiếng của Nhật Bản'),
(12, 'Nguyên Phong', 'Tác giả và dịch giả các tác phẩm văn hóa, tâm linh phương Đông');

INSERT INTO `authors` (`name`, `bio`)
SELECT 'Fujiko F. Fujio', 'Bút danh của họa sĩ manga Hiroshi Fujimoto, đồng sáng tạo bộ truyện Doraemon.'
WHERE NOT EXISTS (SELECT 1 FROM `authors` WHERE `name` = 'Fujiko F. Fujio');

-- 5. BẢNG SHIPPING_PROVIDERS (Đơn vị vận chuyển)
CREATE TABLE IF NOT EXISTS `shipping_providers` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(50) NOT NULL UNIQUE,
  `name` VARCHAR(150) NOT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `base_fee` DOUBLE NOT NULL DEFAULT 20000.0,
  `estimated_days` VARCHAR(100) DEFAULT '2-3 ngày',
  `service_type` VARCHAR(100) DEFAULT 'IN_PROVINCE',
  `scope_description` VARCHAR(255) DEFAULT 'Giao hàng nội tỉnh và liên kết chi nhánh',
  `active` BIT(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `shipping_providers` (`id`, `code`, `name`, `phone`, `base_fee`, `estimated_days`, `service_type`, `scope_description`, `active`) VALUES
(1, 'GHN_STANDARD', 'Giao Hàng Nhanh (GHN) - Tiêu Chuẩn', '1900636677', 20000.0, '2-3 ngày', 'IN_PROVINCE', 'Giao hàng tiêu chuẩn trong tỉnh & thu hồi sách đổi trả', b'1'),
(2, 'GHN_EXPRESS', 'Giao Hàng Nhanh (GHN) - Hỏa Tốc', '1900636677', 40000.0, '2-4 giờ', 'IN_PROVINCE', 'Giao nhanh hỏa tốc trong ngày cùng thành phố', b'1'),
(3, 'SPX_EXPRESS', 'SPX Express (Shopee Xpress)', '19001221', 35000.0, '2-4 ngày', 'OUT_OF_PROVINCE', 'Dịch vụ vận chuyển đối tác toàn quốc liên tỉnh', b'1');

-- 6. BẢNG BRANCHES (Cơ sở / Chi nhánh)
CREATE TABLE IF NOT EXISTS `branches` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `address` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `email` VARCHAR(150) DEFAULT NULL,
  `image_url` VARCHAR(500) DEFAULT NULL,
  `cover_url` VARCHAR(500) DEFAULT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  `app_discount_percent` DOUBLE DEFAULT 10.0,
  `vendor_id` BIGINT DEFAULT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_branches_vendor` (`vendor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `branches` (`id`, `name`, `address`, `phone`, `email`, `status`, `app_discount_percent`, `vendor_id`) VALUES
(1, 'Sách Cũ Chi Nhánh Thủ Đức', 'Số 1 Võ Văn Ngân, P. Linh Chiểu, TP. Thủ Đức, TP.HCM', '0901234567', 'thuduc@websachcu.vn', 'ACTIVE', 10.0, 4),
(2, 'Sách Cũ Chi Nhánh Phú Nhuận', '205 Trần Huy Liệu, P.8, Q. Phú Nhuận, TP.HCM', '0907654321', 'phunhuan@websachcu.vn', 'ACTIVE', 10.0, 6);

-- 7. BẢNG USERS (Người dùng, Vendor, Shipper)
CREATE TABLE IF NOT EXISTS `users` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `full_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `role_id` BIGINT NOT NULL,
  `branch_id` BIGINT DEFAULT NULL,
  `shipping_provider_id` BIGINT DEFAULT NULL,
  `specialized_category_id` BIGINT DEFAULT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  `avatar_url` VARCHAR(500) DEFAULT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  CONSTRAINT `fk_users_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_users_shipping_provider` FOREIGN KEY (`shipping_provider_id`) REFERENCES `shipping_providers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_users_specialized_category` FOREIGN KEY (`specialized_category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Mật khẩu mặc định toàn bộ tài khoản demo là: 123456
INSERT IGNORE INTO `users` (`id`, `full_name`, `email`, `password`, `phone`, `role_id`, `branch_id`, `shipping_provider_id`, `specialized_category_id`, `status`) VALUES
(1, 'Quản Trị Viên Admin', 'admin@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0376131883', 1, NULL, NULL, NULL, 'ACTIVE'),
(2, 'Quản Trị Viên (Minh Khuyên)', 'minhkhuyen779@gmail.com', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0376131883', 1, NULL, NULL, NULL, 'ACTIVE'),
(3, 'Quản Lý Chi Nhánh Thủ Đức', 'manager@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0977777777', 2, 1, NULL, NULL, 'ACTIVE'),
(4, 'Vendor Thủ Đức (Văn Học & Truyện)', 'vendor.thuduc1@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0901111111', 3, 1, NULL, 1, 'ACTIVE'),
(5, 'Vendor Thủ Đức (SGK & Tham Khảo)', 'vendor.thuduc2@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0902222222', 3, 1, NULL, 6, 'ACTIVE'),
(6, 'Vendor Phú Nhuận (Kinh Tế)', 'vendor.phunhuan1@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0903333333', 3, 2, NULL, 3, 'ACTIVE'),
-- 4 Shipper Thủ Đức (2 Tiêu chuẩn, 2 Hỏa tốc)
(7, 'Shipper Thủ Đức (Tiêu Chuẩn 1) - Nguyễn Văn Nam', 'shipper.thuduc1@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0961111111', 4, 1, 1, NULL, 'ACTIVE'),
(10, 'Shipper Thủ Đức (Tiêu Chuẩn 2) - Lê Văn Tài', 'shipper.thuduc.tieuchuan@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0961222222', 4, 1, 1, NULL, 'ACTIVE'),
(8, 'Shipper Thủ Đức (Hỏa Tốc 1) - Trần Văn Bình', 'shipper.thuduc2@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0962222222', 4, 1, 2, NULL, 'ACTIVE'),
(11, 'Shipper Thủ Đức (Hỏa Tốc 2) - Hoàng Văn Dũng', 'shipper.thuduc.hoatoc@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0962333333', 4, 1, 2, NULL, 'ACTIVE'),
-- 2 Shipper Phú Nhuận (1 Tiêu chuẩn, 1 Hỏa tốc)
(12, 'Shipper Phú Nhuận (Tiêu Chuẩn) - Lê Hoàng Long', 'shipper.phunhuan.tieuchuan@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0964444444', 4, 2, 1, NULL, 'ACTIVE'),
(13, 'Shipper Phú Nhuận (Hỏa Tốc) - Phạm Quốc Huy', 'shipper.phunhuan.hoatoc@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0965555555', 4, 2, 2, NULL, 'ACTIVE'),
-- Khách hàng
(9, 'Khách Hàng Mẫu', 'user@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0955555555', 5, NULL, NULL, NULL, 'ACTIVE');

INSERT IGNORE INTO `users` (`full_name`, `email`, `password`, `phone`, `role_id`, `branch_id`, `shipping_provider_id`, `specialized_category_id`, `status`)
SELECT 'Quản Lý Chi Nhánh Phú Nhuận', 'manager.phunhuan@websachcu.vn',
       '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0978888888', r.`id`, b.`id`, NULL, NULL, 'ACTIVE'
FROM `roles` r
JOIN `branches` b ON b.`email` = 'phunhuan@websachcu.vn'
WHERE r.`name` = 'ROLE_MANAGER'
  AND NOT EXISTS (SELECT 1 FROM `users` WHERE `email` = 'manager.phunhuan@websachcu.vn');

-- 8. BẢNG BOOKS (Danh mục đầu sách)
CREATE TABLE IF NOT EXISTS `books` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `isbn` VARCHAR(30) DEFAULT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `category_id` BIGINT DEFAULT NULL,
  `publisher_id` BIGINT DEFAULT NULL,
  `author_id` BIGINT DEFAULT NULL,
  `publish_year` INT DEFAULT NULL,
  `language` VARCHAR(50) DEFAULT 'Tiếng Việt',
  `cover_url` VARCHAR(500) DEFAULT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_books_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_books_publisher` FOREIGN KEY (`publisher_id`) REFERENCES `publishers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_books_author` FOREIGN KEY (`author_id`) REFERENCES `authors` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `books` (`id`, `isbn`, `title`, `description`, `category_id`, `publisher_id`, `author_id`, `publish_year`, `language`, `cover_url`) VALUES
(1, '9786042078888', 'Dế Mèn Phiêu Lưu Ký', 'Tác phẩm văn học kinh điển dành cho thiếu nhi và người lớn của nhà văn Tô Hoài.', 1, 1, 1, 1985, 'Tiếng Việt', 'https://cdn1.fahasa.com/media/catalog/product/d/e/de-men-phieu-luu-ki_bia-cung_to.jpg'),
(2, '9786045612345', 'Số Đỏ (Ấn Bản Năm 1990)', 'Tiểu thuyết trào phúng kinh điển của Vũ Trọng Phụng về nhân vật Xuân Tóc Đỏ.', 2, 2, 2, 1990, 'Tiếng Việt', 'https://cdn1.fahasa.com/media/catalog/product/8/9/8935230010784_1.jpg'),
(3, '9786048991111', 'Tắt Đèn (Bản Cũ 1988)', 'Tác phẩm hiện thực xuất sắc tái hiện cuộc sống nông thôn Việt Nam trước Cách mạng.', 1, 2, 3, 1988, 'Tiếng Việt', 'https://product.hstatic.net/1000237375/product/bia_truoc_08_b4497226ce524fd79a1d81b9086b99a9_master.jpg'),
(4, '9786047722222', 'Tôi Thấy Hoa Vàng Trên Cỏ Xanh', 'Truyện dài cảm động về tuổi thơ nơi làng quê nghèo của Nguyễn Nhật Ánh.', 1, 3, 4, 2012, 'Tiếng Việt', 'https://cdn0.fahasa.com/media/catalog/product/8/9/8934974158448.jpg'),
(5, '9786046633333', 'Đắc Nhân Tâm (Bản Dịch Nguyễn Hiến Lê 1974)', 'Bản dịch kinh điển của dịch giả Nguyễn Hiến Lê trước năm 1975, bìa cứng xưa quý hiếm.', 3, 4, 5, 1974, 'Tiếng Việt', 'https://cdn1.fahasa.com/media/catalog/product/8/9/8935230006015.jpg'),
(6, '9786045544444', 'Doraemon Tập 1 (Bản In Đầu 1996)', 'Tập 1 bộ truyện tranh Doraemon bản dịch cũ mỏng giấy ngả vàng sưu tầm.', 4, 1, 1, 1996, 'Tiếng Việt', 'https://bizweb.dktcdn.net/thumb/1024x1024/100/576/749/products/1-09e4d57d2e8d45f6ae65b8936811fa81.jpg?v=1760791370697'),
(7, '9786040007777', 'Bộ Sách Giáo Khoa Lớp 12 Cũ (Đầy Đủ 12 Môn)', 'Bộ SGK lớp 12 cũ dành cho học sinh chuẩn bị ôn thi đại học và tốt nghiệp.', 6, 5, 6, 2020, 'Tiếng Việt', 'https://cdn1.fahasa.com/media/catalog/product/9/7/9786040392503.jpg'),
(8, '8935235200524', 'Nhà Giả Kim', 'Tiểu thuyết giàu tính biểu tượng về hành trình theo đuổi ước mơ và khám phá chính mình.', 1, 2, 7, 1988, 'Tiếng Việt', 'https://is1-ssl.mzstatic.com/image/thumb/Publication69/v4/10/23/8c/10238cf2-8bdb-4ad0-853b-715e5a9431d2/nha_gia_kim_paulo_coelho.png/1200x1200wz.jpg'),
(9, '9786043945674', 'Cây Cam Ngọt Của Tôi', 'Câu chuyện cảm động về tuổi thơ, tình yêu thương và hành trình trưởng thành của cậu bé Zezé.', 1, 6, 8, 2020, 'Tiếng Việt', 'https://bizweb.dktcdn.net/thumb/1024x1024/100/567/082/products/image-217480.jpg?v=1747326206683'),
(10, '9786045678906', 'Tuổi Trẻ Đáng Giá Bao Nhiêu?', 'Những chia sẻ thực tế về học tập, trải nghiệm, làm việc và cách sống trọn vẹn với tuổi trẻ.', 3, 6, 9, 2021, 'Tiếng Việt', 'https://salt.tikicdn.com/cache/750x750/ts/product/66/51/30/c2815ed03a54650766df95003ed0d809.jpg'),
(11, '9786041122336', 'Cho Tôi Xin Một Vé Đi Tuổi Thơ', 'Một chuyến tàu hóm hỉnh và trong trẻo trở về thế giới tuổi thơ của bốn người bạn nhỏ.', 1, 3, 4, 2008, 'Tiếng Việt', 'https://cdn1.fahasa.com/media/catalog/product/i/m/image_195509_1_20306.jpg'),
(12, '9786043344557', 'Mắt Biếc', 'Câu chuyện tình đầu trong trẻo, day dứt giữa Ngạn và Hà Lan tại làng Đo Đo.', 1, 3, 4, 2019, 'Tiếng Việt', 'https://www.sachkhaitri.com/Data/Sites/2/Product/65549/mat-biec-tai-ban-2019.jpg'),
(13, '9786049988773', 'Atomic Habits - Thay Đổi Tí Hon, Hiệu Quả Bất Ngờ', 'Phương pháp thực tế giúp xây dựng thói quen tốt bằng những thay đổi nhỏ nhưng bền vững.', 3, 7, 10, 2023, 'Tiếng Việt', 'https://cdn1.fahasa.com/media/catalog/product/i/m/image_195509_1_43387.jpg'),
(14, '9786047766550', 'Rừng Na Uy', 'Tiểu thuyết sâu lắng về tình yêu, tuổi trẻ, ký ức và mất mát của Haruki Murakami.', 1, 6, 11, 2024, 'Tiếng Việt', 'https://cdn1.fahasa.com/media/catalog/product/8/9/8935235245815.jpg'),
(15, '9786044455665', 'Muôn Kiếp Nhân Sinh - Tập 1', 'Những câu chuyện và chiêm nghiệm về nhân quả, luân hồi cùng cách con người lựa chọn lối sống thiện lành.', 3, 8, 12, 2020, 'Tiếng Việt', 'https://nxbhcm.com.vn/Image/Biasach/muonkiepnhansinh.png');

UPDATE `books`
SET `author_id` = (SELECT `id` FROM `authors` WHERE `name` = 'Fujiko F. Fujio' LIMIT 1)
WHERE `id` = 6 AND `isbn` = '9786045544444';

-- 9. BẢNG BOOK_COPIES (Bản sao cuốn sách thực tế trong kho chi nhánh)
CREATE TABLE IF NOT EXISTS `book_copies` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `book_id` BIGINT NOT NULL,
  `branch_id` BIGINT NOT NULL,
  `seller_id` BIGINT DEFAULT NULL,
  `condition_rating` VARCHAR(30) NOT NULL,
  `purchase_price` DOUBLE DEFAULT NULL,
  `selling_price` DOUBLE DEFAULT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `status` VARCHAR(30) NOT NULL DEFAULT 'AVAILABLE',
  `note` TEXT DEFAULT NULL,
  `image_url` VARCHAR(500) DEFAULT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_copies_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`),
  CONSTRAINT `fk_copies_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `fk_copies_seller` FOREIGN KEY (`seller_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `book_copies` (`id`, `book_id`, `branch_id`, `seller_id`, `condition_rating`, `purchase_price`, `selling_price`, `quantity`, `status`, `note`, `image_url`) VALUES
(1, 1, 1, 4, 'LIKE_NEW', 40000.0, 65000.0, 10, 'AVAILABLE', 'Bìa mới 95%, không ố vàng, trang sách đầy đủ', 'https://cdn1.fahasa.com/media/catalog/product/d/e/de-men-phieu-luu-ki_bia-cung_to.jpg'),
(2, 2, 2, 6, 'GOOD', 30000.0, 50000.0, 5, 'AVAILABLE', 'Bìa hơi sờn góc, trang hơi ngả vàng theo thời gian', 'https://cdn1.fahasa.com/media/catalog/product/8/9/8935230010784_1.jpg'),
(3, 3, 1, 4, 'VERY_GOOD', 35000.0, 55000.0, 8, 'AVAILABLE', 'Giấy giữ màu tốt, không rách gáy', 'https://product.hstatic.net/1000237375/product/bia_truoc_08_b4497226ce524fd79a1d81b9086b99a9_master.jpg'),
(4, 4, 1, 4, 'LIKE_NEW', 50000.0, 75000.0, 12, 'AVAILABLE', 'Sách như mới 98%, đẹp sạch sẽ', 'https://cdn0.fahasa.com/media/catalog/product/8/9/8934974158448.jpg'),
(5, 5, 2, 6, 'FAIR', 120000.0, 180000.0, 3, 'AVAILABLE', 'Ấn bản hiếm 1974, bìa vải ngả màu thời gian, cực kỳ giá trị', 'https://cdn1.fahasa.com/media/catalog/product/8/9/8935230006015.jpg'),
(6, 6, 1, 4, 'GOOD', 20000.0, 35000.0, 7, 'AVAILABLE', 'Truyện tranh cũ 1996, ruột sạch sẽ đủ trang', 'https://bizweb.dktcdn.net/thumb/1024x1024/100/576/749/products/1-09e4d57d2e8d45f6ae65b8936811fa81.jpg?v=1760791370697'),
(7, 7, 1, 5, 'GOOD', 45000.0, 70000.0, 15, 'AVAILABLE', 'Bộ sách giáo khoa 12 môn còn đầy đủ bìa và ruột sạch sẽ', 'https://cdn1.fahasa.com/media/catalog/product/9/7/9786040392503.jpg'),
(8, 8, 1, 4, 'VERY_GOOD', 32000.0, 52000.0, 8, 'AVAILABLE', 'Sách cũ tuyển chọn, bìa đẹp và ruột đầy đủ', 'https://is1-ssl.mzstatic.com/image/thumb/Publication69/v4/10/23/8c/10238cf2-8bdb-4ad0-853b-715e5a9431d2/nha_gia_kim_paulo_coelho.png/1200x1200wz.jpg'),
(9, 9, 1, 4, 'LIKE_NEW', 49000.0, 79000.0, 7, 'AVAILABLE', 'Sách cũ tuyển chọn, bìa đẹp và ruột đầy đủ', 'https://bizweb.dktcdn.net/thumb/1024x1024/100/567/082/products/image-217480.jpg?v=1747326206683'),
(10, 10, 2, 6, 'VERY_GOOD', 42000.0, 68000.0, 11, 'AVAILABLE', 'Sách cũ tuyển chọn, bìa đẹp và ruột đầy đủ', 'https://salt.tikicdn.com/cache/750x750/ts/product/66/51/30/c2815ed03a54650766df95003ed0d809.jpg'),
(11, 11, 1, 4, 'GOOD', 37000.0, 59000.0, 9, 'AVAILABLE', 'Sách cũ tuyển chọn, bìa đẹp và ruột đầy đủ', 'https://cdn1.fahasa.com/media/catalog/product/i/m/image_195509_1_20306.jpg'),
(12, 12, 1, 4, 'LIKE_NEW', 45000.0, 72000.0, 6, 'AVAILABLE', 'Sách cũ tuyển chọn, bìa đẹp và ruột đầy đủ', 'https://www.sachkhaitri.com/Data/Sites/2/Product/65549/mat-biec-tai-ban-2019.jpg'),
(13, 13, 2, 6, 'LIKE_NEW', 71000.0, 115000.0, 10, 'AVAILABLE', 'Sách cũ tuyển chọn, bìa đẹp và ruột đầy đủ', 'https://cdn1.fahasa.com/media/catalog/product/i/m/image_195509_1_43387.jpg'),
(14, 14, 1, 4, 'VERY_GOOD', 79000.0, 128000.0, 5, 'AVAILABLE', 'Sách cũ tuyển chọn, bìa đẹp và ruột đầy đủ', 'https://cdn1.fahasa.com/media/catalog/product/8/9/8935235245815.jpg'),
(15, 15, 2, 6, 'GOOD', 65000.0, 105000.0, 7, 'AVAILABLE', 'Sách cũ tuyển chọn, bìa đẹp và ruột đầy đủ', 'https://nxbhcm.com.vn/Image/Biasach/muonkiepnhansinh.png');

-- Đồng bộ lại ảnh bìa nếu database đã từng nạp bộ dữ liệu mẫu cũ dùng ảnh chung chung.
UPDATE `books` SET `cover_url` = CASE `isbn`
  WHEN '9786042078888' THEN 'https://cdn1.fahasa.com/media/catalog/product/d/e/de-men-phieu-luu-ki_bia-cung_to.jpg'
  WHEN '9786045612345' THEN 'https://cdn1.fahasa.com/media/catalog/product/8/9/8935230010784_1.jpg'
  WHEN '9786048991111' THEN 'https://product.hstatic.net/1000237375/product/bia_truoc_08_b4497226ce524fd79a1d81b9086b99a9_master.jpg'
  WHEN '9786047722222' THEN 'https://cdn0.fahasa.com/media/catalog/product/8/9/8934974158448.jpg'
  WHEN '9786046633333' THEN 'https://cdn1.fahasa.com/media/catalog/product/8/9/8935230006015.jpg'
  WHEN '9786045544444' THEN 'https://bizweb.dktcdn.net/thumb/1024x1024/100/576/749/products/1-09e4d57d2e8d45f6ae65b8936811fa81.jpg?v=1760791370697'
  WHEN '9786040007777' THEN 'https://cdn1.fahasa.com/media/catalog/product/9/7/9786040392503.jpg'
  ELSE `cover_url`
END
WHERE `id` > 0
  AND `isbn` IN ('9786042078888', '9786045612345', '9786048991111', '9786047722222',
                 '9786046633333', '9786045544444', '9786040007777');

UPDATE `book_copies` bc
JOIN `books` b ON b.`id` = bc.`book_id`
SET bc.`image_url` = b.`cover_url`
WHERE bc.`id` > 0
  AND b.`isbn` IN ('9786042078888', '9786045612345', '9786048991111', '9786047722222',
                   '9786046633333', '9786045544444', '9786040007777')
  AND (bc.`image_url` IS NULL OR bc.`image_url` = '' OR bc.`image_url` LIKE '%images.unsplash.com%');

-- 10. BẢNG PROMOTIONS (Khuyến mãi)
CREATE TABLE IF NOT EXISTS `promotions` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(50) DEFAULT NULL,
  `title` VARCHAR(150) NOT NULL,
  `discount_percent` DOUBLE NOT NULL,
  `max_discount_amount` DOUBLE DEFAULT NULL,
  `min_order_value` DOUBLE DEFAULT NULL,
  `start_date` DATE DEFAULT NULL,
  `end_date` DATE DEFAULT NULL,
  `type` VARCHAR(30) DEFAULT 'PRODUCT_PERCENT',
  `active` BIT(1) DEFAULT b'1',
  `branch_id` BIGINT DEFAULT NULL,
  `vendor_id` BIGINT DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_promotions_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_promotions_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. BẢNG ORDERS (Đơn hàng mua bán)
CREATE TABLE IF NOT EXISTS `orders` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `order_code` VARCHAR(50) NOT NULL UNIQUE,
  `customer_id` BIGINT NOT NULL,
  `branch_id` BIGINT NOT NULL,
  `shipping_provider_id` BIGINT DEFAULT NULL,
  `receiver_name` VARCHAR(100) NOT NULL,
  `receiver_phone` VARCHAR(20) NOT NULL,
  `shipping_address` VARCHAR(255) NOT NULL,
  `total_amount` DOUBLE NOT NULL,
  `shipping_fee` DOUBLE NOT NULL DEFAULT 0.0,
  `discount_amount` DOUBLE DEFAULT 0.0,
  `app_commission_amount` DOUBLE DEFAULT 0.0,
  `final_amount` DOUBLE NOT NULL,
  `payment_method` VARCHAR(30) NOT NULL DEFAULT 'COD',
  `payment_status` VARCHAR(30) NOT NULL DEFAULT 'PENDING',
  `payment_submitted_at` DATETIME DEFAULT NULL,
  `payment_confirmed_at` DATETIME DEFAULT NULL,
  `payment_confirmed_by` VARCHAR(255) DEFAULT NULL,
  `manager_archived` TINYINT(1) NOT NULL DEFAULT 0,
  `order_status` VARCHAR(30) NOT NULL DEFAULT 'NEW',
  `return_method` VARCHAR(20) DEFAULT NULL,
  `return_shipping_fee` DOUBLE DEFAULT NULL,
  `return_address` VARCHAR(255) DEFAULT NULL,
  `return_reason` VARCHAR(500) DEFAULT NULL,
  `refund_amount` DOUBLE DEFAULT NULL,
  `note` TEXT DEFAULT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_orders_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `fk_orders_shipping_provider` FOREIGN KEY (`shipping_provider_id`) REFERENCES `shipping_providers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. BẢNG ORDER_ITEMS (Chi tiết đơn hàng)
CREATE TABLE IF NOT EXISTS `order_items` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `order_id` BIGINT NOT NULL,
  `book_copy_id` BIGINT NOT NULL,
  `quantity` INT NOT NULL,
  `price` DOUBLE NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_items_copy` FOREIGN KEY (`book_copy_id`) REFERENCES `book_copies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 13. BẢNG DELIVERY_ASSIGNMENTS (Phân công giao hàng / thu hồi đổi trả)
CREATE TABLE IF NOT EXISTS `delivery_assignments` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `order_id` BIGINT DEFAULT NULL,
  `sell_request_id` BIGINT DEFAULT NULL,
  `shipper_id` BIGINT DEFAULT NULL,
  `assigned_by` BIGINT DEFAULT NULL,
  `status` VARCHAR(30) NOT NULL,
  `note` TEXT DEFAULT NULL,
  `tracking_code` VARCHAR(100) DEFAULT NULL,
  `rejected_shipper_ids` VARCHAR(255) DEFAULT NULL,
  `failure_reason` VARCHAR(500) DEFAULT NULL,
  `assigned_at` DATETIME(6) DEFAULT NULL,
  `picked_up_at` DATETIME(6) DEFAULT NULL,
  `delivered_at` DATETIME(6) DEFAULT NULL,
  `completed_at` DATETIME(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_assignment_order` (`order_id`),
  UNIQUE KEY `uk_assignment_sell_request` (`sell_request_id`),
  CONSTRAINT `fk_assignment_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_assignment_shipper` FOREIGN KEY (`shipper_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_assignment_assigned_by` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 14. BẢNG SELL_REQUESTS (Yêu cầu thu mua sách cũ tận nhà)
CREATE TABLE IF NOT EXISTS `sell_requests` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `branch_id` BIGINT DEFAULT NULL,
  `buyer_vendor_id` BIGINT DEFAULT NULL,
  `status` VARCHAR(30) NOT NULL,
  `expected_total` DOUBLE DEFAULT NULL,
  `offered_total` DOUBLE DEFAULT NULL,
  `note` TEXT DEFAULT NULL,
  `staff_note` TEXT DEFAULT NULL,
  `created_at` DATETIME(6) DEFAULT NULL,
  `updated_at` DATETIME(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_sell_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_sell_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 15. BẢNG SELL_REQUEST_ITEMS (Chi tiết sách cần bán thu mua)
CREATE TABLE IF NOT EXISTS `sell_request_items` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `sell_request_id` BIGINT NOT NULL,
  `book_id` BIGINT DEFAULT NULL,
  `book_title` VARCHAR(255) NOT NULL,
  `isbn` VARCHAR(30) DEFAULT NULL,
  `condition_description` TEXT NOT NULL,
  `expected_price` DOUBLE DEFAULT NULL,
  `offered_price` DOUBLE DEFAULT NULL,
  `image_url` VARCHAR(500) DEFAULT NULL,
  `staff_note` TEXT DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_item_sell_request` FOREIGN KEY (`sell_request_id`) REFERENCES `sell_requests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_item_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 16. BẢNG SELL_REQUEST_QUOTES (Báo giá thẩm định thu mua độc lập của từng vendor)
CREATE TABLE IF NOT EXISTS `sell_request_quotes` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `sell_request_id` BIGINT NOT NULL,
  `vendor_id` BIGINT NOT NULL,
  `branch_id` BIGINT DEFAULT NULL,
  `offered_price` DOUBLE NOT NULL,
  `note` TEXT DEFAULT NULL,
  `status` VARCHAR(30) NOT NULL,
  `created_at` DATETIME(6) DEFAULT NULL,
  `updated_at` DATETIME(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_quote_sell_request` FOREIGN KEY (`sell_request_id`) REFERENCES `sell_requests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_quote_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_quote_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 17. HỘI THOẠI HỖ TRỢ KHÁCH HÀNG THEO CHI NHÁNH
CREATE TABLE IF NOT EXISTS `support_conversations` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `public_token` VARCHAR(36) NOT NULL UNIQUE,
  `customer_name` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(20) NOT NULL,
  `branch_id` BIGINT NOT NULL,
  `manager_unread` BIT(1) NOT NULL DEFAULT b'1',
  `last_message_at` DATETIME(6) DEFAULT NULL,
  `created_at` DATETIME(6) DEFAULT NULL,
  `updated_at` DATETIME(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_support_conversation_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 18. NỘI DUNG TIN NHẮN HỖ TRỢ
CREATE TABLE IF NOT EXISTS `support_messages` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `conversation_id` BIGINT NOT NULL,
  `sender_type` VARCHAR(20) NOT NULL,
  `sender_name` VARCHAR(100) NOT NULL,
  `content` TEXT NOT NULL,
  `created_at` DATETIME(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_support_message_conversation` FOREIGN KEY (`conversation_id`)
    REFERENCES `support_conversations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 19. BẢNG ĐỊA CHỈ NHẬN HÀNG
CREATE TABLE IF NOT EXISTS `addresses` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `recipient_name` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(20) NOT NULL,
  `street` VARCHAR(255) NOT NULL,
  `ward` VARCHAR(100) DEFAULT NULL,
  `district` VARCHAR(100) DEFAULT NULL,
  `city` VARCHAR(100) NOT NULL,
  `is_default` BIT(1) DEFAULT b'0',
  `created_at` DATETIME(6) DEFAULT NULL,
  `updated_at` DATETIME(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_addresses_user` (`user_id`),
  CONSTRAINT `fk_addresses_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 20. BẢNG MÃ GIẢM GIÁ TOÀN ỨNG DỤNG
CREATE TABLE IF NOT EXISTS `app_discounts` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(50) NOT NULL,
  `discount_percent` DOUBLE DEFAULT NULL,
  `max_discount_amount` DOUBLE DEFAULT NULL,
  `min_order_value` DOUBLE DEFAULT NULL,
  `start_date` DATE DEFAULT NULL,
  `end_date` DATE DEFAULT NULL,
  `active` BIT(1) DEFAULT b'1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_app_discounts_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 21. BẢNG GIỎ HÀNG LƯU TRÊN DATABASE
CREATE TABLE IF NOT EXISTS `cart_items` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `book_copy_id` BIGINT NOT NULL,
  `quantity` INT NOT NULL DEFAULT 1,
  `created_at` DATETIME(6) DEFAULT NULL,
  `updated_at` DATETIME(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_cart_items_user` (`user_id`),
  KEY `idx_cart_items_book_copy` (`book_copy_id`),
  CONSTRAINT `fk_cart_items_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_cart_items_book_copy` FOREIGN KEY (`book_copy_id`) REFERENCES `book_copies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 22. BẢNG SÁCH YÊU THÍCH
CREATE TABLE IF NOT EXISTS `favorites` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `book_id` BIGINT NOT NULL,
  `created_at` DATETIME(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_favorites_user_book` (`user_id`, `book_id`),
  KEY `idx_favorites_book` (`book_id`),
  CONSTRAINT `fk_favorites_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_favorites_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 23. BẢNG OTP ĐĂNG KÝ / ĐẶT LẠI MẬT KHẨU (CHỈ LƯU MÃ ĐÃ HASH)
CREATE TABLE IF NOT EXISTS `otp_tokens` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(150) NOT NULL,
  `otp_code` VARCHAR(100) NOT NULL,
  `expiry_time` DATETIME(6) NOT NULL,
  `used` BIT(1) NOT NULL DEFAULT b'0',
  `type` VARCHAR(30) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_otp_tokens_email_type` (`email`, `type`),
  KEY `idx_otp_tokens_expiry` (`expiry_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 24. BẢNG ĐÁNH GIÁ SÁCH
CREATE TABLE IF NOT EXISTS `reviews` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `book_id` BIGINT NOT NULL,
  `order_item_id` BIGINT DEFAULT NULL,
  `rating` INT NOT NULL,
  `comment` TEXT NOT NULL,
  `image_url` VARCHAR(500) DEFAULT NULL,
  `created_at` DATETIME(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_reviews_order_item` (`order_item_id`),
  KEY `idx_reviews_book` (`book_id`),
  KEY `idx_reviews_user` (`user_id`),
  CONSTRAINT `fk_reviews_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_reviews_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`),
  CONSTRAINT `fk_reviews_order_item` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 25. BẢNG ĐIỀU CHUYỂN SÁCH GIỮA CÁC CHI NHÁNH
CREATE TABLE IF NOT EXISTS `stock_transfers` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `transfer_code` VARCHAR(50) NOT NULL,
  `from_branch_id` BIGINT NOT NULL,
  `to_branch_id` BIGINT NOT NULL,
  `book_copy_id` BIGINT NOT NULL,
  `quantity` INT NOT NULL,
  `status` VARCHAR(30) NOT NULL,
  `requested_by` BIGINT DEFAULT NULL,
  `approved_by` BIGINT DEFAULT NULL,
  `note` TEXT DEFAULT NULL,
  `created_at` DATETIME(6) DEFAULT NULL,
  `updated_at` DATETIME(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_stock_transfers_code` (`transfer_code`),
  KEY `idx_stock_transfers_from_branch` (`from_branch_id`),
  KEY `idx_stock_transfers_to_branch` (`to_branch_id`),
  KEY `idx_stock_transfers_book_copy` (`book_copy_id`),
  CONSTRAINT `fk_stock_transfers_from_branch` FOREIGN KEY (`from_branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `fk_stock_transfers_to_branch` FOREIGN KEY (`to_branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `fk_stock_transfers_book_copy` FOREIGN KEY (`book_copy_id`) REFERENCES `book_copies` (`id`),
  CONSTRAINT `fk_stock_transfers_requested_by` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_stock_transfers_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 26. BẢNG HỘI THOẠI KHÁCH HÀNG - VENDOR
CREATE TABLE IF NOT EXISTS `vendor_conversations` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `customer_id` BIGINT NOT NULL,
  `vendor_id` BIGINT NOT NULL,
  `book_copy_id` BIGINT DEFAULT NULL,
  `last_message` TEXT DEFAULT NULL,
  `last_message_at` DATETIME(6) DEFAULT NULL,
  `customer_unread` BIT(1) NOT NULL DEFAULT b'0',
  `vendor_unread` BIT(1) NOT NULL DEFAULT b'0',
  `created_at` DATETIME(6) DEFAULT NULL,
  `updated_at` DATETIME(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_vendor_conversations_customer` (`customer_id`),
  KEY `idx_vendor_conversations_vendor` (`vendor_id`),
  KEY `idx_vendor_conversations_book_copy` (`book_copy_id`),
  CONSTRAINT `fk_vendor_conversations_customer` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_vendor_conversations_vendor` FOREIGN KEY (`vendor_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_vendor_conversations_book_copy` FOREIGN KEY (`book_copy_id`) REFERENCES `book_copies` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 27. BẢNG TIN NHẮN KHÁCH HÀNG - VENDOR
CREATE TABLE IF NOT EXISTS `vendor_messages` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `conversation_id` BIGINT NOT NULL,
  `sender_id` BIGINT NOT NULL,
  `content` TEXT NOT NULL,
  `book_copy_id` BIGINT DEFAULT NULL,
  `is_read` BIT(1) DEFAULT b'0',
  `created_at` DATETIME(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_vendor_messages_conversation` (`conversation_id`),
  KEY `idx_vendor_messages_sender` (`sender_id`),
  CONSTRAINT `fk_vendor_messages_conversation` FOREIGN KEY (`conversation_id`) REFERENCES `vendor_conversations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_vendor_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_vendor_messages_book_copy` FOREIGN KEY (`book_copy_id`) REFERENCES `book_copies` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 28. BẢNG LỊCH SỬ SÁCH ĐÃ XEM
CREATE TABLE IF NOT EXISTS `viewed_products` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `book_id` BIGINT NOT NULL,
  `viewed_at` DATETIME(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_viewed_products_user` (`user_id`),
  KEY `idx_viewed_products_book` (`book_id`),
  CONSTRAINT `fk_viewed_products_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_viewed_products_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đồng bộ an toàn các database đã import phiên bản SQL cũ.
-- Các câu lệnh chỉ thêm cột còn thiếu hoặc mở rộng kiểu dữ liệu; không xóa bảng/dữ liệu.
DELIMITER $$
DROP PROCEDURE IF EXISTS `sync_web_sach_entity_schema`$$
CREATE PROCEDURE `sync_web_sach_entity_schema`()
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'authors' AND COLUMN_NAME = 'birth_year') THEN
    ALTER TABLE `authors` ADD COLUMN `birth_year` INT DEFAULT NULL;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'publishers' AND COLUMN_NAME = 'phone') THEN
    ALTER TABLE `publishers` ADD COLUMN `phone` VARCHAR(20) DEFAULT NULL;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'publishers' AND COLUMN_NAME = 'active') THEN
    ALTER TABLE `publishers` ADD COLUMN `active` BIT(1) NOT NULL DEFAULT b'1';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'branches' AND COLUMN_NAME = 'description') THEN
    ALTER TABLE `branches` ADD COLUMN `description` TEXT DEFAULT NULL AFTER `name`;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'branches' AND COLUMN_NAME = 'image_url') THEN
    ALTER TABLE `branches` ADD COLUMN `image_url` VARCHAR(500) DEFAULT NULL AFTER `email`;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'branches' AND COLUMN_NAME = 'cover_url') THEN
    ALTER TABLE `branches` ADD COLUMN `cover_url` VARCHAR(500) DEFAULT NULL AFTER `image_url`;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'promotions' AND COLUMN_NAME = 'code') THEN
    ALTER TABLE `promotions` ADD COLUMN `code` VARCHAR(50) DEFAULT NULL AFTER `id`;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'delivery_assignments' AND COLUMN_NAME = 'sell_request_id') THEN
    ALTER TABLE `delivery_assignments` ADD COLUMN `sell_request_id` BIGINT DEFAULT NULL AFTER `order_id`;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sell_requests' AND COLUMN_NAME = 'buyer_vendor_id') THEN
    ALTER TABLE `sell_requests` ADD COLUMN `buyer_vendor_id` BIGINT DEFAULT NULL AFTER `branch_id`;
  END IF;

  ALTER TABLE `users`
    MODIFY COLUMN `email` VARCHAR(150) NOT NULL,
    MODIFY COLUMN `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE';
  ALTER TABLE `branches`
    MODIFY COLUMN `phone` VARCHAR(20) DEFAULT NULL,
    MODIFY COLUMN `email` VARCHAR(150) DEFAULT NULL,
    MODIFY COLUMN `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE';
  ALTER TABLE `shipping_providers`
    MODIFY COLUMN `estimated_days` VARCHAR(100) DEFAULT '2-3 ngày',
    MODIFY COLUMN `service_type` VARCHAR(100) DEFAULT 'IN_PROVINCE';
  ALTER TABLE `promotions`
    MODIFY COLUMN `discount_percent` DOUBLE NOT NULL,
    MODIFY COLUMN `type` VARCHAR(30) DEFAULT 'PRODUCT_PERCENT';
  ALTER TABLE `delivery_assignments`
    MODIFY COLUMN `order_id` BIGINT DEFAULT NULL,
    MODIFY COLUMN `status` VARCHAR(30) NOT NULL;
  ALTER TABLE `sell_requests`
    MODIFY COLUMN `branch_id` BIGINT DEFAULT NULL,
    MODIFY COLUMN `status` VARCHAR(30) NOT NULL;

  IF NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'branches' AND COLUMN_NAME = 'vendor_id'
        AND SEQ_IN_INDEX = 1 AND NON_UNIQUE = 0) THEN
    ALTER TABLE `branches` ADD UNIQUE KEY `uk_branches_vendor` (`vendor_id`);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'branches' AND COLUMN_NAME = 'vendor_id'
        AND REFERENCED_TABLE_NAME = 'users' AND REFERENCED_COLUMN_NAME = 'id') THEN
    ALTER TABLE `branches` ADD CONSTRAINT `fk_branches_vendor`
      FOREIGN KEY (`vendor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.STATISTICS
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'delivery_assignments' AND COLUMN_NAME = 'sell_request_id'
        AND SEQ_IN_INDEX = 1 AND NON_UNIQUE = 0) THEN
    ALTER TABLE `delivery_assignments` ADD UNIQUE KEY `uk_assignment_sell_request` (`sell_request_id`);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'delivery_assignments' AND COLUMN_NAME = 'sell_request_id'
        AND REFERENCED_TABLE_NAME = 'sell_requests' AND REFERENCED_COLUMN_NAME = 'id') THEN
    ALTER TABLE `delivery_assignments` ADD CONSTRAINT `fk_assignment_sell_request`
      FOREIGN KEY (`sell_request_id`) REFERENCES `sell_requests` (`id`) ON DELETE CASCADE;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.KEY_COLUMN_USAGE
      WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'sell_requests' AND COLUMN_NAME = 'buyer_vendor_id'
        AND REFERENCED_TABLE_NAME = 'users' AND REFERENCED_COLUMN_NAME = 'id') THEN
    ALTER TABLE `sell_requests` ADD CONSTRAINT `fk_sell_buyer_vendor`
      FOREIGN KEY (`buyer_vendor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
  END IF;
END$$
DELIMITER ;

CALL `sync_web_sach_entity_schema`();
DROP PROCEDURE `sync_web_sach_entity_schema`;

-- 29. DOANH SỐ MẪU CHO TRANG GUEST
-- Đơn DEMO-SOLD-001 trước đây vừa ghi DELIVERED vừa chưa có phân công Shipper.
-- Xóa đơn mẫu và các dữ liệu phụ thuộc để không làm sai danh sách đơn hàng.
DELETE r FROM `reviews` r
JOIN `order_items` oi ON oi.`id` = r.`order_item_id`
JOIN `orders` o ON o.`id` = oi.`order_id`
WHERE o.`order_code` = 'DEMO-SOLD-001';
DELETE da FROM `delivery_assignments` da
JOIN `orders` o ON o.`id` = da.`order_id`
WHERE o.`order_code` = 'DEMO-SOLD-001';
DELETE oi FROM `order_items` oi
JOIN `orders` o ON o.`id` = oi.`order_id`
WHERE o.`order_code` = 'DEMO-SOLD-001';
DELETE FROM `orders` WHERE `order_code` = 'DEMO-SOLD-001';

INSERT INTO `orders` (
  `order_code`, `customer_id`, `branch_id`, `receiver_name`, `receiver_phone`,
  `shipping_address`, `total_amount`, `shipping_fee`, `discount_amount`,
  `app_commission_amount`, `final_amount`, `payment_method`, `payment_status`,
  `order_status`, `note`, `created_at`, `updated_at`
)
SELECT 'DEMO-SOLD-002', 9, 1, 'Khách Hàng Mẫu', '0955555555',
       '01 Võ Văn Ngân, TP. Thủ Đức, TP.HCM', 1050000, 0, 0,
       105000, 1050000, 'COD', 'PAID', 'DELIVERED',
       'Đơn lịch sử mẫu dùng minh họa doanh số trên trang Guest.',
       DATE_SUB(NOW(), INTERVAL 25 DAY), DATE_SUB(NOW(), INTERVAL 23 DAY)
WHERE NOT EXISTS (SELECT 1 FROM `orders` WHERE `order_code` = 'DEMO-SOLD-002');

INSERT INTO `orders` (
  `order_code`, `customer_id`, `branch_id`, `receiver_name`, `receiver_phone`,
  `shipping_address`, `total_amount`, `shipping_fee`, `discount_amount`,
  `app_commission_amount`, `final_amount`, `payment_method`, `payment_status`,
  `order_status`, `note`, `created_at`, `updated_at`
)
SELECT 'DEMO-SOLD-003', 9, 1, 'Khách Hàng Mẫu', '0955555555',
       '01 Võ Văn Ngân, TP. Thủ Đức, TP.HCM', 840000, 0, 0,
       84000, 840000, 'COD', 'PAID', 'DELIVERED',
       'Đơn lịch sử mẫu dùng minh họa doanh số trên trang Guest.',
       DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 18 DAY)
WHERE NOT EXISTS (SELECT 1 FROM `orders` WHERE `order_code` = 'DEMO-SOLD-003');

INSERT INTO `order_items` (`order_id`, `book_copy_id`, `quantity`, `price`)
SELECT o.`id`, 4, 14, 75000
FROM `orders` o
WHERE o.`order_code` = 'DEMO-SOLD-002'
  AND NOT EXISTS (
    SELECT 1 FROM `order_items` oi
    WHERE oi.`order_id` = o.`id` AND oi.`book_copy_id` = 4
  );

INSERT INTO `order_items` (`order_id`, `book_copy_id`, `quantity`, `price`)
SELECT o.`id`, 7, 12, 70000
FROM `orders` o
WHERE o.`order_code` = 'DEMO-SOLD-003'
  AND NOT EXISTS (
    SELECT 1 FROM `order_items` oi
    WHERE oi.`order_id` = o.`id` AND oi.`book_copy_id` = 7
  );

SET FOREIGN_KEY_CHECKS = 1;
