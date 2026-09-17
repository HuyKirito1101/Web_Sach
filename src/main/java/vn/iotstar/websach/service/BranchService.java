package vn.iotstar.websach.service;

import vn.iotstar.websach.entity.Branch;

import java.util.List;
import java.util.Optional;

public interface BranchService {
    List<Branch> findAllBranches();
    Optional<Branch> findById(Long id);
    Branch saveBranch(Branch branch);
    Branch updateBranch(Long id, Branch branchDetails);
    void deleteBranch(Long id);
}
