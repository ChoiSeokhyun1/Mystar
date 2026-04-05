package service.pve;

import dao.pve.BattleSessionDAO;
import dto.pve.BattleProgressDTO;
import dto.pve.BuildDTO;
import dto.pve.GameState;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class PveBattleServiceImpl implements PveBattleService {

    @Autowired
    private BattleSessionDAO battleSessionDAO;

    @Autowired
    private PveSimulationService pveSimulationService;

    /**
     * 매치업 리스트 기반으로 5세트 시뮬레이션 실행 후 승패 반환
     */
    @Override
    public List<Boolean> calculateWinResults(List<Map<String, Object>> matchupList) {
        List<Boolean> winResults = new ArrayList<>();

        for (Map<String, Object> matchup : matchupList) {
            try {
                // 유저 선수 스탯
                Map<String, Integer> myStats = buildStatMap(matchup, "my");
                // AI 선수 스탯
                Map<String, Integer> aiStats = buildStatMap(matchup, "ai");

                String myRace = (String) matchup.get("myRace");
                String aiRace = (String) matchup.get("aiRace");

                // 빌드 가져오기 (없으면 기본 빌드 자동 생성)
                BuildDTO myBuild = (BuildDTO) matchup.get("myBuild");
                BuildDTO aiBuild = (BuildDTO) matchup.get("aiBuild");

                if (myBuild == null) myBuild = pveSimulationService.generateDefaultBuild(myRace, aiRace);
                if (aiBuild == null) aiBuild = pveSimulationService.generateDefaultBuild(aiRace, myRace);

                // 시뮬레이션 실행
                String myPlayerName = (String) matchup.getOrDefault("myPlayerName", "아군");
                String aiPlayerName = (String) matchup.getOrDefault("aiPlayerName", "AI");
                List<GameState> replay = pveSimulationService.runFullSimulation(
                        myStats, aiStats, myBuild, aiBuild, myRace, aiRace,
                        myPlayerName, aiPlayerName
                );

                // 최종 상태로 승패 판정
                boolean myWin = determineWinner(replay);
                winResults.add(myWin);

            } catch (Exception e) {
                System.err.println("시뮬레이션 오류 (세트 " + winResults.size() + "): " + e.getMessage());
                e.printStackTrace();
                winResults.add(false);
            }
        }

        return winResults;
    }

    /**
     * 최종 GameState 기준 승패 판정
     */
    private boolean determineWinner(List<GameState> replay) {
        if (replay == null || replay.isEmpty()) return false;

        GameState last = replay.get(replay.size() - 1);

        if (last.getDefense() <= 0)   return false; // 내 본진 파괴 → 패
        if (last.getAiDefense() <= 0) return true;  // 적 본진 파괴 → 승

        // 판정: 본진 방어력 비교
        if (last.getDefense() > last.getAiDefense()) return true;
        if (last.getDefense() < last.getAiDefense()) return false;

        // 완전 동점: 전투력 비교
        return last.getCombatPower() >= last.getAiCombatPower();
    }

    /**
     * matchup Map에서 스탯 추출
     * key 예시: "myAttack", "myDefense", "myMacro", "myMicro", "myLuck"
     */
    private Map<String, Integer> buildStatMap(Map<String, Object> matchup, String prefix) {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("attack",  getInt(matchup, prefix + "Attack",  50));
        stats.put("defense", getInt(matchup, prefix + "Defense", 50));
        stats.put("macro",   getInt(matchup, prefix + "Macro",   50));
        stats.put("micro",   getInt(matchup, prefix + "Micro",   50));
        stats.put("luck",    getInt(matchup, prefix + "Luck",    50));
        return stats;
    }

    private int getInt(Map<String, Object> map, String key, int defaultVal) {
        Object val = map.get(key);
        if (val == null) return defaultVal;
        if (val instanceof Integer) return (Integer) val;
        try { return Integer.parseInt(val.toString()); }
        catch (Exception e) { return defaultVal; }
    }

    /**
     * 경기 진행 상태 DB 저장
     */
    @Override
    @Transactional
    public void saveProgress(BattleProgressDTO progress) {
        Map<String, Object> params = new HashMap<>();
        params.put("userId",      progress.getUserId());
        params.put("stageLevel",  progress.getLevel());
        params.put("subLevel",    progress.getSubLevel());
        params.put("currentSet",  progress.getCurrentSet());
        params.put("myWins",      progress.getMyWins());
        params.put("aiWins",      progress.getAiWins());

        if (progress.getGameStateData() != null) {
            params.put("gameStateData", progress.getGameStateData());
        }

        int updatedRows = battleSessionDAO.updateBattleProgress(params);

        if (updatedRows == 0) {
            System.err.println("진행 상태 저장 실패: 활성 배틀 세션을 찾을 수 없습니다.");
        }
    }
}