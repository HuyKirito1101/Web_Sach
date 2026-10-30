package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.OrderItem;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.DeliveryAssignment;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.entity.enums.PaymentMethod;
import vn.iotstar.websach.entity.enums.PaymentStatus;
import vn.iotstar.websach.repository.DeliveryAssignmentRepository;
import vn.iotstar.websach.repository.OrderItemRepository;
import vn.iotstar.websach.repository.OrderRepository;
import vn.iotstar.websach.repository.BookCopyRepository;
import vn.iotstar.websach.service.CustomerOrderService;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CustomerOrderServiceImpl implements CustomerOrderService {

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final DeliveryAssignmentRepository deliveryAssignmentRepository;
    private final BookCopyRepository bookCopyRepository;

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
    public Optional<DeliveryAssignment> getLatestDeliveryAssignment(User user, Long orderId) {
        if (getOrderById(user, orderId) == null) {
            return Optional.empty();
        }
        return deliveryAssignmentRepository.findFirstByOrderIdOrderByIdDesc(orderId);
    }

    @Override
    @Transactional
    public Order markMomoTransferred(User user, Long orderId) {
        Order order = getOrderById(user, orderId);
        if (order == null) {
            throw new SecurityException("Đơn hàng không tồn tại hoặc không thuộc tài khoản của bạn.");
        }
        if (order.getPaymentMethod() != PaymentMethod.MOMO) {
            throw new IllegalStateException("Đơn hàng này không sử dụng thanh toán MoMo.");
        }
        if (order.getOrderStatus() == OrderStatus.CANCELLED || order.getOrderStatus() == OrderStatus.REFUNDED) {
            throw new IllegalStateException("Không thể báo chuyển tiền cho đơn hàng đã hủy hoặc hoàn tiền.");
        }
        if (order.getPaymentStatus() != PaymentStatus.PENDING) {
            throw new IllegalStateException(order.getPaymentStatus() == PaymentStatus.PAID
                    ? "Đơn hàng đã được xác nhận thanh toán."
                    : "Yêu cầu xác nhận thanh toán đã được gửi trước đó.");
        }
        order.setPaymentStatus(PaymentStatus.AWAITING_CONFIRMATION);
        order.setPaymentSubmittedAt(LocalDateTime.now());
        return orderRepository.save(order);
    }

    @Override
    @Transactional
    public boolean cancelOrder(User user, Long orderId, String reason) {
        Order order = getOrderById(user, orderId);
        if (order != null && (order.getOrderStatus() == OrderStatus.NEW || order.getOrderStatus() == OrderStatus.CONFIRMED)) {
            if (order.getPaymentMethod() == PaymentMethod.MOMO
                    && order.getPaymentStatus() == PaymentStatus.PAID) {
                throw new IllegalStateException("Đơn MoMo đã thanh toán không thể hủy trực tiếp. Vui lòng liên hệ cửa hàng để hoàn tiền.");
            }
            order.setOrderStatus(OrderStatus.CANCELLED);
            if (order.getPaymentMethod() == PaymentMethod.MOMO) {
                order.setPaymentStatus(PaymentStatus.FAILED);
            }
            restoreInventory(order);
            if (reason != null && !reason.trim().isEmpty()) {
                order.setNote((order.getNote() != null ? order.getNote() + " | " : "") + "Khách hủy: " + reason);
            }
            orderRepository.save(order);
            return true;
        }
        return false;
    }

    private void restoreInventory(Order order) {
        for (OrderItem item : orderItemRepository.findByOrderId(order.getId())) {
            if (item.getBookCopy() == null || item.getQuantity() == null) continue;
            var copy = item.getBookCopy();
            copy.setQuantity((copy.getQuantity() == null ? 0 : copy.getQuantity()) + item.getQuantity());
            if (copy.getQuantity() > 0
                    && copy.getStatus() == vn.iotstar.websach.entity.enums.BookCopyStatus.SOLD) {
                copy.setStatus(vn.iotstar.websach.entity.enums.BookCopyStatus.AVAILABLE);
            }
            bookCopyRepository.save(copy);
        }
    }

    @Override
    @Transactional
    public boolean requestReturnOrder(User user, Long orderId, String reason) {
        return requestReturnOrder(user, orderId, reason, "STORE", null);
    }

    @Override
    @Transactional
    public boolean requestReturnOrder(User user, Long orderId, String reason, String returnAddress) {
        String method = (returnAddress != null && !returnAddress.isBlank()) ? "SHIPPER" : "STORE";
        return requestReturnOrder(user, orderId, reason, method, returnAddress);
    }

    @Override
    @Transactional
    public boolean requestReturnOrder(User user, Long orderId, String reason, String returnMethod, String returnAddress) {
        Order order = getOrderById(user, orderId);
        if (order != null && order.getOrderStatus() == OrderStatus.DELIVERED) {
            order.setOrderStatus(OrderStatus.RETURN_REQUESTED);
            // Đơn đã được Manager dọn khỏi lịch sử phải xuất hiện lại khi khách
            // phát sinh yêu cầu hoàn trả cần xử lý.
            order.setManagerArchived(false);
            order.setReturnReason(reason);

            // Giữ lại phân công giao ban đầu để khách và Vendor còn xem được
            // nhà vận chuyển/Shipper đã giao đơn. Nhiệm vụ lấy hàng hoàn sẽ được
            // phân công lại trên bản ghi này và được nhận diện bằng ghi chú hoàn trả.

            String method = (returnMethod != null && returnMethod.equalsIgnoreCase("SHIPPER")) ? "SHIPPER" : "STORE";
            order.setReturnMethod(method);

            double finalAmt = order.getFinalAmount() != null ? order.getFinalAmount() : 0.0;
            double shippingFee = (order.getShippingFee() != null && order.getShippingFee() > 0) ? order.getShippingFee() : 20000.0;

            if ("SHIPPER".equals(method)) {
                // Khách hàng chịu 50% phí ship hoàn trả
                double customerReturnFee = Math.round(shippingFee * 0.5);
                order.setReturnShippingFee(customerReturnFee);
                order.setRefundAmount(Math.max(0.0, finalAmt - customerReturnFee));
                String finalAddr = (returnAddress != null && !returnAddress.isBlank()) ? returnAddress.trim() : order.getShippingAddress();
                order.setReturnAddress(finalAddr);
                order.setNote((order.getNote() != null ? order.getNote() + " | " : "") +
                        "Khách yêu cầu trả hàng qua Shipper: " + reason + " (Địa chỉ lấy: " + finalAddr +
                        ", Phí ship khách chịu 50%: " + String.format("%,.0f", customerReturnFee) + "đ, Hoàn lại: " + String.format("%,.0f", order.getRefundAmount()) + "đ)");
            } else {
                // Khách hàng tự mang sách đến cơ sở chi nhánh hoàn trả
                order.setReturnShippingFee(0.0);
                order.setRefundAmount(finalAmt);
                String branchAddr = (order.getBranch() != null)
                        ? (order.getBranch().getName() + " - " + order.getBranch().getAddress())
                        : "Cơ sở chi nhánh cửa hàng";
                order.setReturnAddress(branchAddr);
                order.setNote((order.getNote() != null ? order.getNote() + " | " : "") +
                        "Khách yêu cầu trả hàng tại cơ sở: " + reason + " (Địa chỉ cơ sở: " + branchAddr +
                        ", Miễn phí ship hoàn trả, Hoàn lại: " + String.format("%,.0f", finalAmt) + "đ)");
            }

            orderRepository.save(order);
            return true;
        }
        return false;
    }
}
