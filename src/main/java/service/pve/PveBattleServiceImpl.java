package service.pve;

import dao.pve.BattleSessionDAO;
import dao.pve.ScriptDAO;
import dto.pve.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
public class PveBattleServiceImpl implements PveBattleService {

    @Autowired private BattleSessionDAO battleSessionDAO;
    @Autowired private ScriptDAO        scriptDAO;

    // =====================================================
    // 승패 결정 + 대본 선택
    // =====================================================
    @Override
    public List<Boolean> calculateWinResults(List<Map<String, Object>> matchupList) {
        List<Boolean> winResults = new ArrayList<>();
        Random rand = new Random();

        for (Map<String, Object> matchup : matchupList) {
            try {
                boolean myWin = decideWinner(matchup, rand);
                winResults.add(myWin);
            } catch (Exception e) {
                System.err.println("승패 결정 오류 (세트 " + winResults.size() + "): " + e.getMessage());
                e.printStackTrace();
                winResults.add(false);
            }
        }
        return winResults;
    }

    /**
     * 점수 기반 승패 결정
     * 내 점수 > 상대 점수 → 승
     */
    private boolean decideWinner(Map<String, Object> matchup, Random rand) {
        BuildDTO myBuild = (BuildDTO) matchup.get("myBuild");
        BuildDTO aiBuild = (BuildDTO) matchup.get("aiBuild");

        // ── 기본 능력치 합산
        double myScore = calcBaseScore(matchup, "my");
        double aiScore = calcBaseScore(matchup, "ai");

        // ── 컨디션 배율
        myScore *= conditionMult((String) matchup.getOrDefault("myCondition", "NORMAL"));
        aiScore *= conditionMult((String) matchup.getOrDefault("aiCondition", "NORMAL"));

        // ── 연승(기세) 배율
        myScore *= streakMult(getInt(matchup, "myWinStreak", 0));
        aiScore *= streakMult(getInt(matchup, "aiWinStreak", 0));

        // ── (핵심 수정) 빌드 vs 빌드 상성 배율 적용
        if (myBuild != null && aiBuild != null) {
            // 내 빌드 입장에서 상대 빌드를 상대할 때의 상성
            myScore *= matchupMult(myBuild.getBuildId(), aiBuild.getBuildId());
            
            // AI 빌드 입장에서 내 빌드를 상대할 때의 상성
            aiScore *= matchupMult(aiBuild.getBuildId(), myBuild.getBuildId());
        }

        // ── 빌드별 능력치 가산점
        if (myBuild != null) myScore *= statBonusMult(myBuild.getBuildId(), matchup, "my");
        if (aiBuild != null) aiScore *= statBonusMult(aiBuild.getBuildId(), matchup, "ai");

        // ── 동점 랜덤 처리 (5% 이내 오차)
        if (Math.abs(myScore - aiScore) / Math.max(myScore, aiScore) < 0.05) {
            return rand.nextBoolean();
        }
        return myScore > aiScore;
    }

    /** 능력치 합산 점수 */
    private double calcBaseScore(Map<String, Object> matchup, String prefix) {
        return getInt(matchup, prefix + "Attack",  50)
             + getInt(matchup, prefix + "Defense", 50)
             + getInt(matchup, prefix + "Macro",   50)
             + getInt(matchup, prefix + "Micro",   50)
             + getInt(matchup, prefix + "Luck",    50);
    }

    /** 컨디션 배율 */
    private double conditionMult(String condition) {
        switch (condition == null ? "NORMAL" : condition) {
            case "PEAK":   return 1.20;
            case "GOOD":   return 1.10;
            case "TIRED":  return 0.90;
            case "WORST":  return 0.80;
            default:       return 1.00;
        }
    }

    /** 연승 배율 */
    private double streakMult(int streak) {
        if (streak >= 5) return 1.10;
        if (streak == 4) return 1.08;
        if (streak == 3) return 1.06;
        if (streak == 2) return 1.03;
        return 1.00;
    }

    /** (변경됨) 빌드 vs 빌드 상성 배율: DB에서 직접 상성값(GOOD/BAD/NORMAL) 단건 조회 */
    private double matchupMult(int myBuildId, int oppBuildId) {
        try {
            String matchupStatus = scriptDAO.getBuildMatchup(myBuildId, oppBuildId);
            
            if ("GOOD".equals(matchupStatus)) return 1.30;
            if ("BAD".equals(matchupStatus)) return 0.70;
            
        } catch (Exception e) {
            // DB에 세팅된 값이 없거나 에러가 나면 무조건 보통(1.0) 처리
        }
        return 1.00;
    }

    /** 빌드 능력치 가산점: 높은 스탯에 배율 적용 */
    private double statBonusMult(int buildId, Map<String, Object> matchup, String prefix) {
        try {
            List<BuildStatBonusDTO> bonuses = scriptDAO.selectStatBonusesByBuildId(buildId);
            double extra = 0;
            double base  = calcBaseScore(matchup, prefix);
            for (BuildStatBonusDTO b : bonuses) {
                int statVal = getStatVal(matchup, prefix, b.getStatName());
                // 해당 스탯이 추가 배율로 기여하는 비율 계산
                extra += statVal * (b.getBonusMult() - 1.0);
            }
            return (base + extra) / base;
        } catch (Exception ignored) {}
        return 1.00;
    }

    private int getStatVal(Map<String, Object> matchup, String prefix, String stat) {
        switch (stat) {
            case "attack":  return getInt(matchup, prefix + "Attack",  50);
            case "defense": return getInt(matchup, prefix + "Defense", 50);
            case "macro":   return getInt(matchup, prefix + "Macro",   50);
            case "micro":   return getInt(matchup, prefix + "Micro",   50);
            case "luck":    return getInt(matchup, prefix + "Luck",    50);
            default:        return 50;
        }
    }

    // =====================================================
    // 대본 선택
    // =====================================================
    /**
     * 빌드 + 상대빌드 + WIN/LOSE 기준으로 대본 목록 조회 후 랜덤 선택
     * 줄 단위로 분리하여 반환 (JSP에서 3초마다 한 줄씩 출력)
     */
    @Override
    public List<String> selectScriptLines(int myBuildId, int oppBuildId, boolean myWin) {
        String result = myWin ? "WIN" : "LOSE";
        Map<String, Object> params = new HashMap<>();
        params.put("myBuildId",  myBuildId);
        params.put("oppBuildId", oppBuildId);
        params.put("result",     result);

        List<ScriptDTO> scripts = scriptDAO.selectScriptForPlay(params);
        if (scripts == null || scripts.isEmpty()) {
            // 대본 없음 — 기본 1줄
            return Collections.singletonList(myWin ? "승리하였습니다." : "패배하였습니다.");
        }

        // selectScriptForPlay가 이미 랜덤 정렬되어 첫 번째만 반환하므로 첫 번째 선택
        ScriptDTO chosen = scripts.get(0);
        return chosen.getLines();
    }

    // =====================================================
    // DB 저장
    // =====================================================
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
        if (progress.getGameStateData() != null)
            params.put("gameStateData", progress.getGameStateData());

        int updated = battleSessionDAO.updateBattleProgress(params);
        if (updated == 0)
            System.err.println("진행 상태 저장 실패: 활성 배틀 세션을 찾을 수 없습니다.");
    }

    // ── 유틸 ─────────────────────────────────────────────
    private int getInt(Map<String, Object> map, String key, int def) {
        Object v = map.get(key);
        if (v == null) return def;
        if (v instanceof Integer) return (Integer) v;
        try { return Integer.parseInt(v.toString()); } catch (Exception e) { return def; }
    }
}