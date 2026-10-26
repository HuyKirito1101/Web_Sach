package vn.iotstar.websach.service;

import org.springframework.web.multipart.MultipartFile;
import vn.iotstar.websach.dto.ProductSalesDTO;
import vn.iotstar.websach.dto.VendorDashboardDTO;
import vn.iotstar.websach.dto.VendorProductRequest;
import vn.iotstar.websach.dto.VendorRevenueAnalyticsDTO;
import vn.iotstar.websach.dto.VendorShipperDTO;
import vn.iotstar.websach.entity.*;
import vn.iotstar.websach.entity.enums.OrderStatus;
import vn.iotstar.websach.entity.enums.SellRequestStatus;

import java.time.LocalDate;
import java.util.List;

public interface VendorService {
    Branch getShop(String vendorEmail);
    Branch saveShop(String vendorEmail, Branch details, MultipartFile logo, MultipartFile cover);
    List<BookCopy> getProducts(String vendorEmail);
    BookCopy saveProduct(String vendorEmail, VendorProductRequest request, MultipartFile imageFile);
    void hideProduct(String vendorEmail, Long productId);
    void publishProduct(String vendorEmail, Long productId);
    void unpublishProduct(String vendorEmail, Long productId);
    void deleteProduct(String vendorEmail, Long productId);
    List<Order> getOrders(String vendorEmail, OrderStatus status);
    Order getOrder(String vendorEmail, Long orderId);
    List<OrderItem> getOrderItems(String vendorEmail, Long orderId);
    Order updateOrderStatus(String vendorEmail, Long orderId, OrderStatus target);
    List<Promotion> getPromotions(String vendorEmail);
    Promotion savePromotion(String vendorEmail, Promotion promotion);
    void deletePromotion(String vendorEmail, Long promotionId);
    VendorDashboardDTO getDashboard(String vendorEmail, LocalDate from, LocalDate to);
    List<ProductSalesDTO> getTopProducts(String vendorEmail, LocalDate from, LocalDate to);
    VendorRevenueAnalyticsDTO getRevenueAnalytics(String vendorEmail, Integer year, Integer month);
    List<SellRequest> getSellRequests(String vendorEmail, SellRequestStatus status);
    SellRequest updateSellRequest(String vendorEmail, Long requestId, SellRequestStatus status,
                                  Double offeredTotal, String staffNote);
    DeliveryAssignment assignSellRequestShipper(String vendorEmail, Long requestId, Long shipperId, String note);
    DeliveryAssignment revokeSellRequestAssignment(String vendorEmail, Long requestId);
    List<VendorShipperDTO> getBranchShippers(String vendorEmail);
    DeliveryAssignment assignShipper(String vendorEmail, Long orderId, Long shipperId, String note);
    DeliveryAssignment revokeAssignment(String vendorEmail, Long orderId);
    DeliveryAssignment autoAssignBranchShipper(Order order, User assignedBy);
    List<Order> getReturnOrders(String vendorEmail);
    Order confirmReturnReceived(String vendorEmail, Long orderId);
    Order approveRefund(String vendorEmail, Long orderId);
}
