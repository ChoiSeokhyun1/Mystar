package service.pve;

import com.google.gson.Gson;
import dao.matchup.TeamMatchupDAO;
import dao.player.OwnedPlayerDAO;
import dao.player.PlayerTraitDAO;
import dao.pve.BattleSessionDAO;
import dao.pve.PveOpponentDAO;
import dto.matchup.TeamMatchupBonusDTO;
import dto.player.OwnedPlayerInfoDTO;
import dto.player.PlayerTraitDTO;
import dto.pve.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
public class PveBattleServiceImpl implements PveBattleService {

    private static final int    MAX_TICKS        = 5000;
    private static final int    ATB_THRESHOLD    = 100;
    private static final double COMBO_CHANCE     = 0.20;
    private static final double MIN_DMG_RATIO    = 0.10;
    private static final double HARASS_DMG_MULT  = 0.60;
    private static final double ASSIST_HEAL_PCT  = 0.12;
    private static final int    ASSIST_ATB_GIVE  = 60;
    private static final int    HARASS_ATB_DRAIN = 30;
    private static final int    DEF_SHIELD_TICKS = 2;

    @Autowired private BattleSessionDAO battleSessionDAO;
    @Autowired private PveOpponentDAO   pveOpponentDAO;
    @Autowired private TeamMatchupDAO   teamMatchupDAO;
    @Autowired private PlayerTraitDAO   playerTraitDAO;
    @Autowired private OwnedPlayerDAO   ownedPlayerDAO;

    private final Gson gson = new Gson();

    // =====================================================================
    @Override
    public Map<String, Object> runBattleSimulation(String userId, List<Integer> myOwnedPlayerSeqs,
                                                    int stageLevel, int subLevel, int setNumber) {

        List<BattleFighterDTO> fighters = prepareBattleData(userId, myOwnedPlayerSeqs, stageLevel, subLevel, setNumber);
        applyTeamMatchupBonus(fighters);

        Map<Integer, int[]> traitMap = loadTraitMap(userId);
        List<SimFighter> simFighters = toSimFighters(fighters, traitMap);
        List<GameEvent>  events      = new ArrayList<>();

        int tick = 0;
        Random rand = new Random();

        outer:
        while (tick < MAX_TICKS) {
            tick++;

            for (SimFighter sf : simFighters) {
                if (sf.hp > 0) sf.atb += sf.spd;
                if (sf.shieldTicks > 0) sf.shieldTicks--;
            }

            List<SimFighter> ready = new ArrayList<>();
            for (SimFighter sf : simFighters)
                if (sf.hp > 0 && sf.atb >= ATB_THRESHOLD) ready.add(sf);
            // ★ 속도가 같을 때 항상 같은 팀(blue)이 먼저 행동하는 편향을 막기 위해
            //   매 틱마다 무작위 타이브레이커를 부여한다. (입력 순서에 의존하는 stable sort 방지)
            Map<SimFighter, Integer> tieBreaker = new HashMap<>();
            for (SimFighter sf : ready) tieBreaker.put(sf, rand.nextInt());
            ready.sort((a, b) -> {
                int bySpd = Integer.compare(b.spd, a.spd);
                if (bySpd != 0) return bySpd;
                return Integer.compare(tieBreaker.get(a), tieBreaker.get(b));
            });

            for (SimFighter actor : ready) {
                if (actor.hp <= 0) continue;
                actor.atb = 0;

                List<SimFighter> enemies = getAlive(simFighters, opposite(actor.team));
                if (enemies.isEmpty()) break outer;

                String action = pickAction(actor, rand);

                boolean didCombo = false;
                if ("ATK".equals(action)) {
                    didCombo = tryCombo(actor, enemies, simFighters, events, tick, rand);
                }

                if (!didCombo) {
                    switch (action) {
                        case "ATK":    doAttack(actor, enemies, simFighters, fighters, events, tick, rand); break;
                        case "DEF":    doDefend(actor,          simFighters, fighters, events, tick, rand); break;
                        case "ASSIST": doAssist(actor,          simFighters, fighters, events, tick, rand); break;
                        case "HARASS": doHarass(actor, enemies, simFighters, fighters, events, tick, rand); break;
                        default:       doAttack(actor, enemies, simFighters, fighters, events, tick, rand);
                    }
                }

                if (isTeamWiped(simFighters, "blue") || isTeamWiped(simFighters, "red")) break outer;
            }

            if (isTeamWiped(simFighters, "blue") || isTeamWiped(simFighters, "red")) break;
        }

        boolean blueWon = !isTeamWiped(simFighters, "blue");
        String  winner  = blueWon ? "blue" : "red";
        events.add(GameEvent.battleEnd(tick, winner, blueWon ? "BLUE" : "RED"));

        Map<String, Object> result = new HashMap<>();
        result.put("fighters",     fighters);
        result.put("eventLogJson", gson.toJson(events));
        result.put("winner",       winner);
        return result;
    }

    // =====================================================================
    // 4가지 행동
    // =====================================================================

    private void doAttack(SimFighter actor, List<SimFighter> enemies,
                          List<SimFighter> allSim, List<BattleFighterDTO> fighters,
                          List<GameEvent> events, int tick, Random rand) {
        SimFighter target = pickLowestHpTarget(enemies);
        if (target == null) return;

        int effectiveDef = target.def + (target.shieldTicks > 0 ? target.def / 2 : 0);
        int rawDmg  = actor.atk - effectiveDef;
        int baseDmg = Math.max(rawDmg, (int)(actor.atk * MIN_DMG_RATIO));
        int damage  = (int)(baseDmg * (0.9 + rand.nextDouble() * 0.2));

        target.hp = Math.max(0, target.hp - damage);
        boolean lethal = target.hp <= 0;

        BattleFighterDTO actorDto  = findDto(fighters, actor.id);
        BattleFighterDTO targetDto = findDto(fighters, target.id);
        if (actorDto == null || targetDto == null) return;
        targetDto.setHp(target.hp);

        GameEvent ev = GameEvent.attack(tick, actorDto, targetDto, damage, lethal);
        ev.setActionType("ATK");
        ev.setAtbSnapshotJson(buildAtbSnapshot(allSim));
        events.add(ev);

        if (lethal) events.add(buildDeathEvent(tick, target, fighters, allSim));
    }

    private void doDefend(SimFighter actor,
                          List<SimFighter> allSim, List<BattleFighterDTO> fighters,
                          List<GameEvent> events, int tick, Random rand) {
        List<SimFighter> allies = getAlive(allSim, actor.team);
        SimFighter protectTarget = allies.stream()
                .min(Comparator.comparingDouble(a -> (double)a.hp / a.maxHp))
                .orElse(actor);
        protectTarget.shieldTicks = DEF_SHIELD_TICKS;

        GameEvent ev = new GameEvent();
        ev.setEventType("DEFEND");
        ev.setActionType("DEF");
        ev.setTick(tick);
        ev.setActorId(actor.id);   ev.setActorName(actor.name); ev.setActorTeam(actor.team);
        ev.setTargetId(protectTarget.id); ev.setTargetName(protectTarget.name);
        ev.setCurrentHp(protectTarget.hp); ev.setMaxHp(protectTarget.maxHp);
        BattleFighterDTO actorDto = findDto(fighters, actor.id);
        if (actorDto != null) { ev.setActorX(actorDto.getX()); ev.setActorY(actorDto.getY()); }
        ev.setLogMessage(protectTarget.id.equals(actor.id)
            ? "🛡 <strong>[" + actor.name + "]</strong> 수비 강화! DEF+" + (actor.def/2) + " (" + DEF_SHIELD_TICKS + "턴)"
            : "🛡 <strong>[" + actor.name + "]</strong> → <strong>[" + protectTarget.name + "]</strong> 보호!");
        ev.setLogType(actor.team);
        ev.setAtbSnapshotJson(buildAtbSnapshot(allSim));
        events.add(ev);
    }

    private void doAssist(SimFighter actor,
                          List<SimFighter> allSim, List<BattleFighterDTO> fighters,
                          List<GameEvent> events, int tick, Random rand) {
        List<SimFighter> allies = getAlive(allSim, actor.team);
        allies.removeIf(a -> a.id.equals(actor.id));
        if (allies.isEmpty()) allies.add(actor);

        SimFighter healTarget = allies.stream().min(Comparator.comparingInt(a -> a.hp)).orElse(actor);
        int healAmt = (int)(healTarget.maxHp * ASSIST_HEAL_PCT);
        healTarget.hp = Math.min(healTarget.maxHp, healTarget.hp + healAmt);

        SimFighter atbTarget = allies.stream().min(Comparator.comparingInt(a -> a.atb)).orElse(healTarget);
        atbTarget.atb = Math.min(ATB_THRESHOLD, atbTarget.atb + ASSIST_ATB_GIVE);

        BattleFighterDTO actorDto  = findDto(fighters, actor.id);
        BattleFighterDTO targetDto = findDto(fighters, healTarget.id);
        if (targetDto != null) targetDto.setHp(healTarget.hp);

        GameEvent ev = new GameEvent();
        ev.setEventType("ASSIST");
        ev.setActionType("ASSIST");
        ev.setTick(tick);
        ev.setActorId(actor.id); ev.setActorName(actor.name); ev.setActorTeam(actor.team);
        ev.setTargetId(healTarget.id); ev.setTargetName(healTarget.name);
        ev.setCurrentHp(healTarget.hp); ev.setMaxHp(healTarget.maxHp);
        ev.setDamage(-healAmt);
        if (actorDto != null) { ev.setActorX(actorDto.getX()); ev.setActorY(actorDto.getY()); }
        ev.setLogMessage("🤝 <strong>[" + actor.name + "]</strong> → <strong>[" + healTarget.name + "]</strong> 지원! +" + healAmt + " HP");
        ev.setLogType(actor.team);
        ev.setAtbSnapshotJson(buildAtbSnapshot(allSim));
        events.add(ev);
    }

    private void doHarass(SimFighter actor, List<SimFighter> enemies,
                          List<SimFighter> allSim, List<BattleFighterDTO> fighters,
                          List<GameEvent> events, int tick, Random rand) {
        SimFighter target = enemies.get(rand.nextInt(enemies.size()));

        int baseDmg = (int)(actor.atk * HARASS_DMG_MULT) - target.def / 2;
        int damage  = (int)(Math.max(baseDmg, (int)(actor.atk * MIN_DMG_RATIO)) * (0.85 + rand.nextDouble() * 0.3));

        target.hp  = Math.max(0, target.hp - damage);
        target.atb = Math.max(0, target.atb - HARASS_ATB_DRAIN);
        boolean lethal = target.hp <= 0;

        BattleFighterDTO actorDto  = findDto(fighters, actor.id);
        BattleFighterDTO targetDto = findDto(fighters, target.id);
        if (actorDto == null || targetDto == null) return;
        targetDto.setHp(target.hp);

        GameEvent ev = new GameEvent();
        ev.setEventType("HARASS");
        ev.setActionType("HARASS");
        ev.setTick(tick);
        ev.setActorId(actor.id);   ev.setActorName(actor.name);   ev.setActorTeam(actor.team);
        ev.setActorX(actorDto.getX()); ev.setActorY(actorDto.getY());
        ev.setTargetId(target.id); ev.setTargetName(target.name); ev.setTargetTeam(target.team);
        ev.setTargetX(targetDto.getX()); ev.setTargetY(targetDto.getY());
        ev.setDamage(damage); ev.setCurrentHp(target.hp); ev.setMaxHp(target.maxHp); ev.setLethal(lethal);
        ev.setLogMessage("💢 <strong>[" + actor.name + "]</strong> 견제! → <strong>[" + target.name + "]</strong> -" + damage + " & ATB-" + HARASS_ATB_DRAIN + (lethal ? " 💀" : ""));
        ev.setLogType(actor.team);
        ev.setAtbSnapshotJson(buildAtbSnapshot(allSim));
        events.add(ev);

        if (lethal) events.add(buildDeathEvent(tick, target, fighters, allSim));
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

        int damage = Math.max((int)((actor.atk + partner.atk) * 0.8) - target.def, (int)(actor.atk * 0.15));
        target.hp = Math.max(0, target.hp - damage);
        boolean lethal = target.hp <= 0;

        BattleFighterDTO actorDto   = makeTempDto(allFighters, actor.id);
        BattleFighterDTO partnerDto = makeTempDto(allFighters, partner.id);
        BattleFighterDTO targetDto  = makeTempDto(allFighters, target.id);
        if (actorDto == null || partnerDto == null || targetDto == null) return false;
        targetDto.setHp(target.hp);

        GameEvent ev = GameEvent.combo(tick, actorDto, partnerDto, targetDto, damage, lethal);
        ev.setActionType("ATK");
        ev.setAtbSnapshotJson(buildAtbSnapshot(allFighters));
        events.add(ev);
        if (lethal) events.add(buildDeathEvent(tick, target, null, allFighters));
        return true;
    }

    // =====================================================================
    // 특성 & 행동 선택
    // =====================================================================
    private String pickAction(SimFighter actor, Random rand) {
        int total = actor.atkW + actor.defW + actor.assistW + actor.harassW;
        if (total <= 0) return "ATK";
        int r = rand.nextInt(total);
        if ((r -= actor.atkW)    < 0) return "ATK";
        if ((r -= actor.defW)    < 0) return "DEF";
        if ((r -= actor.assistW) < 0) return "ASSIST";
        return "HARASS";
    }

    private Map<Integer, int[]> loadTraitMap(String userId) {
        Map<Integer, int[]> map = new HashMap<>();
        try {
            for (PlayerTraitDTO t : playerTraitDAO.getTraitListByUserId(userId))
                map.put(t.getOwnedPlayerSeq(), new int[]{t.getAtkWeight(), t.getDefWeight(), t.getAssistWeight(), t.getHarassWeight()});
        } catch (Exception e) { System.err.println("[Trait] 로드 실패: " + e.getMessage()); }
        return map;
    }

    // =====================================================================
    // 종족 상성
    // =====================================================================
    private void applyTeamMatchupBonus(List<BattleFighterDTO> fighters) {
        List<BattleFighterDTO> blue = new ArrayList<>(), red = new ArrayList<>();
        for (BattleFighterDTO f : fighters) { if ("blue".equals(f.getTeam())) blue.add(f); else red.add(f); }
        Map<String, Object> params = new HashMap<>();
        params.put("myTeamCombo", buildTeamCombo(blue)); params.put("oppTeamCombo", buildTeamCombo(red));
        TeamMatchupBonusDTO bonus = teamMatchupDAO.selectMatchupBonus(params);
        double mult = (bonus != null) ? bonus.getBonusMultiplier() : 1.0;
        if (mult == 1.0) return;
        for (BattleFighterDTO f : blue) {
            f.setAtk((int)(f.getAtk()*mult)); f.setDef((int)(f.getDef()*mult)); f.setSpd((int)(f.getSpd()*mult));
            int hp = (int)(f.getHp()*mult); f.setHp(hp); f.setMaxHp(hp);
        }
    }

    private String buildTeamCombo(List<BattleFighterDTO> team) {
        char[] c = new char[3];
        for (int i = 0; i < Math.min(team.size(),3); i++) { String r = team.get(i).getRace(); c[i] = (r!=null&&!r.isEmpty())?r.toUpperCase().charAt(0):'T'; }
        Arrays.sort(c); return new String(c);
    }

    // =====================================================================
    // SimFighter
    // =====================================================================
    private static class SimFighter {
        String id, team, name;
        int hp, maxHp, atk, def, spd, atb;
        int atkW=5, defW=5, assistW=3, harassW=3;
        int shieldTicks=0;
        SimFighter(BattleFighterDTO dto, int[] w) {
            id=dto.getId(); team=dto.getTeam(); name=dto.getName();
            hp=dto.getHp(); maxHp=dto.getMaxHp();
            atk=dto.getAtk(); def=dto.getDef(); spd=dto.getSpd(); atb=0;
            if (w!=null&&w.length==4) { atkW=w[0]; defW=w[1]; assistW=w[2]; harassW=w[3]; }
        }
    }

    private List<SimFighter> toSimFighters(List<BattleFighterDTO> fighters, Map<Integer,int[]> traitMap) {
        List<SimFighter> list=new ArrayList<>();
        for (BattleFighterDTO f : fighters) list.add(new SimFighter(f, traitMap.getOrDefault(f.getOwnedPlayerSeq(), null)));
        return list;
    }

    // =====================================================================
    // 유틸
    // =====================================================================
    private String opposite(String t) { return "blue".equals(t)?"red":"blue"; }
    private List<SimFighter> getAlive(List<SimFighter> all, String team) {
        List<SimFighter> l=new ArrayList<>(); for(SimFighter sf:all) if(team.equals(sf.team)&&sf.hp>0) l.add(sf); return l;
    }
    private boolean isTeamWiped(List<SimFighter> all, String team) {
        for(SimFighter sf:all) if(team.equals(sf.team)&&sf.hp>0) return false; return true;
    }
    private SimFighter pickLowestHpTarget(List<SimFighter> e) { return e.stream().min(Comparator.comparingInt(a->a.hp)).orElse(null); }
    private BattleFighterDTO findDto(List<BattleFighterDTO> list, String id) { for(BattleFighterDTO f:list) if(f.getId().equals(id)) return f; return null; }
    private BattleFighterDTO makeTempDto(List<SimFighter> all, String id) {
        for(SimFighter sf:all) if(sf.id.equals(id)) {
            BattleFighterDTO d=new BattleFighterDTO(); d.setId(sf.id); d.setName(sf.name); d.setTeam(sf.team);
            d.setHp(sf.hp); d.setMaxHp(sf.maxHp); d.setAtk(sf.atk); d.setDef(sf.def); d.setSpd(sf.spd); return d;
        } return null;
    }
    private GameEvent buildDeathEvent(int tick, SimFighter dead, List<BattleFighterDTO> fighters, List<SimFighter> allSim) {
        GameEvent ev=new GameEvent(); ev.setEventType("DEATH"); ev.setTick(tick);
        ev.setActorId(dead.id); ev.setActorName(dead.name); ev.setActorTeam(dead.team); ev.setLethal(true);
        ev.setLogMessage("💀 <strong>["+dead.name+"]</strong> 전사!"); ev.setLogType("kill");
        ev.setAtbSnapshotJson(buildAtbSnapshot(allSim));
        if(fighters!=null) { BattleFighterDTO d=findDto(fighters,dead.id); if(d!=null){ev.setActorX(d.getX());ev.setActorY(d.getY());} }
        return ev;
    }
    private String buildAtbSnapshot(List<SimFighter> all) {
        StringBuilder sb=new StringBuilder("[");
        for(int i=0;i<all.size();i++) {
            SimFighter sf=all.get(i); if(i>0) sb.append(",");
            sb.append("{\"id\":\"").append(sf.id).append("\",\"atb\":").append(Math.min(sf.atb,ATB_THRESHOLD))
              .append(",\"hp\":").append(Math.max(0,sf.hp))
              .append(",\"atkW\":").append(sf.atkW).append(",\"defW\":").append(sf.defW)
              .append(",\"assistW\":").append(sf.assistW).append(",\"harassW\":").append(sf.harassW).append("}");
        }
        return sb.append("]").toString();
    }

    // =====================================================================
    @Override
    public List<BattleFighterDTO> prepareBattleData(String userId, List<Integer> myOwnedPlayerSeqs,
                                                      int stageLevel, int subLevel, int setNumber) {
        List<BattleFighterDTO> fighters = new ArrayList<>();
        double[][] bluePos = {{20,20},{15,50},{20,80}};
        double[][] redPos  = {{80,20},{85,50},{80,80}};

        // ── 블루팀: 이번 세트에 배치된 내 선수 3명 (순서 보장) ──
        List<OwnedPlayerInfoDTO> myFighters = loadMyFightersInOrder(userId, myOwnedPlayerSeqs);
        for (int i = 0; i < Math.min(myFighters.size(), 3); i++) {
            OwnedPlayerInfoDTO p = myFighters.get(i);
            fighters.add(BattleFighterDTO.fromStats("b"+(i+1), p.getPlayerName(), "blue", p.getRace(),
                    p.getCurrentRarity(), p.getPlayerImgUrl(), p.getPlayerSeq(), p.getOwnedPlayerSeq(),
                    p.getTotalAttack(), p.getTotalDefense(), p.getTotalHp(), p.getTotalHarass(), p.getTotalSpeed(),
                    bluePos[i][0], bluePos[i][1]));
        }

        // ── 레드팀: setNumber(1~3) 세트의 AI 엔트리 3명. 9슬롯 체계에서 해당 구간만 조회 ──
        Map<String,Object> oppParams = new HashMap<>();
        oppParams.put("stageLevel", stageLevel);
        oppParams.put("subLevel",   subLevel);
        oppParams.put("setNumber",  setNumber);
        oppParams.put("setStart",   (setNumber - 1) * 3 + 1);
        oppParams.put("setEnd",     setNumber * 3);
        List<PveOpponentInfoDTO> opponents = pveOpponentDAO.findOpponentEntryBySubstage(oppParams);
        for (int i = 0; i < Math.min(opponents.size(), 3); i++) {
            PveOpponentInfoDTO opp = opponents.get(i);
            fighters.add(BattleFighterDTO.fromStats("r"+(i+1), opp.getPlayerName(), "red", opp.getRace(),
                    opp.getRarity(), opp.getPlayerImgUrl(), opp.getPlayerSeq(), 0,
                    opp.getStatAttack(), opp.getStatDefense(), opp.getStatHp(), opp.getStatHarass(), opp.getStatSpeed(),
                    redPos[i][0], redPos[i][1]));
        }
        return fighters;
    }

    /**
     * myOwnedPlayerSeqs 순서를 보존하면서 OwnedPlayerInfoDTO 목록을 가져온다.
     * (DB 조회 결과는 순서가 보장되지 않으므로 재정렬 필요)
     * PVE 엔트리 등록 여부와 무관하게, 유저가 보유한 선수라면 어떤 선수든 출전 가능
     * (단, userId 일치 검증으로 타인 선수 도용을 방지한다).
     */
    private List<OwnedPlayerInfoDTO> loadMyFightersInOrder(String userId, List<Integer> seqs) {
        List<OwnedPlayerInfoDTO> result = new ArrayList<>();
        if (seqs == null || seqs.isEmpty()) return result;

        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("seqs", seqs);
        List<OwnedPlayerInfoDTO> fetched = ownedPlayerDAO.selectOwnedPlayersBySeqs(params);

        Map<Integer, OwnedPlayerInfoDTO> bySeq = new HashMap<>();
        for (OwnedPlayerInfoDTO p : fetched) bySeq.put(p.getOwnedPlayerSeq(), p);

        for (Integer seq : seqs) {
            OwnedPlayerInfoDTO p = bySeq.get(seq);
            if (p != null) result.add(p);
            else System.err.println("[PveBattle] ownedPlayerSeq=" + seq + " 조회 실패 (소유 불일치 또는 존재하지 않음)");
        }
        return result;
    }

    @Override
    public List<Boolean> calculateWinResults(List<Map<String,Object>> matchupList) {
        List<Boolean> r=new ArrayList<>(); Random rand=new Random();
        for(Map<String,Object> m:matchupList) { try{r.add(decideWinner(m,rand));}catch(Exception e){r.add(false);} }
        return r;
    }
    private boolean decideWinner(Map<String,Object> m, Random rand) {
        double my=calcBaseScore(m,"my")*conditionMult((String)m.getOrDefault("myCondition","NORMAL"))*streakMult(getInt(m,"myWinStreak",0));
        double ai=calcBaseScore(m,"ai")*conditionMult((String)m.getOrDefault("aiCondition","NORMAL"))*streakMult(getInt(m,"aiWinStreak",0));
        if(Math.abs(my-ai)/Math.max(my,ai)<0.05) return rand.nextBoolean(); return my>ai;
    }
    private double calcBaseScore(Map<String,Object> m, String p) {
        return getInt(m,p+"Attack",50)+getInt(m,p+"Defense",50)+getInt(m,p+"Hp",50)+getInt(m,p+"Harass",50)+getInt(m,p+"Speed",50);
    }
    private double conditionMult(String c) {
        if(c==null) return 1.0;
        switch(c){case"PEAK":return 1.20;case"GOOD":return 1.10;case"TIRED":return 0.90;case"WORST":return 0.80;default:return 1.00;}
    }
    private double streakMult(int s){if(s>=5)return 1.10;if(s==4)return 1.08;if(s==3)return 1.06;if(s==2)return 1.03;return 1.00;}

    @Override @Transactional
    public void saveProgress(BattleProgressDTO progress) {
        Map<String,Object> params=new HashMap<>();
        params.put("userId",progress.getUserId()); params.put("stageLevel",progress.getLevel());
        params.put("subLevel",progress.getSubLevel()); params.put("currentSet",progress.getCurrentSet());
        params.put("myWins",progress.getMyWins()); params.put("aiWins",progress.getAiWins());
        if(progress.getGameStateData()!=null) params.put("gameStateData",progress.getGameStateData());
        if(battleSessionDAO.updateBattleProgress(params)==0) System.err.println("진행 상태 저장 실패");
    }
    private int getInt(Map<String,Object> map,String key,int def){Object v=map.get(key);if(v==null)return def;if(v instanceof Integer)return(Integer)v;try{return Integer.parseInt(v.toString());}catch(Exception e){return def;}}
}