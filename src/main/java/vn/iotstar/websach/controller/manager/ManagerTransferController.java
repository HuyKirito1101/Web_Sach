package vn.iotstar.websach.controller.manager;

import lombok.RequiredArgsConstructor;
import jakarta.validation.Valid;
import org.springframework.validation.BindingResult;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import vn.iotstar.websach.dto.StockTransferRequest;
import vn.iotstar.websach.entity.StockTransfer;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.service.BookCopyService;
import vn.iotstar.websach.service.BranchService;
import vn.iotstar.websach.service.StockTransferService;
import vn.iotstar.websach.service.UserService;

import java.util.List;
import java.util.Collections;
import vn.iotstar.websach.util.ExceptionMessages;

@Controller
@RequestMapping("/manager/transfers")
@RequiredArgsConstructor
public class ManagerTransferController {

    private final StockTransferService stockTransferService;
    private final BranchService branchService;
    private final BookCopyService bookCopyService;
    private final UserService userService;

    @GetMapping
    public String listTransfers(Authentication authentication, Model model) {
        String email = authentication.getName();
        User manager = userService.findByEmail(email).orElse(null);
        Long branchId = (manager != null && manager.getBranch() != null) ? manager.getBranch().getId() : null;

        if (branchId == null) {
            model.addAttribute("errorMessage", "Tài khoản Manager chưa được gán chi nhánh. Vui lòng liên hệ Admin.");
            model.addAttribute("transfers", Collections.emptyList());
            model.addAttribute("branches", branchService.findAllBranches());
            model.addAttribute("copies", Collections.emptyList());
            model.addAttribute("currentBranchId", null);
            model.addAttribute("transferForm", new StockTransferRequest());
            return "manager/transfers/list";
        }

        List<StockTransfer> transfers = stockTransferService.findTransfersByBranch(branchId);
        model.addAttribute("transfers", transfers);
        model.addAttribute("branches", branchService.findAllBranches());
        model.addAttribute("copies", bookCopyService.findCopiesByBranch(branchId));
        model.addAttribute("currentBranchId", branchId);
        model.addAttribute("transferForm", new StockTransferRequest());
        return "manager/transfers/list";
    }

    @PostMapping("/create")
    public String createTransfer(@Valid @ModelAttribute("transferForm") StockTransferRequest request,
                                 BindingResult bindingResult,
                                 Authentication authentication,
                                 RedirectAttributes redirect) {
        try {
            if (bindingResult.hasErrors()) {
                throw new IllegalArgumentException(bindingResult.getAllErrors().getFirst().getDefaultMessage());
            }
            stockTransferService.createTransferRequest(request, authentication.getName());
            redirect.addFlashAttribute("successMessage", "Đã tạo yêu cầu điều chuyển.");
        } catch (RuntimeException ex) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
        }
        return "redirect:/manager/transfers";
    }

    @PostMapping("/approve/{id}")
    public String approveTransfer(@PathVariable("id") Long id, Authentication authentication,
                                  RedirectAttributes redirect) {
        try {
            stockTransferService.approveTransfer(id, authentication.getName());
            redirect.addFlashAttribute("successMessage", "Đã duyệt và xuất kho điều chuyển.");
        } catch (RuntimeException ex) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
        }
        return "redirect:/manager/transfers";
    }

    @PostMapping("/reject/{id}")
    public String rejectTransfer(@PathVariable("id") Long id, Authentication authentication,
                                 RedirectAttributes redirect) {
        try {
            stockTransferService.rejectTransfer(id, authentication.getName());
            redirect.addFlashAttribute("successMessage", "Đã từ chối yêu cầu điều chuyển.");
        } catch (RuntimeException ex) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
        }
        return "redirect:/manager/transfers";
    }

    @PostMapping("/complete/{id}")
    public String completeTransfer(@PathVariable("id") Long id, Authentication authentication,
                                   RedirectAttributes redirect) {
        try {
            stockTransferService.completeTransfer(id, authentication.getName());
            redirect.addFlashAttribute("successMessage", "Đã xác nhận nhận đủ sách điều chuyển.");
        } catch (RuntimeException ex) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(ex));
        }
        return "redirect:/manager/transfers";
    }
}
