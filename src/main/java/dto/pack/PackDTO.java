package dto.pack; // 팩 관련 DTO 패키지

import lombok.Data;

@Data
public class PackDTO {
    private int packSeq;         // 팩 고유 번호 (NUMBER -> int)
    private String packName;     // 팩 이름 (VARCHAR2 -> String)
    private String description;  // 팩 설명 (VARCHAR2 -> String)
    private int costCrystal;     // 1회 뽑기 크리스탈 비용 (NUMBER -> int)
    private String bannerImgUrl; // 배너 이미지 URL (VARCHAR2 -> String)
    private String isAvailable;  // 판매 여부 (CHAR -> String, 'Y'/'N')
}