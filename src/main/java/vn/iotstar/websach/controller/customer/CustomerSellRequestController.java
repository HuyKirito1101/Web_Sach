package vn.iotstar.websach.controller.customer;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.dto.SellRequestSubmission;
import vn.iotstar.websach.entity.SellRequest;
import vn.iotstar.websach.entity.SellRequestQuote;
import vn.iotstar.websach.service.CustomerSellRequestService;

import java.util.List;
import vn.iotstar.websach.util.ExceptionMessages;

@Controller
@RequestMapping("/sell-books")
@RequiredArgsConstructor
public class CustomerSellRequestController {

    private final CustomerSellRequestService customerSellRequestService;

    @GetMapping
    public String index(Authentication authentication, Model model) {
        model.addAttribute("branches", customerSellRequestService.getActiveBranches());
        if (isAuthenticated(authentication)) {
            String email = authentication.getName();
            model.addAttribute("currentUser", customerSellRequestService.getCustomer(email));
            model.addAttribute("myRequests", customerSellRequestService.getCustomerRequests(email));
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
        if (!isAuthenticated(authentication)) {
            redirect.addFlashAttribute("errorMessage", "Vui lòng đăng nhập để gửi yêu cầu thu mua sách cũ!");
            return "redirect:/auth/login";
        }
        try {
            SellRequest saved = customerSellRequestService.submitRequest(authentication.getName(),
                    SellRequestSubmission.builder()
                            .branchId(branchId)
                            .pickupAddress(pickupAddress)
                            .phone(phone)
                            .note(note)
                            .bookTitles(bookTitles)
                            .isbns(isbns)
                            .conditions(conditions)
                            .expectedPrices(expectedPrices)
                            .imageFiles(imageFiles)
                            .imageUrls(imageUrls)
                            .build());
            redirect.addFlashAttribute("successMessage", "Đã gửi yêu cầu thu mua sách cũ thành công! Đội ngũ "
                    + saved.getBranch().getName() + " sẽ thẩm định và gửi báo giá trong vòng 24h.");
        } catch (RuntimeException ex) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
        }
        return "redirect:/sell-books";
    }

    @PostMapping("/{id}/accept-quote")
    public String acceptQuote(Authentication authentication,
                              @PathVariable Long id,
                              @RequestParam Long quoteId,
                              RedirectAttributes redirect) {
        if (!isAuthenticated(authentication)) {
            return "redirect:/auth/login";
        }
        try {
            SellRequestQuote quote = customerSellRequestService.acceptQuote(authentication.getName(), id, quoteId);
            redirect.addFlashAttribute("successMessage", "Bạn đã đồng ý bán sách cho Shop '"
                    + quote.getVendorName() + "' với mức giá "
                    + String.format("%,.0f đ", quote.getOfferedPrice())
                    + "! Shop sẽ liên hệ và điều phối Shipper đến tận nhà bạn lấy sách.");
        } catch (RuntimeException ex) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
        }
        return "redirect:/sell-books";
    }

    @PostMapping("/{id}/accept")
    public String acceptOffer(Authentication authentication,
                              @PathVariable Long id,
                              RedirectAttributes redirect) {
        if (!isAuthenticated(authentication)) {
            return "redirect:/auth/login";
        }
        try {
            customerSellRequestService.acceptOffer(authentication.getName(), id);
            redirect.addFlashAttribute("successMessage", "Bạn đã đồng ý với mức giá đề nghị của cửa hàng! "
                    + "Cửa hàng sẽ liên hệ để thu nhận sách và thanh toán.");
        } catch (RuntimeException ex) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
        }
        return "redirect:/sell-books";
    }

    @PostMapping("/{id}/cancel")
    public String cancelRequest(Authentication authentication,
                                @PathVariable Long id,
                                RedirectAttributes redirect) {
        if (!isAuthenticated(authentication)) {
            return "redirect:/auth/login";
        }
        try {
            SellRequest cancelled = customerSellRequestService.cancelRequest(authentication.getName(), id);
            redirect.addFlashAttribute("successMessage", "Đã hủy yêu cầu thu mua sách #" + cancelled.getId());
        } catch (RuntimeException ex) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
        }
        return "redirect:/sell-books";
    }

    private boolean isAuthenticated(Authentication authentication) {
        return authentication != null && authentication.isAuthenticated()
                && !"anonymousUser".equals(authentication.getPrincipal());
    }
}
