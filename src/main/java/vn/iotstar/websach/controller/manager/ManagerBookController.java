package vn.iotstar.websach.controller.manager;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import vn.iotstar.websach.entity.Book;
import vn.iotstar.websach.entity.BookCopy;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.BookCondition;
import vn.iotstar.websach.service.*;

import java.util.List;

@Controller
@RequestMapping("/manager/books")
@RequiredArgsConstructor
public class ManagerBookController {

    private final BookCopyService bookCopyService;
    private final BookService bookService;
    private final UserService userService;
    private final BranchService branchService;
    private final CloudinaryService cloudinaryService;

    @GetMapping
    public String listBranchBooks(@RequestParam(value = "condition", required = false) String conditionStr,
                                  Authentication authentication,
                                  Model model) {
        String email = authentication.getName();
        User manager = userService.findByEmail(email).orElse(null);
        Long branchId = (manager != null && manager.getBranch() != null) ? manager.getBranch().getId() : 1L;

        BookCondition condition = null;
        if (conditionStr != null && !conditionStr.isEmpty()) {
            condition = BookCondition.valueOf(conditionStr);
        }

        List<BookCopy> copies = bookCopyService.filterBranchCopies(branchId, condition);
        model.addAttribute("copies", copies);
        model.addAttribute("allBooks", bookService.findAllBooks());
        model.addAttribute("conditions", BookCondition.values());
        model.addAttribute("copyForm", new BookCopy());
        model.addAttribute("selectedCondition", conditionStr);
        return "manager/books/list";
    }

    @PostMapping("/save")
    public String saveBookCopy(@ModelAttribute("copyForm") BookCopy bookCopy,
                               @RequestParam("bookId") Long bookId,
                               @RequestParam(value = "imageFile", required = false) MultipartFile imageFile,
                               Authentication authentication) {
        String email = authentication.getName();
        User manager = userService.findByEmail(email).orElse(null);
        Long branchId = (manager != null && manager.getBranch() != null) ? manager.getBranch().getId() : 1L;

        Book book = bookService.findById(bookId).orElseThrow(() -> new RuntimeException("Đầu sách không tồn tại"));
        Branch branch = branchService.findById(branchId).orElseThrow(() -> new RuntimeException("Chi nhánh không tồn tại"));

        bookCopy.setBook(book);
        bookCopy.setBranch(branch);

        if (imageFile != null && !imageFile.isEmpty()) {
            String imageUrl = cloudinaryService.uploadFile(imageFile);
            bookCopy.setImageUrl(imageUrl);
        }

        if (bookCopy.getId() == null) {
            bookCopyService.saveCopy(bookCopy);
        } else {
            bookCopyService.updateCopy(bookCopy.getId(), bookCopy);
        }

        return "redirect:/manager/books?success";
    }

    @GetMapping("/delete/{id}")
    public String deleteBookCopy(@PathVariable("id") Long id) {
        bookCopyService.deleteCopy(id);
        return "redirect:/manager/books?deleted";
    }
}
