package vn.iotstar.websach.controller.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.Category;
import vn.iotstar.websach.service.CategoryService;
import vn.iotstar.websach.util.ExceptionMessages;

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
    public String saveCategory(@ModelAttribute("categoryForm") Category category,
                               RedirectAttributes redirect) {
        try {
            if (category.getId() == null) {
                categoryService.saveCategory(category);
            } else {
                categoryService.updateCategory(category.getId(), category);
            }
            redirect.addFlashAttribute("successMessage", "Đã lưu danh mục.");
        } catch (RuntimeException ex) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
        }
        return "redirect:/admin/categories";
    }

    @PostMapping("/delete/{id}")
    public String deleteCategory(@PathVariable("id") Long id, RedirectAttributes redirect) {
        try {
            categoryService.deleteCategory(id);
            redirect.addFlashAttribute("successMessage", "Đã ẩn danh mục; dữ liệu sách cũ vẫn được giữ lại.");
        } catch (RuntimeException ex) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
        }
        return "redirect:/admin/categories";
    }
}
