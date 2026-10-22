package vn.iotstar.websach;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.BookCopy;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.Promotion;
import vn.iotstar.websach.entity.enums.BranchStatus;
import vn.iotstar.websach.entity.enums.PromotionType;
import vn.iotstar.websach.repository.BookCopyRepository;
import vn.iotstar.websach.repository.BranchRepository;
import vn.iotstar.websach.service.ManagerAccessService;
import vn.iotstar.websach.service.PromotionService;
import vn.iotstar.websach.service.BranchService;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@SpringBootTest
@ActiveProfiles("h2")
@Transactional
class AdminManagerWorkflowIntegrationTest {

    private static final String MANAGER_EMAIL = "manager@websachcu.vn";

    @Autowired private ManagerAccessService managerAccessService;
    @Autowired private PromotionService promotionService;
    @Autowired private BookCopyRepository bookCopyRepository;
    @Autowired private BranchRepository branchRepository;
    @Autowired private BranchService branchService;

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
}
