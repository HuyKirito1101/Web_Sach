package vn.iotstar.websach.controller.manager;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.RoleName;
import vn.iotstar.websach.service.ManagerAccessService;
import vn.iotstar.websach.service.UserService;

import java.util.List;

@Controller
@RequestMapping("/manager/staff")
@RequiredArgsConstructor
public class ManagerStaffController {

    private final UserService userService;
    private final ManagerAccessService managerAccessService;

    @GetMapping
    public String listBranchStaff(Authentication authentication,
                                  @RequestParam(required = false) String keyword,
                                  Model model) {
        Branch branch = managerAccessService.requireManagedBranch(authentication.getName());
        String search = keyword == null ? "" : keyword.trim().toLowerCase();

        List<User> staffList = userService.findAllUsers().stream()
                .filter(u -> u.getBranch() != null && u.getBranch().getId().equals(branch.getId()))
                .filter(u -> search.isEmpty()
                        || safe(u.getFullName()).contains(search)
                        || safe(u.getEmail()).contains(search)
                        || safe(u.getPhone()).contains(search))
                .toList();

        model.addAttribute("branch", branch);
        model.addAttribute("staffList", staffList);
        model.addAttribute("keyword", keyword);
        return "manager/staff/list";
    }

    @PostMapping("/{id}/toggle-lock")
    public String toggleLock(@PathVariable Long id, Authentication authentication,
                             RedirectAttributes redirect) {
        try {
            User user = managerAccessService.requireUserInBranch(authentication.getName(), id);
            if (user.getRole() != null && (user.getRole().getName() == RoleName.ROLE_ADMIN
                    || user.getRole().getName() == RoleName.ROLE_MANAGER)) {
                throw new SecurityException("Manager không được khóa tài khoản Admin hoặc Manager.");
            }
            userService.toggleUserLock(id);
            redirect.addFlashAttribute("successMessage", "Đã cập nhật trạng thái tài khoản.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/manager/staff";
    }

    private String safe(String value) {
        return value == null ? "" : value.toLowerCase();
    }
}
