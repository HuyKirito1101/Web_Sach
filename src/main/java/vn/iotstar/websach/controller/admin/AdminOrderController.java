package vn.iotstar.websach.controller.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.security.core.Authentication;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.dto.AssignShipperRequest;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.entity.enums.RoleName;
import vn.iotstar.websach.service.OrderService;
import vn.iotstar.websach.service.UserService;

import java.util.List;

@Controller
@RequestMapping("/admin/orders")
@RequiredArgsConstructor
public class AdminOrderController {

    private final OrderService orderService;
    private final UserService userService;

    @GetMapping
    public String listOrders(Model model) {
        List<Order> orders = orderService.findAllOrders();
        List<User> shippers = userService.findByRole(RoleName.ROLE_SHIPPER);
        model.addAttribute("orders", orders);
        model.addAttribute("shippers", shippers);
        model.addAttribute("assignForm", new AssignShipperRequest());
        return "admin/orders/list";
    }

    @PostMapping("/update-status")
    public String updateStatus(@RequestParam("orderId") Long orderId, @RequestParam("status") String status) {
        orderService.updateOrderStatus(orderId, OrderStatus.valueOf(status));
        return "redirect:/admin/orders?updated";
    }

    @PostMapping("/assign-shipper")
    public String assignShipper(Authentication authentication, @ModelAttribute("assignForm") AssignShipperRequest request) {
        orderService.assignShipper(request, authentication.getName());
        return "redirect:/admin/orders?assigned";
    }

    @PostMapping("/{id}/delete")
    public String deleteCancelledOrder(@PathVariable("id") Long orderId,
                                       RedirectAttributes redirectAttributes) {
        try {
            orderService.deleteCancelledOrder(orderId);
            redirectAttributes.addFlashAttribute("successMessage", "Đã xóa đơn hàng đã hủy.");
        } catch (RuntimeException ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/admin/orders";
    }
}
