package vn.iotstar.websach.dto;

import lombok.Builder;
import lombok.Getter;
import vn.iotstar.websach.entity.enums.BookCondition;

@Getter
@Builder
public class MasterBookRequest {
    private final String title;
    private final String isbn;
    private final String authorName;
    private final String publisherName;
    private final Integer publishYear;
    private final Long categoryId;
    private final String coverUrl;
    private final Double sellingPrice;
    private final Double purchasePrice;
    private final BookCondition conditionRating;
    private final Integer quantity;
    private final String note;
}
