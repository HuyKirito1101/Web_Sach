package vn.iotstar.websach.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import vn.iotstar.websach.entity.BookCopy;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.RoleName;
import vn.iotstar.websach.repository.BookCopyRepository;
import vn.iotstar.websach.repository.OrderRepository;
import vn.iotstar.websach.repository.UserRepository;

import java.util.Objects;

@Service
@RequiredArgsConstructor
public class ManagerAccessService {

    private final UserRepository userRepository;
    private final BookCopyRepository bookCopyRepository;
    private final OrderRepository orderRepository;

    public Branch requireManagedBranch(String email) {
        User manager = userRepository.findByEmail(email)
                .orElseThrow(() -> new SecurityException("Không tìm thấy tài khoản Manager."));
        if (manager.getRole() == null || manager.getRole().getName() != RoleName.ROLE_MANAGER) {
            throw new SecurityException("Tài khoản không có quyền Manager.");
        }
        if (manager.getBranch() == null) {
            throw new IllegalStateException("Tài khoản Manager chưa được gán chi nhánh.");
        }
        return manager.getBranch();
    }

    public User requireUserInBranch(String managerEmail, Long userId) {
        Branch branch = requireManagedBranch(managerEmail);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Người dùng không tồn tại."));
        boolean assignedToBranch = user.getBranch() != null
                && Objects.equals(user.getBranch().getId(), branch.getId());
        boolean purchasedAtBranch = user.getRole() != null
                && user.getRole().getName() == RoleName.ROLE_USER
                && orderRepository.existsByBranchIdAndCustomerId(branch.getId(), userId);
        if (!assignedToBranch && !purchasedAtBranch) {
            throw new SecurityException("Không được quản lý người dùng của chi nhánh khác.");
        }
        return user;
    }

    public BookCopy requireCopyInBranch(String managerEmail, Long copyId) {
        Branch branch = requireManagedBranch(managerEmail);
        BookCopy copy = bookCopyRepository.findById(copyId)
                .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại."));
        if (copy.getBranch() == null || !Objects.equals(copy.getBranch().getId(), branch.getId())) {
            throw new SecurityException("Không được quản lý sản phẩm của chi nhánh khác.");
        }
        return copy;
    }

    public Order requireOrderInBranch(String managerEmail, Long orderId) {
        Branch branch = requireManagedBranch(managerEmail);
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Đơn hàng không tồn tại."));
        if (order.getBranch() == null || !Objects.equals(order.getBranch().getId(), branch.getId())) {
            throw new SecurityException("Không được quản lý đơn hàng của chi nhánh khác.");
        }
        return order;
    }
}
