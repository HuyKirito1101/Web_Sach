package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.*;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.entity.enums.PaymentMethod;
import vn.iotstar.websach.entity.enums.PaymentStatus;
import vn.iotstar.websach.repository.*;
import vn.iotstar.websach.service.CartService;
import vn.iotstar.websach.service.CheckoutService;

import java.util.List;
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

    @Override
    public Order processCheckout(User user, Long addressId, String recipientName, String phone, String shippingAddress, Long shippingProviderId, String voucherCode, String paymentMethodStr, String note) {
        List<CartItem> cartItems = cartService.getCartItems(user);
        if (cartItems.isEmpty()) {
            throw new IllegalStateException("Giỏ hàng của bạn đang trống!");
        }

        // Determine address info
        String finalName = recipientName;
        String finalPhone = phone;
        String finalAddressStr = shippingAddress;

        if (addressId != null) {
            Address addr = addressRepository.findByIdAndUser(addressId, user).orElse(null);
            if (addr != null) {
                finalName = addr.getRecipientName();
                finalPhone = addr.getPhone();
                finalAddressStr = addr.getStreet() + ", " + (addr.getWard() != null ? addr.getWard() + ", " : "") + (addr.getDistrict() != null ? addr.getDistrict() + ", " : "") + addr.getCity();
            }
        }

        if (finalName == null || finalName.trim().isEmpty()) finalName = user.getFullName();
        if (finalPhone == null || finalPhone.trim().isEmpty()) finalPhone = user.getPhone() != null ? user.getPhone() : "0900000000";
        if (finalAddressStr == null || finalAddressStr.trim().isEmpty()) finalAddressStr = "Địa chỉ nhận hàng mặc định";

        ShippingProvider provider = null;
        double shipFee = 30000.0;
        if (shippingProviderId != null) {
            provider = shippingProviderRepository.findById(shippingProviderId).orElse(null);
            if (provider != null && provider.getBaseFee() != null) {
                shipFee = provider.getBaseFee();
            }
        }

        // Calculate subtotal
        double subtotal = cartItems.stream()
                .mapToDouble(ci -> (ci.getBookCopy().getSellingPrice() != null ? ci.getBookCopy().getSellingPrice() : 0.0) * ci.getQuantity())
                .sum();

        // Check voucher
        double discount = 0.0;
        if (voucherCode != null && !voucherCode.trim().isEmpty()) {
            AppDiscount promo = appDiscountRepository.findByCodeAndActiveTrue(voucherCode.trim()).orElse(null);
            if (promo != null) {
                if (promo.getDiscountPercent() != null) {
                    discount = subtotal * (promo.getDiscountPercent() / 100.0);
                    if (promo.getMaxDiscountAmount() != null && discount > promo.getMaxDiscountAmount()) {
                        discount = promo.getMaxDiscountAmount();
                    }
                }
            }
        }

        double finalAmount = Math.max(0, subtotal + shipFee - discount);

        PaymentMethod pm = PaymentMethod.COD;
        try {
            if (paymentMethodStr != null) {
                pm = PaymentMethod.valueOf(paymentMethodStr.toUpperCase());
            }
        } catch (Exception ignored) {}

        PaymentStatus ps = (pm == PaymentMethod.VNPAY) ? PaymentStatus.PAID : PaymentStatus.PENDING;

        // Take primary branch from first cart item
        Branch branch = cartItems.get(0).getBookCopy().getBranch();
        double appCommission = subtotal * (branch.getAppDiscountPercent() != null ? branch.getAppDiscountPercent() / 100.0 : 0.1);

        String orderCode = "WS-" + System.currentTimeMillis() + "-" + UUID.randomUUID().toString().substring(0, 4).toUpperCase();

        Order order = Order.builder()
                .orderCode(orderCode)
                .customer(user)
                .branch(branch)
                .shippingProvider(provider)
                .receiverName(finalName)
                .receiverPhone(finalPhone)
                .shippingAddress(finalAddressStr)
                .totalAmount(subtotal)
                .shippingFee(shipFee)
                .discountAmount(discount)
                .appCommissionAmount(appCommission)
                .finalAmount(finalAmount)
                .paymentMethod(pm)
                .paymentStatus(ps)
                .orderStatus(OrderStatus.NEW)
                .note(note)
                .build();

        Order savedOrder = orderRepository.save(order);

        // Save order items & update inventory
        for (CartItem ci : cartItems) {
            BookCopy copy = ci.getBookCopy();
            OrderItem item = OrderItem.builder()
                    .order(savedOrder)
                    .bookCopy(copy)
                    .quantity(ci.getQuantity())
                    .price(copy.getSellingPrice())
                    .build();
            orderItemRepository.save(item);

            // Reduce stock
            if (copy.getQuantity() != null) {
                copy.setQuantity(Math.max(0, copy.getQuantity() - ci.getQuantity()));
                bookCopyRepository.save(copy);
            }
        }

        // Clear cart
        cartService.clearCart(user);

        return savedOrder;
    }
}
