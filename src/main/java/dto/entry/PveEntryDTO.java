package dto.entry; // 엔트리 관련 DTO 패키지

import lombok.Data;

@Data // Lombok: Getter, Setter, ToString 등 자동 생성
public class PveEntryDTO {
    
    // TBL_PVE_ENTRY 테이블 컬럼
    private int pveEntrySeq;    // 엔트리 고유 번호 (PK)
    private String userId;         // 유저 ID (FK)
    private int ownedPlayerSeq; // 보유 선수 고유 번호 (FK)
    private int slotNumber;       // 슬롯 번호 (1 ~ 7)

    // (참고) JOIN 쿼리 사용 시,
    // 이 DTO에 선수 이름, 등급 등을 추가로 선언하여 한 번에 받아올 수도 있습니다.
    // (예: private String playerName; private String currentRarity;)
}