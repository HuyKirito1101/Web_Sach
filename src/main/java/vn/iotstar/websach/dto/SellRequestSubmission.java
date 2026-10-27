package vn.iotstar.websach.dto;

import lombok.Builder;
import lombok.Getter;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Getter
@Builder
public class SellRequestSubmission {
    private final Long branchId;
    private final String pickupAddress;
    private final String phone;
    private final String note;
    private final List<String> bookTitles;
    private final List<String> isbns;
    private final List<String> conditions;
    private final List<Double> expectedPrices;
    private final List<MultipartFile> imageFiles;
    private final List<String> imageUrls;
}
