package vn.iotstar.websach.dto;

import lombok.Getter;
import lombok.Setter;
import vn.iotstar.websach.entity.enums.BookCondition;
import vn.iotstar.websach.entity.enums.BookCopyStatus;

@Getter
@Setter
public class VendorProductRequest {
    private Long id;
    private Long bookId;
    private BookCondition conditionRating;
    private Double purchasePrice;
    private Double sellingPrice;
    private Integer quantity;
    private BookCopyStatus status;
    private String note;
    private String imageUrl;
}
