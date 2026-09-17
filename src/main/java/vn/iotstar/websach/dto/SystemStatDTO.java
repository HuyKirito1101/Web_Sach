package vn.iotstar.websach.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class SystemStatDTO {
    private long totalUsers;
    private long totalBranches;
    private long totalBooks;
    private long totalBookCopies;
    private long totalOrders;
    private Double totalRevenue;
    private Double totalAppCommission;
}
