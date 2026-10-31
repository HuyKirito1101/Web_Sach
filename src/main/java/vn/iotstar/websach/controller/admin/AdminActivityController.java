package vn.iotstar.websach.controller.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import vn.iotstar.websach.service.ManagerActivityLogService;

@Controller
@RequestMapping("/admin/activity")
@RequiredArgsConstructor
public class AdminActivityController {

    private final ManagerActivityLogService activityLogService;

    @GetMapping
    public String history(Model model) {
        model.addAttribute("activities", activityLogService.recentSystemHistory());
        return "admin/activity/list";
    }
}
