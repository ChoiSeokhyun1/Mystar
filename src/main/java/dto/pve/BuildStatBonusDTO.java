package dto.pve;

import lombok.Data;

/** 빌드별 능력치 가산점 */
@Data
public class BuildStatBonusDTO {
    private int    bonusId;
    private int    buildId;
    private String statName;   // attack / defense / macro / micro / luck
    private double bonusMult;  // 가산 배율 (예: 1.3)
}