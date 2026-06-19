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
     *
     * @param userId           유저 ID
     * @param myOwnedPlayerSeqs 이번 세트에 출전할 내 선수 3명의 ownedPlayerSeq (pveMatchSetup 화면에서 배치한 값)
     * @param stageLevel       스테이지 레벨
     * @param subLevel         서브 스테이지 번호
     * @param setNumber        세트 번호 (1~3) — 상대(AI) 엔트리 조회 시 (setNumber-1)*3+1 ~ setNumber*3 구간 사용
     */
    List<BattleFighterDTO> prepareBattleData(String userId, List<Integer> myOwnedPlayerSeqs,
                                              int stageLevel, int subLevel, int setNumber);

    /**
     * ★ 백엔드 ATB 전투 시뮬레이션 전체 실행
     *
     * 1) prepareBattleData 로 6명 전투원 세팅 (내 팀은 myOwnedPlayerSeqs 로 지정된 해당 세트 3명)
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
    Map<String, Object> runBattleSimulation(String userId, List<Integer> myOwnedPlayerSeqs,
                                             int stageLevel, int subLevel, int setNumber);
}