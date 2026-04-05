package dto.pve;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class GameLog {
    private int time;           // 게임 시간 (초)
    private String message;     // 로그 메시지
    private String type;        // 로그 타입 (production, battle, ai_action, etc.)
}