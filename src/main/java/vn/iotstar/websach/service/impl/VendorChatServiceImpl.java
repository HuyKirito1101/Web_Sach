package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.dto.VendorChatMessageDTO;
import vn.iotstar.websach.entity.BookCopy;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.VendorConversation;
import vn.iotstar.websach.entity.VendorMessage;
import vn.iotstar.websach.repository.BookCopyRepository;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.repository.VendorConversationRepository;
import vn.iotstar.websach.repository.VendorMessageRepository;
import vn.iotstar.websach.service.VendorChatService;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Slf4j
public class VendorChatServiceImpl implements VendorChatService {

    private final VendorConversationRepository conversationRepository;
    private final VendorMessageRepository messageRepository;
    private final UserRepository userRepository;
    private final BookCopyRepository bookCopyRepository;
    private final SimpMessagingTemplate messagingTemplate;

    @Override
    @Transactional
    public VendorConversation getOrCreateConversation(String customerEmail, Long vendorId, Long bookCopyId) {
        User customer = userRepository.findByEmail(customerEmail)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy thông tin tài khoản người mua."));
        User vendor = userRepository.findById(vendorId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy người bán."));

        if (Objects.equals(customer.getId(), vendor.getId())) {
            throw new IllegalArgumentException("Bạn không thể tự nhắn tin cho chính mình.");
        }

        BookCopy bookCopy = null;
        if (bookCopyId != null) {
            bookCopy = bookCopyRepository.findById(bookCopyId).orElse(null);
        }

        VendorConversation conversation = conversationRepository
                .findByCustomerIdAndVendorId(customer.getId(), vendor.getId())
                .orElse(null);

        if (conversation != null) {
            if (bookCopy != null && (conversation.getBookCopy() == null || !Objects.equals(conversation.getBookCopy().getId(), bookCopy.getId()))) {
                conversation.setBookCopy(bookCopy);
                conversation = conversationRepository.save(conversation);
            }
            return conversation;
        }

        VendorConversation newConv = VendorConversation.builder()
                .customer(customer)
                .vendor(vendor)
                .bookCopy(bookCopy)
                .customerUnread(false)
                .vendorUnread(false)
                .lastMessage(bookCopy != null ? "Khách hàng bắt đầu quan tâm sản phẩm: " + bookCopy.getBook().getTitle() : null)
                .lastMessageAt(LocalDateTime.now())
                .build();

        return conversationRepository.save(newConv);
    }

    @Override
    @Transactional(readOnly = true)
    public VendorConversation getConversation(Long conversationId, String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new SecurityException("Người dùng chưa xác thực."));
        VendorConversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy cuộc hội thoại."));

        if (!Objects.equals(user.getId(), conversation.getCustomer().getId())
                && !Objects.equals(user.getId(), conversation.getVendor().getId())) {
            throw new SecurityException("Bạn không có quyền truy cập cuộc trò chuyện này.");
        }
        return conversation;
    }

    @Override
    @Transactional(readOnly = true)
    public List<VendorConversation> getCustomerConversations(String customerEmail) {
        User customer = userRepository.findByEmail(customerEmail)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản người mua."));
        return conversationRepository.findByCustomerIdOrderByLastMessageAtDesc(customer.getId());
    }

    @Override
    @Transactional(readOnly = true)
    public List<VendorConversation> getVendorConversations(String vendorEmail) {
        User vendor = userRepository.findByEmail(vendorEmail)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản vendor."));
        return conversationRepository.findByVendorIdOrderByLastMessageAtDesc(vendor.getId());
    }

    @Override
    @Transactional
    public List<VendorMessage> getMessages(Long conversationId, String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new SecurityException("Người dùng chưa xác thực."));
        VendorConversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy cuộc hội thoại."));

        boolean isCustomer = Objects.equals(user.getId(), conversation.getCustomer().getId());
        boolean isVendor = Objects.equals(user.getId(), conversation.getVendor().getId());

        if (!isCustomer && !isVendor) {
            throw new SecurityException("Bạn không có quyền xem tin nhắn của cuộc trò chuyện này.");
        }

        if (isCustomer && Boolean.TRUE.equals(conversation.getCustomerUnread())) {
            conversation.setCustomerUnread(false);
            conversationRepository.save(conversation);
        } else if (isVendor && Boolean.TRUE.equals(conversation.getVendorUnread())) {
            conversation.setVendorUnread(false);
            conversationRepository.save(conversation);
        }

        return messageRepository.findByConversationIdOrderByCreatedAtAsc(conversationId);
    }

    @Override
    @Transactional
    public VendorMessage sendMessage(Long conversationId, String senderEmail, String content, Long bookCopyId) {
        User sender = userRepository.findByEmail(senderEmail)
                .orElseThrow(() -> new SecurityException("Người dùng chưa xác thực."));
        VendorConversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy cuộc hội thoại."));

        boolean isCustomer = Objects.equals(sender.getId(), conversation.getCustomer().getId());
        boolean isVendor = Objects.equals(sender.getId(), conversation.getVendor().getId());

        if (!isCustomer && !isVendor) {
            throw new SecurityException("Bạn không có quyền gửi tin nhắn trong cuộc trò chuyện này.");
        }

        String normalizedContent = normalizeContent(content);

        // Đính kèm sản phẩm nếu khách hàng hỏi về một sản phẩm và đây là tin nhắn đầu tiên về sản phẩm đó
        BookCopy attachedCopy = null;
        if (isCustomer && bookCopyId != null) {
            boolean alreadyAttached = messageRepository.existsByConversationIdAndBookCopyId(conversationId, bookCopyId);
            if (!alreadyAttached) {
                attachedCopy = bookCopyRepository.findById(bookCopyId).orElse(null);
                if (attachedCopy != null) {
                    conversation.setBookCopy(attachedCopy);
                }
            }
        }

        VendorMessage message = VendorMessage.builder()
                .conversation(conversation)
                .sender(sender)
                .content(normalizedContent)
                .bookCopy(attachedCopy)
                .isRead(false)
                .build();
        VendorMessage savedMessage = messageRepository.save(message);

        conversation.setLastMessage(normalizedContent);
        conversation.setLastMessageAt(LocalDateTime.now());
        if (isCustomer) {
            conversation.setVendorUnread(true);
            conversation.setCustomerUnread(false);
        } else {
            conversation.setCustomerUnread(true);
            conversation.setVendorUnread(false);
        }
        conversationRepository.save(conversation);

        // Phát thông báo qua WebSocket
        try {
            VendorChatMessageDTO dto = toDTO(savedMessage, null);
            messagingTemplate.convertAndSend("/topic/vendor-chat/" + conversationId, dto);
            if (isCustomer) {
                messagingTemplate.convertAndSend("/topic/vendor/" + conversation.getVendor().getId() + "/notifications",
                        "Tin nhắn mới từ " + conversation.getCustomer().getFullName());
            }
        } catch (Exception e) {
            log.warn("Không thể gửi thông báo WebSocket: {}", e.getMessage());
        }

        return savedMessage;
    }

    @Override
    @Transactional(readOnly = true)
    public long countUnreadForVendor(String vendorEmail) {
        return userRepository.findByEmail(vendorEmail)
                .map(v -> conversationRepository.countByVendorIdAndVendorUnreadTrue(v.getId()))
                .orElse(0L);
    }

    @Override
    @Transactional(readOnly = true)
    public long countUnreadForCustomer(String customerEmail) {
        return userRepository.findByEmail(customerEmail)
                .map(c -> conversationRepository.countByCustomerIdAndCustomerUnreadTrue(c.getId()))
                .orElse(0L);
    }

    @Override
    public VendorChatMessageDTO toDTO(VendorMessage message, String currentUsername) {
        boolean isMe = currentUsername != null && message.getSender() != null
                && currentUsername.equalsIgnoreCase(message.getSender().getEmail());

        BookCopy copy = message.getBookCopy();
        Long copyId = null;
        Long bookId = null;
        String title = null;
        String cover = null;
        Double price = null;
        String condition = null;

        if (copy != null) {
            copyId = copy.getId();
            if (copy.getBook() != null) {
                bookId = copy.getBook().getId();
                title = copy.getBook().getTitle();
                cover = copy.getBook().getCoverUrl();
            }
            price = copy.getSellingPrice();
            condition = copy.getConditionRating() != null ? copy.getConditionRating().name() : null;
        }

        return VendorChatMessageDTO.builder()
                .id(message.getId())
                .conversationId(message.getConversation().getId())
                .senderId(message.getSender().getId())
                .senderName(message.getSender().getFullName())
                .senderRole(message.getSender().getRole() != null && message.getSender().getRole().getName() != null
                        ? message.getSender().getRole().getName().name() : "")
                .content(message.getContent())
                .formattedCreatedAt(message.getFormattedCreatedAt())
                .isMe(isMe)
                .bookCopyId(copyId)
                .bookId(bookId)
                .bookTitle(title)
                .bookCoverUrl(cover)
                .bookPrice(price)
                .conditionRating(condition)
                .build();
    }

    @Override
    @Transactional
    public void deleteConversation(Long conversationId, String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new SecurityException("Người dùng chưa xác thực."));
        VendorConversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy cuộc hội thoại."));

        boolean isCustomer = Objects.equals(user.getId(), conversation.getCustomer().getId());
        boolean isVendor = Objects.equals(user.getId(), conversation.getVendor().getId());

        if (!isCustomer && !isVendor) {
            throw new SecurityException("Bạn không có quyền xóa cuộc trò chuyện này.");
        }

        // Xóa toàn bộ tin nhắn trong cuộc trò chuyện
        List<VendorMessage> messages = messageRepository.findByConversationIdOrderByCreatedAtAsc(conversationId);
        messageRepository.deleteAll(messages);

        // Xóa cuộc trò chuyện
        conversationRepository.delete(conversation);

        // Báo cho các bên qua WebSocket
        try {
            messagingTemplate.convertAndSend("/topic/vendor-chat/" + conversationId,
                    Map.of("action", "DELETE_CONVERSATION", "conversationId", conversationId));
        } catch (Exception e) {
            log.warn("Không thể gửi thông báo xóa hội thoại qua WebSocket: {}", e.getMessage());
        }
    }

    @Override
    @Transactional
    public void deleteMessage(Long messageId, String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new SecurityException("Người dùng chưa xác thực."));
        VendorMessage message = messageRepository.findById(messageId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tin nhắn cần xóa."));

        boolean isSender = Objects.equals(user.getId(), message.getSender().getId());
        boolean isVendor = Objects.equals(user.getId(), message.getConversation().getVendor().getId());

        if (!isSender && !isVendor) {
            throw new SecurityException("Bạn chỉ có thể xóa tin nhắn do mình gửi.");
        }

        VendorConversation conversation = message.getConversation();
        Long convId = conversation.getId();

        messageRepository.delete(message);

        // Cập nhật lại lastMessage của conversation nếu tin nhắn vừa xóa là tin nhắn mới nhất
        List<VendorMessage> remainingMessages = messageRepository.findByConversationIdOrderByCreatedAtAsc(convId);
        if (remainingMessages.isEmpty()) {
            conversation.setLastMessage(null);
            conversation.setCustomerUnread(false);
            conversation.setVendorUnread(false);
        } else {
            VendorMessage last = remainingMessages.get(remainingMessages.size() - 1);
            conversation.setLastMessage(last.getContent());
            conversation.setLastMessageAt(last.getCreatedAt());
        }
        conversationRepository.save(conversation);

        // Báo qua WebSocket để các bên xóa tin nhắn trên giao diện
        try {
            messagingTemplate.convertAndSend("/topic/vendor-chat/" + convId,
                    Map.of("action", "DELETE_MESSAGE", "messageId", messageId));
        } catch (Exception e) {
            log.warn("Không thể gửi thông báo xóa tin nhắn qua WebSocket: {}", e.getMessage());
        }
    }

    private String normalizeContent(String content) {
        if (content == null || content.isBlank()) {
            throw new IllegalArgumentException("Nội dung tin nhắn không được để trống.");
        }
        String trimmed = content.trim();
        if (trimmed.length() > 2000) {
            throw new IllegalArgumentException("Tin nhắn không được vượt quá 2000 ký tự.");
        }
        return trimmed;
    }
}
