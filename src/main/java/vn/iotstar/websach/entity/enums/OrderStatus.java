package vn.iotstar.websach.entity.enums;

public enum OrderStatus {
    NEW("Đơn mới"),
    CONFIRMED("Đã xác nhận"),
    PACKING("Đang đóng gói"),
    READY_FOR_PICKUP("Chờ shipper lấy"),
    PICKED_UP("Đã lấy hàng"),
    SHIPPING("Đang giao hàng"),
    DELIVERED("Giao thành công"),
    CANCELLED("Đã hủy"),
    RETURN_REQUESTED("Yêu cầu đổi trả"),
    RETURNED("Đã nhận hàng hoàn"),
    REFUNDED("Đã hoàn tiền");

    private final String displayName;

    OrderStatus(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
