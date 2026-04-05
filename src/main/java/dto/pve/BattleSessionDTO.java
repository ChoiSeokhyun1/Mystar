package dto.pve;

import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.Date;

@Data
@NoArgsConstructor
public class BattleSessionDTO {
    
    private int battleId;
    private String userId;
    private int stageLevel;
    private int subLevel;
    
    // (★) 진행 상태를 저장할 필드 추가
    private int currentSet; 
    private int myWins;
    private int aiWins;
    private String gameStateData; // (★★★ 이 줄을 추가하세요)
    
    private String matchupData;     // 5세트 확정 정보 (JSON/CLOB)
    private String myTeamData;
    private String aiTeamData;
    private String setResultsData;  // 세트별 결과 추적 (JSON/CLOB) — 세션 만료 복구용

    private String status;      // 'IN_PROGRESS' or 'COMPLETED'
    private Date createdAt;
}