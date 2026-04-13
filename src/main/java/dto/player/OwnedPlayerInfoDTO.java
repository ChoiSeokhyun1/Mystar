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
    
    // 변경된 현재 스탯
    private int currentHp;
    private int currentHarass;
    private int currentSpeed;
    
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
    
    // 변경된 강화 스탯
    private int enhanceHp;
    private int enhanceHarass;
    private int enhanceSpeed;

    // ★ 전투에서 사용되는 실제 스탯 (일반 + 강화)
    public int getTotalAttack()  { return currentAttack  + enhanceAttack;  }
    public int getTotalDefense() { return currentDefense + enhanceDefense; }
    
    // 변경된 합계 계산 메서드
    public int getTotalHp()      { return currentHp      + enhanceHp;      }
    public int getTotalHarass()  { return currentHarass  + enhanceHarass;  }
    public int getTotalSpeed()   { return currentSpeed   + enhanceSpeed;   }

    // 만약 롬복(@Data) 적용이 꼬일 경우를 대비한 수동 Getter 추가
    public int getWins() { return wins; }
    public int getLosses() { return losses; }
    public double getWinRate() { return winRate; }
    
    public void setWins(int wins) { this.wins = wins; }
    public void setLosses(int losses) { this.losses = losses; }
    public void setWinRate(double winRate) { this.winRate = winRate; }
}