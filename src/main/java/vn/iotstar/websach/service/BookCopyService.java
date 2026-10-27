package vn.iotstar.websach.service;

import org.springframework.web.multipart.MultipartFile;
import vn.iotstar.websach.entity.BookCopy;
import vn.iotstar.websach.entity.enums.BookCondition;
import vn.iotstar.websach.entity.enums.BookCopyStatus;

import java.util.List;
import java.util.Optional;

public interface BookCopyService {
    List<BookCopy> findAllCopies();
    List<BookCopy> findCopiesByBranch(Long branchId);
    List<BookCopy> filterBranchCopies(Long branchId, BookCondition conditionRating);
    Optional<BookCopy> findById(Long id);
    BookCopy saveCopy(BookCopy copy);
    BookCopy updateCopy(Long id, BookCopy copyDetails);
    BookCopy saveManagedCopy(String managerEmail, BookCopy copyDetails, Long bookId, MultipartFile imageFile);
    void deleteManagedCopy(String managerEmail, Long copyId);
    void deleteCopy(Long id);
    BookCopy updateStock(Long copyId, int quantityChange);
}
