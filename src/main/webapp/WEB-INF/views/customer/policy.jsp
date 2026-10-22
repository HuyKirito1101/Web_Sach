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
                    <a href="/policies/guide" class="nav-link ${activePolicy == 'guide' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}">
                        <i class="fa-solid fa-circle-question me-2"></i>Hướng dẫn mua hàng
                    </a>
                    <a href="/policies/payment" class="nav-link ${activePolicy == 'payment' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}">
                        <i class="fa-solid fa-credit-card me-2"></i>Hướng dẫn thanh toán online
                    </a>
                    <a href="/policies/shipping" class="nav-link ${activePolicy == 'shipping' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}">
                        <i class="fa-solid fa-truck-fast me-2"></i>Chính sách giao hàng &amp; phí ship
                    </a>
                    <a href="/policies/returns" class="nav-link ${activePolicy == 'returns' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}">
                        <i class="fa-solid fa-rotate-left me-2"></i>Chính sách đổi trả/hoàn tiền
                    </a>
                    <a href="/policies/privacy" class="nav-link ${activePolicy == 'privacy' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}">
                        <i class="fa-solid fa-user-shield me-2"></i>Chính sách bảo mật
                    </a>
                    <a href="/policies/terms" class="nav-link ${activePolicy == 'terms' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}">
                        <i class="fa-solid fa-scale-balanced me-2"></i>Điều khoản sử dụng
                    </a>
                    <a href="/policies/wholesale" class="nav-link ${activePolicy == 'wholesale' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}">
                        <i class="fa-solid fa-boxes-packing me-2"></i>Chính sách khách sỉ
                    </a>
                    <a href="/policies/sell-books" class="nav-link ${activePolicy == 'sell-books' ? 'active bg-warning text-dark fw-bold' : 'text-secondary'}">
                        <i class="fa-solid fa-hand-holding-dollar me-2"></i>Dịch vụ thu mua sách cũ
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

                    <%-- 5. Chính sách giao hàng & phí ship --%>
                    <c:when test="${activePolicy == 'shipping'}">
                        <h3 class="fw-bold mb-3 text-dark border-start border-4 border-warning ps-3">Chính Sách Giao Hàng &amp; Phí Ship</h3>
                        <p class="text-muted small">Dịch vụ vận chuyển chuyên nghiệp qua các đơn vị hàng đầu (GHN, SPX Express...)</p>
                        <hr>
                        <h5 class="fw-bold text-dark mt-3">1. Phạm vi và Đối tác vận chuyển</h5>
                        <p>Sách Cũ Việt phục vụ giao hàng trên toàn quốc (63 tỉnh/thành phố) thông qua các đối tác vận chuyển liên kết tin cậy như <strong>Giao Hàng Nhanh (GHN Express)</strong>, <strong>Shopee Xpress (SPX Express)</strong> hoặc đội ngũ shipper nội bộ tại các chi nhánh.</p>

                        <h5 class="fw-bold text-dark mt-3">2. Thời gian giao hàng dự kiến</h5>
                        <ul>
                            <li><strong>Nội thành TP. Hồ Chí Minh:</strong> Từ 1 - 2 ngày làm việc kể từ lúc xác nhận đơn hàng.</li>
                            <li><strong>Các tỉnh và thành phố khác:</strong> Từ 2 - 4 ngày làm việc tùy thuộc vào địa chỉ nhận hàng.</li>
                        </ul>

                        <h5 class="fw-bold text-dark mt-3">3. Biểu phí giao hàng (Phí ship)</h5>
                        <p>- Phí giao hàng tiêu chuẩn được áp dụng theo từng gói hàng của chi nhánh (thông thường từ <strong>25.000 ₫ - 35.000 ₫</strong> tùy khu vực).<br>
                           - Áp dụng các voucher miễn phí hoặc giảm phí vận chuyển (FreeShip) trong các chương trình khuyến mãi hiện hành của sàn.</p>

                        <h5 class="fw-bold text-dark mt-3">4. Quy định đồng kiểm khi nhận sách</h5>
                        <p>Khách hàng được quyền kiểm tra gói bọc bên ngoài và đối chiếu thông tin người nhận, số lượng sách theo hóa đơn đính kèm trước khi thanh toán cho nhân viên giao hàng.</p>
                        <p>Mọi vướng mắc về vận chuyển vui lòng liên hệ: Hotline <strong>0376 131 883</strong> hoặc email <strong>minhkhuyen779@gmail.com</strong>.</p>
                    </c:when>

                    <%-- 6. Hướng dẫn thanh toán online --%>
                    <c:when test="${activePolicy == 'payment'}">
                        <h3 class="fw-bold mb-3 text-dark border-start border-4 border-warning ps-3">Hướng Dẫn Thanh Toán Online</h3>
                        <p class="text-muted small">Đa dạng hình thức thanh toán an toàn, bảo mật và tiện lợi</p>
                        <hr>
                        <h5 class="fw-bold text-dark mt-3">1. Thanh toán khi nhận hàng (COD)</h5>
                        <p>Khách hàng kiểm tra thông tin đơn hàng và thanh toán tiền mặt trực tiếp cho nhân viên giao hàng khi nhận sách.</p>

                        <h5 class="fw-bold text-dark mt-3">2. Thanh toán trực tuyến qua cổng VNPAY</h5>
                        <p>Hỗ trợ quét mã VNPAY-QR qua hơn 30 ứng dụng Mobile Banking của các ngân hàng lớn tại Việt Nam, thanh toán bằng thẻ ATM nội địa hoặc thẻ quốc tế Visa/Mastercard/JCB một cách nhanh chóng.</p>

                        <h5 class="fw-bold text-dark mt-3">3. Thanh toán qua Ví điện tử MoMo</h5>
                        <p>Quét mã QR MoMo để xác nhận giao dịch tức thời trong vòng vài giây, thuận tiện và hoàn toàn miễn phí giao dịch.</p>

                        <h5 class="fw-bold text-dark mt-3">4. Cam kết bảo mật thanh toán</h5>
                        <p>Tất cả các giao dịch thanh toán trực tuyến đều được mã hóa bằng giao thức SSL/TLS an toàn. Hệ thống không lưu trữ thông tin số thẻ hay mã bảo mật của quý khách.</p>
                    </c:when>

                    <%-- 7. Dịch vụ thu mua sách cũ tận nhà --%>
                    <c:when test="${activePolicy == 'sell-books'}">
                        <h3 class="fw-bold mb-3 text-dark border-start border-4 border-warning ps-3">Dịch Vụ Thu Mua Sách Cũ Tận Nhà</h3>
                        <p class="text-muted small">Thu gom và tái sinh sách cũ - Định giá minh bạch, nhận tiền ngay</p>
                        <hr>
                        <h5 class="fw-bold text-dark mt-3">1. Ý nghĩa và Mục đích dịch vụ</h5>
                        <p>Nhằm lan tỏa tình yêu sách và tối ưu hóa vòng đời của tri thức, <strong>Sách Cũ Việt</strong> triển khai dịch vụ thu mua sách cũ, sách sưu tầm, sách xưa và ngoại văn tận nhà đối với khách hàng có số lượng sách lớn hoặc không tiện di chuyển đến các chi nhánh.</p>

                        <h5 class="fw-bold text-dark mt-3">2. Quy trình 4 bước thu mua tận nhà</h5>
                        <ol>
                            <li><strong>Liên hệ &amp; Cung cấp thông tin:</strong> Quý khách gửi danh sách, hình ảnh chụp bìa và gáy sách qua Hotline/Zalo: <strong>0376 131 883</strong> hoặc email <strong>minhkhuyen779@gmail.com</strong>.</li>
                            <li><strong>Thẩm định &amp; Báo giá:</strong> Nhân viên phụ trách thu mua của Sách Cũ Việt sẽ liên hệ lại trong vòng 24h để thẩm định và gửi mức giá đề nghị minh bạch.</li>
                            <li><strong>Giao nhận sách:</strong> Đội ngũ nhân viên đến tận nơi đóng gói và nhận sách tại khu vực TP.HCM, hoặc hỗ trợ chi phí gửi bưu phẩm qua bưu điện đối với các tỉnh thành xa.</li>
                            <li><strong>Thanh toán nhanh gọn:</strong> Thanh toán chuyển khoản 100% ngay khi nhận và kiểm đếm đủ số lượng sách.</li>
                        </ol>

                        <h5 class="fw-bold text-dark mt-3">3. Danh mục sách ưu tiên thu mua</h5>
                        <p>- Sách văn học kinh điển, sách triết học, lịch sử, văn hóa.<br>
                           - Sách chuyên ngành y dược, kiến trúc, mỹ thuật, kinh tế.<br>
                           - Sách xuất bản trước năm 1975, sách quý hiếm, sách có chữ ký tác giả.<br>
                           - Sách ngoại văn, truyện tranh nguyên bộ.</p>
                    </c:when>

                    <%-- 8. Chính sách khách sỉ --%>
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
                        <p>Vui lòng liên hệ trực tiếp Hotline: <strong>0376 131 883</strong> hoặc email <strong>minhkhuyen779@gmail.com</strong> để được tư vấn báo giá chi tiết.</p>
                    </c:when>

                    <%-- 9. Giới thiệu --%>
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
