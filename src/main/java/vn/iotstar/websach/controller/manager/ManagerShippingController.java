package vn.iotstar.websach.controller.manager;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.ShippingProvider;
import vn.iotstar.websach.service.ShippingProviderService;

@Controller
@RequestMapping("/manager/shipping")
@RequiredArgsConstructor
public class ManagerShippingController {

    private final ShippingProviderService shippingProviderService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("providers", shippingProviderService.findAllProviders());
        model.addAttribute("providerForm", new ShippingProvider());
        return "manager/shipping/list";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute ShippingProvider provider, RedirectAttributes redirect) {
        try {
            validate(provider);
            if (provider.getId() == null) shippingProviderService.saveProvider(provider);
            else shippingProviderService.updateProvider(provider.getId(), provider);
            redirect.addFlashAttribute("successMessage", "Đã lưu nhà vận chuyển.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/manager/shipping";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id, RedirectAttributes redirect) {
        try {
            shippingProviderService.deleteProvider(id);
            redirect.addFlashAttribute("successMessage", "Đã xóa nhà vận chuyển.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", "Nhà vận chuyển đang được sử dụng, hãy tạm dừng thay vì xóa.");
        }
        return "redirect:/manager/shipping";
    }

    private void validate(ShippingProvider provider) {
        if (provider.getName() == null || provider.getName().isBlank()) {
            throw new IllegalArgumentException("Tên nhà vận chuyển không được để trống.");
        }
        if (provider.getBaseFee() == null || provider.getBaseFee() < 0) {
            throw new IllegalArgumentException("Phí vận chuyển không được âm.");
        }
    }
}
