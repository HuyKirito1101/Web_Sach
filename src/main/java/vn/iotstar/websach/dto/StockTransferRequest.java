package vn.iotstar.websach.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class StockTransferRequest {
    private Long fromBranchId;
    private Long toBranchId;
    private Long bookCopyId;
    private Integer quantity;
    private String note;
}
