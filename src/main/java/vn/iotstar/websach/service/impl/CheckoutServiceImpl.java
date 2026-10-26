package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.*;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.entity.enums.PaymentMethod;
import vn.iotstar.websach.entity.enums.PaymentStatus;
import vn.iotstar.websach.entity.enums.PromotionType;
import vn.iotstar.websach.repository.*;
import vn.iotstar.websach.service.CartService;
import vn.iotstar.websach.service.CheckoutService;
import vn.iotstar.websach.service.PromotionService;

import java.time.LocalDate;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class CheckoutServiceImpl implements CheckoutService {

    private final CartService cartService;
    private final AddressRepository addressRepository;
    private final ShippingProviderRepository shippingProviderRepository;
    private final AppDiscountRepository appDiscountRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final BookCopyRepository bookCopyRepository;
    private final PromotionService promotionService;

    @Override
    public List<Order> processCheckout(User user, Long addressId, String recipientName, String phone, String shippingAddress, Long shippingProviderId, String voucherCode, String paymentMethodStr, String note) {
        List<CartItem> cartItems = cartService.getCartItems(user);
        if (cartItems.isEmpty()) {
            throw new IllegalStateException("Giỏ hàng của bạn đang trống!");
        }

        // 1. Chặn mua vượt số lượng tồn kho
        for (CartItem item : cartItems) {
            if (item.getBookCopy() == null || item.getBookCopy().getId() == null) {
                throw new IllegalStateException("Giỏ hàng chứa sản phẩm không hợp lệ.");
            }
            BookCopy copy = bookCopyRepository.findByIdForUpdate(item.getBookCopy().getId())
                    .orElseThrow(() -> new IllegalStateException("Sản phẩm trong giỏ không còn tồn tại."));
            item.setBookCopy(copy);
            Integer available = copy != null ? copy.getQuantity() : 0;
            String bookTitle = (copy != null && copy.getBook() != null) ? copy.getBook().getTitle() : "Sách";
            if (available == null || available <= 0) {
                throw new IllegalStateException("Sản phẩm '" + bookTitle + "' hiện đã hết hàng!");
            }
            if (item.getQuantity() == null || item.getQuantity() <= 0) {
                throw new IllegalStateException("Số lượng sản phẩm đặt không hợp lệ!");
            }
            if (item.getQuantity() > available) {
                throw new IllegalStateException("Sản phẩm '" + bookTitle + "' chỉ còn " + available
                        + " cuốn trong kho, không đủ số lượng bạn đặt (" + item.getQuantity() + " cuốn)!");
            }
            if (copy.getStatus() != vn.iotstar.websach.entity.enums.BookCopyStatus.AVAILABLE) {
                throw new IllegalStateException("Sản phẩm '" + bookTitle + "' hiện không được mở bán.");
            }
            if (copy.getSellingPrice() == null || copy.getSellingPrice() < 0) {
                throw new IllegalStateException("Giá bán của sản phẩm '" + bookTitle + "' không hợp lệ.");
            }
        }

        // 2. Xác định thông tin địa chỉ giao hàng
        String finalName = recipientName;
        String finalPhone = phone;
        String finalAddressStr = shippingAddress;

        if (addressId != null) {
            Address addr = addressRepository.findByIdAndUser(addressId, user)
                    .orElseThrow(() -> new SecurityException("Địa chỉ nhận hàng không thuộc tài khoản của bạn."));
            finalName = addr.getRecipientName();
            finalPhone = addr.getPhone();
            finalAddressStr = addr.getStreet() + ", " + (addr.getWard() != null ? addr.getWard() + ", " : "") + (addr.getDistrict() != null ? addr.getDistrict() + ", " : "") + addr.getCity();
        }

        if (finalName == null || finalName.trim().isEmpty()) finalName = user.getFullName();
        if (finalPhone == null || finalPhone.trim().isEmpty()) finalPhone = user.getPhone();
        if (finalName == null || finalName.isBlank() || finalName.trim().length() > 100) {
            throw new IllegalArgumentException("Tên người nhận không hợp lệ.");
        }
        if (finalPhone == null || !finalPhone.trim().matches("^(?:0\\d{9}|\\+84\\d{9})$")) {
            throw new IllegalArgumentException("Số điện thoại nhận hàng phải là số Việt Nam hợp lệ.");
        }
        if (finalAddressStr == null || finalAddressStr.isBlank() || finalAddressStr.trim().length() > 255) {
            throw new IllegalArgumentException("Vui lòng chọn hoặc nhập đầy đủ địa chỉ nhận hàng.");
        }
        finalName = finalName.trim();
        finalPhone = finalPhone.trim();
        finalAddressStr = finalAddressStr.trim();
        if (note != null && note.length() > 1000) {
            throw new IllegalArgumentException("Ghi chú đơn hàng không được vượt quá 1000 ký tự.");
        }

        if (shippingProviderId == null) {
            throw new IllegalArgumentException("Vui lòng chọn nhà vận chuyển.");
        }
        ShippingProvider provider = shippingProviderRepository.findById(shippingProviderId)
                .orElseThrow(() -> new IllegalArgumentException("Nhà vận chuyển không tồn tại."));
        if (!Boolean.TRUE.equals(provider.getActive())) {
            throw new IllegalArgumentException("Nhà vận chuyển đã ngừng hoạt động.");
        }
        if (provider.getBaseFee() == null || provider.getBaseFee() < 0) {
            throw new IllegalStateException("Phí vận chuyển chưa được cấu hình hợp lệ.");
        }
        double baseShipFee = provider.getBaseFee();

        double totalCartSubtotal = cartItems.stream()
                .mapToDouble(ci -> (ci.getBookCopy().getSellingPrice() != null ? ci.getBookCopy().getSellingPrice() : 0.0) * ci.getQuantity())
                .sum();

        // 3. Kiểm tra Voucher (ngày bắt đầu, hết hạn, min order value)
        AppDiscount promo = null;
        if (voucherCode != null && !voucherCode.trim().isEmpty()) {
            String normalizedVoucherCode = voucherCode.trim().toUpperCase(Locale.ROOT);
            promo = appDiscountRepository.findByCodeAndActiveTrue(normalizedVoucherCode).orElse(null);
            if (promo == null) {
                throw new IllegalArgumentException("Mã voucher '" + voucherCode.trim() + "' không tồn tại hoặc đã bị khóa!");
            }
            LocalDate today = LocalDate.now();
            if (promo.getStartDate() != null && today.isBefore(promo.getStartDate())) {
                throw new IllegalArgumentException("Mã voucher '" + promo.getCode() + "' chưa có hiệu lực (bắt đầu từ " + promo.getStartDate() + ")!");
            }
            if (promo.getEndDate() != null && today.isAfter(promo.getEndDate())) {
                throw new IllegalArgumentException("Mã voucher '" + promo.getCode() + "' đã hết hạn vào ngày " + promo.getEndDate() + "!");
            }
            if (promo.getMinOrderValue() != null && totalCartSubtotal < promo.getMinOrderValue()) {
                throw new IllegalArgumentException("Đơn hàng chưa đạt giá trị tối thiểu "
                        + String.format("%,.0f đ", promo.getMinOrderValue())
                        + " để áp dụng mã này (giá trị hiện tại: "
                        + String.format("%,.0f đ", totalCartSubtotal) + ")!");
            }
        }
        double totalVoucherDiscount = 0.0;
        if (promo != null && promo.getDiscountPercent() != null && promo.getDiscountPercent() > 0) {
            totalVoucherDiscount = totalCartSubtotal * promo.getDiscountPercent() / 100.0;
            if (promo.getMaxDiscountAmount() != null) {
                totalVoucherDiscount = Math.min(totalVoucherDiscount, promo.getMaxDiscountAmount());
            }
        }

        // 4. Nhóm sản phẩm theo từng chi nhánh / Shop (Tách đơn theo shop)
        java.util.Map<Branch, List<CartItem>> itemsByBranch = new java.util.LinkedHashMap<>();
        for (CartItem ci : cartItems) {
            Branch b = ci.getBookCopy().getBranch();
            if (b == null) {
                throw new IllegalStateException("Sản phẩm chưa được gán cho cửa hàng.");
            }
            itemsByBranch.computeIfAbsent(b, k -> new java.util.ArrayList<>()).add(ci);
        }

        PaymentMethod pm;
        if ("COD".equalsIgnoreCase(paymentMethodStr == null ? "" : paymentMethodStr.trim())) {
            pm = PaymentMethod.COD;
        } else if ("MOMO".equalsIgnoreCase(paymentMethodStr == null ? "" : paymentMethodStr.trim())) {
            pm = PaymentMethod.MOMO;
        } else {
            throw new IllegalArgumentException("Hệ thống chỉ hỗ trợ COD hoặc MoMo demo xác nhận thủ công.");
        }

        List<Order> createdOrders = new java.util.ArrayList<>();

        for (java.util.Map.Entry<Branch, List<CartItem>> entry : itemsByBranch.entrySet()) {
            Branch branch = entry.getKey();
            List<CartItem> branchItems = entry.getValue();

            double branchSubtotal = branchItems.stream()
                    .mapToDouble(ci -> (ci.getBookCopy().getSellingPrice() != null ? ci.getBookCopy().getSellingPrice() : 0.0) * ci.getQuantity())
                    .sum();

            double branchShipFee = baseShipFee;
            double branchDiscount = 0.0;

            // Chia tổng mức giảm voucher theo tỷ lệ giá trị từng shop. Giới hạn
            // giảm tối đa chỉ được áp dụng một lần cho toàn giỏ hàng.
            if (totalVoucherDiscount > 0 && totalCartSubtotal > 0) {
                branchDiscount += totalVoucherDiscount * branchSubtotal / totalCartSubtotal;
            }

            // Áp dụng khuyến mãi theo chi nhánh nếu có
            if (branch != null && branch.getId() != null) {
                List<Promotion> applicablePromotions = promotionService.findApplicablePromotions(
                        branch.getId(), LocalDate.now(), branchSubtotal);
                double productPromo = applicablePromotions.stream()
                        .filter(p -> p.getType() == null || p.getType() == PromotionType.PRODUCT_PERCENT)
                        .mapToDouble(p -> cappedDiscount(branchSubtotal, p))
                        .max().orElse(0.0);
                final double currentShipFee = branchShipFee;
                double shippingPromo = applicablePromotions.stream()
                        .filter(p -> p.getType() == PromotionType.SHIPPING_PERCENT)
                        .mapToDouble(p -> cappedDiscount(currentShipFee, p))
                        .max().orElse(0.0);
                branchDiscount += productPromo;
                branchShipFee = Math.max(0, branchShipFee - shippingPromo);
            }

            double branchFinalAmount = Math.max(0, branchSubtotal + branchShipFee - branchDiscount);
            double appCommission = branchSubtotal * ((branch != null && branch.getAppDiscountPercent() != null)
                    ? branch.getAppDiscountPercent() / 100.0 : 0.1);

            String orderCode = "WS-" + System.currentTimeMillis() + "-" + UUID.randomUUID().toString().substring(0, 4).toUpperCase();

            // COD chỉ PAID sau khi giao thành công; MoMo demo chỉ PAID sau khi
            // khách báo đã chuyển và Manager chi nhánh kiểm tra thủ công.
            Order order = Order.builder()
                    .orderCode(orderCode)
                    .customer(user)
                    .branch(branch)
                    .shippingProvider(provider)
                    .receiverName(finalName)
                    .receiverPhone(finalPhone)
                    .shippingAddress(finalAddressStr)
                    .totalAmount(branchSubtotal)
                    .shippingFee(branchShipFee)
                    .discountAmount(branchDiscount)
                    .appCommissionAmount(appCommission)
                    .finalAmount(branchFinalAmount)
                    .paymentMethod(pm)
                    .paymentStatus(PaymentStatus.PENDING)
                    .orderStatus(OrderStatus.NEW)
                    .note(note)
                    .build();

            Order savedOrder = orderRepository.save(order);

            // Lưu các order item và trừ tồn kho
            for (CartItem ci : branchItems) {
                BookCopy copy = ci.getBookCopy();
                OrderItem item = OrderItem.builder()
                        .order(savedOrder)
                        .bookCopy(copy)
                        .quantity(ci.getQuantity())
                        .price(copy.getSellingPrice())
                        .build();
                orderItemRepository.save(item);

                if (copy.getQuantity() != null) {
                    int remaining = Math.max(0, copy.getQuantity() - ci.getQuantity());
                    copy.setQuantity(remaining);
                    if (remaining == 0) {
                        copy.setStatus(vn.iotstar.websach.entity.enums.BookCopyStatus.SOLD);
                    }
                    bookCopyRepository.save(copy);
                }
            }

            createdOrders.add(savedOrder);
        }

        // Xóa giỏ hàng sau khi đặt thành công tất cả các đơn
        cartService.clearCart(user);

        return createdOrders;
    }

    private double cappedDiscount(double amount, Promotion promotion) {
        if (promotion.getDiscountPercent() == null) return 0.0;
        double value = amount * promotion.getDiscountPercent() / 100.0;
        if (promotion.getMaxDiscountAmount() != null) {
            value = Math.min(value, promotion.getMaxDiscountAmount());
        }
        return Math.max(0.0, value);
    }
}
