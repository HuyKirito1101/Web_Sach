package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.RoleName;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    Boolean existsByEmail(String email);

    List<User> findByRoleName(RoleName roleName);
    List<User> findByBranchId(Long branchId);
    List<User> findByRoleNameAndBranchId(RoleName roleName, Long branchId);

    @Query("SELECT u FROM User u WHERE LOWER(u.fullName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR LOWER(u.email) LIKE LOWER(CONCAT('%', :keyword, '%')) OR u.phone LIKE CONCAT('%', :keyword, '%')")
    List<User> searchUsers(@Param("keyword") String keyword);

    @Query("""
            SELECT DISTINCT u FROM User u
            WHERE u.role.name IN :roles
              AND u.branch.id = :branchId
              AND (:keyword = ''
                   OR LOWER(u.fullName) LIKE LOWER(CONCAT('%', :keyword, '%'))
                   OR LOWER(u.email) LIKE LOWER(CONCAT('%', :keyword, '%'))
                   OR u.phone LIKE CONCAT('%', :keyword, '%'))
            ORDER BY u.id DESC
            """)
    List<User> searchManageableUsersByBranch(@Param("branchId") Long branchId,
                                              @Param("roles") List<RoleName> roles,
                                              @Param("keyword") String keyword);
}
