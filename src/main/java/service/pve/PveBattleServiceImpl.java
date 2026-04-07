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
                Map<String, Integer> myStats = buildStatMap(matchup, "my");
                Map<String, Integer> aiStats = buildStatMap(matchup, "ai");

                String myRace = (String) matchup.get("myRace");
                String aiRace = (String) matchup.get("aiRace");

                BuildDTO myBuild = (BuildDTO) matchup.get("myBuild");
                BuildDTO aiBuild = (BuildDTO) matchup.get("aiBuild");

                if (myBuild == null) myBuild = pveSimulationService.generateDefaultBuild(myRace, aiRace);
                if (aiBuild == null) aiBuild = pveSimulationService.generateDefaultBuild(aiRace, myRace);

                String myPlayerName = (String) matchup.getOrDefault("myPlayerName", "아군");
                String aiPlayerName = (String) matchup.getOrDefault("aiPlayerName", "AI");
                
                // ★ 컨디션 및 연승 데이터 추출
                String myCondition = (String) matchup.getOrDefault("myCondition", "NORMAL");
                int myWinStreak = getInt(matchup, "myWinStreak", 0);
                String aiCondition = (String) matchup.getOrDefault("aiCondition", "NORMAL");
                int aiWinStreak = getInt(matchup, "aiWinStreak", 0);

                // ★ 파라미터 전달 추가
                List<GameState> replay = pveSimulationService.runFullSimulation(
                        myStats, aiStats, myBuild, aiBuild, myRace, aiRace,
                        myPlayerName, aiPlayerName,
                        myCondition, myWinStreak, aiCondition, aiWinStreak
                );

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
     * matchup Map에서 스탯 추출 (★ 컨디션 및 연승 배율 로직 추가 완료)
     * key 예시: "myAttack", "myDefense", "myCondition", "myWinStreak"
     */
    private Map<String, Integer> buildStatMap(Map<String, Object> matchup, String prefix) {
        Map<String, Integer> stats = new HashMap<>();
        
        // 1. 기본 스탯(총합) 가져오기
        int attack  = getInt(matchup, prefix + "Attack",  50);
        int defense = getInt(matchup, prefix + "Defense", 50);
        int macro   = getInt(matchup, prefix + "Macro",   50);
        int micro   = getInt(matchup, prefix + "Micro",   50);
        int luck    = getInt(matchup, prefix + "Luck",    50);

        // 2. 컨디션 배율 적용 (데이터가 없으면 NORMAL)
        String condition = (String) matchup.getOrDefault(prefix + "Condition", "NORMAL");
        double condMultiplier = 1.0;
        switch (condition) {
            case "PEAK":   condMultiplier = 1.20; break; // 20% 증가
            case "GOOD":   condMultiplier = 1.10; break; // 10% 증가
            case "NORMAL": condMultiplier = 1.00; break; // 기본
            case "TIRED":  condMultiplier = 0.90; break; // 10% 감소
            case "WORST":  condMultiplier = 0.80; break; // 20% 감소
        }

        // 3. 연승(기세) 배율 적용 (최대 5연승 캡)
        int winStreak = getInt(matchup, prefix + "WinStreak", 0);
        double streakMultiplier = 1.0;
        if (winStreak >= 5) {
            streakMultiplier = 1.10; // 5연승 이상: 10% 증가
        } else if (winStreak == 4) {
            streakMultiplier = 1.08; // 4연승: 8% 증가
        } else if (winStreak == 3) {
            streakMultiplier = 1.06; // 3연승: 6% 증가
        } else if (winStreak == 2) {
            streakMultiplier = 1.03; // 2연승: 3% 증가
        } else {
            streakMultiplier = 1.00; // 0~1연승: 효과 없음
        }

        // 4. 최종 배율을 스탯에 곱해서 세팅
        double finalMultiplier = condMultiplier * streakMultiplier;

        stats.put("attack",  (int)(attack * finalMultiplier));
        stats.put("defense", (int)(defense * finalMultiplier));
        stats.put("macro",   (int)(macro * finalMultiplier));
        stats.put("micro",   (int)(micro * finalMultiplier));
        stats.put("luck",    (int)(luck * finalMultiplier));

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