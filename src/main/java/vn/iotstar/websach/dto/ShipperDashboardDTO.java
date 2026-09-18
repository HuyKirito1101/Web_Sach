package vn.iotstar.websach.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class ShipperDashboardDTO {
    private long total;
    private long assigned;
    private long inProgress;
    private long delivered;
    private long failed;
    private double totalCodCollected;
}
