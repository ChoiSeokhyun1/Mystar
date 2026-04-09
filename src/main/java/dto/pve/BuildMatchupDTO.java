package dto.pve;

public class BuildMatchupDTO {
    private int matchupId;
    private int buildIdA;     // 내 빌드
    private int buildIdB;     // 상대 빌드
    private String matchup;   // GOOD, NORMAL, BAD

    // Getter, Setter 추가
    public int getMatchupId() { return matchupId; }
    public void setMatchupId(int matchupId) { this.matchupId = matchupId; }
    
    public int getBuildIdA() { return buildIdA; }
    public void setBuildIdA(int buildIdA) { this.buildIdA = buildIdA; }
    
    public int getBuildIdB() { return buildIdB; }
    public void setBuildIdB(int buildIdB) { this.buildIdB = buildIdB; }
    
    public String getMatchup() { return matchup; }
    public void setMatchup(String matchup) { this.matchup = matchup; }
}