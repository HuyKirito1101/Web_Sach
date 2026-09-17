package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.AppDiscount;

import java.util.Optional;

@Repository
public interface AppDiscountRepository extends JpaRepository<AppDiscount, Long> {
    Optional<AppDiscount> findByCodeAndActiveTrue(String code);
}
