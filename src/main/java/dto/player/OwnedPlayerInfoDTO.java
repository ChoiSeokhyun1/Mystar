package dto.player;

import java.util.Date;
import lombok.Data;

@Data
public class OwnedPlayerInfoDTO {
    
    private int ownedPlayerSeq;
    private String userId;
    private int playerSeq;
    private int currentAttack;
    private int currentDefense;
    private int currentMacro;
    private int currentMicro;
    private int currentLuck;
    private Date acquiredAt;
    private String currentRarity;

    private String playerName;
    private String race;
    private String rarity;
    private int playerCost; 
    private String playerImgUrl; 
    private int slotNumber;
    private String packName; 

    // (★★★) 화면 출력을 위한 전적 데이터
    private int wins;
    private int losses;
    private double winRate;

    // 컨디션 & 경기력
    private String condition;   // PEAK / GOOD / NORMAL / TIRED / WORST
    private int winStreak;      // 현재 연승 수

    // ★ 강화 시스템 — 경기 패배로 절대 하락하지 않는 별도 스탯
    private int enhanceLevel;
    private int enhanceAttack;
    private int enhanceDefense;
    private int enhanceMacro;
    private int enhanceMicro;
    private int enhanceLuck;

    // ★ 전투에서 사용되는 실제 스탯 (일반 + 강화)
    public int getTotalAttack()  { return currentAttack  + enhanceAttack;  }
    public int getTotalDefense() { return currentDefense + enhanceDefense; }
    public int getTotalMacro()   { return currentMacro   + enhanceMacro;   }
    public int getTotalMicro()   { return currentMicro   + enhanceMicro;   }
    public int getTotalLuck()    { return currentLuck    + enhanceLuck;    }

    // 만약 롬복(@Data) 적용이 꼬일 경우를 대비한 수동 Getter 추가
    public int getWins() { return wins; }
    public int getLosses() { return losses; }
    public double getWinRate() { return winRate; }
    
    public void setWins(int wins) { this.wins = wins; }
    public void setLosses(int losses) { this.losses = losses; }
    public void setWinRate(double winRate) { this.winRate = winRate; }
}