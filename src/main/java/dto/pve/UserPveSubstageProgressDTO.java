package dto.pve;

import lombok.Data;
import java.sql.Timestamp;

@Data
public class UserPveSubstageProgressDTO {
    private String userId;      // 사용자 ID
    private int stageLevel;     // 메인 스테이지 레벨
    private int subLevel;       // 하위 스테이지 번호
    private String isCleared;   // 클리어 여부 ('Y')
    private Timestamp clearedAt; // 클리어 시각
}