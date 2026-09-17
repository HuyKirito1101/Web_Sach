package vn.iotstar.websach.controller.manager;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import vn.iotstar.websach.dto.BranchStatDTO;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.service.OrderService;
import vn.iotstar.websach.service.StatService;
import vn.iotstar.websach.service.UserService;

@Controller
@RequestMapping("/manager")
@RequiredArgsConstructor
public class ManagerDashboardController {

    private final StatService statService;
    private final UserService userService;
    private final OrderService orderService;

    @GetMapping("/dashboard")
    public String dashboard(Authentication authentication, Model model) {
        String email = authentication.getName();
        User manager = userService.findByEmail(email).orElse(null);

        Long branchId = (manager != null && manager.getBranch() != null) ? manager.getBranch().getId() : 1L;

        BranchStatDTO stats = statService.getBranchStats(branchId);
        model.addAttribute("stats", stats);
        model.addAttribute("recentOrders", orderService.findOrdersByBranch(branchId).stream().limit(10).toList());
        model.addAttribute("manager", manager);

        return "manager/dashboard";
    }
}
