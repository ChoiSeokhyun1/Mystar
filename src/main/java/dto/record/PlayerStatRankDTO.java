package dto.record;

import lombok.Data;

@Data
public class PlayerStatRankDTO {
    private int    ownedPlayerSeq;
    private String playerName;
    private String race;
    private String currentRarity;
    private int    gamesPlayed;   // 총 출전
    private int    wins;          // 승리 수
    private int    losses;        // 패배 수
    private double winRate;       // 승률 (0~100)
}