package vn.iotstar.websach.service;

import vn.iotstar.websach.entity.Book;
import vn.iotstar.websach.entity.BookCopy;
import vn.iotstar.websach.entity.enums.BookCondition;

import java.util.List;

public interface CustomerBookService {
    List<Book> getTop10ByPriceDesc();
    List<Book> getTop20NewBooks();
    List<Book> getTop20BestSellers();
    List<Book> getTop20TopRated();
    List<Book> getTop20MostFavorite();
    List<Book> searchAndFilterBooks(String keyword, Long categoryId, Long branchId, BookCondition condition, Double minPrice, Double maxPrice, String sortBy);
    Book getBookById(Long id);
    List<BookCopy> getAvailableBookCopies(Long bookId);
    Double getAverageRating(Long bookId);
    Long getReviewCount(Long bookId);
}
