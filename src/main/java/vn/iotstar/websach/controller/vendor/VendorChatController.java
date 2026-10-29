package vn.iotstar.websach.controller.vendor;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.dto.VendorChatMessageDTO;
import vn.iotstar.websach.entity.VendorConversation;
import vn.iotstar.websach.entity.VendorMessage;
import vn.iotstar.websach.service.VendorChatService;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import vn.iotstar.websach.util.ExceptionMessages;

@Controller
@RequestMapping("/vendor/messages")
@RequiredArgsConstructor
@Slf4j
public class VendorChatController {

    private final VendorChatService vendorChatService;

    @GetMapping
    public String inbox(@RequestParam(value = "conversationId", required = false) Long conversationId,
                        Authentication authentication,
                        Model model,
                        RedirectAttributes redirectAttributes) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/auth/login";
        }
        String vendorEmail = authentication.getName();

        try {
            List<VendorConversation> conversations = vendorChatService.getVendorConversations(vendorEmail);
            VendorConversation selected = null;

            if (conversationId != null) {
                selected = vendorChatService.getConversation(conversationId, vendorEmail);
            } else if (!conversations.isEmpty()) {
                selected = conversations.get(0);
            }

            if (selected != null) {
                List<VendorMessage> messages = vendorChatService.getMessages(selected.getId(), vendorEmail);
                model.addAttribute("selectedConversation", selected);
                model.addAttribute("messages", messages);
                model.addAttribute("currentBookCopy", selected.getBookCopy());
            }

            model.addAttribute("conversations", conversations);
            return "vendor/messages/list";
        } catch (Exception ex) {
            log.error("Lỗi khi tải hộp thư tin nhắn vendor", ex);
            redirectAttributes.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
            return "redirect:/vendor/dashboard";
        }
    }

    @PostMapping("/{id}/reply")
    public String reply(@PathVariable("id") Long conversationId,
                        @RequestParam("content") String content,
                        @RequestParam(value = "bookCopyId", required = false) Long bookCopyId,
                        Authentication authentication,
                        RedirectAttributes redirectAttributes) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/auth/login";
        }
        try {
            vendorChatService.sendMessage(conversationId, authentication.getName(), content, bookCopyId);
            redirectAttributes.addFlashAttribute("successMessage", "Đã gửi phản hồi thành công.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
        }
        return "redirect:/vendor/messages?conversationId=" + conversationId;
    }

    @PostMapping("/{id}/delete")
    public String deleteConversation(@PathVariable("id") Long conversationId,
                                     Authentication authentication,
                                     RedirectAttributes redirectAttributes) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/auth/login";
        }
        try {
            vendorChatService.deleteConversation(conversationId, authentication.getName());
            redirectAttributes.addFlashAttribute("successMessage", "Đã xóa lịch sử cuộc trò chuyện thành công.");
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
        }
        return "redirect:/vendor/messages";
    }

    @PostMapping(value = "/api/conversation/{id}/delete", produces = "application/json")
    @ResponseBody
    public ResponseEntity<?> deleteConversationApi(@PathVariable("id") Long conversationId,
                                                   Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).body(Map.of("error", "Chưa đăng nhập"));
        }
        try {
            vendorChatService.deleteConversation(conversationId, authentication.getName());
            return ResponseEntity.ok(Map.of("success", true, "conversationId", conversationId));
        } catch (Exception ex) {
            return ResponseEntity.status(ExceptionMessages.httpStatus(ex))
                    .body(Map.of("error", ExceptionMessages.userMessage(ex)));
        }
    }

    @PostMapping(value = "/api/send", produces = "application/json")
    @ResponseBody
    public ResponseEntity<?> sendApi(@RequestParam("conversationId") Long conversationId,
                                     @RequestParam("content") String content,
                                     @RequestParam(value = "bookCopyId", required = false) Long bookCopyId,
                                     Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).body("Chưa đăng nhập");
        }
        try {
            VendorMessage msg = vendorChatService.sendMessage(conversationId, authentication.getName(), content, bookCopyId);
            return ResponseEntity.ok(vendorChatService.toDTO(msg, authentication.getName()));
        } catch (Exception ex) {
            return ResponseEntity.status(ExceptionMessages.httpStatus(ex)).body(ExceptionMessages.userMessage(ex));
        }
    }

    @PostMapping(value = "/api/message/{messageId}/delete", produces = "application/json")
    @ResponseBody
    public ResponseEntity<?> deleteMessageApi(@PathVariable("messageId") Long messageId,
                                              Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).body(Map.of("error", "Chưa đăng nhập"));
        }
        try {
            vendorChatService.deleteMessage(messageId, authentication.getName());
            return ResponseEntity.ok(Map.of("success", true, "messageId", messageId));
        } catch (Exception ex) {
            return ResponseEntity.status(ExceptionMessages.httpStatus(ex))
                    .body(Map.of("error", ExceptionMessages.userMessage(ex)));
        }
    }

    @GetMapping(value = "/api/messages/{conversationId}", produces = "application/json")
    @ResponseBody
    public ResponseEntity<?> getMessagesApi(@PathVariable("conversationId") Long conversationId,
                                            Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).build();
        }
        try {
            List<VendorMessage> messages = vendorChatService.getMessages(conversationId, authentication.getName());
            List<VendorChatMessageDTO> dtos = messages.stream()
                    .map(m -> vendorChatService.toDTO(m, authentication.getName()))
                    .toList();
            return ResponseEntity.ok(dtos);
        } catch (Exception ex) {
            if (ExceptionMessages.isDatabaseFailure(ex)) {
                return ResponseEntity.status(ExceptionMessages.httpStatus(ex))
                        .body(Map.of("error", ExceptionMessages.userMessage(ex)));
            }
            return ResponseEntity.ok(Collections.emptyList());
        }
    }
}
