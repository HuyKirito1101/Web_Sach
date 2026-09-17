package vn.iotstar.websach.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AssignShipperRequest {
    private Long orderId;
    private Long shipperId;
    private String note;
}
