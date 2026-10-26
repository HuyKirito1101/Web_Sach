package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.iotstar.websach.entity.SupportConversation;

import java.util.List;
import java.util.Optional;

public interface SupportConversationRepository extends JpaRepository<SupportConversation, Long> {
    Optional<SupportConversation> findByPublicToken(String publicToken);
    List<SupportConversation> findByBranchIdOrderByLastMessageAtDesc(Long branchId);
    long countByBranchIdAndManagerUnreadTrue(Long branchId);
}
