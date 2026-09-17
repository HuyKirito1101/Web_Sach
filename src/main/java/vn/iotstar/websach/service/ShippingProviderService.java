package vn.iotstar.websach.service;

import vn.iotstar.websach.entity.ShippingProvider;

import java.util.List;
import java.util.Optional;

public interface ShippingProviderService {
    List<ShippingProvider> findAllProviders();
    Optional<ShippingProvider> findById(Long id);
    ShippingProvider saveProvider(ShippingProvider provider);
    ShippingProvider updateProvider(Long id, ShippingProvider details);
    void deleteProvider(Long id);
}
