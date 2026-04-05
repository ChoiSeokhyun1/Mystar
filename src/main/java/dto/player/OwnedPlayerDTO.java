package dto.player;

import java.util.Date; // Date import
import lombok.Data;

@Data
public class OwnedPlayerDTO {
    private int ownedPlayerSeq;
    private String userId;
    private int playerSeq;
    private int currentAttack;
    private int currentDefense;
    private int currentMacro;
    private int currentMicro;
    private int currentLuck;
    private Date acquiredAt;   // Date 타입 사용
    private String currentRarity;
    private int wins;
    private int losses;
    private double winRate;
    
    // (★★) [신규 추가] 선수를 획득한 팩의 ID
    private int acquiredFromPackSeq;

    // 컨디션 & 경기력
    private String condition;   // PEAK / GOOD / NORMAL / TIRED / WORST
    private int winStreak;      // 현재 연승 수 (패배시 0 리셋)

    // ★ 강화 시스템 — 경기 패배로 절대 하락하지 않는 별도 스탯
    private int enhanceLevel;   // 현재 강화 단계 (0~99)
    private int enhanceAttack;
    private int enhanceDefense;
    private int enhanceMacro;
    private int enhanceMicro;
    private int enhanceLuck;
    // 양수 = 연속 성공 횟수, 음수 = 연속 실패 횟수, 0 = 초기
    private int enhanceStreak;
}