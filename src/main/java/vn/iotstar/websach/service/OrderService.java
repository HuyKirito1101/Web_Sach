package vn.iotstar.websach.service;

import vn.iotstar.websach.dto.AssignShipperRequest;
import vn.iotstar.websach.entity.DeliveryAssignment;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.enums.OrderStatus;

import java.util.List;
import java.util.Optional;

public interface OrderService {
    List<Order> findAllOrders();
    List<Order> findOrdersByBranch(Long branchId);
    List<Order> findOrdersByCustomer(Long customerId);
    Optional<Order> findById(Long id);
    Optional<Order> findByOrderCode(String orderCode);
    Order updateOrderStatus(Long orderId, OrderStatus status);
    DeliveryAssignment assignShipper(AssignShipperRequest request, String assignedByEmail);
    int clearCompletedOrderHistory(String managerEmail);
    void deleteCancelledOrder(Long orderId);
}
