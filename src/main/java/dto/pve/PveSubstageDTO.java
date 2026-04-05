package dto.pve;

import lombok.Data;

@Data
public class PveSubstageDTO {
    private int stageLevel;   // 메인 스테이지 레벨
    private int subLevel;     // 하위 스테이지 번호
    private String subTitle;  // 하위 스테이지 제목
    private String opponentTeamName;
    // (★) 테이블에 추가한 컬럼이 있다면 여기에 필드 추가
    // private String enemyInfo;
    // private String rewardInfo;
    // private int requiredCost;
}