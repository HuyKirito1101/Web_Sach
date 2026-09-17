package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.BookCopy;
import vn.iotstar.websach.entity.enums.BookCondition;
import vn.iotstar.websach.entity.enums.BookCopyStatus;
import vn.iotstar.websach.repository.BookCopyRepository;
import vn.iotstar.websach.service.BookCopyService;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class BookCopyServiceImpl implements BookCopyService {

    private final BookCopyRepository bookCopyRepository;

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
