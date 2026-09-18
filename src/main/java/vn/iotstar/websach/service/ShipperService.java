package vn.iotstar.websach.service;

import vn.iotstar.websach.dto.ShipperDashboardDTO;
import vn.iotstar.websach.entity.DeliveryAssignment;
import vn.iotstar.websach.entity.enums.DeliveryStatus;

import java.time.LocalDate;
import java.util.List;

public interface ShipperService {
    List<DeliveryAssignment> getAssignments(String shipperEmail, DeliveryStatus status,
                                            LocalDate from, LocalDate to);
    DeliveryAssignment getAssignment(String shipperEmail, Long assignmentId);
    DeliveryAssignment updateStatus(String shipperEmail, Long assignmentId,
                                    DeliveryStatus target, String failureReason);
    ShipperDashboardDTO getDashboard(String shipperEmail, LocalDate from, LocalDate to);
}
