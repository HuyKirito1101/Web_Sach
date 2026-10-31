package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.iotstar.websach.entity.ManagerActivityLog;

import java.util.List;

public interface ManagerActivityLogRepository extends JpaRepository<ManagerActivityLog, Long> {
    List<ManagerActivityLog> findTop100ByOrderByCreatedAtDesc();
}
