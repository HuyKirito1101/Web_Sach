package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.DeliveryAssignment;
import vn.iotstar.websach.entity.enums.DeliveryStatus;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
public interface DeliveryAssignmentRepository extends JpaRepository<DeliveryAssignment, Long> {
    Optional<DeliveryAssignment> findByOrderId(Long orderId);
    Optional<DeliveryAssignment> findFirstByOrderIdOrderByIdDesc(Long orderId);
    Optional<DeliveryAssignment> findBySellRequestId(Long sellRequestId);
    List<DeliveryAssignment> findBySellRequestIdAndShipperIdNot(Long sellRequestId, Long shipperId);
    List<DeliveryAssignment> findByShipperId(Long shipperId);
    List<DeliveryAssignment> findByShipperIdOrderByAssignedAtDesc(Long shipperId);
    List<DeliveryAssignment> findByShipperIdAndStatus(Long shipperId, DeliveryStatus status);
    boolean existsByOrderIdAndShipperId(Long orderId, Long shipperId);
    List<DeliveryAssignment> findByOrderIdAndShipperIdNot(Long orderId, Long shipperId);

    long countByShipperIdAndStatus(Long shipperId, DeliveryStatus status);
    long countByShipperIdAndStatusIn(Long shipperId, Collection<DeliveryStatus> statuses);

    boolean existsByShipperIdAndStatusIn(Long shipperId, Collection<DeliveryStatus> statuses);
    Optional<DeliveryAssignment> findFirstByShipperIdAndStatusIn(Long shipperId, Collection<DeliveryStatus> statuses);
}
