package vn.iotstar.websach;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
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
@ActiveProfiles("h2")
@Transactional
class VendorShipperWorkflowIntegrationTest {

    private static final String VENDOR_EMAIL = "vendor.thuduc1@websachcu.vn";
    private static final String SHIPPER_EMAIL = "shipper.thuduc1@websachcu.vn";

    @Autowired private VendorService vendorService;
    @Autowired private ShipperService shipperService;
    @Autowired private OrderService orderService;
    @Autowired private UserRepository userRepository;

    @Test
    void vendorToShipperCodWorkflowIsScopedAndCompletes() {
        Order order = orderService.findByOrderCode("DH-DEMO-001").orElseThrow();

        vendorService.updateOrderStatus(VENDOR_EMAIL, order.getId(), OrderStatus.CONFIRMED);
        vendorService.updateOrderStatus(VENDOR_EMAIL, order.getId(), OrderStatus.PACKING);
        vendorService.updateOrderStatus(VENDOR_EMAIL, order.getId(), OrderStatus.READY_FOR_PICKUP);

        User shipper = userRepository.findByEmail(SHIPPER_EMAIL).orElseThrow();
        AssignShipperRequest request = new AssignShipperRequest();
        request.setOrderId(order.getId());
        request.setShipperId(shipper.getId());
        request.setNote("Giao trong giờ hành chính");
        DeliveryAssignment assignment = orderService.assignShipper(request, "manager@websachcu.vn");

        assertThat(assignment.getStatus()).isEqualTo(DeliveryStatus.ASSIGNED);
        assertThatThrownBy(() -> shipperService.getAssignment(VENDOR_EMAIL, assignment.getId()))
                .isInstanceOf(SecurityException.class);

        shipperService.updateStatus(SHIPPER_EMAIL, assignment.getId(), DeliveryStatus.ACCEPTED, null);
        shipperService.updateStatus(SHIPPER_EMAIL, assignment.getId(), DeliveryStatus.PICKED_UP, null);
        shipperService.updateStatus(SHIPPER_EMAIL, assignment.getId(), DeliveryStatus.SHIPPING, null);
        DeliveryAssignment delivered = shipperService.updateStatus(
                SHIPPER_EMAIL, assignment.getId(), DeliveryStatus.DELIVERED, null);

        Order completedOrder = orderService.findById(order.getId()).orElseThrow();
        assertThat(delivered.getDeliveredAt()).isNotNull();
        assertThat(completedOrder.getOrderStatus()).isEqualTo(OrderStatus.DELIVERED);
        assertThat(completedOrder.getPaymentStatus()).isEqualTo(PaymentStatus.PAID);
        assertThat(shipperService.getDashboard(SHIPPER_EMAIL, null, null).getDelivered()).isEqualTo(1);
    }

    @Test
    void failedDeliveryRequiresAReason() {
        Order order = orderService.findByOrderCode("DH-DEMO-001").orElseThrow();
        vendorService.updateOrderStatus(VENDOR_EMAIL, order.getId(), OrderStatus.CONFIRMED);
        vendorService.updateOrderStatus(VENDOR_EMAIL, order.getId(), OrderStatus.READY_FOR_PICKUP);

        User shipper = userRepository.findByEmail(SHIPPER_EMAIL).orElseThrow();
        AssignShipperRequest request = new AssignShipperRequest();
        request.setOrderId(order.getId());
        request.setShipperId(shipper.getId());
        DeliveryAssignment assignment = orderService.assignShipper(request, "manager@websachcu.vn");
        shipperService.updateStatus(SHIPPER_EMAIL, assignment.getId(), DeliveryStatus.PICKED_UP, null);

        assertThatThrownBy(() -> shipperService.updateStatus(
                SHIPPER_EMAIL, assignment.getId(), DeliveryStatus.FAILED, " "))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("lý do");
    }
}
