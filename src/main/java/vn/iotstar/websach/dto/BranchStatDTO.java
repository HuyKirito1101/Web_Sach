package vn.iotstar.websach.dto;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class BranchStatDTO {
    private String branchName;
    private long totalCopiesInStock;
    private long totalOrders;
    private long pendingOrders;
    private Double totalBranchRevenue;
}
