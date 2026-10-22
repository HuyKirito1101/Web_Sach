package vn.iotstar.websach.controller.customer;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@Controller
public class PolicyController {

    @GetMapping("/about")
    public String about(Model model) {
        return viewPolicy("about", model);
    }

    @GetMapping("/policies/{type}")
    public String viewPolicy(@PathVariable("type") String type, Model model) {
        String activePolicy = (type != null ? type.toLowerCase() : "terms");
        model.addAttribute("activePolicy", activePolicy);
        return "customer/policy";
    }
}
