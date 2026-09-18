package vn.iotstar.websach.controller.manager;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import vn.iotstar.websach.entity.*;
import vn.iotstar.websach.entity.enums.BookCondition;
import vn.iotstar.websach.repository.AuthorRepository;
import vn.iotstar.websach.repository.PublisherRepository;
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
    private final CategoryService categoryService;
    private final AuthorRepository authorRepository;
    private final PublisherRepository publisherRepository;
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

    @PostMapping("/create-master-book")
    public String createMasterBook(@RequestParam("title") String title,
                                   @RequestParam(value = "isbn", required = false) String isbn,
                                   @RequestParam(value = "authorName", required = false) String authorName,
                                   @RequestParam(value = "publisherName", required = false) String publisherName,
                                   @RequestParam(value = "publishYear", required = false) Integer publishYear,
                                   @RequestParam(value = "categoryId", required = false) Long categoryId,
                                   @RequestParam(value = "coverUrl", required = false) String coverUrl,
                                   @RequestParam(value = "coverFile", required = false) MultipartFile coverFile) {

        Category category = (categoryId != null) ? categoryService.findById(categoryId).orElse(null) : null;
        Author author = null;
        if (authorName != null && !authorName.trim().isEmpty()) {
            author = authorRepository.findByName(authorName.trim()).orElseGet(() ->
                    authorRepository.save(Author.builder().name(authorName.trim()).build())
            );
        }
        Publisher publisher = null;
        if (publisherName != null && !publisherName.trim().isEmpty()) {
            publisher = publisherRepository.findByName(publisherName.trim()).orElseGet(() ->
                    publisherRepository.save(Publisher.builder().name(publisherName.trim()).build())
            );
        }

        String finalCover = coverUrl;
        if (coverFile != null && !coverFile.isEmpty()) {
            finalCover = cloudinaryService.uploadFile(coverFile);
        }
        if (finalCover == null || finalCover.trim().isEmpty()) {
            finalCover = "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500&q=80";
        }

        Book book = Book.builder()
                .title(title)
                .isbn(isbn)
                .author(author)
                .publisher(publisher)
                .publishYear(publishYear)
                .category(category)
                .coverUrl(finalCover)
                .build();

        bookService.saveBook(book);
        return "redirect:/manager/books?bookAdded=true";
    }

    @GetMapping("/delete/{id}")
    public String deleteBookCopy(@PathVariable("id") Long id) {
        bookCopyService.deleteCopy(id);
        return "redirect:/manager/books?deleted";
    }
}
