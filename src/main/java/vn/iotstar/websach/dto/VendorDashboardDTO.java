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
    private double deliveredRevenue;
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
