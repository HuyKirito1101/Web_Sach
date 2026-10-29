package vn.iotstar.websach.controller.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.BookCopy;
import vn.iotstar.websach.entity.enums.BookCondition;
import vn.iotstar.websach.entity.enums.BookCopyStatus;
import vn.iotstar.websach.service.BookCopyService;
import vn.iotstar.websach.service.BranchService;

import java.util.List;
import vn.iotstar.websach.util.ExceptionMessages;

@Controller
@RequestMapping("/admin/products")
@RequiredArgsConstructor
public class AdminProductController {

    private final BookCopyService bookCopyService;
    private final BranchService branchService;

    @GetMapping
    public String list(@RequestParam(required = false) String keyword,
                       @RequestParam(required = false) Long branchId,
                       @RequestParam(required = false) BookCondition condition,
                       @RequestParam(required = false) BookCopyStatus status,
                       Model model) {
        String normalizedKeyword = keyword == null ? "" : keyword.trim().toLowerCase();
        List<BookCopy> products = bookCopyService.findAllCopies().stream()
                .filter(p -> branchId == null || (p.getBranch() != null && branchId.equals(p.getBranch().getId())))
                .filter(p -> condition == null || p.getConditionRating() == condition)
                .filter(p -> status == null || p.getStatus() == status)
                .filter(p -> normalizedKeyword.isEmpty()
                        || (p.getBook() != null && p.getBook().getTitle().toLowerCase().contains(normalizedKeyword))
                        || (p.getBook() != null && p.getBook().getIsbn() != null
                            && p.getBook().getIsbn().toLowerCase().contains(normalizedKeyword))
                        || (p.getSeller() != null && p.getSeller().getEmail().toLowerCase().contains(normalizedKeyword)))
                .toList();
        model.addAttribute("products", products);
        model.addAttribute("branches", branchService.findAllBranches());
        model.addAttribute("conditions", BookCondition.values());
        model.addAttribute("statuses", BookCopyStatus.values());
        model.addAttribute("keyword", keyword);
        model.addAttribute("selectedBranch", branchId);
        model.addAttribute("selectedCondition", condition);
        model.addAttribute("selectedStatus", status);
        return "admin/products/list";
    }

    @PostMapping("/{id}/update")
    public String update(@PathVariable Long id,
                         @RequestParam Double sellingPrice,
                         @RequestParam Integer quantity,
                         @RequestParam BookCopyStatus status,
                         RedirectAttributes redirect) {
        try {
            if (sellingPrice == null || sellingPrice < 0 || quantity == null || quantity < 0) {
                throw new IllegalArgumentException("Giá bán và số lượng không được âm.");
            }
            BookCopy product = bookCopyService.findById(id)
                    .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại."));
            product.setSellingPrice(sellingPrice);
            product.setQuantity(quantity);
            product.setStatus(quantity == 0 ? BookCopyStatus.SOLD : status);
            bookCopyService.saveCopy(product);
            redirect.addFlashAttribute("successMessage", "Đã cập nhật sản phẩm.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/admin/products";
    }

    @PostMapping("/{id}/toggle")
    public String toggle(@PathVariable Long id, RedirectAttributes redirect) {
        BookCopy product = bookCopyService.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Sản phẩm không tồn tại."));
        product.setStatus(product.getStatus() == BookCopyStatus.AVAILABLE
                ? BookCopyStatus.SOLD : BookCopyStatus.AVAILABLE);
        bookCopyService.saveCopy(product);
        redirect.addFlashAttribute("successMessage", "Đã đổi trạng thái sản phẩm.");
        return "redirect:/admin/products";
    }
}
