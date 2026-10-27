package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.VendorMessage;

import java.util.List;

@Repository
public interface VendorMessageRepository extends JpaRepository<VendorMessage, Long> {

    List<VendorMessage> findByConversationIdOrderByCreatedAtAsc(Long conversationId);

    boolean existsByConversationIdAndBookCopyId(Long conversationId, Long bookCopyId);

    void deleteByConversationId(Long conversationId);
}
