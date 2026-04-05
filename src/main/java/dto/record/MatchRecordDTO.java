package dto.record;

import java.util.Date;
import lombok.Data;

@Data
public class MatchRecordDTO {
    private int matchSeq;
    private int ownedPlayerSeq;
    private String matchType;
    private String opponentName;
    private String mapName;
    private String isWin; // "Y" or "N"
    private Date matchDate;
    private String opponentRace;    // 상대방 종족 (T, P, Z, A 등)
}