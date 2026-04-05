package dto.pve;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class BattleProgressDTO {
    private String userId;
    private int level;
    private int subLevel;
    private int currentSet;
    private int myWins;
    private int aiWins;
    private String gameStateData; // (★★★ 이 줄을 추가하세요)
}