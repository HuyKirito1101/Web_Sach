-- ===================================================================
-- SCRIPT TẠO DATABASE VÀ DỮ LIỆU MẪU CHO HỆ THỐNG QUẢN LÝ CHUỖI SÁCH CŨ
-- Database: MySQL 8.x
-- ===================================================================

CREATE DATABASE IF NOT EXISTS `web_sach_cu` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `web_sach_cu`;

-- Vô hiệu hóa kiểm tra khóa ngoại để thực hiện DROP & CREATE TABLE không bị lỗi constraint 3730
SET FOREIGN_KEY_CHECKS = 0;

-- -------------------------------------------------------------------
-- 1. BẢNG ROLES (Quyền hạn)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(30) NOT NULL UNIQUE,
  `description` VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `roles` (`id`, `name`, `description`) VALUES
(1, 'ROLE_ADMIN', 'Quản trị viên toàn hệ thống chuỗi cửa hàng'),
(2, 'ROLE_MANAGER', 'Quản lý chi nhánh cửa hàng sách'),
(3, 'ROLE_VENDOR', 'Chủ gian hàng / Đối tác bán sách tại chi nhánh'),
(4, 'ROLE_SHIPPER', 'Nhân viên giao hàng của chi nhánh / đơn vị vận chuyển'),
(5, 'ROLE_USER', 'Khách hàng mua bán sách cũ');

-- -------------------------------------------------------------------
-- 2. BẢNG CATEGORIES (Danh mục sách)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `slug` VARCHAR(150) NOT NULL UNIQUE,
  `description` TEXT DEFAULT NULL,
  `active` BIT(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `categories` (`id`, `name`, `slug`, `description`, `active`) VALUES
(1, 'Văn Học Việt Nam', 'van-hoc-viet-nam', 'Các tác phẩm văn học nổi tiếng trong nước qua các thời kỳ', b'1'),
(2, 'Sách Trước 1975', 'sach-truoc-1975', 'Các ấn bản sách cũ, tài liệu quý hiếm phát hành trước 1975', b'1'),
(3, 'Kinh Tế - Kỹ Năng', 'kinh-te-ky-nang', 'Sách quản trị kinh doanh, tài chính và phát triển bản thân', b'1'),
(4, 'Truyện Tranh & Manga Cũ', 'truyen-tranh-manga', 'Bộ truyện tranh sưu tầm ngả màu thời gian', b'1'),
(5, 'Giáo Trình & Ngoại Ngữ', 'giao-trinh-ngoai-ngu', 'Giáo trình đại học và tài liệu luyện thi ngoại ngữ', b'1'),
(6, 'Sách Giáo Khoa & Tham Khảo', 'sgk-tham-khao', 'Bộ sách giáo khoa 1-12 và sách luyện thi cũ', b'1');

-- -------------------------------------------------------------------
-- 3. BẢNG AUTHORS (Tác giả) & PUBLISHERS (Nhà xuất bản)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `authors`;
CREATE TABLE `authors` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `bio` TEXT DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `authors` (`id`, `name`, `bio`) VALUES
(1, 'Tô Hoài', 'Nhà văn lớn của văn học hiện đại Việt Nam'),
(2, 'Vũ Trọng Phụng', 'Ông vua văn xuôi trào phúng Việt Nam'),
(3, 'Ngô Tất Tố', 'Nhà văn, nhà báo, nhà nghiên cứu văn hóa nổi tiếng'),
(4, 'Nguyễn Nhật Ánh', 'Tác giả của nhiều tựa sách tuổi học trò được yêu thích'),
(5, 'Dale Carnegie', 'Tác giả hàng đầu thế giới về Đắc Nhân Tâm và giao tiếp'),
(6, 'Bộ Giáo Dục & Đào Tạo', 'Tác giả biên soạn bộ SGK phổ thông');

DROP TABLE IF EXISTS `publishers`;
CREATE TABLE `publishers` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `address` VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `publishers` (`id`, `name`, `address`) VALUES
(1, 'NXB Kim Đồng', 'Hà Nội'),
(2, 'NXB Văn Học', 'Hà Nội'),
(3, 'NXB Trẻ', 'TP.HCM'),
(4, 'NXB Cổ Phong (Trước 1975)', 'Sài Gòn'),
(5, 'NXB Giáo Dục Việt Nam', 'Hà Nội');

-- -------------------------------------------------------------------
-- 4. BẢNG BRANCHES (Chi nhánh cửa hàng)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `branches`;
CREATE TABLE `branches` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `address` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `email` VARCHAR(150) DEFAULT NULL,
  `image_url` VARCHAR(500) DEFAULT NULL,
  `cover_url` VARCHAR(500) DEFAULT NULL,
  `vendor_id` BIGINT DEFAULT NULL UNIQUE,
  `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  `app_discount_percent` DOUBLE DEFAULT 10.0,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `branches` (`id`, `name`, `description`, `address`, `phone`, `email`, `status`, `app_discount_percent`) VALUES
(1, 'Sách Cũ Chi Nhánh Thủ Đức', 'Cửa hàng chuyên sách cũ, sách xưa và các ấn bản đã qua sử dụng.', '01 Võ Văn Ngân, TP. Thủ Đức, TP.HCM', '0376131883', 'thuduc@websachcu.vn', 'ACTIVE', 10.0),
(2, 'Sách Cũ Chi Nhánh Phú Nhuận', 'Chi nhánh trung tâm chuyên sách ngoại văn, giáo trình và truyện tranh hiếm.', '205 Trần Huy Liệu, P.8, Q. Phú Nhuận, TP.HCM', '0907654321', 'phunhuan@websachcu.vn', 'ACTIVE', 12.0);

-- -------------------------------------------------------------------
-- 5. BẢNG SHIPPING_PROVIDERS (Đơn vị vận chuyển)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `shipping_providers`;
CREATE TABLE `shipping_providers` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(150) NOT NULL,
  `code` VARCHAR(50) NOT NULL UNIQUE,
  `service_type` VARCHAR(100) DEFAULT NULL,
  `estimated_days` VARCHAR(50) DEFAULT NULL,
  `scope_description` VARCHAR(255) DEFAULT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `base_fee` DOUBLE NOT NULL DEFAULT 20000.0,
  `active` BIT(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `shipping_providers` (`id`, `name`, `code`, `service_type`, `estimated_days`, `scope_description`, `phone`, `base_fee`, `active`) VALUES
(1, 'Giao Hàng Nhanh (GHN) - Tiêu Chuẩn', 'GHN_STANDARD', 'Trong tỉnh (Tiêu chuẩn)', '1 - 2 ngày', 'Vận chuyển đơn mua trong tỉnh / nội thành', '19006789', 20000.0, b'1'),
(2, 'Giao Hàng Nhanh (GHN) - Hỏa Tốc', 'GHN_EXPRESS', 'Trong tỉnh (Hỏa tốc)', '2 - 4 giờ', 'Giao gấp nhận ngay trong ngày cho đơn nội tỉnh', '19006789', 40000.0, b'1'),
(3, 'SPX Express (Shopee Xpress)', 'SPX_EXPRESS', 'Ngoại tỉnh (Liên tỉnh)', '2 - 4 ngày', 'Chuyên vận chuyển các đơn giao ngoài tỉnh toàn quốc', '19001221', 32000.0, b'1');

-- -------------------------------------------------------------------
-- 6. BẢNG USERS (Tài khoản người dùng)
-- Mật khẩu mặc định của tất cả tài khoản mẫu là: 123456
-- (Mã hóa BCrypt: $2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `full_name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(150) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `avatar_url` VARCHAR(500) DEFAULT NULL,
  `role_id` BIGINT NOT NULL,
  `branch_id` BIGINT DEFAULT NULL,
  `shipping_provider_id` BIGINT DEFAULT NULL,
  `specialized_category_id` BIGINT DEFAULT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_users_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  CONSTRAINT `fk_users_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_users_shipping_provider` FOREIGN KEY (`shipping_provider_id`) REFERENCES `shipping_providers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_users_specialized_category` FOREIGN KEY (`specialized_category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `users` (`id`, `full_name`, `email`, `password`, `phone`, `role_id`, `branch_id`, `shipping_provider_id`, `specialized_category_id`, `status`) VALUES
(1, 'Quản Trị Viên Admin', 'admin@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0376131883', 1, NULL, NULL, NULL, 'ACTIVE'),
(2, 'Quản Trị Viên (Minh Khuyên)', 'minhkhuyen779@gmail.com', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0376131883', 1, NULL, NULL, NULL, 'ACTIVE'),
(3, 'Quản Lý Chi Nhánh Thủ Đức', 'manager@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0977777777', 2, 1, NULL, NULL, 'ACTIVE'),
(4, 'Vendor Thủ Đức (Văn Học & Truyện)', 'vendor.thuduc1@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0901111111', 3, 1, NULL, 1, 'ACTIVE'),
(5, 'Vendor Thủ Đức (SGK & Tham Khảo)', 'vendor.thuduc2@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0902222222', 3, 1, NULL, 6, 'ACTIVE'),
(6, 'Vendor Phú Nhuận (Kinh Tế)', 'vendor.phunhuan1@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0903333333', 3, 2, NULL, 3, 'ACTIVE'),
(7, 'Shipper Thủ Đức (GHN Tiêu Chuẩn)', 'shipper.thuduc1@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0961111111', 4, 1, 1, NULL, 'ACTIVE'),
(8, 'Shipper Thủ Đức (GHN Hỏa Tốc)', 'shipper.thuduc2@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0962222222', 4, 1, 2, NULL, 'ACTIVE'),
(9, 'Khách Hàng Nguyễn Văn A', 'user@websachcu.vn', '$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.', '0955555555', 5, NULL, NULL, NULL, 'ACTIVE');

-- Cập nhật vendor_id chủ sở hữu chi nhánh
UPDATE `branches` SET `vendor_id` = 4 WHERE `id` = 1;
UPDATE `branches` SET `vendor_id` = 6 WHERE `id` = 2;

-- -------------------------------------------------------------------
-- 7. BẢNG BOOKS (Danh mục đầu sách)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `books`;
CREATE TABLE `books` (
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

INSERT INTO `books` (`id`, `isbn`, `title`, `description`, `category_id`, `publisher_id`, `author_id`, `publish_year`, `language`, `cover_url`) VALUES
(1, '9786042078888', 'Dế Mèn Phiêu Lưu Ký', 'Tác phẩm văn học kinh điển dành cho thiếu nhi và người lớn của nhà văn Tô Hoài.', 1, 1, 1, 1985, 'Tiếng Việt', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500&q=80'),
(2, '9786045612345', 'Số Đỏ (Ấn Bản Năm 1990)', 'Tiểu thuyết trào phúng kinh điển của Vũ Trọng Phụng về nhân vật Xuân Tóc Đỏ.', 2, 2, 2, 1990, 'Tiếng Việt', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500&q=80'),
(3, '9786048991111', 'Tắt Đèn (Bản Cũ 1988)', 'Tác phẩm hiện thực xuất sắc tái hiện cuộc sống nông thôn Việt Nam trước Cách mạng.', 1, 2, 3, 1988, 'Tiếng Việt', 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=500&q=80'),
(4, '9786047722222', 'Tôi Thấy Hoa Vàng Trên Cỏ Xanh', 'Truyện dài cảm động về tuổi thơ nơi làng quê nghèo của Nguyễn Nhật Ánh.', 1, 3, 4, 2012, 'Tiếng Việt', 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=500&q=80'),
(5, '9786046633333', 'Đắc Nhân Tâm (Bản Dịch Nguyễn Hiến Lê 1974)', 'Bản dịch kinh điển của dịch giả Nguyễn Hiến Lê trước năm 1975, bìa cứng xưa quý hiếm.', 3, 4, 5, 1974, 'Tiếng Việt', 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=500&q=80'),
(6, '9786045544444', 'Doraemon Tập 1 (Bản In Đầu 1996)', 'Tập 1 bộ truyện tranh Doraemon bản dịch cũ mỏng giấy ngả vàng sưu tầm.', 4, 1, 1, 1996, 'Tiếng Việt', 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=500&q=80'),
(7, '9786040007777', 'Bộ Sách Giáo Khoa Lớp 12 Cũ (Đầy Đủ 12 Môn)', 'Bộ SGK lớp 12 cũ dành cho học sinh chuẩn bị ôn thi đại học và tốt nghiệp.', 6, 5, 6, 2020, 'Tiếng Việt', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500&q=80');

-- -------------------------------------------------------------------
-- 8. BẢNG BOOK_COPIES (Bản sao cuốn sách thực tế trong kho chi nhánh)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `book_copies`;
CREATE TABLE `book_copies` (
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

INSERT INTO `book_copies` (`id`, `book_id`, `branch_id`, `seller_id`, `condition_rating`, `purchase_price`, `selling_price`, `quantity`, `status`, `note`, `image_url`) VALUES
(1, 1, 1, 4, 'LIKE_NEW', 40000.0, 65000.0, 10, 'AVAILABLE', 'Bìa mới 95%, không ố vàng, trang sách đầy đủ', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500&q=80'),
(2, 2, 2, 6, 'GOOD', 30000.0, 50000.0, 5, 'AVAILABLE', 'Bìa hơi sờn góc, trang hơi ngả vàng theo thời gian', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500&q=80'),
(3, 3, 1, 4, 'VERY_GOOD', 35000.0, 55000.0, 8, 'AVAILABLE', 'Giấy giữ màu tốt, không rách gáy', 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=500&q=80'),
(4, 4, 1, 4, 'LIKE_NEW', 50000.0, 75000.0, 12, 'AVAILABLE', 'Sách như mới 98%, đẹp sạch sẽ', 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=500&q=80'),
(5, 5, 2, 6, 'FAIR', 120000.0, 180000.0, 3, 'AVAILABLE', 'Ấn bản hiếm 1974, bìa vải ngả màu thời gian, cực kỳ giá trị', 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=500&q=80'),
(6, 6, 1, 4, 'GOOD', 20000.0, 35000.0, 7, 'AVAILABLE', 'Truyện tranh cũ 1996, ruột sạch sẽ đủ trang', 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=500&q=80'),
(7, 7, 1, 5, 'GOOD', 45000.0, 70000.0, 15, 'AVAILABLE', 'Bộ sách giáo khoa 12 môn còn đầy đủ bìa và ruột sạch sẽ', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500&q=80');

-- -------------------------------------------------------------------
-- 9. BẢNG APP_DISCOUNTS (Mã giảm giá hệ thống)
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `app_discounts`;
CREATE TABLE `app_discounts` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(50) NOT NULL UNIQUE,
  `discount_percent` DOUBLE NOT NULL,
  `max_discount_amount` DOUBLE DEFAULT NULL,
  `min_order_value` DOUBLE DEFAULT NULL,
  `start_date` DATE DEFAULT NULL,
  `end_date` DATE DEFAULT NULL,
  `active` BIT(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `app_discounts` (`id`, `code`, `discount_percent`, `max_discount_amount`, `min_order_value`, `start_date`, `end_date`, `active`) VALUES
(1, 'SACHCU10', 10.0, 30000.0, 100000.0, '2026-01-01', '2026-12-31', b'1');

-- -------------------------------------------------------------------
-- 10. BẢNG ORDERS (Đơn hàng mua bán) & ORDER_ITEMS
-- -------------------------------------------------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
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
  `order_status` VARCHAR(30) NOT NULL DEFAULT 'NEW',
  `note` TEXT DEFAULT NULL,
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_orders_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `fk_orders_shipping_provider` FOREIGN KEY (`shipping_provider_id`) REFERENCES `shipping_providers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `orders` (`id`, `order_code`, `customer_id`, `branch_id`, `shipping_provider_id`, `receiver_name`, `receiver_phone`, `shipping_address`, `total_amount`, `shipping_fee`, `discount_amount`, `app_commission_amount`, `final_amount`, `payment_method`, `payment_status`, `order_status`, `note`) VALUES
(1, 'DH-DEMO-001', 9, 1, 1, 'Nguyễn Văn A', '0955555555', '12 Võ Văn Ngân, TP. Thủ Đức, TP.HCM', 65000.0, 20000.0, 0.0, 6500.0, 85000.0, 'COD', 'PENDING', 'NEW', 'Gọi trước khi giao');

DROP TABLE IF EXISTS `order_items`;
CREATE TABLE `order_items` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `order_id` BIGINT NOT NULL,
  `book_copy_id` BIGINT NOT NULL,
  `quantity` INT NOT NULL,
  `price` DOUBLE NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_items_copy` FOREIGN KEY (`book_copy_id`) REFERENCES `book_copies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `order_items` (`id`, `order_id`, `book_copy_id`, `quantity`, `price`) VALUES
(1, 1, 1, 1, 65000.0);

-- Bật lại kiểm tra khóa ngoại
SET FOREIGN_KEY_CHECKS = 1;

-- ===================================================================
-- HOÀN TẤT KHỞI TẠO CƠ SỞ DỮ LIỆU MYSQL WEB_SACH_CU
-- ===================================================================
