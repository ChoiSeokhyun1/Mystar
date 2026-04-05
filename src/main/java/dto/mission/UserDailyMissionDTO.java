package dto.mission;

import java.util.Date;
import lombok.Data;

@Data
public class UserDailyMissionDTO {
    private String userId;
    private int missionId;
    private int currentCount;
    private String isCompleted;      // Y/N
    private String isClaimed;        // Y/N
    private Date completedAt;
    private Date claimedAt;
    private Date resetDate;
    
    // JOIN용 추가 필드 (미션 정보)
    private String missionType;
    private String missionTitle;
    private String missionDesc;
    private int targetCount;
    private int rewardCrystal;
    private int rewardExp;
    private String missionIcon;
    private int displayOrder;
    
    // 계산된 필드
    public int getProgressPercent() {
        if (targetCount == 0) return 0;
        return Math.min(100, (currentCount * 100) / targetCount);
    }
    
    public boolean canClaim() {
        return "Y".equals(isCompleted) && "N".equals(isClaimed);
    }
}