package dto.record; // 기록 관련 DTO 패키지

import lombok.Data;

@Data
public class PlayerRecordSummaryDTO {
    private int gamesPlayed; // 총 경기 수
    private int wins;        // 승리 수
    private int losses;      // 패배 수
    private double winRate;    // 승률 (계산된 값)
}