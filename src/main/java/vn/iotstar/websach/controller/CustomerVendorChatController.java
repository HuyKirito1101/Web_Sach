package vn.iotstar.websach.controller;

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

@Controller
@RequiredArgsConstructor
@Slf4j
public class CustomerVendorChatController {

    private final VendorChatService vendorChatService;

    @GetMapping("/messages")
    public String messagesDispatcher(Authentication authentication) {
        if (authentication != null && authentication.getAuthorities().stream()
                .anyMatch(a -> "ROLE_VENDOR".equals(a.getAuthority()))) {
            return "redirect:/vendor/messages";
        }
        return "redirect:/chat/vendor";
    }

    @GetMapping("/chat/vendor")
    public String chatWithVendor(@RequestParam(value = "bookCopyId", required = false) Long bookCopyId,
                                 @RequestParam(value = "vendorId", required = false) Long vendorId,
                                 @RequestParam(value = "conversationId", required = false) Long conversationId,
                                 Authentication authentication,
                                 Model model,
                                 RedirectAttributes redirectAttributes) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/auth/login";
        }
        String currentEmail = authentication.getName();

        try {
            VendorConversation selectedConversation = null;

            // 1. Trường hợp bấm "Chat với Shop" từ sản phẩm sách cụ thể
            if (bookCopyId != null) {
                selectedConversation = vendorChatService.getOrCreateConversationForBook(currentEmail, bookCopyId);
            } else if (vendorId != null) {
                // 2. Nhắn tin cho vendor theo vendorId
                selectedConversation = vendorChatService.getOrCreateConversation(currentEmail, vendorId, null);
            } else if (conversationId != null) {
                // 3. Mở hội thoại theo id
                selectedConversation = vendorChatService.getConversation(conversationId, currentEmail);
            }

            List<VendorConversation> conversations = vendorChatService.getCustomerConversations(currentEmail);

            if (selectedConversation == null && !conversations.isEmpty()) {
                selectedConversation = conversations.get(0);
            }

            if (selectedConversation != null) {
                List<VendorMessage> messages = vendorChatService.getMessages(selectedConversation.getId(), currentEmail);
                model.addAttribute("selectedConversation", selectedConversation);
                model.addAttribute("messages", messages);
                model.addAttribute("currentBookCopy", selectedConversation.getBookCopy());
            }

            model.addAttribute("conversations", conversations);
            return "customer/vendor-chat";
        } catch (IllegalArgumentException ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
            return "redirect:/books";
        } catch (Exception ex) {
            log.error("Lỗi khi mở giao diện chat với vendor", ex);
            redirectAttributes.addFlashAttribute("errorMessage", "Đã xảy ra lỗi khi mở tin nhắn: " + ex.getMessage());
            return "redirect:/books";
        }
    }

    @PostMapping("/chat/vendor/send")
    public String sendMessage(@RequestParam("conversationId") Long conversationId,
                              @RequestParam("content") String content,
                              @RequestParam(value = "bookCopyId", required = false) Long bookCopyId,
                              Authentication authentication,
                              RedirectAttributes redirectAttributes) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return "redirect:/auth/login";
        }
        try {
            vendorChatService.sendMessage(conversationId, authentication.getName(), content, bookCopyId);
        } catch (Exception ex) {
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/chat/vendor?conversationId=" + conversationId;
    }

    @PostMapping(value = "/chat/vendor/api/send", produces = "application/json")
    @ResponseBody
    public ResponseEntity<?> sendMessageApi(@RequestParam("conversationId") Long conversationId,
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
            return ResponseEntity.badRequest().body(ex.getMessage());
        }
    }

    @GetMapping(value = "/chat/vendor/api/messages/{conversationId}", produces = "application/json")
    @ResponseBody
    public ResponseEntity<List<VendorChatMessageDTO>> getMessagesApi(@PathVariable("conversationId") Long conversationId,
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
            return ResponseEntity.ok(Collections.emptyList());
        }
    }

    @PostMapping("/chat/vendor/{id}/delete")
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
            redirectAttributes.addFlashAttribute("errorMessage", ex.getMessage());
        }
        return "redirect:/chat/vendor";
    }

    @PostMapping(value = "/chat/vendor/api/conversation/{id}/delete", produces = "application/json")
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
            return ResponseEntity.badRequest().body(Map.of("error", ex.getMessage()));
        }
    }

    @PostMapping(value = "/chat/vendor/api/message/{messageId}/delete", produces = "application/json")
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
            return ResponseEntity.badRequest().body(Map.of("error", ex.getMessage()));
        }
    }
}
