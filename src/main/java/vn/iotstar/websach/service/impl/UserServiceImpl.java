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
import java.security.SecureRandom;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private static final String REGISTER_OTP_TYPE = "REGISTER";
    private static final String FORGOT_PASSWORD_OTP_TYPE = "FORGOT_PASSWORD";
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

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
        String email = normalizeEmail(request.getEmail());

        Role userRole = roleRepository.findByName(RoleName.ROLE_USER)
                .orElseThrow(() -> new RuntimeException("Lỗi cấu hình Role mặc định USER"));

        User user = userRepository.findByEmail(email).map(existingUser -> {
            if (existingUser.getStatus() != UserStatus.INACTIVE) {
                throw new IllegalStateException("Email đã được đăng ký và kích hoạt trong hệ thống!");
            }

            // Email chưa xác thực được phép đăng ký lại để nhận OTP mới.
            existingUser.setFullName(request.getFullName().trim());
            existingUser.setPassword(passwordEncoder.encode(request.getPassword()));
            existingUser.setPhone(request.getPhone());
            existingUser.setRole(userRole);
            return existingUser;
        }).orElseGet(() -> User.builder()
                .fullName(request.getFullName().trim())
                .email(email)
                .password(passwordEncoder.encode(request.getPassword()))
                .phone(request.getPhone())
                .role(userRole)
                .status(UserStatus.INACTIVE)
                .build());

        User savedUser = userRepository.save(user);
        issueRegistrationOtp(email);
        return savedUser;
    }

    @Override
    @Transactional
    public void resendRegistrationOtp(String email) {
        String normalizedEmail = normalizeEmail(email);
        User user = userRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản chờ xác thực."));

        if (user.getStatus() != UserStatus.INACTIVE) {
            throw new IllegalStateException("Tài khoản này đã được kích hoạt hoặc đã bị khóa.");
        }

        issueRegistrationOtp(normalizedEmail);
    }

    private void issueRegistrationOtp(String email) {
        otpTokenRepository.deleteByEmailAndType(email, REGISTER_OTP_TYPE);

        String otpCode = String.format("%06d", SECURE_RANDOM.nextInt(900000) + 100000);
        OtpToken otpToken = OtpToken.builder()
                .email(email)
                .otpCode(otpCode)
                .expiryTime(LocalDateTime.now().plusMinutes(5))
                .used(false)
                .type(REGISTER_OTP_TYPE)
                .build();
        // Flush trước khi gửi email để mọi lỗi dữ liệu được phát hiện ngay,
        // thay vì gửi một mã chưa thực sự tồn tại trong database.
        otpTokenRepository.saveAndFlush(otpToken);

        // Nếu SMTP lỗi, exception được ném ra để transaction rollback. User mới
        // sẽ không bị lưu ở trạng thái dở dang khi chưa nhận được OTP.
        emailService.sendOtpEmail(email, otpCode);
    }

    @Override
    @Transactional
    public boolean verifyOtp(String email, String otpCode) {
        String normalizedEmail = normalizeEmail(email);
        Optional<OtpToken> otpOpt = otpTokenRepository
                .findByEmailAndOtpCodeAndTypeAndUsedFalse(
                        normalizedEmail, otpCode == null ? "" : otpCode.trim(), REGISTER_OTP_TYPE);
        if (otpOpt.isPresent()) {
            OtpToken otpToken = otpOpt.get();
            if (otpToken.getExpiryTime().isAfter(LocalDateTime.now())) {
                User user = userRepository.findByEmail(normalizedEmail)
                        .orElseThrow(() -> new RuntimeException("Không tìm thấy user"));
                if (user.getStatus() != UserStatus.INACTIVE) {
                    return false;
                }

                user.setStatus(UserStatus.ACTIVE);
                userRepository.save(user);
                // Không xóa entity vừa được đọc/khóa trong cùng persistence
                // context. Đánh dấu đã dùng giúp tránh stale-state khi người
                // dùng bấm xác thực hoặc gửi lại OTP nhiều lần gần nhau.
                otpToken.setUsed(true);
                otpTokenRepository.saveAndFlush(otpToken);
                return true;
            }
        }
        return false;
    }

    @Override
    @Transactional
    public void sendForgotPasswordOtp(String email) {
        String normalizedEmail = normalizeEmail(email);
        User user = userRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản với email này."));

        if (user.getStatus() == UserStatus.LOCKED) {
            throw new IllegalStateException("Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên.");
        }

        otpTokenRepository.deleteByEmailAndType(normalizedEmail, FORGOT_PASSWORD_OTP_TYPE);

        String otpCode = String.format("%06d", SECURE_RANDOM.nextInt(900000) + 100000);
        OtpToken otpToken = OtpToken.builder()
                .email(normalizedEmail)
                .otpCode(otpCode)
                .expiryTime(LocalDateTime.now().plusMinutes(5))
                .used(false)
                .type(FORGOT_PASSWORD_OTP_TYPE)
                .build();

        otpTokenRepository.saveAndFlush(otpToken);
        emailService.sendOtpEmail(normalizedEmail, otpCode);
    }

    @Override
    @Transactional
    public void resetPasswordWithOtp(String email, String otpCode, String newPassword) {
        String normalizedEmail = normalizeEmail(email);
        User user = userRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản."));

        OtpToken otpToken = otpTokenRepository
                .findByEmailAndOtpCodeAndTypeAndUsedFalse(
                        normalizedEmail, otpCode == null ? "" : otpCode.trim(), FORGOT_PASSWORD_OTP_TYPE)
                .orElseThrow(() -> new IllegalArgumentException("Mã OTP không đúng hoặc đã được sử dụng."));

        if (otpToken.getExpiryTime().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("Mã OTP đã hết hạn. Vui lòng yêu cầu gửi lại mã mới.");
        }

        if (newPassword == null || newPassword.trim().length() < 6) {
            throw new IllegalArgumentException("Mật khẩu mới phải có tối thiểu 6 ký tự.");
        }

        user.setPassword(passwordEncoder.encode(newPassword.trim()));
        userRepository.save(user);

        otpToken.setUsed(true);
        otpTokenRepository.saveAndFlush(otpToken);
    }

    @Override
    public String login(LoginRequest request) {
        String email = normalizeEmail(request.getEmail());
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(email, request.getPassword())
        );

        User user = userRepository.findByEmail(email)
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

        otpTokenRepository.deleteByEmail(user.getEmail());
        userRepository.delete(user);
        userRepository.flush();
    }

    private String normalizeEmail(String email) {
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("Email không được để trống.");
        }
        return email.trim().toLowerCase(Locale.ROOT);
    }
}
