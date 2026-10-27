package vn.iotstar.websach.controller.manager;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.dto.MasterBookRequest;
import vn.iotstar.websach.entity.*;
import vn.iotstar.websach.entity.enums.BookCondition;
import vn.iotstar.websach.service.*;

import java.util.List;

@Controller
@RequestMapping("/manager/books")
@RequiredArgsConstructor
public class ManagerBookController {

    private final BookCopyService bookCopyService;
    private final BookService bookService;
    private final CategoryService categoryService;
    private final ManagerAccessService managerAccessService;

    @GetMapping
    public String listBranchBooks(@RequestParam(value = "condition", required = false) String conditionStr,
                                  Authentication authentication,
                                  Model model) {
        String email = authentication.getName();
        Long branchId = managerAccessService.requireManagedBranch(email).getId();

        BookCondition condition = null;
        if (conditionStr != null && !conditionStr.isEmpty()) {
            condition = BookCondition.valueOf(conditionStr);
        }

        List<BookCopy> copies = bookCopyService.filterBranchCopies(branchId, condition);
        model.addAttribute("copies", copies);
        model.addAttribute("allBooks", bookService.findAllBooks());
        model.addAttribute("categories", categoryService.findAllCategories());
        model.addAttribute("conditions", BookCondition.values());
        model.addAttribute("copyForm", new BookCopy());
        model.addAttribute("selectedCondition", conditionStr);
        return "manager/books/list";
    }

    @PostMapping("/save")
    public String saveBookCopy(@ModelAttribute("copyForm") BookCopy bookCopy,
                               @RequestParam("bookId") Long bookId,
                               @RequestParam(value = "imageFile", required = false) MultipartFile imageFile,
                               Authentication authentication,
                               RedirectAttributes redirect) {
        try {
            bookCopyService.saveManagedCopy(authentication.getName(), bookCopy, bookId, imageFile);
            redirect.addFlashAttribute("successMessage", "Đã lưu bản sách thành công.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }

        return "redirect:/manager/books";
    }

    @PostMapping("/create-master-book")
    public String createMasterBook(@RequestParam("title") String title,
                                   @RequestParam(value = "isbn", required = false) String isbn,
                                   @RequestParam(value = "authorName", required = false) String authorName,
                                   @RequestParam(value = "publisherName", required = false) String publisherName,
                                   @RequestParam(value = "publishYear", required = false) Integer publishYear,
                                   @RequestParam(value = "categoryId", required = false) Long categoryId,
                                   @RequestParam(value = "coverUrl", required = false) String coverUrl,
                                   @RequestParam(value = "coverFile", required = false) MultipartFile coverFile,
                                   RedirectAttributes redirect) {
        try {
            bookService.createMasterBook(MasterBookRequest.builder()
                    .title(title)
                    .isbn(isbn)
                    .authorName(authorName)
                    .publisherName(publisherName)
                    .publishYear(publishYear)
                    .categoryId(categoryId)
                    .coverUrl(coverUrl)
                    .build(), coverFile);
            redirect.addFlashAttribute("successMessage", "Đã thêm đầu sách mới thành công.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/manager/books";
    }

    @PostMapping("/delete/{id}")
    public String deleteBookCopy(@PathVariable("id") Long id, Authentication authentication) {
        bookCopyService.deleteManagedCopy(authentication.getName(), id);
        return "redirect:/manager/books?deleted";
    }
}
