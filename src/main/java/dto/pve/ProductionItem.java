package dto.pve;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProductionItem {
    private String entityId;     // 엔티티 ID (예: "scv", "marine")
    private String name;          // 이름 (예: "SCV", "마린")
    private int endTime;          // 완성 시간 (게임 시간)
    private String type;          // 타입 ("building" or "unit")
    private int scriptStep = -1;  // AI 스크립트 단계 (-1 = 유저 생산)
    private int queueStatus = 0;  // 큐 상태 (0 = 생산중, 1 = 대기중)
    private int attackGroupId = -1; // 공격 그룹 ID (어느 [공격] 명령 전인지)
}