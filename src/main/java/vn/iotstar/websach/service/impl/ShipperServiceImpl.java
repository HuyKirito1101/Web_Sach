package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.dto.ShipperDashboardDTO;
import vn.iotstar.websach.entity.DeliveryAssignment;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.*;
import vn.iotstar.websach.repository.DeliveryAssignmentRepository;
import vn.iotstar.websach.repository.OrderRepository;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.service.ShipperService;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ShipperServiceImpl implements ShipperService {
    private final UserRepository userRepository;
    private final DeliveryAssignmentRepository assignmentRepository;
    private final OrderRepository orderRepository;
    private final SimpMessagingTemplate messagingTemplate;

    private User requireShipper(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản Shipper"));
        if (user.getRole() == null || user.getRole().getName() != RoleName.ROLE_SHIPPER) {
            throw new SecurityException("Tài khoản không có quyền Shipper");
        }
        return user;
    }

    @Override
    public List<DeliveryAssignment> getAssignments(String email, DeliveryStatus status, LocalDate from, LocalDate to) {
        User shipper = requireShipper(email);
        return assignmentRepository.findByShipperIdOrderByAssignedAtDesc(shipper.getId()).stream()
                .filter(a -> status == null || a.getStatus() == status)
                .filter(a -> from == null || (a.getAssignedAt() != null && !a.getAssignedAt().toLocalDate().isBefore(from)))
                .filter(a -> to == null || (a.getAssignedAt() != null && !a.getAssignedAt().toLocalDate().isAfter(to)))
                .toList();
    }

    @Override
    public DeliveryAssignment getAssignment(String email, Long assignmentId) {
        User shipper = requireShipper(email);
        DeliveryAssignment assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new IllegalArgumentException("Đơn giao không tồn tại"));
        if (assignment.getShipper() == null || !Objects.equals(assignment.getShipper().getId(), shipper.getId())) {
            throw new SecurityException("Không được truy cập đơn giao của shipper khác");
        }
        return assignment;
    }

    @Override
    @Transactional
    public DeliveryAssignment updateStatus(String email, Long assignmentId, DeliveryStatus target, String failureReason) {
        DeliveryAssignment assignment = getAssignment(email, assignmentId);
        DeliveryStatus current = assignment.getStatus();
        boolean allowed = (current == DeliveryStatus.ASSIGNED && (target == DeliveryStatus.ACCEPTED || target == DeliveryStatus.PICKED_UP || target == DeliveryStatus.CANCELLED))
                || (current == DeliveryStatus.ACCEPTED && (target == DeliveryStatus.PICKED_UP || target == DeliveryStatus.CANCELLED))
                || (current == DeliveryStatus.PICKED_UP && (target == DeliveryStatus.SHIPPING || target == DeliveryStatus.FAILED))
                || (current == DeliveryStatus.SHIPPING && (target == DeliveryStatus.DELIVERED || target == DeliveryStatus.FAILED));
        if (!allowed) throw new IllegalStateException("Không thể chuyển trạng thái giao từ " + current + " sang " + target);
        if (target == DeliveryStatus.FAILED && (failureReason == null || failureReason.isBlank())) {
            throw new IllegalArgumentException("Phải nhập lý do giao thất bại");
        }

        Order order = assignment.getOrder();
        if ((target == DeliveryStatus.ACCEPTED || target == DeliveryStatus.PICKED_UP)
                && order.getOrderStatus() != OrderStatus.READY_FOR_PICKUP) {
            throw new IllegalStateException("Đơn hàng chưa sẵn sàng để lấy");
        }

        assignment.setStatus(target);
        if (target == DeliveryStatus.PICKED_UP) {
            assignment.setPickedUpAt(LocalDateTime.now());
            order.setOrderStatus(OrderStatus.PICKED_UP);
        } else if (target == DeliveryStatus.SHIPPING) {
            order.setOrderStatus(OrderStatus.SHIPPING);
        } else if (target == DeliveryStatus.DELIVERED) {
            LocalDateTime now = LocalDateTime.now();
            assignment.setDeliveredAt(now);
            assignment.setCompletedAt(now);
            order.setOrderStatus(OrderStatus.DELIVERED);
            if (order.getPaymentMethod() == PaymentMethod.COD) order.setPaymentStatus(PaymentStatus.PAID);
        } else if (target == DeliveryStatus.FAILED) {
            assignment.setFailureReason(failureReason.trim());
            assignment.setCompletedAt(LocalDateTime.now());
            order.setOrderStatus(OrderStatus.READY_FOR_PICKUP);
        } else if (target == DeliveryStatus.CANCELLED) {
            assignment.setCompletedAt(LocalDateTime.now());
            order.setOrderStatus(OrderStatus.READY_FOR_PICKUP);
        }
        orderRepository.save(order);
        DeliveryAssignment saved = assignmentRepository.save(assignment);
        try {
            messagingTemplate.convertAndSend("/topic/orders", "Đơn " + order.getOrderCode() + " cập nhật giao hàng: " + target);
        } catch (Exception ignored) { }
        return saved;
    }

    @Override
    public ShipperDashboardDTO getDashboard(String email, LocalDate from, LocalDate to) {
        List<DeliveryAssignment> assignments = getAssignments(email, null, from, to);
        double totalCod = assignments.stream()
                .filter(a -> a.getStatus() == DeliveryStatus.DELIVERED)
                .filter(a -> a.getOrder() != null && a.getOrder().getPaymentMethod() == PaymentMethod.COD)
                .mapToDouble(a -> a.getOrder().getFinalAmount() != null ? a.getOrder().getFinalAmount() : 0.0)
                .sum();

        return ShipperDashboardDTO.builder()
                .total(assignments.size())
                .assigned(assignments.stream().filter(a -> a.getStatus() == DeliveryStatus.ASSIGNED || a.getStatus() == DeliveryStatus.ACCEPTED).count())
                .inProgress(assignments.stream().filter(a -> a.getStatus() == DeliveryStatus.PICKED_UP || a.getStatus() == DeliveryStatus.SHIPPING).count())
                .delivered(assignments.stream().filter(a -> a.getStatus() == DeliveryStatus.DELIVERED).count())
                .failed(assignments.stream().filter(a -> a.getStatus() == DeliveryStatus.FAILED).count())
                .totalCodCollected(totalCod)
                .build();
    }
}
