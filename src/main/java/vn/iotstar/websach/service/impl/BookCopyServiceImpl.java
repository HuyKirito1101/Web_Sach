package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import vn.iotstar.websach.entity.Book;
import vn.iotstar.websach.entity.BookCopy;
import vn.iotstar.websach.entity.Branch;
import vn.iotstar.websach.entity.enums.BookCondition;
import vn.iotstar.websach.entity.enums.BookCopyStatus;
import vn.iotstar.websach.repository.BookCopyRepository;
import vn.iotstar.websach.repository.BookRepository;
import vn.iotstar.websach.service.BookCopyService;
import vn.iotstar.websach.service.CloudinaryService;
import vn.iotstar.websach.service.ManagerAccessService;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class BookCopyServiceImpl implements BookCopyService {

    private final BookCopyRepository bookCopyRepository;
    private final BookRepository bookRepository;
    private final CloudinaryService cloudinaryService;
    private final ManagerAccessService managerAccessService;

    @Override
    public List<BookCopy> findAllCopies() {
        return bookCopyRepository.findAll();
    }

    @Override
    public List<BookCopy> findCopiesByBranch(Long branchId) {
        return bookCopyRepository.findByBranchId(branchId);
    }

    @Override
    public List<BookCopy> filterBranchCopies(Long branchId, BookCondition conditionRating) {
        return bookCopyRepository.filterBranchCopies(branchId, conditionRating);
    }

    @Override
    public Optional<BookCopy> findById(Long id) {
        return bookCopyRepository.findById(id);
    }

    @Override
    public BookCopy saveCopy(BookCopy copy) {
        return bookCopyRepository.save(copy);
    }

    @Override
    public BookCopy updateCopy(Long id, BookCopy details) {
        BookCopy copy = bookCopyRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Bản sách cũ không tồn tại id: " + id));

        copy.setConditionRating(details.getConditionRating());
        copy.setPurchasePrice(details.getPurchasePrice());
        copy.setSellingPrice(details.getSellingPrice());
        copy.setQuantity(details.getQuantity());
        copy.setStatus(details.getStatus());
        copy.setNote(details.getNote());
        if (details.getImageUrl() != null) {
            copy.setImageUrl(details.getImageUrl());
        }

        return bookCopyRepository.save(copy);
    }

    @Override
    @Transactional
    public BookCopy saveManagedCopy(String managerEmail, BookCopy details, Long bookId, MultipartFile imageFile) {
        Branch branch = managerAccessService.requireManagedBranch(managerEmail);
        Book book = bookRepository.findById(bookId)
                .orElseThrow(() -> new IllegalArgumentException("Đầu sách không tồn tại."));
        BookCopy target;
        if (details.getId() == null) {
            target = details;
        } else {
            target = managerAccessService.requireCopyInBranch(managerEmail, details.getId());
            target.setConditionRating(details.getConditionRating());
            target.setPurchasePrice(details.getPurchasePrice());
            target.setSellingPrice(details.getSellingPrice());
            target.setQuantity(details.getQuantity());
            target.setStatus(details.getStatus());
            target.setNote(details.getNote());
            if (details.getImageUrl() != null && !details.getImageUrl().isBlank()) {
                target.setImageUrl(details.getImageUrl());
            }
        }
        target.setBook(book);
        target.setBranch(branch);
        if (imageFile != null && !imageFile.isEmpty()) {
            target.setImageUrl(cloudinaryService.uploadFile(imageFile));
        }
        return bookCopyRepository.save(target);
    }

    @Override
    @Transactional
    public void deleteManagedCopy(String managerEmail, Long copyId) {
        BookCopy copy = managerAccessService.requireCopyInBranch(managerEmail, copyId);
        bookCopyRepository.delete(copy);
    }

    @Override
    public void deleteCopy(Long id) {
        bookCopyRepository.deleteById(id);
    }

    @Override
    @Transactional
    public BookCopy updateStock(Long copyId, int quantityChange) {
        BookCopy copy = bookCopyRepository.findById(copyId)
                .orElseThrow(() -> new RuntimeException("Bản sách không tồn tại id: " + copyId));

        int newQty = copy.getQuantity() + quantityChange;
        if (newQty < 0) {
            throw new RuntimeException("Số lượng tồn kho không đủ!");
        }
        copy.setQuantity(newQty);
        if (newQty == 0) {
            copy.setStatus(BookCopyStatus.SOLD);
        } else {
            copy.setStatus(BookCopyStatus.AVAILABLE);
        }

        return bookCopyRepository.save(copy);
    }
}
