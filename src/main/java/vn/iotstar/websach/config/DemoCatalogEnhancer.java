package vn.iotstar.websach.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.Author;
import vn.iotstar.websach.entity.Book;
import vn.iotstar.websach.entity.BookCopy;
import vn.iotstar.websach.entity.Category;
import vn.iotstar.websach.entity.OrderItem;
import vn.iotstar.websach.entity.Publisher;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.BookCondition;
import vn.iotstar.websach.entity.enums.BookCopyStatus;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.entity.enums.PaymentMethod;
import vn.iotstar.websach.entity.enums.PaymentStatus;
import vn.iotstar.websach.repository.AuthorRepository;
import vn.iotstar.websach.repository.BookCopyRepository;
import vn.iotstar.websach.repository.BookRepository;
import vn.iotstar.websach.repository.CategoryRepository;
import vn.iotstar.websach.repository.DeliveryAssignmentRepository;
import vn.iotstar.websach.repository.PublisherRepository;
import vn.iotstar.websach.repository.OrderItemRepository;
import vn.iotstar.websach.repository.OrderRepository;
import vn.iotstar.websach.repository.ReviewRepository;
import vn.iotstar.websach.repository.UserRepository;

import java.util.List;
import java.util.Map;

/**
 * Nâng cấp bộ dữ liệu minh họa cũ một cách idempotent.
 *
 * <p>Chỉ chạy khi nhận ra ISBN đánh dấu của bộ dữ liệu mẫu, vì vậy database thật
 * trống hoặc catalog do người dùng tự tạo sẽ không bị chèn sách demo.</p>
 */
@Component
@Order(2)
@RequiredArgsConstructor
@Slf4j
public class DemoCatalogEnhancer implements CommandLineRunner {

    private static final String DEMO_MARKER_ISBN = "9786042078888";

    private static final Map<String, String> LEGACY_COVERS = Map.of(
            "9786042078888", "https://cdn1.fahasa.com/media/catalog/product/d/e/de-men-phieu-luu-ki_bia-cung_to.jpg",
            "9786045612345", "https://cdn1.fahasa.com/media/catalog/product/8/9/8935230010784_1.jpg",
            "9786048991111", "https://product.hstatic.net/1000237375/product/bia_truoc_08_b4497226ce524fd79a1d81b9086b99a9_master.jpg",
            "9786047722222", "https://cdn0.fahasa.com/media/catalog/product/8/9/8934974158448.jpg",
            "9786046633333", "https://cdn1.fahasa.com/media/catalog/product/8/9/8935230006015.jpg",
            "9786045544444", "https://bizweb.dktcdn.net/thumb/1024x1024/100/576/749/products/1-09e4d57d2e8d45f6ae65b8936811fa81.jpg?v=1760791370697",
            "9786040007777", "https://cdn1.fahasa.com/media/catalog/product/9/7/9786040392503.jpg"
    );

    private final BookRepository bookRepository;
    private final BookCopyRepository bookCopyRepository;
    private final CategoryRepository categoryRepository;
    private final AuthorRepository authorRepository;
    private final PublisherRepository publisherRepository;
    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final ReviewRepository reviewRepository;
    private final DeliveryAssignmentRepository deliveryAssignmentRepository;

    @Override
    @Transactional
    public void run(String... args) {
        repairDoraemonAuthor();

        if (bookRepository.findFirstByIsbn(DEMO_MARKER_ISBN).isEmpty()) {
            return;
        }

        removeInconsistentDemoOrder("DEMO-SOLD-001");
        LEGACY_COVERS.forEach(this::replaceGenericCover);

        Category literature = categoryRepository.findBySlug("van-hoc-viet-nam").orElse(null);
        Category skills = categoryRepository.findBySlug("kinh-te-ky-nang").orElse(null);
        User literatureVendor = firstExistingUser(
                "vendor.thuduc1@websachcu.vn",
                "vendor.phunhuan1@websachcu.vn");
        User skillsVendor = firstExistingUser(
                "vendor.quan1_1@websachcu.vn",
                "vendor.phunhuan1@websachcu.vn");

        if (literature == null || skills == null || literatureVendor == null || skillsVendor == null
                || literatureVendor.getBranch() == null || skillsVendor.getBranch() == null) {
            log.warn("Không đủ dữ liệu chi nhánh/vendor để bổ sung catalog sách mẫu.");
            return;
        }

        ensureBook("8935235200524", "Nhà Giả Kim", "Paulo Coelho", "NXB Văn Học",
                literature, literatureVendor, 1988,
                "Tiểu thuyết giàu tính biểu tượng về hành trình theo đuổi ước mơ và khám phá chính mình.",
                "https://is1-ssl.mzstatic.com/image/thumb/Publication69/v4/10/23/8c/10238cf2-8bdb-4ad0-853b-715e5a9431d2/nha_gia_kim_paulo_coelho.png/1200x1200wz.jpg",
                52000.0, 8, BookCondition.VERY_GOOD);
        ensureBook("9786043945674", "Cây Cam Ngọt Của Tôi", "José Mauro de Vasconcelos", "NXB Hội Nhà Văn",
                literature, literatureVendor, 2020,
                "Câu chuyện cảm động về tuổi thơ, tình yêu thương và hành trình trưởng thành của cậu bé Zezé.",
                "https://bizweb.dktcdn.net/thumb/1024x1024/100/567/082/products/image-217480.jpg?v=1747326206683",
                79000.0, 7, BookCondition.LIKE_NEW);
        ensureBook("9786045678906", "Tuổi Trẻ Đáng Giá Bao Nhiêu?", "Rosie Nguyễn", "NXB Hội Nhà Văn",
                skills, skillsVendor, 2021,
                "Những chia sẻ thực tế về học tập, trải nghiệm, làm việc và cách sống trọn vẹn với tuổi trẻ.",
                "https://salt.tikicdn.com/cache/750x750/ts/product/66/51/30/c2815ed03a54650766df95003ed0d809.jpg",
                68000.0, 11, BookCondition.VERY_GOOD);
        ensureBook("9786041122336", "Cho Tôi Xin Một Vé Đi Tuổi Thơ", "Nguyễn Nhật Ánh", "NXB Trẻ",
                literature, literatureVendor, 2008,
                "Một chuyến tàu hóm hỉnh và trong trẻo trở về thế giới tuổi thơ của bốn người bạn nhỏ.",
                "https://cdn1.fahasa.com/media/catalog/product/i/m/image_195509_1_20306.jpg",
                59000.0, 9, BookCondition.GOOD);
        ensureBook("9786043344557", "Mắt Biếc", "Nguyễn Nhật Ánh", "NXB Trẻ",
                literature, literatureVendor, 2019,
                "Câu chuyện tình đầu trong trẻo, day dứt giữa Ngạn và Hà Lan tại làng Đo Đo.",
                "https://www.sachkhaitri.com/Data/Sites/2/Product/65549/mat-biec-tai-ban-2019.jpg",
                72000.0, 6, BookCondition.LIKE_NEW);
        ensureBook("9786049988773", "Atomic Habits - Thay Đổi Tí Hon, Hiệu Quả Bất Ngờ", "James Clear", "NXB Thế Giới",
                skills, skillsVendor, 2023,
                "Phương pháp thực tế giúp xây dựng thói quen tốt bằng những thay đổi nhỏ nhưng bền vững.",
                "https://cdn1.fahasa.com/media/catalog/product/i/m/image_195509_1_43387.jpg",
                115000.0, 10, BookCondition.LIKE_NEW);
        ensureBook("9786047766550", "Rừng Na Uy", "Haruki Murakami", "NXB Hội Nhà Văn",
                literature, literatureVendor, 2024,
                "Tiểu thuyết sâu lắng về tình yêu, tuổi trẻ, ký ức và mất mát của Haruki Murakami.",
                "https://cdn1.fahasa.com/media/catalog/product/8/9/8935235245815.jpg",
                128000.0, 5, BookCondition.VERY_GOOD);
        ensureBook("9786044455665", "Muôn Kiếp Nhân Sinh - Tập 1", "Nguyên Phong", "First News - Trí Việt",
                skills, skillsVendor, 2020,
                "Những câu chuyện và chiêm nghiệm về nhân quả, luân hồi cùng cách con người lựa chọn lối sống thiện lành.",
                "https://nxbhcm.com.vn/Image/Biasach/muonkiepnhansinh.png",
                105000.0, 7, BookCondition.GOOD);

        // Dữ liệu lịch sử bán hàng có thật trong database để khu vực Guest
        // "đã bán trên 10 cuốn" luôn có nội dung minh họa đúng điều kiện.
        ensureHistoricalSale("9786047722222", "DEMO-SOLD-002", 14);
        ensureHistoricalSale("9786040007777", "DEMO-SOLD-003", 12);

        log.info("Đã đồng bộ ảnh bìa và bổ sung catalog sách mẫu phong phú.");
    }

    private void repairDoraemonAuthor() {
        bookRepository.findFirstByIsbn("9786045544444").ifPresent(book -> {
            Author author = authorRepository.findByName("Fujiko F. Fujio")
                    .orElseGet(() -> authorRepository.save(Author.builder()
                            .name("Fujiko F. Fujio")
                            .bio("Bút danh của họa sĩ manga Hiroshi Fujimoto, đồng sáng tạo bộ truyện Doraemon.")
                            .build()));
            if (book.getAuthor() == null || !author.getId().equals(book.getAuthor().getId())) {
                book.setAuthor(author);
                bookRepository.save(book);
                log.info("Đã sửa tác giả sách Doraemon thành Fujiko F. Fujio.");
            }
        });
    }

    private void replaceGenericCover(String isbn, String coverUrl) {
        bookRepository.findFirstByIsbn(isbn).ifPresent(book -> {
            if (isGenericCover(book.getCoverUrl())) {
                book.setCoverUrl(coverUrl);
                bookRepository.save(book);
            }
            for (BookCopy copy : bookCopyRepository.findByBookId(book.getId())) {
                if (isGenericCover(copy.getImageUrl())) {
                    copy.setImageUrl(coverUrl);
                    bookCopyRepository.save(copy);
                }
            }
        });
    }

    private boolean isGenericCover(String url) {
        return url == null || url.isBlank() || url.contains("images.unsplash.com");
    }

    private User firstExistingUser(String... emails) {
        for (String email : emails) {
            User user = userRepository.findByEmail(email).orElse(null);
            if (user != null) {
                return user;
            }
        }
        return null;
    }

    private void ensureBook(String isbn,
                            String title,
                            String authorName,
                            String publisherName,
                            Category category,
                            User vendor,
                            int publishYear,
                            String description,
                            String coverUrl,
                            double sellingPrice,
                            int quantity,
                            BookCondition condition) {
        Author author = authorRepository.findByName(authorName)
                .orElseGet(() -> authorRepository.save(Author.builder().name(authorName).build()));
        Publisher publisher = publisherRepository.findByName(publisherName)
                .orElseGet(() -> publisherRepository.save(Publisher.builder().name(publisherName).build()));

        Book book = bookRepository.findFirstByIsbn(isbn).orElseGet(() -> Book.builder().isbn(isbn).build());
        book.setTitle(title);
        book.setDescription(description);
        book.setCategory(category);
        book.setAuthor(author);
        book.setPublisher(publisher);
        book.setPublishYear(publishYear);
        book.setLanguage("Tiếng Việt");
        book.setCoverUrl(coverUrl);
        book = bookRepository.save(book);

        List<BookCopy> copies = bookCopyRepository.findByBookId(book.getId());
        boolean alreadyStockedByVendor = copies.stream()
                .anyMatch(copy -> copy.getSeller() != null && copy.getSeller().getId().equals(vendor.getId()));
        if (!alreadyStockedByVendor) {
            bookCopyRepository.save(BookCopy.builder()
                    .book(book)
                    .branch(vendor.getBranch())
                    .seller(vendor)
                    .conditionRating(condition)
                    .purchasePrice((double) Math.round(sellingPrice * 0.62))
                    .sellingPrice(sellingPrice)
                    .quantity(quantity)
                    .status(BookCopyStatus.AVAILABLE)
                    .note("Sách cũ tuyển chọn, bìa đẹp, ruột đầy đủ và đã kiểm tra chất lượng.")
                    .imageUrl(coverUrl)
                    .build());
        }
    }

    private void ensureHistoricalSale(String isbn, String orderCode, int targetSoldQuantity) {
        Book book = bookRepository.findFirstByIsbn(isbn).orElse(null);
        User customer = userRepository.findByEmail("user@websachcu.vn").orElse(null);
        if (book == null || customer == null) {
            return;
        }

        long currentSold = orderItemRepository.getSoldQuantityByBookId(book.getId());
        if (currentSold > 10 || orderRepository.findByOrderCode(orderCode).isPresent()) {
            return;
        }

        BookCopy copy = bookCopyRepository.findByBookId(book.getId()).stream()
                .filter(item -> item.getBranch() != null)
                .findFirst()
                .orElse(null);
        if (copy == null) {
            return;
        }

        int historyQuantity = Math.max(1, targetSoldQuantity - (int) currentSold);
        double price = copy.getSellingPrice() == null ? 0.0 : copy.getSellingPrice();
        double subtotal = price * historyQuantity;
        double commissionRate = copy.getBranch().getAppDiscountPercent() == null
                ? 0.10 : copy.getBranch().getAppDiscountPercent() / 100.0;

        vn.iotstar.websach.entity.Order historicalOrder = orderRepository.save(
                vn.iotstar.websach.entity.Order.builder()
                .orderCode(orderCode)
                .customer(customer)
                .branch(copy.getBranch())
                .receiverName(customer.getFullName())
                .receiverPhone(customer.getPhone())
                .shippingAddress("Đơn lịch sử dùng minh họa sản phẩm bán chạy")
                .totalAmount(subtotal)
                .shippingFee(0.0)
                .discountAmount(0.0)
                .appCommissionAmount(subtotal * commissionRate)
                .finalAmount(subtotal)
                .paymentMethod(PaymentMethod.COD)
                .paymentStatus(PaymentStatus.PAID)
                .orderStatus(OrderStatus.DELIVERED)
                .managerArchived(false)
                .note("Dữ liệu lịch sử bán hàng mẫu; kho hiện tại đã được nhập lại.")
                .build());

        orderItemRepository.save(OrderItem.builder()
                .order(historicalOrder)
                .bookCopy(copy)
                .quantity(historyQuantity)
                .price(price)
                .build());
    }

    /** Xóa đơn bán mẫu bị lệch giữa trạng thái giao hàng và phân công Shipper. */
    private void removeInconsistentDemoOrder(String orderCode) {
        vn.iotstar.websach.entity.Order order = orderRepository.findByOrderCode(orderCode).orElse(null);
        if (order == null) {
            return;
        }

        Long orderId = order.getId();
        deliveryAssignmentRepository.findByOrderId(orderId).ifPresent(deliveryAssignmentRepository::delete);
        reviewRepository.deleteAll(reviewRepository.findByOrderItemOrderId(orderId));
        orderItemRepository.deleteAll(orderItemRepository.findByOrderId(orderId));
        orderRepository.delete(order);
        orderRepository.flush();
        log.info("Đã xóa đơn demo {} vì trạng thái giao hàng không khớp phân công Shipper.", orderCode);
    }
}
