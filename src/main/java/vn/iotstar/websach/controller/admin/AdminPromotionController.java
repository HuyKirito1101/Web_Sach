package vn.iotstar.websach.controller.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.Promotion;
import vn.iotstar.websach.entity.enums.PromotionType;
import vn.iotstar.websach.service.BranchService;
import vn.iotstar.websach.service.PromotionService;
import vn.iotstar.websach.util.ExceptionMessages;

@Controller
@RequestMapping("/admin/promotions")
@RequiredArgsConstructor
public class AdminPromotionController {

    private final PromotionService promotionService;
    private final BranchService branchService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("promotions", promotionService.findAllPromotions());
        model.addAttribute("branches", branchService.findAllBranches());
        model.addAttribute("types", PromotionType.values());
        model.addAttribute("promotionForm", new Promotion());
        return "admin/promotions/list";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute Promotion promotion,
                       @RequestParam(required = false) Long branchId,
                       RedirectAttributes redirect) {
        try {
            promotionService.saveForAdmin(promotion, branchId);
            redirect.addFlashAttribute("successMessage", "Đã lưu chương trình khuyến mãi.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/admin/promotions";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id, RedirectAttributes redirect) {
        try {
            promotionService.deleteForAdmin(id);
            redirect.addFlashAttribute("successMessage", "Đã xóa chương trình khuyến mãi.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", "Không thể xóa chương trình này.");
        }
        return "redirect:/admin/promotions";
    }
}
