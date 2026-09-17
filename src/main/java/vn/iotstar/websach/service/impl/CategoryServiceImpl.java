package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import vn.iotstar.websach.entity.Category;
import vn.iotstar.websach.repository.CategoryRepository;
import vn.iotstar.websach.service.CategoryService;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {

    private final CategoryRepository categoryRepository;

    @Override
    public List<Category> findAllCategories() {
        return categoryRepository.findAll();
    }

    @Override
    public Optional<Category> findById(Long id) {
        return categoryRepository.findById(id);
    }

    @Override
    public Category saveCategory(Category category) {
        if (category.getSlug() == null || category.getSlug().isEmpty()) {
            category.setSlug(category.getName().toLowerCase().replaceAll("[^a-z0-9]", "-"));
        }
        return categoryRepository.save(category);
    }

    @Override
    public Category updateCategory(Long id, Category details) {
        Category cat = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Danh mục không tồn tại: " + id));
        cat.setName(details.getName());
        cat.setDescription(details.getDescription());
        if (details.getActive() != null) {
            cat.setActive(details.getActive());
        }
        return categoryRepository.save(cat);
    }

    @Override
    public void deleteCategory(Long id) {
        categoryRepository.deleteById(id);
    }
}
