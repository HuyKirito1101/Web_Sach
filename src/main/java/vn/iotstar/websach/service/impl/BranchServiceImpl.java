package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.repository.BranchRepository;
import vn.iotstar.websach.service.BranchService;

import java.util.List;
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
        return branchRepository.save(branch);
    }

    @Override
    public Branch updateBranch(Long id, Branch details) {
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
        branchRepository.deleteById(id);
    }
}
