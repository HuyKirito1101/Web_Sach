package vn.iotstar.websach.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.SupportConversation;
import vn.iotstar.websach.entity.enums.BranchStatus;
import vn.iotstar.websach.service.BranchService;
import vn.iotstar.websach.service.SupportChatService;
import vn.iotstar.websach.service.UserService;

@Controller
@RequiredArgsConstructor
public class SupportChatController {

    private final SupportChatService supportChatService;
    private final BranchService branchService;
    private final UserService userService;

    @GetMapping("/support-chat")
    public String newConversation(Authentication authentication, Model model) {
        model.addAttribute("branches", branchService.findAllBranches().stream()
                .filter(branch -> branch.getStatus() == BranchStatus.ACTIVE)
                .toList());
        if (authentication != null && authentication.isAuthenticated()) {
            userService.findByEmail(authentication.getName()).ifPresent(user -> {
                model.addAttribute("customerName", user.getFullName());
                model.addAttribute("customerPhone", user.getPhone());
            });
        }
        return "customer/support-chat";
    }

    @PostMapping("/support-chat/start")
    public String startConversation(@RequestParam(value = "customerName", required = false) String customerName,
                                    @RequestParam("phone") String phone,
                                    @RequestParam("branchId") Long branchId,
                                    @RequestParam("content") String content,
                                    RedirectAttributes redirectAttributes) {
        try {
            SupportConversation conversation = supportChatService.startConversation(
                    customerName, phone, branchId, content);
            redirectAttributes.addFlashAttribute("successMessage",
                    "Đã gửi tin nhắn đến Manager chi nhánh. Hãy lưu đường dẫn này để xem phản hồi.");
            return "redirect:/support-chat/" + conversation.getPublicToken();
        } catch (RuntimeException ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
            return "redirect:/support-chat";
        }
    }

    @GetMapping("/support-chat/{token}")
    public String conversation(@PathVariable("token") String token,
                               Model model,
                               RedirectAttributes redirectAttributes) {
        try {
            SupportConversation conversation = supportChatService.getCustomerConversation(token);
            model.addAttribute("conversation", conversation);
            model.addAttribute("messages", supportChatService.getCustomerMessages(token));
            return "customer/support-chat";
        } catch (RuntimeException ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
            return "redirect:/support-chat";
        }
    }

    @PostMapping("/support-chat/{token}/send")
    public String sendMessage(@PathVariable("token") String token,
                              @RequestParam("content") String content,
                              RedirectAttributes redirectAttributes) {
        try {
            supportChatService.sendCustomerMessage(token, content);
            redirectAttributes.addFlashAttribute("successMessage", "Đã gửi tin nhắn.");
        } catch (RuntimeException ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/support-chat/" + token;
    }
}
