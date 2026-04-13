package dto.player;

import lombok.Data;

@Data
public class PlayerDTO {
    private int playerSeq;
    private String playerName;
    private String race;
    private String rarity;
    
    // 변경된 스탯
    private int statAttack;    // 공격력
    private int statDefense;   // 방어력
    private int statHp;        // 체력
    private int statHarass;    // 견제력
    private int statSpeed;     // 속도
    
    private String playerImgUrl;
    private int playerCost;
}