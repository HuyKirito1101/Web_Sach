package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.ShippingProvider;

import java.util.List;

@Repository
public interface ShippingProviderRepository extends JpaRepository<ShippingProvider, Long> {
    List<ShippingProvider> findByActiveTrue();
}
