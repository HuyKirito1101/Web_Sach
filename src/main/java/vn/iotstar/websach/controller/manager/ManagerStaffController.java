package vn.iotstar.websach.controller.manager;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.service.ManagerAccessService;
import vn.iotstar.websach.service.UserService;

import java.util.List;
import vn.iotstar.websach.util.ExceptionMessages;

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
        List<User> staffList = userService.searchUsersForManagedBranch(authentication.getName(), keyword);

        model.addAttribute("branch", branch);
        model.addAttribute("staffList", staffList);
        model.addAttribute("roles", userService.findBranchManageableRoles());
        model.addAttribute("keyword", keyword);
        return "manager/staff/list";
    }

    @PostMapping("/update-role-status")
    public String updateRoleStatus(@RequestParam Long userId,
                                   @RequestParam Long roleId,
                                   @RequestParam String status,
                                   Authentication authentication,
                                   RedirectAttributes redirect) {
        try {
            userService.updateManagedBranchUser(authentication.getName(), userId, roleId, status);
            redirect.addFlashAttribute("successMessage", "Đã cập nhật quyền và trạng thái tài khoản trong chi nhánh.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/manager/staff";
    }

    @PostMapping("/{id}/toggle-lock")
    public String toggleLock(@PathVariable Long id, Authentication authentication,
                             RedirectAttributes redirect) {
        try {
            userService.toggleManagedBranchUserLock(authentication.getName(), id);
            redirect.addFlashAttribute("successMessage", "Đã cập nhật trạng thái tài khoản.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/manager/staff";
    }

    @PostMapping("/{id}/delete")
    public String deleteUser(@PathVariable Long id, Authentication authentication,
                             RedirectAttributes redirect) {
        try {
            userService.deleteManagedBranchUser(authentication.getName(), id);
            redirect.addFlashAttribute("successMessage", "Đã xóa tài khoản khỏi hệ thống.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/manager/staff";
    }
}
