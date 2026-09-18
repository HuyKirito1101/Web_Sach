package vn.iotstar.websach.service;

import vn.iotstar.websach.entity.Address;
import vn.iotstar.websach.entity.User;

import java.util.List;

public interface CustomerProfileService {
    User updateProfile(User user, String fullName, String phone, String avatarUrl);
    List<Address> getUserAddresses(User user);
    Address addAddress(User user, String recipientName, String phone, String street, String ward, String district, String city, Boolean isDefault);
    void deleteAddress(User user, Long addressId);
    void setDefaultAddress(User user, Long addressId);
}
