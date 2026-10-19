package vn.iotstar.websach.controller.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.repository.RoleRepository;
import vn.iotstar.websach.service.BranchService;
import vn.iotstar.websach.service.UserService;

import java.util.List;

@Controller
@RequestMapping("/admin/users")
@RequiredArgsConstructor
public class AdminUserController {

    private final UserService userService;
    private final RoleRepository roleRepository;
    private final BranchService branchService;

    @GetMapping
    public String listUsers(@RequestParam(value = "keyword", required = false) String keyword, Model model) {
        List<User> users = userService.searchUsers(keyword);
        model.addAttribute("users", users);
        model.addAttribute("roles", roleRepository.findAll());
        model.addAttribute("branches", branchService.findAllBranches());
        model.addAttribute("keyword", keyword);
        return "admin/users/list";
    }

    @PostMapping("/update-role-status")
    public String updateRoleStatus(@RequestParam("userId") Long userId,
                                   @RequestParam(value = "roleId", required = false) Long roleId,
                                   @RequestParam(value = "branchId", required = false) Long branchId,
                                   @RequestParam(value = "status", required = false) String status,
                                   Authentication authentication,
                                   RedirectAttributes redirectAttributes) {
        User currentAdmin = userService.findByEmail(authentication.getName()).orElse(null);
        if (currentAdmin != null && currentAdmin.getId().equals(userId)) {
            redirectAttributes.addFlashAttribute("errorMessage", "Không thể tự đổi quyền hoặc trạng thái của tài khoản đang đăng nhập.");
            return "redirect:/admin/users";
        }
        userService.updateUserRoleAndStatus(userId, roleId, branchId, status);
        return "redirect:/admin/users?success";
    }

    @PostMapping("/toggle-lock/{id}")
    public String toggleLock(@PathVariable("id") Long userId,
                             Authentication authentication,
                             RedirectAttributes redirectAttributes) {
        User currentAdmin = userService.findByEmail(authentication.getName()).orElse(null);
        if (currentAdmin != null && currentAdmin.getId().equals(userId)) {
            redirectAttributes.addFlashAttribute("errorMessage", "Bạn không thể tự khóa tài khoản đang đăng nhập.");
            return "redirect:/admin/users";
        }
        userService.toggleUserLock(userId);
        return "redirect:/admin/users?locked";
    }

    @PostMapping("/delete/{id}")
    public String deleteUser(@PathVariable("id") Long userId,
                             Authentication authentication,
                             RedirectAttributes redirectAttributes) {
        try {
            User currentAdmin = userService.findByEmail(authentication.getName()).orElse(null);
            if (currentAdmin != null && currentAdmin.getId().equals(userId)) {
                redirectAttributes.addFlashAttribute("errorMessage", "Bạn không thể tự xóa tài khoản đang đăng nhập.");
                return "redirect:/admin/users";
            }
            userService.deleteUser(userId);
            redirectAttributes.addFlashAttribute("successMessage", "Đã xóa thành công người dùng id: " + userId);
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("errorMessage",
                    "Không thể xóa người dùng vì tài khoản đang liên kết với dữ liệu nghiệp vụ. Hãy khóa tài khoản nếu cần giữ lịch sử.");
        }
        return "redirect:/admin/users";
    }
}
