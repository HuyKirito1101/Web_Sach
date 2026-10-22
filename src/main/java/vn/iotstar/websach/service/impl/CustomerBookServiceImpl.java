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
import vn.iotstar.websach.repository.FavoriteRepository;
import vn.iotstar.websach.repository.OrderItemRepository;
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
    private final FavoriteRepository favoriteRepository;
    private final OrderItemRepository orderItemRepository;

    @Override
    public List<Book> getTop10BestSellers() {
        List<Book> all = bookRepository.findAll();
        Map<Long, Long> soldMap = new HashMap<>();
        for (Book b : all) {
            Long soldOrders = orderItemRepository.getSoldQuantityByBookId(b.getId());
            long soldFromOrders = soldOrders != null ? soldOrders : 0L;
            long soldCopies = bookCopyRepository.findByBookId(b.getId()).stream()
                    .filter(c -> c.getStatus() == BookCopyStatus.SOLD).count();
            soldMap.put(b.getId(), Math.max(soldFromOrders, soldCopies));
        }

        // Lọc các sách bán trên 10 cuốn, xếp theo số lượng bán giảm dần
        List<Book> over10Sold = all.stream()
                .filter(b -> soldMap.getOrDefault(b.getId(), 0L) >= 10)
                .sorted((b1, b2) -> Long.compare(soldMap.getOrDefault(b2.getId(), 0L), soldMap.getOrDefault(b1.getId(), 0L)))
                .limit(10)
                .collect(Collectors.toList());

        if (over10Sold.size() >= 10) {
            return over10Sold;
        }

        // Bổ sung các cuốn bán chạy theo số lượng giảm dần để đủ top 10
        Set<Long> pickedIds = over10Sold.stream().map(Book::getId).collect(Collectors.toSet());
        List<Book> remainingBestSellers = all.stream()
                .filter(b -> !pickedIds.contains(b.getId()))
                .sorted((b1, b2) -> Long.compare(soldMap.getOrDefault(b2.getId(), 0L), soldMap.getOrDefault(b1.getId(), 0L)))
                .limit(10 - over10Sold.size())
                .collect(Collectors.toList());

        over10Sold.addAll(remainingBestSellers);
        return over10Sold;
    }

    /**
     * Top 10 sản phẩm sắp xếp giá bán cao → thấp (dựa trên giá cao nhất của các bản copy)
     */
    @Override
    public List<Book> getTop10ByPriceDesc() {
        List<Book> all = bookRepository.findAll();
        // Sắp xếp theo giá bán cao nhất trong các bản copy
        all.sort((b1, b2) -> {
            double p1 = getMaxPrice(b1.getId());
            double p2 = getMaxPrice(b2.getId());
            return Double.compare(p2, p1); // giảm dần
        });
        return all.stream().limit(10).collect(Collectors.toList());
    }

    private double getMaxPrice(Long bookId) {
        return bookCopyRepository.findByBookId(bookId).stream()
                .filter(c -> c.getStatus() == BookCopyStatus.AVAILABLE && c.getSellingPrice() != null)
                .mapToDouble(BookCopy::getSellingPrice)
                .max()
                .orElse(0.0);
    }

    @Override
    public List<Book> getTop20NewBooks() {
        List<Book> all = bookRepository.findAll();
        all.sort((b1, b2) -> {
            if (b2.getCreatedAt() == null && b1.getCreatedAt() == null) return 0;
            if (b2.getCreatedAt() == null) return -1;
            if (b1.getCreatedAt() == null) return 1;
            return b2.getCreatedAt().compareTo(b1.getCreatedAt());
        });
        return all.stream().limit(20).collect(Collectors.toList());
    }

    @Override
    public List<Book> getTop20BestSellers() {
        // Sắp xếp theo số lượng bản copy bán được (số copy với status SOLD)
        List<Book> all = bookRepository.findAll();
        all.sort((b1, b2) -> {
            long sold1 = bookCopyRepository.findByBookId(b1.getId()).stream()
                    .filter(c -> c.getStatus() == BookCopyStatus.SOLD).count();
            long sold2 = bookCopyRepository.findByBookId(b2.getId()).stream()
                    .filter(c -> c.getStatus() == BookCopyStatus.SOLD).count();
            return Long.compare(sold2, sold1);
        });
        return all.stream().limit(20).collect(Collectors.toList());
    }

    @Override
    public List<Book> getTop20TopRated() {
        List<Book> all = bookRepository.findAll();
        all.sort((b1, b2) -> {
            Double r1 = reviewRepository.getAverageRatingForBook(b1);
            Double r2 = reviewRepository.getAverageRatingForBook(b2);
            double v1 = r1 != null ? r1 : 0.0;
            double v2 = r2 != null ? r2 : 0.0;
            return Double.compare(v2, v1);
        });
        return all.stream().limit(20).collect(Collectors.toList());
    }

    @Override
    public List<Book> getTop20MostFavorite() {
        // Lấy danh sách sách được yêu thích nhiều nhất
        List<Object[]> rows = favoriteRepository.findTopFavoriteBooks();
        List<Book> result = rows.stream()
                .map(r -> (Book) r[0])
                .limit(20)
                .collect(Collectors.toList());
        // Nếu chưa đủ 20, bổ sung bằng sách mới nhất
        if (result.size() < 20) {
            Set<Long> existingIds = result.stream().map(Book::getId).collect(Collectors.toSet());
            List<Book> all = bookRepository.findAll();
            for (Book b : all) {
                if (!existingIds.contains(b.getId())) {
                    result.add(b);
                    if (result.size() >= 20) break;
                }
            }
        }
        return result;
    }

    @Override
    public List<Book> searchAndFilterBooks(String keyword, Long categoryId, Long branchId, BookCondition condition, Double minPrice, Double maxPrice, String sortBy) {
        List<Book> all = bookRepository.findAll();

        List<Book> filtered = all.stream().filter(book -> {
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

        // Sắp xếp
        if (sortBy != null) {
            switch (sortBy) {
                case "price_asc":
                    filtered.sort(Comparator.comparingDouble(b -> getMaxPrice(b.getId())));
                    break;
                case "price_desc":
                    filtered.sort((b1, b2) -> Double.compare(getMaxPrice(b2.getId()), getMaxPrice(b1.getId())));
                    break;
                case "newest":
                    filtered.sort((b1, b2) -> {
                        if (b2.getCreatedAt() == null && b1.getCreatedAt() == null) return 0;
                        if (b2.getCreatedAt() == null) return -1;
                        if (b1.getCreatedAt() == null) return 1;
                        return b2.getCreatedAt().compareTo(b1.getCreatedAt());
                    });
                    break;
                case "best_seller":
                    filtered.sort((b1, b2) -> {
                        long s1 = bookCopyRepository.findByBookId(b1.getId()).stream().filter(c -> c.getStatus() == BookCopyStatus.SOLD).count();
                        long s2 = bookCopyRepository.findByBookId(b2.getId()).stream().filter(c -> c.getStatus() == BookCopyStatus.SOLD).count();
                        return Long.compare(s2, s1);
                    });
                    break;
                case "top_rated":
                    filtered.sort((b1, b2) -> {
                        Double r1 = reviewRepository.getAverageRatingForBook(b1);
                        Double r2 = reviewRepository.getAverageRatingForBook(b2);
                        return Double.compare(r2 != null ? r2 : 0.0, r1 != null ? r1 : 0.0);
                    });
                    break;
                case "most_favorite":
                    filtered.sort((b1, b2) -> {
                        long f1 = favoriteRepository.countByBook(b1);
                        long f2 = favoriteRepository.countByBook(b2);
                        return Long.compare(f2, f1);
                    });
                    break;
                default:
                    break;
            }
        }

        return filtered;
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
