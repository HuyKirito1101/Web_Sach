package vn.iotstar.websach.service.impl;

import com.cloudinary.Cloudinary;
import com.cloudinary.Uploader;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockMultipartFile;

import java.io.IOException;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class CloudinaryServiceImplTest {

    private static final byte[] VALID_JPEG = new byte[]{
            (byte) 0xFF, (byte) 0xD8, (byte) 0xFF, (byte) 0xE0, 0x00, 0x10
    };

    @Test
    void returnsSecureUrlWhenUploadSucceeds() throws IOException {
        Cloudinary cloudinary = mock(Cloudinary.class);
        Uploader uploader = mock(Uploader.class);
        when(cloudinary.uploader()).thenReturn(uploader);
        when(uploader.upload(any(byte[].class), any(Map.class)))
                .thenReturn(Map.of("secure_url", "https://res.cloudinary.com/demo/image/upload/book.jpg"));

        CloudinaryServiceImpl service = new CloudinaryServiceImpl(cloudinary);
        MockMultipartFile file = new MockMultipartFile(
                "imageFile", "book.jpg", "image/jpeg", VALID_JPEG);

        assertThat(service.uploadFile(file))
                .isEqualTo("https://res.cloudinary.com/demo/image/upload/book.jpg");
    }

    @Test
    void throwsClearErrorInsteadOfReturningPlaceholderWhenUploadFails() throws IOException {
        Cloudinary cloudinary = mock(Cloudinary.class);
        Uploader uploader = mock(Uploader.class);
        when(cloudinary.uploader()).thenReturn(uploader);
        when(uploader.upload(any(byte[].class), any(Map.class)))
                .thenThrow(new IOException("Invalid credentials"));

        CloudinaryServiceImpl service = new CloudinaryServiceImpl(cloudinary);
        MockMultipartFile file = new MockMultipartFile(
                "imageFile", "book.jpg", "image/jpeg", VALID_JPEG);

        assertThatThrownBy(() -> service.uploadFile(file))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("Không thể tải tệp lên Cloudinary. Vui lòng kiểm tra cấu hình hoặc thử lại.")
                .hasCauseInstanceOf(IOException.class);
    }

    @Test
    void emptyFileDoesNotTriggerUpload() {
        CloudinaryServiceImpl service = new CloudinaryServiceImpl(mock(Cloudinary.class));

        assertThat(service.uploadFile(null)).isNull();
        assertThat(service.uploadFile(new MockMultipartFile(
                "imageFile", "", "image/jpeg", new byte[0]))).isNull();
    }

    @Test
    void rejectsExecutableDisguisedAsImage() {
        CloudinaryServiceImpl service = new CloudinaryServiceImpl(mock(Cloudinary.class));
        MockMultipartFile file = new MockMultipartFile(
                "imageFile", "payload.jpg", "image/jpeg", "MZ executable".getBytes());

        assertThatThrownBy(() -> service.uploadFile(file))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("Nội dung tệp không khớp với định dạng được phép.");
    }
}
