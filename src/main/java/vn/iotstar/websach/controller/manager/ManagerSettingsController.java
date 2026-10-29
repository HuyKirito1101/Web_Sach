package vn.iotstar.websach.controller.manager;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.service.BranchService;
import vn.iotstar.websach.service.ManagerAccessService;
import vn.iotstar.websach.util.ExceptionMessages;

@Controller
@RequestMapping("/manager/settings")
@RequiredArgsConstructor
public class ManagerSettingsController {

    private final ManagerAccessService managerAccessService;
    private final BranchService branchService;

    @GetMapping
    public String settings(Authentication authentication, Model model) {
        model.addAttribute("branch", managerAccessService.requireManagedBranch(authentication.getName()));
        return "manager/settings";
    }

    @PostMapping("/commission")
    public String updateCommission(Authentication authentication,
                                   @RequestParam Double appDiscountPercent,
                                   RedirectAttributes redirect) {
        try {
            if (appDiscountPercent == null || appDiscountPercent < 0 || appDiscountPercent > 100) {
                throw new IllegalArgumentException("Chiết khấu ứng dụng phải nằm trong khoảng 0 đến 100%.");
            }
            Branch branch = managerAccessService.requireManagedBranch(authentication.getName());
            branch.setAppDiscountPercent(appDiscountPercent);
            branchService.saveBranch(branch);
            redirect.addFlashAttribute("successMessage", "Đã cập nhật chiết khấu cho chi nhánh.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/manager/settings";
    }
}
