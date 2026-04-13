// dto/pve/BuildDTO.java — 대본/상성/가산점 필드 제거 버전

package dto.pve;

import java.sql.Timestamp;
import java.util.List;

public class BuildDTO {

    // 기본 정보
    private int buildId;
    private String userId;
    private String buildName;
    private String race;           // 이 빌드의 종족 (저그/테란/프로토스)
    private String vsRace;         // ALL, ZERG, TERRAN, PROTOSS

    // 전적
    private int winCount;
    private int loseCount;
    private Timestamp createdAt;

    // ★ matchups (BuildMatchupDTO), statBonuses (BuildStatBonusDTO), scripts (ScriptDTO) 필드 제거됨

    // ========================================
    // Getters & Setters
    // ========================================

    public int getBuildId() { return buildId; }
    public void setBuildId(int buildId) { this.buildId = buildId; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getBuildName() { return buildName; }
    public void setBuildName(String buildName) { this.buildName = buildName; }

    public String getRace() { return race; }
    public void setRace(String race) { this.race = race; }

    public String getVsRace() { return vsRace; }
    public void setVsRace(String vsRace) { this.vsRace = vsRace; }

    public int getWinCount() { return winCount; }
    public void setWinCount(int winCount) { this.winCount = winCount; }

    public int getLoseCount() { return loseCount; }
    public void setLoseCount(int loseCount) { this.loseCount = loseCount; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    // ========================================
    // 유틸리티 메서드
    // ========================================

    public double getWinRate() {
        int total = winCount + loseCount;
        if (total == 0) return 0.0;
        return (double) winCount / total * 100;
    }

    public String getRaceName() {
        if ("ZERG".equals(race)) return "저그";
        if ("TERRAN".equals(race)) return "테란";
        if ("PROTOSS".equals(race)) return "프로토스";
        return race;
    }

    @Override
    public String toString() {
        return "BuildDTO{" +
                "buildId=" + buildId +
                ", buildName='" + buildName + '\'' +
                ", race='" + race + '\'' +
                ", vsRace='" + vsRace + '\'' +
                ", winCount=" + winCount +
                ", loseCount=" + loseCount +
                '}';
    }
}