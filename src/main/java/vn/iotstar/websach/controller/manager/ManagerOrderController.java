package vn.iotstar.websach.controller.manager;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.iotstar.websach.dto.AssignShipperRequest;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.entity.enums.RoleName;
import vn.iotstar.websach.service.OrderService;
import vn.iotstar.websach.service.UserService;

import java.util.List;

@Controller
@RequestMapping("/manager/orders")
@RequiredArgsConstructor
public class ManagerOrderController {

    private final OrderService orderService;
    private final UserService userService;

    @GetMapping
    public String listBranchOrders(Authentication authentication, Model model) {
        String email = authentication.getName();
        User manager = userService.findByEmail(email).orElse(null);
        Long branchId = (manager != null && manager.getBranch() != null) ? manager.getBranch().getId() : 1L;

        List<Order> orders = orderService.findOrdersByBranch(branchId);
        List<User> shippers = userService.findByRole(RoleName.ROLE_SHIPPER);

        model.addAttribute("orders", orders);
        model.addAttribute("shippers", shippers);
        model.addAttribute("assignForm", new AssignShipperRequest());
        return "manager/orders/list";
    }

    @PostMapping("/update-status")
    public String updateStatus(@RequestParam("orderId") Long orderId, @RequestParam("status") String status) {
        orderService.updateOrderStatus(orderId, OrderStatus.valueOf(status));
        return "redirect:/manager/orders?updated";
    }

    @PostMapping("/assign-shipper")
    public String assignShipper(@ModelAttribute("assignForm") AssignShipperRequest request) {
        orderService.assignShipper(request);
        return "redirect:/manager/orders?assigned";
    }
}
