package service.pve;

import dto.pve.BattleProgressDTO;
import java.util.List;
import java.util.Map;

public interface PveBattleService {

    /** 매치업 리스트 기반 5세트 승패 결정 (점수 계산 방식) */
    List<Boolean> calculateWinResults(List<Map<String, Object>> matchupList);

    /** 빌드 + 상대빌드 + 승패 기준으로 대본 줄 목록 반환 */
    List<String> selectScriptLines(int myBuildId, int oppBuildId, boolean myWin);

    /** 경기 진행 상태 DB 저장 */
    void saveProgress(BattleProgressDTO progress);
}