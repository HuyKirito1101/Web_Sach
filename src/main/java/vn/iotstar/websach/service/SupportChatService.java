package vn.iotstar.websach.service;

import vn.iotstar.websach.entity.SupportConversation;
import vn.iotstar.websach.entity.SupportMessage;

import java.util.List;

public interface SupportChatService {
    SupportConversation startConversation(String customerName, String phone, Long branchId, String content);
    SupportConversation getCustomerConversation(String publicToken);
    List<SupportMessage> getCustomerMessages(String publicToken);
    void sendCustomerMessage(String publicToken, String content);
    List<SupportConversation> getManagerConversations(String managerEmail);
    SupportConversation openForManager(String managerEmail, Long conversationId);
    List<SupportMessage> getManagerMessages(String managerEmail, Long conversationId);
    void replyAsManager(String managerEmail, Long conversationId, String content);
    void deleteConversation(String managerEmail, Long conversationId);
    long countUnreadForManager(String managerEmail);
}
