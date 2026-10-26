package vn.iotstar.websach.controller.shipper;

import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.enums.DeliveryStatus;
import vn.iotstar.websach.service.ShipperService;

import java.time.LocalDate;

@Controller
@RequestMapping("/shipper")
@RequiredArgsConstructor
public class ShipperController {
    private final ShipperService shipperService;

    @GetMapping({"", "/dashboard"})
    public String dashboard(Authentication auth,
                            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
                            @RequestParam(required = false) Integer chartYear,
                            @RequestParam(required = false) Integer chartMonth,
                            Model model) {
        model.addAttribute("stats", shipperService.getDashboard(auth.getName(), from, to));
        // Chỉ hiện 5 đơn đã hoàn thành gần đây nhất ở dashboard
        model.addAttribute("recentCompletedAssignments", shipperService.getAssignments(auth.getName(), DeliveryStatus.DELIVERED, from, to).stream().limit(5).toList());
        model.addAttribute("incomeAnalytics", shipperService.getIncomeAnalytics(auth.getName(), chartYear, chartMonth));
        model.addAttribute("from", from);
        model.addAttribute("to", to);
        return "shipper/dashboard";
    }

    @GetMapping("/orders")
    public String orders(Authentication auth,
                         @RequestParam(required = false) DeliveryStatus status,
                         @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                         @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
                         Model model) {
        model.addAttribute("assignments", shipperService.getAssignments(auth.getName(), status, from, to));
        model.addAttribute("statuses", DeliveryStatus.values());
        model.addAttribute("selectedStatus", status);
        model.addAttribute("from", from);
        model.addAttribute("to", to);
        return "shipper/orders/list";
    }

    @GetMapping("/orders/{id}")
    public String detail(Authentication auth, @PathVariable Long id, Model model) {
        model.addAttribute("assignment", shipperService.getAssignment(auth.getName(), id));
        return "shipper/orders/detail";
    }

    @PostMapping("/orders/{id}/status")
    public String updateStatus(Authentication auth, @PathVariable Long id,
                               @RequestParam DeliveryStatus status,
                               @RequestParam(required = false) String failureReason,
                               RedirectAttributes redirect) {
        try {
            shipperService.updateStatus(auth.getName(), id, status, failureReason);
            redirect.addFlashAttribute("successMessage", "Đã cập nhật trạng thái giao hàng");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/shipper/orders/" + id;
    }

    @PostMapping("/orders/{id}/reject")
    public String reject(Authentication auth, @PathVariable Long id,
                         @RequestParam String reason,
                         RedirectAttributes redirect) {
        try {
            shipperService.updateStatus(auth.getName(), id, DeliveryStatus.CANCELLED, reason);
            redirect.addFlashAttribute("successMessage", "Đã từ chối nhận đơn giao và gửi lý do về cho cửa hàng");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/shipper/orders";
    }
}
