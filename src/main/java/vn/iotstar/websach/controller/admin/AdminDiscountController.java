package vn.iotstar.websach.controller.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.AppDiscount;
import vn.iotstar.websach.service.AppDiscountService;

@Controller
@RequestMapping("/admin/discounts")
@RequiredArgsConstructor
public class AdminDiscountController {

    private final AppDiscountService appDiscountService;

    @GetMapping
    public String listDiscounts(Model model) {
        model.addAttribute("discounts", appDiscountService.findAllDiscounts());
        model.addAttribute("discountForm", new AppDiscount());
        return "admin/discounts/list";
    }

    @PostMapping("/save")
    public String saveDiscount(@ModelAttribute("discountForm") AppDiscount discount,
                               RedirectAttributes redirect) {
        try {
            if (discount.getId() == null) appDiscountService.saveDiscount(discount);
            else appDiscountService.updateDiscount(discount.getId(), discount);
            redirect.addFlashAttribute("successMessage", "Đã lưu voucher.");
        } catch (RuntimeException ex) {
            redirect.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/admin/discounts";
    }

    @PostMapping("/delete/{id}")
    public String deleteDiscount(@PathVariable("id") Long id, RedirectAttributes redirect) {
        try {
            appDiscountService.deleteDiscount(id);
            redirect.addFlashAttribute("successMessage", "Đã ngừng áp dụng voucher.");
        } catch (RuntimeException ex) {
            redirect.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/admin/discounts";
    }
}
