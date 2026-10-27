package vn.iotstar.websach;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.BookCopy;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.Promotion;
import vn.iotstar.websach.entity.SupportConversation;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.enums.BranchStatus;
import vn.iotstar.websach.entity.enums.PromotionType;
import vn.iotstar.websach.entity.enums.RoleName;
import vn.iotstar.websach.dto.StockTransferRequest;
import vn.iotstar.websach.repository.BookCopyRepository;
import vn.iotstar.websach.repository.BranchRepository;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.service.ManagerAccessService;
import vn.iotstar.websach.service.PromotionService;
import vn.iotstar.websach.service.BranchService;
import vn.iotstar.websach.service.StockTransferService;
import vn.iotstar.websach.service.SupportChatService;
import vn.iotstar.websach.service.UserService;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
@ActiveProfiles("test")
@Transactional
class AdminManagerWorkflowIntegrationTest {

    private static final String MANAGER_EMAIL = "manager@websachcu.vn";

    @Autowired private ManagerAccessService managerAccessService;
    @Autowired private PromotionService promotionService;
    @Autowired private BookCopyRepository bookCopyRepository;
    @Autowired private BranchRepository branchRepository;
    @Autowired private BranchService branchService;
    @Autowired private StockTransferService stockTransferService;
    @Autowired private SupportChatService supportChatService;
    @Autowired private UserService userService;
    @Autowired private UserRepository userRepository;

    @Test
    void adminCanEditBranchInformationWithoutClearingCurrentImage() {
        Branch current = branchRepository.findAll().getFirst();
        current.setImageUrl("https://res.cloudinary.com/demo/current.jpg");
        branchRepository.saveAndFlush(current);

        Branch details = Branch.builder()
                .name("Chi nhánh đã cập nhật")
                .description("Mô tả mới của chi nhánh")
                .address("123 Đường Mới, TP.HCM")
                .phone("0901234567")
                .email("chinhanh@example.com")
                .status(BranchStatus.INACTIVE)
                .appDiscountPercent(15.0)
                .build();

        Branch updated = branchService.updateBranch(current.getId(), details);

        assertThat(updated.getName()).isEqualTo("Chi nhánh đã cập nhật");
        assertThat(updated.getDescription()).isEqualTo("Mô tả mới của chi nhánh");
        assertThat(updated.getAddress()).isEqualTo("123 Đường Mới, TP.HCM");
        assertThat(updated.getStatus()).isEqualTo(BranchStatus.INACTIVE);
        assertThat(updated.getAppDiscountPercent()).isEqualTo(15.0);
        assertThat(updated.getImageUrl()).isEqualTo("https://res.cloudinary.com/demo/current.jpg");
    }

    @Test
    void managerCannotManageAProductFromAnotherBranch() {
        Branch managedBranch = managerAccessService.requireManagedBranch(MANAGER_EMAIL);
        BookCopy anotherBranchProduct = bookCopyRepository.findAll().stream()
                .filter(copy -> !copy.getBranch().getId().equals(managedBranch.getId()))
                .findFirst().orElseThrow();

        assertThatThrownBy(() -> managerAccessService.requireCopyInBranch(
                MANAGER_EMAIL, anotherBranchProduct.getId()))
                .isInstanceOf(SecurityException.class)
                .hasMessageContaining("chi nhánh khác");
    }

    @Test
    void activeGlobalPromotionIsAppliedAndManagerCannotDeleteOtherBranchPromotion() {
        Branch managedBranch = managerAccessService.requireManagedBranch(MANAGER_EMAIL);
        Branch otherBranch = branchRepository.findAll().stream()
                .filter(branch -> !branch.getId().equals(managedBranch.getId()))
                .findFirst().orElseThrow();

        Promotion global = promotionService.saveForAdmin(Promotion.builder()
                .title("Miễn phí giao hàng toàn hệ thống")
                .type(PromotionType.SHIPPING_PERCENT)
                .discountPercent(100.0)
                .maxDiscountAmount(30000.0)
                .minOrderValue(50000.0)
                .startDate(LocalDate.now().minusDays(1))
                .endDate(LocalDate.now().plusDays(1))
                .active(true)
                .build(), null);

        Promotion otherBranchPromotion = promotionService.saveForAdmin(Promotion.builder()
                .title("Khuyến mãi chi nhánh khác")
                .type(PromotionType.PRODUCT_PERCENT)
                .discountPercent(10.0)
                .startDate(LocalDate.now())
                .endDate(LocalDate.now().plusDays(7))
                .active(true)
                .build(), otherBranch.getId());

        assertThat(promotionService.findApplicablePromotions(
                managedBranch.getId(), LocalDate.now(), 100000.0))
                .extracting(Promotion::getId)
                .contains(global.getId());
        assertThatThrownBy(() -> promotionService.deleteForBranch(
                otherBranchPromotion.getId(), managedBranch.getId()))
                .isInstanceOf(SecurityException.class)
                .hasMessageContaining("chi nhánh khác");
    }

    @Test
    void managerCannotCreateTransferFromAnotherBranch() {
        Branch managedBranch = managerAccessService.requireManagedBranch(MANAGER_EMAIL);
        BookCopy otherCopy = bookCopyRepository.findAll().stream()
                .filter(copy -> copy.getBranch() != null)
                .filter(copy -> !copy.getBranch().getId().equals(managedBranch.getId()))
                .filter(copy -> copy.getQuantity() != null && copy.getQuantity() > 0)
                .findFirst().orElseThrow();

        StockTransferRequest request = new StockTransferRequest();
        request.setFromBranchId(otherCopy.getBranch().getId());
        request.setToBranchId(managedBranch.getId());
        request.setBookCopyId(otherCopy.getId());
        request.setQuantity(1);

        assertThatThrownBy(() -> stockTransferService.createTransferRequest(request, MANAGER_EMAIL))
                .isInstanceOf(SecurityException.class)
                .hasMessageContaining("chi nhánh mình quản lý");
    }

    @Test
    void customerMessagesAreRoutedToTheCorrectBranchManager() {
        Branch managedBranch = managerAccessService.requireManagedBranch(MANAGER_EMAIL);
        Branch otherBranch = branchRepository.findAll().stream()
                .filter(branch -> branch.getStatus() == BranchStatus.ACTIVE)
                .filter(branch -> !branch.getId().equals(managedBranch.getId()))
                .findFirst().orElseThrow();

        SupportConversation conversation = supportChatService.startConversation(
                "Khách cần hỗ trợ", "0901234567", managedBranch.getId(), "Chi nhánh còn sách này không?");

        assertThat(supportChatService.getManagerConversations(MANAGER_EMAIL))
                .extracting(SupportConversation::getId)
                .contains(conversation.getId());
        assertThat(supportChatService.countUnreadForManager(MANAGER_EMAIL)).isGreaterThanOrEqualTo(1);

        supportChatService.openForManager(MANAGER_EMAIL, conversation.getId());
        supportChatService.replyAsManager(MANAGER_EMAIL, conversation.getId(), "Chi nhánh vẫn còn sách, mời bạn ghé xem.");

        assertThat(supportChatService.getCustomerMessages(conversation.getPublicToken()))
                .extracting(message -> message.getSenderType().name())
                .containsExactly("CUSTOMER", "MANAGER");

        SupportConversation anotherBranchConversation = supportChatService.startConversation(
                "Khách chi nhánh khác", "0912345678", otherBranch.getId(), "Tôi cần hỗ trợ.");
        assertThatThrownBy(() -> supportChatService.openForManager(MANAGER_EMAIL, anotherBranchConversation.getId()))
                .isInstanceOf(SecurityException.class)
                .hasMessageContaining("chi nhánh khác");
        assertThatThrownBy(() -> supportChatService.deleteConversation(MANAGER_EMAIL, anotherBranchConversation.getId()))
                .isInstanceOf(SecurityException.class)
                .hasMessageContaining("chi nhánh khác");

        supportChatService.deleteConversation(MANAGER_EMAIL, conversation.getId());
        assertThat(supportChatService.getManagerConversations(MANAGER_EMAIL))
                .extracting(SupportConversation::getId)
                .doesNotContain(conversation.getId());
        assertThatThrownBy(() -> supportChatService.getCustomerConversation(conversation.getPublicToken()))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Không tìm thấy hội thoại");
    }

    @Test
    void managerCanManageUsersVendorsAndShippersOnlyInsideManagedBranch() {
        Branch managedBranch = managerAccessService.requireManagedBranch(MANAGER_EMAIL);
        var managedUsers = userService.searchUsersForManagedBranch(MANAGER_EMAIL, "");

        assertThat(managedUsers).isNotEmpty();
        assertThat(managedUsers)
                .allMatch(user -> user.getRole() != null
                        && (user.getRole().getName() == RoleName.ROLE_USER
                        || user.getRole().getName() == RoleName.ROLE_VENDOR
                        || user.getRole().getName() == RoleName.ROLE_SHIPPER));
        assertThat(managedUsers).anyMatch(user -> user.getRole().getName() == RoleName.ROLE_USER);
        assertThat(managedUsers).anyMatch(user -> user.getRole().getName() == RoleName.ROLE_VENDOR);
        assertThat(managedUsers).anyMatch(user -> user.getRole().getName() == RoleName.ROLE_SHIPPER);

        User branchUser = managedUsers.stream()
                .filter(user -> user.getRole().getName() == RoleName.ROLE_USER)
                .findFirst().orElseThrow();
        Long shipperRoleId = userService.findBranchManageableRoles().stream()
                .filter(role -> role.getName() == RoleName.ROLE_SHIPPER)
                .findFirst().orElseThrow().getId();

        User updated = userService.updateManagedBranchUser(
                MANAGER_EMAIL, branchUser.getId(), shipperRoleId, "ACTIVE");
        assertThat(updated.getRole().getName()).isEqualTo(RoleName.ROLE_SHIPPER);
        assertThat(updated.getBranch().getId()).isEqualTo(managedBranch.getId());

        User otherBranchUser = userRepository.findAll().stream()
                .filter(user -> user.getBranch() != null)
                .filter(user -> !user.getBranch().getId().equals(managedBranch.getId()))
                .filter(user -> user.getRole() != null && user.getRole().getName() == RoleName.ROLE_VENDOR)
                .findFirst().orElseThrow();
        assertThatThrownBy(() -> userService.toggleManagedBranchUserLock(
                MANAGER_EMAIL, otherBranchUser.getId()))
                .isInstanceOf(SecurityException.class)
                .hasMessageContaining("chi nhánh khác");
    }
}
