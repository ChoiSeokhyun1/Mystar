package dto.pve;

import lombok.Data;

@Data
public class OwnedBuildDTO {
    private int ownedBuildSeq;
    private int playerSeq;      // TBL_OWNED_PLAYERS.OWNED_PLAYER_SEQ
    private int buildId;

    // Mapper JOIN용
    private String buildName;
    private String race;
    private String vsRace;
    private String playStyle;
    private String expandStyle;
    private String aggression;
    private String techStyle;
}