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
        log.info("Dang khoi tao du lieu mau cho WebSachCu...");

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
                        .address("1 Vo Van Ngan, Thu Duc, TP.HCM")
                        .phone("0901234567")
                        .email("thuduc@websach.com")
                        .status(BranchStatus.ACTIVE)
                        .appDiscountPercent(10.0)
                        .build())
        );

        Branch b2 = branchRepository.save(Branch.builder()
                .name("Sách Cũ Chi Nhánh Quận 1")
                .address("100 Nguyen Hue, Quan 1, TP.HCM")
                .phone("0907654321")
                .email("quan1@websach.com")
                .status(BranchStatus.ACTIVE)
                .appDiscountPercent(12.0)
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
            b1.setDescription("Cửa hàng chuyên sách cũ, sách xưa và các ấn bản đã qua sử dụng.");
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
                        .fullName("Khách Hàng Nguyen Van A")
                        .email("user@websach.com")
                        .password(passwordEncoder.encode("123456"))
                        .phone("0955555555")
                        .role(userRole)
                        .status(UserStatus.ACTIVE)
                        .build())
        );

        // 4. Categories
        Category cat1 = categoryRepository.save(Category.builder().name("Văn Học Việt Nam").slug("van-hoc-viet-nam").description("Cac tac phẩm van hoc noi tieng").active(true).build());
        Category cat2 = categoryRepository.save(Category.builder().name("Sách Trước 1975").slug("sach-truoc-1975").description("Cac ban sach cu, sach xua quy hiem").active(true).build());
        Category cat3 = categoryRepository.save(Category.builder().name("Kinh Tế - Kỹ Năng").slug("kinh-te-ky-nang").description("Sach kinh doanh ky nang").active(true).build());

        // 5. Author & Publisher
        Author author1 = authorRepository.save(Author.builder().name("Tô Hoài").bio("Nha van noi tieng").build());
        Publisher pub1 = publisherRepository.save(Publisher.builder().name("NXB Kim Đồng").address("Ha Noi").build());

        // 6. Books
        Book book1 = bookRepository.save(Book.builder()
                .isbn("9786042078888")
                .title("Dế Mèn Phiêu Lưu Ký")
                .description("Tac pham van hoc kinh dien cho thieu nhi va nguoi lon")
                .category(cat1)
                .author(author1)
                .publisher(pub1)
                .publishYear(1985)
                .language("Tiếng Việt")
                .coverUrl("https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500&q=80")
                .build());

        Book book2 = bookRepository.save(Book.builder()
                .isbn("9786045612345")
                .title("Số Đỏ (Bản Sách Cũ 1990)")
                .description("Tieu thuyet truyen hinh cua Vu Trong Phung")
                .category(cat2)
                .author(author1)
                .publisher(pub1)
                .publishYear(1990)
                .language("Tiếng Việt")
                .coverUrl("https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500&q=80")
                .build());

        // 7. BookCopies
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
                    .shippingAddress("12 Võ Văn Ngân, Thủ Đức, TP.HCM")
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

        log.info("Khoi tao du lieu mau thanh cong! San sang su dung.");
    }
}
