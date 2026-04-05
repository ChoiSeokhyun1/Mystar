package dao.pve;

import dto.pve.BattleSessionDTO;
import java.util.Map;

public interface BattleSessionDAO {
    
    /**
     * 특정 유저/스테이지에 대해 현재 'IN_PROGRESS' 상태인 BattleSession을 조회합니다.
     * @param params Map - "userId", "stageLevel", "subLevel" 포함
     * @return BattleSessionDTO (단일 레코드)
     */
    BattleSessionDTO selectActiveBattle(Map<String, Object> params);
    
    /**
     * 새로운 BattleSession 레코드를 DB에 삽입합니다. (AI 빌드 확정 및 데이터 저장)
     * @param dto 삽입할 BattleSession 정보
     */
    void insertNewBattle(BattleSessionDTO dto);

    /**
     * (★) [유지] 경기 진행 중 스코어와 세트 번호를 업데이트합니다.
     * @param params Map - userId, level, subLevel, currentSet, myWins, aiWins 포함
     * @return 영향받은 행 수
     */
    int updateBattleProgress(Map<String, Object> params);

    /**
     * (★★) [수정] 경기 승리 시 STATUS를 'COMPLETED'로 변경하고 최종 스코어를 저장합니다.
     * @param params Map - userId, level, subLevel, myWins, aiWins 포함
     * @return 영향받은 행 수
     */
    int completePveBattleSession(Map<String, Object> params);

    /**
     * (★★) [추가] 경기 패배 시 'IN_PROGRESS' 상태인 세션을 삭제합니다.
     * @param params Map - userId, level, subLevel 포함
     * @return 영향받은 행 수
     */
    int deletePveBattleSession(Map<String, Object> params);

    /**
     * 세트 완료 시 setResultsData(JSON)를 DB에 저장합니다.
     * 세션 만료 후 재접속해도 세트별 선수 추적 정보를 복구할 수 있습니다.
     * @param params Map - userId, stageLevel, subLevel, setResultsData 포함
     */
    int updateSetResultsData(Map<String, Object> params);
}