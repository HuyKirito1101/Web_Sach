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
        if (bookRepository.count() > 0) {
            log.info("Dữ liệu đã tồn tại, bỏ qua khởi tạo lại.");
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

        User vendor = userRepository.findByEmail("vendor@websach.com").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Chủ Cửa Hàng Sách Cũ")
                        .email("vendor@websach.com")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0933333333")
                        .role(vendorRole)
                        .branch(b1)
                        .status(UserStatus.ACTIVE)
                        .build())
        );
        if (b1.getOwner() == null) {
            b1.setOwner(vendor);
            branchRepository.save(b1);
        }

        userRepository.findByEmail("shipper@websach.com").orElseGet(() ->
                userRepository.save(User.builder()
                        .fullName("Nhân Viên Giao Hàng Shipper")
                        .email("shipper@websach.com")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0966666666")
                        .role(shipperRole)
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

        // 4. Categories
        Category cat1 = categoryRepository.save(Category.builder().name("Văn Học Việt Nam").slug("van-hoc-viet-nam").description("Các tác phẩm văn học nổi tiếng trong nước qua các thời kỳ.").active(true).build());
        Category cat2 = categoryRepository.save(Category.builder().name("Sách Trước 1975").slug("sach-truoc-1975").description("Các bản sách cũ, ấn bản xưa quý hiếm trước năm 1975.").active(true).build());
        Category cat3 = categoryRepository.save(Category.builder().name("Kinh Tế - Kỹ Năng").slug("kinh-te-ky-nang").description("Sách kinh doanh, quản trị và phát triển bản thân.").active(true).build());
        Category cat4 = categoryRepository.save(Category.builder().name("Truyện Tranh & Manga Cũ").slug("truyen-tranh-manga").description("Bộ truyện tranh, manga sưu tầm xưa và cũ.").active(true).build());
        Category cat5 = categoryRepository.save(Category.builder().name("Giáo Trình & Ngoại Ngữ").slug("giao-trinh-ngoai-ngu").description("Giáo trình đại học, sách học tiếng Anh, Nhật, Trung.").active(true).build());

        // 5. Authors & Publishers
        Author a1 = authorRepository.save(Author.builder().name("Tô Hoài").bio("Nhà văn lớn của văn học hiện đại Việt Nam.").build());
        Author a2 = authorRepository.save(Author.builder().name("Vũ Trọng Phụng").bio("Ông vua văn xuôi trào phúng Việt Nam.").build());
        Author a3 = authorRepository.save(Author.builder().name("Ngô Tất Tố").bio("Nhà văn, nhà báo, nhà nghiên cứu văn hóa nổi tiếng.").build());
        Author a4 = authorRepository.save(Author.builder().name("Nguyễn Nhật Ánh").bio("Tác giả của nhiều tựa sách tuổi học trò được yêu thích.").build());
        Author a5 = authorRepository.save(Author.builder().name("Dale Carnegie").bio("Tác giả hàng đầu thế giới về dắc nhân tâm và giao tiếp.").build());

        Publisher p1 = publisherRepository.save(Publisher.builder().name("NXB Kim Đồng").address("Hà Nội").build());
        Publisher p2 = publisherRepository.save(Publisher.builder().name("NXB Văn Học").address("Hà Nội").build());
        Publisher p3 = publisherRepository.save(Publisher.builder().name("NXB Trẻ").address("TP.HCM").build());
        Publisher p4 = publisherRepository.save(Publisher.builder().name("NXB Cổ Phong (Trước 1975)").address("Sài Gòn").build());

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
                .category(cat2)
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

        // 7. BookCopies across Branches
        BookCopy copy1 = bookCopyRepository.save(BookCopy.builder()
                .book(book1)
                .branch(b1)
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
                .branch(b1)
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
                .branch(b2)
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
                .conditionRating(BookCondition.GOOD)
                .purchasePrice(20000.0)
                .sellingPrice(35000.0)
                .quantity(7)
                .status(BookCopyStatus.AVAILABLE)
                .note("Truyện tranh cũ 1996, ruột sạch sẽ đủ trang")
                .imageUrl("https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=500&q=80")
                .build());

        // 8. Shipping Providers & App Discounts
        ShippingProvider ghn = shippingProviderRepository.save(ShippingProvider.builder().name("Giao Hàng Nhanh (GHN)").phone("19001234").baseFee(25000.0).active(true).build());
        shippingProviderRepository.save(ShippingProvider.builder().name("Viettel Post").phone("19005678").baseFee(22000.0).active(true).build());

        appDiscountRepository.save(AppDiscount.builder().code("SACHCU10").discountPercent(10.0).maxDiscountAmount(30000.0).minOrderValue(100000.0).startDate(LocalDate.now()).endDate(LocalDate.now().plusMonths(3)).active(true).build());

        promotionRepository.save(Promotion.builder()
                .title("Tuần lễ sách cũ chất lượng")
                .branch(b1).discountPercent(10.0)
                .startDate(LocalDate.now()).endDate(LocalDate.now().plusDays(14)).active(true).build());

        if (orderRepository.count() == 0) {
            Order order = orderRepository.save(Order.builder()
                    .orderCode("DH-DEMO-001").customer(customer).branch(b1).shippingProvider(ghn)
                    .receiverName(customer.getFullName()).receiverPhone(customer.getPhone())
                    .shippingAddress("12 Võ Văn Ngân, TP. Thủ Đức, TP.HCM")
                    .totalAmount(65000.0).shippingFee(25000.0).discountAmount(0.0)
                    .appCommissionAmount(6500.0).finalAmount(90000.0)
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
