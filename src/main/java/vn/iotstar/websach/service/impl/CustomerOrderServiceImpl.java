package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.OrderItem;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.repository.DeliveryAssignmentRepository;
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
    private final DeliveryAssignmentRepository deliveryAssignmentRepository;

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
            order.setReturnReason(reason);

            // Xóa phân công vận chuyển chiều giao trước đó (nếu có) để chuẩn bị cho quy trình hoàn trả
            deliveryAssignmentRepository.findByOrderId(order.getId()).ifPresent(deliveryAssignmentRepository::delete);

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
