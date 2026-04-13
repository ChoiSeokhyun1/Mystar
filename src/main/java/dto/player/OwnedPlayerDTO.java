package dto.player;

import java.util.Date;
import lombok.Data;

@Data
public class OwnedPlayerDTO {
    private int ownedPlayerSeq;
    private String userId;
    private int playerSeq;
    
    // 변경된 현재 스탯
    private int currentAttack;
    private int currentDefense;
    private int currentHp;
    private int currentHarass;
    private int currentSpeed;
    
    private Date acquiredAt;
    private String currentRarity;
    private int wins;
    private int losses;
    private double winRate;
    
    private int acquiredFromPackSeq;

    private String condition;   
    private int winStreak;      

    private int enhanceLevel;   
    
    // 변경된 강화 스탯
    private int enhanceAttack;
    private int enhanceDefense;
    private int enhanceHp;
    private int enhanceHarass;
    private int enhanceSpeed;
    
    private int enhanceStreak;
}