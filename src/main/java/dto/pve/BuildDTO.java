package dto.pve;

import java.sql.Timestamp;
import java.util.List;

/**
 * 빌드 DTO (대본 방식 - 간소화)
 * VS_RACE 제거: 빌드는 종족만 표시
 */
public class BuildDTO {
    
    // 기본 정보
    private int buildId;
    private String userId;
    private String buildName;
    private String race;           // 이 빌드의 종족 (저그/테란/프로토스)
    
    // 전적
    private int winCount;
    private int loseCount;
    private Timestamp createdAt;
    
    // 대본 관련 (조인 데이터)
    private List<BuildMatchupDTO> matchups;      // 상성 정보
    private List<BuildStatBonusDTO> statBonuses; // 능력치 가산점
    private List<ScriptDTO> scripts;             // 대본 목록

    // ========================================
    // Getters & Setters
    // ========================================
    
    public int getBuildId() {
        return buildId;
    }

    public void setBuildId(int buildId) {
        this.buildId = buildId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getBuildName() {
        return buildName;
    }

    public void setBuildName(String buildName) {
        this.buildName = buildName;
    }

    public String getRace() {
        return race;
    }

    public void setRace(String race) {
        this.race = race;
    }

    public int getWinCount() {
        return winCount;
    }

    public void setWinCount(int winCount) {
        this.winCount = winCount;
    }

    public int getLoseCount() {
        return loseCount;
    }

    public void setLoseCount(int loseCount) {
        this.loseCount = loseCount;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public List<BuildMatchupDTO> getMatchups() {
        return matchups;
    }

    public void setMatchups(List<BuildMatchupDTO> matchups) {
        this.matchups = matchups;
    }

    public List<BuildStatBonusDTO> getStatBonuses() {
        return statBonuses;
    }

    public void setStatBonuses(List<BuildStatBonusDTO> statBonuses) {
        this.statBonuses = statBonuses;
    }

    public List<ScriptDTO> getScripts() {
        return scripts;
    }

    public void setScripts(List<ScriptDTO> scripts) {
        this.scripts = scripts;
    }

    // ========================================
    // 유틸리티 메서드
    // ========================================
    
    /**
     * 승률 계산
     */
    public double getWinRate() {
        int total = winCount + loseCount;
        if (total == 0) return 0.0;
        return (double) winCount / total * 100;
    }
    
    /**
     * 종족 이름 (한글)
     */
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
                ", winCount=" + winCount +
                ", loseCount=" + loseCount +
                '}';
    }
}