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
}
