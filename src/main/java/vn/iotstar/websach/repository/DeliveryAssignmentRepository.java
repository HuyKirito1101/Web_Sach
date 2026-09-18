package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.DeliveryAssignment;
import vn.iotstar.websach.entity.enums.DeliveryStatus;

import java.util.List;
import java.util.Optional;

@Repository
public interface DeliveryAssignmentRepository extends JpaRepository<DeliveryAssignment, Long> {
    Optional<DeliveryAssignment> findByOrderId(Long orderId);
    List<DeliveryAssignment> findByShipperId(Long shipperId);
    List<DeliveryAssignment> findByShipperIdOrderByAssignedAtDesc(Long shipperId);
    List<DeliveryAssignment> findByShipperIdAndStatus(Long shipperId, DeliveryStatus status);
}
