package vn.iotstar.websach.service;

import vn.iotstar.websach.entity.Category;

import java.util.List;
import java.util.Optional;

public interface CategoryService {
    List<Category> findAllCategories();
    Optional<Category> findById(Long id);
    Category saveCategory(Category category);
    Category updateCategory(Long id, Category categoryDetails);
    void deleteCategory(Long id);
}
