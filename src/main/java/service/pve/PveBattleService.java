package service.pve;

import dto.pve.BattleFighterDTO;
import dto.pve.BattleProgressDTO;
import dto.pve.GameEvent;

import java.util.List;
import java.util.Map;

public interface PveBattleService {

    /** 매치업 리스트 기반 5세트 승패 결정 (점수 계산 방식) */
    List<Boolean> calculateWinResults(List<Map<String, Object>> matchupList);

    /** 경기 진행 상태 DB 저장 */
    void saveProgress(BattleProgressDTO progress);

    /**
     * 3:3 ATB 전투용 전투원 데이터 준비 (6명 DTO 반환)
     * MainController 의 showPveBattleResult 에서 사용.
     */
    List<BattleFighterDTO> prepareBattleData(String userId, int stageLevel, int subLevel);

    /**
     * ★ 신규: 백엔드 ATB 전투 시뮬레이션 전체 실행
     *
     * 1) prepareBattleData 로 6명 전투원 세팅
     * 2) TeamMatchupBonus 조회 → 블루팀 스탯에 배율 적용
     * 3) 틱 루프로 게임 끝까지 시뮬레이션 → List<GameEvent> 생성
     * 4) 결과 반환: fighters (초기 상태), events (타임라인), winner
     *
     * @return Map{
     *   "fighters"     : List<BattleFighterDTO>  (초기 스탯, 좌표 포함),
     *   "eventLogJson" : String (JSON 직렬화된 List<GameEvent>),
     *   "winner"       : "blue" | "red"
     * }
     */
    Map<String, Object> runBattleSimulation(String userId, int stageLevel, int subLevel);
}