package vn.iotstar.websach.controller.customer;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.iotstar.websach.entity.Address;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.service.CustomerProfileService;
import vn.iotstar.websach.service.UserService;

import java.util.List;

@Controller
@RequestMapping("/profile")
@RequiredArgsConstructor
public class CustomerProfileController {

    private final CustomerProfileService profileService;
    private final UserService userService;

    @GetMapping
    public String profile(Authentication authentication, Model model) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        List<Address> addresses = profileService.getUserAddresses(user);

        model.addAttribute("user", user);
        model.addAttribute("addresses", addresses);

        return "customer/profile";
    }

    @PostMapping("/update")
    public String updateProfile(@RequestParam("fullName") String fullName,
                                @RequestParam(value = "phone", required = false) String phone,
                                @RequestParam(value = "avatarUrl", required = false) String avatarUrl,
                                Authentication authentication) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user != null) {
            profileService.updateProfile(user, fullName, phone, avatarUrl);
        }
        return "redirect:/profile?updated=true";
    }

    @PostMapping("/address/add")
    public String addAddress(@RequestParam("recipientName") String recipientName,
                             @RequestParam("phone") String phone,
                             @RequestParam("street") String street,
                             @RequestParam(value = "ward", required = false) String ward,
                             @RequestParam(value = "district", required = false) String district,
                             @RequestParam("city") String city,
                             @RequestParam(value = "isDefault", defaultValue = "false") Boolean isDefault,
                             Authentication authentication) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user != null) {
            profileService.addAddress(user, recipientName, phone, street, ward, district, city, isDefault);
        }
        return "redirect:/profile";
    }

    @PostMapping("/address/delete")
    public String deleteAddress(@RequestParam("addressId") Long addressId,
                                Authentication authentication) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user != null) {
            profileService.deleteAddress(user, addressId);
        }
        return "redirect:/profile";
    }

    @PostMapping("/address/set-default")
    public String setDefaultAddress(@RequestParam("addressId") Long addressId,
                                   Authentication authentication) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user != null) {
            profileService.setDefaultAddress(user, addressId);
        }
        return "redirect:/profile";
    }
}
