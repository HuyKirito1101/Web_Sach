package vn.iotstar.websach.service;

import vn.iotstar.websach.dto.VendorChatMessageDTO;
import vn.iotstar.websach.entity.VendorConversation;
import vn.iotstar.websach.entity.VendorMessage;

import java.util.List;

public interface VendorChatService {

    VendorConversation getOrCreateConversation(String customerEmail, Long vendorId, Long bookCopyId);

    VendorConversation getConversation(Long conversationId, String userEmail);

    List<VendorConversation> getCustomerConversations(String customerEmail);

    List<VendorConversation> getVendorConversations(String vendorEmail);

    List<VendorMessage> getMessages(Long conversationId, String userEmail);

    VendorMessage sendMessage(Long conversationId, String senderEmail, String content, Long bookCopyId);

    long countUnreadForVendor(String vendorEmail);

    long countUnreadForCustomer(String customerEmail);

    VendorChatMessageDTO toDTO(VendorMessage message, String currentUsername);

    void deleteConversation(Long conversationId, String userEmail);

    void deleteMessage(Long messageId, String userEmail);
}
