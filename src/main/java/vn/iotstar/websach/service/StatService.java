package vn.iotstar.websach.service;

import vn.iotstar.websach.dto.BranchStatDTO;
import vn.iotstar.websach.dto.SystemStatDTO;

public interface StatService {
    SystemStatDTO getSystemStats();
    BranchStatDTO getBranchStats(Long branchId);
}
