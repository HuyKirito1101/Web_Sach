package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import vn.iotstar.websach.dto.MasterBookRequest;
import vn.iotstar.websach.entity.Author;
import vn.iotstar.websach.entity.Book;
import vn.iotstar.websach.entity.Category;
import vn.iotstar.websach.entity.Publisher;
import vn.iotstar.websach.repository.AuthorRepository;
import vn.iotstar.websach.repository.BookRepository;
import vn.iotstar.websach.repository.CategoryRepository;
import vn.iotstar.websach.repository.PublisherRepository;
import vn.iotstar.websach.service.BookService;
import vn.iotstar.websach.service.CloudinaryService;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class BookServiceImpl implements BookService {

    private final BookRepository bookRepository;
    private final AuthorRepository authorRepository;
    private final PublisherRepository publisherRepository;
    private final CategoryRepository categoryRepository;
    private final CloudinaryService cloudinaryService;

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
    @Transactional
    public Book createMasterBook(MasterBookRequest request, MultipartFile coverFile) {
        if (request.getTitle() == null || request.getTitle().isBlank()) {
            throw new IllegalArgumentException("Tên sách không được để trống.");
        }
        String coverUrl = request.getCoverUrl();
        if (coverFile != null && !coverFile.isEmpty()) {
            coverUrl = cloudinaryService.uploadFile(coverFile);
        }
        if (coverUrl == null || coverUrl.isBlank()) {
            coverUrl = "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500&q=80";
        }

        Category category = request.getCategoryId() == null ? null
                : categoryRepository.findById(request.getCategoryId()).orElse(null);
        Author author = null;
        if (request.getAuthorName() != null && !request.getAuthorName().isBlank()) {
            String name = request.getAuthorName().trim();
            author = authorRepository.findByName(name)
                    .orElseGet(() -> authorRepository.save(Author.builder().name(name).build()));
        }
        Publisher publisher = null;
        if (request.getPublisherName() != null && !request.getPublisherName().isBlank()) {
            String name = request.getPublisherName().trim();
            publisher = publisherRepository.findByName(name)
                    .orElseGet(() -> publisherRepository.save(Publisher.builder().name(name).build()));
        }

        return bookRepository.save(Book.builder()
                .title(request.getTitle().trim())
                .isbn(request.getIsbn())
                .author(author)
                .publisher(publisher)
                .publishYear(request.getPublishYear())
                .category(category)
                .coverUrl(coverUrl.trim())
                .build());
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
