package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.OtpToken;

import java.util.Optional;

@Repository
public interface OtpTokenRepository extends JpaRepository<OtpToken, Long> {
    Optional<OtpToken> findByEmailAndOtpCodeAndTypeAndUsedFalse(String email, String otpCode, String type);
    void deleteByEmailAndType(String email, String type);
    void deleteByEmail(String email);
}
