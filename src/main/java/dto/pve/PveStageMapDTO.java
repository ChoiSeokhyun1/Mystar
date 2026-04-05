package dto.pve;

import lombok.Data;

@Data
public class PveStageMapDTO {
    // TBL_PVE_SUBSTAGE_MAPS
    private int setNumber;    // 세트 번호 (1~5)
    
    // TBL_MAPS (JOIN)
    private String mapId;       // 맵 고유 ID
    private String mapName;     // 맵 이름
    private String description; // 맵 설명
    private double winRateT;    // 테란 승률
    private double winRateP;    // 프로토스 승률
    private double winRateZ;    // 저그 승률
}