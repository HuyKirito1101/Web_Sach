package vn.iotstar.websach.service;

import vn.iotstar.websach.entity.Favorite;
import vn.iotstar.websach.entity.User;

import java.util.List;

public interface FavoriteService {
    List<Favorite> getUserFavorites(User user);
    boolean toggleFavorite(User user, Long bookId);
    boolean isFavorite(User user, Long bookId);
}
