package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.SupportConversation;
import vn.iotstar.websach.entity.SupportMessage;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.BranchStatus;
import vn.iotstar.websach.entity.enums.SupportSenderType;
import vn.iotstar.websach.repository.BranchRepository;
import vn.iotstar.websach.repository.SupportConversationRepository;
import vn.iotstar.websach.repository.SupportMessageRepository;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.service.ManagerAccessService;
import vn.iotstar.websach.service.SupportChatService;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SupportChatServiceImpl implements SupportChatService {

    private final SupportConversationRepository conversationRepository;
    private final SupportMessageRepository messageRepository;
    private final BranchRepository branchRepository;
    private final UserRepository userRepository;
    private final ManagerAccessService managerAccessService;
    private final SimpMessagingTemplate messagingTemplate;

    @Override
    @Transactional
    public SupportConversation startConversation(String customerName, String phone, Long branchId, String content) {
        Branch branch = requireActiveBranch(branchId);
        String normalizedPhone = normalizePhone(phone);
        String normalizedName = normalizeName(customerName, normalizedPhone);
        String normalizedContent = normalizeContent(content);

        SupportConversation conversation = conversationRepository.save(SupportConversation.builder()
                .publicToken(UUID.randomUUID().toString())
                .customerName(normalizedName)
                .phone(normalizedPhone)
                .branch(branch)
                .managerUnread(true)
                .lastMessageAt(LocalDateTime.now())
                .build());
        saveMessage(conversation, SupportSenderType.CUSTOMER, normalizedName, normalizedContent);
        notifyManager(conversation);
        return conversation;
    }

    @Override
    @Transactional(readOnly = true)
    public SupportConversation getCustomerConversation(String publicToken) {
        return requireConversationByToken(publicToken);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SupportMessage> getCustomerMessages(String publicToken) {
        SupportConversation conversation = requireConversationByToken(publicToken);
        return messageRepository.findByConversationIdOrderByCreatedAtAsc(conversation.getId());
    }

    @Override
    @Transactional
    public void sendCustomerMessage(String publicToken, String content) {
        SupportConversation conversation = requireConversationByToken(publicToken);
        saveMessage(conversation, SupportSenderType.CUSTOMER, conversation.getCustomerName(), normalizeContent(content));
        conversation.setManagerUnread(true);
        conversation.setLastMessageAt(LocalDateTime.now());
        conversationRepository.save(conversation);
        notifyManager(conversation);
    }

    @Override
    @Transactional(readOnly = true)
    public List<SupportConversation> getManagerConversations(String managerEmail) {
        Long branchId = managerAccessService.requireManagedBranch(managerEmail).getId();
        return conversationRepository.findByBranchIdOrderByLastMessageAtDesc(branchId);
    }

    @Override
    @Transactional
    public SupportConversation openForManager(String managerEmail, Long conversationId) {
        SupportConversation conversation = requireManagerConversation(managerEmail, conversationId);
        if (Boolean.TRUE.equals(conversation.getManagerUnread())) {
            conversation.setManagerUnread(false);
            return conversationRepository.save(conversation);
        }
        return conversation;
    }

    @Override
    @Transactional(readOnly = true)
    public List<SupportMessage> getManagerMessages(String managerEmail, Long conversationId) {
        SupportConversation conversation = requireManagerConversation(managerEmail, conversationId);
        return messageRepository.findByConversationIdOrderByCreatedAtAsc(conversation.getId());
    }

    @Override
    @Transactional
    public void replyAsManager(String managerEmail, Long conversationId, String content) {
        SupportConversation conversation = requireManagerConversation(managerEmail, conversationId);
        User manager = userRepository.findByEmail(managerEmail)
                .orElseThrow(() -> new SecurityException("Không tìm thấy tài khoản Manager."));
        saveMessage(conversation, SupportSenderType.MANAGER, manager.getFullName(), normalizeContent(content));
        conversation.setManagerUnread(false);
        conversation.setLastMessageAt(LocalDateTime.now());
        conversationRepository.save(conversation);
    }

    @Override
    @Transactional
    public void deleteConversation(String managerEmail, Long conversationId) {
        SupportConversation conversation = requireManagerConversation(managerEmail, conversationId);
        messageRepository.deleteByConversationId(conversation.getId());
        conversationRepository.delete(conversation);
    }

    @Override
    @Transactional(readOnly = true)
    public long countUnreadForManager(String managerEmail) {
        Long branchId = managerAccessService.requireManagedBranch(managerEmail).getId();
        return conversationRepository.countByBranchIdAndManagerUnreadTrue(branchId);
    }

    private SupportConversation requireConversationByToken(String token) {
        if (token == null || token.isBlank()) {
            throw new IllegalArgumentException("Mã hội thoại không hợp lệ.");
        }
        return conversationRepository.findByPublicToken(token.trim())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy hội thoại hỗ trợ."));
    }

    private SupportConversation requireManagerConversation(String managerEmail, Long conversationId) {
        Branch branch = managerAccessService.requireManagedBranch(managerEmail);
        SupportConversation conversation = conversationRepository.findById(conversationId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy hội thoại hỗ trợ."));
        if (!Objects.equals(branch.getId(), conversation.getBranch().getId())) {
            throw new SecurityException("Không được xem tin nhắn của chi nhánh khác.");
        }
        return conversation;
    }

    private Branch requireActiveBranch(Long branchId) {
        if (branchId == null) throw new IllegalArgumentException("Vui lòng chọn chi nhánh cần hỗ trợ.");
        Branch branch = branchRepository.findById(branchId)
                .orElseThrow(() -> new IllegalArgumentException("Chi nhánh không tồn tại."));
        if (branch.getStatus() != BranchStatus.ACTIVE) {
            throw new IllegalStateException("Chi nhánh này hiện không nhận yêu cầu hỗ trợ.");
        }
        return branch;
    }

    private void saveMessage(SupportConversation conversation, SupportSenderType senderType,
                             String senderName, String content) {
        messageRepository.save(SupportMessage.builder()
                .conversation(conversation)
                .senderType(senderType)
                .senderName(senderName)
                .content(content)
                .build());
    }

    private String normalizePhone(String phone) {
        if (phone == null || !phone.trim().matches("^(?:0\\d{9}|\\+84\\d{9})$")) {
            throw new IllegalArgumentException("Số điện thoại Việt Nam không hợp lệ.");
        }
        return phone.trim();
    }

    private String normalizeName(String name, String phone) {
        if (name == null || name.isBlank()) return "Khách " + phone.substring(Math.max(0, phone.length() - 4));
        String normalized = name.trim();
        if (normalized.length() > 100) throw new IllegalArgumentException("Tên khách hàng không được quá 100 ký tự.");
        return normalized;
    }

    private String normalizeContent(String content) {
        if (content == null || content.isBlank()) throw new IllegalArgumentException("Nội dung tin nhắn không được để trống.");
        String normalized = content.trim();
        if (normalized.length() > 1000) throw new IllegalArgumentException("Tin nhắn không được quá 1000 ký tự.");
        return normalized;
    }

    private void notifyManager(SupportConversation conversation) {
        try {
            messagingTemplate.convertAndSend("/topic/support/branch/" + conversation.getBranch().getId(),
                    "Tin nhắn mới từ " + conversation.getCustomerName() + " (" + conversation.getPhone() + ")");
        } catch (Exception ignored) {}
    }
}
