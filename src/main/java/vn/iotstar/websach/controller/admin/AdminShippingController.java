package vn.iotstar.websach.controller.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.ShippingProvider;
import vn.iotstar.websach.service.ShippingProviderService;
import vn.iotstar.websach.util.ExceptionMessages;

@Controller
@RequestMapping("/admin/shipping")
@RequiredArgsConstructor
public class AdminShippingController {

    private final ShippingProviderService shippingProviderService;

    @GetMapping
    public String listShippingProviders(Model model) {
        model.addAttribute("providers", shippingProviderService.findAllProviders());
        model.addAttribute("providerForm", new ShippingProvider());
        return "admin/shipping/list";
    }

    @PostMapping("/save")
    public String saveShippingProvider(@ModelAttribute("providerForm") ShippingProvider provider,
                                       RedirectAttributes redirect) {
        try {
            if (provider.getId() == null) shippingProviderService.saveProvider(provider);
            else shippingProviderService.updateProvider(provider.getId(), provider);
            redirect.addFlashAttribute("successMessage", "Đã lưu nhà vận chuyển.");
        } catch (RuntimeException ex) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
        }
        return "redirect:/admin/shipping";
    }

    @PostMapping("/delete/{id}")
    public String deleteShippingProvider(@PathVariable("id") Long id, RedirectAttributes redirect) {
        try {
            shippingProviderService.deleteProvider(id);
            redirect.addFlashAttribute("successMessage", "Đã chuyển nhà vận chuyển sang trạng thái tạm dừng.");
        } catch (RuntimeException ex) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
        }
        return "redirect:/admin/shipping";
    }
}
