package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.iotstar.websach.entity.SupportMessage;

import java.util.List;

public interface SupportMessageRepository extends JpaRepository<SupportMessage, Long> {
    List<SupportMessage> findByConversationIdOrderByCreatedAtAsc(Long conversationId);
    long deleteByConversationId(Long conversationId);
}
