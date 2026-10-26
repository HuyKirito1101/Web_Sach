package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import vn.iotstar.websach.entity.ShippingProvider;
import vn.iotstar.websach.repository.ShippingProviderRepository;
import vn.iotstar.websach.service.ShippingProviderService;

import java.util.List;
import java.util.Optional;
import java.util.Locale;

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
        validate(provider);
        normalize(provider);
        return shippingProviderRepository.save(provider);
    }

    @Override
    public ShippingProvider updateProvider(Long id, ShippingProvider details) {
        validate(details);
        normalize(details);
        ShippingProvider p = shippingProviderRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Nhà vận chuyển không tồn tại id: " + id));
        p.setName(details.getName());
        if (details.getCode() != null) p.setCode(details.getCode());
        if (details.getServiceType() != null) p.setServiceType(details.getServiceType());
        if (details.getEstimatedDays() != null) p.setEstimatedDays(details.getEstimatedDays());
        if (details.getScopeDescription() != null) p.setScopeDescription(details.getScopeDescription());
        p.setPhone(details.getPhone());
        p.setBaseFee(details.getBaseFee());
        if (details.getActive() != null) {
            p.setActive(details.getActive());
        }
        return shippingProviderRepository.save(p);
    }

    @Override
    public void deleteProvider(Long id) {
        ShippingProvider provider = shippingProviderRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Nhà vận chuyển không tồn tại."));
        provider.setActive(false);
        shippingProviderRepository.save(provider);
    }

    private void validate(ShippingProvider provider) {
        if (provider == null || provider.getName() == null || provider.getName().isBlank()
                || provider.getName().trim().length() > 150) {
            throw new IllegalArgumentException("Tên nhà vận chuyển phải có từ 1 đến 150 ký tự.");
        }
        if (provider.getCode() == null || !provider.getCode().trim().matches("[A-Za-z0-9_-]{2,50}")) {
            throw new IllegalArgumentException("Mã nhà vận chuyển phải có 2-50 ký tự chữ, số, gạch ngang hoặc gạch dưới.");
        }
        if (provider.getBaseFee() == null || provider.getBaseFee() < 0) {
            throw new IllegalArgumentException("Phí vận chuyển không được âm.");
        }
        if (provider.getPhone() != null && !provider.getPhone().isBlank()
                && !provider.getPhone().trim().matches("^(?:0\\d{9}|\\+84\\d{9})$")) {
            throw new IllegalArgumentException("Số điện thoại nhà vận chuyển không hợp lệ.");
        }
    }

    private void normalize(ShippingProvider provider) {
        provider.setName(provider.getName().trim());
        provider.setCode(provider.getCode().trim().toUpperCase(Locale.ROOT));
        if (provider.getPhone() != null) provider.setPhone(provider.getPhone().trim());
    }
}
