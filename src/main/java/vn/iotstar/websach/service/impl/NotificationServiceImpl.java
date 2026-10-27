package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.DeliveryAssignment;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.DeliveryStatus;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.entity.enums.RoleName;
import vn.iotstar.websach.entity.enums.SellRequestStatus;
import vn.iotstar.websach.repository.DeliveryAssignmentRepository;
import vn.iotstar.websach.repository.OrderItemRepository;
import vn.iotstar.websach.repository.OrderRepository;
import vn.iotstar.websach.repository.SellRequestRepository;
import vn.iotstar.websach.repository.SupportConversationRepository;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.repository.VendorConversationRepository;
import vn.iotstar.websach.service.NotificationService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class NotificationServiceImpl implements NotificationService {

    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final SellRequestRepository sellRequestRepository;
    private final DeliveryAssignmentRepository deliveryAssignmentRepository;
    private final SupportConversationRepository supportConversationRepository;
    private final VendorConversationRepository vendorConversationRepository;

    @Override
    public Map<String, Long> getNotificationAttributes(String email) {
        Map<String, Long> attributes = new HashMap<>();
        User user = userRepository.findByEmail(email).orElse(null);
        if (user == null || user.getRole() == null) {
            return attributes;
        }

        attributes.put("userMessageBadge",
                vendorConversationRepository.countByCustomerIdAndCustomerUnreadTrue(user.getId()));

        RoleName role = user.getRole().getName();
        if (role == RoleName.ROLE_MANAGER && user.getBranch() != null) {
            attributes.put("managerMessageBadge", supportConversationRepository
                    .countByBranchIdAndManagerUnreadTrue(user.getBranch().getId()));
        } else if (role == RoleName.ROLE_VENDOR && user.getBranch() != null) {
            addVendorAttributes(attributes, user);
        } else if (role == RoleName.ROLE_SHIPPER) {
            addShipperAttributes(attributes, user);
        }
        return attributes;
    }

    private void addVendorAttributes(Map<String, Long> attributes, User vendor) {
        Long branchId = vendor.getBranch().getId();
        Long vendorId = vendor.getId();
        List<Order> vendorOrders = orderRepository.findByBranchId(branchId).stream()
                .filter(order -> orderItemRepository.findByOrderId(order.getId()).stream()
                        .anyMatch(item -> item.getBookCopy() != null
                                && item.getBookCopy().getSeller() != null
                                && Objects.equals(item.getBookCopy().getSeller().getId(), vendorId)))
                .toList();

        long newOrders = vendorOrders.stream()
                .filter(order -> order.getOrderStatus() == OrderStatus.NEW
                        || order.getOrderStatus() == OrderStatus.CONFIRMED)
                .count();
        long readyOrders = vendorOrders.stream()
                .filter(order -> order.getOrderStatus() == OrderStatus.READY_FOR_PICKUP)
                .count();
        long rejectedAssignments = vendorOrders.stream()
                .filter(order -> {
                    Optional<DeliveryAssignment> assignment = deliveryAssignmentRepository.findByOrderId(order.getId());
                    return assignment.isPresent() && assignment.get().getStatus() == DeliveryStatus.CANCELLED;
                })
                .count();
        long orderBadge = newOrders + readyOrders + rejectedAssignments;
        long returnBadge = vendorOrders.stream()
                .filter(order -> order.getOrderStatus() == OrderStatus.RETURN_REQUESTED)
                .count();
        long sellBadge = sellRequestRepository.countByBranchIdAndStatus(branchId, SellRequestStatus.PENDING);
        long messageBadge = vendorConversationRepository.countByVendorIdAndVendorUnreadTrue(vendorId);

        attributes.put("vNewOrders", newOrders);
        attributes.put("vReadyOrders", readyOrders);
        attributes.put("vRejectedBadge", rejectedAssignments);
        attributes.put("vOrderBadge", orderBadge);
        attributes.put("vReturnBadge", returnBadge);
        attributes.put("vSellBadge", sellBadge);
        attributes.put("vMessageBadge", messageBadge);
        attributes.put("vTotalNotif", orderBadge + returnBadge + sellBadge + messageBadge);
    }

    private void addShipperAttributes(Map<String, Long> attributes, User shipper) {
        long assigned = deliveryAssignmentRepository.countByShipperIdAndStatus(
                shipper.getId(), DeliveryStatus.ASSIGNED);
        long accepted = deliveryAssignmentRepository.countByShipperIdAndStatus(
                shipper.getId(), DeliveryStatus.ACCEPTED);
        long pickedUp = deliveryAssignmentRepository.countByShipperIdAndStatus(
                shipper.getId(), DeliveryStatus.PICKED_UP);
        long shipping = deliveryAssignmentRepository.countByShipperIdAndStatus(
                shipper.getId(), DeliveryStatus.SHIPPING);
        long inProgress = accepted + pickedUp + shipping;

        attributes.put("sAssignedBadge", assigned);
        attributes.put("sInProgressBadge", inProgress);
        attributes.put("sTotalNotif", assigned + inProgress);
    }
}
