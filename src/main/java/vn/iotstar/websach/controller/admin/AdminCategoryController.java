package vn.iotstar.websach.controller.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.iotstar.websach.entity.Category;
import vn.iotstar.websach.service.CategoryService;

@Controller
@RequestMapping("/admin/categories")
@RequiredArgsConstructor
public class AdminCategoryController {

    private final CategoryService categoryService;

    @GetMapping
    public String listCategories(Model model) {
        model.addAttribute("categories", categoryService.findAllCategories());
        model.addAttribute("categoryForm", new Category());
        return "admin/categories/list";
    }

    @PostMapping("/save")
    public String saveCategory(@ModelAttribute("categoryForm") Category category) {
        if (category.getId() == null) {
            categoryService.saveCategory(category);
        } else {
            categoryService.updateCategory(category.getId(), category);
        }
        return "redirect:/admin/categories?success";
    }

    @PostMapping("/delete/{id}")
    public String deleteCategory(@PathVariable("id") Long id) {
        categoryService.deleteCategory(id);
        return "redirect:/admin/categories?deleted";
    }
}
