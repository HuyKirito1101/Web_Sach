package vn.iotstar.websach.service;

import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.ViewedProduct;

import java.util.List;

public interface ViewedProductService {
    void recordView(User user, Long bookId);
    List<ViewedProduct> getUserViewedProducts(User user);
    long clearUserViewedProducts(User user);
}
