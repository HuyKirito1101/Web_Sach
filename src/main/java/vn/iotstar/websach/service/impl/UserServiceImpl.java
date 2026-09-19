package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.config.JwtUtils;
import vn.iotstar.websach.dto.LoginRequest;
import vn.iotstar.websach.dto.RegisterRequest;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.OtpToken;
import vn.iotstar.websach.entity.Role;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.RoleName;
import vn.iotstar.websach.entity.enums.UserStatus;
import vn.iotstar.websach.repository.BranchRepository;
import vn.iotstar.websach.repository.OtpTokenRepository;
import vn.iotstar.websach.repository.RoleRepository;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.service.EmailService;
import vn.iotstar.websach.service.UserService;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final BranchRepository branchRepository;
    private final OtpTokenRepository otpTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtUtils jwtUtils;
    private final EmailService emailService;

    @Override
    @Transactional
    public User register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("Email đã được đăng ký trong hệ thống!");
        }

        Role userRole = roleRepository.findByName(RoleName.ROLE_USER)
                .orElseThrow(() -> new RuntimeException("Lỗi cấu hình Role mặc định USER"));

        User user = User.builder()
                .fullName(request.getFullName())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .role(userRole)
                .status(UserStatus.INACTIVE) // Chờ xác thực OTP
                .build();

        User savedUser = userRepository.save(user);

        // Sinh OTP & Gửi Email
        String otpCode = String.format("%06d", new Random().nextInt(900000) + 100000);
        OtpToken otpToken = OtpToken.builder()
                .email(user.getEmail())
                .otpCode(otpCode)
                .expiryTime(LocalDateTime.now().plusMinutes(5))
                .used(false)
                .type("REGISTER")
                .build();
        otpTokenRepository.save(otpToken);

        emailService.sendOtpEmail(user.getEmail(), otpCode);

        return savedUser;
    }

    @Override
    @Transactional
    public boolean verifyOtp(String email, String otpCode) {
        Optional<OtpToken> otpOpt = otpTokenRepository.findByEmailAndOtpCodeAndUsedFalse(email, otpCode);
        if (otpOpt.isPresent()) {
            OtpToken otpToken = otpOpt.get();
            if (otpToken.getExpiryTime().isAfter(LocalDateTime.now())) {
                otpToken.setUsed(true);
                otpTokenRepository.save(otpToken);

                User user = userRepository.findByEmail(email)
                        .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));
                user.setStatus(UserStatus.ACTIVE);
                userRepository.save(user);
                return true;
            }
        }
        return false;
    }

    @Override
    public String login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User không tồn tại"));

        return jwtUtils.generateJwtToken(user.getEmail(), user.getRole().getName().name());
    }

    @Override
    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    @Override
    public List<User> findAllUsers() {
        return userRepository.findAll();
    }

    @Override
    public List<User> searchUsers(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return userRepository.findAll();
        }
        return userRepository.searchUsers(keyword.trim());
    }

    @Override
    public List<User> findByRole(RoleName roleName) {
        return userRepository.findByRoleName(roleName);
    }

    @Override
    public List<User> findByRoleAndBranch(RoleName roleName, Long branchId) {
        return userRepository.findByRoleNameAndBranchId(roleName, branchId);
    }

    @Override
    public User saveUser(User user) {
        return userRepository.save(user);
    }

    @Override
    @Transactional
    public User updateUserRoleAndStatus(Long userId, Long roleId, Long branchId, String statusStr) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user id: " + userId));

        if (roleId != null) {
            Role role = roleRepository.findById(roleId)
                    .orElseThrow(() -> new RuntimeException("Role không tồn tại"));
            user.setRole(role);
        }

        if (branchId != null) {
            Branch branch = branchRepository.findById(branchId).orElse(null);
            user.setBranch(branch);
        }

        if (statusStr != null) {
            user.setStatus(UserStatus.valueOf(statusStr));
        }

        return userRepository.save(user);
    }

    @Override
    @Transactional
    public User toggleUserLock(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy user id: " + userId));

        if (user.getStatus() == UserStatus.LOCKED) {
            user.setStatus(UserStatus.ACTIVE);
        } else {
            user.setStatus(UserStatus.LOCKED);
        }

        return userRepository.save(user);
    }

    @Override
    @Transactional
    public void deleteUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Không tìm thấy người dùng id: " + userId));

        // Nếu user đang làm Vendor sở hữu branch, gỡ bỏ liên kết owner trước khi xóa
        branchRepository.findAll().stream()
                .filter(b -> b.getOwner() != null && b.getOwner().getId().equals(userId))
                .forEach(b -> {
                    b.setOwner(null);
                    branchRepository.save(b);
                });

        userRepository.delete(user);
    }
}
