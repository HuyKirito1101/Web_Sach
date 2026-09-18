package vn.iotstar.websach.controller.vendor;

import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.dto.VendorDashboardDTO;
import vn.iotstar.websach.dto.VendorProductRequest;
import vn.iotstar.websach.entity.*;
import vn.iotstar.websach.entity.enums.*;
import vn.iotstar.websach.repository.AuthorRepository;
import vn.iotstar.websach.repository.PublisherRepository;
import vn.iotstar.websach.service.*;

import java.time.LocalDate;
import java.util.Collections;

@Controller
@RequestMapping("/vendor")
@RequiredArgsConstructor
public class VendorController {
    private final VendorService vendorService;
    private final BookService bookService;
    private final CategoryService categoryService;
    private final AuthorRepository authorRepository;
    private final PublisherRepository publisherRepository;
    private final CloudinaryService cloudinaryService;

    @GetMapping({"", "/dashboard"})
    public String dashboard(Authentication auth,
                            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
                            Model model) {
        Branch shop = vendorService.getShop(auth.getName());
        model.addAttribute("shop", shop);
        if (shop == null) {
            model.addAttribute("stats", VendorDashboardDTO.builder().build());
            model.addAttribute("topProducts", Collections.emptyList());
        } else {
            model.addAttribute("stats", vendorService.getDashboard(auth.getName(), from, to));
            model.addAttribute("topProducts", vendorService.getTopProducts(auth.getName(), from, to));
        }
        model.addAttribute("from", from);
        model.addAttribute("to", to);
        return "vendor/dashboard";
    }

    @GetMapping("/shop")
    public String shop(Authentication auth, Model model) {
        Branch shop = vendorService.getShop(auth.getName());
        model.addAttribute("shop", shop == null ? new Branch() : shop);
        model.addAttribute("hasShop", shop != null);
        return "vendor/shop";
    }

    @PostMapping("/shop")
    public String saveShop(Authentication auth, @ModelAttribute Branch shop,
                           @RequestParam(value = "logoFile", required = false) MultipartFile logo,
                           @RequestParam(value = "coverFile", required = false) MultipartFile cover,
                           RedirectAttributes redirect) {
        try {
            vendorService.saveShop(auth.getName(), shop, logo, cover);
            redirect.addFlashAttribute("successMessage", "Cập nhật thông tin shop thành công");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/vendor/shop";
    }

    @GetMapping("/products")
    public String products(Authentication auth, Model model) {
        model.addAttribute("products", vendorService.getProducts(auth.getName()));
        model.addAttribute("allBooks", bookService.findAllBooks());
        model.addAttribute("categories", categoryService.findAllCategories());
        model.addAttribute("conditions", BookCondition.values());
        model.addAttribute("statuses", BookCopyStatus.values());
        model.addAttribute("productForm", new VendorProductRequest());
        return "vendor/products/list";
    }

    @PostMapping("/products/save")
    public String saveProduct(Authentication auth, @ModelAttribute VendorProductRequest request,
                              @RequestParam(value = "imageFile", required = false) MultipartFile imageFile,
                              RedirectAttributes redirect) {
        try {
            vendorService.saveProduct(auth.getName(), request, imageFile);
            redirect.addFlashAttribute("successMessage", "Đã lưu sản phẩm");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/vendor/products";
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
            redirect.addFlashAttribute("successMessage", "Đã thêm đầu sách mới thành công");
        } catch (Exception e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/vendor/products";
    }

    @PostMapping("/products/{id}/toggle")
    public String toggleProduct(Authentication auth, @PathVariable Long id, RedirectAttributes redirect) {
        try {
            vendorService.hideProduct(auth.getName(), id);
            redirect.addFlashAttribute("successMessage", "Đã cập nhật trạng thái sản phẩm");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/vendor/products";
    }

    @GetMapping("/orders")
    public String orders(Authentication auth, @RequestParam(required = false) OrderStatus status, Model model) {
        model.addAttribute("orders", vendorService.getOrders(auth.getName(), status));
        model.addAttribute("statuses", OrderStatus.values());
        model.addAttribute("selectedStatus", status);
        return "vendor/orders/list";
    }

    @GetMapping("/orders/{id}")
    public String orderDetail(Authentication auth, @PathVariable Long id, Model model) {
        model.addAttribute("order", vendorService.getOrder(auth.getName(), id));
        model.addAttribute("items", vendorService.getOrderItems(auth.getName(), id));
        return "vendor/orders/detail";
    }

    @PostMapping("/orders/{id}/status")
    public String updateOrder(Authentication auth, @PathVariable Long id,
                              @RequestParam OrderStatus status, RedirectAttributes redirect) {
        try {
            vendorService.updateOrderStatus(auth.getName(), id, status);
            redirect.addFlashAttribute("successMessage", "Đã cập nhật trạng thái đơn hàng");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/vendor/orders";
    }

    @GetMapping("/promotions")
    public String promotions(Authentication auth, Model model) {
        model.addAttribute("promotions", vendorService.getPromotions(auth.getName()));
        model.addAttribute("promotionForm", new Promotion());
        return "vendor/promotions/list";
    }

    @PostMapping("/promotions/save")
    public String savePromotion(Authentication auth, @ModelAttribute Promotion promotion, RedirectAttributes redirect) {
        try {
            vendorService.savePromotion(auth.getName(), promotion);
            redirect.addFlashAttribute("successMessage", "Đã lưu chương trình khuyến mãi");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/vendor/promotions";
    }

    @PostMapping("/promotions/{id}/delete")
    public String deletePromotion(Authentication auth, @PathVariable Long id, RedirectAttributes redirect) {
        try {
            vendorService.deletePromotion(auth.getName(), id);
            redirect.addFlashAttribute("successMessage", "Đã xóa chương trình khuyến mãi");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/vendor/promotions";
    }

    @GetMapping("/sell-requests")
    public String sellRequests(Authentication auth, @RequestParam(required = false) SellRequestStatus status, Model model) {
        model.addAttribute("requests", vendorService.getSellRequests(auth.getName(), status));
        model.addAttribute("statuses", SellRequestStatus.values());
        model.addAttribute("selectedStatus", status);
        return "vendor/sell-requests/list";
    }

    @PostMapping("/sell-requests/{id}/status")
    public String updateSellRequest(Authentication auth, @PathVariable Long id,
                                    @RequestParam SellRequestStatus status,
                                    @RequestParam(required = false) Double offeredTotal,
                                    @RequestParam(required = false) String staffNote,
                                    RedirectAttributes redirect) {
        try {
            vendorService.updateSellRequest(auth.getName(), id, status, offeredTotal, staffNote);
            redirect.addFlashAttribute("successMessage", "Đã cập nhật yêu cầu thu mua");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", e.getMessage());
        }
        return "redirect:/vendor/sell-requests";
    }
}
