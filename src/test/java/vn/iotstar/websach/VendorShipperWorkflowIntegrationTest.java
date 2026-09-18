package vn.iotstar.websach;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.dto.AssignShipperRequest;
import vn.iotstar.websach.entity.DeliveryAssignment;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.DeliveryStatus;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.entity.enums.PaymentStatus;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.service.OrderService;
import vn.iotstar.websach.service.ShipperService;
import vn.iotstar.websach.service.VendorService;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
@Transactional
class VendorShipperWorkflowIntegrationTest {

    @Autowired private VendorService vendorService;
    @Autowired private ShipperService shipperService;
    @Autowired private OrderService orderService;
    @Autowired private UserRepository userRepository;

    @Test
    void vendorToShipperCodWorkflowIsScopedAndCompletes() {
        Order order = orderService.findByOrderCode("DH-DEMO-001").orElseThrow();

        vendorService.updateOrderStatus("vendor@websach.com", order.getId(), OrderStatus.CONFIRMED);
        vendorService.updateOrderStatus("vendor@websach.com", order.getId(), OrderStatus.PACKING);
        vendorService.updateOrderStatus("vendor@websach.com", order.getId(), OrderStatus.READY_FOR_PICKUP);

        User shipper = userRepository.findByEmail("shipper@websach.com").orElseThrow();
        AssignShipperRequest request = new AssignShipperRequest();
        request.setOrderId(order.getId());
        request.setShipperId(shipper.getId());
        request.setNote("Giao trong giờ hành chính");
        DeliveryAssignment assignment = orderService.assignShipper(request, "manager@websach.com");

        assertThat(assignment.getStatus()).isEqualTo(DeliveryStatus.ASSIGNED);
        assertThatThrownBy(() -> shipperService.getAssignment("vendor@websach.com", assignment.getId()))
                .isInstanceOf(SecurityException.class);

        shipperService.updateStatus("shipper@websach.com", assignment.getId(), DeliveryStatus.ACCEPTED, null);
        shipperService.updateStatus("shipper@websach.com", assignment.getId(), DeliveryStatus.PICKED_UP, null);
        shipperService.updateStatus("shipper@websach.com", assignment.getId(), DeliveryStatus.SHIPPING, null);
        DeliveryAssignment delivered = shipperService.updateStatus(
                "shipper@websach.com", assignment.getId(), DeliveryStatus.DELIVERED, null);

        Order completedOrder = orderService.findById(order.getId()).orElseThrow();
        assertThat(delivered.getDeliveredAt()).isNotNull();
        assertThat(completedOrder.getOrderStatus()).isEqualTo(OrderStatus.DELIVERED);
        assertThat(completedOrder.getPaymentStatus()).isEqualTo(PaymentStatus.PAID);
        assertThat(shipperService.getDashboard("shipper@websach.com", null, null).getDelivered()).isEqualTo(1);
    }

    @Test
    void failedDeliveryRequiresAReason() {
        Order order = orderService.findByOrderCode("DH-DEMO-001").orElseThrow();
        vendorService.updateOrderStatus("vendor@websach.com", order.getId(), OrderStatus.CONFIRMED);
        vendorService.updateOrderStatus("vendor@websach.com", order.getId(), OrderStatus.READY_FOR_PICKUP);

        User shipper = userRepository.findByEmail("shipper@websach.com").orElseThrow();
        AssignShipperRequest request = new AssignShipperRequest();
        request.setOrderId(order.getId());
        request.setShipperId(shipper.getId());
        DeliveryAssignment assignment = orderService.assignShipper(request, "manager@websach.com");
        shipperService.updateStatus("shipper@websach.com", assignment.getId(), DeliveryStatus.PICKED_UP, null);

        assertThatThrownBy(() -> shipperService.updateStatus(
                "shipper@websach.com", assignment.getId(), DeliveryStatus.FAILED, " "))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("lý do");
    }
}
