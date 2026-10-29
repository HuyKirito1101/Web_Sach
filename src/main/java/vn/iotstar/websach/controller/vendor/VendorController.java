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
import vn.iotstar.websach.dto.MasterBookRequest;
import vn.iotstar.websach.dto.VendorProductRequest;
import vn.iotstar.websach.dto.VendorRevenueAnalyticsDTO;
import vn.iotstar.websach.entity.*;
import vn.iotstar.websach.entity.enums.*;
import vn.iotstar.websach.service.*;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;
import vn.iotstar.websach.util.ExceptionMessages;

@Controller
@RequestMapping("/vendor")
@RequiredArgsConstructor
public class VendorController {
    private final VendorService vendorService;
    private final CategoryService categoryService;

    @ModelAttribute("vendorPendingOrdersCount")
    public long vendorPendingOrdersCount(Authentication auth) {
        if (auth == null || !auth.isAuthenticated()) return 0;
        try {
            Branch shop = vendorService.getShop(auth.getName());
            if (shop != null && shop.getStatus() == BranchStatus.ACTIVE) {
                return vendorService.getOrders(auth.getName(), OrderStatus.NEW).size();
            }
        } catch (Exception ignored) {}
        return 0;
    }

    @GetMapping({"", "/dashboard"})
    public String dashboard(Authentication auth,
                            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate from,
                            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate to,
                            @RequestParam(required = false) Integer chartYear,
                            @RequestParam(required = false) Integer chartMonth,
                            Model model) {
        Branch shop = vendorService.getShop(auth.getName());
        model.addAttribute("shop", shop);
        VendorRevenueAnalyticsDTO analytics;
        if (shop == null) {
            model.addAttribute("stats", VendorDashboardDTO.builder().build());
            model.addAttribute("topProducts", Collections.emptyList());
            model.addAttribute("recentOrders", Collections.emptyList());
            analytics = VendorRevenueAnalyticsDTO.builder()
                    .selectedYear(LocalDate.now().getYear())
                    .selectedMonth(LocalDate.now().getMonthValue())
                    .totalYearRevenue(0.0)
                    .yearlyTotalRevenue(0.0)
                    .currentMonthTotal(0.0)
                    .availableYears(List.of(LocalDate.now().getYear()))
                    .yearlyMonths(Collections.nCopies(12, 0.0))
                    .monthlyRevenues(Collections.nCopies(12, 0.0))
                    .monthlyData(Collections.emptyMap())
                    .dailyRevenuesByMonth(Collections.emptyMap())
                    .build();
        } else {
            model.addAttribute("stats", vendorService.getDashboard(auth.getName(), from, to));
            model.addAttribute("topProducts", vendorService.getTopProducts(auth.getName(), from, to));
            try {
                if (shop.getStatus() == BranchStatus.ACTIVE) {
                    List<Order> orders = vendorService.getOrders(auth.getName(), null);
                    model.addAttribute("recentOrders", orders.stream().limit(5).toList());
                } else {
                    model.addAttribute("recentOrders", Collections.emptyList());
                }
            } catch (Exception e) {
                model.addAttribute("recentOrders", Collections.emptyList());
            }
            analytics = vendorService.getRevenueAnalytics(auth.getName(), chartYear, chartMonth);
        }
        model.addAttribute("analytics", analytics);
        model.addAttribute("revenueAnalytics", analytics);
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
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/vendor/shop";
    }

    @GetMapping("/products")
    public String products(Authentication auth, Model model) {
        java.util.List<BookCopy> vendorProducts = vendorService.getProducts(auth.getName());

        model.addAttribute("products", vendorProducts);
        model.addAttribute("allBooks", vendorService.getProductCatalog(auth.getName()));
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
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/vendor/products";
    }

    @PostMapping("/create-master-book")
    public String createMasterBook(Authentication auth,
                                   @RequestParam("title") String title,
                                   @RequestParam(value = "sellingPrice", required = false) Double sellingPrice,
                                   @RequestParam(value = "purchasePrice", required = false) Double purchasePrice,
                                   @RequestParam(value = "conditionRating", required = false) BookCondition conditionRating,
                                   @RequestParam(value = "quantity", required = false) Integer quantity,
                                   @RequestParam(value = "note", required = false) String note,
                                   @RequestParam(value = "isbn", required = false) String isbn,
                                   @RequestParam(value = "authorName", required = false) String authorName,
                                   @RequestParam(value = "publisherName", required = false) String publisherName,
                                   @RequestParam(value = "publishYear", required = false) Integer publishYear,
                                   @RequestParam(value = "categoryId", required = false) Long categoryId,
                                   @RequestParam(value = "coverUrl", required = false) String coverUrl,
                                   @RequestParam(value = "coverFile", required = false) MultipartFile coverFile,
                                   RedirectAttributes redirect) {
        try {
            vendorService.createMasterBookProduct(auth.getName(), MasterBookRequest.builder()
                    .title(title)
                    .isbn(isbn)
                    .authorName(authorName)
                    .publisherName(publisherName)
                    .publishYear(publishYear)
                    .categoryId(categoryId)
                    .coverUrl(coverUrl)
                    .sellingPrice(sellingPrice)
                    .purchasePrice(purchasePrice)
                    .conditionRating(conditionRating)
                    .quantity(quantity)
                    .note(note)
                    .build(), coverFile);
            redirect.addFlashAttribute("successMessage", "Đã thêm đầu sách mới thành công");
        } catch (Exception e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/vendor/products";
    }

    @PostMapping("/products/{id}/toggle")
    public String toggleProduct(Authentication auth, @PathVariable Long id, RedirectAttributes redirect) {
        try {
            vendorService.hideProduct(auth.getName(), id);
            redirect.addFlashAttribute("successMessage", "Đã cập nhật trạng thái sản phẩm");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/vendor/products";
    }

    @PostMapping("/products/{id}/publish")
    public String publishProduct(Authentication auth, @PathVariable Long id, RedirectAttributes redirect) {
        try {
            vendorService.publishProduct(auth.getName(), id);
            redirect.addFlashAttribute("successMessage", "Đã đăng bán sản phẩm lên trang web thành công!");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/vendor/products";
    }

    @PostMapping("/products/{id}/unpublish")
    public String unpublishProduct(Authentication auth, @PathVariable Long id, RedirectAttributes redirect) {
        try {
            vendorService.unpublishProduct(auth.getName(), id);
            redirect.addFlashAttribute("successMessage", "Đã gỡ sản phẩm khỏi trang web (chuyển sang Chưa đăng bán)");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/vendor/products";
    }

    @PostMapping("/products/{id}/delete")
    public String deleteProduct(Authentication auth, @PathVariable Long id, RedirectAttributes redirect) {
        try {
            vendorService.deleteProduct(auth.getName(), id);
            redirect.addFlashAttribute("successMessage", "Đã gỡ bán và xóa vĩnh viễn sản phẩm khỏi gian hàng.");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/vendor/products";
    }

    @GetMapping("/returns")
    public String returns(Authentication auth, Model model) {
        List<Order> returnOrders = vendorService.getReturnOrders(auth.getName());
        model.addAttribute("orders", returnOrders);
        model.addAttribute("shippers", vendorService.getBranchShippers(auth.getName()));
        model.addAttribute("assignments", vendorService.getReturnAssignments(auth.getName(), returnOrders));
        return "vendor/returns/list";
    }

    @PostMapping("/orders/{id}/assign-shipper")
    public String assignShipper(Authentication auth, @PathVariable Long id,
                                @RequestParam Long shipperId,
                                @RequestParam(required = false) String note,
                                @RequestParam(required = false) String redirectUrl,
                                RedirectAttributes redirect) {
        try {
            vendorService.assignShipper(auth.getName(), id, shipperId, note);
            redirect.addFlashAttribute("successMessage", "Đã phân công Shipper lấy đơn thành công! (Chờ Shipper xác nhận)");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return (redirectUrl != null && !redirectUrl.isBlank()) ? "redirect:" + redirectUrl : "redirect:/vendor/orders";
    }

    @PostMapping("/orders/{id}/revoke-shipper")
    public String revokeShipper(Authentication auth, @PathVariable Long id,
                                @RequestParam(required = false) String redirectUrl,
                                RedirectAttributes redirect) {
        try {
            vendorService.revokeAssignment(auth.getName(), id);
            redirect.addFlashAttribute("successMessage", "Đã thu hồi phân công Shipper thành công!");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return (redirectUrl != null && !redirectUrl.isBlank()) ? "redirect:" + redirectUrl : "redirect:/vendor/orders";
    }

    @PostMapping("/orders/{id}/confirm-return")
    public String confirmReturn(Authentication auth, @PathVariable Long id,
                                @RequestParam(required = false) String redirectUrl,
                                RedirectAttributes redirect) {
        try {
            vendorService.confirmReturnReceived(auth.getName(), id);
            redirect.addFlashAttribute("successMessage", "Đã xác nhận nhận lại sách hoàn trả và phục hồi số lượng tồn kho!");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return (redirectUrl != null && !redirectUrl.isBlank()) ? "redirect:" + redirectUrl : "redirect:/vendor/orders";
    }

    @PostMapping("/orders/{id}/approve-refund")
    public String approveRefund(Authentication auth, @PathVariable Long id,
                                @RequestParam(required = false) String redirectUrl,
                                RedirectAttributes redirect) {
        try {
            vendorService.approveRefund(auth.getName(), id);
            redirect.addFlashAttribute("successMessage", "Đã hoàn tất thủ tục hoàn tiền cho khách hàng và thanh toán phí cho Shipper!");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return (redirectUrl != null && !redirectUrl.isBlank()) ? "redirect:" + redirectUrl : "redirect:/vendor/orders";
    }

    @GetMapping("/orders")
    public String orders(Authentication auth, @RequestParam(required = false) OrderStatus status, Model model) {
        List<Order> allOrders = vendorService.getOrders(auth.getName(), null);
        List<Order> orders = (status != null)
                ? allOrders.stream().filter(o -> o.getOrderStatus() == status).toList()
                : allOrders;

        long newCount = allOrders.stream().filter(o -> o.getOrderStatus() == OrderStatus.NEW).count();
        long awaitingMomoCount = allOrders.stream()
                .filter(o -> o.getPaymentMethod() == PaymentMethod.MOMO && o.getPaymentStatus() == PaymentStatus.AWAITING_CONFIRMATION)
                .count();
        long processingCount = allOrders.stream()
                .filter(o -> o.getOrderStatus() == OrderStatus.CONFIRMED || o.getOrderStatus() == OrderStatus.PACKING)
                .count();
        long readyForPickupCount = allOrders.stream()
                .filter(o -> o.getOrderStatus() == OrderStatus.READY_FOR_PICKUP)
                .count();
        long deliveredCount = allOrders.stream()
                .filter(o -> o.getOrderStatus() == OrderStatus.DELIVERED)
                .count();
        long returnsCount = allOrders.stream()
                .filter(o -> o.getOrderStatus() == OrderStatus.RETURN_REQUESTED || o.getOrderStatus() == OrderStatus.RETURNED || o.getOrderStatus() == OrderStatus.REFUNDED)
                .count();

        model.addAttribute("orders", orders);
        model.addAttribute("totalCount", allOrders.size());
        model.addAttribute("newCount", newCount);
        model.addAttribute("awaitingMomoCount", awaitingMomoCount);
        model.addAttribute("processingCount", processingCount);
        model.addAttribute("readyForPickupCount", readyForPickupCount);
        model.addAttribute("deliveredCount", deliveredCount);
        model.addAttribute("returnsCount", returnsCount);
        model.addAttribute("statuses", OrderStatus.values());
        model.addAttribute("selectedStatus", status);
        model.addAttribute("shippers", vendorService.getBranchShippers(auth.getName()));
        model.addAttribute("assignments", vendorService.getOrderAssignments(auth.getName(), orders));
        return "vendor/orders/list";
    }

    @GetMapping("/orders/{id}")
    public String orderDetail(Authentication auth, @PathVariable Long id, Model model) {
        model.addAttribute("order", vendorService.getOrder(auth.getName(), id));
        model.addAttribute("items", vendorService.getOrderItems(auth.getName(), id));
        vendorService.getOrderAssignment(auth.getName(), id)
                .ifPresent(assignment -> model.addAttribute("assignment", assignment));
        return "vendor/orders/detail";
    }

    @PostMapping("/orders/{id}/status")
    public String updateOrder(Authentication auth, @PathVariable Long id,
                              @RequestParam OrderStatus status, RedirectAttributes redirect) {
        try {
            Order updated = vendorService.updateOrderStatus(auth.getName(), id, status);
            if (updated.getPaymentMethod() == PaymentMethod.MOMO && status == OrderStatus.CONFIRMED && updated.getPaymentStatus() == PaymentStatus.PAID) {
                redirect.addFlashAttribute("successMessage", "Đã xác nhận thanh toán MoMo và duyệt đơn hàng #" + updated.getOrderCode() + " thành công!");
            } else if (status == OrderStatus.CONFIRMED) {
                redirect.addFlashAttribute("successMessage", "Đã xác nhận duyệt đơn hàng #" + updated.getOrderCode() + " thành công!");
            } else if (status == OrderStatus.CANCELLED) {
                redirect.addFlashAttribute("successMessage", "Đã hủy đơn hàng #" + updated.getOrderCode() + " thành công!");
            } else {
                redirect.addFlashAttribute("successMessage", "Đã cập nhật đơn hàng #" + updated.getOrderCode() + " sang trạng thái " + status.getDisplayName());
            }
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/vendor/orders";
    }

    @PostMapping("/orders/{id}/confirm-momo-payment")
    public String confirmMomoPayment(Authentication auth, @PathVariable Long id,
                                     RedirectAttributes redirect) {
        try {
            Order updated = vendorService.confirmManualMomoPayment(auth.getName(), id);
            redirect.addFlashAttribute("successMessage", "Đã xác nhận nhận được tiền MoMo cho đơn hàng #" + updated.getOrderCode() + ".");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
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
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/vendor/promotions";
    }

    @PostMapping("/promotions/{id}/delete")
    public String deletePromotion(Authentication auth, @PathVariable Long id, RedirectAttributes redirect) {
        try {
            vendorService.deletePromotion(auth.getName(), id);
            redirect.addFlashAttribute("successMessage", "Đã xóa chương trình khuyến mãi");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/vendor/promotions";
    }

    @GetMapping("/sell-requests")
    public String sellRequests(Authentication auth, @RequestParam(required = false) SellRequestStatus status, Model model) {
        List<SellRequest> requests = vendorService.getSellRequests(auth.getName(), status);
        model.addAttribute("requests", requests);
        model.addAttribute("statuses", SellRequestStatus.values());
        model.addAttribute("selectedStatus", status);
        model.addAttribute("shippers", vendorService.getBranchShippers(auth.getName()));

        model.addAttribute("assignments", vendorService.getSellRequestAssignments(auth.getName(), requests));
        model.addAttribute("myQuotes", vendorService.getSellRequestQuotes(auth.getName(), requests));

        // Đếm số lượng theo trạng thái cho dashboard
        List<SellRequest> allVisible = vendorService.getSellRequests(auth.getName(), null);
        long totalCount = allVisible.size();
        long pendingCount = allVisible.stream().filter(r -> r.getStatus() == SellRequestStatus.PENDING).count();
        long inspectingCount = allVisible.stream().filter(r -> r.getStatus() == SellRequestStatus.INSPECTING || r.getStatus() == SellRequestStatus.QUOTED).count();
        long acceptedCount = allVisible.stream().filter(r -> r.getStatus() == SellRequestStatus.ACCEPTED).count();
        long completedCount = allVisible.stream().filter(r -> r.getStatus() == SellRequestStatus.COMPLETED).count();

        model.addAttribute("totalCount", totalCount);
        model.addAttribute("pendingCount", pendingCount);
        model.addAttribute("inspectingCount", inspectingCount);
        model.addAttribute("acceptedCount", acceptedCount);
        model.addAttribute("completedCount", completedCount);

        return "vendor/sell-requests/list";
    }

    @PostMapping("/sell-requests/{id}/assign-shipper")
    public String assignSellRequestShipper(Authentication auth, @PathVariable Long id,
                                          @RequestParam Long shipperId,
                                          @RequestParam(required = false) String note,
                                          RedirectAttributes redirect) {
        try {
            vendorService.assignSellRequestShipper(auth.getName(), id, shipperId, note);
            redirect.addFlashAttribute("successMessage", "Đã phân công Shipper lấy sách thu mua thành công! (Chờ Shipper nhận đơn)");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/vendor/sell-requests";
    }

    @PostMapping("/sell-requests/{id}/revoke-shipper")
    public String revokeSellRequestShipper(Authentication auth, @PathVariable Long id,
                                           RedirectAttributes redirect) {
        try {
            vendorService.revokeSellRequestAssignment(auth.getName(), id);
            redirect.addFlashAttribute("successMessage", "Đã thu hồi phân công Shipper thành công!");
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/vendor/sell-requests";
    }

    @PostMapping("/sell-requests/{id}/status")
    public String updateSellRequest(Authentication auth, @PathVariable Long id,
                                    @RequestParam SellRequestStatus status,
                                    @RequestParam(required = false) Double offeredTotal,
                                    @RequestParam(required = false) String staffNote,
                                    RedirectAttributes redirect) {
        try {
            vendorService.updateSellRequest(auth.getName(), id, status, offeredTotal, staffNote);
            if (status == SellRequestStatus.COMPLETED) {
                redirect.addFlashAttribute("successMessage", "Đã xác nhận nhận sách về kho và nhập kho bán thành công!");
            } else {
                redirect.addFlashAttribute("successMessage", "Đã cập nhật yêu cầu thu mua thành công");
            }
        } catch (RuntimeException e) {
            redirect.addFlashAttribute("errorMessage", ExceptionMessages.userMessage(e));
        }
        return "redirect:/vendor/sell-requests";
    }
}
