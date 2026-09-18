package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.Book;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.entity.ViewedProduct;
import vn.iotstar.websach.repository.BookRepository;
import vn.iotstar.websach.repository.ViewedProductRepository;
import vn.iotstar.websach.service.ViewedProductService;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class ViewedProductServiceImpl implements ViewedProductService {

    private final ViewedProductRepository viewedProductRepository;
    private final BookRepository bookRepository;

    @Override
    public void recordView(User user, Long bookId) {
        if (user == null || bookId == null) return;
        Book book = bookRepository.findById(bookId).orElse(null);
        if (book == null) return;

        Optional<ViewedProduct> opt = viewedProductRepository.findByUserAndBook(user, book);
        ViewedProduct vp;
        if (opt.isPresent()) {
            vp = opt.get();
        } else {
            vp = ViewedProduct.builder().user(user).book(book).build();
        }
        viewedProductRepository.save(vp);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ViewedProduct> getUserViewedProducts(User user) {
        if (user == null) return List.of();
        return viewedProductRepository.findByUserOrderByViewedAtDesc(user);
    }
}
