package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import vn.iotstar.websach.entity.ShippingProvider;
import vn.iotstar.websach.repository.ShippingProviderRepository;
import vn.iotstar.websach.service.ShippingProviderService;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ShippingProviderServiceImpl implements ShippingProviderService {

    private final ShippingProviderRepository shippingProviderRepository;

    @Override
    public List<ShippingProvider> findAllProviders() {
        return shippingProviderRepository.findAll();
    }

    @Override
    public Optional<ShippingProvider> findById(Long id) {
        return shippingProviderRepository.findById(id);
    }

    @Override
    public ShippingProvider saveProvider(ShippingProvider provider) {
        return shippingProviderRepository.save(provider);
    }

    @Override
    public ShippingProvider updateProvider(Long id, ShippingProvider details) {
        ShippingProvider p = shippingProviderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Nhà vận chuyển không tồn tại id: " + id));
        p.setName(details.getName());
        p.setPhone(details.getPhone());
        p.setBaseFee(details.getBaseFee());
        if (details.getActive() != null) {
            p.setActive(details.getActive());
        }
        return shippingProviderRepository.save(p);
    }

    @Override
    public void deleteProvider(Long id) {
        shippingProviderRepository.deleteById(id);
    }
}
