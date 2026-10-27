package vn.iotstar.websach.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class VendorDashboardDTO {
    private long totalProducts;
    private long totalStock;
    private long newOrders;
    private long totalOrders;
    private double grossRevenue;              // Tổng doanh số bán sách trước khi giảm giá
    private double totalDiscount;             // Toàn bộ tiền khuyến mãi/voucher đã trừ vào thu nhập vendor
    private double deliveredRevenue;          // Doanh thu đơn hàng sau khi khấu trừ khuyến mãi/giảm giá
    private double commission;
    private double bookAcquisitionCost;       // Tiền trả khách khi mua sách cũ
    private double shippingAcquisitionCost;   // Tiền trả cho shipper khi thu gom sách cũ về kho
    private double totalAcquisitionExpense;   // Tổng chi phí thu mua (sách + shipper)
    private double returnShippingCost;        // Phí trả cho shipper khi thu hồi sách đổi trả về kho (đơn REFUNDED)
    private double refundedAmount;            // Tổng tiền đã hoàn trả cho khách hàng (đơn REFUNDED)

    public double getNetRevenue() {
        return deliveredRevenue - commission - totalAcquisitionExpense - returnShippingCost;
    }
}
