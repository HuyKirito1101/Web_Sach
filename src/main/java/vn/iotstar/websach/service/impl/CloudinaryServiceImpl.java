package vn.iotstar.websach.service.impl;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import vn.iotstar.websach.service.CloudinaryService;

import java.io.IOException;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class CloudinaryServiceImpl implements CloudinaryService {

    private static final long MAX_UPLOAD_BYTES = 10L * 1024 * 1024;
    private static final Set<String> ALLOWED_EXTENSIONS =
            Set.of("jpg", "jpeg", "png", "gif", "webp", "mp4", "webm");

    private final Cloudinary cloudinary;

    @Override
    public String uploadFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return null;
        }

        byte[] content;
        try {
            content = file.getBytes();
        } catch (IOException e) {
            throw new IllegalStateException("Không thể đọc tệp tải lên.", e);
        }

        String detectedMime = validateAndDetectMime(file, content);
        String resourceType = detectedMime.startsWith("video/") ? "video" : "image";

        try {
            Map uploadResult = cloudinary.uploader().upload(content, ObjectUtils.asMap(
                    "folder", "websach_cu",
                    "resource_type", resourceType,
                    "public_id", UUID.randomUUID().toString(),
                    "use_filename", false,
                    "unique_filename", true,
                    "overwrite", false));
            String secureUrl = (String) uploadResult.get("secure_url");
            if (secureUrl == null || secureUrl.isBlank()) {
                throw new IllegalStateException("Cloudinary không trả về đường dẫn tệp đã tải lên.");
            }
            return secureUrl;
        } catch (Exception e) {
            log.error("Không thể tải tệp {} lên Cloudinary",
                    file.getOriginalFilename(), e);
            throw new IllegalStateException(
                    "Không thể tải tệp lên Cloudinary. Vui lòng kiểm tra cấu hình hoặc thử lại.", e);
        }
    }

    private String validateAndDetectMime(MultipartFile file, byte[] content) {
        if (content.length > MAX_UPLOAD_BYTES) {
            throw new IllegalArgumentException("Tệp tải lên không được vượt quá 10 MB.");
        }

        String filename = file.getOriginalFilename() == null ? "" : file.getOriginalFilename();
        int dot = filename.lastIndexOf('.');
        String extension = dot >= 0 ? filename.substring(dot + 1).toLowerCase(Locale.ROOT) : "";
        if (!ALLOWED_EXTENSIONS.contains(extension)) {
            throw new IllegalArgumentException("Chỉ chấp nhận JPG, PNG, GIF, WEBP, MP4 hoặc WEBM.");
        }

        String detectedMime = detectMime(content);
        if (detectedMime == null || !extensionMatches(extension, detectedMime)) {
            throw new IllegalArgumentException("Nội dung tệp không khớp với định dạng được phép.");
        }

        String declaredMime = file.getContentType();
        if (declaredMime != null && !declaredMime.isBlank()
                && !declaredMime.equalsIgnoreCase(detectedMime)) {
            throw new IllegalArgumentException("Loại nội dung tệp không hợp lệ.");
        }
        return detectedMime;
    }

    private String detectMime(byte[] bytes) {
        if (startsWith(bytes, 0xFF, 0xD8, 0xFF)) return "image/jpeg";
        if (startsWith(bytes, 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)) return "image/png";
        if (startsWithAscii(bytes, "GIF87a") || startsWithAscii(bytes, "GIF89a")) return "image/gif";
        if (bytes.length >= 12 && startsWithAscii(bytes, "RIFF")
                && asciiAt(bytes, 8, "WEBP")) return "image/webp";
        if (bytes.length >= 12 && asciiAt(bytes, 4, "ftyp")) return "video/mp4";
        if (startsWith(bytes, 0x1A, 0x45, 0xDF, 0xA3)) return "video/webm";
        return null;
    }

    private boolean extensionMatches(String extension, String mime) {
        return switch (mime) {
            case "image/jpeg" -> extension.equals("jpg") || extension.equals("jpeg");
            case "image/png" -> extension.equals("png");
            case "image/gif" -> extension.equals("gif");
            case "image/webp" -> extension.equals("webp");
            case "video/mp4" -> extension.equals("mp4");
            case "video/webm" -> extension.equals("webm");
            default -> false;
        };
    }

    private boolean startsWith(byte[] bytes, int... signature) {
        if (bytes.length < signature.length) return false;
        for (int i = 0; i < signature.length; i++) {
            if ((bytes[i] & 0xFF) != signature[i]) return false;
        }
        return true;
    }

    private boolean startsWithAscii(byte[] bytes, String value) {
        return asciiAt(bytes, 0, value);
    }

    private boolean asciiAt(byte[] bytes, int offset, String value) {
        if (bytes.length < offset + value.length()) return false;
        for (int i = 0; i < value.length(); i++) {
            if (bytes[offset + i] != (byte) value.charAt(i)) return false;
        }
        return true;
    }
}
