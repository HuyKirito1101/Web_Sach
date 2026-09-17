package vn.iotstar.websach.controller.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import vn.iotstar.websach.dto.SystemStatDTO;
import vn.iotstar.websach.service.BranchService;
import vn.iotstar.websach.service.OrderService;
import vn.iotstar.websach.service.StatService;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminDashboardController {

    private final StatService statService;
    private final BranchService branchService;
    private final OrderService orderService;

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        SystemStatDTO stats = statService.getSystemStats();
        model.addAttribute("stats", stats);
        model.addAttribute("branches", branchService.findAllBranches());
        model.addAttribute("recentOrders", orderService.findAllOrders().stream().limit(10).toList());
        return "admin/dashboard";
    }
}
