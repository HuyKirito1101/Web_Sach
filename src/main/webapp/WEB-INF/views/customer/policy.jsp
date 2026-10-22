<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="../common/header.jsp">
    <jsp:param name="title" value="Chính Sách & Điều Khoản - Sách Cũ Việt"/>
</jsp:include>
<jsp:include page="../common/navbar.jsp"/>

<div class="container py-5">
    <div class="row g-4">
        <!-- Sidebar Navigation -->
        <div class="col-lg-3">
            <div class="card border-0 shadow-sm rounded-3 p-3 sticky-top" style="top: 20px;">
                <h6 class="fw-bold text-dark border-bottom pb-2 mb-3">
                    <i class="fa-solid fa-file-contract text-warning me-2"></i>Trung Tâm Chính Sách
                </h6>
                <div class="nav flex-column nav-pills gap-1">
                    <a href="/policies/terms" class="nav-link ${activePolicy == 'terms' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}">
                        <i class="fa-solid fa-scale-balanced me-2"></i>Điều khoản sử dụng
                    </a>
                    <a href="/policies/privacy" class="nav-link ${activePolicy == 'privacy' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}">
                        <i class="fa-solid fa-user-shield me-2"></i>Chính sách bảo mật
                    </a>
                    <a href="/policies/returns" class="nav-link ${activePolicy == 'returns' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}">
                        <i class="fa-solid fa-rotate-left me-2"></i>Chính sách đổi trả/hoàn tiền
                    </a>
                    <a href="/policies/guide" class="nav-link ${activePolicy == 'guide' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}">
                        <i class="fa-solid fa-circle-question me-2"></i>Hướng dẫn mua hàng
                    </a>
                    <a href="/policies/wholesale" class="nav-link ${activePolicy == 'wholesale' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}">
                        <i class="fa-solid fa-boxes-packing me-2"></i>Chính sách khách sỉ
                    </a>
                    <a href="/policies/about" class="nav-link ${activePolicy == 'about' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}">
                        <i class="fa-solid fa-building me-2"></i>Giới thiệu Sách Cũ Việt
                    </a>
                </div>
            </div>
        </div>

        <!-- Content Area -->
        <div class="col-lg-9">
            <div class="card border-0 shadow-sm rounded-3 p-4 bg-white">
                <c:choose>
                    <%-- 1. Điều khoản sử dụng --%>
                    <c:when test="${activePolicy == 'terms'}">
                        <h3 class="fw-bold mb-3 text-dark border-start border-4 border-warning ps-3">Điều Khoản Sử Dụng</h3>
                        <p class="text-muted small">Cập nhật lần cuối: Tháng 10/2026</p>
                        <hr>
                        <h5 class="fw-bold text-dark mt-3">1. Giới thiệu và Phạm vi áp dụng</h5>
                        <p>Chào mừng bạn đến với sàn giao dịch sách cũ trực tuyến <strong>Sách Cũ Việt</strong>. Khi truy cập và sử dụng dịch vụ trên nền tảng của chúng tôi, bạn đồng ý tuân thủ các quy định và điều khoản được nêu dưới đây.</p>

                        <h5 class="fw-bold text-dark mt-3">2. Tài khoản và Bảo mật</h5>
                        <p>Người dùng có trách nhiệm tự bảo vệ thông tin đăng nhập và mật khẩu cá nhân. Mọi hoạt động phát sinh từ tài khoản của bạn sẽ do bạn chịu hoàn toàn trách nhiệm.</p>

                        <h5 class="fw-bold text-dark mt-3">3. Quy định Đặt hàng &amp; Giao dịch</h5>
                        <p>Mỗi đơn hàng được tạo trên hệ thống biểu thị sự cam kết mua bán giữa người mua và các chi nhánh hoặc đối tác bán sách. Bạn có trách nhiệm cung cấp chính xác địa chỉ và số điện thoại nhận hàng.</p>

                        <h5 class="fw-bold text-dark mt-3">4. Quy định về Đánh giá và Bình luận</h5>
                        <p>Nhằm đảm bảo tính khách quan và trung thực, <strong>chỉ những khách hàng đã mua và nhận hàng thành công mới được quyền viết đánh giá</strong>. Nội dung đánh giá cần phản ánh đúng thực tế, có độ dài tối thiểu 50 ký tự và không chứa từ ngữ vi phạm thuần phong mỹ tục.</p>
                    </c:when>

                    <%-- 2. Chính sách bảo mật --%>
                    <c:when test="${activePolicy == 'privacy'}">
                        <h3 class="fw-bold mb-3 text-dark border-start border-4 border-warning ps-3">Chính Sách Bảo Mật Thông Tin</h3>
                        <p class="text-muted small">Cam kết bảo vệ dữ liệu khách hàng theo tiêu chuẩn an toàn</p>
                        <hr>
                        <h5 class="fw-bold text-dark mt-3">1. Thu thập thông tin cá nhân</h5>
                        <p>Chúng tôi chỉ thu thập các thông tin cần thiết phục vụ cho việc quản lý tài khoản, xử lý đơn hàng và giao sách, bao gồm: Họ tên, Email, Số điện thoại và Địa chỉ nhận hàng.</p>

                        <h5 class="fw-bold text-dark mt-3">2. Mục đích sử dụng thông tin</h5>
                        <p>- Xử lý đơn hàng, điều phối giao hàng qua các đối tác vận chuyển.<br>
                           - Gửi mã xác thực OTP phục vụ đăng ký tài khoản và khôi phục mật khẩu khi người dùng yêu cầu.<br>
                           - Hỗ trợ giải quyết khiếu nại, đổi trả và hoàn tiền nhanh chóng.</p>

                        <h5 class="fw-bold text-dark mt-3">3. Bảo mật giao dịch &amp; Thanh toán</h5>
                        <p>Mọi giao dịch thanh toán qua thẻ, quét mã QR (VNPAY, MoMo) đều được xử lý qua cổng bảo mật của nhà cung cấp dịch vụ thanh toán. Chúng tôi tuyệt đối không lưu giữ thông tin thẻ ngân hàng của người dùng.</p>
                    </c:when>

                    <%-- 3. Chính sách đổi trả / hoàn tiền --%>
                    <c:when test="${activePolicy == 'returns'}">
                        <h3 class="fw-bold mb-3 text-dark border-start border-4 border-warning ps-3">Chính Sách Đổi Trả &amp; Hoàn Tiền</h3>
                        <p class="text-muted small">Quy trình xử lý minh bạch: <code>DELIVERED → RETURN_REQUESTED → RETURNED → REFUNDED</code></p>
                        <hr>
                        <div class="alert alert-warning border-0 rounded-3 mb-4">
                            <i class="fa-solid fa-circle-exclamation me-2"></i>
                            <strong>Thời gian yêu cầu đổi trả:</strong> Trong vòng <strong>48 giờ</strong> kể từ thời điểm đơn hàng được cập nhật trạng thái <strong>Đã giao (DELIVERED)</strong>.
                        </div>

                        <h5 class="fw-bold text-dark mt-3">1. Các trường hợp được chấp nhận trả hàng</h5>
                        <ul>
                            <li>Sách bị giao sai đầu sách hoặc sai phiên bản so với đơn đặt hàng.</li>
                            <li>Tình trạng sách cũ thực tế rách nát, mất trang nghiêm trọng không đúng với mô tả (Condition Rating).</li>
                            <li>Sách bị ướt, hư hỏng trong quá trình vận chuyển.</li>
                        </ul>

                        <h5 class="fw-bold text-dark mt-3">2. Quy trình các bước trả hàng - hoàn tiền</h5>
                        <ol>
                            <li><strong>Khách hàng gửi yêu cầu:</strong> Vào mục <em>Chi tiết đơn hàng</em> đã nhận, bấm <strong>Yêu Cầu Trả Hàng / Hoàn Tiền</strong>, cung cấp lý do cụ thể. Đơn hàng chuyển sang trạng thái <code>RETURN_REQUESTED</code>.</li>
                            <li><strong>Kiểm duyệt &amp; Thu hồi sách:</strong> Quản lý chi nhánh tiếp nhận và điều phối thu hồi hàng hoặc tiếp nhận bưu phẩm hoàn. Khi hàng về kho, trạng thái chuyển thành <code>RETURNED</code> và tồn kho sách được hoàn trả tự động.</li>
                            <li><strong>Hoàn tiền:</strong> Quản trị viên / Quản lý duyệt hoàn tiền, đơn hàng hoàn tất chu trình ở trạng thái <code>REFUNDED</code>, tiền thanh toán được hoàn lại cho khách hàng.</li>
                        </ol>
                    </c:when>

                    <%-- 4. Hướng dẫn mua hàng --%>
                    <c:when test="${activePolicy == 'guide'}">
                        <h3 class="fw-bold mb-3 text-dark border-start border-4 border-warning ps-3">Hướng Dẫn Mua Hàng</h3>
                        <p class="text-muted small">Các bước đặt mua sách cũ nhanh chóng và thuận tiện</p>
                        <hr>
                        <div class="row g-3 my-2">
                            <div class="col-md-4">
                                <div class="p-3 border rounded-3 text-center h-100">
                                    <i class="fa-solid fa-magnifying-glass fs-2 text-warning mb-2"></i>
                                    <h6 class="fw-bold">1. Tìm &amp; Chọn Sách</h6>
                                    <p class="small text-muted mb-0">Tìm kiếm theo tên sách, tác giả, ISBN, lọc theo mức giá và tình trạng sách cũ.</p>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="p-3 border rounded-3 text-center h-100">
                                    <i class="fa-solid fa-cart-shopping fs-2 text-warning mb-2"></i>
                                    <h6 class="fw-bold">2. Thêm Vào Giỏ Hàng</h6>
                                    <p class="small text-muted mb-0">Chọn số lượng mua trong phạm vi tồn kho sẵn có của từng chi nhánh.</p>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="p-3 border rounded-3 text-center h-100">
                                    <i class="fa-solid fa-credit-card fs-2 text-warning mb-2"></i>
                                    <h6 class="fw-bold">3. Thanh Toán &amp; Nhận Hàng</h6>
                                    <p class="small text-muted mb-0">Áp mã giảm giá voucher, chọn thanh toán COD, VNPAY hoặc MoMo.</p>
                                </div>
                            </div>
                        </div>

                        <h5 class="fw-bold text-dark mt-4">Lưu ý quan trọng khi giỏ hàng có nhiều Shop:</h5>
                        <p class="text-secondary">Hệ thống sẽ <strong>tự động tách thành các đơn hàng riêng biệt</strong> tương ứng với từng chi nhánh/cửa hàng cung cấp sách để đảm bảo quy trình đóng gói và vận chuyển nhanh nhất.</p>
                    </c:when>

                    <%-- 5. Chính sách khách sỉ --%>
                    <c:when test="${activePolicy == 'wholesale'}">
                        <h3 class="fw-bold mb-3 text-dark border-start border-4 border-warning ps-3">Chính Sách Khách Sỉ &amp; Thư Viện</h3>
                        <p class="text-muted small">Ưu đãi dành cho tổ chức, nhà sưu tầm và các đơn vị mua số lượng lớn</p>
                        <hr>
                        <p>Sách Cũ Việt cung cấp chính sách chiết khấu linh hoạt cho các quán cà phê sách, thư viện trường học, nhà sách và cá nhân sưu tầm sách cũ theo lô lớn:</p>
                        <ul>
                            <li>Đơn hàng từ 20 cuốn trở lên: Chiết khấu thêm từ 10% - 20% trên giá niêm yết.</li>
                            <li>Hỗ trợ đóng gói chuyên dụng chống ẩm mốc cho sách xuất bản trước năm 1975.</li>
                            <li>Hỗ trợ xuất hóa đơn và chứng từ hợp lệ cho cơ quan, tổ chức.</li>
                        </ul>
                        <p>Vui lòng liên hệ trực tiếp Hotline: <strong>0358.414.848</strong> hoặc email <strong>huykirito@gmail.com</strong> để được tư vấn báo giá chi tiết.</p>
                    </c:when>

                    <%-- 6. Giới thiệu --%>
                    <c:otherwise>
                        <h3 class="fw-bold mb-3 text-dark border-start border-4 border-warning ps-3">Về Chúng Tôi - Sách Cũ Việt</h3>
                        <p class="text-muted small">Nơi lưu giữ giá trị tri thức và hồi sinh những trang sách cũ</p>
                        <hr>
                        <p><strong>Sách Cũ Việt</strong> là nền tảng thương mại điện tử kết nối chuỗi các cửa hàng sách cũ trên toàn quốc. Sứ mệnh của chúng tôi là tạo nên một thị trường trao đổi, mua bán sách đã qua sử dụng một cách tiện lợi, tin cậy và minh bạch.</p>
                        <h5 class="fw-bold text-dark mt-4">Cam kết của chúng tôi:</h5>
                        <ul>
                            <li><strong>Phân loại tình trạng chuẩn xác:</strong> Mọi bản sao sách đều được thẩm định và phân loại tình trạng rõ ràng trước khi niêm yết.</li>
                            <li><strong>Bảo vệ quyền lợi người mua:</strong> Đánh giá chân thực từ chính những khách hàng đã mua sản phẩm.</li>
                            <li><strong>Đổi trả an tâm:</strong> Quy trình xử lý đổi trả và hoàn tiền rõ ràng, nhanh chóng.</li>
                        </ul>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp"/>
