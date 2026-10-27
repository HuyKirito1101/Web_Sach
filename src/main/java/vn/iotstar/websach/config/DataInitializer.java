package vn.iotstar.websach.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.beans.factory.annotation.Value;
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
import java.util.Optional;

@Component
@org.springframework.core.annotation.Order(1)
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {

    /**
     * Hash đã có trong bản SQL ban đầu nhưng không khớp với mật khẩu 123456
     * được công bố cho các tài khoản demo.
     */
    private static final String INVALID_LEGACY_DEMO_PASSWORD_HASH =
            "$2a$10$8.UnVuG9HHgffUDAlk8qfOUVGkqRzgVym5pE6tqE/m/m14wU50y/.";

    /**
     * Chỉ các tài khoản minh họa do project tạo sẵn mới được phép đặt lại
     * mật khẩu khi chạy ở môi trường phát triển.
     */
    private static final List<String> DEMO_ACCOUNT_EMAILS = List.of(
            "admin@websachcu.vn",
            "manager@websachcu.vn",
            "user@websachcu.vn",
            "vendor.thuduc1@websachcu.vn",
            "vendor.thuduc2@websachcu.vn",
            "vendor.phunhuan1@websachcu.vn",
            "vendor.quan1_1@websachcu.vn",
            "vendor.quan1_2@websachcu.vn",
            "shipper.thuduc1@websachcu.vn",
            "shipper.thuduc2@websachcu.vn",
            "shipper.thuduc3@websachcu.vn",
            "shipper.quan1_1@websachcu.vn",
            "shipper.quan1_2@websachcu.vn",
            "shipper.quan1_3@websachcu.vn"
    );

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
    private final vn.iotstar.websach.repository.DeliveryAssignmentRepository deliveryAssignmentRepository;

    @Value("${app.demo-data.enabled:false}")
    private boolean demoDataEnabled;

    @Value("${app.demo-accounts.reset-passwords:false}")
    private boolean resetDemoAccountPasswords;

    @Override
    public void run(String... args) throws Exception {
        // Role là dữ liệu hệ thống bắt buộc, không phải dữ liệu demo.
        for (RoleName roleName : RoleName.values()) {
            roleRepository.findByName(roleName).orElseGet(() ->
                    roleRepository.save(Role.builder().name(roleName)
                            .description("Role " + roleName.name()).build())
            );
        }

        repairLegacyDemoPasswords();
        ensureDemoLoginAccounts();

        if (resetDemoAccountPasswords) {
            resetExistingDemoAccountPasswords();
        }

        if (!demoDataEnabled) {
            log.info("Dữ liệu mẫu đang tắt; không tạo hoặc đặt lại mật khẩu tài khoản demo.");
            return;
        }

        repairLegacyDemoPasswords();

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
            ensureDemoLoginAccounts();
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
        Branch b1 = branchRepository.findAll().stream()
                .filter(b -> b.getName() != null && b.getName().contains("Thủ Đức"))
                .findFirst().orElseGet(() ->
                branchRepository.save(Branch.builder()
                        .name("Sách Cũ Chi Nhánh Thủ Đức")
                        .address("1 Võ Văn Ngân, TP. Thủ Đức, TP.HCM")
                        .phone("0901234567")
                        .email("thuduc@websachcu.vn")
                        .status(BranchStatus.ACTIVE)
                        .appDiscountPercent(10.0)
                        .description("Cửa hàng chuyên sách cũ, sách xưa và các ấn bản đã qua sử dụng.")
                        .build())
        );

        Branch b2 = branchRepository.findAll().stream()
                .filter(b -> b.getName() != null && (b.getName().contains("Phú Nhuận") || b.getName().contains("Quận 1")))
                .findFirst()
                .orElseGet(() ->
                branchRepository.save(Branch.builder()
                        .name("Sách Cũ Chi Nhánh Phú Nhuận")
                        .address("205 Trần Huy Liệu, P.8, Q. Phú Nhuận, TP.HCM")
                        .phone("0907654321")
                        .email("phunhuan@websachcu.vn")
                        .status(BranchStatus.ACTIVE)
                        .appDiscountPercent(12.0)
                        .description("Chi nhánh trung tâm chuyên sách ngoại văn, giáo trình và truyện tranh hiếm.")
                        .build()));
        if (b2.getName() == null || !b2.getName().contains("Phú Nhuận")) {
            b2.setName("Sách Cũ Chi Nhánh Phú Nhuận");
            b2.setAddress("205 Trần Huy Liệu, P.8, Q. Phú Nhuận, TP.HCM");
            b2.setEmail("phunhuan@websachcu.vn");
            branchRepository.save(b2);
        }
        // 3. Users
        userRepository.findByEmail("admin@websachcu.vn").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Quản Trị Viên Admin")
                        .email("admin@websachcu.vn")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0988888888")
                        .role(adminRole)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        userRepository.findByEmail("minhkhuyen779@gmail.com").ifPresentOrElse(
                u -> {
                    if (u.getRole() == null || u.getRole().getName() != RoleName.ROLE_ADMIN) {
                        u.setRole(adminRole);
                        userRepository.save(u);
                    }
                },
                () -> userRepository.save(User.builder()
                        .fullName("Quản Trị Viên Minh Khuyên")
                        .email("minhkhuyen779@gmail.com")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0376131883")
                        .role(adminRole)
                        .branch(b1)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        userRepository.findByEmail("manager@websachcu.vn").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Quản Lý Chi Nhánh Thủ Đức")
                        .email("manager@websachcu.vn")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0977777777")
                        .role(managerRole)
                        .branch(b1)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        User customer = userRepository.findByEmail("user@websachcu.vn").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Khách Hàng Nguyễn Văn A")
                        .email("user@websachcu.vn")
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
        User vThuduc1 = userRepository.findByEmail("vendor.thuduc1@websachcu.vn").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Vendor 1 Thủ Đức - Sách Văn Học & Truyện Tranh")
                        .email("vendor.thuduc1@websachcu.vn")
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

        User vThuduc2 = userRepository.findByEmail("vendor.thuduc2@websachcu.vn").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Vendor 2 Thủ Đức - Sách Giáo Khoa & Tham Khảo")
                        .email("vendor.thuduc2@websachcu.vn")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0902222222")
                        .role(vendorRole)
                        .branch(b1)
                        .specializedCategory(cat6)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        // 3.2. 4 Shippers cho Chi Nhánh Thủ Đức (b1): 2 Tiêu Chuẩn, 2 Hỏa Tốc
        userRepository.findByEmail("shipper.thuduc1@websachcu.vn").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Shipper Thủ Đức (Tiêu Chuẩn 1) - Nguyễn Văn Nam")
                        .email("shipper.thuduc1@websachcu.vn")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0961111111")
                        .role(shipperRole)
                        .branch(b1)
                        .shippingProvider(ghnStandard)
                        .status(UserStatus.ACTIVE)
                        .build())
        );
        userRepository.findByEmail("shipper.thuduc.tieuchuan@websachcu.vn").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Shipper Thủ Đức (Tiêu Chuẩn 2) - Lê Văn Tài")
                        .email("shipper.thuduc.tieuchuan@websachcu.vn")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0961222222")
                        .role(shipperRole)
                        .branch(b1)
                        .shippingProvider(ghnStandard)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        userRepository.findByEmail("shipper.thuduc2@websachcu.vn").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Shipper Thủ Đức (Hỏa Tốc 1) - Trần Văn Bình")
                        .email("shipper.thuduc2@websachcu.vn")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0962222222")
                        .role(shipperRole)
                        .branch(b1)
                        .shippingProvider(ghnExpress)
                        .status(UserStatus.ACTIVE)
                        .build())
        );
        userRepository.findByEmail("shipper.thuduc.hoatoc@websachcu.vn").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Shipper Thủ Đức (Hỏa Tốc 2) - Hoàng Văn Dũng")
                        .email("shipper.thuduc.hoatoc@websachcu.vn")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0962333333")
                        .role(shipperRole)
                        .branch(b1)
                        .shippingProvider(ghnExpress)
                        .status(UserStatus.ACTIVE)
                        .build())
        );
        // 3.3. Vendors cho Chi Nhánh Quận 1 (b2) kèm Chuyên Môn Danh Mục
        User vQuan1_1 = userRepository.findByEmail("vendor.quan1_1@websachcu.vn").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Vendor 1 Quận 1 - Sách Kinh Tế & Kỹ Năng")
                        .email("vendor.quan1_1@websachcu.vn")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0903333333")
                        .role(vendorRole)
                        .branch(b2)
                        .specializedCategory(cat3)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        User vQuan1_2 = userRepository.findByEmail("vendor.quan1_2@websachcu.vn").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Vendor 2 Quận 1 - Sách Ngoại Văn & Trước 1975")
                        .email("vendor.quan1_2@websachcu.vn")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0904444444")
                        .role(vendorRole)
                        .branch(b2)
                        .specializedCategory(cat2)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        // 3.4. Shippers cho Chi Nhánh Phú Nhuận (b2): 1 Tiêu Chuẩn, 1 Hỏa Tốc
        userRepository.findByEmail("shipper.phunhuan.tieuchuan@websachcu.vn").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Shipper Phú Nhuận (Tiêu Chuẩn) - Lê Hoàng Long")
                        .email("shipper.phunhuan.tieuchuan@websachcu.vn")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0964444444")
                        .role(shipperRole)
                        .branch(b2)
                        .shippingProvider(ghnStandard)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        userRepository.findByEmail("shipper.phunhuan.hoatoc@websachcu.vn").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Shipper Phú Nhuận (Hỏa Tốc) - Phạm Quốc Huy")
                        .email("shipper.phunhuan.hoatoc@websachcu.vn")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0965555555")
                        .role(shipperRole)
                        .branch(b2)
                        .shippingProvider(ghnExpress)
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
                .coverUrl("https://cdn1.fahasa.com/media/catalog/product/d/e/de-men-phieu-luu-ki_bia-cung_to.jpg")
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
                .coverUrl("https://cdn1.fahasa.com/media/catalog/product/8/9/8935230010784_1.jpg")
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
                .coverUrl("https://product.hstatic.net/1000237375/product/bia_truoc_08_b4497226ce524fd79a1d81b9086b99a9_master.jpg")
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
                .coverUrl("https://cdn0.fahasa.com/media/catalog/product/8/9/8934974158448.jpg")
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
                .coverUrl("https://cdn1.fahasa.com/media/catalog/product/8/9/8935230006015.jpg")
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
                .coverUrl("https://bizweb.dktcdn.net/thumb/1024x1024/100/576/749/products/1-09e4d57d2e8d45f6ae65b8936811fa81.jpg?v=1760791370697")
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
                .coverUrl("https://cdn1.fahasa.com/media/catalog/product/9/7/9786040392503.jpg")
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
                .imageUrl("https://cdn1.fahasa.com/media/catalog/product/d/e/de-men-phieu-luu-ki_bia-cung_to.jpg")
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
                .imageUrl("https://cdn1.fahasa.com/media/catalog/product/8/9/8935230010784_1.jpg")
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
                .imageUrl("https://product.hstatic.net/1000237375/product/bia_truoc_08_b4497226ce524fd79a1d81b9086b99a9_master.jpg")
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
                .imageUrl("https://cdn0.fahasa.com/media/catalog/product/8/9/8934974158448.jpg")
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
                .imageUrl("https://cdn1.fahasa.com/media/catalog/product/8/9/8935230006015.jpg")
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
                .imageUrl("https://bizweb.dktcdn.net/thumb/1024x1024/100/576/749/products/1-09e4d57d2e8d45f6ae65b8936811fa81.jpg?v=1760791370697")
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
                .imageUrl("https://cdn1.fahasa.com/media/catalog/product/9/7/9786040392503.jpg")
                .build());

        // 8. App Discounts & Promotions
        appDiscountRepository.save(AppDiscount.builder().code("SACHCU10").discountPercent(10.0).maxDiscountAmount(30000.0).minOrderValue(100000.0).startDate(LocalDate.now()).endDate(LocalDate.now().plusMonths(3)).active(true).build());

        promotionRepository.save(Promotion.builder()
                .title("Tuần lễ sách cũ chất lượng")
                .branch(b1).discountPercent(10.0)
                .startDate(LocalDate.now()).endDate(LocalDate.now().plusDays(14)).active(true).build());

        if (orderRepository.count() == 0) {
            deliveryAssignmentRepository.deleteAll(); // Dọn dẹp các phân công rác cũ nếu có
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

        ensureDemoLoginAccounts();
        log.info("Khởi tạo dữ liệu mẫu thành công! Sẵn sàng sử dụng.");
    }

    /**
     * Sửa đúng một lần các tài khoản được import từ file SQL mẫu cũ. Chỉ thay
     * hash lỗi đã biết, không can thiệp vào mật khẩu do người dùng tự thay đổi.
     */
    private void repairLegacyDemoPasswords() {
        userRepository.findAll().stream()
                .filter(user -> INVALID_LEGACY_DEMO_PASSWORD_HASH.equals(user.getPassword()))
                .forEach(user -> {
                    user.setPassword(passwordEncoder.encode("123456"));
                    userRepository.save(user);
                    log.info("Đã sửa mật khẩu tài khoản mẫu: {}", user.getEmail());
                });
    }

    /**
     * Dành riêng cho môi trường local/demo. Không đặt lại tất cả người dùng và
     * không nhận email từ request, nhờ đó tài khoản thật không bị ảnh hưởng.
     */
    private void resetExistingDemoAccountPasswords() {
        int updated = 0;
        for (String email : DEMO_ACCOUNT_EMAILS) {
            Optional<User> userOptional = userRepository.findByEmail(email);
            if (userOptional.isEmpty()) {
                continue;
            }

            User user = userOptional.get();
            boolean changed = false;
            if (!passwordEncoder.matches("123456", user.getPassword())) {
                user.setPassword(passwordEncoder.encode("123456"));
                changed = true;
            }
            if (user.getStatus() != UserStatus.ACTIVE) {
                user.setStatus(UserStatus.ACTIVE);
                changed = true;
            }
            if (changed) {
                userRepository.save(user);
                updated++;
            }
        }
        log.info("Đã đồng bộ mật khẩu cho {} tài khoản demo local.", updated);
    }

    /**
     * Bảo đảm hai tài khoản được hiển thị trên trang đăng nhập luôn tồn tại,
     * đang hoạt động và dùng đúng mật khẩu demo. Phần này cũng sửa database cũ
     * từng tạo tài khoản với tên miền @websach.com không đồng nhất với file SQL.
     */
    private void ensureDemoShipperAccount(String email, String fullName, String phone, Branch branch, String providerCode) {
        Role shipperRole = roleRepository.findByName(RoleName.ROLE_SHIPPER).orElse(null);
        if (shipperRole == null) return;
        ShippingProvider provider = (providerCode != null) ? shippingProviderRepository.findByCode(providerCode).orElse(null) : null;

        User user = userRepository.findByEmail(email).orElseGet(() -> User.builder()
                .email(email)
                .fullName(fullName)
                .phone(phone)
                .role(shipperRole)
                .branch(branch)
                .shippingProvider(provider)
                .status(UserStatus.ACTIVE)
                .password(passwordEncoder.encode("123456"))
                .build());

        boolean changed = user.getId() == null;
        if (!passwordEncoder.matches("123456", user.getPassword())) {
            user.setPassword(passwordEncoder.encode("123456"));
            changed = true;
        }
        if (user.getStatus() != UserStatus.ACTIVE) {
            user.setStatus(UserStatus.ACTIVE);
            changed = true;
        }
        if (user.getRole() == null || user.getRole().getName() != RoleName.ROLE_SHIPPER) {
            user.setRole(shipperRole);
            changed = true;
        }
        if (branch != null && (user.getBranch() == null || !Objects.equals(user.getBranch().getId(), branch.getId()))) {
            user.setBranch(branch);
            changed = true;
        }
        if (provider != null && (user.getShippingProvider() == null || !Objects.equals(user.getShippingProvider().getId(), provider.getId()))) {
            user.setShippingProvider(provider);
            changed = true;
        }
        if (fullName != null && !Objects.equals(user.getFullName(), fullName)) {
            user.setFullName(fullName);
            changed = true;
        }
        if (phone != null && !Objects.equals(user.getPhone(), phone)) {
            user.setPhone(phone);
            changed = true;
        }
        if (changed) {
            userRepository.save(user);
            log.info("Đã đồng bộ tài khoản Shipper demo: {}", email);
        }
    }

    private void ensureDemoLoginAccounts() {
        Optional<Role> adminRole = roleRepository.findByName(RoleName.ROLE_ADMIN);
        Optional<Role> managerRole = roleRepository.findByName(RoleName.ROLE_MANAGER);
        if (adminRole.isEmpty() || managerRole.isEmpty()) {
            return;
        }

        Branch bThuduc = branchRepository.findAll().stream()
                .filter(b -> (b.getEmail() != null && b.getEmail().contains("thuduc")) || (b.getName() != null && b.getName().contains("Thủ Đức")))
                .findFirst()
                .orElseGet(() -> branchRepository.findAll().stream().findFirst().orElse(null));

        Branch bPhunhuan = branchRepository.findAll().stream()
                .filter(b -> (b.getEmail() != null && b.getEmail().contains("phunhuan")) || (b.getName() != null && (b.getName().contains("Phú Nhuận") || b.getName().contains("Quận 1"))))
                .findFirst()
                .orElseGet(() -> branchRepository.save(Branch.builder()
                        .name("Sách Cũ Chi Nhánh Phú Nhuận")
                        .address("205 Trần Huy Liệu, P.8, Q. Phú Nhuận, TP.HCM")
                        .phone("0907654321")
                        .email("phunhuan@websachcu.vn")
                        .status(BranchStatus.ACTIVE)
                        .appDiscountPercent(12.0)
                        .description("Chi nhánh trung tâm chuyên sách ngoại văn, giáo trình và truyện tranh hiếm.")
                        .build()));
        if (bPhunhuan.getName() == null || (!bPhunhuan.getName().contains("Phú Nhuận") && (bPhunhuan.getEmail() == null || !bPhunhuan.getEmail().contains("phunhuan")))) {
            bPhunhuan.setName("Sách Cũ Chi Nhánh Phú Nhuận");
            bPhunhuan.setAddress("205 Trần Huy Liệu, P.8, Q. Phú Nhuận, TP.HCM");
            bPhunhuan.setEmail("phunhuan@websachcu.vn");
            bPhunhuan = branchRepository.save(bPhunhuan);
        }

        ensureDemoAccount(
                "admin@websachcu.vn", "Quản Trị Viên Admin", "0988888888",
                adminRole.get(), null);
        ensureDemoAccount(
                "manager@websachcu.vn", "Quản Lý Chi Nhánh", "0977777777",
                managerRole.get(), bThuduc);

        Optional<Role> vendorRole = roleRepository.findByName(RoleName.ROLE_VENDOR);
        if (vendorRole.isPresent()) {
            ensureDemoAccount(
                    "vendor.thuduc1@websachcu.vn", "Vendor 1 Thủ Đức - Sách Văn Học & Truyện Tranh", "0901111111",
                    vendorRole.get(), bThuduc);
            ensureDemoAccount(
                    "vendor.thuduc2@websachcu.vn", "Vendor 2 Thủ Đức - Sách Giáo Khoa & Tham Khảo", "0902222222",
                    vendorRole.get(), bThuduc);
            ensureDemoAccount(
                    "vendor.phunhuan1@websachcu.vn", "Vendor 1 Phú Nhuận - Sách Kinh Tế & Kỹ Năng", "0903333333",
                    vendorRole.get(), bPhunhuan);
        }

        Optional<Role> userRole = roleRepository.findByName(RoleName.ROLE_USER);
        if (userRole.isPresent()) {
            ensureDemoAccount(
                    "user@websachcu.vn", "Khách Hàng Mẫu", "0955555555",
                    userRole.get(), null);
        }

        // Xóa bỏ 2 tài khoản shipper cũ theo yêu cầu
        userRepository.findByEmail("shipper.quan1_1@websachcu.vn").ifPresent(u -> {
            try {
                userRepository.delete(u);
                log.info("Đã xóa bỏ tài khoản shipper cũ: shipper.quan1_1@websachcu.vn");
            } catch (Exception e) {
                log.warn("Không thể xóa shipper.quan1_1: {}", e.getMessage());
            }
        });
        userRepository.findByEmail("shipper.quan1_2@websachcu.vn").ifPresent(u -> {
            try {
                userRepository.delete(u);
                log.info("Đã xóa bỏ tài khoản shipper cũ: shipper.quan1_2@websachcu.vn");
            } catch (Exception e) {
                log.warn("Không thể xóa shipper.quan1_2: {}", e.getMessage());
            }
        });

        // 4 tài khoản Shipper cho cơ sở Thủ Đức (2 Tiêu chuẩn, 2 Hỏa tốc)
        ensureDemoShipperAccount("shipper.thuduc1@websachcu.vn", "Shipper Thủ Đức (Tiêu Chuẩn 1) - Nguyễn Văn Nam", "0961111111", bThuduc, "GHN_STANDARD");
        ensureDemoShipperAccount("shipper.thuduc.tieuchuan@websachcu.vn", "Shipper Thủ Đức (Tiêu Chuẩn 2) - Lê Văn Tài", "0961222222", bThuduc, "GHN_STANDARD");

        ensureDemoShipperAccount("shipper.thuduc2@websachcu.vn", "Shipper Thủ Đức (Hỏa Tốc 1) - Trần Văn Bình", "0962222222", bThuduc, "GHN_EXPRESS");
        ensureDemoShipperAccount("shipper.thuduc.hoatoc@websachcu.vn", "Shipper Thủ Đức (Hỏa Tốc 2) - Hoàng Văn Dũng", "0962333333", bThuduc, "GHN_EXPRESS");

        // 2 tài khoản Shipper cho cơ sở Phú Nhuận (1 Tiêu chuẩn, 1 Hỏa tốc)
        ensureDemoShipperAccount("shipper.phunhuan.tieuchuan@websachcu.vn", "Shipper Phú Nhuận (Tiêu Chuẩn) - Lê Hoàng Long", "0964444444", bPhunhuan, "GHN_STANDARD");
        ensureDemoShipperAccount("shipper.phunhuan.hoatoc@websachcu.vn", "Shipper Phú Nhuận (Hỏa Tốc) - Phạm Quốc Huy", "0965555555", bPhunhuan, "GHN_EXPRESS");
    }

    private void ensureDemoAccount(String email, String fullName, String phone, Role role, Branch branch) {
        User user = userRepository.findByEmail(email).orElseGet(() -> User.builder()
                .email(email)
                .fullName(fullName)
                .phone(phone)
                .role(role)
                .branch(branch)
                .status(UserStatus.ACTIVE)
                .password(passwordEncoder.encode("123456"))
                .build());

        boolean changed = user.getId() == null;
        if (!passwordEncoder.matches("123456", user.getPassword())) {
            user.setPassword(passwordEncoder.encode("123456"));
            changed = true;
        }
        if (user.getStatus() != UserStatus.ACTIVE) {
            user.setStatus(UserStatus.ACTIVE);
            changed = true;
        }
        if (user.getRole() == null || user.getRole().getName() != role.getName()) {
            user.setRole(role);
            changed = true;
        }
        if (branch != null && user.getBranch() == null) {
            user.setBranch(branch);
            changed = true;
        }

        if (changed) {
            userRepository.save(user);
            log.info("Đã đồng bộ tài khoản demo: {}", email);
        }
    }
}
