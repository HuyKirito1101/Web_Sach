package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.BookCopy;
import vn.iotstar.websach.entity.CartItem;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.repository.BookCopyRepository;
import vn.iotstar.websach.repository.CartItemRepository;
import vn.iotstar.websach.service.CartService;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class CartServiceImpl implements CartService {

    private final CartItemRepository cartItemRepository;
    private final BookCopyRepository bookCopyRepository;

    @Override
    @Transactional(readOnly = true)
    public List<CartItem> getCartItems(User user) {
        if (user == null) return List.of();
        return cartItemRepository.findByUserOrderByCreatedAtDesc(user);
    }

    @Override
    public CartItem addToCart(User user, Long bookCopyId, Integer quantity) {
        if (user == null) throw new IllegalArgumentException("User null");
        BookCopy copy = bookCopyRepository.findById(bookCopyId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy sản phẩm bản sao sách!"));

        int availableStock = copy.getQuantity() != null ? copy.getQuantity() : 0;
        if (availableStock <= 0) {
            throw new IllegalArgumentException("Sản phẩm này hiện đã hết hàng!");
        }

        int qtyToAdd = (quantity != null && quantity > 0) ? quantity : 1;

        CartItem item = cartItemRepository.findByUserAndBookCopy(user, copy).orElse(null);
        int currentQty = (item != null && item.getQuantity() != null) ? item.getQuantity() : 0;
        if (currentQty + qtyToAdd > availableStock) {
            throw new IllegalArgumentException("Không thể thêm vào giỏ. Tổng số lượng (" 
                    + (currentQty + qtyToAdd) + ") vượt quá tồn kho hiện có (" + availableStock + ")!");
        }

        if (item != null) {
            item.setQuantity(item.getQuantity() + qtyToAdd);
        } else {
            item = CartItem.builder()
                    .user(user)
                    .bookCopy(copy)
                    .quantity(qtyToAdd)
                    .build();
        }
        return cartItemRepository.save(item);
    }

    @Override
    public CartItem updateCartItemQuantity(User user, Long cartItemId, Integer quantity) {
        CartItem item = cartItemRepository.findByIdAndUser(cartItemId, user)
                .orElseThrow(() -> new IllegalArgumentException("Mục giỏ hàng không tồn tại!"));

        if (quantity == null || quantity <= 0) {
            cartItemRepository.delete(item);
            return null;
        }

        int availableStock = item.getBookCopy().getQuantity() != null ? item.getBookCopy().getQuantity() : 0;
        if (quantity > availableStock) {
            throw new IllegalArgumentException("Số lượng yêu cầu (" + quantity + ") vượt quá tồn kho hiện có (" + availableStock + ")!");
        }

        item.setQuantity(quantity);
        return cartItemRepository.save(item);
    }

    @Override
    public void removeCartItem(User user, Long cartItemId) {
        CartItem item = cartItemRepository.findByIdAndUser(cartItemId, user).orElse(null);
        if (item != null) {
            cartItemRepository.delete(item);
        }
    }

    @Override
    public void clearCart(User user) {
        if (user != null) {
            cartItemRepository.deleteByUser(user);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public Double getCartTotal(User user) {
        List<CartItem> items = getCartItems(user);
        return items.stream()
                .mapToDouble(i -> (i.getBookCopy().getSellingPrice() != null ? i.getBookCopy().getSellingPrice() : 0.0) * i.getQuantity())
                .sum();
    }

    @Override
    @Transactional(readOnly = true)
    public Integer getCartCount(User user) {
        List<CartItem> items = getCartItems(user);
        return items.stream().mapToInt(CartItem::getQuantity).sum();
    }
}
