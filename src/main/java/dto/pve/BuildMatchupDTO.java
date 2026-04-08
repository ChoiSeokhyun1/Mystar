package dto.pve;

import lombok.Data;

/** 빌드별 종족 상성 */
@Data
public class BuildMatchupDTO {
    private int    matchupId;
    private int    buildId;
    private String vsRace;   // T / Z / P
    private String matchup;  // GOOD / NORMAL / BAD
}