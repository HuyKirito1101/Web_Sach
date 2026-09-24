package vn.iotstar.websach.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import vn.iotstar.websach.entity.*;
import vn.iotstar.websach.entity.enums.BookCondition;
import vn.iotstar.websach.entity.enums.BookCopyStatus;
import vn.iotstar.websach.entity.enums.BranchStatus;
import vn.iotstar.websach.entity.enums.RoleName;
import vn.iotstar.websach.entity.enums.*;
import vn.iotstar.websach.repository.*;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {

    private final RoleRepository roleRepository;
    private final UserRepository userRepository;
    private final BranchRepository branchRepository;
    private final CategoryRepository categoryRepository;
    private final AuthorRepository authorRepository;
    private final PublisherRepository publisherRepository;
    private final BookRepository bookRepository;
    private final BookCopyRepository bookCopyRepository;
    private final ShippingProviderRepository shippingProviderRepository;
    private final AppDiscountRepository appDiscountRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final PromotionRepository promotionRepository;
    private final SellRequestRepository sellRequestRepository;
    private final SellRequestItemRepository sellRequestItemRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) throws Exception {
        // Dọn dẹp các tài khoản cũ không còn dùng (vendor@websach.com, shipper@websach.com, customer.test@websach.com)
        List<String> deprecatedEmails = List.of("vendor@websach.com", "shipper@websach.com", "customer.test@websach.com");
        for (String email : deprecatedEmails) {
            userRepository.findByEmail(email).ifPresent(u -> {
                branchRepository.findAll().stream()
                        .filter(br -> br.getOwner() != null && Objects.equals(br.getOwner().getId(), u.getId()))
                        .forEach(br -> { br.setOwner(null); branchRepository.save(br); });
                userRepository.delete(u);
                log.info("Đã xóa tài khoản cũ: {}", email);
            });
        }

        if (bookRepository.count() > 0) {
            log.info("Dữ liệu đã tồn tại, tiến hành dọn dẹp các bản copy sách cũ không thuộc Vendor nào...");
            List<BookCopy> orphans = bookCopyRepository.findAll().stream()
                    .filter(c -> c.getSeller() == null)
                    .toList();
            if (!orphans.isEmpty()) {
                log.info("Đã xóa {} bản copy sách không thuộc về Vendor nào.", orphans.size());
                bookCopyRepository.deleteAll(orphans);
            }
            return;
        }

        log.info("Đang khởi tạo dữ liệu mẫu phong phú cho Web Sách Cũ...");

        // 1. Roles
        for (RoleName roleName : RoleName.values()) {
            roleRepository.findByName(roleName).orElseGet(() ->
                    roleRepository.save(Role.builder().name(roleName).description("Role " + roleName.name()).build())
            );
        }

        Role adminRole = roleRepository.findByName(RoleName.ROLE_ADMIN).get();
        Role managerRole = roleRepository.findByName(RoleName.ROLE_MANAGER).get();
        Role shipperRole = roleRepository.findByName(RoleName.ROLE_SHIPPER).get();
        Role vendorRole = roleRepository.findByName(RoleName.ROLE_VENDOR).get();
        Role userRole = roleRepository.findByName(RoleName.ROLE_USER).get();

        // 2. Branches
        Branch b1 = branchRepository.findAll().stream().findFirst().orElseGet(() ->
                branchRepository.save(Branch.builder()
                        .name("Sách Cũ Chi Nhánh Thủ Đức")
                        .address("1 Võ Văn Ngân, TP. Thủ Đức, TP.HCM")
                        .phone("0901234567")
                        .email("thuduc@websach.com")
                        .status(BranchStatus.ACTIVE)
                        .appDiscountPercent(10.0)
                        .description("Cửa hàng chuyên sách cũ, sách xưa và các ấn bản đã qua sử dụng.")
                        .build())
        );

        Branch b2 = branchRepository.save(Branch.builder()
                .name("Sách Cũ Chi Nhánh Quận 1")
                .address("100 Nguyễn Huệ, Quận 1, TP.HCM")
                .phone("0907654321")
                .email("quan1@websach.com")
                .status(BranchStatus.ACTIVE)
                .appDiscountPercent(12.0)
                .description("Chi nhánh trung tâm chuyên sách ngoại văn, giáo trình và truyện tranh hiếm.")
                .build());

        // 3. Users
        userRepository.findByEmail("admin@websach.com").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Quản Trị Viên Admin")
                        .email("admin@websach.com")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0988888888")
                        .role(adminRole)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        userRepository.findByEmail("manager@websach.com").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Quản Lý Chi Nhánh Thủ Đức")
                        .email("manager@websach.com")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0977777777")
                        .role(managerRole)
                        .branch(b1)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        User customer = userRepository.findByEmail("user@websach.com").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Khách Hàng Nguyễn Văn A")
                        .email("user@websach.com")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0955555555")
                        .role(userRole)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        // 4. Categories (Khởi tạo trước để gán cho Vendor & Sách)
        Category cat1 = categoryRepository.save(Category.builder().name("Văn Học Việt Nam").slug("van-hoc-viet-nam").description("Các tác phẩm văn học nổi tiếng trong nước qua các thời kỳ.").active(true).build());
        Category cat2 = categoryRepository.save(Category.builder().name("Sách Trước 1975").slug("sach-truoc-1975").description("Các bản sách cũ, ấn bản xưa quý hiếm trước năm 1975.").active(true).build());
        Category cat3 = categoryRepository.save(Category.builder().name("Kinh Tế - Kỹ Năng").slug("kinh-te-ky-nang").description("Sách kinh doanh, quản trị và phát triển bản thân.").active(true).build());
        Category cat4 = categoryRepository.save(Category.builder().name("Truyện Tranh & Manga Cũ").slug("truyen-tranh-manga").description("Bộ truyện tranh, manga sưu tầm xưa và cũ.").active(true).build());
        Category cat5 = categoryRepository.save(Category.builder().name("Giáo Trình & Ngoại Ngữ").slug("giao-trinh-ngoai-ngu").description("Giáo trình đại học, sách học tiếng Anh, Nhật, Trung.").active(true).build());
        Category cat6 = categoryRepository.save(Category.builder().name("Sách Giáo Khoa & Tham Khảo").slug("sgk-tham-khao").description("Bộ sách giáo khoa các lớp 1-12, sách luyện thi đại học cũ.").active(true).build());

        // Shipping Providers (Đơn vị vận chuyển)
        ShippingProvider ghnStandard = shippingProviderRepository.save(ShippingProvider.builder()
                .name("Giao Hàng Nhanh (GHN) - Tiêu Chuẩn")
                .code("GHN_STANDARD")
                .serviceType("Trong tỉnh (Tiêu chuẩn)")
                .estimatedDays("1 - 2 ngày")
                .scopeDescription("Vận chuyển đơn mua trong tỉnh / nội thành")
                .phone("19006789")
                .baseFee(20000.0)
                .active(true)
                .build());

        ShippingProvider ghnExpress = shippingProviderRepository.save(ShippingProvider.builder()
                .name("Giao Hàng Nhanh (GHN) - Hỏa Tốc")
                .code("GHN_EXPRESS")
                .serviceType("Trong tỉnh (Hỏa tốc)")
                .estimatedDays("2 - 4 giờ (Trong ngày)")
                .scopeDescription("Giao gấp nhận ngay trong ngày cho đơn nội tỉnh")
                .phone("19006789")
                .baseFee(40000.0)
                .active(true)
                .build());

        ShippingProvider spxExpress = shippingProviderRepository.save(ShippingProvider.builder()
                .name("SPX Express (Shopee Xpress) - Giao Liên Tỉnh")
                .code("SPX_EXPRESS")
                .serviceType("Ngoại tỉnh (Liên tỉnh)")
                .estimatedDays("2 - 4 ngày")
                .scopeDescription("Chuyên vận chuyển các đơn giao ngoài tỉnh toàn quốc")
                .phone("19001221")
                .baseFee(32000.0)
                .active(true)
                .build());

        // 3.1. Vendors cho Chi Nhánh Thủ Đức (b1) kèm Chuyên Môn Danh Mục
        User vThuduc1 = userRepository.findByEmail("vendor.thuduc1@websach.com").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Vendor 1 Thủ Đức - Sách Văn Học & Truyện Tranh")
                        .email("vendor.thuduc1@websach.com")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0901111111")
                        .role(vendorRole)
                        .branch(b1)
                        .specializedCategory(cat1)
                        .status(UserStatus.ACTIVE)
                        .build())
        );
        if (b1.getOwner() == null) {
            b1.setOwner(vThuduc1);
            branchRepository.save(b1);
        }

        User vThuduc2 = userRepository.findByEmail("vendor.thuduc2@websach.com").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Vendor 2 Thủ Đức - Sách Giáo Khoa & Tham Khảo")
                        .email("vendor.thuduc2@websach.com")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0902222222")
                        .role(vendorRole)
                        .branch(b1)
                        .specializedCategory(cat6)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        // 3.2. Shippers cho Chi Nhánh Thủ Đức (b1) chia theo NVC (GHN Tiêu chuẩn, GHN Hỏa tốc, SPX Express)
        userRepository.findByEmail("shipper.thuduc1@websach.com").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Shipper Thủ Đức (GHN Tiêu Chuẩn) - Nguyễn Văn Nam")
                        .email("shipper.thuduc1@websach.com")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0961111111")
                        .role(shipperRole)
                        .branch(b1)
                        .shippingProvider(ghnStandard)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        userRepository.findByEmail("shipper.thuduc2@websach.com").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Shipper Thủ Đức (GHN Hỏa Tốc) - Trần Văn Bình")
                        .email("shipper.thuduc2@websach.com")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0962222222")
                        .role(shipperRole)
                        .branch(b1)
                        .shippingProvider(ghnExpress)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        userRepository.findByEmail("shipper.thuduc3@websach.com").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Shipper Thủ Đức (SPX Express) - Nguyễn Thị Mai")
                        .email("shipper.thuduc3@websach.com")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0963333333")
                        .role(shipperRole)
                        .branch(b1)
                        .shippingProvider(spxExpress)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        // 3.3. Vendors cho Chi Nhánh Quận 1 (b2) kèm Chuyên Môn Danh Mục
        User vQuan1_1 = userRepository.findByEmail("vendor.quan1_1@websach.com").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Vendor 1 Quận 1 - Sách Kinh Tế & Kỹ Năng")
                        .email("vendor.quan1_1@websach.com")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0903333333")
                        .role(vendorRole)
                        .branch(b2)
                        .specializedCategory(cat3)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        User vQuan1_2 = userRepository.findByEmail("vendor.quan1_2@websach.com").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Vendor 2 Quận 1 - Sách Ngoại Văn & Trước 1975")
                        .email("vendor.quan1_2@websach.com")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0904444444")
                        .role(vendorRole)
                        .branch(b2)
                        .specializedCategory(cat2)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        // 3.4. Shippers cho Chi Nhánh Quận 1 (b2) chia theo NVC (GHN Tiêu chuẩn, GHN Hỏa tốc, SPX Express)
        userRepository.findByEmail("shipper.quan1_1@websach.com").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Shipper Quận 1 (GHN Tiêu Chuẩn) - Lê Hoàng Long")
                        .email("shipper.quan1_1@websach.com")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0964444444")
                        .role(shipperRole)
                        .branch(b2)
                        .shippingProvider(ghnStandard)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        userRepository.findByEmail("shipper.quan1_2@websach.com").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Shipper Quận 1 (GHN Hỏa Tốc) - Phạm Quốc Huy")
                        .email("shipper.quan1_2@websach.com")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0965555555")
                        .role(shipperRole)
                        .branch(b2)
                        .shippingProvider(ghnExpress)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        userRepository.findByEmail("shipper.quan1_3@websach.com").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Shipper Quận 1 (SPX Express) - Trịnh Văn An")
                        .email("shipper.quan1_3@websach.com")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0966666667")
                        .role(shipperRole)
                        .branch(b2)
                        .shippingProvider(spxExpress)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        // 5. Authors & Publishers
        Author a1 = authorRepository.save(Author.builder().name("Tô Hoài").bio("Nhà văn lớn của văn học hiện đại Việt Nam.").build());
        Author a2 = authorRepository.save(Author.builder().name("Vũ Trọng Phụng").bio("Ông vua văn xuôi trào phúng Việt Nam.").build());
        Author a3 = authorRepository.save(Author.builder().name("Ngô Tất Tố").bio("Nhà văn, nhà báo, nhà nghiên cứu văn hóa nổi tiếng.").build());
        Author a4 = authorRepository.save(Author.builder().name("Nguyễn Nhật Ánh").bio("Tác giả của nhiều tựa sách tuổi học trò được yêu thích.").build());
        Author a5 = authorRepository.save(Author.builder().name("Dale Carnegie").bio("Tác giả hàng đầu thế giới về dắc nhân tâm và giao tiếp.").build());
        Author a6 = authorRepository.save(Author.builder().name("Bộ Giáo Dục & Đào Tạo").bio("Tác giả biên soạn SGK phổ thông.").build());

        Publisher p1 = publisherRepository.save(Publisher.builder().name("NXB Kim Đồng").address("Hà Nội").build());
        Publisher p2 = publisherRepository.save(Publisher.builder().name("NXB Văn Học").address("Hà Nội").build());
        Publisher p3 = publisherRepository.save(Publisher.builder().name("NXB Trẻ").address("TP.HCM").build());
        Publisher p4 = publisherRepository.save(Publisher.builder().name("NXB Cổ Phong (Trước 1975)").address("Sài Gòn").build());
        Publisher p5 = publisherRepository.save(Publisher.builder().name("NXB Giáo Dục Việt Nam").address("Hà Nội").build());

        // 6. Books
        Book book1 = bookRepository.save(Book.builder()
                .isbn("9786042078888")
                .title("Dế Mèn Phiêu Lưu Ký")
                .description("Tác phẩm văn học kinh điển dành cho thiếu nhi và người lớn của nhà văn Tô Hoài.")
                .category(cat1)
                .author(a1)
                .publisher(p1)
                .publishYear(1985)
                .language("Tiếng Việt")
                .coverUrl("https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500&q=80")
                .build());

        Book book2 = bookRepository.save(Book.builder()
                .isbn("9786045612345")
                .title("Số Đỏ (Ấn Bản Năm 1990)")
                .description("Tiểu thuyết trào phúng kinh điển của Vũ Trọng Phụng về nhân vật Xuân Tóc Đỏ.")
                .category(cat2)
                .author(a2)
                .publisher(p2)
                .publishYear(1990)
                .language("Tiếng Việt")
                .coverUrl("https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500&q=80")
                .build());

        Book book3 = bookRepository.save(Book.builder()
                .isbn("9786048991111")
                .title("Tắt Đèn (Bản Cũ 1988)")
                .description("Tác phẩm hiện thực xuất sắc tái hiện cuộc sống nông thôn Việt Nam trước Cách mạng.")
                .category(cat1)
                .author(a3)
                .publisher(p2)
                .publishYear(1988)
                .language("Tiếng Việt")
                .coverUrl("https://images.unsplash.com/photo-1532012197267-da84d127e765?w=500&q=80")
                .build());

        Book book4 = bookRepository.save(Book.builder()
                .isbn("9786047722222")
                .title("Tôi Thấy Hoa Vàng Trên Cỏ Xanh")
                .description("Truyện dài cảm động về tuổi thơ nơi làng quê nghèo của Nguyễn Nhật Ánh.")
                .category(cat1)
                .author(a4)
                .publisher(p3)
                .publishYear(2012)
                .language("Tiếng Việt")
                .coverUrl("https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=500&q=80")
                .build());

        Book book5 = bookRepository.save(Book.builder()
                .isbn("9786046633333")
                .title("Đắc Nhân Tâm (Bản Dịch Nguyễn Hiến Lê 1974)")
                .description("Bản dịch kinh điển của dịch giả Nguyễn Hiến Lê trước năm 1975, bìa cứng xưa quý hiếm.")
                .category(cat3)
                .author(a5)
                .publisher(p4)
                .publishYear(1974)
                .language("Tiếng Việt")
                .coverUrl("https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=500&q=80")
                .build());

        Book book6 = bookRepository.save(Book.builder()
                .isbn("9786045544444")
                .title("Doraemon Tập 1 (Bản In Đầu 1996)")
                .description("Tập 1 bộ truyện tranh Doraemon bản dịch cũ mỏng giấy ngả vàng sưu tầm.")
                .category(cat4)
                .author(a1)
                .publisher(p1)
                .publishYear(1996)
                .language("Tiếng Việt")
                .coverUrl("https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=500&q=80")
                .build());

        Book book7 = bookRepository.save(Book.builder()
                .isbn("9786040007777")
                .title("Bộ Sách Giáo Khoa Lớp 12 Cũ (Đầy Đủ 12 Môn)")
                .description("Bộ SGK lớp 12 cũ dành cho học sinh chuẩn bị ôn thi đại học và tốt nghiệp.")
                .category(cat6)
                .author(a6)
                .publisher(p5)
                .publishYear(2020)
                .language("Tiếng Việt")
                .coverUrl("https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500&q=80")
                .build());

        // 7. BookCopies across Branches & Specialized Vendors
        BookCopy copy1 = bookCopyRepository.save(BookCopy.builder()
                .book(book1)
                .branch(b1)
                .seller(vThuduc1)
                .conditionRating(BookCondition.LIKE_NEW)
                .purchasePrice(40000.0)
                .sellingPrice(65000.0)
                .quantity(10)
                .status(BookCopyStatus.AVAILABLE)
                .note("Bìa mới 95%, không ố vàng, trang sách đầy đủ")
                .imageUrl("https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500&q=80")
                .build());

        BookCopy copy2 = bookCopyRepository.save(BookCopy.builder()
                .book(book2)
                .branch(b2)
                .seller(vQuan1_2)
                .conditionRating(BookCondition.GOOD)
                .purchasePrice(30000.0)
                .sellingPrice(50000.0)
                .quantity(5)
                .status(BookCopyStatus.AVAILABLE)
                .note("Bìa hơi sờn góc, trang hơi ngả vàng theo thời gian")
                .imageUrl("https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500&q=80")
                .build());

        BookCopy copy3 = bookCopyRepository.save(BookCopy.builder()
                .book(book3)
                .branch(b1)
                .seller(vThuduc1)
                .conditionRating(BookCondition.VERY_GOOD)
                .purchasePrice(35000.0)
                .sellingPrice(55000.0)
                .quantity(8)
                .status(BookCopyStatus.AVAILABLE)
                .note("Giấy giữ màu tốt, không rách gáy")
                .imageUrl("https://images.unsplash.com/photo-1532012197267-da84d127e765?w=500&q=80")
                .build());

        BookCopy copy4 = bookCopyRepository.save(BookCopy.builder()
                .book(book4)
                .branch(b1)
                .seller(vThuduc1)
                .conditionRating(BookCondition.LIKE_NEW)
                .purchasePrice(50000.0)
                .sellingPrice(75000.0)
                .quantity(12)
                .status(BookCopyStatus.AVAILABLE)
                .note("Sách như mới 98%, đẹp sạch sẽ")
                .imageUrl("https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=500&q=80")
                .build());

        BookCopy copy5 = bookCopyRepository.save(BookCopy.builder()
                .book(book5)
                .branch(b2)
                .seller(vQuan1_1)
                .conditionRating(BookCondition.FAIR)
                .purchasePrice(120000.0)
                .sellingPrice(180000.0)
                .quantity(3)
                .status(BookCopyStatus.AVAILABLE)
                .note("Ấn bản hiếm 1974, bìa vải ngả màu thời gian, cực kỳ giá trị cho dân sưu tầm")
                .imageUrl("https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=500&q=80")
                .build());

        BookCopy copy6 = bookCopyRepository.save(BookCopy.builder()
                .book(book6)
                .branch(b1)
                .seller(vThuduc1)
                .conditionRating(BookCondition.GOOD)
                .purchasePrice(20000.0)
                .sellingPrice(35000.0)
                .quantity(7)
                .status(BookCopyStatus.AVAILABLE)
                .note("Truyện tranh cũ 1996, ruột sạch sẽ đủ trang")
                .imageUrl("https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=500&q=80")
                .build());

        BookCopy copy7 = bookCopyRepository.save(BookCopy.builder()
                .book(book7)
                .branch(b1)
                .seller(vThuduc2)
                .conditionRating(BookCondition.GOOD)
                .purchasePrice(45000.0)
                .sellingPrice(70000.0)
                .quantity(15)
                .status(BookCopyStatus.AVAILABLE)
                .note("Bộ sách giáo khoa 12 môn còn đầy đủ bìa và ruột sạch sẽ")
                .imageUrl("https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500&q=80")
                .build());

        // 8. App Discounts & Promotions
        appDiscountRepository.save(AppDiscount.builder().code("SACHCU10").discountPercent(10.0).maxDiscountAmount(30000.0).minOrderValue(100000.0).startDate(LocalDate.now()).endDate(LocalDate.now().plusMonths(3)).active(true).build());

        promotionRepository.save(Promotion.builder()
                .title("Tuần lễ sách cũ chất lượng")
                .branch(b1).discountPercent(10.0)
                .startDate(LocalDate.now()).endDate(LocalDate.now().plusDays(14)).active(true).build());

        if (orderRepository.count() == 0) {
            Order order = orderRepository.save(Order.builder()
                    .orderCode("DH-DEMO-001").customer(customer).branch(b1).shippingProvider(ghnStandard)
                    .receiverName(customer.getFullName()).receiverPhone(customer.getPhone())
                    .shippingAddress("12 Võ Văn Ngân, TP. Thủ Đức, TP.HCM")
                    .totalAmount(65000.0).shippingFee(20000.0).discountAmount(0.0)
                    .appCommissionAmount(6500.0).finalAmount(85000.0)
                    .paymentMethod(PaymentMethod.COD).paymentStatus(PaymentStatus.PENDING)
                    .orderStatus(OrderStatus.NEW).note("Gọi trước khi giao").build());
            orderItemRepository.save(OrderItem.builder().order(order).bookCopy(copy1).quantity(1).price(65000.0).build());
        }

        if (sellRequestRepository.count() == 0) {
            SellRequest request = sellRequestRepository.save(SellRequest.builder()
                    .customer(customer).branch(b1).status(SellRequestStatus.PENDING)
                    .expectedTotal(50000.0).note("Muốn bán lại một cuốn sách văn học còn đủ trang.").build());
            sellRequestItemRepository.save(SellRequestItem.builder()
                    .sellRequest(request).book(book2).bookTitle(book2.getTitle()).isbn(book2.getIsbn())
                    .conditionDescription("Bìa sờn nhẹ, trang đủ, không rách.")
                    .expectedPrice(50000.0).imageUrl(book2.getCoverUrl()).build());
        }

        log.info("Khởi tạo dữ liệu mẫu thành công! Sẵn sàng sử dụng.");
    }
}
