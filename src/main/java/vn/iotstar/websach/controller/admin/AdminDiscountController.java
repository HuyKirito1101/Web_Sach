package vn.iotstar.websach.controller.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
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
    public String saveDiscount(@ModelAttribute("discountForm") AppDiscount discount) {
        if (discount.getId() == null) {
            appDiscountService.saveDiscount(discount);
        } else {
            appDiscountService.updateDiscount(discount.getId(), discount);
        }
        return "redirect:/admin/discounts?success";
    }

    @GetMapping("/delete/{id}")
    public String deleteDiscount(@PathVariable("id") Long id) {
        appDiscountService.deleteDiscount(id);
        return "redirect:/admin/discounts?deleted";
    }
}
