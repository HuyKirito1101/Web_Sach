package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import vn.iotstar.websach.dto.ProductSalesDTO;
import vn.iotstar.websach.dto.VendorDashboardDTO;
import vn.iotstar.websach.dto.VendorProductRequest;
import vn.iotstar.websach.dto.VendorRevenueAnalyticsDTO;
import vn.iotstar.websach.dto.VendorShipperDTO;
import vn.iotstar.websach.dto.MasterBookRequest;
import vn.iotstar.websach.entity.*;
import vn.iotstar.websach.entity.enums.*;
import vn.iotstar.websach.repository.*;
import vn.iotstar.websach.service.CloudinaryService;
import vn.iotstar.websach.service.RealtimeNotificationService;
import vn.iotstar.websach.service.VendorService;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class VendorServiceImpl implements VendorService {
    private final UserRepository userRepository;
    private final BranchRepository branchRepository;
    private final BookRepository bookRepository;
    private final BookCopyRepository bookCopyRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final PromotionRepository promotionRepository;
    private final SellRequestRepository sellRequestRepository;
    private final CloudinaryService cloudinaryService;
    private final RealtimeNotificationService realtimeNotificationService;
    private final DeliveryAssignmentRepository deliveryAssignmentRepository;
    private final CartItemRepository cartItemRepository;
    private final ShippingProviderRepository shippingProviderRepository;
    private final SellRequestQuoteRepository sellRequestQuoteRepository;
    private final vn.iotstar.websach.service.BookService bookService;

    private User requireVendor(String email) {
        User vendor = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản Vendor"));
        if (vendor.getRole() == null || (
                vendor.getRole().getName() != RoleName.ROLE_VENDOR
                && vendor.getRole().getName() != RoleName.ROLE_ADMIN
                && vendor.getRole().getName() != RoleName.ROLE_MANAGER)) {
            throw new SecurityException("Tài khoản không có quyền Vendor");
        }
        return vendor;
    }

    @Override
    public Branch getShop(String vendorEmail) {
        User vendor = requireVendor(vendorEmail);
        Branch shop = branchRepository.findByOwnerId(vendor.getId()).orElse(null);
        if (shop == null && vendor.getBranch() != null) {
            shop = vendor.getBranch();
        }
        return shop;
    }

    private Branch requireShop(String email) {
        Branch shop = getShop(email);
        if (shop == null) throw new IllegalStateException("Vendor chưa đăng ký cửa hàng");
        return shop;
    }

    private Branch requireActiveShop(String email) {
        Branch shop = requireShop(email);
        if (shop.getStatus() != BranchStatus.ACTIVE) {
            throw new IllegalStateException("Cửa hàng chưa được duyệt hoặc đang bị khóa");
        }
        return shop;
    }

    @Override
    @Transactional
    public Branch saveShop(String vendorEmail, Branch details, MultipartFile logo, MultipartFile cover) {
        User vendor = requireVendor(vendorEmail);
        Branch shop = branchRepository.findByOwnerId(vendor.getId()).orElse(null);
        if (shop == null && vendor.getBranch() != null) {
            shop = vendor.getBranch();
        }
        if (shop == null) {
            shop = Branch.builder().owner(vendor).status(BranchStatus.PENDING).build();
        }
        shop.setName(details.getName());
        shop.setAddress(details.getAddress());
        shop.setPhone(details.getPhone());
        shop.setEmail(details.getEmail());
        shop.setDescription(details.getDescription());
        String logoUrl = cloudinaryService.uploadFile(logo);
        String coverUrl = cloudinaryService.uploadFile(cover);
        if (logoUrl != null) shop.setImageUrl(logoUrl);
        if (coverUrl != null) shop.setCoverUrl(coverUrl);
        Branch saved = branchRepository.save(shop);
        if (vendor.getBranch() == null || !Objects.equals(vendor.getBranch().getId(), saved.getId())) {
            vendor.setBranch(saved);
            userRepository.save(vendor);
        }
        return saved;
    }

    @Override
    public List<BookCopy> getProducts(String vendorEmail) {
        User vendor = requireVendor(vendorEmail);
        return bookCopyRepository.findBySellerId(vendor.getId());
    }

    @Override
    public List<Book> getProductCatalog(String vendorEmail) {
        Map<String, Book> uniqueBooks = new LinkedHashMap<>();
        for (BookCopy copy : getProducts(vendorEmail)) {
            if (copy.getBook() != null && copy.getBook().getTitle() != null
                    && !copy.getBook().getTitle().isBlank()) {
                uniqueBooks.putIfAbsent(copy.getBook().getTitle().trim().toLowerCase(Locale.ROOT), copy.getBook());
            }
        }
        for (Book book : bookRepository.findAll()) {
            if (book.getTitle() != null && !book.getTitle().isBlank()) {
                uniqueBooks.putIfAbsent(book.getTitle().trim().toLowerCase(Locale.ROOT), book);
            }
        }
        return new ArrayList<>(uniqueBooks.values());
    }

    @Override
    @Transactional
    public BookCopy createMasterBookProduct(String vendorEmail,
                                            MasterBookRequest request,
                                            MultipartFile coverFile) {
        User vendor = requireVendor(vendorEmail);
        Branch shop = requireActiveShop(vendorEmail);
        Book book = bookService.createMasterBook(request, coverFile);
        BookCopy copy = BookCopy.builder()
                .book(book)
                .branch(shop)
                .seller(vendor)
                .purchasePrice(request.getPurchasePrice() != null ? request.getPurchasePrice() : 0.0)
                .sellingPrice(request.getSellingPrice() != null && request.getSellingPrice() > 0
                        ? request.getSellingPrice() : 50000.0)
                .quantity(request.getQuantity() != null && request.getQuantity() > 0 ? request.getQuantity() : 1)
                .conditionRating(request.getConditionRating() != null
                        ? request.getConditionRating() : BookCondition.LIKE_NEW)
                .note(request.getNote() != null && !request.getNote().isBlank()
                        ? request.getNote().trim() : "Sản phẩm mới nhập gian hàng")
                .imageUrl(book.getCoverUrl())
                .status(BookCopyStatus.UNPUBLISHED)
                .build();
        return bookCopyRepository.save(copy);
    }

    @Override
    @Transactional
    public BookCopy saveProduct(String vendorEmail, VendorProductRequest request, MultipartFile imageFile) {
        User vendor = requireVendor(vendorEmail);
        Branch shop = requireActiveShop(vendorEmail);
        BookCopy product;
        BookCopyStatus targetStatus = request.getStatus() != null ? request.getStatus() : BookCopyStatus.UNPUBLISHED;

        if (request.getId() == null) {
            List<BookCopy> existingCopies = bookCopyRepository.findBySellerId(vendor.getId());
            Book targetBook = (request.getBookId() != null) ? bookRepository.findById(request.getBookId()).orElse(null) : null;

            if (targetStatus == BookCopyStatus.AVAILABLE) {
                Optional<BookCopy> duplicate = existingCopies.stream()
                        .filter(c -> c.getBook() != null && (
                                Objects.equals(c.getBook().getId(), request.getBookId()) ||
                                (targetBook != null && c.getBook().getTitle() != null && 
                                 c.getBook().getTitle().trim().equalsIgnoreCase(targetBook.getTitle().trim()))
                        )
                                  && c.getConditionRating() == request.getConditionRating()
                                  && (c.getStatus() == BookCopyStatus.AVAILABLE || c.getStatus() == BookCopyStatus.RESERVED))
                        .findFirst();

                if (duplicate.isPresent()) {
                    BookCopy existing = duplicate.get();
                    int addedQty = (request.getQuantity() != null && request.getQuantity() > 0) ? request.getQuantity() : 1;
                    existing.setQuantity((existing.getQuantity() != null ? existing.getQuantity() : 0) + addedQty);
                    existing.setStatus(BookCopyStatus.AVAILABLE);
                    if (request.getSellingPrice() != null && request.getSellingPrice() > 0) {
                        existing.setSellingPrice(request.getSellingPrice());
                    }
                    if (request.getPurchasePrice() != null && request.getPurchasePrice() > 0) {
                        existing.setPurchasePrice(request.getPurchasePrice());
                    }
                    if (request.getNote() != null && !request.getNote().isBlank()) {
                        existing.setNote(request.getNote());
                    }
                    String imageUrl = cloudinaryService.uploadFile(imageFile);
                    if (imageUrl != null) {
                        existing.setImageUrl(imageUrl);
                        if (existing.getBook() != null) {
                            existing.getBook().setCoverUrl(imageUrl);
                            bookRepository.save(existing.getBook());
                        }
                    }
                    return bookCopyRepository.save(existing);
                }
            } else {
                Optional<BookCopy> duplicateUnpublished = existingCopies.stream()
                        .filter(c -> c.getBook() != null && (
                                Objects.equals(c.getBook().getId(), request.getBookId()) ||
                                (targetBook != null && c.getBook().getTitle() != null && 
                                 c.getBook().getTitle().trim().equalsIgnoreCase(targetBook.getTitle().trim()))
                        )
                                  && c.getConditionRating() == request.getConditionRating()
                                  && c.getStatus() == BookCopyStatus.UNPUBLISHED)
                        .findFirst();

                if (duplicateUnpublished.isPresent()) {
                    BookCopy existing = duplicateUnpublished.get();
                    int addedQty = (request.getQuantity() != null && request.getQuantity() > 0) ? request.getQuantity() : 1;
                    existing.setQuantity((existing.getQuantity() != null ? existing.getQuantity() : 0) + addedQty);
                    if (request.getSellingPrice() != null && request.getSellingPrice() > 0) {
                        existing.setSellingPrice(request.getSellingPrice());
                    }
                    if (request.getPurchasePrice() != null && request.getPurchasePrice() > 0) {
                        existing.setPurchasePrice(request.getPurchasePrice());
                    }
                    if (request.getNote() != null && !request.getNote().isBlank()) {
                        existing.setNote(request.getNote());
                    }
                    String imageUrl = cloudinaryService.uploadFile(imageFile);
                    if (imageUrl != null) {
                        existing.setImageUrl(imageUrl);
                        if (existing.getBook() != null) {
                            existing.getBook().setCoverUrl(imageUrl);
                            bookRepository.save(existing.getBook());
                        }
                    }
                    return bookCopyRepository.save(existing);
                }
            }

            Book book = (targetBook != null) ? targetBook : bookRepository.findById(request.getBookId())
                    .orElseThrow(() -> new IllegalArgumentException("Đầu sách không tồn tại"));
            product = BookCopy.builder().book(book).branch(shop).seller(vendor).build();
        } else {
            product = bookCopyRepository.findById(request.getId())
                    .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại"));
            assertOwned(shop, product);
            if (request.getBookId() != null) {
                product.setBook(bookRepository.findById(request.getBookId())
                        .orElseThrow(() -> new IllegalArgumentException("Đầu sách không tồn tại")));
            }
            product.setSeller(vendor);
        }

        if (request.getSellingPrice() == null || request.getSellingPrice() < 0) {
            throw new IllegalArgumentException("Giá bán không hợp lệ");
        }
        if (request.getQuantity() == null || request.getQuantity() < 0) {
            throw new IllegalArgumentException("Tồn kho không hợp lệ");
        }
        product.setConditionRating(request.getConditionRating());
        product.setPurchasePrice(request.getPurchasePrice());
        product.setSellingPrice(request.getSellingPrice());
        product.setQuantity(request.getQuantity());
        product.setNote(request.getNote());

        BookCopyStatus requestedStatus = request.getStatus();
        if (request.getId() == null) {
            product.setStatus(requestedStatus != null ? requestedStatus : BookCopyStatus.UNPUBLISHED);
        } else {
            product.setStatus(request.getQuantity() == 0 ? BookCopyStatus.SOLD : (requestedStatus != null ? requestedStatus : product.getStatus()));
        }

        String imageUrl = cloudinaryService.uploadFile(imageFile);
        if (imageUrl != null) {
            product.setImageUrl(imageUrl);
            if (product.getBook() != null) {
                product.getBook().setCoverUrl(imageUrl);
                bookRepository.save(product.getBook());
            }
        } else if (request.getImageUrl() != null && !request.getImageUrl().isBlank()) {
            product.setImageUrl(request.getImageUrl());
            if (product.getBook() != null) {
                product.getBook().setCoverUrl(request.getImageUrl());
                bookRepository.save(product.getBook());
            }
        }
        return bookCopyRepository.save(product);
    }

    private void assertOwned(Branch shop, BookCopy product) {
        if (product.getBranch() == null || !Objects.equals(shop.getId(), product.getBranch().getId())) {
            throw new SecurityException("Không được thao tác sản phẩm của cửa hàng khác");
        }
    }

    @Override
    @Transactional
    public void hideProduct(String vendorEmail, Long productId) {
        Branch shop = requireActiveShop(vendorEmail);
        BookCopy product = bookCopyRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại"));
        assertOwned(shop, product);
        if (product.getStatus() == BookCopyStatus.AVAILABLE) {
            product.setStatus(BookCopyStatus.RESERVED);
        } else {
            product.setStatus(BookCopyStatus.AVAILABLE);
        }
        bookCopyRepository.save(product);
    }

    @Override
    @Transactional
    public void publishProduct(String vendorEmail, Long productId) {
        Branch shop = requireActiveShop(vendorEmail);
        BookCopy product = bookCopyRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại"));
        assertOwned(shop, product);
        if (product.getQuantity() == null || product.getQuantity() <= 0) {
            throw new IllegalArgumentException("Sản phẩm phải có số lượng tồn kho > 0 để đăng bán");
        }
        if (product.getSellingPrice() == null || product.getSellingPrice() <= 0) {
            throw new IllegalArgumentException("Sản phẩm phải có giá bán > 0 để đăng bán");
        }

        User vendor = requireVendor(vendorEmail);
        List<BookCopy> existingCopies = bookCopyRepository.findBySellerId(vendor.getId());
        Optional<BookCopy> duplicateActive = existingCopies.stream()
                .filter(c -> !Objects.equals(c.getId(), product.getId())
                        && c.getBook() != null && product.getBook() != null
                        && (Objects.equals(c.getBook().getId(), product.getBook().getId())
                            || (c.getBook().getTitle() != null && product.getBook().getTitle() != null
                                && c.getBook().getTitle().trim().equalsIgnoreCase(product.getBook().getTitle().trim())))
                        && c.getConditionRating() == product.getConditionRating()
                        && (c.getStatus() == BookCopyStatus.AVAILABLE || c.getStatus() == BookCopyStatus.RESERVED))
                .findFirst();

        if (duplicateActive.isPresent()) {
            BookCopy mainCopy = duplicateActive.get();
            int addQty = (product.getQuantity() != null) ? product.getQuantity() : 0;
            mainCopy.setQuantity((mainCopy.getQuantity() != null ? mainCopy.getQuantity() : 0) + addQty);
            mainCopy.setStatus(BookCopyStatus.AVAILABLE);
            if (product.getSellingPrice() != null && product.getSellingPrice() > 0) {
                mainCopy.setSellingPrice(product.getSellingPrice());
            }
            if (product.getPurchasePrice() != null && product.getPurchasePrice() > 0) {
                mainCopy.setPurchasePrice(product.getPurchasePrice());
            }
            if (product.getImageUrl() != null && !product.getImageUrl().isBlank()) {
                mainCopy.setImageUrl(product.getImageUrl());
                if (mainCopy.getBook() != null) {
                    mainCopy.getBook().setCoverUrl(product.getImageUrl());
                    bookRepository.save(mainCopy.getBook());
                }
            }
            bookCopyRepository.save(mainCopy);
            try {
                cartItemRepository.findAll().stream()
                        .filter(ci -> ci.getBookCopy() != null && Objects.equals(ci.getBookCopy().getId(), product.getId()))
                        .forEach(cartItemRepository::delete);
                bookCopyRepository.delete(product);
            } catch (Exception e) {
                product.setSeller(null);
                product.setQuantity(0);
                product.setStatus(BookCopyStatus.SOLD);
                bookCopyRepository.save(product);
            }
        } else {
            product.setStatus(BookCopyStatus.AVAILABLE);
            bookCopyRepository.save(product);
        }
    }

    @Override
    @Transactional
    public void unpublishProduct(String vendorEmail, Long productId) {
        Branch shop = requireActiveShop(vendorEmail);
        BookCopy product = bookCopyRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại"));
        assertOwned(shop, product);
        product.setStatus(BookCopyStatus.UNPUBLISHED);
        bookCopyRepository.save(product);
    }

    @Override
    @Transactional
    public void deleteProduct(String vendorEmail, Long productId) {
        Branch shop = requireActiveShop(vendorEmail);
        BookCopy product = bookCopyRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại"));
        assertOwned(shop, product);

        try {
            cartItemRepository.findAll().stream()
                    .filter(ci -> ci.getBookCopy() != null && Objects.equals(ci.getBookCopy().getId(), productId))
                    .forEach(cartItemRepository::delete);
        } catch (Exception ignored) { }

        boolean hasOrders = orderItemRepository.findAll().stream()
                .anyMatch(oi -> oi.getBookCopy() != null && Objects.equals(oi.getBookCopy().getId(), productId));

        if (hasOrders) {
            product.setSeller(null);
            product.setQuantity(0);
            product.setStatus(BookCopyStatus.SOLD);
            bookCopyRepository.save(product);
        } else {
            bookCopyRepository.delete(product);
        }
    }

    @Override
    @Transactional
    public DeliveryAssignment autoAssignBranchShipper(Order order, User assignedBy) {
        // Hệ thống không tự động phân công ngầm; Vendor sẽ chủ động phân công qua modal giao diện
        return null;
    }

    @Override
    @Transactional
    public List<Order> getOrders(String vendorEmail, OrderStatus status) {
        User vendor = requireVendor(vendorEmail);
        Branch shop = requireActiveShop(vendorEmail);
        List<Order> branchOrders = (status != null)
                ? orderRepository.findByBranchIdAndOrderStatus(shop.getId(), status)
                : orderRepository.findByBranchIdOrderByCreatedAtDesc(shop.getId());

        return branchOrders.stream()
                .filter(o -> orderItemRepository.findByOrderId(o.getId()).stream()
                        .anyMatch(item -> item.getBookCopy() != null && item.getBookCopy().getSeller() != null
                                && Objects.equals(item.getBookCopy().getSeller().getId(), vendor.getId())))
                .toList();
    }

    @Override
    public Order getOrder(String vendorEmail, Long orderId) {
        Branch shop = requireActiveShop(vendorEmail);
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Đơn hàng không tồn tại"));
        if (!Objects.equals(order.getBranch().getId(), shop.getId())) {
            throw new SecurityException("Không được xem đơn hàng của cửa hàng khác");
        }
        return order;
    }

    @Override
    public List<OrderItem> getOrderItems(String vendorEmail, Long orderId) {
        getOrder(vendorEmail, orderId);
        return orderItemRepository.findByOrderId(orderId);
    }

    @Override
    public Map<Long, DeliveryAssignment> getOrderAssignments(String vendorEmail, List<Order> orders) {
        Set<Long> allowedOrderIds = getOrders(vendorEmail, null).stream()
                .map(Order::getId)
                .collect(Collectors.toSet());
        Map<Long, DeliveryAssignment> assignments = new HashMap<>();
        for (Order order : orders == null ? List.<Order>of() : orders) {
            if (!allowedOrderIds.contains(order.getId())) {
                continue;
            }
            deliveryAssignmentRepository.findByOrderId(order.getId()).ifPresent(assignment -> {
                if (order.getOrderStatus() == OrderStatus.NEW
                        || order.getOrderStatus() == OrderStatus.CONFIRMED
                        || order.getOrderStatus() == OrderStatus.PACKING) {
                    return;
                }
                if (order.getOrderStatus() == OrderStatus.READY_FOR_PICKUP
                        && (assignment.getStatus() == DeliveryStatus.SHIPPING
                        || assignment.getStatus() == DeliveryStatus.DELIVERED)) {
                    return;
                }
                assignments.put(order.getId(), assignment);
            });
        }
        return assignments;
    }

    @Override
    public Map<Long, DeliveryAssignment> getReturnAssignments(String vendorEmail, List<Order> orders) {
        Set<Long> allowedOrderIds = getReturnOrders(vendorEmail).stream()
                .map(Order::getId)
                .collect(Collectors.toSet());
        Map<Long, DeliveryAssignment> assignments = new HashMap<>();
        for (Order order : orders == null ? List.<Order>of() : orders) {
            if (!allowedOrderIds.contains(order.getId())) {
                continue;
            }
            deliveryAssignmentRepository.findByOrderId(order.getId()).ifPresent(assignment -> {
                if (order.getOrderStatus() == OrderStatus.RETURN_REQUESTED
                        && assignment.getStatus() == DeliveryStatus.DELIVERED
                        && (assignment.getNote() == null
                        || (!assignment.getNote().toLowerCase(Locale.ROOT).contains("thu hồi")
                        && !assignment.getNote().toLowerCase(Locale.ROOT).contains("hoàn trả")))) {
                    return;
                }
                assignments.put(order.getId(), assignment);
            });
        }
        return assignments;
    }

    @Override
    public Optional<DeliveryAssignment> getOrderAssignment(String vendorEmail, Long orderId) {
        getOrder(vendorEmail, orderId);
        return deliveryAssignmentRepository.findByOrderId(orderId);
    }

    @Override
    @Transactional
    public Order confirmManualMomoPayment(String vendorEmail, Long orderId) {
        User vendor = userRepository.findByEmail(vendorEmail)
                .orElseThrow(() -> new SecurityException("Không tìm thấy tài khoản Vendor."));
        if (vendor.getRole() == null || vendor.getRole().getName() != RoleName.ROLE_VENDOR) {
            throw new SecurityException("Chỉ Vendor bán sản phẩm trong đơn mới được xác nhận thanh toán MoMo.");
        }

        Order order = getOrder(vendorEmail, orderId);
        boolean ownsOrderItem = orderItemRepository.findByOrderId(orderId).stream()
                .anyMatch(item -> item.getBookCopy() != null
                        && item.getBookCopy().getSeller() != null
                        && Objects.equals(item.getBookCopy().getSeller().getId(), vendor.getId()));
        if (!ownsOrderItem) {
            throw new SecurityException("Vendor không được xác nhận thanh toán cho đơn hàng không có sản phẩm của mình.");
        }
        if (order.getPaymentMethod() != PaymentMethod.MOMO) {
            throw new IllegalStateException("Đơn hàng này không thanh toán bằng MoMo.");
        }
        if (order.getOrderStatus() == OrderStatus.CANCELLED || order.getOrderStatus() == OrderStatus.REFUNDED) {
            throw new IllegalStateException("Không thể xác nhận thanh toán cho đơn hàng đã hủy hoặc hoàn tiền.");
        }
        if (order.getPaymentStatus() != PaymentStatus.AWAITING_CONFIRMATION) {
            throw new IllegalStateException(order.getPaymentStatus() == PaymentStatus.PAID
                    ? "Đơn hàng đã được xác nhận thanh toán."
                    : "Khách hàng chưa báo đã chuyển tiền.");
        }

        order.setPaymentStatus(PaymentStatus.PAID);
        order.setPaymentConfirmedAt(LocalDateTime.now());
        order.setPaymentConfirmedBy(vendorEmail);
        Order saved = orderRepository.save(order);
        send(order.getBranch().getId(), "Đơn hàng " + order.getOrderCode() + " đã được Vendor xác nhận thanh toán MoMo.");
        return saved;
    }

    @Override
    @Transactional
    public Order updateOrderStatus(String vendorEmail, Long orderId, OrderStatus target) {
        User vendor = requireVendor(vendorEmail);
        Order order = getOrder(vendorEmail, orderId);
        OrderStatus current = order.getOrderStatus();
        if (order.getPaymentMethod() == PaymentMethod.MOMO
                && target != OrderStatus.CANCELLED
                && order.getPaymentStatus() != PaymentStatus.PAID) {
            if (target == OrderStatus.CONFIRMED && order.getPaymentStatus() == PaymentStatus.AWAITING_CONFIRMATION) {
                // Tự động xác nhận thanh toán MoMo khi Vendor duyệt đơn
                order.setPaymentStatus(PaymentStatus.PAID);
                order.setPaymentConfirmedAt(LocalDateTime.now());
                order.setPaymentConfirmedBy(vendorEmail);
                send(order.getBranch().getId(), "Đơn hàng " + order.getOrderCode() + " đã được Vendor xác nhận thanh toán MoMo.");
            } else if (order.getPaymentStatus() == PaymentStatus.PENDING) {
                throw new IllegalStateException("Đơn MoMo chưa thể duyệt vì khách hàng chưa hoàn tất chuyển tiền hoặc chưa bấm xác nhận đã chuyển.");
            } else {
                throw new IllegalStateException("Đơn MoMo chưa được Vendor xác nhận thanh toán.");
            }
        }
        if (order.getPaymentMethod() == PaymentMethod.MOMO
                && target == OrderStatus.CANCELLED
                && order.getPaymentStatus() == PaymentStatus.PAID) {
            throw new IllegalStateException("Đơn MoMo đã thanh toán phải thực hiện quy trình hoàn tiền.");
        }
        boolean allowed = (current == OrderStatus.NEW && (target == OrderStatus.CONFIRMED || target == OrderStatus.CANCELLED))
                || (current == OrderStatus.CONFIRMED && (target == OrderStatus.PACKING || target == OrderStatus.READY_FOR_PICKUP || target == OrderStatus.CANCELLED))
                || (current == OrderStatus.PACKING && target == OrderStatus.READY_FOR_PICKUP)
                || (current == OrderStatus.RETURN_REQUESTED && (target == OrderStatus.RETURNED || target == OrderStatus.REFUNDED))
                || (current == OrderStatus.RETURNED && target == OrderStatus.REFUNDED);
        if (!allowed) {
            throw new IllegalStateException("Vendor không được chuyển trạng thái từ " + current + " sang " + target);
        }
        if (target == OrderStatus.RETURNED) {
            return confirmReturnReceived(vendorEmail, orderId);
        } else if (target == OrderStatus.REFUNDED) {
            return approveRefund(vendorEmail, orderId);
        }

        if (target == OrderStatus.CANCELLED) {
            for (OrderItem item : orderItemRepository.findByOrderId(order.getId())) {
                BookCopy copy = item.getBookCopy();
                if (copy == null || item.getQuantity() == null) continue;
                copy.setQuantity((copy.getQuantity() == null ? 0 : copy.getQuantity()) + item.getQuantity());
                if (copy.getQuantity() > 0 && copy.getStatus() == BookCopyStatus.SOLD) {
                    copy.setStatus(BookCopyStatus.AVAILABLE);
                }
                bookCopyRepository.save(copy);
            }
            if (order.getPaymentMethod() == PaymentMethod.MOMO) {
                order.setPaymentStatus(PaymentStatus.FAILED);
            }
        }
        order.setOrderStatus(target);
        Order saved = orderRepository.save(order);
        send(order.getBranch().getId(), "Đơn hàng #" + order.getOrderCode() + " đã chuyển sang " + target);
        return saved;
    }

    @Override
    public List<VendorShipperDTO> getBranchShippers(String vendorEmail) {
        Branch shop = requireActiveShop(vendorEmail);
        List<User> shippers = userRepository.findByRoleNameAndBranchId(RoleName.ROLE_SHIPPER, shop.getId());
        // Chỉ khi shipper đang trong giai đoạn vận chuyển (SHIPPING) mới coi là bận
        List<DeliveryStatus> busyStatuses = List.of(DeliveryStatus.SHIPPING);

        return shippers.stream().map(u -> {
            Optional<DeliveryAssignment> activeOpt = deliveryAssignmentRepository.findFirstByShipperIdAndStatusIn(u.getId(), busyStatuses);
            boolean busy = activeOpt.isPresent();
            String busyOrderCode = activeOpt.map(a -> a.getOrder() != null ? a.getOrder().getOrderCode() : "N/A").orElse(null);
            String busyStatus = activeOpt.map(a -> a.getStatus().name()).orElse(null);

            return VendorShipperDTO.builder()
                    .id(u.getId())
                    .fullName(u.getFullName())
                    .phone(u.getPhone())
                    .email(u.getEmail())
                    .shippingProvider(u.getShippingProvider())
                    .busy(busy)
                    .busyOrderCode(busyOrderCode)
                    .busyStatus(busyStatus)
                    .build();
        }).toList();
    }

    @Override
    @Transactional
    public DeliveryAssignment assignShipper(String vendorEmail, Long orderId, Long shipperId, String note) {
        User vendor = requireVendor(vendorEmail);
        Order order = getOrder(vendorEmail, orderId);

        DeliveryAssignment assignment = deliveryAssignmentRepository.findByOrderId(order.getId())
                .orElse(DeliveryAssignment.builder().order(order).build());

        if (shipperId == null || shipperId <= 0) {
            throw new IllegalArgumentException("Vui lòng chọn một Shipper nội bộ hợp lệ.");
        }

        User shipper = userRepository.findById(shipperId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy Shipper id: " + shipperId));
        if (shipper.getRole() == null || shipper.getRole().getName() != RoleName.ROLE_SHIPPER) {
            throw new IllegalArgumentException("Tài khoản được chọn không phải Shipper");
        }
        if (shipper.getBranch() == null || !Objects.equals(shipper.getBranch().getId(), order.getBranch().getId())) {
            throw new IllegalArgumentException("Shipper không thuộc cùng chi nhánh với đơn hàng");
        }

        // Ràng buộc đơn vị vận chuyển
        boolean isReturn = (order.getOrderStatus() == OrderStatus.RETURN_REQUESTED || order.getOrderStatus() == OrderStatus.RETURNED);
        if (isReturn) {
            // Đơn thu hồi sách đổi trả: Bắt buộc phân công Shipper Tiêu Chuẩn
            boolean isStandardShipper = shipper.getShippingProvider() != null &&
                    ("GHN_STANDARD".equalsIgnoreCase(shipper.getShippingProvider().getCode())
                    || shipper.getShippingProvider().getName().toLowerCase().contains("tiêu chuẩn"));
            if (!isStandardShipper) {
                throw new IllegalArgumentException("Đơn thu hồi sách hoàn trả bắt buộc phân công Shipper Tiêu Chuẩn!");
            }
        } else {
            // Đơn giao thông thường: Ràng buộc khớp đơn vị vận chuyển giữa shipper và đơn hàng của khách
            if (order.getShippingProvider() != null && shipper.getShippingProvider() != null
                    && !"SPX_EXPRESS".equalsIgnoreCase(order.getShippingProvider().getCode())) {
                String orderCode = order.getShippingProvider().getCode();
                String shipperCode = shipper.getShippingProvider().getCode();
                if (!Objects.equals(orderCode, shipperCode)) {
                    throw new IllegalArgumentException("Khách hàng đã chọn hình thức '" + order.getShippingProvider().getName() +
                            "'. Vui lòng phân công nhân viên thuộc đúng đơn vị vận chuyển này (không thể phân cho nhân viên " + shipper.getShippingProvider().getName() + ")!");
                }
            }
        }

        // Ràng buộc shipper đã từng từ chối đơn hàng này
        if (assignment.hasShipperRejected(shipperId)) {
            throw new IllegalStateException("Shipper " + shipper.getFullName() + " đã từng từ chối nhận đơn hàng này trước đó. Vui lòng phân công cho shipper khác!");
        }

        // Ràng buộc Shipper bận
        // Chỉ khi shipper đang trong giai đoạn vận chuyển (SHIPPING) mới coi là bận
        List<DeliveryStatus> busyStatuses = List.of(DeliveryStatus.SHIPPING);
        Optional<DeliveryAssignment> ongoing = deliveryAssignmentRepository.findFirstByShipperIdAndStatusIn(shipperId, busyStatuses);
        if (ongoing.isPresent()) {
            throw new IllegalStateException("Shipper " + shipper.getFullName() + " hiện đang trong giai đoạn vận chuyển đơn hàng #" + ongoing.get().getOrder().getOrderCode() + ". Không thể phân công cho đến khi hoàn thành giao đơn hiện tại!");
        }

        assignment.setShipper(shipper);
        assignment.setAssignedBy(vendor);
        assignment.setStatus(DeliveryStatus.ASSIGNED); // Chuyển sang trạng thái CHỜ shipper xác nhận
        assignment.setAssignedAt(LocalDateTime.now());
        assignment.setFailureReason(null); // Xóa lý do từ chối cũ
        if (note != null && !note.isBlank()) {
            assignment.setNote(note.trim());
        } else if (order.getOrderStatus() == OrderStatus.RETURN_REQUESTED) {
            assignment.setNote("Thu hồi sách hoàn trả từ khách tại: " + (order.getReturnAddress() != null ? order.getReturnAddress() : order.getShippingAddress()));
        } else {
            assignment.setNote("Lấy hàng tại cửa hàng: " + order.getBranch().getName());
        }
        DeliveryAssignment saved = deliveryAssignmentRepository.save(assignment);
        send(order.getBranch().getId(), "Đơn hàng #" + order.getOrderCode() + " đã phân công Shipper " + shipper.getFullName() + " (Đang chờ nhận đơn)");
        return saved;
    }

    @Override
    @Transactional
    public DeliveryAssignment revokeAssignment(String vendorEmail, Long orderId) {
        User vendor = requireVendor(vendorEmail);
        Order order = getOrder(vendorEmail, orderId);
        DeliveryAssignment assignment = deliveryAssignmentRepository.findByOrderId(order.getId())
                .orElseThrow(() -> new IllegalArgumentException("Đơn hàng chưa có thông tin phân công vận chuyển"));

        if (assignment.getStatus() != DeliveryStatus.ASSIGNED) {
            throw new IllegalStateException("Chỉ có thể thu hồi phân công khi đơn đang ở trạng thái 'Chờ Shipper xác nhận'");
        }

        String oldShipperName = assignment.getShipper() != null ? assignment.getShipper().getFullName() : "Shipper";
        assignment.setShipper(null);
        assignment.setStatus(DeliveryStatus.CANCELLED);
        assignment.setCompletedAt(LocalDateTime.now());
        assignment.setFailureReason("Vendor đã thu hồi phân công để điều phối shipper khác");

        boolean isReturn = (order.getOrderStatus() == OrderStatus.RETURN_REQUESTED || order.getOrderStatus() == OrderStatus.RETURNED);
        if (!isReturn) {
            order.setOrderStatus(OrderStatus.READY_FOR_PICKUP);
        } else {
            order.setOrderStatus(OrderStatus.RETURN_REQUESTED);
        }
        order.setNote((order.getNote() != null ? order.getNote() + " | " : "") +
                "Vendor đã thu hồi phân công từ " + oldShipperName + " lúc " +
                LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM")));

        orderRepository.save(order);
        DeliveryAssignment saved = deliveryAssignmentRepository.save(assignment);
        send(order.getBranch().getId(), "Đơn hàng #" + order.getOrderCode() + ": Đã thu hồi phân công giao hàng");
        return saved;
    }

    @Override
    public List<Order> getReturnOrders(String vendorEmail) {
        User vendor = requireVendor(vendorEmail);
        Branch shop = requireActiveShop(vendorEmail);
        return orderRepository.findByBranchIdOrderByCreatedAtDesc(shop.getId()).stream()
                .filter(o -> o.getOrderStatus() == OrderStatus.RETURN_REQUESTED
                        || o.getOrderStatus() == OrderStatus.RETURNED
                        || o.getOrderStatus() == OrderStatus.REFUNDED)
                .filter(o -> orderItemRepository.findByOrderId(o.getId()).stream()
                        .anyMatch(item -> item.getBookCopy() != null && item.getBookCopy().getSeller() != null
                                && Objects.equals(item.getBookCopy().getSeller().getId(), vendor.getId())))
                .toList();
    }

    @Override
    @Transactional
    public Order confirmReturnReceived(String vendorEmail, Long orderId) {
        Order order = getOrder(vendorEmail, orderId);
        if (order.getOrderStatus() != OrderStatus.RETURN_REQUESTED) {
            throw new IllegalStateException("Chỉ xác nhận nhận lại sách khi đơn đang ở trạng thái RETURN_REQUESTED");
        }

        boolean isShipper = "SHIPPER".equalsIgnoreCase(order.getReturnMethod());
        if (isShipper) {
            DeliveryAssignment assignment = deliveryAssignmentRepository.findByOrderId(order.getId())
                    .orElseThrow(() -> new IllegalStateException("Đơn hoàn trả qua Shipper cần được phân công Shipper trước khi nhận hàng!"));
            if (assignment.getShipper() == null) {
                throw new IllegalStateException("Đơn hoàn trả chưa có Shipper nhận phân công!");
            }
            if (assignment.getStatus() != DeliveryStatus.DELIVERED) {
                throw new IllegalStateException("Shipper chưa giao sách hoàn về trụ sở (Trạng thái hiện tại: " + assignment.getStatus() + "). Vui lòng đợi Shipper giao sách đến trụ sở trước khi xác nhận!");
            }
        }

        order.setOrderStatus(OrderStatus.RETURNED);
        List<OrderItem> items = orderItemRepository.findByOrderId(order.getId());
        for (OrderItem item : items) {
            BookCopy copy = item.getBookCopy();
            if (copy != null && copy.getQuantity() != null && item.getQuantity() != null) {
                copy.setQuantity(copy.getQuantity() + item.getQuantity());
                if (copy.getStatus() == BookCopyStatus.SOLD && copy.getQuantity() > 0) {
                    copy.setStatus(BookCopyStatus.AVAILABLE);
                }
                bookCopyRepository.save(copy);
            }
        }
        Order saved = orderRepository.save(order);
        send(order.getBranch().getId(), "Đơn hàng #" + order.getOrderCode() + " đã nhận lại sách hoàn trả tại kho");
        return saved;
    }

    @Override
    @Transactional
    public Order approveRefund(String vendorEmail, Long orderId) {
        Order order = getOrder(vendorEmail, orderId);
        if (order.getOrderStatus() != OrderStatus.RETURNED && order.getOrderStatus() != OrderStatus.RETURN_REQUESTED) {
            throw new IllegalStateException("Chỉ duyệt hoàn tiền khi đơn ở trạng thái RETURN_REQUESTED hoặc RETURNED");
        }
        if (order.getOrderStatus() == OrderStatus.RETURN_REQUESTED) {
            confirmReturnReceived(vendorEmail, orderId);
        }
        order.setOrderStatus(OrderStatus.REFUNDED);
        order.setPaymentStatus(PaymentStatus.REFUNDED);
        order.setUpdatedAt(LocalDateTime.now());
        Double refundAmount = (order.getRefundAmount() != null) ? order.getRefundAmount() : order.getFinalAmount();

        // Chi trả tiền công thu hồi sách hoàn trả cho Shipper
        String shipperPayoutNote = "";
        if ("SHIPPER".equalsIgnoreCase(order.getReturnMethod())) {
            double baseFee = 20000.0;
            if (order.getShippingProvider() != null && order.getShippingProvider().getBaseFee() != null && order.getShippingProvider().getBaseFee() > 0) {
                baseFee = order.getShippingProvider().getBaseFee();
            }
            double returnFee = (order.getReturnShippingFee() != null && order.getReturnShippingFee() > baseFee) ? order.getReturnShippingFee() : baseFee;
            DeliveryAssignment assignment = deliveryAssignmentRepository.findByOrderId(order.getId()).orElse(null);
            if (assignment != null) {
                if (assignment.getStatus() != DeliveryStatus.DELIVERED) {
                    assignment.setStatus(DeliveryStatus.DELIVERED);
                }
                if (assignment.getCompletedAt() == null) {
                    assignment.setCompletedAt(LocalDateTime.now());
                }
                deliveryAssignmentRepository.save(assignment);
                if (assignment.getShipper() != null) {
                    shipperPayoutNote = " | Đã thanh toán phí vận chuyển thu hồi sách (" + String.format("%,.0f", returnFee) + "đ) cho Shipper " + assignment.getShipper().getFullName();
                }
            }
        }

        order.setNote((order.getNote() != null ? order.getNote() + " | " : "") +
                "Đã hoàn tiền " + String.format("%,.0f", refundAmount) + "đ cho khách hàng" +
                ("SHIPPER".equalsIgnoreCase(order.getReturnMethod()) ? " (sau khi trừ 50% phí ship hoàn: " + String.format("%,.0f", order.getReturnShippingFee() != null ? order.getReturnShippingFee() : 0.0) + "đ)" : " (hoàn 100% tiền đơn)") +
                shipperPayoutNote);
        Order saved = orderRepository.save(order);
        send(order.getBranch().getId(), "Đơn hàng #" + order.getOrderCode() + " đã hoàn tiền thành công và thanh toán phí cho Shipper");
        return saved;
    }

    @Override
    public List<Promotion> getPromotions(String vendorEmail) {
        User vendor = requireVendor(vendorEmail);
        Branch shop = requireShop(vendorEmail);
        return promotionRepository.findApplicableForVendor(shop.getId(), vendor.getId());
    }

    @Override
    @Transactional
    public Promotion savePromotion(String vendorEmail, Promotion promotion) {
        User vendor = requireVendor(vendorEmail);
        Branch shop = requireActiveShop(vendorEmail);
        if (promotion.getId() != null) {
            Promotion existing = promotionRepository.findById(promotion.getId())
                    .orElseThrow(() -> new IllegalArgumentException("Khuyến mãi không tồn tại"));
            if (existing.getVendor() == null) {
                throw new SecurityException("Không được chỉnh sửa chương trình khuyến mãi chung của Manager");
            }
            if (!Objects.equals(existing.getVendor().getId(), vendor.getId())) {
                throw new SecurityException("Không được sửa khuyến mãi của Vendor khác");
            }
        } else {
            promotion.setVendor(vendor);
        }
        promotion.setBranch(shop);
        if (promotion.getDiscountPercent() == null || promotion.getDiscountPercent() <= 0 || promotion.getDiscountPercent() > 100) {
            throw new IllegalArgumentException("% giảm không hợp lệ");
        }
        return promotionRepository.save(promotion);
    }

    @Override
    @Transactional
    public void deletePromotion(String vendorEmail, Long promotionId) {
        User vendor = requireVendor(vendorEmail);
        Branch shop = requireActiveShop(vendorEmail);
        Promotion promotion = promotionRepository.findById(promotionId)
                .orElseThrow(() -> new IllegalArgumentException("Khuyến mãi không tồn tại"));
        if (promotion.getBranch() == null || !Objects.equals(promotion.getBranch().getId(), shop.getId())) {
            throw new SecurityException("Không được xóa khuyến mãi của cửa hàng khác");
        }
        if (promotion.getVendor() == null) {
            throw new SecurityException("Không được xóa chương trình khuyến mãi chung của Manager");
        }
        if (!Objects.equals(promotion.getVendor().getId(), vendor.getId())) {
            throw new SecurityException("Không được xóa khuyến mãi của Vendor khác");
        }
        promotionRepository.delete(promotion);
    }

    @Override
    public VendorDashboardDTO getDashboard(String vendorEmail, LocalDate from, LocalDate to) {
        User vendor = requireVendor(vendorEmail);
        Branch shop = requireShop(vendorEmail);

        List<BookCopy> products = bookCopyRepository.findBySellerId(vendor.getId());

        // Đơn hàng đã giao thành công hoặc đang trong tiến trình xử lý đổi trả (chưa duyệt hoàn tiền) vẫn tính vào doanh thu
        List<OrderItem> vendorDeliveredItems = orderItemRepository.findAll().stream()
                .filter(item -> item.getBookCopy() != null && item.getBookCopy().getSeller() != null
                        && Objects.equals(item.getBookCopy().getSeller().getId(), vendor.getId()))
                .filter(item -> item.getOrder() != null && (
                        item.getOrder().getOrderStatus() == OrderStatus.DELIVERED
                        || item.getOrder().getOrderStatus() == OrderStatus.RETURN_REQUESTED
                        || item.getOrder().getOrderStatus() == OrderStatus.RETURNED
                ))
                .filter(item -> item.getOrder().getCreatedAt() != null)
                .filter(item -> from == null || !item.getOrder().getCreatedAt().toLocalDate().isBefore(from))
                .filter(item -> to == null || !item.getOrder().getCreatedAt().toLocalDate().isAfter(to))
                .toList();

        // Nhóm theo Order để tính doanh thu và khấu trừ tiền khuyến mãi/giảm giá của từng đơn (kể cả mã giảm phí ship cũng trừ vào vendor)
        Map<Order, List<OrderItem>> itemsByOrder = vendorDeliveredItems.stream()
                .collect(Collectors.groupingBy(OrderItem::getOrder));

        double grossRevenue = 0.0;
        double totalDiscount = 0.0;

        for (Map.Entry<Order, List<OrderItem>> entry : itemsByOrder.entrySet()) {
            Order o = entry.getKey();
            List<OrderItem> oItems = entry.getValue();

            double vendorOrderSubtotal = oItems.stream()
                    .mapToDouble(i -> Optional.ofNullable(i.getPrice()).orElse(0.0) * Optional.ofNullable(i.getQuantity()).orElse(1))
                    .sum();
            grossRevenue += vendorOrderSubtotal;

            double orderTotal = (o.getTotalAmount() != null && o.getTotalAmount() > 0) ? o.getTotalAmount() : vendorOrderSubtotal;
            double orderDiscount = Optional.ofNullable(o.getDiscountAmount()).orElse(0.0);

            // Tỷ lệ phân bổ giảm giá cho vendor trong đơn này
            double vendorDiscount = orderTotal > 0 ? (orderDiscount * (vendorOrderSubtotal / orderTotal)) : orderDiscount;
            vendorDiscount = Math.min(vendorDiscount, vendorOrderSubtotal);
            totalDiscount += vendorDiscount;
        }

        // Doanh thu đơn hàng đã giao sau khi trừ toàn bộ khuyến mãi (cả giảm giá sách và giảm giá phí ship)
        double revenue = Math.max(0.0, grossRevenue - totalDiscount);

        double commissionRate = Optional.ofNullable(shop.getAppDiscountPercent()).orElse(10.0) / 100.0;
        double commission = revenue * commissionRate;

        List<Order> vendorOrders = orderRepository.findByBranchIdOrderByCreatedAtDesc(shop.getId()).stream()
                .filter(o -> orderItemRepository.findByOrderId(o.getId()).stream()
                        .anyMatch(item -> item.getBookCopy() != null && item.getBookCopy().getSeller() != null
                                && Objects.equals(item.getBookCopy().getSeller().getId(), vendor.getId())))
                .toList();

        long newOrdersCount = vendorOrders.stream().filter(o -> o.getOrderStatus() == OrderStatus.NEW).count();

        // Khấu trừ chi phí thu mua sách cũ & phí trả cho Shipper vận chuyển sách về kho
        List<SellRequest> vendorCompletedSellRequests = sellRequestRepository.findByBuyerVendorIdAndStatus(vendor.getId(), SellRequestStatus.COMPLETED).stream()
                .filter(r -> {
                    LocalDate dt = r.getUpdatedAt() != null ? r.getUpdatedAt().toLocalDate() : (r.getCreatedAt() != null ? r.getCreatedAt().toLocalDate() : null);
                    if (dt == null) return true;
                    return (from == null || !dt.isBefore(from)) && (to == null || !dt.isAfter(to));
                })
                .toList();

        double bookAcquisitionCost = vendorCompletedSellRequests.stream()
                .mapToDouble(r -> {
                    if (r.getOfferedTotal() != null && r.getOfferedTotal() > 0) return r.getOfferedTotal();
                    Optional<SellRequestQuote> qOpt = sellRequestQuoteRepository.findBySellRequestIdAndVendorId(r.getId(), vendor.getId());
                    if (qOpt.isPresent() && qOpt.get().getOfferedPrice() != null && qOpt.get().getOfferedPrice() > 0) {
                        return qOpt.get().getOfferedPrice();
                    }
                    return (r.getExpectedTotal() != null ? r.getExpectedTotal() : 0.0);
                })
                .sum();

        double shippingAcquisitionCost = 0.0;
        for (SellRequest r : vendorCompletedSellRequests) {
            double fee = 20000.0;
            Optional<DeliveryAssignment> daOpt = deliveryAssignmentRepository.findBySellRequestId(r.getId());
            if (daOpt.isPresent() && daOpt.get().getStatus() == DeliveryStatus.DELIVERED) {
                DeliveryAssignment da = daOpt.get();
                if (da.getShipper() != null && da.getShipper().getShippingProvider() != null && da.getShipper().getShippingProvider().getBaseFee() != null) {
                    fee = da.getShipper().getShippingProvider().getBaseFee();
                }
            }
            shippingAcquisitionCost += fee;
        }

        double totalAcquisitionExpense = bookAcquisitionCost + shippingAcquisitionCost;

        // Khấu trừ phí trả cho Shipper thu hồi sách đổi trả và tổng tiền đã hoàn lại cho khách (CHỈ khi đơn đã hoàn tất REFUNDED)
        List<Order> vendorRefundedOrders = orderRepository.findByBranchIdOrderByCreatedAtDesc(shop.getId()).stream()
                .filter(o -> o.getOrderStatus() == OrderStatus.REFUNDED)
                .filter(o -> orderItemRepository.findByOrderId(o.getId()).stream()
                        .anyMatch(item -> item.getBookCopy() != null && item.getBookCopy().getSeller() != null
                                && Objects.equals(item.getBookCopy().getSeller().getId(), vendor.getId())))
                .filter(o -> {
                    LocalDate dt = o.getUpdatedAt() != null ? o.getUpdatedAt().toLocalDate() : (o.getCreatedAt() != null ? o.getCreatedAt().toLocalDate() : null);
                    if (dt == null) return true;
                    return (from == null || !dt.isBefore(from)) && (to == null || !dt.isAfter(to));
                })
                .toList();

        double returnShippingCost = 0.0;
        double refundedAmount = 0.0;
        for (Order o : vendorRefundedOrders) {
            refundedAmount += (o.getRefundAmount() != null ? o.getRefundAmount() : (o.getFinalAmount() != null ? o.getFinalAmount() : 0.0));
            if ("SHIPPER".equalsIgnoreCase(o.getReturnMethod())) {
                double fee = 20000.0;
                if (o.getShippingProvider() != null && o.getShippingProvider().getBaseFee() != null && o.getShippingProvider().getBaseFee() > 0) {
                    fee = o.getShippingProvider().getBaseFee();
                }
                if (o.getReturnShippingFee() != null && o.getReturnShippingFee() > fee) {
                    fee = o.getReturnShippingFee();
                }
                returnShippingCost += fee;
            }
        }

        return VendorDashboardDTO.builder()
                .totalProducts(products.size())
                .totalStock(products.stream().mapToLong(p -> Optional.ofNullable(p.getQuantity()).orElse(0)).sum())
                .newOrders(newOrdersCount)
                .totalOrders(vendorOrders.size())
                .grossRevenue(grossRevenue)
                .totalDiscount(totalDiscount)
                .deliveredRevenue(revenue)
                .commission(commission)
                .bookAcquisitionCost(bookAcquisitionCost)
                .shippingAcquisitionCost(shippingAcquisitionCost)
                .totalAcquisitionExpense(totalAcquisitionExpense)
                .returnShippingCost(returnShippingCost)
                .refundedAmount(refundedAmount)
                .build();
    }

    @Override
    public List<ProductSalesDTO> getTopProducts(String vendorEmail, LocalDate from, LocalDate to) {
        User vendor = requireVendor(vendorEmail);
        Map<Long, ProductSalesDTO> totals = new HashMap<>();

        List<OrderItem> vendorDeliveredItems = orderItemRepository.findAll().stream()
                .filter(item -> item.getBookCopy() != null && item.getBookCopy().getSeller() != null
                        && Objects.equals(item.getBookCopy().getSeller().getId(), vendor.getId()))
                .filter(item -> item.getOrder() != null && (
                        item.getOrder().getOrderStatus() == OrderStatus.DELIVERED
                        || item.getOrder().getOrderStatus() == OrderStatus.RETURN_REQUESTED
                        || item.getOrder().getOrderStatus() == OrderStatus.RETURNED
                ))
                .filter(item -> item.getOrder().getCreatedAt() != null)
                .filter(item -> from == null || !item.getOrder().getCreatedAt().toLocalDate().isBefore(from))
                .filter(item -> to == null || !item.getOrder().getCreatedAt().toLocalDate().isAfter(to))
                .toList();

        for (OrderItem item : vendorDeliveredItems) {
            Long id = item.getBookCopy().getId();
            ProductSalesDTO old = totals.get(id);
            long quantity = item.getQuantity();
            double revenue = Optional.ofNullable(item.getPrice()).orElse(0.0) * quantity;
            totals.put(id, new ProductSalesDTO(id, item.getBookCopy().getBook().getTitle(),
                    (old == null ? 0 : old.getQuantity()) + quantity,
                    (old == null ? 0 : old.getRevenue()) + revenue));
        }

        return totals.values().stream()
                .sorted(Comparator.comparingLong(ProductSalesDTO::getQuantity).reversed())
                .limit(10).toList();
    }

    @Override
    public VendorRevenueAnalyticsDTO getRevenueAnalytics(String vendorEmail, Integer year, Integer month) {
        User vendor = requireVendor(vendorEmail);
        Branch shop = requireShop(vendorEmail);
        int targetYear = (year != null && year > 2000) ? year : LocalDate.now().getYear();
        int targetMonth = (month != null && month >= 1 && month <= 12) ? month : LocalDate.now().getMonthValue();

        List<OrderItem> vendorDeliveredItems = orderItemRepository.findAll().stream()
                .filter(item -> item.getBookCopy() != null && item.getBookCopy().getSeller() != null
                        && Objects.equals(item.getBookCopy().getSeller().getId(), vendor.getId()))
                .filter(item -> item.getOrder() != null && (
                        item.getOrder().getOrderStatus() == OrderStatus.DELIVERED
                        || item.getOrder().getOrderStatus() == OrderStatus.RETURN_REQUESTED
                        || item.getOrder().getOrderStatus() == OrderStatus.RETURNED
                ))
                .filter(item -> item.getOrder().getCreatedAt() != null)
                .toList();

        List<Double> yearlyMonths = new ArrayList<>(Collections.nCopies(12, 0.0));
        Map<Integer, List<Double>> monthlyData = new HashMap<>();

        for (int m = 1; m <= 12; m++) {
            int days = YearMonth.of(targetYear, m).lengthOfMonth();
            monthlyData.put(m, new ArrayList<>(Collections.nCopies(days, 0.0)));
        }

        // Nhóm theo Order để tính doanh thu sau khi trừ toàn bộ khuyến mãi/giảm giá của từng đơn
        Map<Order, List<OrderItem>> itemsByOrder = vendorDeliveredItems.stream()
                .collect(Collectors.groupingBy(OrderItem::getOrder));

        double totalYear = 0.0;
        for (Map.Entry<Order, List<OrderItem>> entry : itemsByOrder.entrySet()) {
            Order o = entry.getKey();
            LocalDate dt = o.getCreatedAt().toLocalDate();
            if (dt.getYear() == targetYear) {
                List<OrderItem> oItems = entry.getValue();
                double vendorOrderSubtotal = oItems.stream()
                        .mapToDouble(i -> Optional.ofNullable(i.getPrice()).orElse(0.0) * Optional.ofNullable(i.getQuantity()).orElse(1))
                        .sum();
                double orderTotal = (o.getTotalAmount() != null && o.getTotalAmount() > 0) ? o.getTotalAmount() : vendorOrderSubtotal;
                double orderDiscount = Optional.ofNullable(o.getDiscountAmount()).orElse(0.0);
                double vendorDiscount = orderTotal > 0 ? (orderDiscount * (vendorOrderSubtotal / orderTotal)) : orderDiscount;
                double netOrderRev = Math.max(0.0, vendorOrderSubtotal - vendorDiscount);

                totalYear += netOrderRev;
                int mIdx = dt.getMonthValue() - 1;
                yearlyMonths.set(mIdx, yearlyMonths.get(mIdx) + netOrderRev);

                List<Double> daysList = monthlyData.get(dt.getMonthValue());
                int dayIdx = dt.getDayOfMonth() - 1;
                if (dayIdx >= 0 && dayIdx < daysList.size()) {
                    daysList.set(dayIdx, daysList.get(dayIdx) + netOrderRev);
                }
            }
        }

        // Khấu trừ chi phí mua sách cũ và phí trả cho Shipper thu gom trong năm mục tiêu
        List<SellRequest> completedInYear = sellRequestRepository.findByBuyerVendorIdAndStatus(vendor.getId(), SellRequestStatus.COMPLETED).stream()
                .filter(r -> {
                    LocalDate dt = r.getUpdatedAt() != null ? r.getUpdatedAt().toLocalDate() : (r.getCreatedAt() != null ? r.getCreatedAt().toLocalDate() : null);
                    return dt != null && dt.getYear() == targetYear;
                })
                .toList();

        for (SellRequest r : completedInYear) {
            LocalDate dt = r.getUpdatedAt() != null ? r.getUpdatedAt().toLocalDate() : r.getCreatedAt().toLocalDate();
            double bookCost = (r.getOfferedTotal() != null && r.getOfferedTotal() > 0) ? r.getOfferedTotal() : 0.0;
            if (bookCost == 0.0) {
                Optional<SellRequestQuote> qOpt = sellRequestQuoteRepository.findBySellRequestIdAndVendorId(r.getId(), vendor.getId());
                if (qOpt.isPresent() && qOpt.get().getOfferedPrice() != null && qOpt.get().getOfferedPrice() > 0) {
                    bookCost = qOpt.get().getOfferedPrice();
                } else if (r.getExpectedTotal() != null) {
                    bookCost = r.getExpectedTotal();
                }
            }
            double shipCost = 20000.0;
            Optional<DeliveryAssignment> daOpt = deliveryAssignmentRepository.findBySellRequestId(r.getId());
            if (daOpt.isPresent() && daOpt.get().getStatus() == DeliveryStatus.DELIVERED) {
                DeliveryAssignment da = daOpt.get();
                if (da.getShipper() != null && da.getShipper().getShippingProvider() != null && da.getShipper().getShippingProvider().getBaseFee() != null) {
                    shipCost = da.getShipper().getShippingProvider().getBaseFee();
                }
            }
            double totalExpense = bookCost + shipCost;
            totalYear = Math.max(0.0, totalYear - totalExpense);

            int mIdx = dt.getMonthValue() - 1;
            yearlyMonths.set(mIdx, Math.max(0.0, yearlyMonths.get(mIdx) - totalExpense));

            List<Double> daysList = monthlyData.get(dt.getMonthValue());
            int dayIdx = dt.getDayOfMonth() - 1;
            if (dayIdx >= 0 && dayIdx < daysList.size()) {
                daysList.set(dayIdx, Math.max(0.0, daysList.get(dayIdx) - totalExpense));
            }
        }

        // Khấu trừ phí trả cho Shipper đối với các đơn hoàn trả đã duyệt hoàn tiền (REFUNDED) trong năm
        List<Order> refundedInYear = orderRepository.findByBranchIdOrderByCreatedAtDesc(shop.getId()).stream()
                .filter(o -> o.getOrderStatus() == OrderStatus.REFUNDED)
                .filter(o -> "SHIPPER".equalsIgnoreCase(o.getReturnMethod()))
                .filter(o -> orderItemRepository.findByOrderId(o.getId()).stream()
                        .anyMatch(item -> item.getBookCopy() != null && item.getBookCopy().getSeller() != null
                                && Objects.equals(item.getBookCopy().getSeller().getId(), vendor.getId())))
                .filter(o -> {
                    LocalDate dt = o.getUpdatedAt() != null ? o.getUpdatedAt().toLocalDate() : (o.getCreatedAt() != null ? o.getCreatedAt().toLocalDate() : null);
                    return dt != null && dt.getYear() == targetYear;
                })
                .toList();

        for (Order o : refundedInYear) {
            LocalDate dt = o.getUpdatedAt() != null ? o.getUpdatedAt().toLocalDate() : o.getCreatedAt().toLocalDate();
            double baseFee = 20000.0;
            if (o.getShippingProvider() != null && o.getShippingProvider().getBaseFee() != null && o.getShippingProvider().getBaseFee() > 0) {
                baseFee = o.getShippingProvider().getBaseFee();
            }
            double shipCost = (o.getReturnShippingFee() != null && o.getReturnShippingFee() > baseFee) ? o.getReturnShippingFee() : baseFee;

            totalYear = Math.max(0.0, totalYear - shipCost);

            int mIdx = dt.getMonthValue() - 1;
            yearlyMonths.set(mIdx, Math.max(0.0, yearlyMonths.get(mIdx) - shipCost));

            List<Double> daysList = monthlyData.get(dt.getMonthValue());
            int dayIdx = dt.getDayOfMonth() - 1;
            if (dayIdx >= 0 && dayIdx < daysList.size()) {
                daysList.set(dayIdx, Math.max(0.0, daysList.get(dayIdx) - shipCost));
            }
        }

        double currentMonthTotal = yearlyMonths.get(targetMonth - 1);

        return VendorRevenueAnalyticsDTO.builder()
                .selectedYear(targetYear)
                .selectedMonth(targetMonth)
                .totalYearRevenue(totalYear)
                .yearlyTotalRevenue(totalYear)
                .currentMonthTotal(currentMonthTotal)
                .availableYears(List.of(targetYear - 1, targetYear, targetYear + 1))
                .yearlyMonths(yearlyMonths)
                .monthlyRevenues(yearlyMonths)
                .monthlyData(monthlyData)
                .dailyRevenuesByMonth(monthlyData)
                .build();
    }

    @Override
    public List<SellRequest> getSellRequests(String vendorEmail, SellRequestStatus status) {
        User vendor = requireVendor(vendorEmail);
        Branch shop = requireActiveShop(vendorEmail);
        if (status != null) {
            return sellRequestRepository.findVisibleForVendorAndStatus(vendor.getId(), shop.getId(), status);
        }
        return sellRequestRepository.findVisibleForVendor(vendor.getId(), shop.getId());
    }

    @Override
    public Map<Long, DeliveryAssignment> getSellRequestAssignments(String vendorEmail,
                                                                    List<SellRequest> requests) {
        Set<Long> allowedIds = getSellRequests(vendorEmail, null).stream()
                .map(SellRequest::getId)
                .collect(Collectors.toSet());
        Map<Long, DeliveryAssignment> assignments = new HashMap<>();
        for (SellRequest request : requests == null ? List.<SellRequest>of() : requests) {
            if (allowedIds.contains(request.getId())) {
                deliveryAssignmentRepository.findBySellRequestId(request.getId())
                        .ifPresent(assignment -> assignments.put(request.getId(), assignment));
            }
        }
        return assignments;
    }

    @Override
    public Map<Long, SellRequestQuote> getSellRequestQuotes(String vendorEmail,
                                                             List<SellRequest> requests) {
        User vendor = requireVendor(vendorEmail);
        Set<Long> allowedIds = getSellRequests(vendorEmail, null).stream()
                .map(SellRequest::getId)
                .collect(Collectors.toSet());
        Map<Long, SellRequestQuote> quotes = new HashMap<>();
        for (SellRequest request : requests == null ? List.<SellRequest>of() : requests) {
            if (allowedIds.contains(request.getId())) {
                sellRequestQuoteRepository.findBySellRequestIdAndVendorId(request.getId(), vendor.getId())
                        .ifPresent(quote -> quotes.put(request.getId(), quote));
            }
        }
        return quotes;
    }

    @Override
    @Transactional
    public SellRequest updateSellRequest(String vendorEmail, Long requestId, SellRequestStatus target,
                                         Double offeredTotal, String staffNote) {
        User vendor = requireVendor(vendorEmail);
        Branch shop = requireActiveShop(vendorEmail);
        SellRequest request = sellRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Yêu cầu thu mua không tồn tại"));

        SellRequestStatus current = request.getStatus();

        // Nếu đơn đã có người mua thành công (ACCEPTED, COMPLETED) thì chỉ duy nhất buyerVendor mới được thao tác
        if (request.isNegotiated()) {
            boolean isAuthorized = (request.getBuyerVendor() != null && Objects.equals(request.getBuyerVendor().getId(), vendor.getId()));
            if (!isAuthorized) {
                throw new SecurityException("Yêu cầu thu mua này đã được shop khác mua thành công!");
            }
        }

        // Khi vendor đưa ra báo giá (QUOTED) hoặc đang thẩm định (INSPECTING):
        // Lưu báo giá độc lập của vendor vào SellRequestQuote. Không gán buyerVendor lên SellRequest
        // để các shop khác vẫn có thể thẩm định độc lập và khách hàng tự quyết định chọn shop.
        if (target == SellRequestStatus.QUOTED || target == SellRequestStatus.INSPECTING) {
            double priceToQuote = (offeredTotal != null && offeredTotal >= 0) ? offeredTotal : (request.getExpectedTotal() != null ? request.getExpectedTotal() : 0.0);
            SellRequestQuote quote = sellRequestQuoteRepository
                    .findBySellRequestIdAndVendorId(request.getId(), vendor.getId())
                    .orElseGet(() -> SellRequestQuote.builder()
                            .sellRequest(request)
                            .vendor(vendor)
                            .branch(shop)
                            .status(SellRequestQuoteStatus.PENDING)
                            .build());

            quote.setOfferedPrice(priceToQuote);
            if (staffNote != null && !staffNote.isBlank()) {
                quote.setNote(staffNote.trim());
            }
            quote.setStatus(SellRequestQuoteStatus.PENDING);
            quote.setUpdatedAt(LocalDateTime.now());
            sellRequestQuoteRepository.save(quote);

            request.setStatus(target);
            request.setUpdatedAt(LocalDateTime.now());
        } else if (target == SellRequestStatus.REJECTED) {
            sellRequestQuoteRepository.findBySellRequestIdAndVendorId(request.getId(), vendor.getId()).ifPresent(q -> {
                q.setStatus(SellRequestQuoteStatus.REJECTED);
                q.setUpdatedAt(LocalDateTime.now());
                sellRequestQuoteRepository.save(q);
            });
        } else if (target == SellRequestStatus.ACCEPTED) {
            request.setBuyerVendor(vendor);
            request.setBranch(shop);
            request.setStatus(SellRequestStatus.ACCEPTED);
            request.setUpdatedAt(LocalDateTime.now());
            if (offeredTotal != null && offeredTotal >= 0) request.setOfferedTotal(offeredTotal);
            if (staffNote != null) request.setStaffNote(staffNote);
        } else if (target == SellRequestStatus.COMPLETED) {
            request.setStatus(SellRequestStatus.COMPLETED);
            request.setUpdatedAt(LocalDateTime.now());
            request.setBuyerVendor(vendor);
            request.setBranch(shop);
            if (request.getOfferedTotal() == null || request.getOfferedTotal() == 0.0) {
                sellRequestQuoteRepository.findBySellRequestIdAndVendorId(request.getId(), vendor.getId())
                        .ifPresent(q -> request.setOfferedTotal(q.getOfferedPrice()));
            }
            if ((request.getOfferedTotal() == null || request.getOfferedTotal() == 0.0) && offeredTotal != null && offeredTotal >= 0) {
                request.setOfferedTotal(offeredTotal);
            }
            if (request.getOfferedTotal() == null || request.getOfferedTotal() == 0.0) {
                request.setOfferedTotal(request.getExpectedTotal() != null ? request.getExpectedTotal() : 0.0);
            }

            // Đồng bộ trạng thái hoàn thành cho DeliveryAssignment thu gom sách cũ
            Optional<DeliveryAssignment> daOpt = deliveryAssignmentRepository.findBySellRequestId(request.getId());
            if (daOpt.isPresent()) {
                DeliveryAssignment da = daOpt.get();
                if (da.getStatus() == DeliveryStatus.DELIVERED && da.getCompletedAt() == null) {
                    da.setCompletedAt(LocalDateTime.now());
                    deliveryAssignmentRepository.save(da);
                }
            }

            // Đồng bộ trạng thái báo giá của vendor thành ACCEPTED
            sellRequestQuoteRepository.findBySellRequestIdAndVendorId(request.getId(), vendor.getId()).ifPresent(q -> {
                q.setStatus(SellRequestQuoteStatus.ACCEPTED);
                q.setUpdatedAt(LocalDateTime.now());
                sellRequestQuoteRepository.save(q);
            });

            // Chỉ tạo bản sao sách vào kho nếu trước đó chưa hoàn thành nhập kho
            if (current != SellRequestStatus.COMPLETED) {
                for (SellRequestItem item : request.getItems()) {
                    Book book = item.getBook();
                    if (book == null && item.getBookTitle() != null) {
                        book = bookRepository.searchBooks(item.getBookTitle())
                                .stream().findFirst().orElse(null);
                    }
                    if (book == null && item.getBookTitle() != null) {
                        book = bookRepository.save(Book.builder()
                                .title(item.getBookTitle())
                                .isbn(item.getIsbn())
                                .coverUrl(item.getImageUrl() != null && !item.getImageUrl().isBlank()
                                        ? item.getImageUrl()
                                        : "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500&q=80")
                                .description(item.getConditionDescription())
                                .build());
                    }
                    if (book != null) {
                        Double price = item.getOfferedPrice() != null ? item.getOfferedPrice()
                                : (request.getOfferedTotal() != null ? request.getOfferedTotal() : item.getExpectedPrice());
                        BookCopy copy = BookCopy.builder()
                                .book(book)
                                .branch(shop)
                                .seller(vendor)
                                .conditionRating(BookCondition.GOOD)
                                .purchasePrice(price != null ? price : 0.0)
                                .sellingPrice(price != null ? price * 1.3 : 0.0)
                                .quantity(1)
                                .status(BookCopyStatus.AVAILABLE)
                                .note("Sách cũ thu mua từ Khách #" + (request.getCustomer() != null ? request.getCustomer().getFullName() : "") + " (Yêu cầu #" + request.getId() + ") - " + item.getConditionDescription())
                                .imageUrl(item.getImageUrl() != null && !item.getImageUrl().isBlank() ? item.getImageUrl() : book.getCoverUrl())
                                .build();
                        bookCopyRepository.save(copy);
                    }
                }
            }
        }

        SellRequest saved = sellRequestRepository.save(request);
        send(request.getBranch() == null ? null : request.getBranch().getId(),
                "Yêu cầu thu mua #" + request.getId() + " đã chuyển sang " + target);
        return saved;
    }

    @Override
    @Transactional
    public DeliveryAssignment assignSellRequestShipper(String vendorEmail, Long requestId, Long shipperId, String note) {
        User vendor = requireVendor(vendorEmail);
        Branch shop = requireActiveShop(vendorEmail);
        SellRequest request = sellRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Yêu cầu thu mua không tồn tại"));

        if (request.getStatus() != SellRequestStatus.ACCEPTED) {
            throw new IllegalStateException("Chỉ có thể phân công shipper khi khách hàng đã chấp nhận bán sách cho shop");
        }

        if (request.getBuyerVendor() == null || !Objects.equals(request.getBuyerVendor().getId(), vendor.getId())) {
            throw new SecurityException("Bạn không phải cửa hàng đã đàm phán mua thành công đơn này!");
        }

        User shipper = userRepository.findById(shipperId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy Shipper id: " + shipperId));
        if (shipper.getRole() == null || shipper.getRole().getName() != RoleName.ROLE_SHIPPER) {
            throw new IllegalArgumentException("Tài khoản được chọn không phải Shipper");
        }
        if (shipper.getBranch() == null || !Objects.equals(shipper.getBranch().getId(), shop.getId())) {
            throw new IllegalArgumentException("Shipper không thuộc cùng chi nhánh với cửa hàng");
        }

        // Ràng buộc Shipper Tiêu Chuẩn (GHN_STANDARD)
        boolean isStandardShipper = shipper.getShippingProvider() != null &&
                ("GHN_STANDARD".equalsIgnoreCase(shipper.getShippingProvider().getCode())
                || shipper.getShippingProvider().getName().toLowerCase().contains("tiêu chuẩn"));
        if (!isStandardShipper) {
            throw new IllegalArgumentException("Đơn thu gom sách cũ thu mua bắt buộc phân công Shipper Tiêu Chuẩn!");
        }

        DeliveryAssignment assignment = deliveryAssignmentRepository.findBySellRequestId(request.getId())
                .orElse(DeliveryAssignment.builder().sellRequest(request).build());

        // Ràng buộc shipper đã từng từ chối đơn này
        if (assignment.hasShipperRejected(shipperId)) {
            throw new IllegalStateException("Shipper " + shipper.getFullName() + " đã từng từ chối nhận đơn thu gom này trước đó. Vui lòng phân công cho shipper khác!");
        }

        // Ràng buộc Shipper bận: Chỉ khi shipper đang trong giai đoạn vận chuyển (SHIPPING) mới coi là bận
        List<DeliveryStatus> busyStatuses = List.of(DeliveryStatus.SHIPPING);
        Optional<DeliveryAssignment> ongoing = deliveryAssignmentRepository.findFirstByShipperIdAndStatusIn(shipperId, busyStatuses);
        if (ongoing.isPresent()) {
            throw new IllegalStateException("Shipper " + shipper.getFullName() + " hiện đang trong giai đoạn vận chuyển đơn #" + ongoing.get().getReferenceCode() + ". Không thể phân công cho đến khi hoàn thành!");
        }

        assignment.setSellRequest(request);
        assignment.setShipper(shipper);
        assignment.setAssignedBy(vendor);
        assignment.setStatus(DeliveryStatus.ASSIGNED);
        assignment.setAssignedAt(LocalDateTime.now());
        assignment.setFailureReason(null);
        if (note != null && !note.isBlank()) {
            assignment.setNote(note.trim());
        } else {
            assignment.setNote("Đến địa chỉ của khách hàng để nhận sách cũ thu mua mang về chi nhánh " + shop.getName());
        }

        DeliveryAssignment saved = deliveryAssignmentRepository.save(assignment);
        send(request.getBranch() == null ? null : request.getBranch().getId(),
                "Đơn thu gom sách #" + request.getId() + " đã phân công Shipper " + shipper.getFullName() + " (Đang chờ nhận đơn)");
        return saved;
    }

    @Override
    @Transactional
    public DeliveryAssignment revokeSellRequestAssignment(String vendorEmail, Long requestId) {
        User vendor = requireVendor(vendorEmail);
        SellRequest request = sellRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Yêu cầu thu mua không tồn tại"));

        if (request.getBuyerVendor() == null || !Objects.equals(request.getBuyerVendor().getId(), vendor.getId())) {
            throw new SecurityException("Bạn không phải cửa hàng đã đàm phán mua thành công đơn này!");
        }

        DeliveryAssignment assignment = deliveryAssignmentRepository.findBySellRequestId(request.getId())
                .orElseThrow(() -> new IllegalArgumentException("Đơn chưa có thông tin phân công vận chuyển"));

        if (assignment.getStatus() != DeliveryStatus.ASSIGNED) {
            throw new IllegalStateException("Chỉ có thể thu hồi phân công khi đơn đang ở trạng thái 'Chờ Shipper xác nhận'");
        }

        assignment.setShipper(null);
        assignment.setStatus(DeliveryStatus.CANCELLED);
        assignment.setCompletedAt(LocalDateTime.now());
        return deliveryAssignmentRepository.save(assignment);
    }

    private void send(Long branchId, String message) {
        realtimeNotificationService.notifyOrder(branchId, message);
    }
}
