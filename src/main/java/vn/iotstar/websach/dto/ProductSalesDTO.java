package vn.iotstar.websach.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class ProductSalesDTO {
    private Long productId;
    private String title;
    private long quantity;
    private double revenue;
}
