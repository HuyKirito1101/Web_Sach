package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import vn.iotstar.websach.entity.AppDiscount;
import vn.iotstar.websach.repository.AppDiscountRepository;
import vn.iotstar.websach.service.AppDiscountService;

import java.util.List;
import java.util.Optional;
import java.util.Locale;

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
        if (code == null || code.isBlank()) {
            return Optional.empty();
        }
        return appDiscountRepository.findByCodeAndActiveTrue(code.trim().toUpperCase(Locale.ROOT));
    }

    @Override
    public AppDiscount saveDiscount(AppDiscount discount) {
        validate(discount);
        discount.setCode(discount.getCode().trim().toUpperCase(Locale.ROOT));
        return appDiscountRepository.save(discount);
    }

    @Override
    public AppDiscount updateDiscount(Long id, AppDiscount details) {
        validate(details);
        AppDiscount d = appDiscountRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Mã giảm giá không tồn tại id: " + id));

        d.setCode(details.getCode().trim().toUpperCase(Locale.ROOT));
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
        AppDiscount discount = appDiscountRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Voucher không tồn tại."));
        discount.setActive(false);
        appDiscountRepository.save(discount);
    }

    private void validate(AppDiscount discount) {
        if (discount == null || discount.getCode() == null
                || !discount.getCode().trim().matches("[A-Za-z0-9_-]{3,50}")) {
            throw new IllegalArgumentException("Mã voucher phải có 3-50 ký tự chữ, số, gạch ngang hoặc gạch dưới.");
        }
        if (discount.getDiscountPercent() == null || discount.getDiscountPercent() <= 0
                || discount.getDiscountPercent() > 100) {
            throw new IllegalArgumentException("Phần trăm giảm phải lớn hơn 0 và không quá 100.");
        }
        if ((discount.getMaxDiscountAmount() != null && discount.getMaxDiscountAmount() < 0)
                || (discount.getMinOrderValue() != null && discount.getMinOrderValue() < 0)) {
            throw new IllegalArgumentException("Giá trị tiền của voucher không được âm.");
        }
        if (discount.getStartDate() == null || discount.getEndDate() == null
                || discount.getEndDate().isBefore(discount.getStartDate())) {
            throw new IllegalArgumentException("Ngày bắt đầu và kết thúc voucher không hợp lệ.");
        }
    }
}
