package vn.iotstar.websach.service;

import vn.iotstar.websach.entity.CartItem;
import vn.iotstar.websach.entity.User;

import java.util.List;

public interface CartService {
    List<CartItem> getCartItems(User user);
    CartItem addToCart(User user, Long bookCopyId, Integer quantity);
    CartItem updateCartItemQuantity(User user, Long cartItemId, Integer quantity);
    void removeCartItem(User user, Long cartItemId);
    void clearCart(User user);
    Double getCartTotal(User user);
    Integer getCartCount(User user);
}
