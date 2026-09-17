package vn.iotstar.websach.service;

import vn.iotstar.websach.entity.AppDiscount;

import java.util.List;
import java.util.Optional;

public interface AppDiscountService {
    List<AppDiscount> findAllDiscounts();
    Optional<AppDiscount> findById(Long id);
    Optional<AppDiscount> findByCode(String code);
    AppDiscount saveDiscount(AppDiscount discount);
    AppDiscount updateDiscount(Long id, AppDiscount details);
    void deleteDiscount(Long id);
}
