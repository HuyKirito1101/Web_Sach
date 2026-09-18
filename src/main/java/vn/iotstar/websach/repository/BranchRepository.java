package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.Branch;

import java.util.List;
import java.util.Optional;

@Repository
public interface BranchRepository extends JpaRepository<Branch, Long> {
    List<Branch> findByNameContainingIgnoreCase(String name);
    Optional<Branch> findByOwnerId(Long ownerId);
    boolean existsByNameIgnoreCase(String name);
}
