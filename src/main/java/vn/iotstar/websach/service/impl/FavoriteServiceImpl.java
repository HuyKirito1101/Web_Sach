package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.Book;
import vn.iotstar.websach.entity.Favorite;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.repository.BookRepository;
import vn.iotstar.websach.repository.FavoriteRepository;
import vn.iotstar.websach.service.FavoriteService;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional
public class FavoriteServiceImpl implements FavoriteService {

    private final FavoriteRepository favoriteRepository;
    private final BookRepository bookRepository;

    @Override
    @Transactional(readOnly = true)
    public List<Favorite> getUserFavorites(User user) {
        if (user == null) return List.of();
        return favoriteRepository.findByUserOrderByCreatedAtDesc(user);
    }

    @Override
    public boolean toggleFavorite(User user, Long bookId) {
        if (user == null) return false;
        Book book = bookRepository.findById(bookId).orElse(null);
        if (book == null) return false;

        Optional<Favorite> opt = favoriteRepository.findByUserAndBook(user, book);
        if (opt.isPresent()) {
            favoriteRepository.delete(opt.get());
            return false;
        } else {
            Favorite favorite = Favorite.builder().user(user).book(book).build();
            favoriteRepository.save(favorite);
            return true;
        }
    }

    @Override
    @Transactional(readOnly = true)
    public boolean isFavorite(User user, Long bookId) {
        if (user == null) return false;
        Book book = bookRepository.findById(bookId).orElse(null);
        if (book == null) return false;
        return favoriteRepository.existsByUserAndBook(user, book);
    }
}
