package vn.iotstar.websach.service;

import org.springframework.web.multipart.MultipartFile;
import vn.iotstar.websach.dto.MasterBookRequest;
import vn.iotstar.websach.entity.Book;

import java.util.List;
import java.util.Optional;

public interface BookService {
    List<Book> findAllBooks();
    Optional<Book> findById(Long id);
    Book saveBook(Book book);
    Book createMasterBook(MasterBookRequest request, MultipartFile coverFile);
    Book updateBook(Long id, Book bookDetails);
    void deleteBook(Long id);
    List<Book> searchBooks(String keyword);
}
