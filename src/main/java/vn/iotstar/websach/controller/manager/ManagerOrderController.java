package vn.iotstar.websach.controller.manager;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.service.OrderService;
import vn.iotstar.websach.service.ManagerAccessService;

import java.util.List;

@Controller
@RequestMapping("/manager/orders")
@RequiredArgsConstructor
public class ManagerOrderController {

    private final OrderService orderService;
    private final ManagerAccessService managerAccessService;

    @GetMapping
    public String listBranchOrders(Authentication authentication, Model model) {
        String email = authentication.getName();
        Long branchId = managerAccessService.requireManagedBranch(email).getId();

        List<Order> orders = orderService.findOrdersByBranch(branchId);
        model.addAttribute("orders", orders);
        return "manager/orders/list";
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

}
