package vn.iotstar.websach.controller.manager;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.SupportConversation;
import vn.iotstar.websach.service.SupportChatService;
import vn.iotstar.websach.util.ExceptionMessages;

@Controller
@RequestMapping("/manager/messages")
@RequiredArgsConstructor
public class ManagerSupportChatController {

    private final SupportChatService supportChatService;

    @GetMapping
    public String inbox(@RequestParam(value = "conversationId", required = false) Long conversationId,
                        Authentication authentication,
                        Model model,
                        RedirectAttributes redirectAttributes) {
        String managerEmail = authentication.getName();
        try {
            if (conversationId != null) {
                SupportConversation selected = supportChatService.openForManager(managerEmail, conversationId);
                model.addAttribute("selectedConversation", selected);
                model.addAttribute("messages", supportChatService.getManagerMessages(managerEmail, conversationId));
            }
            model.addAttribute("conversations", supportChatService.getManagerConversations(managerEmail));
            return "manager/messages/list";
        } catch (RuntimeException ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
            return "redirect:/manager/dashboard";
        }
    }

    @PostMapping("/{id}/reply")
    public String reply(@PathVariable("id") Long conversationId,
                        @RequestParam("content") String content,
                        Authentication authentication,
                        RedirectAttributes redirectAttributes) {
        try {
            supportChatService.replyAsManager(authentication.getName(), conversationId, content);
            redirectAttributes.addFlashAttribute("successMessage", "Đã gửi phản hồi cho khách hàng.");
        } catch (RuntimeException ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
        }
        return "redirect:/manager/messages?conversationId=" + conversationId;
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable("id") Long conversationId,
                         Authentication authentication,
                         RedirectAttributes redirectAttributes) {
        try {
            supportChatService.deleteConversation(authentication.getName(), conversationId);
            redirectAttributes.addFlashAttribute("successMessage", "Đã xóa lịch sử hội thoại với khách hàng.");
        } catch (RuntimeException ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
        }
        return "redirect:/manager/messages";
    }
}
