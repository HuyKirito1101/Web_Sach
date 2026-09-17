package vn.iotstar.websach.controller.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.iotstar.websach.entity.ShippingProvider;
import vn.iotstar.websach.service.ShippingProviderService;

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
    public String saveShippingProvider(@ModelAttribute("providerForm") ShippingProvider provider) {
        if (provider.getId() == null) {
            shippingProviderService.saveProvider(provider);
        } else {
            shippingProviderService.updateProvider(provider.getId(), provider);
        }
        return "redirect:/admin/shipping?success";
    }

    @GetMapping("/delete/{id}")
    public String deleteShippingProvider(@PathVariable("id") Long id) {
        shippingProviderService.deleteProvider(id);
        return "redirect:/admin/shipping?deleted";
    }
}
