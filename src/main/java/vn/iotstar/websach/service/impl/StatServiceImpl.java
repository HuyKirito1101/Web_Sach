package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import vn.iotstar.websach.dto.BranchStatDTO;
import vn.iotstar.websach.dto.SystemStatDTO;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.repository.*;
import vn.iotstar.websach.service.StatService;

@Service
@RequiredArgsConstructor
public class StatServiceImpl implements StatService {

    private final UserRepository userRepository;
    private final BranchRepository branchRepository;
    private final BookRepository bookRepository;
    private final BookCopyRepository bookCopyRepository;
    private final OrderRepository orderRepository;

    @Override
    public SystemStatDTO getSystemStats() {
        Double rev = orderRepository.getTotalSystemRevenue();
        Double comm = orderRepository.getTotalAppCommission();

        return SystemStatDTO.builder()
                .totalUsers(userRepository.count())
                .totalBranches(branchRepository.count())
                .totalBooks(bookRepository.count())
                .totalBookCopies(bookCopyRepository.count())
                .totalOrders(orderRepository.count())
                .totalRevenue(rev != null ? rev : 0.0)
                .totalAppCommission(comm != null ? comm : 0.0)
                .build();
    }

    @Override
    public BranchStatDTO getBranchStats(Long branchId) {
        Branch branch = branchRepository.findById(branchId).orElse(null);
        String name = branch != null ? branch.getName() : "Unknown";

        Double rev = orderRepository.getBranchRevenue(branchId);
        long pending = orderRepository.findByBranchIdAndOrderStatus(branchId, OrderStatus.NEW).size();
        long totalCopies = bookCopyRepository.findByBranchId(branchId).stream()
                .mapToLong(c -> c.getQuantity() != null ? c.getQuantity() : 0)
                .sum();

        return BranchStatDTO.builder()
                .branchName(name)
                .totalCopiesInStock(totalCopies)
                .totalOrders(orderRepository.findByBranchId(branchId).size())
                .pendingOrders(pending)
                .totalBranchRevenue(rev != null ? rev : 0.0)
                .build();
    }
}
