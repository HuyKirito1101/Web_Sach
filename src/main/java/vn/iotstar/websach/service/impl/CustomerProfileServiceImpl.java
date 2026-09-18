package vn.iotstar.websach.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import vn.iotstar.websach.entity.Address;
import vn.iotstar.websach.entity.User;
import vn.iotstar.websach.repository.AddressRepository;
import vn.iotstar.websach.repository.UserRepository;
import vn.iotstar.websach.service.CustomerProfileService;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class CustomerProfileServiceImpl implements CustomerProfileService {

    private final UserRepository userRepository;
    private final AddressRepository addressRepository;

    @Override
    public User updateProfile(User user, String fullName, String phone, String avatarUrl) {
        if (user == null) return null;
        if (fullName != null && !fullName.trim().isEmpty()) user.setFullName(fullName.trim());
        if (phone != null) user.setPhone(phone.trim());
        if (avatarUrl != null && !avatarUrl.trim().isEmpty()) user.setAvatarUrl(avatarUrl.trim());
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
                .recipientName(recipientName)
                .phone(phone)
                .street(street)
                .ward(ward)
                .district(district)
                .city(city)
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
        List<Address> existing = addressRepository.findByUserOrderByIsDefaultDescCreatedAtDesc(user);
        existing.forEach(a -> {
            a.setIsDefault(a.getId().equals(addressId));
            addressRepository.save(a);
        });
    }
}
