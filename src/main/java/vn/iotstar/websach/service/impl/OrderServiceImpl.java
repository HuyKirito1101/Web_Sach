package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.dto.AssignShipperRequest;
import vn.iotstar.websach.entity.DeliveryAssignment;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.DeliveryStatus;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.entity.enums.PaymentStatus;
import vn.iotstar.websach.repository.DeliveryAssignmentRepository;
import vn.iotstar.websach.repository.OrderRepository;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.service.OrderService;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;
    private final UserRepository userRepository;
    private final DeliveryAssignmentRepository deliveryAssignmentRepository;
    private final SimpMessagingTemplate messagingTemplate;

    @Override
    public List<Order> findAllOrders() {
        return orderRepository.findAll();
    }

    @Override
    public List<Order> findOrdersByBranch(Long branchId) {
        return orderRepository.findByBranchId(branchId);
    }

    @Override
    public List<Order> findOrdersByCustomer(Long customerId) {
        return orderRepository.findByCustomerId(customerId);
    }

    @Override
    public Optional<Order> findById(Long id) {
        return orderRepository.findById(id);
    }

    @Override
    public Optional<Order> findByOrderCode(String orderCode) {
        return orderRepository.findByOrderCode(orderCode);
    }

    @Override
    @Transactional
    public Order updateOrderStatus(Long orderId, OrderStatus status) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy đơn hàng id: " + orderId));

        order.setOrderStatus(status);
        if (status == OrderStatus.DELIVERED) {
            order.setPaymentStatus(PaymentStatus.PAID);
        }

        Order saved = orderRepository.save(order);

        // Gửi WebSocket Notification cập nhật trạng thái đơn
        try {
            messagingTemplate.convertAndSend("/topic/orders", "Đơn hàng " + order.getOrderCode() + " đã chuyển sang trạng thái: " + status);
        } catch (Exception ignored) {}

        return saved;
    }

    @Override
    @Transactional
    public DeliveryAssignment assignShipper(AssignShipperRequest request) {
        Order order = orderRepository.findById(request.getOrderId())
                .orElseThrow(() -> new RuntimeException("Đơn hàng không tồn tại id: " + request.getOrderId()));

        User shipper = userRepository.findById(request.getShipperId())
                .orElseThrow(() -> new RuntimeException("Shipper không tồn tại id: " + request.getShipperId()));

        DeliveryAssignment assignment = deliveryAssignmentRepository.findByOrderId(order.getId())
                .orElse(DeliveryAssignment.builder().order(order).build());

        assignment.setShipper(shipper);
        assignment.setStatus(DeliveryStatus.ASSIGNED);
        assignment.setNote(request.getNote());
        assignment.setAssignedAt(LocalDateTime.now());

        order.setOrderStatus(OrderStatus.READY_FOR_PICKUP);
        orderRepository.save(order);

        DeliveryAssignment saved = deliveryAssignmentRepository.save(assignment);

        // Notify Shipper via WebSocket
        try {
            messagingTemplate.convertAndSend("/topic/shipper/" + shipper.getId(), "Bạn vừa được phân công đơn hàng mới: " + order.getOrderCode());
        } catch (Exception ignored) {}

        return saved;
    }

    @Override
    public List<DeliveryAssignment> findAssignmentsByShipper(Long shipperId) {
        return deliveryAssignmentRepository.findByShipperId(shipperId);
    }

    @Override
    @Transactional
    public DeliveryAssignment updateDeliveryStatus(Long assignmentId, String deliveryStatusStr) {
        DeliveryAssignment assignment = deliveryAssignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy phân công giao hàng id: " + assignmentId));

        DeliveryStatus deliveryStatus = DeliveryStatus.valueOf(deliveryStatusStr);
        assignment.setStatus(deliveryStatus);

        Order order = assignment.getOrder();
        if (deliveryStatus == DeliveryStatus.PICKED_UP) {
            order.setOrderStatus(OrderStatus.PICKED_UP);
        } else if (deliveryStatus == DeliveryStatus.SHIPPING) {
            order.setOrderStatus(OrderStatus.SHIPPING);
        } else if (deliveryStatus == DeliveryStatus.DELIVERED) {
            order.setOrderStatus(OrderStatus.DELIVERED);
            order.setPaymentStatus(PaymentStatus.PAID);
            assignment.setCompletedAt(LocalDateTime.now());
        } else if (deliveryStatus == DeliveryStatus.FAILED) {
            order.setOrderStatus(OrderStatus.CANCELLED);
        }

        orderRepository.save(order);
        return deliveryAssignmentRepository.save(assignment);
    }
}
