package dto.matchup;

import lombok.Data;
import java.sql.Timestamp;

/**
 * 3:3 팀 종족 상성 보너스 DTO
 *
 * myTeamCombo  : 내 팀 3명의 종족 코드 알파벳 정렬 문자열 (예: "PPT", "TTZ")
 * oppTeamCombo : 상대 팀 3명의 종족 코드 알파벳 정렬 문자열
 * bonusMultiplier : 블루(내) 팀 전체 스탯에 곱하는 배율
 *                   1.2 → 20% 강화 / 0.85 → 15% 약화
 */
@Data
public class TeamMatchupBonusDTO {

    private int    matchupId;
    private String myTeamCombo;       // 예: "TTZ"
    private String oppTeamCombo;      // 예: "PPP"
    private double bonusMultiplier;   // 예: 1.20
    private String description;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // ── 화면 표시용 편의 메서드 ──

    public String getMyComboDisplay() {
        return formatCombo(myTeamCombo);
    }

    public String getOppComboDisplay() {
        return formatCombo(oppTeamCombo);
    }

    public String getBonusLabel() {
        if (bonusMultiplier > 1.0) return "유리 (+" + String.format("%.0f", (bonusMultiplier - 1.0) * 100) + "%)";
        if (bonusMultiplier < 1.0) return "불리 (-" + String.format("%.0f", (1.0 - bonusMultiplier) * 100) + "%)";
        return "보통 (0%)";
    }

    private String formatCombo(String combo) {
        if (combo == null || combo.length() < 3) return combo;
        return raceLabel(combo.charAt(0)) + "+"
             + raceLabel(combo.charAt(1)) + "+"
             + raceLabel(combo.charAt(2));
    }

    private String raceLabel(char c) {
        switch (c) {
            case 'T': return "테란";
            case 'P': return "프토";
            case 'Z': return "저그";
            default:  return String.valueOf(c);
        }
    }
}