package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.dto.ShipperDashboardDTO;
import vn.iotstar.websach.dto.ShipperIncomeAnalyticsDTO;
import vn.iotstar.websach.entity.DeliveryAssignment;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.SellRequest;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.*;
import vn.iotstar.websach.repository.DeliveryAssignmentRepository;
import vn.iotstar.websach.repository.OrderRepository;
import vn.iotstar.websach.repository.SellRequestRepository;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.service.OrderService;
import vn.iotstar.websach.service.ShipperService;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ShipperServiceImpl implements ShipperService {
    private final UserRepository userRepository;
    private final DeliveryAssignmentRepository assignmentRepository;
    private final OrderRepository orderRepository;
    private final SellRequestRepository sellRequestRepository;
    private final SimpMessagingTemplate messagingTemplate;
    
    @Autowired
    @Lazy
    private OrderService orderService;

    private User requireShipper(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản Shipper"));
        if (user.getRole() == null || user.getRole().getName() != RoleName.ROLE_SHIPPER) {
            throw new SecurityException("Tài khoản không có quyền Shipper");
        }
        return user;
    }

    @Override
    @Transactional
    public List<DeliveryAssignment> getAssignments(String email, DeliveryStatus status, LocalDate from, LocalDate to) {
        User shipper = requireShipper(email);
        return assignmentRepository.findByShipperIdOrderByAssignedAtDesc(shipper.getId()).stream()
                .filter(a -> status == null || a.getStatus() == status)
                .filter(a -> from == null || (a.getAssignedAt() != null && !a.getAssignedAt().toLocalDate().isBefore(from)))
                .filter(a -> to == null || (a.getAssignedAt() != null && !a.getAssignedAt().toLocalDate().isAfter(to)))
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public DeliveryAssignment getAssignment(String email, Long assignmentId) {
        User shipper = requireShipper(email);
        DeliveryAssignment assignment = assignmentRepository.findById(assignmentId)
                .orElseThrow(() -> new IllegalArgumentException("Đơn giao không tồn tại"));
        if (assignment.getShipper() == null || !Objects.equals(assignment.getShipper().getId(), shipper.getId())) {
            throw new SecurityException("Không được truy cập đơn giao của shipper khác");
        }
        if (assignment.getSellRequest() != null && assignment.getSellRequest().getItems() != null) {
            assignment.getSellRequest().getItems().size();
        }
        return assignment;
    }

    @Override
    @Transactional
    public DeliveryAssignment updateStatus(String email, Long assignmentId, DeliveryStatus target, String failureReason) {
        User shipper = requireShipper(email);
        DeliveryAssignment assignment = getAssignment(email, assignmentId);
        DeliveryStatus current = assignment.getStatus();
        boolean allowed = (current == DeliveryStatus.ASSIGNED && (target == DeliveryStatus.ACCEPTED || target == DeliveryStatus.PICKED_UP || target == DeliveryStatus.CANCELLED))
                || (current == DeliveryStatus.ACCEPTED && (target == DeliveryStatus.PICKED_UP || target == DeliveryStatus.CANCELLED))
                || (current == DeliveryStatus.PICKED_UP && (target == DeliveryStatus.SHIPPING || target == DeliveryStatus.FAILED))
                || (current == DeliveryStatus.SHIPPING && (target == DeliveryStatus.DELIVERED || target == DeliveryStatus.FAILED));
        if (!allowed) throw new IllegalStateException("Không thể chuyển trạng thái giao từ " + current + " sang " + target);

        if (target == DeliveryStatus.FAILED && (failureReason == null || failureReason.isBlank())) {
            throw new IllegalArgumentException("Phải nhập lý do giao thất bại");
        }
        if (target == DeliveryStatus.CANCELLED && (failureReason == null || failureReason.isBlank())) {
            throw new IllegalArgumentException("Vui lòng nhập lý do từ chối nhận đơn");
        }

        Order order = assignment.getOrder();
        SellRequest sellRequest = assignment.getSellRequest();
        boolean isSellRequest = (sellRequest != null);
        boolean isReturnOrder = (order != null && (order.getOrderStatus() == OrderStatus.RETURN_REQUESTED || order.getOrderStatus() == OrderStatus.RETURNED));

        if (!isSellRequest && (target == DeliveryStatus.ACCEPTED || target == DeliveryStatus.PICKED_UP)
                && order != null && order.getOrderStatus() != OrderStatus.READY_FOR_PICKUP && !isReturnOrder) {
            throw new IllegalStateException("Đơn hàng chưa sẵn sàng để lấy");
        }

        // Ràng buộc Shipper bận: Chỉ khi đang trong giai đoạn vận chuyển (SHIPPING) mới không được nhận thêm đơn
        if (target == DeliveryStatus.ACCEPTED) {
            List<DeliveryStatus> busyStatuses = List.of(DeliveryStatus.SHIPPING);
            Optional<DeliveryAssignment> ongoing = assignmentRepository.findFirstByShipperIdAndStatusIn(shipper.getId(), busyStatuses);
            if (ongoing.isPresent() && !Objects.equals(ongoing.get().getId(), assignment.getId())) {
                String code = ongoing.get().getReferenceCode();
                throw new IllegalStateException("Bạn đang trong giai đoạn vận chuyển đơn giao #" + code + ". Vui lòng hoàn thành giao đơn hiện tại trước khi nhận thêm đơn mới!");
            }
        }

        assignment.setStatus(target);
        if (target == DeliveryStatus.ACCEPTED) {
            if (isSellRequest) {
                List<DeliveryAssignment> otherAssignments = assignmentRepository.findBySellRequestIdAndShipperIdNot(sellRequest.getId(), assignment.getShipper().getId());
                for (DeliveryAssignment oa : otherAssignments) {
                    if (oa.getStatus() == DeliveryStatus.ASSIGNED) {
                        oa.setStatus(DeliveryStatus.CANCELLED);
                        oa.setCompletedAt(LocalDateTime.now());
                        assignmentRepository.save(oa);
                    }
                }
                sellRequest.setStaffNote((sellRequest.getStaffNote() != null ? sellRequest.getStaffNote() + " | " : "") +
                        "Shipper " + shipper.getFullName() + " đã xác nhận nhận đơn lúc " +
                        LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM")));
                sellRequestRepository.save(sellRequest);
            } else if (order != null) {
                List<DeliveryAssignment> otherAssignments = assignmentRepository.findByOrderIdAndShipperIdNot(order.getId(), assignment.getShipper().getId());
                for (DeliveryAssignment oa : otherAssignments) {
                    if (oa.getStatus() == DeliveryStatus.ASSIGNED) {
                        oa.setStatus(DeliveryStatus.CANCELLED);
                        oa.setCompletedAt(LocalDateTime.now());
                        assignmentRepository.save(oa);
                    }
                }
                order.setNote((order.getNote() != null ? order.getNote() + " | " : "") +
                        "Shipper " + shipper.getFullName() + " đã xác nhận nhận đơn lúc " +
                        LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM")));
                orderRepository.save(order);
            }
        } else if (target == DeliveryStatus.PICKED_UP) {
            assignment.setPickedUpAt(LocalDateTime.now());
            if (isSellRequest) {
                sellRequest.setStaffNote((sellRequest.getStaffNote() != null ? sellRequest.getStaffNote() + " | " : "") +
                        "Shipper " + shipper.getFullName() + " đã nhận sách từ khách lúc " +
                        LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM")));
                sellRequestRepository.save(sellRequest);
            } else if (order != null) {
                if (!isReturnOrder) order.setOrderStatus(OrderStatus.PICKED_UP);
                orderRepository.save(order);
            }
        } else if (target == DeliveryStatus.SHIPPING) {
            if (isSellRequest) {
                sellRequest.setStaffNote((sellRequest.getStaffNote() != null ? sellRequest.getStaffNote() + " | " : "") +
                        "Shipper " + shipper.getFullName() + " đang vận chuyển sách về kho lúc " +
                        LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM")));
                sellRequestRepository.save(sellRequest);
            } else if (order != null) {
                if (!isReturnOrder) order.setOrderStatus(OrderStatus.SHIPPING);
                orderRepository.save(order);
            }
        } else if (target == DeliveryStatus.DELIVERED) {
            LocalDateTime now = LocalDateTime.now();
            assignment.setDeliveredAt(now);
            assignment.setCompletedAt(now);
            if (isSellRequest) {
                sellRequest.setStaffNote((sellRequest.getStaffNote() != null ? sellRequest.getStaffNote() + " | " : "") +
                        "Shipper " + (assignment.getShipper() != null ? assignment.getShipper().getFullName() : "") +
                        " đã giao sách về kho chi nhánh lúc " + now.format(java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM")) +
                        ". Chờ Shop kiểm tra và hoàn tất nhập kho.");
                sellRequestRepository.save(sellRequest);
            } else if (order != null) {
                if (isReturnOrder) {
                    order.setNote((order.getNote() != null ? order.getNote() + " | " : "") +
                            "Shipper " + (assignment.getShipper() != null ? assignment.getShipper().getFullName() : "") +
                            " đã giao sách hoàn trả về trụ sở lúc " + now.format(java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM")) +
                            ". Chờ Vendor kiểm tra và xác nhận nhận sách.");
                } else {
                    order.setOrderStatus(OrderStatus.DELIVERED);
                    if (order.getPaymentMethod() == PaymentMethod.COD) order.setPaymentStatus(PaymentStatus.PAID);
                }
                orderRepository.save(order);
            }
        } else if (target == DeliveryStatus.FAILED) {
            assignment.setFailureReason(failureReason.trim());
            assignment.setCompletedAt(LocalDateTime.now());
            if (order != null && !isReturnOrder) {
                order.setOrderStatus(OrderStatus.READY_FOR_PICKUP);
                orderRepository.save(order);
            }
        } else if (target == DeliveryStatus.CANCELLED) {
            // Shipper từ chối nhận đơn
            assignment.setFailureReason("Shipper từ chối: " + failureReason.trim());
            assignment.addRejectedShipper(shipper.getId());
            assignment.setCompletedAt(LocalDateTime.now());
            if (isSellRequest) {
                sellRequest.setStaffNote((sellRequest.getStaffNote() != null ? sellRequest.getStaffNote() + " | " : "") +
                        "Shipper " + shipper.getFullName() + " từ chối lấy sách lúc " +
                        LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM")) +
                        ". Lý do: " + failureReason.trim());
                sellRequestRepository.save(sellRequest);
            } else if (order != null) {
                if (!isReturnOrder) order.setOrderStatus(OrderStatus.READY_FOR_PICKUP);
                else order.setOrderStatus(OrderStatus.RETURN_REQUESTED);

                order.setNote((order.getNote() != null ? order.getNote() + " | " : "") +
                        "Shipper " + shipper.getFullName() + " đã từ chối nhận đơn lúc " +
                        LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm dd/MM")) +
                        ". Lý do: " + failureReason.trim());
                orderRepository.save(order);
                try {
                    messagingTemplate.convertAndSend("/topic/orders", "Shipper " + shipper.getFullName() + " đã từ chối đơn #" + order.getOrderCode() + ": " + failureReason.trim());
                } catch (Exception ignored) { }
            }
        }
        DeliveryAssignment saved = assignmentRepository.save(assignment);
        try {
            messagingTemplate.convertAndSend("/topic/orders", "Đơn " + order.getOrderCode() + " cập nhật giao hàng: " + target);
        } catch (Exception ignored) { }
        return saved;
    }

    public double calculateAssignmentIncome(DeliveryAssignment a) {
        if (a.getStatus() != DeliveryStatus.DELIVERED) return 0.0;
        Order o = a.getOrder();
        if (o == null) return 20000.0; // Thu gom sách cũ thu mua: 20,000đ

        double baseFee = 20000.0;
        if (o.getShippingProvider() != null && o.getShippingProvider().getBaseFee() != null && o.getShippingProvider().getBaseFee() > 0) {
            baseFee = o.getShippingProvider().getBaseFee();
        }

        boolean isReturn = "SHIPPER".equalsIgnoreCase(o.getReturnMethod())
                || o.getOrderStatus() == OrderStatus.RETURN_REQUESTED
                || o.getOrderStatus() == OrderStatus.RETURNED
                || o.getOrderStatus() == OrderStatus.REFUNDED;
        if (isReturn) {
            // Shipper đi lấy hàng hoàn trả nhận đủ công giao hàng (tối thiểu 20.000đ)
            return (o.getReturnShippingFee() != null && o.getReturnShippingFee() > baseFee)
                    ? o.getReturnShippingFee()
                    : baseFee;
        }
        // Đơn hàng tiêu chuẩn: Phí công giao hàng cho Shipper tối thiểu là baseFee (20.000đ)
        // (Kể cả khi khách hàng được áp mã giảm giá phí vận chuyển)
        return (o.getShippingFee() != null && o.getShippingFee() > baseFee) ? o.getShippingFee() : baseFee;
    }

    @Override
    public ShipperDashboardDTO getDashboard(String email, LocalDate from, LocalDate to) {
        List<DeliveryAssignment> assignments = getAssignments(email, null, from, to);
        double totalCod = assignments.stream()
                .filter(a -> a.getStatus() == DeliveryStatus.DELIVERED)
                .filter(a -> a.getOrder() != null && a.getOrder().getPaymentMethod() == PaymentMethod.COD)
                .mapToDouble(a -> a.getOrder().getFinalAmount() != null ? a.getOrder().getFinalAmount() : 0.0)
                .sum();

        double shippingRevenue = assignments.stream()
                .filter(a -> a.getStatus() == DeliveryStatus.DELIVERED)
                .mapToDouble(this::calculateAssignmentIncome)
                .sum();

        return ShipperDashboardDTO.builder()
                .total(assignments.size())
                .assigned(assignments.stream().filter(a -> a.getStatus() == DeliveryStatus.ASSIGNED || a.getStatus() == DeliveryStatus.ACCEPTED).count())
                .inProgress(assignments.stream().filter(a -> a.getStatus() == DeliveryStatus.PICKED_UP || a.getStatus() == DeliveryStatus.SHIPPING).count())
                .delivered(assignments.stream().filter(a -> a.getStatus() == DeliveryStatus.DELIVERED).count())
                .failed(assignments.stream().filter(a -> a.getStatus() == DeliveryStatus.FAILED).count())
                .totalCodCollected(totalCod)
                .shippingRevenue(shippingRevenue)
                .build();
    }

    @Override
    public ShipperIncomeAnalyticsDTO getIncomeAnalytics(String email, Integer year, Integer month) {
        User shipper = requireShipper(email);
        int targetYear = (year != null && year > 2000) ? year : LocalDate.now().getYear();
        int targetMonth = (month != null && month >= 1 && month <= 12) ? month : LocalDate.now().getMonthValue();

        List<DeliveryAssignment> allDelivered = assignmentRepository.findByShipperId(shipper.getId()).stream()
                .filter(a -> a.getStatus() == DeliveryStatus.DELIVERED)
                .toList();

        List<Integer> availableYears = allDelivered.stream()
                .map(a -> {
                    LocalDateTime dt = a.getCompletedAt() != null ? a.getCompletedAt()
                            : (a.getDeliveredAt() != null ? a.getDeliveredAt() : a.getAssignedAt());
                    return dt != null ? dt.getYear() : LocalDate.now().getYear();
                })
                .distinct()
                .sorted()
                .collect(Collectors.toCollection(ArrayList::new));

        if (!availableYears.contains(targetYear)) {
            availableYears.add(targetYear);
            availableYears.sort(Integer::compareTo);
        }
        if (!availableYears.contains(LocalDate.now().getYear())) {
            availableYears.add(LocalDate.now().getYear());
            availableYears.sort(Integer::compareTo);
        }

        List<Double> yearlyMonths = new ArrayList<>(Collections.nCopies(12, 0.0));
        Map<Integer, List<Double>> monthlyData = new HashMap<>();

        for (int m = 1; m <= 12; m++) {
            int days = YearMonth.of(targetYear, m).lengthOfMonth();
            monthlyData.put(m, new ArrayList<>(Collections.nCopies(days, 0.0)));
        }

        double totalYear = 0.0;
        for (DeliveryAssignment a : allDelivered) {
            LocalDateTime dt = a.getCompletedAt() != null ? a.getCompletedAt()
                    : (a.getDeliveredAt() != null ? a.getDeliveredAt() : a.getAssignedAt());
            if (dt == null) continue;
            LocalDate ld = dt.toLocalDate();
            if (ld.getYear() == targetYear) {
                double income = calculateAssignmentIncome(a);
                totalYear += income;
                int mIdx = ld.getMonthValue() - 1;
                yearlyMonths.set(mIdx, yearlyMonths.get(mIdx) + income);

                List<Double> daysList = monthlyData.get(ld.getMonthValue());
                int dayIdx = ld.getDayOfMonth() - 1;
                if (daysList != null && dayIdx >= 0 && dayIdx < daysList.size()) {
                    daysList.set(dayIdx, daysList.get(dayIdx) + income);
                }
            }
        }

        double currentMonthTotal = (targetMonth >= 1 && targetMonth <= 12) ? yearlyMonths.get(targetMonth - 1) : 0.0;

        return ShipperIncomeAnalyticsDTO.builder()
                .selectedYear(targetYear)
                .selectedMonth(targetMonth)
                .totalYearIncome(totalYear)
                .currentMonthIncome(currentMonthTotal)
                .availableYears(availableYears)
                .yearlyMonths(yearlyMonths)
                .monthlyData(monthlyData)
                .build();
    }
}
