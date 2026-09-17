package vn.iotstar.websach.controller.manager;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.iotstar.websach.dto.StockTransferRequest;
import vn.iotstar.websach.entity.StockTransfer;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.service.BookCopyService;
import vn.iotstar.websach.service.BranchService;
import vn.iotstar.websach.service.StockTransferService;
import vn.iotstar.websach.service.UserService;

import java.util.List;

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
        Long branchId = (manager != null && manager.getBranch() != null) ? manager.getBranch().getId() : 1L;

        List<StockTransfer> transfers = stockTransferService.findTransfersByBranch(branchId);
        model.addAttribute("transfers", transfers);
        model.addAttribute("branches", branchService.findAllBranches());
        model.addAttribute("copies", bookCopyService.findCopiesByBranch(branchId));
        model.addAttribute("currentBranchId", branchId);
        model.addAttribute("transferForm", new StockTransferRequest());
        return "manager/transfers/list";
    }

    @PostMapping("/create")
    public String createTransfer(@ModelAttribute("transferForm") StockTransferRequest request, Authentication authentication) {
        stockTransferService.createTransferRequest(request, authentication.getName());
        return "redirect:/manager/transfers?created";
    }

    @GetMapping("/approve/{id}")
    public String approveTransfer(@PathVariable("id") Long id, Authentication authentication) {
        stockTransferService.approveTransfer(id, authentication.getName());
        return "redirect:/manager/transfers?approved";
    }

    @GetMapping("/reject/{id}")
    public String rejectTransfer(@PathVariable("id") Long id, Authentication authentication) {
        stockTransferService.rejectTransfer(id, authentication.getName());
        return "redirect:/manager/transfers?rejected";
    }

    @GetMapping("/complete/{id}")
    public String completeTransfer(@PathVariable("id") Long id) {
        stockTransferService.completeTransfer(id);
        return "redirect:/manager/transfers?completed";
    }
}
