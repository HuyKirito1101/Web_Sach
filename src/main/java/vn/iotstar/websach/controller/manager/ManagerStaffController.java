package vn.iotstar.websach.controller.manager;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.service.UserService;

import java.util.List;

@Controller
@RequestMapping("/manager/staff")
@RequiredArgsConstructor
public class ManagerStaffController {

    private final UserService userService;

    @GetMapping
    public String listBranchStaff(Authentication authentication, Model model) {
        String email = authentication.getName();
        User manager = userService.findByEmail(email).orElse(null);
        Long branchId = (manager != null && manager.getBranch() != null) ? manager.getBranch().getId() : 1L;

        List<User> staffList = userService.findAllUsers().stream()
                .filter(u -> u.getBranch() != null && u.getBranch().getId().equals(branchId))
                .toList();

        model.addAttribute("staffList", staffList);
        return "manager/staff/list";
    }
}
