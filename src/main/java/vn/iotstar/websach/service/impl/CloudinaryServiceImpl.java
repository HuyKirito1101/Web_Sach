package vn.iotstar.websach.service.impl;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import vn.iotstar.websach.service.CloudinaryService;

import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class CloudinaryServiceImpl implements CloudinaryService {

    private final Cloudinary cloudinary;

    @Override
    public String uploadFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return null;
        }
        try {
            Map uploadResult = cloudinary.uploader().upload(file.getBytes(), ObjectUtils.asMap("folder", "websach_cu"));
            return (String) uploadResult.get("secure_url");
        } catch (Exception e) {
            log.error("Loi upload anh Cloudinary: {}", e.getMessage());
            // Fallback placeholder image URL if credentials not provided
            return "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500&q=80";
        }
    }
}
