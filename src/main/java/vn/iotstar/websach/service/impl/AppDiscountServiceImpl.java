package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import vn.iotstar.websach.entity.AppDiscount;
import vn.iotstar.websach.repository.AppDiscountRepository;
import vn.iotstar.websach.service.AppDiscountService;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AppDiscountServiceImpl implements AppDiscountService {

    private final AppDiscountRepository appDiscountRepository;

    @Override
    public List<AppDiscount> findAllDiscounts() {
        return appDiscountRepository.findAll();
    }

    @Override
    public Optional<AppDiscount> findById(Long id) {
        return appDiscountRepository.findById(id);
    }

    @Override
    public Optional<AppDiscount> findByCode(String code) {
        return appDiscountRepository.findByCodeAndActiveTrue(code);
    }

    @Override
    public AppDiscount saveDiscount(AppDiscount discount) {
        return appDiscountRepository.save(discount);
    }

    @Override
    public AppDiscount updateDiscount(Long id, AppDiscount details) {
        AppDiscount d = appDiscountRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Mã giảm giá không tồn tại id: " + id));

        d.setCode(details.getCode());
        d.setDiscountPercent(details.getDiscountPercent());
        d.setMaxDiscountAmount(details.getMaxDiscountAmount());
        d.setMinOrderValue(details.getMinOrderValue());
        d.setStartDate(details.getStartDate());
        d.setEndDate(details.getEndDate());
        if (details.getActive() != null) {
            d.setActive(details.getActive());
        }

        return appDiscountRepository.save(d);
    }

    @Override
    public void deleteDiscount(Long id) {
        appDiscountRepository.deleteById(id);
    }
}
