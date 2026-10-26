package vn.iotstar.websach.controller.manager;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.Category;
import vn.iotstar.websach.service.CategoryService;

@Controller
@RequestMapping("/manager/categories")
@RequiredArgsConstructor
public class ManagerCategoryController {

    private final CategoryService categoryService;

    @GetMapping
    public String list(Model model) {
        model.addAttribute("categories", categoryService.findAllCategories());
        model.addAttribute("categoryForm", new Category());
        return "manager/categories/list";
    }

    @PostMapping("/save")
    public String save(@ModelAttribute Category category, RedirectAttributes redirect) {
        try {
            if (category.getName() == null || category.getName().isBlank()) {
                throw new IllegalArgumentException("Tên danh mục không được để trống.");
            }
            if (category.getId() == null) categoryService.saveCategory(category);
            else categoryService.updateCategory(category.getId(), category);
            redirect.addFlashAttribute("successMessage", "Đã lưu danh mục.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/manager/categories";
    }

    @PostMapping("/{id}/delete")
    public String delete(@PathVariable Long id, RedirectAttributes redirect) {
        try {
            categoryService.deleteCategory(id);
            redirect.addFlashAttribute("successMessage", "Đã ẩn danh mục.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/manager/categories";
    }
}
