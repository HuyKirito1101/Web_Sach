package vn.iotstar.websach.dto;

import lombok.*;
import vn.iotstar.websach.entity.ShippingProvider;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VendorShipperDTO {
    private Long id;
    private String fullName;
    private String phone;
    private String email;
    private ShippingProvider shippingProvider;
    private boolean busy;
    private String busyOrderCode;
    private String busyStatus;
}
