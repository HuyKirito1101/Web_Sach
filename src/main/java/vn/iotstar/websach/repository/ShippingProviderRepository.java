package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.ShippingProvider;

import java.util.List;
import java.util.Optional;

@Repository
public interface ShippingProviderRepository extends JpaRepository<ShippingProvider, Long> {
    List<ShippingProvider> findByActiveTrue();
    Optional<ShippingProvider> findByCode(String code);
}
