package vn.iotstar.websach.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class VendorChatMessageDTO {
    private Long id;
    private Long conversationId;
    private Long senderId;
    private String senderName;
    private String senderRole;
    private String content;
    private String formattedCreatedAt;
    private boolean isMe;

    // Sản phẩm trao đổi nếu có
    private Long bookCopyId;
    private Long bookId;
    private String bookTitle;
    private String bookCoverUrl;
    private Double bookPrice;
    private String conditionRating;
}
