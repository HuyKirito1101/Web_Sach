package vn.iotstar.websach.controller.customer;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.entity.*;
import vn.iotstar.websach.entity.enums.BranchStatus;
import vn.iotstar.websach.entity.enums.SellRequestStatus;
import vn.iotstar.websach.repository.*;
import vn.iotstar.websach.service.CloudinaryService;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Controller
@RequestMapping("/sell-books")
@RequiredArgsConstructor
@Slf4j
public class CustomerSellRequestController {

    private final SellRequestRepository sellRequestRepository;
    private final SellRequestItemRepository sellRequestItemRepository;
    private final SellRequestQuoteRepository sellRequestQuoteRepository;
    private final BranchRepository branchRepository;
    private final UserRepository userRepository;
    private final SimpMessagingTemplate messagingTemplate;
    private final CloudinaryService cloudinaryService;

    @GetMapping
    public String index(Authentication authentication, Model model) {
        List<Branch> branches = branchRepository.findAll().stream()
                .filter(b -> b.getStatus() == BranchStatus.ACTIVE)
                .toList();
        model.addAttribute("branches", branches);

        if (authentication != null && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getPrincipal())) {
            userRepository.findByEmail(authentication.getName()).ifPresent(user -> {
                model.addAttribute("currentUser", user);
                List<SellRequest> myRequests = sellRequestRepository.findByCustomerIdOrderByCreatedAtDesc(user.getId());
                model.addAttribute("myRequests", myRequests);
            });
        }
        return "customer/sell-books/index";
    }

    @PostMapping
    public String submitRequest(Authentication authentication,
                                @RequestParam(value = "branchId", required = false) Long branchId,
                                @RequestParam String pickupAddress,
                                @RequestParam String phone,
                                @RequestParam(required = false) String note,
                                @RequestParam("bookTitle") List<String> bookTitles,
                                @RequestParam(value = "isbn", required = false) List<String> isbns,
                                @RequestParam("conditionDescription") List<String> conditions,
                                @RequestParam("expectedPrice") List<Double> expectedPrices,
                                @RequestParam(value = "imageFiles", required = false) List<MultipartFile> imageFiles,
                                @RequestParam(value = "imageUrl", required = false) List<String> imageUrls,
                                RedirectAttributes redirect) {
        if (authentication == null || !authentication.isAuthenticated()
                || "anonymousUser".equals(authentication.getPrincipal())) {
            redirect.addFlashAttribute("errorMessage", "Vui lòng đăng nhập để gửi yêu cầu thu mua sách cũ!");
            return "redirect:/auth/login";
        }

        User customer = userRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy thông tin tài khoản"));

        Branch branch = null;
        if (branchId != null) {
            branch = branchRepository.findById(branchId).orElse(null);
        }
        if (branch == null) {
            branch = branchRepository.findAll().stream()
                    .filter(b -> b.getStatus() == BranchStatus.ACTIVE)
                    .findFirst()
                    .orElse(null);
        }

        if (bookTitles == null || bookTitles.isEmpty()) {
            redirect.addFlashAttribute("errorMessage", "Vui lòng nhập ít nhất một cuốn sách cần bán!");
            return "redirect:/sell-books";
        }

        double totalExpected = 0.0;
        List<SellRequestItem> items = new ArrayList<>();

        SellRequest request = SellRequest.builder()
                .customer(customer)
                .branch(branch)
                .status(SellRequestStatus.PENDING)
                .note("Địa chỉ lấy sách tận nhà: " + pickupAddress.trim() + " (SĐT: " + phone.trim() + ")" +
                        (note != null && !note.isBlank() ? " | Ghi chú: " + note.trim() : ""))
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();

        for (int i = 0; i < bookTitles.size(); i++) {
            String title = bookTitles.get(i);
            if (title == null || title.isBlank()) continue;

            String isbn = (isbns != null && i < isbns.size()) ? isbns.get(i) : null;
            String cond = (conditions != null && i < conditions.size() && !conditions.get(i).isBlank())
                    ? conditions.get(i).trim() : "Bìa còn nguyên, trang đủ";
            Double price = (expectedPrices != null && i < expectedPrices.size() && expectedPrices.get(i) != null)
                    ? expectedPrices.get(i) : 0.0;

            String img = null;
            if (imageFiles != null && i < imageFiles.size()) {
                MultipartFile file = imageFiles.get(i);
                if (file != null && !file.isEmpty()) {
                    try {
                        img = cloudinaryService.uploadFile(file);
                    } catch (Exception e) {
                        log.error("Lỗi khi tải ảnh sách lên Cloudinary: {}", e.getMessage());
                    }
                }
            }
            if ((img == null || img.isBlank()) && (imageUrls != null && i < imageUrls.size())) {
                img = imageUrls.get(i);
            }
            if (img == null || img.isBlank()) {
                img = "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500&q=80";
            }

            totalExpected += price;

            SellRequestItem item = SellRequestItem.builder()
                    .sellRequest(request)
                    .bookTitle(title.trim())
                    .isbn(isbn)
                    .conditionDescription(cond)
                    .expectedPrice(price)
                    .imageUrl(img.trim())
                    .build();
            items.add(item);
        }

        if (items.isEmpty()) {
            redirect.addFlashAttribute("errorMessage", "Vui lòng nhập thông tin hợp lệ của ít nhất một cuốn sách!");
            return "redirect:/sell-books";
        }

        request.setExpectedTotal(totalExpected);
        request.setItems(items);

        SellRequest saved = sellRequestRepository.save(request);

        try {
            messagingTemplate.convertAndSend("/topic/orders", "Khách hàng " + customer.getFullName() + " vừa gửi yêu cầu thu mua sách #" + saved.getId() + " (" + items.size() + " cuốn) tại cơ sở " + branch.getName());
        } catch (Exception ignored) {}

        redirect.addFlashAttribute("successMessage", "Đã gửi yêu cầu thu mua sách cũ thành công! Đội ngũ " + branch.getName() + " sẽ thẩm định và gửi báo giá trong vòng 24h.");
        return "redirect:/sell-books";
    }

    @PostMapping("/{id}/accept-quote")
    public String acceptQuote(Authentication authentication,
                              @PathVariable Long id,
                              @RequestParam Long quoteId,
                              RedirectAttributes redirect) {
        if (authentication == null || !authentication.isAuthenticated()) return "redirect:/auth/login";
        User customer = userRepository.findByEmail(authentication.getName()).orElse(null);
        if (customer == null) return "redirect:/auth/login";

        SellRequest req = sellRequestRepository.findById(id).orElse(null);
        if (req == null || !Objects.equals(req.getCustomer().getId(), customer.getId())) {
            redirect.addFlashAttribute("errorMessage", "Không tìm thấy yêu cầu thu mua hợp lệ!");
            return "redirect:/sell-books";
        }

        SellRequestQuote chosenQuote = sellRequestQuoteRepository.findById(quoteId).orElse(null);
        if (chosenQuote == null || !Objects.equals(chosenQuote.getSellRequest().getId(), req.getId())) {
            redirect.addFlashAttribute("errorMessage", "Báo giá của Shop không hợp lệ hoặc đã hết hạn!");
            return "redirect:/sell-books";
        }

        chosenQuote.setStatus(vn.iotstar.websach.entity.enums.SellRequestQuoteStatus.ACCEPTED);
        chosenQuote.setUpdatedAt(LocalDateTime.now());
        sellRequestQuoteRepository.save(chosenQuote);

        // Các báo giá của các shop khác tự động chuyển sang REJECTED
        List<SellRequestQuote> allQuotes = sellRequestQuoteRepository.findBySellRequestIdOrderByCreatedAtDesc(req.getId());
        for (SellRequestQuote q : allQuotes) {
            if (!Objects.equals(q.getId(), chosenQuote.getId())) {
                q.setStatus(vn.iotstar.websach.entity.enums.SellRequestQuoteStatus.REJECTED);
                q.setUpdatedAt(LocalDateTime.now());
                sellRequestQuoteRepository.save(q);
            }
        }

        req.setBuyerVendor(chosenQuote.getVendor());
        req.setBranch(chosenQuote.getBranch() != null ? chosenQuote.getBranch() : (chosenQuote.getVendor().getBranch() != null ? chosenQuote.getVendor().getBranch() : req.getBranch()));
        req.setOfferedTotal(chosenQuote.getOfferedPrice());
        req.setStaffNote(chosenQuote.getNote());
        req.setStatus(SellRequestStatus.ACCEPTED);
        req.setUpdatedAt(LocalDateTime.now());
        sellRequestRepository.save(req);

        try {
            messagingTemplate.convertAndSend("/topic/orders", "Khách hàng " + customer.getFullName()
                    + " đã chấp nhận bán sách cho Shop " + chosenQuote.getVendorName()
                    + " (Yêu cầu #" + req.getId() + " - Giá: " + String.format("%,.0f đ", chosenQuote.getOfferedPrice()) + ")");
        } catch (Exception ignored) {}

        redirect.addFlashAttribute("successMessage", "Bạn đã đồng ý bán sách cho Shop '"
                + chosenQuote.getVendorName() + "' với mức giá "
                + String.format("%,.0f đ", chosenQuote.getOfferedPrice())
                + "! Shop sẽ liên hệ và điều phối Shipper đến tận nhà bạn lấy sách.");
        return "redirect:/sell-books";
    }

    @PostMapping("/{id}/accept")
    public String acceptOffer(Authentication authentication, @PathVariable Long id, RedirectAttributes redirect) {
        if (authentication == null) return "redirect:/auth/login";
        User customer = userRepository.findByEmail(authentication.getName()).orElse(null);
        if (customer == null) return "redirect:/auth/login";

        SellRequest req = sellRequestRepository.findById(id).orElse(null);
        if (req != null && Objects.equals(req.getCustomer().getId(), customer.getId()) && req.getStatus() == SellRequestStatus.QUOTED) {
            req.setStatus(SellRequestStatus.ACCEPTED);
            req.setUpdatedAt(LocalDateTime.now());
            if (req.getBuyerVendor() == null && req.getBranch() != null && req.getBranch().getOwner() != null) {
                req.setBuyerVendor(req.getBranch().getOwner());
            }
            sellRequestRepository.save(req);
            try {
                messagingTemplate.convertAndSend("/topic/orders", "Khách hàng đã đồng ý mức giá thu mua cho yêu cầu #" + req.getId());
            } catch (Exception ignored) {}
            redirect.addFlashAttribute("successMessage", "Bạn đã đồng ý với mức giá đề nghị của cửa hàng! Cửa hàng sẽ liên hệ để thu nhận sách và thanh toán.");
        }
        return "redirect:/sell-books";
    }

    @PostMapping("/{id}/cancel")
    public String cancelRequest(Authentication authentication, @PathVariable Long id, RedirectAttributes redirect) {
        if (authentication == null) return "redirect:/auth/login";
        User customer = userRepository.findByEmail(authentication.getName()).orElse(null);
        if (customer == null) return "redirect:/auth/login";

        SellRequest req = sellRequestRepository.findById(id).orElse(null);
        if (req != null && Objects.equals(req.getCustomer().getId(), customer.getId())
                && req.getStatus() != SellRequestStatus.COMPLETED) {
            req.setStatus(SellRequestStatus.CANCELLED);
            req.setUpdatedAt(LocalDateTime.now());
            sellRequestRepository.save(req);
            redirect.addFlashAttribute("successMessage", "Đã hủy yêu cầu thu mua sách #" + req.getId());
        }
        return "redirect:/sell-books";
    }
}
