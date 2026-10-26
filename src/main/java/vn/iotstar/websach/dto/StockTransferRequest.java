package vn.iotstar.websach.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class StockTransferRequest {
    @NotNull(message = "Chi nhánh nguồn không được để trống.")
    private Long fromBranchId;
    @NotNull(message = "Chi nhánh nhận không được để trống.")
    private Long toBranchId;
    @NotNull(message = "Sản phẩm điều chuyển không được để trống.")
    private Long bookCopyId;
    @NotNull(message = "Số lượng không được để trống.")
    @Min(value = 1, message = "Số lượng điều chuyển phải lớn hơn 0.")
    private Integer quantity;
    private String note;
}
