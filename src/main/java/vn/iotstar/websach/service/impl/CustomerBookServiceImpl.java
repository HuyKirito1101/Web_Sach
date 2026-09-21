package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.Book;
import vn.iotstar.websach.entity.BookCopy;
import vn.iotstar.websach.entity.enums.BookCondition;
import vn.iotstar.websach.entity.enums.BookCopyStatus;
import vn.iotstar.websach.repository.BookCopyRepository;
import vn.iotstar.websach.repository.BookRepository;
import vn.iotstar.websach.repository.ReviewRepository;
import vn.iotstar.websach.service.CustomerBookService;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CustomerBookServiceImpl implements CustomerBookService {

    private final BookRepository bookRepository;
    private final BookCopyRepository bookCopyRepository;
    private final ReviewRepository reviewRepository;

    @Override
    public List<Book> getTop20NewBooks() {
        List<Book> all = bookRepository.findAll();
        all.sort((b1, b2) -> b2.getCreatedAt().compareTo(b1.getCreatedAt()));
        return all.stream().limit(20).collect(Collectors.toList());
    }

    @Override
    public List<Book> getTop20BestSellers() {
        List<Book> all = bookRepository.findAll();
        return all.stream().limit(20).collect(Collectors.toList());
    }

    @Override
    public List<Book> getTop20TopRated() {
        List<Book> all = bookRepository.findAll();
        return all.stream().limit(20).collect(Collectors.toList());
    }

    @Override
    public List<Book> searchAndFilterBooks(String keyword, Long categoryId, Long branchId, BookCondition condition, Double minPrice, Double maxPrice, String sortBy) {
        List<Book> all = bookRepository.findAll();

        return all.stream().filter(book -> {
            boolean matchesKeyword = true;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = keyword.trim().toLowerCase();
                String title = book.getTitle() != null ? book.getTitle().toLowerCase() : "";
                String author = book.getAuthor() != null ? book.getAuthor().getName().toLowerCase() : "";
                String isbn = book.getIsbn() != null ? book.getIsbn().toLowerCase() : "";
                matchesKeyword = title.contains(kw) || author.contains(kw) || isbn.contains(kw);
            }

            boolean matchesCategory = (categoryId == null || (book.getCategory() != null && book.getCategory().getId().equals(categoryId)));

            List<BookCopy> copies = bookCopyRepository.findByBookId(book.getId()).stream()
                    .filter(c -> c.getStatus() == BookCopyStatus.AVAILABLE && c.getSeller() != null)
                    .collect(Collectors.toList());

            boolean matchesBranch = (branchId == null || copies.stream().anyMatch(c -> c.getBranch().getId().equals(branchId)));
            boolean matchesCondition = (condition == null || copies.stream().anyMatch(c -> c.getConditionRating() == condition));

            boolean matchesPrice = true;
            if (minPrice != null || maxPrice != null) {
                matchesPrice = copies.stream().anyMatch(c -> {
                    double price = c.getSellingPrice() != null ? c.getSellingPrice() : 0.0;
                    boolean geMin = (minPrice == null || price >= minPrice);
                    boolean leMax = (maxPrice == null || price <= maxPrice);
                    return geMin && leMax;
                });
            }

            return matchesKeyword && matchesCategory && matchesBranch && matchesCondition && matchesPrice;
        }).collect(Collectors.toList());
    }

    @Override
    public Book getBookById(Long id) {
        return bookRepository.findById(id).orElse(null);
    }

    @Override
    public List<BookCopy> getAvailableBookCopies(Long bookId) {
        Book book = bookRepository.findById(bookId).orElse(null);
        if (book == null) return Collections.emptyList();
        return bookCopyRepository.findByBookId(bookId).stream()
                .filter(c -> c.getStatus() == BookCopyStatus.AVAILABLE && c.getSeller() != null)
                .collect(Collectors.toList());
    }

    @Override
    public Double getAverageRating(Long bookId) {
        Book book = bookRepository.findById(bookId).orElse(null);
        if (book == null) return 5.0;
        Double avg = reviewRepository.getAverageRatingForBook(book);
        return avg != null ? Math.round(avg * 10.0) / 10.0 : 5.0;
    }

    @Override
    public Long getReviewCount(Long bookId) {
        Book book = bookRepository.findById(bookId).orElse(null);
        if (book == null) return 0L;
        Long count = reviewRepository.countReviewsForBook(book);
        return count != null ? count : 0L;
    }
}
