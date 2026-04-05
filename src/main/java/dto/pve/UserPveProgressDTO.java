package dto.pve; // (★) pve 패키지 사용

import lombok.Data; // (★) @Data 어노테이션 임포트
import java.sql.Timestamp;

@Data // (★) Getter, Setter, toString, EqualsAndHashCode, RequiredArgsConstructor 자동 생성
public class UserPveProgressDTO {
    private String userId;      // tbl_users.user_id 참조
    private int stageLevel;     // 스테이지 레벨 (1~10)
    private String stageStatus; // "CLEARE D", "IN_PROGRESS", "LOCKED"
    private Timestamp updatedAt;  // 마지막 업데이트 시각
}