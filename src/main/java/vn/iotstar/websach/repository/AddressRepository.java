package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.iotstar.websach.entity.Address;
import vn.iotstar.websach.entity.User;

import java.util.List;
import java.util.Optional;

@Repository
public interface AddressRepository extends JpaRepository<Address, Long> {
    List<Address> findByUserOrderByIsDefaultDescCreatedAtDesc(User user);
    Optional<Address> findByUserAndIsDefaultTrue(User user);
    Optional<Address> findByIdAndUser(Long id, User user);
}
