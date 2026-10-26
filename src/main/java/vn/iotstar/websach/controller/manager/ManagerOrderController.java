package vn.iotstar.websach.controller.manager;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.dto.AssignShipperRequest;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.entity.enums.RoleName;
import vn.iotstar.websach.service.OrderService;
import vn.iotstar.websach.service.ManagerAccessService;
import vn.iotstar.websach.service.UserService;

import java.util.List;

@Controller
@RequestMapping("/manager/orders")
@RequiredArgsConstructor
public class ManagerOrderController {

    private final OrderService orderService;
    private final UserService userService;
    private final ManagerAccessService managerAccessService;

    @GetMapping
    public String listBranchOrders(Authentication authentication, Model model) {
        String email = authentication.getName();
        Long branchId = managerAccessService.requireManagedBranch(email).getId();

        List<Order> orders = orderService.findOrdersByBranch(branchId);
        List<User> shippers = userService.findByRoleAndBranch(RoleName.ROLE_SHIPPER, branchId);

        model.addAttribute("orders", orders);
        model.addAttribute("shippers", shippers);
        model.addAttribute("assignForm", new AssignShipperRequest());
        return "manager/orders/list";
    }

    @PostMapping("/update-status")
    public String updateStatus(Authentication authentication,
                               @RequestParam("orderId") Long orderId,
                               @RequestParam("status") String status,
                               RedirectAttributes redirect) {
        try {
            Order order = managerAccessService.requireOrderInBranch(authentication.getName(), orderId);
            OrderStatus target = OrderStatus.valueOf(status);
            if (!isAllowedTransition(order.getOrderStatus(), target)) {
                throw new IllegalStateException("Không thể chuyển trạng thái "
                        + order.getOrderStatus() + " sang " + target + ".");
            }
            orderService.updateOrderStatus(orderId, target);
            redirect.addFlashAttribute("successMessage", "Đã cập nhật trạng thái đơn hàng.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/manager/orders";
    }

    @PostMapping("/assign-shipper")
    public String assignShipper(Authentication authentication,
                                @ModelAttribute("assignForm") AssignShipperRequest request,
                                RedirectAttributes redirect) {
        try {
            managerAccessService.requireOrderInBranch(authentication.getName(), request.getOrderId());
            orderService.assignShipper(request, authentication.getName());
            redirect.addFlashAttribute("successMessage", "Đã phân công shipper.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/manager/orders";
    }

    @PostMapping("/{id}/confirm-momo-payment")
    public String confirmMomoPayment(@PathVariable("id") Long orderId,
                                     Authentication authentication,
                                     RedirectAttributes redirect) {
        try {
            orderService.confirmManualMomoPayment(orderId, authentication.getName());
            redirect.addFlashAttribute("successMessage", "Đã xác nhận cửa hàng nhận được tiền MoMo.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/manager/orders";
    }

    @PostMapping("/clear-history")
    public String clearCompletedHistory(Authentication authentication,
                                        RedirectAttributes redirect) {
        try {
            int cleared = orderService.clearCompletedOrderHistory(authentication.getName());
            if (cleared == 0) {
                redirect.addFlashAttribute("errorMessage", "Không có đơn hàng đã kết thúc để dọn khỏi lịch sử.");
            } else {
                redirect.addFlashAttribute("successMessage",
                        "Đã dọn " + cleared + " đơn hàng đã kết thúc khỏi danh sách quản lý.");
            }
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/manager/orders";
    }

    private boolean isAllowedTransition(OrderStatus current, OrderStatus target) {
        return (current == OrderStatus.NEW
                    && (target == OrderStatus.CONFIRMED || target == OrderStatus.CANCELLED))
                || (current == OrderStatus.CONFIRMED
                    && (target == OrderStatus.PACKING || target == OrderStatus.READY_FOR_PICKUP
                        || target == OrderStatus.CANCELLED))
                || (current == OrderStatus.PACKING
                    && (target == OrderStatus.READY_FOR_PICKUP || target == OrderStatus.CANCELLED))
                || (current == OrderStatus.RETURN_REQUESTED && target == OrderStatus.RETURNED)
                || (current == OrderStatus.RETURNED && target == OrderStatus.REFUNDED);
    }
}
