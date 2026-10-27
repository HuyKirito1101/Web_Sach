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
import vn.iotstar.websach.repository.ReviewRepository;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.service.ManagerAccessService;
import vn.iotstar.websach.service.OrderService;
import vn.iotstar.websach.service.RealtimeNotificationService;

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
    private final ReviewRepository reviewRepository;
    private final ManagerAccessService managerAccessService;
    private final RealtimeNotificationService realtimeNotificationService;

    @Override
    public List<Order> findAllOrders() {
        return orderRepository.findAll();
    }

    @Override
    public List<Order> findOrdersByBranch(Long branchId) {
        return orderRepository.findByBranchId(branchId).stream()
                .filter(order -> !Boolean.TRUE.equals(order.getManagerArchived()))
                .toList();
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

        OrderStatus current = order.getOrderStatus();
        if (current == status) return order;
        if (order.getPaymentMethod() == PaymentMethod.MOMO
                && status != OrderStatus.CANCELLED
                && order.getPaymentStatus() != PaymentStatus.PAID) {
            throw new IllegalStateException("Đơn MoMo chưa được xác nhận thanh toán.");
        }
        if (order.getPaymentMethod() == PaymentMethod.MOMO
                && status == OrderStatus.CANCELLED
                && order.getPaymentStatus() == PaymentStatus.PAID) {
            throw new IllegalStateException("Đơn MoMo đã thanh toán phải thực hiện quy trình hoàn tiền.");
        }
        if (!isAllowedTransition(current, status)) {
            throw new IllegalStateException("Không được chuyển trạng thái đơn từ " + current + " sang " + status + ".");
        }

        order.setOrderStatus(status);
        if (status == OrderStatus.DELIVERED && order.getPaymentMethod() == PaymentMethod.COD) {
            order.setPaymentStatus(PaymentStatus.PAID);
        } else if (status == OrderStatus.REFUNDED) {
            order.setPaymentStatus(PaymentStatus.REFUNDED);
        } else if (status == OrderStatus.RETURNED || status == OrderStatus.CANCELLED) {
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
            if (status == OrderStatus.CANCELLED && order.getPaymentMethod() == PaymentMethod.MOMO) {
                order.setPaymentStatus(PaymentStatus.FAILED);
            }
        }

        Order saved = orderRepository.save(order);

        // Gửi WebSocket Notification cập nhật trạng thái đơn
        realtimeNotificationService.notifyOrder(order.getBranch().getId(),
                "Đơn hàng " + order.getOrderCode() + " đã chuyển sang trạng thái: " + status);

        return saved;
    }

    private boolean isAllowedTransition(OrderStatus current, OrderStatus target) {
        return switch (current) {
            case NEW -> target == OrderStatus.CONFIRMED || target == OrderStatus.CANCELLED;
            case CONFIRMED -> target == OrderStatus.PACKING || target == OrderStatus.CANCELLED;
            case PACKING -> target == OrderStatus.READY_FOR_PICKUP || target == OrderStatus.CANCELLED;
            case READY_FOR_PICKUP -> target == OrderStatus.PICKED_UP || target == OrderStatus.SHIPPING
                    || target == OrderStatus.CANCELLED;
            case PICKED_UP -> target == OrderStatus.SHIPPING;
            case SHIPPING -> target == OrderStatus.DELIVERED;
            case DELIVERED -> target == OrderStatus.RETURN_REQUESTED;
            case RETURN_REQUESTED -> target == OrderStatus.RETURNED;
            case RETURNED -> target == OrderStatus.REFUNDED;
            case CANCELLED, REFUNDED -> false;
        };
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
        if (assignerRole != RoleName.ROLE_MANAGER && assignerRole != RoleName.ROLE_ADMIN && assignerRole != RoleName.ROLE_VENDOR) {
            throw new SecurityException("Chỉ Manager/Admin được phân công Shipper");
        }
        if (shipper.getRole() == null || shipper.getRole().getName() != RoleName.ROLE_SHIPPER) {
            throw new IllegalArgumentException("Tài khoản được chọn không phải Shipper");
        }
        boolean isReturn = (order.getOrderStatus() == OrderStatus.RETURN_REQUESTED || order.getOrderStatus() == OrderStatus.RETURNED);
        if (order.getOrderStatus() != OrderStatus.READY_FOR_PICKUP && !isReturn) {
            throw new IllegalStateException("Chỉ phân Shipper khi đơn READY_FOR_PICKUP");
        }
        if (assignedBy.getBranch() != null && (assignerRole == RoleName.ROLE_MANAGER || assignerRole == RoleName.ROLE_VENDOR)
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

        if (!isReturn) {
            order.setOrderStatus(OrderStatus.READY_FOR_PICKUP);
        }
        orderRepository.save(order);

        DeliveryAssignment saved = deliveryAssignmentRepository.save(assignment);

        // Notify Shipper via WebSocket
        try {
            messagingTemplate.convertAndSend("/topic/shipper/" + shipper.getId(), "Bạn vừa được phân công đơn hàng mới: " + order.getOrderCode());
        } catch (Exception ignored) {}

        return saved;
    }

    @Override
    @Transactional
    public int clearCompletedOrderHistory(String managerEmail) {
        Long branchId = managerAccessService.requireManagedBranch(managerEmail).getId();
        List<Order> completedOrders = orderRepository.findByBranchId(branchId).stream()
                .filter(order -> !Boolean.TRUE.equals(order.getManagerArchived()))
                .filter(order -> order.getOrderStatus() == OrderStatus.DELIVERED
                        || order.getOrderStatus() == OrderStatus.CANCELLED
                        || order.getOrderStatus() == OrderStatus.REFUNDED)
                .toList();
        completedOrders.forEach(order -> order.setManagerArchived(true));
        orderRepository.saveAll(completedOrders);
        return completedOrders.size();
    }

    @Override
    @Transactional
    public void deleteCancelledOrder(Long orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy đơn hàng id: " + orderId));
        if (order.getOrderStatus() != OrderStatus.CANCELLED) {
            throw new IllegalStateException("Chỉ được xóa đơn hàng đã hủy.");
        }

        // Xóa theo thứ tự bảng con -> bảng cha để không vi phạm khóa ngoại MySQL.
        deliveryAssignmentRepository.findByOrderId(orderId)
                .ifPresent(deliveryAssignmentRepository::delete);
        reviewRepository.deleteAll(reviewRepository.findByOrderItemOrderId(orderId));
        orderItemRepository.deleteAll(orderItemRepository.findByOrderId(orderId));
        orderRepository.delete(order);
        orderRepository.flush();

        realtimeNotificationService.notifyOrder(order.getBranch().getId(),
                "Đơn hàng " + order.getOrderCode() + " đã được xóa.");
    }

}
