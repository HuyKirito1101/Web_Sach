package vn.iotstar.websach.service.impl;

import jakarta.persistence.EntityManager;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
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
import vn.iotstar.websach.service.ManagerAccessService;
import vn.iotstar.websach.service.UserService;

import java.time.LocalDateTime;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private static final String REGISTER_OTP_TYPE = "REGISTER";
    private static final String FORGOT_PASSWORD_OTP_TYPE = "FORGOT_PASSWORD";
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();
    private static final List<RoleName> BRANCH_MANAGEABLE_ROLES = List.of(
            RoleName.ROLE_VENDOR, RoleName.ROLE_SHIPPER);

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final BranchRepository branchRepository;
    private final OtpTokenRepository otpTokenRepository;
    private final EntityManager entityManager;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtUtils jwtUtils;
    private final EmailService emailService;
    private final ManagerAccessService managerAccessService;

    @Override
    @Transactional
    public User register(RegisterRequest request) {
        String email = normalizeEmail(request.getEmail());
        validatePassword(request.getPassword());
        String fullName = normalizeFullName(request.getFullName());
        String phone = normalizePhone(request.getPhone());

        Role userRole = roleRepository.findByName(RoleName.ROLE_USER)
                .orElseThrow(() -> new RuntimeException("Lỗi cấu hình Role mặc định USER"));

        User user = userRepository.findByEmail(email).map(existingUser -> {
            if (existingUser.getStatus() != UserStatus.INACTIVE) {
                throw new IllegalStateException("Email đã được đăng ký và kích hoạt trong hệ thống!");
            }

            // Email chưa xác thực được phép đăng ký lại để nhận OTP mới.
            existingUser.setFullName(fullName);
            existingUser.setPassword(passwordEncoder.encode(request.getPassword()));
            existingUser.setPhone(phone);
            existingUser.setRole(userRole);
            return existingUser;
        }).orElseGet(() -> User.builder()
                .fullName(fullName)
                .email(email)
                .password(passwordEncoder.encode(request.getPassword()))
                .phone(phone)
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
                .otpCode(passwordEncoder.encode(otpCode))
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
                .findTopByEmailAndTypeAndUsedFalseOrderByIdDesc(normalizedEmail, REGISTER_OTP_TYPE);
        if (otpOpt.isPresent()) {
            OtpToken otpToken = otpOpt.get();
            String submittedOtp = otpCode == null ? "" : otpCode.trim();
            if (otpToken.getExpiryTime().isAfter(LocalDateTime.now())
                    && passwordEncoder.matches(submittedOtp, otpToken.getOtpCode())) {
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
        Optional<User> userOpt = userRepository.findByEmail(normalizedEmail);

        // Không tiết lộ email nào có tài khoản (chống account enumeration).
        if (userOpt.isEmpty() || userOpt.get().getStatus() == UserStatus.LOCKED) {
            return;
        }

        otpTokenRepository.deleteByEmailAndType(normalizedEmail, FORGOT_PASSWORD_OTP_TYPE);

        String otpCode = String.format("%06d", SECURE_RANDOM.nextInt(900000) + 100000);
        OtpToken otpToken = OtpToken.builder()
                .email(normalizedEmail)
                .otpCode(passwordEncoder.encode(otpCode))
                .expiryTime(LocalDateTime.now().plusMinutes(5))
                .used(false)
                .type(FORGOT_PASSWORD_OTP_TYPE)
                .build();

        otpTokenRepository.saveAndFlush(otpToken);
        emailService.sendPasswordResetOtpEmail(normalizedEmail, otpCode);
    }

    @Override
    @Transactional
    public void resetPasswordWithOtp(String email, String otpCode, String newPassword) {
        String normalizedEmail = normalizeEmail(email);
        User user = userRepository.findByEmail(normalizedEmail)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản."));

        OtpToken otpToken = otpTokenRepository
                .findTopByEmailAndTypeAndUsedFalseOrderByIdDesc(normalizedEmail, FORGOT_PASSWORD_OTP_TYPE)
                .orElseThrow(() -> new IllegalArgumentException("Mã OTP không đúng hoặc đã được sử dụng."));

        if (otpToken.getExpiryTime().isBefore(LocalDateTime.now())) {
            throw new IllegalArgumentException("Mã OTP đã hết hạn. Vui lòng yêu cầu gửi lại mã mới.");
        }

        if (!passwordEncoder.matches(otpCode == null ? "" : otpCode.trim(), otpToken.getOtpCode())) {
            throw new IllegalArgumentException("Mã OTP không đúng hoặc đã được sử dụng.");
        }

        validatePassword(newPassword);

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
    public String getLandingPage(String email) {
        User user = userRepository.findByEmail(normalizeEmail(email))
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản."));
        if (user.getRole() == null || user.getRole().getName() == null) {
            return "/";
        }
        return switch (user.getRole().getName()) {
            case ROLE_ADMIN -> "/admin/dashboard";
            case ROLE_MANAGER -> "/manager/dashboard";
            case ROLE_VENDOR -> "/vendor/dashboard";
            case ROLE_SHIPPER -> "/shipper/dashboard";
            default -> "/";
        };
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
    public List<Role> findAllRoles() {
        return roleRepository.findAll();
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

        Role selectedRole = user.getRole();
        if (roleId != null) {
            selectedRole = roleRepository.findById(roleId)
                    .orElseThrow(() -> new RuntimeException("Role không tồn tại"));
            user.setRole(selectedRole);
        }

        Branch selectedBranch = branchId == null ? null : branchRepository.findById(branchId)
                .orElseThrow(() -> new IllegalArgumentException("Chi nhánh không tồn tại."));
        if (selectedRole != null && (selectedRole.getName() == RoleName.ROLE_MANAGER
                || selectedRole.getName() == RoleName.ROLE_SHIPPER) && selectedBranch == null) {
            throw new IllegalArgumentException("Manager và Shipper phải được gán một chi nhánh.");
        }
        user.setBranch(selectedBranch);

        if (statusStr != null && !statusStr.isBlank()) {
            try {
                user.setStatus(UserStatus.valueOf(statusStr.trim().toUpperCase(Locale.ROOT)));
            } catch (IllegalArgumentException ex) {
                throw new IllegalArgumentException("Trạng thái tài khoản không hợp lệ.");
            }
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

        List<String> blockers = findDeletionBlockers(userId);
        if (!blockers.isEmpty()) {
            throw new IllegalStateException("Không thể xóa tài khoản " + user.getEmail()
                    + " vì còn dữ liệu liên quan: " + String.join(", ", blockers)
                    + ". Hãy xử lý dữ liệu này hoặc khóa tài khoản thay vì xóa.");
        }

        // OTP không có khóa ngoại tới users và không phải dữ liệu nghiệp vụ cần lưu.
        otpTokenRepository.deleteByEmail(user.getEmail());
        try {
            userRepository.delete(user);
            userRepository.flush();
        } catch (DataIntegrityViolationException ex) {
            // Bảo vệ trường hợp dữ liệu liên quan phát sinh ngay sau bước kiểm tra.
            throw new IllegalStateException("Không thể xóa tài khoản vì vẫn còn dữ liệu liên quan trong hệ thống. "
                    + "Vui lòng tải lại danh sách và thử lại.", ex);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<User> searchUsersForManagedBranch(String managerEmail, String keyword) {
        Branch branch = managerAccessService.requireManagedBranch(managerEmail);
        String normalizedKeyword = keyword == null ? "" : keyword.trim();
        return userRepository.searchManageableUsersByBranch(
                branch.getId(), BRANCH_MANAGEABLE_ROLES, normalizedKeyword);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Role> findBranchManageableRoles() {
        return BRANCH_MANAGEABLE_ROLES.stream()
                .map(roleName -> roleRepository.findByName(roleName)
                        .orElseThrow(() -> new IllegalStateException("Thiếu quyền hệ thống " + roleName)))
                .toList();
    }

    @Override
    @Transactional
    public User updateManagedBranchUser(String managerEmail, Long userId, Long roleId, String statusStr) {
        Branch branch = managerAccessService.requireManagedBranch(managerEmail);
        User user = managerAccessService.requireUserInBranch(managerEmail, userId);
        ensureManagerCanManage(user);

        Role selectedRole = roleRepository.findById(roleId)
                .orElseThrow(() -> new IllegalArgumentException("Role không tồn tại."));
        if (!BRANCH_MANAGEABLE_ROLES.contains(selectedRole.getName())) {
            throw new SecurityException("Manager chỉ được gán quyền User, Vendor hoặc Shipper.");
        }

        user.setRole(selectedRole);
        user.setBranch(branch);
        if (statusStr != null && !statusStr.isBlank()) {
            try {
                user.setStatus(UserStatus.valueOf(statusStr.trim().toUpperCase(Locale.ROOT)));
            } catch (IllegalArgumentException ex) {
                throw new IllegalArgumentException("Trạng thái tài khoản không hợp lệ.");
            }
        }
        return userRepository.save(user);
    }

    @Override
    @Transactional
    public User toggleManagedBranchUserLock(String managerEmail, Long userId) {
        User user = managerAccessService.requireUserInBranch(managerEmail, userId);
        ensureManagerCanManage(user);
        user.setStatus(user.getStatus() == UserStatus.LOCKED ? UserStatus.ACTIVE : UserStatus.LOCKED);
        return userRepository.save(user);
    }

    @Override
    @Transactional
    public void deleteManagedBranchUser(String managerEmail, Long userId) {
        User user = managerAccessService.requireUserInBranch(managerEmail, userId);
        ensureManagerCanManage(user);
        deleteUser(userId);
    }

    private void ensureManagerCanManage(User user) {
        if (user.getRole() == null || !BRANCH_MANAGEABLE_ROLES.contains(user.getRole().getName())) {
            throw new SecurityException("Manager không được quản lý tài khoản Admin hoặc Manager.");
        }
    }

    private List<String> findDeletionBlockers(Long userId) {
        List<String> blockers = new ArrayList<>();
        addBlocker(blockers, countUserReferences(
                "select count(o) from Order o where o.customer.id = :userId", userId), "đơn hàng mua");
        addBlocker(blockers, countUserReferences(
                "select count(r) from SellRequest r where r.customer.id = :userId or r.buyerVendor.id = :userId",
                userId), "yêu cầu thu mua sách");
        addBlocker(blockers, countUserReferences(
                "select count(b) from BookCopy b where b.seller.id = :userId", userId), "sản phẩm đang bán");
        addBlocker(blockers, countUserReferences(
                "select count(b) from Branch b where b.owner.id = :userId", userId), "chi nhánh đang sở hữu");
        addBlocker(blockers, countUserReferences(
                "select count(p) from Promotion p where p.vendor.id = :userId", userId), "chương trình khuyến mãi");
        addBlocker(blockers, countUserReferences(
                "select count(r) from Review r where r.user.id = :userId", userId), "đánh giá sản phẩm");
        addBlocker(blockers, countUserReferences(
                "select count(q) from SellRequestQuote q where q.vendor.id = :userId", userId), "báo giá thu mua");
        addBlocker(blockers, countUserReferences(
                "select count(d) from DeliveryAssignment d where d.shipper.id = :userId or d.assignedBy.id = :userId",
                userId), "phân công giao hàng");
        addBlocker(blockers, countUserReferences(
                "select count(s) from StockTransfer s where s.requestedBy.id = :userId or s.approvedBy.id = :userId",
                userId), "phiếu điều chuyển kho");
        addBlocker(blockers, countUserReferences(
                "select count(a) from Address a where a.user.id = :userId", userId), "địa chỉ nhận hàng");
        addBlocker(blockers, countUserReferences(
                "select count(c) from CartItem c where c.user.id = :userId", userId), "sản phẩm trong giỏ hàng");
        addBlocker(blockers, countUserReferences(
                "select count(f) from Favorite f where f.user.id = :userId", userId), "sản phẩm yêu thích");
        addBlocker(blockers, countUserReferences(
                "select count(v) from ViewedProduct v where v.user.id = :userId", userId), "lịch sử xem sản phẩm");
        return blockers;
    }

    private long countUserReferences(String jpql, Long userId) {
        return entityManager.createQuery(jpql, Long.class)
                .setParameter("userId", userId)
                .getSingleResult();
    }

    private void addBlocker(List<String> blockers, long count, String label) {
        if (count > 0) {
            blockers.add(label + " (" + count + ")");
        }
    }

    private String normalizeEmail(String email) {
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("Email không được để trống.");
        }
        return email.trim().toLowerCase(Locale.ROOT);
    }

    private void validatePassword(String password) {
        if (password == null || password.length() < 8 || password.length() > 72) {
            throw new IllegalArgumentException("Mật khẩu phải có từ 8 đến 72 ký tự.");
        }
    }

    private String normalizeFullName(String fullName) {
        if (fullName == null || fullName.isBlank() || fullName.trim().length() > 100) {
            throw new IllegalArgumentException("Họ tên phải có từ 1 đến 100 ký tự.");
        }
        return fullName.trim();
    }

    private String normalizePhone(String phone) {
        if (phone == null || phone.isBlank()) {
            return null;
        }
        String normalized = phone.trim();
        if (!normalized.matches("^(?:0\\d{9}|\\+84\\d{9})$")) {
            throw new IllegalArgumentException("Số điện thoại Việt Nam không hợp lệ.");
        }
        return normalized;
    }
}
