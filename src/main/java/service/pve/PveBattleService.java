package service.pve;

import dto.pve.BattleProgressDTO;
import java.util.List;
import java.util.Map;

public interface PveBattleService {

    /**
     * (★) [수정] 확정된 Matchup List를 기반으로 '실제 시뮬레이션'을 실행하고
     * 5세트의 승패 결과를 계산합니다.
     * @param matchupList JSP에 전달될 List<Map> (선수, 빌드 등 모든 정보)
     * @return 5세트 승패 결과 (유저 승: true, AI 승: false)
     */
    List<Boolean> calculateWinResults(List<Map<String, Object>> matchupList);
    
    /**
     * (★) 경기 진행 상태를 DB에 트랜잭션 처리하여 저장합니다.
     */
    void saveProgress(BattleProgressDTO progress);
}