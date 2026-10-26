package vn.iotstar.websach.config;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;
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
import vn.iotstar.websach.repository.UserRepository;

import java.util.List;
import java.util.Objects;
import java.util.Optional;

@ControllerAdvice
@RequiredArgsConstructor
public class NotificationControllerAdvice {

    private final UserRepository userRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final SellRequestRepository sellRequestRepository;
    private final DeliveryAssignmentRepository deliveryAssignmentRepository;

    @ModelAttribute
    public void addNotificationAttributes(Model model) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated() || "anonymousUser".equals(auth.getName())) {
            return;
        }

        User user = userRepository.findByEmail(auth.getName()).orElse(null);
        if (user == null || user.getRole() == null) return;

        RoleName role = user.getRole().getName();
        if (role == RoleName.ROLE_VENDOR && user.getBranch() != null) {
            Long branchId = user.getBranch().getId();
            Long vendorId = user.getId();

            // Đảm bảo tính độc lập: Chỉ tính các đơn hàng có sách của chính Vendor này
            List<Order> vendorOrders = orderRepository.findByBranchId(branchId).stream()
                    .filter(o -> orderItemRepository.findByOrderId(o.getId()).stream()
                            .anyMatch(item -> item.getBookCopy() != null && item.getBookCopy().getSeller() != null
                                    && Objects.equals(item.getBookCopy().getSeller().getId(), vendorId)))
                    .toList();

            long vNewOrders = vendorOrders.stream()
                    .filter(o -> o.getOrderStatus() == OrderStatus.NEW || o.getOrderStatus() == OrderStatus.CONFIRMED)
                    .count();
            long vReadyOrders = vendorOrders.stream()
                    .filter(o -> o.getOrderStatus() == OrderStatus.READY_FOR_PICKUP)
                    .count();

            // Đơn bị Shipper từ chối cần phân công lại
            long vRejectedBadge = vendorOrders.stream()
                    .filter(o -> {
                        Optional<DeliveryAssignment> da = deliveryAssignmentRepository.findByOrderId(o.getId());
                        return da.isPresent() && da.get().getStatus() == DeliveryStatus.CANCELLED;
                    })
                    .count();

            long vOrderBadge = vNewOrders + vReadyOrders + vRejectedBadge;

            long vReturnBadge = vendorOrders.stream()
                    .filter(o -> o.getOrderStatus() == OrderStatus.RETURN_REQUESTED)
                    .count();

            long vSellBadge = sellRequestRepository.countByBranchIdAndStatus(branchId, SellRequestStatus.PENDING);
            long vTotalNotif = vOrderBadge + vReturnBadge + vSellBadge;

            model.addAttribute("vNewOrders", vNewOrders);
            model.addAttribute("vReadyOrders", vReadyOrders);
            model.addAttribute("vRejectedBadge", vRejectedBadge);
            model.addAttribute("vOrderBadge", vOrderBadge);
            model.addAttribute("vReturnBadge", vReturnBadge);
            model.addAttribute("vSellBadge", vSellBadge);
            model.addAttribute("vTotalNotif", vTotalNotif);

        } else if (role == RoleName.ROLE_SHIPPER) {
            long sAssignedBadge = deliveryAssignmentRepository.countByShipperIdAndStatus(user.getId(), DeliveryStatus.ASSIGNED);
            long sAcceptedBadge = deliveryAssignmentRepository.countByShipperIdAndStatus(user.getId(), DeliveryStatus.ACCEPTED);
            long sPickedUpBadge = deliveryAssignmentRepository.countByShipperIdAndStatus(user.getId(), DeliveryStatus.PICKED_UP);
            long sShippingBadge = deliveryAssignmentRepository.countByShipperIdAndStatus(user.getId(), DeliveryStatus.SHIPPING);
            long sInProgressBadge = sAcceptedBadge + sPickedUpBadge + sShippingBadge;
            long sTotalNotif = sAssignedBadge + sInProgressBadge;

            model.addAttribute("sAssignedBadge", sAssignedBadge);
            model.addAttribute("sInProgressBadge", sInProgressBadge);
            model.addAttribute("sTotalNotif", sTotalNotif);
        }
    }
}
