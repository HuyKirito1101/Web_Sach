package vn.iotstar.websach.config;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.RoleName;
import vn.iotstar.websach.entity.enums.UserStatus;
import vn.iotstar.websach.repository.RoleRepository;
import vn.iotstar.websach.repository.UserRepository;

import java.util.Collections;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Không tìm thấy người dùng với email: " + email));

        if (user.getStatus() != UserStatus.ACTIVE) {
            throw new UsernameNotFoundException("Tài khoản chưa được kích hoạt hoặc đã bị khóa");
        }

        // Tự động gán quyền ADMIN cho tài khoản admin chính nếu chưa có
        if (email.equalsIgnoreCase("minhkhuyen779@gmail.com")
                && (user.getRole() == null || user.getRole().getName() != RoleName.ROLE_ADMIN)) {
            roleRepository.findByName(RoleName.ROLE_ADMIN).ifPresent(r -> {
                user.setRole(r);
                userRepository.save(user);
            });
        }

        return new org.springframework.security.core.userdetails.User(
                user.getEmail(),
                user.getPassword(),
                Collections.singletonList(new SimpleGrantedAuthority(user.getRole().getName().name()))
        );
    }
}
