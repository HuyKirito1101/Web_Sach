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
import vn.iotstar.websach.entity.enums.PaymentMethod;
import vn.iotstar.websach.entity.enums.RoleName;
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
    private final vn.iotstar.websach.repository.OrderItemRepository orderItemRepository;
    private final vn.iotstar.websach.repository.BookCopyRepository bookCopyRepository;

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
        if (status == OrderStatus.DELIVERED && order.getPaymentMethod() == PaymentMethod.COD) {
            order.setPaymentStatus(PaymentStatus.PAID);
        } else if (status == OrderStatus.REFUNDED) {
            order.setPaymentStatus(PaymentStatus.REFUNDED);
        } else if (status == OrderStatus.RETURNED) {
            List<vn.iotstar.websach.entity.OrderItem> items = orderItemRepository.findByOrderId(order.getId());
            for (vn.iotstar.websach.entity.OrderItem item : items) {
                vn.iotstar.websach.entity.BookCopy copy = item.getBookCopy();
                if (copy != null && copy.getQuantity() != null && item.getQuantity() != null) {
                    copy.setQuantity(copy.getQuantity() + item.getQuantity());
                    if (copy.getStatus() == vn.iotstar.websach.entity.enums.BookCopyStatus.SOLD && copy.getQuantity() > 0) {
                        copy.setStatus(vn.iotstar.websach.entity.enums.BookCopyStatus.AVAILABLE);
                    }
                    bookCopyRepository.save(copy);
                }
            }
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
    public DeliveryAssignment assignShipper(AssignShipperRequest request, String assignedByEmail) {
        Order order = orderRepository.findById(request.getOrderId())
                .orElseThrow(() -> new RuntimeException("Đơn hàng không tồn tại id: " + request.getOrderId()));

        User shipper = userRepository.findById(request.getShipperId())
                .orElseThrow(() -> new RuntimeException("Shipper không tồn tại id: " + request.getShipperId()));

        User assignedBy = userRepository.findByEmail(assignedByEmail)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người phân công"));
        RoleName assignerRole = assignedBy.getRole().getName();
        if (assignerRole != RoleName.ROLE_MANAGER && assignerRole != RoleName.ROLE_ADMIN) {
            throw new SecurityException("Chỉ Manager/Admin được phân công Shipper");
        }
        if (shipper.getRole() == null || shipper.getRole().getName() != RoleName.ROLE_SHIPPER) {
            throw new IllegalArgumentException("Tài khoản được chọn không phải Shipper");
        }
        if (order.getOrderStatus() != OrderStatus.READY_FOR_PICKUP) {
            throw new IllegalStateException("Chỉ phân Shipper khi đơn READY_FOR_PICKUP");
        }
        if (assignedBy.getBranch() != null && assignerRole == RoleName.ROLE_MANAGER
                && !assignedBy.getBranch().getId().equals(order.getBranch().getId())) {
            throw new SecurityException("Manager không được phân công đơn ngoài chi nhánh");
        }
        if (shipper.getBranch() == null || !shipper.getBranch().getId().equals(order.getBranch().getId())) {
            throw new IllegalArgumentException("Shipper phải thuộc cùng chi nhánh với đơn hàng");
        }

        DeliveryAssignment assignment = deliveryAssignmentRepository.findByOrderId(order.getId())
                .orElse(DeliveryAssignment.builder().order(order).build());

        assignment.setShipper(shipper);
        assignment.setAssignedBy(assignedBy);
        assignment.setStatus(DeliveryStatus.ASSIGNED);
        assignment.setNote(request.getNote());
        assignment.setAssignedAt(LocalDateTime.now());
        assignment.setPickedUpAt(null);
        assignment.setDeliveredAt(null);
        assignment.setCompletedAt(null);
        assignment.setFailureReason(null);

        order.setOrderStatus(OrderStatus.READY_FOR_PICKUP);
        orderRepository.save(order);

        DeliveryAssignment saved = deliveryAssignmentRepository.save(assignment);

        // Notify Shipper via WebSocket
        try {
            messagingTemplate.convertAndSend("/topic/shipper/" + shipper.getId(), "Bạn vừa được phân công đơn hàng mới: " + order.getOrderCode());
        } catch (Exception ignored) {}

        return saved;
    }

}
