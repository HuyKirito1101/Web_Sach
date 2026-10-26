package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.enums.BranchStatus;
import vn.iotstar.websach.repository.BranchRepository;
import vn.iotstar.websach.service.BranchService;

import java.util.List;
import java.util.Locale;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class BranchServiceImpl implements BranchService {

    private final BranchRepository branchRepository;

    @Override
    public List<Branch> findAllBranches() {
        return branchRepository.findAll();
    }

    @Override
    public Optional<Branch> findById(Long id) {
        return branchRepository.findById(id);
    }

    @Override
    public Branch saveBranch(Branch branch) {
        validate(branch);
        normalize(branch);
        return branchRepository.save(branch);
    }

    @Override
    public Branch updateBranch(Long id, Branch details) {
        validate(details);
        normalize(details);
        Branch branch = branchRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Chi nhánh không tồn tại: " + id));
        branch.setName(details.getName());
        branch.setDescription(details.getDescription());
        branch.setAddress(details.getAddress());
        branch.setPhone(details.getPhone());
        branch.setEmail(details.getEmail());
        if (details.getImageUrl() != null) {
            branch.setImageUrl(details.getImageUrl());
        }
        if (details.getStatus() != null) {
            branch.setStatus(details.getStatus());
        }
        if (details.getAppDiscountPercent() != null) {
            branch.setAppDiscountPercent(details.getAppDiscountPercent());
        }
        return branchRepository.save(branch);
    }

    @Override
    public void deleteBranch(Long id) {
        Branch branch = branchRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Chi nhánh không tồn tại."));
        branch.setStatus(BranchStatus.INACTIVE);
        branchRepository.save(branch);
    }

    private void validate(Branch branch) {
        if (branch == null || branch.getName() == null || branch.getName().isBlank()
                || branch.getName().trim().length() > 150) {
            throw new IllegalArgumentException("Tên chi nhánh phải có từ 1 đến 150 ký tự.");
        }
        if (branch.getAddress() == null || branch.getAddress().isBlank()
                || branch.getAddress().trim().length() > 255) {
            throw new IllegalArgumentException("Địa chỉ chi nhánh phải có từ 1 đến 255 ký tự.");
        }
        if (branch.getPhone() != null && !branch.getPhone().isBlank()
                && !branch.getPhone().trim().matches("^(?:0\\d{9}|\\+84\\d{9})$")) {
            throw new IllegalArgumentException("Số điện thoại chi nhánh không hợp lệ.");
        }
        if (branch.getEmail() != null && !branch.getEmail().isBlank()
                && !branch.getEmail().trim().matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")) {
            throw new IllegalArgumentException("Email chi nhánh không hợp lệ.");
        }
        if (branch.getAppDiscountPercent() != null
                && (branch.getAppDiscountPercent() < 0 || branch.getAppDiscountPercent() > 100)) {
            throw new IllegalArgumentException("Chiết khấu ứng dụng phải nằm trong khoảng 0 đến 100%.");
        }
    }

    private void normalize(Branch branch) {
        branch.setName(branch.getName().trim());
        branch.setAddress(branch.getAddress().trim());
        if (branch.getPhone() != null) branch.setPhone(branch.getPhone().trim());
        if (branch.getEmail() != null) branch.setEmail(branch.getEmail().trim().toLowerCase(Locale.ROOT));
    }
}
