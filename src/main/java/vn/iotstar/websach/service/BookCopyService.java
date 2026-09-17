package vn.iotstar.websach.service;

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
    void deleteCopy(Long id);
    BookCopy updateStock(Long copyId, int quantityChange);
}
