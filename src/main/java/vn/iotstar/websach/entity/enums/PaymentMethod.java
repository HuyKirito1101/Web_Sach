package vn.iotstar.websach.entity.enums;

public enum PaymentMethod {
    COD("COD (Thanh toán khi nhận)"),
    VNPAY("VNPay"),
    MOMO("Ví MoMo");

    private final String displayName;

    PaymentMethod(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
