package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.OrderItem;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.repository.OrderItemRepository;
import vn.iotstar.websach.repository.OrderRepository;
import vn.iotstar.websach.service.CustomerOrderService;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CustomerOrderServiceImpl implements CustomerOrderService {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;

    @Override
    public List<Order> getCustomerOrders(User user, OrderStatus status) {
        List<Order> orders = orderRepository.findByCustomerId(user.getId());
        if (status != null) {
            return orders.stream().filter(o -> o.getOrderStatus() == status).collect(Collectors.toList());
        }
        return orders;
    }

    @Override
    public Order getOrderById(User user, Long orderId) {
        return orderRepository.findById(orderId)
                .filter(o -> o.getCustomer().getId().equals(user.getId()))
                .orElse(null);
    }

    @Override
    public List<OrderItem> getOrderItems(Long orderId) {
        return orderItemRepository.findByOrderId(orderId);
    }

    @Override
    @Transactional
    public boolean cancelOrder(User user, Long orderId, String reason) {
        Order order = getOrderById(user, orderId);
        if (order != null && (order.getOrderStatus() == OrderStatus.NEW || order.getOrderStatus() == OrderStatus.CONFIRMED)) {
            order.setOrderStatus(OrderStatus.CANCELLED);
            if (reason != null && !reason.trim().isEmpty()) {
                order.setNote((order.getNote() != null ? order.getNote() + " | " : "") + "Khách hủy: " + reason);
            }
            orderRepository.save(order);
            return true;
        }
        return false;
    }

    @Override
    @Transactional
    public boolean requestReturnOrder(User user, Long orderId, String reason) {
        Order order = getOrderById(user, orderId);
        if (order != null && order.getOrderStatus() == OrderStatus.DELIVERED) {
            order.setOrderStatus(OrderStatus.CANCELLED);
            order.setNote((order.getNote() != null ? order.getNote() + " | " : "") + "Yêu cầu trả hàng: " + reason);
            orderRepository.save(order);
            return true;
        }
        return false;
    }
}
