package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.Address;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.repository.AddressRepository;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.service.CustomerProfileService;

import java.net.URI;
import java.util.List;
import java.util.regex.Pattern;

@Service
@RequiredArgsConstructor
@Transactional
public class CustomerProfileServiceImpl implements CustomerProfileService {

    private static final Pattern PHONE_PATTERN = Pattern.compile("^[0-9+().\\s-]{8,20}$");

    private final UserRepository userRepository;
    private final AddressRepository addressRepository;

    @Override
    public User updateProfile(User user, String fullName, String phone, String avatarUrl) {
        if (user == null) return null;
        user.setFullName(requiredText(fullName, "Họ tên", 100));
        user.setPhone(optionalPhone(phone));
        user.setAvatarUrl(optionalHttpsUrl(avatarUrl));
        return userRepository.save(user);
    }

    @Override
    @Transactional(readOnly = true)
    public List<Address> getUserAddresses(User user) {
        if (user == null) return List.of();
        return addressRepository.findByUserOrderByIsDefaultDescCreatedAtDesc(user);
    }

    @Override
    public Address addAddress(User user, String recipientName, String phone, String street, String ward, String district, String city, Boolean isDefault) {
        if (user == null) throw new IllegalArgumentException("User null");

        String safeRecipientName = requiredText(recipientName, "Tên người nhận", 100);
        String safePhone = requiredPhone(phone);
        String safeStreet = requiredText(street, "Địa chỉ", 255);
        String safeWard = optionalText(ward, "Phường/xã", 100);
        String safeDistrict = optionalText(district, "Quận/huyện", 100);
        String safeCity = requiredText(city, "Tỉnh/thành phố", 100);

        boolean makeDefault = Boolean.TRUE.equals(isDefault);
        List<Address> existing = addressRepository.findByUserOrderByIsDefaultDescCreatedAtDesc(user);
        if (existing.isEmpty()) {
            makeDefault = true;
        }

        if (makeDefault) {
            existing.forEach(a -> {
                a.setIsDefault(false);
                addressRepository.save(a);
            });
        }

        Address address = Address.builder()
                .user(user)
                .recipientName(safeRecipientName)
                .phone(safePhone)
                .street(safeStreet)
                .ward(safeWard)
                .district(safeDistrict)
                .city(safeCity)
                .isDefault(makeDefault)
                .build();

        return addressRepository.save(address);
    }

    @Override
    public void deleteAddress(User user, Long addressId) {
        Address addr = addressRepository.findByIdAndUser(addressId, user).orElse(null);
        if (addr != null) {
            addressRepository.delete(addr);
        }
    }

    @Override
    public void setDefaultAddress(User user, Long addressId) {
        if (user == null || addressId == null || addressRepository.findByIdAndUser(addressId, user).isEmpty()) {
            throw new IllegalArgumentException("Địa chỉ không hợp lệ.");
        }
        List<Address> existing = addressRepository.findByUserOrderByIsDefaultDescCreatedAtDesc(user);
        existing.forEach(a -> {
            a.setIsDefault(a.getId().equals(addressId));
            addressRepository.save(a);
        });
    }

    private String requiredText(String value, String fieldName, int maxLength) {
        String normalized = value == null ? "" : value.trim();
        if (normalized.isEmpty() || normalized.length() > maxLength) {
            throw new IllegalArgumentException(fieldName + " phải có từ 1 đến " + maxLength + " ký tự.");
        }
        return normalized;
    }

    private String optionalText(String value, String fieldName, int maxLength) {
        if (value == null || value.isBlank()) return null;
        return requiredText(value, fieldName, maxLength);
    }

    private String requiredPhone(String value) {
        String normalized = requiredText(value, "Số điện thoại", 20);
        if (!PHONE_PATTERN.matcher(normalized).matches()) {
            throw new IllegalArgumentException("Số điện thoại không đúng định dạng.");
        }
        return normalized;
    }

    private String optionalPhone(String value) {
        if (value == null || value.isBlank()) return null;
        return requiredPhone(value);
    }

    private String optionalHttpsUrl(String value) {
        if (value == null || value.isBlank()) return null;
        String normalized = requiredText(value, "URL ảnh đại diện", 500);
        try {
            URI uri = URI.create(normalized);
            if (!"https".equalsIgnoreCase(uri.getScheme()) || uri.getHost() == null || uri.getUserInfo() != null) {
                throw new IllegalArgumentException("URL ảnh đại diện phải là liên kết HTTPS hợp lệ.");
            }
            return uri.toASCIIString();
        } catch (IllegalArgumentException e) {
            throw new IllegalArgumentException("URL ảnh đại diện phải là liên kết HTTPS hợp lệ.");
        }
    }
}
