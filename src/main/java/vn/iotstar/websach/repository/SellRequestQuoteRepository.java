package vn.iotstar.websach.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import vn.iotstar.websach.entity.SellRequestQuote;

import java.util.List;
import java.util.Optional;

public interface SellRequestQuoteRepository extends JpaRepository<SellRequestQuote, Long> {
    List<SellRequestQuote> findBySellRequestIdOrderByCreatedAtDesc(Long sellRequestId);
    Optional<SellRequestQuote> findBySellRequestIdAndVendorId(Long sellRequestId, Long vendorId);
    List<SellRequestQuote> findByVendorId(Long vendorId);
    void deleteBySellRequestId(Long sellRequestId);
}
