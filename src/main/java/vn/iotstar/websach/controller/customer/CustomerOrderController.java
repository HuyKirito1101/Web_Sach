package vn.iotstar.websach.controller.customer;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.OrderItem;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.service.CustomerOrderService;
import vn.iotstar.websach.service.UserService;

import java.util.List;

@Controller
@RequestMapping("/orders")
@RequiredArgsConstructor
public class CustomerOrderController {

    private final CustomerOrderService customerOrderService;
    private final UserService userService;

    @GetMapping
    public String listOrders(@RequestParam(value = "status", required = false) OrderStatus status,
                             Authentication authentication,
                             Model model) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        List<Order> orders = customerOrderService.getCustomerOrders(user, status);
        model.addAttribute("orders", orders);
        model.addAttribute("selectedStatus", status);
        model.addAttribute("statuses", OrderStatus.values());

        return "customer/order-history";
    }

    @GetMapping("/{id}")
    public String orderDetail(@PathVariable("id") Long id,
                              @RequestParam(value = "success", required = false) Boolean success,
                              Authentication authentication,
                              Model model) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        Order order = customerOrderService.getOrderById(user, id);
        if (order == null) return "redirect:/orders";

        List<OrderItem> items = customerOrderService.getOrderItems(id);

        model.addAttribute("order", order);
        model.addAttribute("items", items);
        model.addAttribute("success", success);

        return "customer/order-detail";
    }

    @PostMapping("/{id}/cancel")
    public String cancelOrder(@PathVariable("id") Long id,
                              @RequestParam(value = "reason", required = false) String reason,
                              Authentication authentication) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        customerOrderService.cancelOrder(user, id, reason);
        return "redirect:/orders/" + id;
    }

    @PostMapping("/{id}/return")
    public String requestReturn(@PathVariable("id") Long id,
                                @RequestParam("reason") String reason,
                                Authentication authentication) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        customerOrderService.requestReturnOrder(user, id, reason);
        return "redirect:/orders/" + id;
    }
}
