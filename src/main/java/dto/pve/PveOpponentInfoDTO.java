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
    
    // [수정됨] Macro, Micro, Luck -> Hp, Harass, Speed
    private int statHp;
    private int statHarass;
    private int statSpeed;
    
    private String playerImgUrl;
    
    // TBL_PVE_OPPONENTS 정보
    private int setNumber;
    private int opponentId;
    
    // 상대방 빌드 (AI 로직용)
    private Integer buildIdVsT;
    private Integer buildIdVsZ;
    private Integer buildIdVsP;
}