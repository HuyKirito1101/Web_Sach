package vn.iotstar.websach.controller.admin;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.enums.BranchStatus;
import vn.iotstar.websach.service.BranchService;
import vn.iotstar.websach.service.CloudinaryService;

@Controller
@RequestMapping("/admin/branches")
@RequiredArgsConstructor
public class AdminBranchController {

    private final BranchService branchService;
    private final CloudinaryService cloudinaryService;

    @GetMapping
    public String listBranches(Model model) {
        model.addAttribute("branches", branchService.findAllBranches());
        model.addAttribute("branchForm", new Branch());
        return "admin/branches/list";
    }

    @PostMapping("/save")
    public String saveBranch(@ModelAttribute("branchForm") Branch branch,
                             @RequestParam(value = "imageFile", required = false) MultipartFile imageFile) {
        if (imageFile != null && !imageFile.isEmpty()) {
            String imageUrl = cloudinaryService.uploadFile(imageFile);
            branch.setImageUrl(imageUrl);
        }
        if (branch.getId() == null) {
            branchService.saveBranch(branch);
        } else {
            branchService.updateBranch(branch.getId(), branch);
        }
        return "redirect:/admin/branches?success";
    }

    @GetMapping("/delete/{id}")
    public String deleteBranch(@PathVariable("id") Long id) {
        branchService.deleteBranch(id);
        return "redirect:/admin/branches?deleted";
    }
}
