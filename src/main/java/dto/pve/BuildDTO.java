// dto/pve/BuildDTO.java 전체 교체용 코드

package dto.pve;

import java.sql.Timestamp;
import java.util.List;

public class BuildDTO {
    
    // 기본 정보
    private int buildId;
    private String userId;
    private String buildName;
    private String race;           // 이 빌드의 종족 (저그/테란/프로토스)
    
    // ★ 추가 1: 상대 가능 종족 (vsRace) 변수 추가
    private String vsRace;         // ALL, ZERG, TERRAN, PROTOSS

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
    
    public int getBuildId() { return buildId; }
    public void setBuildId(int buildId) { this.buildId = buildId; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getBuildName() { return buildName; }
    public void setBuildName(String buildName) { this.buildName = buildName; }

    public String getRace() { return race; }
    public void setRace(String race) { this.race = race; }

    // ★ 추가 2: vsRace의 Getter, Setter 추가
    public String getVsRace() { return vsRace; }
    public void setVsRace(String vsRace) { this.vsRace = vsRace; }

    public int getWinCount() { return winCount; }
    public void setWinCount(int winCount) { this.winCount = winCount; }

    public int getLoseCount() { return loseCount; }
    public void setLoseCount(int loseCount) { this.loseCount = loseCount; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public List<BuildMatchupDTO> getMatchups() { return matchups; }
    public void setMatchups(List<BuildMatchupDTO> matchups) { this.matchups = matchups; }

    public List<BuildStatBonusDTO> getStatBonuses() { return statBonuses; }
    public void setStatBonuses(List<BuildStatBonusDTO> statBonuses) { this.statBonuses = statBonuses; }

    public List<ScriptDTO> getScripts() { return scripts; }
    public void setScripts(List<ScriptDTO> scripts) { this.scripts = scripts; }

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

    // ★ 추가 3: toString() 에도 vsRace 내용이 찍히도록 수정
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