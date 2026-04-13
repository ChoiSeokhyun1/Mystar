package service.pve;

import com.google.gson.Gson;
import dao.entry.PveEntryDAO;
import dao.matchup.TeamMatchupDAO;
import dao.pve.BattleSessionDAO;
import dao.pve.PveOpponentDAO;
import dto.matchup.TeamMatchupBonusDTO;
import dto.player.OwnedPlayerInfoDTO;
import dto.pve.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
public class PveBattleServiceImpl implements PveBattleService {

    // ─────────────── 상수 ───────────────
    /** 한 전투의 최대 틱 수 (무한루프 방지) */
    private static final int  MAX_TICKS       = 5000;
    /** ATB 게이지가 이 값 이상이면 행동 */
    private static final int  ATB_THRESHOLD   = 100;
    /** 콤보 발동 확률 */
    private static final double COMBO_CHANCE  = 0.25;
    /** 방어 난입 확률 */
    private static final double SHIELD_CHANCE = 0.30;
    /** 방어 시 데미지 경감 비율 */
    private static final double SHIELD_REDUCE = 0.50;
    /** 최소 데미지 = ATK * 이 배율 */
    private static final double MIN_DMG_RATIO = 0.10;

    // ─────────────── 의존성 ───────────────
    @Autowired private BattleSessionDAO battleSessionDAO;
    @Autowired private PveEntryDAO      pveEntryDAO;
    @Autowired private PveOpponentDAO   pveOpponentDAO;
    @Autowired private TeamMatchupDAO   teamMatchupDAO;

    private final Gson gson = new Gson();

    // =====================================================================
    // ★ 핵심 메서드: 백엔드 ATB 전투 시뮬레이션 전체 실행
    // =====================================================================
    @Override
    public Map<String, Object> runBattleSimulation(String userId, int stageLevel, int subLevel) {

        // ── 1. 전투원 데이터 준비 (BattleFighterDTO 6명) ──
        List<BattleFighterDTO> fighters = prepareBattleData(userId, stageLevel, subLevel);

        // ── 2. 종족 상성 보너스 조회 및 블루팀 스탯 적용 ──
        applyTeamMatchupBonus(fighters);

        // ── 3. 시뮬레이션용 내부 상태 복사 ──
        List<SimFighter> simFighters = toSimFighters(fighters);
        List<GameEvent>  events      = new ArrayList<>();

        // ── 4. 틱 루프: 양 팀 중 한 팀이 전멸할 때까지 ──
        int tick = 0;
        Random rand = new Random();

        outer:
        while (tick < MAX_TICKS) {
            tick++;

            // 4-a. 전체 생존 전투원 ATB 충전
            for (SimFighter sf : simFighters) {
                if (sf.hp > 0) {
                    sf.atb += sf.spd;
                }
            }

            // 4-b. ATB 100 이상인 전투원 수집 후 SPD 내림차순 정렬 → 순서대로 행동
            List<SimFighter> ready = new ArrayList<>();
            for (SimFighter sf : simFighters) {
                if (sf.hp > 0 && sf.atb >= ATB_THRESHOLD) ready.add(sf);
            }
            ready.sort((a, b) -> b.spd - a.spd);

            for (SimFighter actor : ready) {
                if (actor.hp <= 0) continue; // 이미 이 틱에 전사

                actor.atb = 0; // ATB 초기화

                // 4-c. 살아있는 적 목록
                List<SimFighter> enemies = getAlive(simFighters, opposite(actor.team));
                if (enemies.isEmpty()) break outer;

                // 4-d. 콤보 시도
                boolean didCombo = tryCombo(actor, enemies, simFighters, events, tick, rand);

                // 4-e. 콤보 실패 → 일반 공격 or 방어 난입 체크
                if (!didCombo) {
                    SimFighter target = pickLowestHpTarget(enemies);
                    SimFighter interceptor = tryIntercept(target, simFighters, rand);

                    int rawDmg  = actor.atk - target.def;
                    int baseDmg = Math.max(rawDmg, (int)(actor.atk * MIN_DMG_RATIO));
                    int variance = (int)(baseDmg * (0.9 + rand.nextDouble() * 0.2));

                    if (interceptor != null) {
                        // 방어 난입
                        interceptor.atb = Math.max(0, interceptor.atb - 50);
                        int reducedDmg = (int)(variance * SHIELD_REDUCE);
                        target.hp -= reducedDmg;

                        boolean lethal = target.hp <= 0;
                        if (lethal) target.hp = 0;

                        // SHIELD 이벤트 기록
                        BattleFighterDTO actorDto  = getDtoById(fighters, actor.id);
                        BattleFighterDTO targetDto = getDtoById(fighters, target.id);
                        BattleFighterDTO intDto    = getDtoById(fighters, interceptor.id);

                        targetDto.setHp(target.hp); // 임시 반영
                        GameEvent shieldEv = GameEvent.shield(tick, actorDto, targetDto, intDto, reducedDmg);
                        shieldEv.setCurrentHp(target.hp);
                        shieldEv.setLethal(lethal);
                        shieldEv.setAtbSnapshotJson(buildAtbSnapshot(simFighters));
                        events.add(shieldEv);

                        if (lethal) {
                            events.add(buildDeathEvent(tick, target, fighters, simFighters));
                        }

                    } else {
                        // 일반 공격
                        target.hp -= variance;
                        boolean lethal = target.hp <= 0;
                        if (lethal) target.hp = 0;

                        BattleFighterDTO actorDto  = getDtoById(fighters, actor.id);
                        BattleFighterDTO targetDto = getDtoById(fighters, target.id);
                        targetDto.setHp(target.hp);

                        GameEvent atkEv = GameEvent.attack(tick, actorDto, targetDto, variance, lethal);
                        atkEv.setAtbSnapshotJson(buildAtbSnapshot(simFighters));
                        events.add(atkEv);

                        if (lethal) {
                            events.add(buildDeathEvent(tick, target, fighters, simFighters));
                        }
                    }
                }

                // 4-f. 전멸 체크
                if (isTeamWiped(simFighters, "blue") || isTeamWiped(simFighters, "red")) {
                    break outer;
                }
            }

            // 4-g. 매 틱 후 전멸 체크
            if (isTeamWiped(simFighters, "blue") || isTeamWiped(simFighters, "red")) {
                break;
            }
        }

        // ── 5. 승패 판정 ──
        boolean blueWon = !isTeamWiped(simFighters, "blue");
        String  winner  = blueWon ? "blue" : "red";

        events.add(GameEvent.battleEnd(tick, winner, blueWon ? "BLUE" : "RED"));

        // ── 6. 결과 반환 ──
        Map<String, Object> result = new HashMap<>();
        result.put("fighters",     fighters);
        result.put("eventLogJson", gson.toJson(events));
        result.put("winner",       winner);
        return result;
    }

    // =====================================================================
    // 종족 상성 보너스 적용
    // =====================================================================
    private void applyTeamMatchupBonus(List<BattleFighterDTO> fighters) {
        List<BattleFighterDTO> blueTeam = new ArrayList<>();
        List<BattleFighterDTO> redTeam  = new ArrayList<>();
        for (BattleFighterDTO f : fighters) {
            if ("blue".equals(f.getTeam())) blueTeam.add(f);
            else                             redTeam.add(f);
        }

        String myCombo  = buildTeamCombo(blueTeam);
        String oppCombo = buildTeamCombo(redTeam);

        Map<String, Object> params = new HashMap<>();
        params.put("myTeamCombo",  myCombo);
        params.put("oppTeamCombo", oppCombo);
        TeamMatchupBonusDTO bonus = teamMatchupDAO.selectMatchupBonus(params);

        double mult = (bonus != null) ? bonus.getBonusMultiplier() : 1.0;

        if (mult == 1.0) return; // 보정 없음

        for (BattleFighterDTO f : blueTeam) {
            f.setAtk((int)(f.getAtk() * mult));
            f.setDef((int)(f.getDef() * mult));
            f.setSpd((int)(f.getSpd() * mult));
            int newHp = (int)(f.getHp() * mult);
            f.setHp(newHp);
            f.setMaxHp(newHp);
        }
    }

    private String buildTeamCombo(List<BattleFighterDTO> team) {
        char[] chars = new char[3];
        for (int i = 0; i < Math.min(team.size(), 3); i++) {
            String race = team.get(i).getRace();
            chars[i] = (race != null && !race.isEmpty()) ? race.toUpperCase().charAt(0) : 'T';
        }
        Arrays.sort(chars);
        return new String(chars);
    }

    // =====================================================================
    // 내부 시뮬레이션 상태 (SimFighter)
    // =====================================================================
    private static class SimFighter {
        String id, team, name;
        int hp, maxHp, atk, def, spd, atb;

        SimFighter(BattleFighterDTO dto) {
            id = dto.getId(); team = dto.getTeam(); name = dto.getName();
            hp = dto.getHp(); maxHp = dto.getMaxHp();
            atk = dto.getAtk(); def = dto.getDef(); spd = dto.getSpd();
            atb = 0;
        }
    }

    private List<SimFighter> toSimFighters(List<BattleFighterDTO> fighters) {
        List<SimFighter> list = new ArrayList<>();
        for (BattleFighterDTO f : fighters) list.add(new SimFighter(f));
        return list;
    }

    // ── 유틸 ──

    private String opposite(String team) { return "blue".equals(team) ? "red" : "blue"; }

    private List<SimFighter> getAlive(List<SimFighter> all, String team) {
        List<SimFighter> list = new ArrayList<>();
        for (SimFighter sf : all) if (team.equals(sf.team) && sf.hp > 0) list.add(sf);
        return list;
    }

    private boolean isTeamWiped(List<SimFighter> all, String team) {
        for (SimFighter sf : all) if (team.equals(sf.team) && sf.hp > 0) return false;
        return true;
    }

    private SimFighter pickLowestHpTarget(List<SimFighter> enemies) {
        return enemies.stream().min(Comparator.comparingInt(a -> a.hp)).orElse(null);
    }

    private SimFighter tryIntercept(SimFighter target, List<SimFighter> all, Random rand) {
        List<SimFighter> allies = new ArrayList<>();
        for (SimFighter sf : all) {
            if (sf.team.equals(target.team) && !sf.id.equals(target.id) && sf.hp > 0 && sf.atb >= 50)
                allies.add(sf);
        }
        if (allies.isEmpty() || rand.nextDouble() > SHIELD_CHANCE) return null;
        allies.sort((a, b) -> b.atb - a.atb);
        return allies.get(0);
    }

    private boolean tryCombo(SimFighter actor, List<SimFighter> enemies,
                              List<SimFighter> allFighters,
                              List<GameEvent> events, int tick, Random rand) {
        if (rand.nextDouble() > COMBO_CHANCE) return false;

        List<SimFighter> aliveAllies = getAlive(allFighters, actor.team);
        aliveAllies.removeIf(a -> a.id.equals(actor.id) || a.atb < ATB_THRESHOLD);
        if (aliveAllies.isEmpty()) return false;

        SimFighter partner = aliveAllies.get(0);
        partner.atb = 0;

        SimFighter target = pickLowestHpTarget(enemies);
        if (target == null) return false;

        int comboDmg = (int)((actor.atk + partner.atk) * 0.8) - target.def;
        int damage   = Math.max(comboDmg, (int)(actor.atk * 0.15));

        target.hp -= damage;
        boolean lethal = target.hp <= 0;
        if (lethal) target.hp = 0;

        BattleFighterDTO actorDto   = getDtoByIdMutable(allFighters, actor.id, enemies);
        BattleFighterDTO partnerDto = getDtoByIdMutable(allFighters, partner.id, enemies);
        BattleFighterDTO targetDto  = getDtoByIdMutable(allFighters, target.id, enemies);

        if (actorDto == null || partnerDto == null || targetDto == null) return false;
        targetDto.setHp(target.hp);

        GameEvent comboEv = GameEvent.combo(tick, actorDto, partnerDto, targetDto, damage, lethal);
        comboEv.setAtbSnapshotJson(buildAtbSnapshot(allFighters));
        events.add(comboEv);

        if (lethal) events.add(buildDeathEvent(tick, target, null, allFighters));
        return true;
    }

    private GameEvent buildDeathEvent(int tick, SimFighter dead,
                                      List<BattleFighterDTO> fighters,
                                      List<SimFighter> allSim) {
        GameEvent ev = new GameEvent();
        ev.setEventType("DEATH");
        ev.setTick(tick);
        ev.setActorId(dead.id);
        ev.setActorName(dead.name);
        ev.setActorTeam(dead.team);
        ev.setLethal(true);
        ev.setLogMessage("💀 <strong>[" + dead.name + "]</strong> 전사!");
        ev.setLogType("kill");
        ev.setAtbSnapshotJson(buildAtbSnapshot(allSim));
        if (fighters != null) {
            BattleFighterDTO dto = getDtoById(fighters, dead.id);
            if (dto != null) { ev.setActorX(dto.getX()); ev.setActorY(dto.getY()); }
        }
        return ev;
    }

    private String buildAtbSnapshot(List<SimFighter> all) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < all.size(); i++) {
            SimFighter sf = all.get(i);
            if (i > 0) sb.append(",");
            sb.append("{\"id\":\"").append(sf.id).append("\",")
              .append("\"atb\":").append(Math.min(sf.atb, ATB_THRESHOLD)).append(",")
              .append("\"hp\":").append(Math.max(0, sf.hp)).append("}");
        }
        return sb.append("]").toString();
    }

    private BattleFighterDTO getDtoById(List<BattleFighterDTO> list, String id) {
        for (BattleFighterDTO f : list) if (f.getId().equals(id)) return f;
        return null;
    }

    private BattleFighterDTO getDtoByIdMutable(List<SimFighter> all,
                                               String id,
                                               List<SimFighter> enemies) {
        for (SimFighter sf : all) {
            if (sf.id.equals(id)) {
                BattleFighterDTO dto = new BattleFighterDTO();
                dto.setId(sf.id); dto.setName(sf.name); dto.setTeam(sf.team);
                dto.setHp(sf.hp); dto.setMaxHp(sf.maxHp);
                dto.setAtk(sf.atk); dto.setDef(sf.def); dto.setSpd(sf.spd);
                return dto;
            }
        }
        return null;
    }

    // =====================================================================
    // ★ 여기서 수정! Macro, Micro, Luck -> Hp, Harass, Speed 로 호출 
    // =====================================================================
    @Override
    public List<BattleFighterDTO> prepareBattleData(String userId, int stageLevel, int subLevel) {

        List<BattleFighterDTO> fighters = new ArrayList<>();

        // ── 블루팀: 유저 PVE 엔트리 상위 3명 ──
        List<OwnedPlayerInfoDTO> myEntry = pveEntryDAO.selectPveEntryPlayersByUserId(userId);
        int blueCount = Math.min(myEntry.size(), 3);
        double[][] bluePos = { {20, 20}, {15, 50}, {20, 80} };

        for (int i = 0; i < blueCount; i++) {
            OwnedPlayerInfoDTO p = myEntry.get(i);
            fighters.add(BattleFighterDTO.fromStats(
                "b" + (i + 1), p.getPlayerName(), "blue",
                p.getRace(), p.getCurrentRarity(), p.getPlayerImgUrl(),
                p.getPlayerSeq(), p.getOwnedPlayerSeq(),
                // 변경된 DTO 메서드 호출 적용
                p.getTotalAttack(), p.getTotalDefense(), p.getTotalHp(),
                p.getTotalHarass(), p.getTotalSpeed(),
                bluePos[i][0], bluePos[i][1]
            ));
        }

        // ── 레드팀: 서브스테이지 상대 상위 3명 ──
        Map<String, Object> oppParams = new HashMap<>();
        oppParams.put("stageLevel", stageLevel);
        oppParams.put("subLevel",   subLevel);
        List<dto.pve.PveOpponentInfoDTO> opponents = pveOpponentDAO.findOpponentEntryBySubstage(oppParams);

        int redCount = Math.min(opponents.size(), 3);
        double[][] redPos = { {80, 20}, {85, 50}, {80, 80} };

        for (int i = 0; i < redCount; i++) {
            dto.pve.PveOpponentInfoDTO opp = opponents.get(i);
            fighters.add(BattleFighterDTO.fromStats(
                "r" + (i + 1), opp.getPlayerName(), "red",
                opp.getRace(), opp.getRarity(), opp.getPlayerImgUrl(),
                opp.getPlayerSeq(), 0,
                // 변경된 DTO 메서드 호출 적용
                opp.getStatAttack(), opp.getStatDefense(), opp.getStatHp(),
                opp.getStatHarass(), opp.getStatSpeed(),
                redPos[i][0], redPos[i][1]
            ));
        }

        return fighters;
    }

    // =====================================================================
    // 승패 결정 
    // =====================================================================
    @Override
    public List<Boolean> calculateWinResults(List<Map<String, Object>> matchupList) {
        List<Boolean> results = new ArrayList<>();
        Random rand = new Random();
        for (Map<String, Object> m : matchupList) {
            try { results.add(decideWinner(m, rand)); }
            catch (Exception e) { results.add(false); }
        }
        return results;
    }

    private boolean decideWinner(Map<String, Object> matchup, Random rand) {
        double myScore = calcBaseScore(matchup, "my");
        double aiScore = calcBaseScore(matchup, "ai");
        myScore *= conditionMult((String) matchup.getOrDefault("myCondition", "NORMAL"));
        aiScore *= conditionMult((String) matchup.getOrDefault("aiCondition", "NORMAL"));
        myScore *= streakMult(getInt(matchup, "myWinStreak", 0));
        aiScore *= streakMult(getInt(matchup, "aiWinStreak", 0));
        if (Math.abs(myScore - aiScore) / Math.max(myScore, aiScore) < 0.05) return rand.nextBoolean();
        return myScore > aiScore;
    }

    private double calcBaseScore(Map<String, Object> m, String prefix) {
        // 기존의 Macro/Micro/Luck 키 대신 Hp/Harass/Speed 키를 찾도록 변경
        return getInt(m, prefix+"Attack",50) + getInt(m, prefix+"Defense",50)
             + getInt(m, prefix+"Hp",50) + getInt(m, prefix+"Harass",50) + getInt(m, prefix+"Speed",50);
    }

    private double conditionMult(String c) {
        switch (c==null?"NORMAL":c) {
            case "PEAK":  return 1.20; case "GOOD":  return 1.10;
            case "TIRED": return 0.90; case "WORST": return 0.80;
            default:      return 1.00;
        }
    }

    private double streakMult(int s) {
        if(s>=5)return 1.10; if(s==4)return 1.08; if(s==3)return 1.06; if(s==2)return 1.03; return 1.00;
    }

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
        if (updated == 0) System.err.println("진행 상태 저장 실패: 활성 세션 없음");
    }

    private int getInt(Map<String, Object> map, String key, int def) {
        Object v = map.get(key);
        if (v == null) return def;
        if (v instanceof Integer) return (Integer) v;
        try { return Integer.parseInt(v.toString()); } catch (Exception e) { return def; }
    }
}