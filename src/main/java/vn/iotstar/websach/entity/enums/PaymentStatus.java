package vn.iotstar.websach.entity.enums;

public enum PaymentStatus {
    PENDING("Chờ thanh toán"),
    AWAITING_CONFIRMATION("Khách báo đã chuyển"),
    PAID("Đã thanh toán"),
    FAILED("Thanh toán thất bại"),
    REFUNDED("Đã hoàn tiền");

    private final String displayName;

    PaymentStatus(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
