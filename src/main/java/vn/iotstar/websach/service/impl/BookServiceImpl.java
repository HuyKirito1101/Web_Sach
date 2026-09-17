package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import vn.iotstar.websach.entity.Book;
import vn.iotstar.websach.repository.BookRepository;
import vn.iotstar.websach.service.BookService;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class BookServiceImpl implements BookService {

    private final BookRepository bookRepository;

    @Override
    public List<Book> findAllBooks() {
        return bookRepository.findAll();
    }

    @Override
    public Optional<Book> findById(Long id) {
        return bookRepository.findById(id);
    }

    @Override
    public Book saveBook(Book book) {
        return bookRepository.save(book);
    }

    @Override
    public Book updateBook(Long id, Book details) {
        Book book = bookRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Đầu sách không tồn tại: " + id));
        book.setIsbn(details.getIsbn());
        book.setTitle(details.getTitle());
        book.setDescription(details.getDescription());
        book.setCategory(details.getCategory());
        book.setPublisher(details.getPublisher());
        book.setAuthor(details.getAuthor());
        book.setPublishYear(details.getPublishYear());
        book.setLanguage(details.getLanguage());
        if (details.getCoverUrl() != null) {
            book.setCoverUrl(details.getCoverUrl());
        }
        return bookRepository.save(book);
    }

    @Override
    public void deleteBook(Long id) {
        bookRepository.deleteById(id);
    }

    @Override
    public List<Book> searchBooks(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return bookRepository.findAll();
        }
        return bookRepository.searchBooks(keyword.trim());
    }
}
