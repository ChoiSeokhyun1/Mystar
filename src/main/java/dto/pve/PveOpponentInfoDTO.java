package dto.pve;

import lombok.Data;

@Data
public class PveOpponentInfoDTO {
    // TBL_PLAYERS 정보
    private int playerSeq;
    private String playerName;
    private String race;
    private String rarity;
    private int statAttack;
    private int statDefense;
    private int statMacro;
    private int statMicro;
    private int statLuck;
    private String playerImgUrl;
    private int playerCost;
    
    // TBL_PVE_OPPONENTS 정보
    private int setNumber; // (★) 배정된 세트 번호 (1~5, 벤치면 0 또는 null)
    private Integer opponentId; // opponent ID
    private Integer buildIdVsT; // vs 테란 빌드 ID (nullable)
    private Integer buildIdVsZ; // vs 저그 빌드 ID (nullable)
    private Integer buildIdVsP; // vs 프로토스 빌드 ID (nullable)
}