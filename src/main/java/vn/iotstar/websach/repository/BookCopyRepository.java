package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.BookCopy;
import vn.iotstar.websach.entity.enums.BookCondition;
import vn.iotstar.websach.entity.enums.BookCopyStatus;

import java.util.List;

@Repository
public interface BookCopyRepository extends JpaRepository<BookCopy, Long> {
    List<BookCopy> findByBranchId(Long branchId);
    List<BookCopy> findByBranchIdAndStatus(Long branchId, BookCopyStatus status);
    List<BookCopy> findByBookId(Long bookId);
    List<BookCopy> findByBookIdAndBranchId(Long bookId, Long branchId);
    long countByBranchId(Long branchId);

    List<BookCopy> findBySellerId(Long sellerId);
    long countBySellerId(Long sellerId);
    List<BookCopy> findBySellerIdAndStatus(Long sellerId, BookCopyStatus status);

    @Query("SELECT bc FROM BookCopy bc WHERE bc.branch.id = :branchId AND (:conditionRating IS NULL OR bc.conditionRating = :conditionRating)")
    List<BookCopy> filterBranchCopies(@Param("branchId") Long branchId, @Param("conditionRating") BookCondition conditionRating);
}
