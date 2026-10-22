package vn.iotstar.websach.controller.customer;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import vn.iotstar.websach.entity.Address;
import vn.iotstar.websach.entity.CartItem;
import vn.iotstar.websach.entity.Order;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.service.*;

import java.util.List;

@Controller
@RequestMapping("/checkout")
@RequiredArgsConstructor
public class CheckoutController {

    private final CartService cartService;
    private final CheckoutService checkoutService;
    private final CustomerProfileService profileService;
    private final ShippingProviderService shippingProviderService;
    private final UserService userService;
    private final AppDiscountService appDiscountService;
    private final vn.iotstar.websach.repository.OrderRepository orderRepository;

    @GetMapping
    public String showCheckoutPage(Authentication authentication, Model model) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        List<CartItem> cartItems = cartService.getCartItems(user);
        if (cartItems.isEmpty()) {
            return "redirect:/cart";
        }

        List<Address> addresses = profileService.getUserAddresses(user);
        Double subtotal = cartService.getCartTotal(user);

        model.addAttribute("cartItems", cartItems);
        model.addAttribute("addresses", addresses);
        model.addAttribute("shippingProviders", shippingProviderService.findAllProviders());
        model.addAttribute("subtotal", subtotal);
        model.addAttribute("user", user);
        // Danh sách mã giảm giá có thể dùng
        model.addAttribute("availableDiscounts", appDiscountService.findAllDiscounts()
                .stream().filter(d -> Boolean.TRUE.equals(d.getActive())).toList());

        return "customer/checkout";
    }

    @PostMapping("/place-order")
    public String placeOrder(@RequestParam(value = "addressId", required = false) Long addressId,
                             @RequestParam(value = "recipientName", required = false) String recipientName,
                             @RequestParam(value = "phone", required = false) String phone,
                             @RequestParam(value = "shippingAddress", required = false) String shippingAddress,
                             @RequestParam(value = "shippingProviderId", required = false) Long shippingProviderId,
                             @RequestParam(value = "voucherCode", required = false) String voucherCode,
                             @RequestParam(value = "paymentMethod", defaultValue = "COD") String paymentMethod,
                             @RequestParam(value = "note", required = false) String note,
                             Authentication authentication,
                             Model model) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        try {
            List<Order> orders = checkoutService.processCheckout(user, addressId, recipientName, phone, shippingAddress,
                    shippingProviderId, voucherCode, paymentMethod, note);

            String orderIdsStr = orders.stream().map(o -> o.getId().toString()).collect(java.util.stream.Collectors.joining(","));

            if ("VNPAY".equalsIgnoreCase(paymentMethod)) {
                return "redirect:/checkout/vnpay-demo?orderIds=" + orderIdsStr;
            }

            if ("MOMO".equalsIgnoreCase(paymentMethod)) {
                return "redirect:/checkout/momo-demo?orderIds=" + orderIdsStr;
            }

            if (orders.size() == 1) {
                return "redirect:/orders/" + orders.get(0).getId() + "?success=true";
            }
            return "redirect:/orders?multiSuccess=" + orders.size();
        } catch (Exception e) {
            model.addAttribute("errorMessage", e.getMessage());
            return showCheckoutPage(authentication, model);
        }
    }

    @GetMapping("/payment-callback")
    public String paymentCallback(@RequestParam(value = "orderId", required = false) Long orderId,
                                  @RequestParam(value = "orderIds", required = false) String orderIds,
                                  @RequestParam("status") String status,
                                  @RequestParam(value = "method", defaultValue = "VNPAY") String method,
                                  Authentication authentication,
                                  org.springframework.web.servlet.mvc.support.RedirectAttributes redirectAttributes) {
        User user = userService.findByEmail(authentication.getName()).orElse(null);
        if (user == null) return "redirect:/auth/login";

        List<Long> ids = new java.util.ArrayList<>();
        if (orderId != null) ids.add(orderId);
        if (orderIds != null && !orderIds.trim().isEmpty()) {
            for (String s : orderIds.split(",")) {
                try { ids.add(Long.parseLong(s.trim())); } catch (Exception ignored) {}
            }
        }

        if ("SUCCESS".equalsIgnoreCase(status)) {
            for (Long id : ids) {
                Order order = orderRepository.findById(id).orElse(null);
                if (order != null && order.getCustomer().getId().equals(user.getId())) {
                    order.setPaymentStatus(vn.iotstar.websach.entity.enums.PaymentStatus.PAID);
                    orderRepository.save(order);
                }
            }
            if (ids.size() == 1) {
                return "redirect:/orders/" + ids.get(0) + "?paymentSuccess=true";
            }
            redirectAttributes.addFlashAttribute("successMessage", "Thanh toán qua " + method + " thành công cho " + ids.size() + " đơn hàng!");
            return "redirect:/orders";
        } else {
            if (!ids.isEmpty()) {
                return "redirect:/orders/" + ids.get(0) + "?paymentFailed=true";
            }
            return "redirect:/orders";
        }
    }

    @GetMapping("/vnpay-callback")
    public String vnpayCallback(@RequestParam(value = "orderId", required = false) Long orderId,
                                @RequestParam(value = "orderIds", required = false) String orderIds,
                                @RequestParam(value = "status", defaultValue = "SUCCESS") String status,
                                Authentication authentication,
                                org.springframework.web.servlet.mvc.support.RedirectAttributes redirectAttributes) {
        return paymentCallback(orderId, orderIds, status, "VNPAY", authentication, redirectAttributes);
    }

    @GetMapping("/momo-callback")
    public String momoCallback(@RequestParam(value = "orderId", required = false) Long orderId,
                               @RequestParam(value = "orderIds", required = false) String orderIds,
                               @RequestParam(value = "status", defaultValue = "SUCCESS") String status,
                               Authentication authentication,
                               org.springframework.web.servlet.mvc.support.RedirectAttributes redirectAttributes) {
        return paymentCallback(orderId, orderIds, status, "MoMo", authentication, redirectAttributes);
    }

    @GetMapping("/vnpay-demo")
    public String vnpayDemo(@RequestParam(value = "orderId", required = false) Long orderId,
                            @RequestParam(value = "orderIds", required = false) String orderIds,
                            Model model) {
        String finalOrderIds = orderIds != null ? orderIds : (orderId != null ? orderId.toString() : "");
        model.addAttribute("orderId", orderId != null ? orderId : (orderIds != null ? orderIds.split(",")[0] : null));
        model.addAttribute("orderIds", finalOrderIds);
        return "customer/vnpay-demo";
    }

    @GetMapping("/momo-demo")
    public String momoDemo(@RequestParam(value = "orderId", required = false) Long orderId,
                           @RequestParam(value = "orderIds", required = false) String orderIds,
                           Model model) {
        String finalOrderIds = orderIds != null ? orderIds : (orderId != null ? orderId.toString() : "");
        model.addAttribute("orderId", orderId != null ? orderId : (orderIds != null ? orderIds.split(",")[0] : null));
        model.addAttribute("orderIds", finalOrderIds);
        return "customer/momo-demo";
    }
}
