package vn.iotstar.websach.controller.manager;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.Promotion;
import vn.iotstar.websach.entity.enums.PromotionType;
import vn.iotstar.websach.service.ManagerAccessService;
import vn.iotstar.websach.service.PromotionService;

@Controller
@RequestMapping("/manager/promotions")
@RequiredArgsConstructor
public class ManagerPromotionController {

    private final PromotionService promotionService;
    private final ManagerAccessService managerAccessService;

    @GetMapping
    public String list(Authentication authentication, Model model) {
        Branch branch = managerAccessService.requireManagedBranch(authentication.getName());
        model.addAttribute("branch", branch);
        model.addAttribute("promotions", promotionService.findByBranch(branch.getId()));
        model.addAttribute("types", PromotionType.values());
        model.addAttribute("promotionForm", new Promotion());
        return "manager/promotions/list";
    }

    @PostMapping("/save")
    public String save(Authentication authentication, @ModelAttribute Promotion promotion,
                       RedirectAttributes redirect) {
        try {
            Branch branch = managerAccessService.requireManagedBranch(authentication.getName());
            promotionService.saveForBranch(promotion, branch.getId());
            redirect.addFlashAttribute("successMessage", "Đã lưu chương trình khuyến mãi.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/manager/promotions";
    }

    @PostMapping("/{id}/delete")
    public String delete(Authentication authentication, @PathVariable Long id,
                         RedirectAttributes redirect) {
        try {
            Branch branch = managerAccessService.requireManagedBranch(authentication.getName());
            promotionService.deleteForBranch(id, branch.getId());
            redirect.addFlashAttribute("successMessage", "Đã xóa chương trình khuyến mãi.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/manager/promotions";
    }
}
