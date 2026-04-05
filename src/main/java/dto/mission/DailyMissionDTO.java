package dto.mission;

import java.util.Date;
import lombok.Data;

@Data
public class DailyMissionDTO {
    private int missionId;
    private String missionType;      // PVE_WIN, PVE_PLAY, GACHA, ENHANCE, LOGIN
    private String missionTitle;
    private String missionDesc;
    private int targetCount;
    private int rewardCrystal;
    private int rewardExp;
    private String missionIcon;
    private int displayOrder;
    private String isActive;
    private Date createdAt;
}