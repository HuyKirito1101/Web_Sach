package vn.iotstar.websach;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.dto.VendorChatMessageDTO;
import vn.iotstar.websach.entity.*;
import vn.iotstar.websach.entity.enums.BookCondition;
import vn.iotstar.websach.entity.enums.BookCopyStatus;
import vn.iotstar.websach.entity.enums.RoleName;
import vn.iotstar.websach.entity.enums.UserStatus;
import vn.iotstar.websach.repository.*;
import vn.iotstar.websach.service.EmailService;
import vn.iotstar.websach.service.VendorChatService;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class VendorChatIntegrationTest {

    @Autowired private VendorChatService vendorChatService;
    @Autowired private UserRepository userRepository;
    @Autowired private RoleRepository roleRepository;
    @Autowired private BranchRepository branchRepository;
    @Autowired private BookRepository bookRepository;
    @Autowired private BookCopyRepository bookCopyRepository;
    @Autowired private VendorConversationRepository conversationRepository;
    @Autowired private VendorMessageRepository messageRepository;

    @MockBean private EmailService emailService;

    private User customer;
    private User vendor;
    private User otherUser;
    private BookCopy bookCopy;

    @BeforeEach
    void setUp() {
        Role customerRole = roleRepository.findByName(RoleName.ROLE_USER).orElseThrow();
        Role vendorRole = roleRepository.findByName(RoleName.ROLE_VENDOR).orElseThrow();

        customer = userRepository.findByEmail("customer.chat.test@websachcu.vn").orElseGet(() ->
                userRepository.save(User.builder()
                        .email("customer.chat.test@websachcu.vn")
                        .fullName("Khách Hàng Test Chat")
                        .password("123456")
                        .phone("0987654321")
                        .role(customerRole)
                        .status(UserStatus.ACTIVE)
                        .build()));

        vendor = userRepository.findByEmail("vendor.chat.test@websachcu.vn").orElseGet(() ->
                userRepository.save(User.builder()
                        .email("vendor.chat.test@websachcu.vn")
                        .fullName("Vendor Shop Test")
                        .password("123456")
                        .phone("0912345678")
                        .role(vendorRole)
                        .status(UserStatus.ACTIVE)
                        .build()));

        otherUser = userRepository.findByEmail("other.user.test@websachcu.vn").orElseGet(() ->
                userRepository.save(User.builder()
                        .email("other.user.test@websachcu.vn")
                        .fullName("Người Dùng Thứ 3")
                        .password("123456")
                        .phone("0900000000")
                        .role(customerRole)
                        .status(UserStatus.ACTIVE)
                        .build()));

        Branch branch = branchRepository.findAll().stream().findFirst().orElseThrow();

        Book book = bookRepository.findAll().stream().findFirst().orElseGet(() ->
                bookRepository.save(Book.builder()
                        .title("Sách Cũ Test Nhắn Tin")
                        .isbn("978-0-123456-47-2")
                        .coverUrl("https://example.com/cover.jpg")
                        .build()));

        bookCopy = bookCopyRepository.save(BookCopy.builder()
                .book(book)
                .branch(branch)
                .seller(vendor)
                .sellingPrice(85000.0)
                .conditionRating(BookCondition.VERY_GOOD)
                .quantity(3)
                .note("Sách còn rất mới, bìa đẹp")
                .status(BookCopyStatus.AVAILABLE)
                .build());
    }

    @Test
    void testCustomerVendorChatWorkflow() {
        // 1. Khách hàng bắt đầu hội thoại từ sản phẩm sách cũ
        VendorConversation conv = vendorChatService.getOrCreateConversation(
                customer.getEmail(), vendor.getId(), bookCopy.getId());

        assertThat(conv).isNotNull();
        assertThat(conv.getId()).isNotNull();
        assertThat(conv.getCustomer().getId()).isEqualTo(customer.getId());
        assertThat(conv.getVendor().getId()).isEqualTo(vendor.getId());
        assertThat(conv.getBookCopy()).isNotNull();
        assertThat(conv.getBookCopy().getId()).isEqualTo(bookCopy.getId());
        assertThat(conv.getVendorUnread()).isFalse();

        // 2. Khách hàng gửi tin nhắn hỏi mua sách
        String customerMsgContent = "Chào shop, cuốn sách '" + bookCopy.getBook().getTitle() + "' này còn không ạ?";
        VendorMessage msg1 = vendorChatService.sendMessage(conv.getId(), customer.getEmail(), customerMsgContent, bookCopy.getId());

        assertThat(msg1.getId()).isNotNull();
        assertThat(msg1.getContent()).isEqualTo(customerMsgContent);
        assertThat(msg1.getSender().getId()).isEqualTo(customer.getId());

        // Kiểm tra trạng thái hội thoại sau khi khách gửi
        VendorConversation updatedConv = conversationRepository.findById(conv.getId()).orElseThrow();
        assertThat(updatedConv.getLastMessage()).isEqualTo(customerMsgContent);
        assertThat(updatedConv.getVendorUnread()).isTrue();
        assertThat(updatedConv.getCustomerUnread()).isFalse();
        assertThat(vendorChatService.countUnreadForVendor(vendor.getEmail())).isGreaterThanOrEqualTo(1);

        // 3. Vendor mở tin nhắn xem -> vendorUnread chuyển thành false
        List<VendorMessage> messagesForVendor = vendorChatService.getMessages(conv.getId(), vendor.getEmail());
        assertThat(messagesForVendor).hasSize(1);

        updatedConv = conversationRepository.findById(conv.getId()).orElseThrow();
        assertThat(updatedConv.getVendorUnread()).isFalse();

        // 4. Vendor phản hồi lại cho khách
        String vendorReplyContent = "Dạ sách vẫn còn sẵn bạn nhé, bạn có thể bấm Mua ngay trên khung chat ạ!";
        VendorMessage replyMsg = vendorChatService.sendMessage(conv.getId(), vendor.getEmail(), vendorReplyContent, null);

        assertThat(replyMsg.getContent()).isEqualTo(vendorReplyContent);
        assertThat(replyMsg.getSender().getId()).isEqualTo(vendor.getId());

        updatedConv = conversationRepository.findById(conv.getId()).orElseThrow();
        assertThat(updatedConv.getLastMessage()).isEqualTo(vendorReplyContent);
        assertThat(updatedConv.getCustomerUnread()).isTrue();
        assertThat(updatedConv.getVendorUnread()).isFalse();
        assertThat(vendorChatService.countUnreadForCustomer(customer.getEmail())).isGreaterThanOrEqualTo(1);

        // 5. Khách hàng mở tin nhắn đọc -> customerUnread chuyển thành false
        List<VendorMessage> messagesForCustomer = vendorChatService.getMessages(conv.getId(), customer.getEmail());
        assertThat(messagesForCustomer).hasSize(2);

        updatedConv = conversationRepository.findById(conv.getId()).orElseThrow();
        assertThat(updatedConv.getCustomerUnread()).isFalse();
    }

    @Test
    void testSelfMessagingIsBlocked() {
        // Vendor không thể tự chat với chính mình
        assertThatThrownBy(() -> vendorChatService.getOrCreateConversation(
                vendor.getEmail(), vendor.getId(), bookCopy.getId()))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("không thể tự nhắn tin cho chính mình");
    }

    @Test
    void testUnauthorizedUserCannotAccessConversation() {
        VendorConversation conv = vendorChatService.getOrCreateConversation(
                customer.getEmail(), vendor.getId(), bookCopy.getId());

        // Người dùng thứ 3 không liên quan cố tình đọc tin nhắn
        assertThatThrownBy(() -> vendorChatService.getMessages(conv.getId(), otherUser.getEmail()))
                .isInstanceOf(SecurityException.class);

        // Người dùng thứ 3 cố tình gửi tin nhắn vào cuộc hội thoại
        assertThatThrownBy(() -> vendorChatService.sendMessage(conv.getId(), otherUser.getEmail(), "Hack message", null))
                .isInstanceOf(SecurityException.class);
    }

    @Test
    void testDtoConversionIncludesProductDetails() {
        VendorConversation conv = vendorChatService.getOrCreateConversation(
                customer.getEmail(), vendor.getId(), bookCopy.getId());
        VendorMessage msg = vendorChatService.sendMessage(conv.getId(), customer.getEmail(), "Hỏi giá sách", bookCopy.getId());

        VendorChatMessageDTO dto = vendorChatService.toDTO(msg, customer.getEmail());
        assertThat(dto.isMe()).isTrue();
        assertThat(dto.getBookCopyId()).isEqualTo(bookCopy.getId());
        assertThat(dto.getBookId()).isEqualTo(bookCopy.getBook().getId());
        assertThat(dto.getBookTitle()).isEqualTo(bookCopy.getBook().getTitle());
        assertThat(dto.getBookPrice()).isEqualTo(bookCopy.getSellingPrice());
        assertThat(dto.getConditionRating()).isEqualTo(bookCopy.getConditionRating().name());
    }

    @Test
    void testFirstMessageAttachesProductAndSubsequentDoNot() {
        VendorConversation conv = vendorChatService.getOrCreateConversation(
                customer.getEmail(), vendor.getId(), bookCopy.getId());

        // Tin nhắn đầu tiên về sản phẩm bookCopy -> Được đính kèm sản phẩm
        VendorMessage msg1 = vendorChatService.sendMessage(conv.getId(), customer.getEmail(), "Tin nhắn 1 hỏi về sách", bookCopy.getId());
        assertThat(msg1.getBookCopy()).isNotNull();
        assertThat(msg1.getBookCopy().getId()).isEqualTo(bookCopy.getId());

        // Tin nhắn thứ hai của khách trong cùng hội thoại -> KHÔNG đính kèm lặp lại
        VendorMessage msg2 = vendorChatService.sendMessage(conv.getId(), customer.getEmail(), "Tin nhắn 2 hỏi thêm", bookCopy.getId());
        assertThat(msg2.getBookCopy()).isNull();

        // Vendor phản hồi -> KHÔNG đính kèm sản phẩm
        VendorMessage msg3 = vendorChatService.sendMessage(conv.getId(), vendor.getEmail(), "Shop trả lời khách", null);
        assertThat(msg3.getBookCopy()).isNull();
    }

    @Test
    void testDeleteMessageSuccessAndSecurity() {
        VendorConversation conv = vendorChatService.getOrCreateConversation(
                customer.getEmail(), vendor.getId(), bookCopy.getId());

        VendorMessage msg = vendorChatService.sendMessage(conv.getId(), customer.getEmail(), "Tin nhắn gửi nhầm cần xóa", null);
        Long msgId = msg.getId();
        assertThat(messageRepository.findById(msgId)).isPresent();

        // Người dùng thứ 3 không liên quan cố xóa tin nhắn -> bị chặn
        assertThatThrownBy(() -> vendorChatService.deleteMessage(msgId, otherUser.getEmail()))
                .isInstanceOf(SecurityException.class);

        // Chính người gửi xóa tin nhắn gửi nhầm -> Thành công
        vendorChatService.deleteMessage(msgId, customer.getEmail());
        assertThat(messageRepository.findById(msgId)).isEmpty();
    }

    @Test
    void testDeleteConversationHistory() {
        VendorConversation conv = vendorChatService.getOrCreateConversation(
                customer.getEmail(), vendor.getId(), bookCopy.getId());
        Long convId = conv.getId();

        vendorChatService.sendMessage(convId, customer.getEmail(), "Tin nhắn 1", null);
        vendorChatService.sendMessage(convId, vendor.getEmail(), "Tin nhắn 2", null);

        assertThat(messageRepository.findByConversationIdOrderByCreatedAtAsc(convId)).hasSize(2);

        // Xóa lịch sử cuộc trò chuyện
        vendorChatService.deleteConversation(convId, vendor.getEmail());

        assertThat(conversationRepository.findById(convId)).isEmpty();
        assertThat(messageRepository.findByConversationIdOrderByCreatedAtAsc(convId)).isEmpty();
    }
}
