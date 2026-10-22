package vn.iotstar.websach.repository;

import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.OtpToken;

import java.util.Optional;

@Repository
public interface OtpTokenRepository extends JpaRepository<OtpToken, Long> {
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    Optional<OtpToken> findTopByEmailAndTypeAndUsedFalseOrderByIdDesc(String email, String type);

    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("delete from OtpToken o where o.email = :email and o.type = :type")
    int deleteByEmailAndType(@Param("email") String email, @Param("type") String type);

    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("delete from OtpToken o where o.email = :email")
    int deleteByEmail(@Param("email") String email);
}
