package vn.iotstar.websach.service;

import vn.iotstar.websach.dto.LoginRequest;
import vn.iotstar.websach.dto.RegisterRequest;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.RoleName;

import java.util.List;
import java.util.Optional;

public interface UserService {
    User register(RegisterRequest request);
    void resendRegistrationOtp(String email);
    boolean verifyOtp(String email, String otpCode);
    void sendForgotPasswordOtp(String email);
    void resetPasswordWithOtp(String email, String otpCode, String newPassword);
    String login(LoginRequest request);
    Optional<User> findByEmail(String email);
    List<User> findAllUsers();
    List<User> searchUsers(String keyword);
    List<User> findByRole(RoleName roleName);
    List<User> findByRoleAndBranch(RoleName roleName, Long branchId);
    User saveUser(User user);
    User updateUserRoleAndStatus(Long userId, Long roleId, Long branchId, String status);
    User toggleUserLock(Long userId);
    void deleteUser(Long userId);
}
