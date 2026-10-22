package vn.iotstar.websach.service;

import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.User;

import java.util.List;

public interface CheckoutService {
    List<Order> processCheckout(User user, Long addressId, String recipientName, String phone, String shippingAddress, Long shippingProviderId, String voucherCode, String paymentMethod, String note);
}
