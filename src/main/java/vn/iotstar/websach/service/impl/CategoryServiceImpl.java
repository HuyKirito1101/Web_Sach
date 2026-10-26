package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import vn.iotstar.websach.entity.Category;
import vn.iotstar.websach.repository.CategoryRepository;
import vn.iotstar.websach.service.CategoryService;

import java.util.List;
import java.util.Optional;
import java.text.Normalizer;
import java.util.Locale;

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
        validateAndNormalize(category);
        return categoryRepository.save(category);
    }

    @Override
    public Category updateCategory(Long id, Category details) {
        validateAndNormalize(details);
        Category cat = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Danh mục không tồn tại: " + id));
        cat.setName(details.getName());
        cat.setSlug(details.getSlug());
        cat.setDescription(details.getDescription());
        if (details.getActive() != null) {
            cat.setActive(details.getActive());
        }
        return categoryRepository.save(cat);
    }

    @Override
    public void deleteCategory(Long id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Danh mục không tồn tại."));
        category.setActive(false);
        categoryRepository.save(category);
    }

    private void validateAndNormalize(Category category) {
        if (category == null || category.getName() == null || category.getName().isBlank()
                || category.getName().trim().length() > 150) {
            throw new IllegalArgumentException("Tên danh mục phải có từ 1 đến 150 ký tự.");
        }
        category.setName(category.getName().trim());
        if (category.getSlug() == null || category.getSlug().isBlank()) {
            String slug = Normalizer.normalize(category.getName(), Normalizer.Form.NFD)
                    .replaceAll("\\p{M}", "")
                    .toLowerCase(Locale.ROOT)
                    .replaceAll("[^a-z0-9]+", "-")
                    .replaceAll("(^-|-$)", "");
            category.setSlug(slug);
        } else {
            category.setSlug(category.getSlug().trim().toLowerCase(Locale.ROOT));
        }
    }
}
