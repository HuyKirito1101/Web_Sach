package vn.iotstar.websach.service;

import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.OrderItem;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.DeliveryAssignment;
import vn.iotstar.websach.entity.enums.OrderStatus;

import java.util.List;
import java.util.Optional;

public interface CustomerOrderService {
    List<Order> getCustomerOrders(User user, OrderStatus status);
    Order getOrderById(User user, Long orderId);
    List<OrderItem> getOrderItems(Long orderId);
    Optional<DeliveryAssignment> getLatestDeliveryAssignment(User user, Long orderId);
    Order markMomoTransferred(User user, Long orderId);
    boolean cancelOrder(User user, Long orderId, String reason);
    boolean requestReturnOrder(User user, Long orderId, String reason);
    boolean requestReturnOrder(User user, Long orderId, String reason, String returnAddress);
    boolean requestReturnOrder(User user, Long orderId, String reason, String returnMethod, String returnAddress);
}
