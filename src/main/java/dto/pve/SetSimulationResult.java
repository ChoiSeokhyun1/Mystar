package dto.pve;

import lombok.Data;
import java.util.List;
import java.util.ArrayList; // (★★) [신규] ArrayList 임포트

@Data
public class SetSimulationResult {

    private boolean myWin;       

    // (★★) [수정] NullPointerException 방지를 위해 리스트를 직접 초기화
    private List<String> logs = new ArrayList<>();   

    // (★★) [신규] 그래프용 스탯 히스토리 리스트 (초기화)
    private List<StatDataPoint> statHistory = new ArrayList<>();

    // (Lombok이 @Data로 Getter/Setter를 자동 생성합니다)
}