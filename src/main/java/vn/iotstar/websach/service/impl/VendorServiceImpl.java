package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import vn.iotstar.websach.dto.ProductSalesDTO;
import vn.iotstar.websach.dto.VendorDashboardDTO;
import vn.iotstar.websach.dto.VendorProductRequest;
import vn.iotstar.websach.entity.*;
import vn.iotstar.websach.entity.enums.*;
import vn.iotstar.websach.repository.*;
import vn.iotstar.websach.service.CloudinaryService;
import vn.iotstar.websach.service.VendorService;

import java.time.LocalDate;
import java.util.*;

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
    private final SimpMessagingTemplate messagingTemplate;

    private User requireVendor(String email) {
        User vendor = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản Vendor"));
        if (vendor.getRole() == null || vendor.getRole().getName() != RoleName.ROLE_VENDOR) {
            throw new SecurityException("Tài khoản không có quyền Vendor");
        }
        return vendor;
    }

    @Override
    public Branch getShop(String vendorEmail) {
        User vendor = requireVendor(vendorEmail);
        return branchRepository.findByOwnerId(vendor.getId()).orElse(null);
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
        boolean creating = shop == null;
        if (creating) {
            if (branchRepository.existsByNameIgnoreCase(details.getName())) {
                throw new IllegalArgumentException("Tên cửa hàng đã tồn tại");
            }
            shop = new Branch();
            shop.setOwner(vendor);
            shop.setStatus(BranchStatus.PENDING);
            shop.setAppDiscountPercent(10.0);
        }
        shop.setName(details.getName().trim());
        shop.setDescription(details.getDescription());
        shop.setAddress(details.getAddress().trim());
        shop.setPhone(details.getPhone());
        shop.setEmail(details.getEmail());
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
        Branch shop = requireShop(vendorEmail);
        return bookCopyRepository.findByBranchId(shop.getId());
    }

    @Override
    @Transactional
    public BookCopy saveProduct(String vendorEmail, VendorProductRequest request, MultipartFile imageFile) {
        Branch shop = requireActiveShop(vendorEmail);
        BookCopy product;
        if (request.getId() == null) {
            Book book = bookRepository.findById(request.getBookId())
                    .orElseThrow(() -> new IllegalArgumentException("Đầu sách không tồn tại"));
            product = BookCopy.builder().book(book).branch(shop).build();
        } else {
            product = bookCopyRepository.findById(request.getId())
                    .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại"));
            assertOwned(shop, product);
            if (request.getBookId() != null) {
                product.setBook(bookRepository.findById(request.getBookId())
                        .orElseThrow(() -> new IllegalArgumentException("Đầu sách không tồn tại")));
            }
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
        BookCopyStatus requestedStatus = request.getStatus() == null ? BookCopyStatus.AVAILABLE : request.getStatus();
        product.setStatus(request.getQuantity() == 0 ? BookCopyStatus.SOLD : requestedStatus);
        String imageUrl = cloudinaryService.uploadFile(imageFile);
        if (imageUrl != null) product.setImageUrl(imageUrl);
        else if (request.getImageUrl() != null && !request.getImageUrl().isBlank()) product.setImageUrl(request.getImageUrl());
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
        product.setStatus(product.getStatus() == BookCopyStatus.AVAILABLE ? BookCopyStatus.RESERVED : BookCopyStatus.AVAILABLE);
        bookCopyRepository.save(product);
    }

    @Override
    public List<Order> getOrders(String vendorEmail, OrderStatus status) {
        Branch shop = requireActiveShop(vendorEmail);
        if (status != null) return orderRepository.findByBranchIdAndOrderStatus(shop.getId(), status);
        return orderRepository.findByBranchIdOrderByCreatedAtDesc(shop.getId());
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
    @Transactional
    public Order updateOrderStatus(String vendorEmail, Long orderId, OrderStatus target) {
        Order order = getOrder(vendorEmail, orderId);
        OrderStatus current = order.getOrderStatus();
        boolean allowed = (current == OrderStatus.NEW && (target == OrderStatus.CONFIRMED || target == OrderStatus.CANCELLED))
                || (current == OrderStatus.CONFIRMED && (target == OrderStatus.PACKING || target == OrderStatus.READY_FOR_PICKUP || target == OrderStatus.CANCELLED))
                || (current == OrderStatus.PACKING && (target == OrderStatus.READY_FOR_PICKUP || target == OrderStatus.CANCELLED))
                || (current == OrderStatus.RETURN_REQUESTED && target == OrderStatus.RETURNED)
                || (current == OrderStatus.RETURNED && target == OrderStatus.REFUNDED);
        if (!allowed) throw new IllegalStateException("Không thể chuyển trạng thái " + current + " sang " + target);
        order.setOrderStatus(target);
        Order saved = orderRepository.save(order);
        send("Đơn hàng " + order.getOrderCode() + " đã chuyển sang " + target);
        return saved;
    }

    @Override
    public List<Promotion> getPromotions(String vendorEmail) {
        return promotionRepository.findByBranchId(requireShop(vendorEmail).getId());
    }

    @Override
    @Transactional
    public Promotion savePromotion(String vendorEmail, Promotion details) {
        Branch shop = requireActiveShop(vendorEmail);
        if (details.getStartDate() == null || details.getEndDate() == null || details.getEndDate().isBefore(details.getStartDate())) {
            throw new IllegalArgumentException("Thời gian khuyến mãi không hợp lệ");
        }
        if (details.getDiscountPercent() == null || details.getDiscountPercent() <= 0 || details.getDiscountPercent() > 100) {
            throw new IllegalArgumentException("Phần trăm giảm phải từ 0 đến 100");
        }
        Promotion promotion;
        if (details.getId() == null) promotion = new Promotion();
        else {
            promotion = promotionRepository.findById(details.getId())
                    .orElseThrow(() -> new IllegalArgumentException("Khuyến mãi không tồn tại"));
            if (promotion.getBranch() == null || !Objects.equals(promotion.getBranch().getId(), shop.getId())) {
                throw new SecurityException("Không được sửa khuyến mãi của cửa hàng khác");
            }
        }
        promotion.setBranch(shop);
        promotion.setTitle(details.getTitle());
        promotion.setDiscountPercent(details.getDiscountPercent());
        promotion.setStartDate(details.getStartDate());
        promotion.setEndDate(details.getEndDate());
        promotion.setActive(details.getActive() == null || details.getActive());
        return promotionRepository.save(promotion);
    }

    @Override
    @Transactional
    public void deletePromotion(String vendorEmail, Long promotionId) {
        Branch shop = requireActiveShop(vendorEmail);
        Promotion promotion = promotionRepository.findById(promotionId)
                .orElseThrow(() -> new IllegalArgumentException("Khuyến mãi không tồn tại"));
        if (promotion.getBranch() == null || !Objects.equals(promotion.getBranch().getId(), shop.getId())) {
            throw new SecurityException("Không được xóa khuyến mãi của cửa hàng khác");
        }
        promotionRepository.delete(promotion);
    }

    private List<Order> deliveredInRange(Branch shop, LocalDate from, LocalDate to) {
        return orderRepository.findByBranchIdAndOrderStatus(shop.getId(), OrderStatus.DELIVERED).stream()
                .filter(o -> o.getCreatedAt() != null)
                .filter(o -> from == null || !o.getCreatedAt().toLocalDate().isBefore(from))
                .filter(o -> to == null || !o.getCreatedAt().toLocalDate().isAfter(to))
                .toList();
    }

    @Override
    public VendorDashboardDTO getDashboard(String vendorEmail, LocalDate from, LocalDate to) {
        Branch shop = requireShop(vendorEmail);
        List<BookCopy> products = bookCopyRepository.findByBranchId(shop.getId());
        List<Order> delivered = deliveredInRange(shop, from, to);
        double revenue = delivered.stream().mapToDouble(o -> Optional.ofNullable(o.getFinalAmount()).orElse(0.0)).sum();
        double commission = delivered.stream().mapToDouble(o -> Optional.ofNullable(o.getAppCommissionAmount()).orElse(0.0)).sum();
        return VendorDashboardDTO.builder()
                .totalProducts(products.size())
                .totalStock(products.stream().mapToLong(p -> Optional.ofNullable(p.getQuantity()).orElse(0)).sum())
                .newOrders(orderRepository.countByBranchIdAndOrderStatus(shop.getId(), OrderStatus.NEW))
                .totalOrders(orderRepository.countByBranchId(shop.getId()))
                .deliveredRevenue(revenue)
                .commission(commission)
                .build();
    }

    @Override
    public List<ProductSalesDTO> getTopProducts(String vendorEmail, LocalDate from, LocalDate to) {
        Branch shop = requireShop(vendorEmail);
        Map<Long, ProductSalesDTO> totals = new HashMap<>();
        for (OrderItem item : orderItemRepository.findByOrderBranchIdAndOrderOrderStatus(shop.getId(), OrderStatus.DELIVERED)) {
            if (item.getOrder().getCreatedAt() == null
                    || (from != null && item.getOrder().getCreatedAt().toLocalDate().isBefore(from))
                    || (to != null && item.getOrder().getCreatedAt().toLocalDate().isAfter(to))) continue;
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
    public List<SellRequest> getSellRequests(String vendorEmail, SellRequestStatus status) {
        Branch shop = requireActiveShop(vendorEmail);
        if (status == null) return sellRequestRepository.findByBranchIdOrderByCreatedAtDesc(shop.getId());
        return sellRequestRepository.findByBranchIdAndStatusOrderByCreatedAtDesc(shop.getId(), status);
    }

    @Override
    @Transactional
    public SellRequest updateSellRequest(String vendorEmail, Long requestId, SellRequestStatus target,
                                         Double offeredTotal, String staffNote) {
        Branch shop = requireActiveShop(vendorEmail);
        SellRequest request = sellRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("Yêu cầu thu mua không tồn tại"));
        if (!Objects.equals(request.getBranch().getId(), shop.getId())) {
            throw new SecurityException("Không được xử lý yêu cầu của cửa hàng khác");
        }
        SellRequestStatus current = request.getStatus();
        boolean allowed = (current == SellRequestStatus.PENDING && (target == SellRequestStatus.INSPECTING || target == SellRequestStatus.QUOTED || target == SellRequestStatus.REJECTED))
                || (current == SellRequestStatus.INSPECTING && (target == SellRequestStatus.QUOTED || target == SellRequestStatus.REJECTED))
                || (current == SellRequestStatus.QUOTED && (target == SellRequestStatus.ACCEPTED || target == SellRequestStatus.REJECTED))
                || (current == SellRequestStatus.ACCEPTED && target == SellRequestStatus.COMPLETED);
        if (!allowed) throw new IllegalStateException("Chuyển trạng thái thu mua không hợp lệ");
        if (target == SellRequestStatus.QUOTED && (offeredTotal == null || offeredTotal < 0)) {
            throw new IllegalArgumentException("Cần nhập giá đề nghị hợp lệ");
        }
        request.setStatus(target);
        if (offeredTotal != null) request.setOfferedTotal(offeredTotal);
        request.setStaffNote(staffNote);

        // Tự động nhập kho sách cũ khi hoàn tất thu mua
        if (target == SellRequestStatus.COMPLETED && current != SellRequestStatus.COMPLETED) {
            for (SellRequestItem item : request.getItems()) {
                Book book = item.getBook();
                if (book == null && item.getBookTitle() != null) {
                    book = bookRepository.searchBooks(item.getBookTitle())
                            .stream().findFirst().orElse(null);
                }
                if (book != null) {
                    Double price = item.getOfferedPrice() != null ? item.getOfferedPrice() : item.getExpectedPrice();
                    BookCopy copy = BookCopy.builder()
                            .book(book)
                            .branch(shop)
                            .conditionRating(BookCondition.GOOD)
                            .purchasePrice(price != null ? price : 0.0)
                            .sellingPrice(price != null ? price * 1.3 : 0.0)
                            .quantity(1)
                            .status(BookCopyStatus.AVAILABLE)
                            .note("Sách cũ thu mua từ Khách #" + (request.getCustomer() != null ? request.getCustomer().getFullName() : "") + " (Yêu cầu #" + request.getId() + ") - " + item.getConditionDescription())
                            .imageUrl(item.getImageUrl())
                            .build();
                    bookCopyRepository.save(copy);
                }
            }
        }

        SellRequest saved = sellRequestRepository.save(request);
        send("Yêu cầu thu mua #" + request.getId() + " đã chuyển sang " + target);
        return saved;
    }

    private void send(String message) {
        try { messagingTemplate.convertAndSend("/topic/orders", message); }
        catch (Exception ignored) { }
    }
}
