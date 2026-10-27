package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.VendorConversation;

import java.util.List;
import java.util.Optional;

@Repository
public interface VendorConversationRepository extends JpaRepository<VendorConversation, Long> {

    Optional<VendorConversation> findByCustomerIdAndVendorId(Long customerId, Long vendorId);

    List<VendorConversation> findByCustomerIdOrderByLastMessageAtDesc(Long customerId);

    List<VendorConversation> findByVendorIdOrderByLastMessageAtDesc(Long vendorId);

    long countByVendorIdAndVendorUnreadTrue(Long vendorId);

    long countByCustomerIdAndCustomerUnreadTrue(Long customerId);
}
