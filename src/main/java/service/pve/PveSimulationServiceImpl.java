package service.pve;

import dto.pve.*;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class PveSimulationServiceImpl implements PveSimulationService {

    private final Random rand = new Random();

    private static final int GAME_DURATION = 1800;
    private static final int EARLY_END     = 600;
    private static final int MID_END       = 1200;

    private String getCurrentPhase(int time) {
        if (time < EARLY_END) return "EARLY";
        if (time < MID_END)   return "MID";
        return "LATE";
    }

    private String nextPhase(String phase) {
        if ("EARLY".equals(phase)) return "MID";
        if ("MID".equals(phase))   return "LATE";
        return "LATE";
    }

    // ── 플레이스타일별 페이즈 가중치 ──────────────────────────
    private double[] getPhaseAttackWeights(String playStyle) {
        switch (playStyle == null ? "AGGRESSIVE" : playStyle) {
            case "AGGRESSIVE":   return new double[]{0.35, 0.50, 0.15}; // 공격 스타일: 초·중반 집중
            case "NORMAL":       return new double[]{0.20, 0.43, 0.37}; // 일반 스타일: 균형 배분
            case "DEFENSIVE":    return new double[]{0.05, 0.35, 0.60}; // 수비 스타일: 후반 결전
            // 구버전 호환
            case "HARASS_FOCUS": return new double[]{0.20, 0.43, 0.37};
            case "EARLY_ALLIN": return new double[]{0.90, 0.10, 0.00};
            case "MID_TIMING":  return new double[]{0.10, 0.80, 0.10};
            case "LATE_OPS":    return new double[]{0.00, 0.10, 0.90};
            case "RUSH":  return new double[]{0.90, 0.10, 0.00};
            case "EARLY": return new double[]{0.60, 0.25, 0.15};
            case "LATE":  return new double[]{0.05, 0.15, 0.80};
            default:      return new double[]{0.20, 0.43, 0.37};
        }
    }

    // ── 전투 스케줄 생성 ──────────────────────────────────────
    private Set<Integer> generateBattleSchedule(BuildDTO myBuild, BuildDTO aiBuild) {
        List<Integer> combined = new ArrayList<>();
        combined.addAll(generateSideSchedule(myBuild));
        combined.addAll(generateSideSchedule(aiBuild));
        // 합치지 않고 양측 타이밍 그대로 유지 — 내팀/AI 각자 공격 타이밍이 따로 발생
        Set<Integer> merged = new TreeSet<>(combined);

        // 추가 랜덤성: ±1~2회 무작위 조정 (최소 2회 보장)
        int delta = rand.nextInt(4) - 1;  // -1 ~ +2
        if (delta > 0) {
            for (int i = 0; i < delta; i++) {
                int t = 120 + rand.nextInt(GAME_DURATION - 120);
                merged.add(t);
            }
        } else if (delta < 0 && merged.size() > 2) {
            List<Integer> list = new ArrayList<>(merged);
            list.remove(rand.nextInt(list.size()));
            merged = new TreeSet<>(list);
        }
        return merged;
    }

    private List<Integer> generateSideSchedule(BuildDTO build) {
        String playStyle = build.getPlayStyle();

        // playStyle 기반으로 전투 횟수 + 타이밍 결정
        int baseCount;
        int earlyStart;
        switch (playStyle == null ? "AGGRESSIVE" : playStyle) {
            case "AGGRESSIVE":   baseCount = 4 + rand.nextInt(2); earlyStart = 60;  break; // 공격스타일: 교전 자주, 초반부터
            case "NORMAL":       baseCount = 3 + rand.nextInt(2); earlyStart = 120; break; // 일반스타일: 중간 교전 빈도
            case "DEFENSIVE":    baseCount = 2 + rand.nextInt(2); earlyStart = 180; break; // 수비스타일: 교전 적게, 후반 위주
            // 구버전 호환
            case "HARASS_FOCUS": baseCount = 3 + rand.nextInt(2); earlyStart = 120; break;
            case "EARLY_ALLIN": baseCount = 3 + rand.nextInt(2); earlyStart = 60;  break;
            case "MID_TIMING":  baseCount = 3 + rand.nextInt(2); earlyStart = 120; break;
            case "LATE_OPS":    baseCount = 2 + rand.nextInt(2); earlyStart = 120; break;
            case "RUSH":        baseCount = 4 + rand.nextInt(2); earlyStart = 60;  break;
            case "EARLY":       baseCount = 5 + rand.nextInt(3); earlyStart = 90;  break;
            case "LATE":        baseCount = 2 + rand.nextInt(2); earlyStart = 120; break;
            default:            baseCount = 3 + rand.nextInt(3); earlyStart = 120; break;
        }

        // MAX_MULTI(확장 성향) 최소 멀티: 병력 집중 → 교전 횟수 +1
        if ("MIN_MULTI".equals(build.getAggression())) baseCount += 1;
        // MAX_MULTI 최대 멀티: 경제 집중 → 교전 횟수 -1
        if ("MAX_MULTI".equals(build.getAggression())) baseCount = Math.max(1, baseCount - 1);
        // 구버전 호환 (expandStyle 필드 제거됨)
        baseCount = Math.max(1, baseCount);

        double[] w = getPhaseAttackWeights(playStyle);
        int earlyCount = (int) Math.round(baseCount * w[0]);
        int midCount   = (int) Math.round(baseCount * w[1]);
        int lateCount  = Math.max(0, baseCount - earlyCount - midCount);

        List<Integer> times = new ArrayList<>();
        times.addAll(randomTimes(earlyCount, earlyStart, EARLY_END));
        times.addAll(randomTimes(midCount,   EARLY_END,  MID_END));
        times.addAll(randomTimes(lateCount,  MID_END,    GAME_DURATION));
        return times;
    }

    // ── 견제 스케줄 생성 ───────────────────────────────────────
    // 견제 성향별 견제 횟수 기준
    //   NO_HARASS    : 견제 안 함 — 0회
    //   NORMAL_HARASS: 일반 견제 — 4회 ±2 (2~6회)
    //   HEAVY_HARASS : 강한 견제 — 9회 ±2 (7~11회)
    // 타이밍은 4분~30분 전체 구간에서 완전 랜덤 배치
    // 최소 간격 30초 (동시 발생 방지 수준) — 균등 배치 없음
    private Set<Integer> generateHarassSchedule(String harassStyle) {
        if (harassStyle == null) harassStyle = "NORMAL_HARASS";

        // 견제 없음 — 즉시 빈 Set 반환
        if ("NO_HARASS".equals(harassStyle)) return new TreeSet<>();

        // 기준 횟수 결정
        int base;
        switch (harassStyle) {
            case "HEAVY_HARASS":  base = 9;  break;  // 강한 견제: 7~11회
            case "NORMAL_HARASS": base = 4;  break;  // 일반 견제: 2~6회
            // 구버전 호환
            case "HEAVY_HARAS":  base = 9;  break;
            case "LIGHT_HARAS":  base = 4;  break;
            default:             base = 4;  break;
        }

        // ±2 랜덤성 (base-2 ~ base+2)
        int count = base + rand.nextInt(5) - 2;
        count = Math.max(1, count);

        // 4분(240초)부터 30분(1800초) 전 구간 중 완전 랜덤 — 중복 제한 없음
        final int START = 240;
        final int END   = GAME_DURATION;

        Set<Integer> schedule = new TreeSet<>();
        while (schedule.size() < count) {
            schedule.add(START + rand.nextInt(END - START));
        }
        return schedule;
    }

    private List<Integer> randomTimes(int count, int minT, int maxT) {
        List<Integer> times = new ArrayList<>();
        if (count <= 0 || minT >= maxT) return times;
        for (int i = 0; i < count; i++) times.add(minT + rand.nextInt(maxT - minT));
        return times;
    }

    // ── 멀티 확장 스케줄 ──────────────────────────────────────
    // 첫 멀티 건설 시도 최소 시간 — 4분~7분 랜덤
    private int getFirstExpandTime() {
        return 240 + rand.nextInt(181);
    }

    // 멀티 간 쿨타임 — aggression(확장 성향)별, ±30초 랜덤
    // MIN_MULTI: 10분 / MID_MULTI: 7분 / MAX_MULTI: 4분
    private int getExpandCooldown(String aggression) {
        int base;
        switch (aggression == null ? "MID_MULTI" : aggression) {
            case "MIN_MULTI": base = 600; break;
            case "MID_MULTI": base = 420; break;
            case "MAX_MULTI": base = 240; break;
            default:          base = 420; break;
        }
        return base + rand.nextInt(61) - 30;
    }

    // 최대 기지 수 (본진 포함)
    // MIN_MULTI: 멀티 1개 = 기지 2개
    // MID_MULTI: 멀티 3개 = 기지 4개
    // MAX_MULTI: 멀티 5개 = 기지 6개
    private int getMaxBases(String expandScale) {
        switch (expandScale == null ? "MID_MULTI" : expandScale) {
            case "MIN_MULTI": return 2;
            case "MID_MULTI": return 4;
            case "MAX_MULTI": return 6;
            default:          return 4;
        }
    }

    // =====================================================
    // 엔티티 DB
    // =====================================================
    private static class EntityData {
        String id, name, type, race;
        String productionBuilding, techBuilding, requiredBuilding;
        int mineralCost, gasCost, buildTime;
        double combatPower;

        // 유닛용 (가스 비용 포함)
        EntityData(String id, String name, String type, String race,
                   int mineralCost, int gasCost, int buildTime,
                   String prodBld, String techBld, double power) {
            this.id=id; this.name=name; this.type=type; this.race=race;
            this.mineralCost=mineralCost; this.gasCost=gasCost; this.buildTime=buildTime;
            this.productionBuilding=prodBld; this.techBuilding=techBld;
            this.requiredBuilding=techBld!=null?techBld:prodBld;
            this.combatPower=power;
        }

        // 건물용 (가스 0)
        EntityData(String id, String name, String type, String race,
                   int mineralCost, int buildTime, String req, double power) {
            this.id=id; this.name=name; this.type=type; this.race=race;
            this.mineralCost=mineralCost; this.gasCost=0; this.buildTime=buildTime;
            this.productionBuilding=req; this.techBuilding=null; this.requiredBuilding=req;
            this.combatPower=power;
        }

        // 건물용 (가스 있음 — tier3 에드온 등)
        EntityData(String id, String name, String type, String race,
                   int mineralCost, int gasCost, int buildTime, String req, double power) {
            this.id=id; this.name=name; this.type=type; this.race=race;
            this.mineralCost=mineralCost; this.gasCost=gasCost; this.buildTime=buildTime;
            this.productionBuilding=req; this.techBuilding=null; this.requiredBuilding=req;
            this.combatPower=power;
        }
    }

    private static final Map<String, EntityData> ENTITY_DB = new LinkedHashMap<>();
    static {
        // ── 테란 건물 ── (티어 1 / 2 / 3)
        // [티어 1] 빠른 건설, 저렴 (buildTime 50~70s)
        ENTITY_DB.put("command_center", new EntityData("command_center","커맨드센터","building","T",400, 60,null,0));
        ENTITY_DB.put("refinery",       new EntityData("refinery",      "정제소",   "building","T",100, 40,"command_center",0));
        ENTITY_DB.put("barracks",       new EntityData("barracks",      "배럭스",   "building","T",150, 60,"command_center",0));
        ENTITY_DB.put("academy",        new EntityData("academy",       "아카데미", "building","T",150, 65,"barracks",0));
        // [티어 2] 중간 건설시간, 중간 비용 (buildTime 75~90s)
        ENTITY_DB.put("factory",        new EntityData("factory",       "팩토리",   "building","T",200, 80,"barracks",0));
        ENTITY_DB.put("machine_shop",   new EntityData("machine_shop",  "머신샵",   "building","T", 50, 75,"factory",0));  // 에드온 — 탱크 해금
        ENTITY_DB.put("armory",         new EntityData("armory",        "아머리",   "building","T",100, 80,"factory",0));  // 골리앗 해금
        ENTITY_DB.put("starport",       new EntityData("starport",      "스타포트", "building","T",150, 85,"factory",0));  // 레이스·드랍쉽
        // [티어 3] 느린 건설, 고비용 (buildTime 110~130s)
        ENTITY_DB.put("science_facility",new EntityData("science_facility","사이언스 퍼실리티","building","T",400,     120,"starport",0)); // 베슬 해금 기지
        ENTITY_DB.put("nuclear_silo",   new EntityData("nuclear_silo",  "뉴클리어 어댑터","building","T",100,100,120,"science_facility",0)); // 고스트 해금
        ENTITY_DB.put("battle_adaptor", new EntityData("battle_adaptor","배틀 어댑터",    "building","T",100,150,125,"science_facility",0)); // 배틀크루저 해금
        // ── 테란 유닛 (mineral, gas, time, prodBld, techBld, power) ──
        // [티어 1 유닛]
        ENTITY_DB.put("scv",     new EntityData("scv",    "SCV",      "unit","T", 50,  0, 26,"command_center",null,       0.0));
        ENTITY_DB.put("marine",  new EntityData("marine", "마린",     "unit","T", 50,  0, 24,"barracks",      null,       6.0));
        ENTITY_DB.put("firebat", new EntityData("firebat","파이어뱃", "unit","T", 50, 25, 24,"barracks",      "academy", 16.0));
        ENTITY_DB.put("medic",   new EntityData("medic",  "메딕",     "unit","T", 50, 25, 30,"barracks",      "academy",  3.0));
        // [티어 2 유닛]
        ENTITY_DB.put("vulture", new EntityData("vulture","벌처",     "unit","T", 75,  0, 30,"factory",       null,      20.0));
        ENTITY_DB.put("tank",    new EntityData("tank",   "탱크",     "unit","T",150,100, 35,"factory",       "machine_shop", 30.0));
        ENTITY_DB.put("goliath", new EntityData("goliath","골리앗",   "unit","T",100, 50, 40,"factory",       "armory",  18.0));
        ENTITY_DB.put("wraith",  new EntityData("wraith", "레이스",   "unit","T",150,100, 40,"starport",      null,      15.0));
        ENTITY_DB.put("dropship",new EntityData("dropship","드랍쉽",  "unit","T",100,100, 50,"starport",      null,       0.0));
        // [티어 3 유닛]
        ENTITY_DB.put("vessel",       new EntityData("vessel",       "사이언스베슬","unit","T",100,225, 60,"starport","science_facility",  8.0));
        ENTITY_DB.put("ghost",        new EntityData("ghost",        "고스트",      "unit","T", 25, 75, 40,"barracks","nuclear_silo",     22.0));
        ENTITY_DB.put("battlecruiser",new EntityData("battlecruiser","배틀크루저",  "unit","T",400,300,140,"starport","battle_adaptor",   85.0));
        // ── 저그 건물 ── (티어 1 / 2 / 3)
        // [티어 1] 해처리 단계
        ENTITY_DB.put("hatchery",       new EntityData("hatchery",       "해처리",         "building","Z",300,  0, 60,null,             0));
        ENTITY_DB.put("extractor",      new EntityData("extractor",      "추출기",         "building","Z", 50,  0, 40,"hatchery",       0));
        ENTITY_DB.put("spawning_pool",  new EntityData("spawning_pool",  "스포닝풀",       "building","Z",200,  0, 65,"hatchery",       0));
        ENTITY_DB.put("hydralisk_den",  new EntityData("hydralisk_den",  "히드라덴",       "building","Z",100,  0, 40,"hatchery",       0));
        // [티어 2] 레어 단계
        ENTITY_DB.put("lair",           new EntityData("lair",           "레어",           "building","Z",150,100,100,"spawning_pool",  0));
        ENTITY_DB.put("spire",          new EntityData("spire",          "스파이어",       "building","Z",200,200,120,"lair",           0));
        ENTITY_DB.put("queens_nest",    new EntityData("queens_nest",    "퀸즈 네스트",    "building","Z",150,100,100,"lair",           0));
        // [티어 3] 하이브 단계
        ENTITY_DB.put("hive",           new EntityData("hive",           "하이브",         "building","Z",200,150,120,"queens_nest",    0));
        ENTITY_DB.put("greater_spire",  new EntityData("greater_spire",  "그레이트 스파이어","building","Z",100,150,100,"hive",           0));
        ENTITY_DB.put("defiler_mound",  new EntityData("defiler_mound",  "디파일러 마운드", "building","Z",100,100,100,"hive",           0));
        ENTITY_DB.put("ultralisk_cavern",new EntityData("ultralisk_cavern","울트라리스크 케이번","building","Z",150,200,100,"hive",        0));
        // ── 저그 유닛 ──
        // [티어 1]
        ENTITY_DB.put("drone",      new EntityData("drone",      "드론",           "unit","Z", 50,  0, 26,"hatchery",       null,          0.0));
        ENTITY_DB.put("zergling",   new EntityData("zergling",   "저글링",         "unit","Z", 25,  0, 28,"spawning_pool",  null,          5.0));
        ENTITY_DB.put("hydralisk",  new EntityData("hydralisk",  "히드라리스크",   "unit","Z", 75, 25, 28,"hydralisk_den",  null,         10.0));
        // [티어 2]
        ENTITY_DB.put("lurker",     new EntityData("lurker",     "러커",           "unit","Z", 50,100, 40,"hydralisk_den",  "lair",       18.0));
        ENTITY_DB.put("mutalisk",   new EntityData("mutalisk",   "뮤탈리스크",     "unit","Z",100,100, 40,"spire",          null,           9.0));
        ENTITY_DB.put("scourge",    new EntityData("scourge",    "스컬지",         "unit","Z", 25, 75, 30,"spire",          null,           7.0));
        ENTITY_DB.put("queen",      new EntityData("queen",      "퀸",             "unit","Z",100,100, 75,"queens_nest",    null,           5.0));
        // [티어 3]
        ENTITY_DB.put("guardian",   new EntityData("guardian",   "가디언",         "unit","Z", 50,100, 40,"greater_spire",  null,          22.0));
        ENTITY_DB.put("devourer",   new EntityData("devourer",   "디바우러",       "unit","Z", 25, 75, 40,"greater_spire",  null,          14.0));
        ENTITY_DB.put("ultralisk",  new EntityData("ultralisk",  "울트라리스크",   "unit","Z",200,200, 60,"ultralisk_cavern",null,         40.0));
        ENTITY_DB.put("defiler",    new EntityData("defiler",    "디파일러",       "unit","Z", 50,150, 60,"defiler_mound",  null,          10.0));
        // ── 프로토스 건물 ── (티어 1 / 2 / 3)
        // [티어 1]
        ENTITY_DB.put("nexus",              new EntityData("nexus",              "넥서스",             "building","P",400, 60,null,0));
        ENTITY_DB.put("assimilator",        new EntityData("assimilator",        "동화기",             "building","P",100, 40,"nexus",0));
        ENTITY_DB.put("gateway",            new EntityData("gateway",            "게이트웨이",         "building","P",150, 60,"nexus",0));
        ENTITY_DB.put("cybernetics_core",   new EntityData("cybernetics_core",   "사이버네틱스코어",   "building","P",200, 60,"gateway",0));
        // [티어 2]
        ENTITY_DB.put("citadel_of_adun",    new EntityData("citadel_of_adun",    "시타델 아둔",        "building","P",150, 60,"cybernetics_core",0));
        ENTITY_DB.put("templar_archives",   new EntityData("templar_archives",   "템플러 아카이브",    "building","P",150, 90,"citadel_of_adun",0));
        ENTITY_DB.put("robotics_facility",  new EntityData("robotics_facility",  "로보틱스 퍼실리티",  "building","P",200, 80,"cybernetics_core",0));
        ENTITY_DB.put("robotics_support_bay",new EntityData("robotics_support_bay","로보틱스 서포트베이","building","P",120, 55,"robotics_facility",0));
        ENTITY_DB.put("stargate",           new EntityData("stargate",           "스타게이트",         "building","P",150, 70,"cybernetics_core",0));
        // [티어 3]
        ENTITY_DB.put("fleet_beacon",       new EntityData("fleet_beacon",       "플릿 비콘",          "building","P",300,200,"stargate",0));
        ENTITY_DB.put("arbiter_tribunal",   new EntityData("arbiter_tribunal",   "아비터 트리뷰널",    "building","P",200,150,"stargate",0));
        // ── 프로토스 유닛 ──
        // [티어 1]
        ENTITY_DB.put("probe",        new EntityData("probe",        "프로브",     "unit","P", 50,  0, 26,"nexus",               null,               0.0));
        ENTITY_DB.put("zealot",       new EntityData("zealot",       "질럿",       "unit","P",100,  0, 40,"gateway",             null,              16.0));
        ENTITY_DB.put("dragoon",      new EntityData("dragoon",      "드라군",     "unit","P",125, 50, 50,"cybernetics_core",    null,              20.0));
        // [티어 2]
        ENTITY_DB.put("high_templar", new EntityData("high_templar", "하이템플러", "unit","P", 50,150, 50,"gateway",             "templar_archives",22.0));
        ENTITY_DB.put("dark_templar", new EntityData("dark_templar", "다크템플러", "unit","P",125,100, 50,"gateway",             "templar_archives",26.0));
        ENTITY_DB.put("shuttle",      new EntityData("shuttle",      "셔틀",       "unit","P",200,  0, 65,"robotics_facility",   null,               0.0));
        ENTITY_DB.put("reaver",       new EntityData("reaver",       "리버",       "unit","P",200,100, 70,"robotics_facility",   "robotics_support_bay",35.0));
        ENTITY_DB.put("corsair",      new EntityData("corsair",      "커세어",     "unit","P",150,100, 40,"stargate",            null,              12.0));
        ENTITY_DB.put("scout",        new EntityData("scout",        "스카우트",   "unit","P",150,100, 80,"stargate",            null,              14.0));
        // [티어 3]
        ENTITY_DB.put("carrier",      new EntityData("carrier",      "캐리어",     "unit","P",350,250,140,"stargate",            "fleet_beacon",    70.0));
        ENTITY_DB.put("arbiter",      new EntityData("arbiter",      "아비터",     "unit","P",100,350,160,"stargate",            "arbiter_tribunal",30.0));
    }

    // ── 유닛 상성 테이블 (JSP COUNTER 객체와 동일) ──────────────────────
    // good: 내 유닛이 유리한 상대 유닛 목록
    // bad : 내 유닛이 불리한 상대 유닛 목록
    private static final Map<String, List<String>> COUNTER_GOOD = new HashMap<String, List<String>>() {{
        put("marine",        Arrays.asList("zergling","zealot","mutalisk"));
        put("firebat",       Arrays.asList("zergling","zealot","hydralisk"));
        put("medic",         Collections.emptyList());
        put("vulture",       Arrays.asList("zergling","zealot"));
        put("tank",          Arrays.asList("hydralisk","zealot","dragoon","lurker"));
        put("goliath",       Arrays.asList("mutalisk","wraith","corsair","carrier"));
        put("wraith",        Arrays.asList("mutalisk","corsair","zergling"));
        put("ghost",         Arrays.asList("lurker","high_templar","carrier"));
        put("vessel",        Arrays.asList("lurker","zergling","dark_templar"));
        put("battlecruiser", Arrays.asList("zealot","hydralisk","mutalisk"));
        put("zergling",      Arrays.asList("marine","firebat","medic"));
        put("hydralisk",     Arrays.asList("marine","wraith","zealot"));
        put("mutalisk",      Arrays.asList("marine","tank","vessel","reaver"));
        put("lurker",        Arrays.asList("marine","firebat","zealot","dragoon"));
        put("scourge",       Arrays.asList("wraith","corsair","carrier","battlecruiser"));
        put("queen",         Arrays.asList("marine","zealot","zergling"));
        put("guardian",      Arrays.asList("marine","zealot","zergling","hydralisk"));
        put("devourer",      Arrays.asList("mutalisk","wraith","corsair","carrier"));
        put("ultralisk",     Arrays.asList("marine","firebat","zergling","zealot"));
        put("defiler",       Arrays.asList("marine","zealot","hydralisk"));
        put("zealot",        Arrays.asList("marine","firebat","zergling","vulture"));
        put("dragoon",       Arrays.asList("wraith","vulture","mutalisk"));
        put("dark_templar",  Arrays.asList("marine","zergling","hydralisk"));
        put("reaver",        Arrays.asList("marine","vulture","zergling","hydralisk"));
        put("high_templar",  Arrays.asList("zergling","hydralisk","marine","lurker"));
        put("corsair",       Arrays.asList("mutalisk","wraith"));
        put("carrier",       Arrays.asList("zergling","hydralisk","marine"));
        put("shuttle",       Arrays.asList("zergling","hydralisk"));
        put("scout",         Arrays.asList("mutalisk","corsair","wraith"));
        put("arbiter",       Arrays.asList("marine","zergling","hydralisk"));
    }};
    private static final Map<String, List<String>> COUNTER_BAD = new HashMap<String, List<String>>() {{
        put("marine",        Arrays.asList("lurker","tank","reaver","dark_templar"));
        put("firebat",       Arrays.asList("tank","dragoon","lurker"));
        put("medic",         Arrays.asList("lurker","tank","reaver"));
        put("vulture",       Arrays.asList("hydralisk","dragoon","reaver"));
        put("tank",          Arrays.asList("mutalisk","dark_templar","wraith"));
        put("goliath",       Arrays.asList("zealot","zergling"));
        put("wraith",        Arrays.asList("goliath","hydralisk","dragoon"));
        put("ghost",         Arrays.asList("zergling","zealot","hydralisk"));
        put("vessel",        Arrays.asList("mutalisk","corsair"));
        put("battlecruiser", Arrays.asList("goliath","wraith","corsair"));
        put("zergling",      Arrays.asList("vulture","tank","zealot","dark_templar"));
        put("hydralisk",     Arrays.asList("tank","lurker","reaver","high_templar"));
        put("mutalisk",      Arrays.asList("goliath","wraith","corsair","scourge"));
        put("lurker",        Arrays.asList("vessel","ghost","high_templar"));
        put("scourge",       Arrays.asList("goliath","hydralisk","devourer"));
        put("queen",         Arrays.asList("vessel","ghost","goliath"));
        put("guardian",      Arrays.asList("goliath","corsair","scout","wraith"));
        put("devourer",      Arrays.asList("goliath","corsair","hydralisk"));
        put("ultralisk",     Arrays.asList("lurker","reaver","tank"));
        put("defiler",       Arrays.asList("vessel","ghost","corsair"));
        put("zealot",        Arrays.asList("lurker","tank","reaver","high_templar"));
        put("dragoon",       Arrays.asList("lurker","zealot","zergling"));
        put("dark_templar",  Arrays.asList("vessel","ghost"));
        put("reaver",        Arrays.asList("mutalisk","wraith"));
        put("high_templar",  Arrays.asList("dark_templar","lurker"));
        put("corsair",       Arrays.asList("goliath","hydralisk","scout"));
        put("carrier",       Arrays.asList("goliath","ghost","corsair"));
        put("shuttle",       Arrays.asList("goliath","wraith","corsair","hydralisk"));
        put("scout",         Arrays.asList("goliath","corsair","hydralisk"));
        put("arbiter",       Arrays.asList("goliath","corsair","hydralisk"));
    }};

    private static final List<String> BUILD_ORDER_T = Arrays.asList(
            "command_center","refinery","barracks","academy",
            "factory","machine_shop","armory","starport",
            "science_facility","nuclear_silo","battle_adaptor");
    private static final List<String> BUILD_ORDER_Z = Arrays.asList(
            "hatchery","extractor","spawning_pool","hydralisk_den",
            "lair","spire","queens_nest",
            "hive","greater_spire","defiler_mound","ultralisk_cavern");
    private static final List<String> BUILD_ORDER_P = Arrays.asList(
            "nexus","assimilator","gateway","cybernetics_core",
            "citadel_of_adun","templar_archives",
            "robotics_facility","robotics_support_bay",
            "stargate","fleet_beacon","arbiter_tribunal");

    // ── 엔티티별 티어 (건물+유닛 공통) ─────────────────────
    private static final Map<String, Integer> ENTITY_TIER = new HashMap<String, Integer>() {{
        // Terran 건물
        put("command_center",1); put("refinery",1); put("barracks",1); put("academy",1);
        put("factory",2); put("machine_shop",2); put("armory",2); put("starport",2);
        put("science_facility",3); put("nuclear_silo",3); put("battle_adaptor",3);
        // Terran 유닛
        put("scv",1); put("marine",1); put("firebat",1); put("medic",1);
        put("vulture",2); put("tank",2); put("goliath",2); put("wraith",2); put("dropship",2);
        put("ghost",3); put("vessel",3); put("battlecruiser",3);
        // Zerg 건물
        put("hatchery",1); put("extractor",1); put("spawning_pool",1); put("hydralisk_den",1);
        put("lair",2); put("spire",2); put("queens_nest",2);
        put("hive",3); put("greater_spire",3); put("defiler_mound",3); put("ultralisk_cavern",3);
        // Zerg 유닛
        put("drone",1); put("zergling",1); put("hydralisk",1);
        put("lurker",2); put("mutalisk",2); put("scourge",2); put("queen",2);
        put("guardian",3); put("devourer",3); put("ultralisk",3); put("defiler",3);
        // Protoss 건물
        put("nexus",1); put("assimilator",1); put("gateway",1); put("cybernetics_core",1);
        put("citadel_of_adun",2); put("templar_archives",2);
        put("robotics_facility",2); put("robotics_support_bay",2);
        put("stargate",2);
        put("fleet_beacon",3); put("arbiter_tribunal",3);
        // Protoss 유닛
        put("probe",1); put("zealot",1); put("dragoon",1);
        put("high_templar",2); put("dark_templar",2);
        put("shuttle",2); put("reaver",2); put("corsair",2); put("scout",2);
        put("carrier",3); put("arbiter",3);
    }};

    /** 엔티티 ID의 티어 반환 (없으면 1) */
    private int getTier(String entityId) {
        return ENTITY_TIER.getOrDefault(entityId, 1);
    }

    /** 빌드의 maxTier 반환 (0이면 제한없음=3) */
    private int resolveMaxTier(BuildDTO build) {
        int t = build.getMaxTier();
        return (t >= 1 && t <= 3) ? t : 3;
    }

    private List<String> getBuildOrder(String race) {
        switch (race) { case "Z": return BUILD_ORDER_Z; case "P": return BUILD_ORDER_P; default: return BUILD_ORDER_T; }
    }

    // =====================================================
    // 메인 시뮬레이션
    // =====================================================
    @Override
    public List<GameState> runFullSimulation(
            Map<String, Integer> myStats, Map<String, Integer> aiStats,
            BuildDTO myBuild, BuildDTO aiBuild,
            String myRace, String aiRace,
            String myPlayerName, String aiPlayerName) {

        List<GameState> replay = new ArrayList<>();
        commentaryFired.clear(); // 매 경기마다 해설 초기화
        lastMyTopUnit = null; lastAiTopUnit = null;
        GameState state = new GameState();
        state.setMyPlayerName(myPlayerName != null ? myPlayerName : "아군");
        state.setAiPlayerName(aiPlayerName != null ? aiPlayerName : "AI");
        state.setInitialBuilding(myRace, aiRace);
        state.setDefense(200);  state.setAiDefense(200);
        state.setMinerals(50);  state.setAiMinerals(50);
        state.setGas(0);        state.setAiGas(0);

        // ── 스탯 공식 (기본 1~100 / 강화·합성 시 최대 150까지 허용)
        // ATTACK: stat/150*0.25 → stat150=x1.25, stat100=x1.167, stat50=x1.083, stat1≈x1.0
        double myAtkMult = 1.0 + Math.min(myStats.getOrDefault("attack", 50), 150) / 150.0 * 0.25;
        double aiAtkMult = 1.0 + Math.min(aiStats.getOrDefault("attack", 50), 150) / 150.0 * 0.25;
        double myMacro   = Math.min(myStats.getOrDefault("macro",   50), 150);
        double aiMacro   = Math.min(aiStats.getOrDefault("macro",   50), 150);
        double myMicro   = Math.min(myStats.getOrDefault("micro",   50), 150);
        double aiMicro   = Math.min(aiStats.getOrDefault("micro",   50), 150);
        double myLuck    = Math.min(myStats.getOrDefault("luck",    50), 150);
        double aiLuck    = Math.min(aiStats.getOrDefault("luck",    50), 150);
        double myDefStat = Math.min(myStats.getOrDefault("defense", 50), 150);
        double aiDefStat = Math.min(aiStats.getOrDefault("defense", 50), 150);

        // MACRO 파생
        // 채취보너스: stat100=+12%, stat50=+6%, stat1≈0% (stat150→캡 15%)
        double myMacroEco  = Math.min(0.15, myMacro / 100.0 * 0.12);
        double aiMacroEco  = Math.min(0.15, aiMacro / 100.0 * 0.12);
        // 건설 속도는 누구나 동일 — macroSpd 제거
        // 건물/유닛 생산 시작 기준 자원
        // 최솟값 300 고정, 상한값이 macro에 따라 달라짐
        // macro100: 300~400 (범위 100 — 안정적 운영)
        // macro 50: 300~550 (범위 250 — 가끔 타이트, 가끔 여유)
        // macro  1: 300~700 (범위 400 — 완전 랜덤, 운 좋으면 빠른 건설)
        int myThrRange  = (int) Math.round((1.0 - Math.min(myMacro, 150) / 150.0) * 90);
        int aiThrRange  = (int) Math.round((1.0 - Math.min(aiMacro, 150) / 150.0) * 90);
        int myExpandThr = 150 + rand.nextInt(myThrRange + 1);
        int aiExpandThr = 150 + rand.nextInt(aiThrRange + 1);
        // MICRO 파생
        // 전투효율: stat100=+10%, stat50=0%, stat1≈-10% (캡 ±10%)
        double myMicroEff  = Math.min(0.10, Math.max(-0.10, myMicro / 100.0 * 0.20 - 0.10));
        double aiMicroEff  = Math.min(0.10, Math.max(-0.10, aiMicro / 100.0 * 0.20 - 0.10));
        double myMicroHar  = myMicro;
        double aiMicroHar  = aiMicro;
        // DEFENSE 파생: stat100=12% 경감, stat50=6% (stat150→캡 15%)
        double myDefRed    = Math.min(0.15, myDefStat / 100.0 * 0.12);
        double aiDefRed    = Math.min(0.15, aiDefStat / 100.0 * 0.12);
        // LUCK 파생: stat100=40% 크리, stat50=20%, stat1≈0% (stat150→캡 50%) ← 역전 요소
        double myLuckCrit  = Math.min(0.50, myLuck / 100.0 * 0.40);
        double aiLuckCrit  = Math.min(0.50, aiLuck / 100.0 * 0.40);

        // 확장 저축 모드 상태 변수
        int myMaxBases      = getMaxBases(myBuild.getAggression());
        int aiMaxBases      = getMaxBases(aiBuild.getAggression());
        int myExpandMin     = getFirstExpandTime();
        int aiExpandMin     = getFirstExpandTime();
        int myExpandCool    = getExpandCooldown(myBuild.getAggression());
        int aiExpandCool    = getExpandCooldown(aiBuild.getAggression());
        int myLastExpand = 0;
        int aiLastExpand = 0;

        // 선호 건물 맵 (수량 + 우선순위 가중치)
        Map<String, dto.pve.BuildDTO.BuildingPref> myPrefBuildings = myBuild.getPreferredBuildingMap();
        Map<String, dto.pve.BuildDTO.BuildingPref> aiPrefBuildings = aiBuild.getPreferredBuildingMap();

        // ── 건물 건설 딜레이 맵 (macro 기반) ────────────────────────────
        Map<String, Integer> myBuildDelayUntil = new HashMap<>();
        Map<String, Integer> aiBuildDelayUntil = new HashMap<>();

        Map<String, List<String>> myUnitPlan = buildUnitPlan(myBuild);
        Map<String, List<String>> aiUnitPlan = buildUnitPlan(aiBuild);
        List<String> myPreferredIds = myBuild.getPreferredUnitIds();
        java.util.Map<String, dto.pve.BuildDTO.UnitPref> myUnitPrefMap = myBuild.getPreferredUnitMap();
        List<String> aiPreferredIds = aiBuild.getPreferredUnitIds();
        java.util.Map<String, dto.pve.BuildDTO.UnitPref> aiUnitPrefMap = aiBuild.getPreferredUnitMap();
        // 높음 그룹 타겟 추적 (틱 간 유지 — 가중치 비율로 순번 결정)
        String[] myNextTarget = {null};
        String[] aiNextTarget = {null};
        Set<Integer> myBattleSchedule = new TreeSet<>(generateSideSchedule(myBuild));
        Set<Integer> aiBattleSchedule = new TreeSet<>(generateSideSchedule(aiBuild));
        // 합쳐서 전체 전투 시간표 (중복 제거 + 최소간격 90초)
        Set<Integer> battleSchedule   = generateBattleSchedule(myBuild, aiBuild);
        Set<Integer> myHarasSchedule  = generateHarassSchedule(myBuild.getHarassStyle());
        Set<Integer> aiHarasSchedule  = generateHarassSchedule(aiBuild.getHarassStyle());

        state.clearLogs();

        // ── 경기 시작 멘트 + 능력치 비교 해설 ───────────────────────
        String MY = state.getMyPlayerName(), AI = state.getAiPlayerName();
        addLog(state, "system", MY + "과 " + AI + "의 경기를 시작합니다!");
        int myTotal = myStats.values().stream().mapToInt(Integer::intValue).sum();
        int aiTotal = aiStats.values().stream().mapToInt(Integer::intValue).sum();
        int diff    = Math.abs(myTotal - aiTotal);
        String stronger = myTotal >= aiTotal ? MY : AI;
        String weaker   = myTotal >= aiTotal ? AI : MY;
        if (diff >= 100) {
            addLog(state, "commentary", "🎙 " + weaker + " 선수가 " + stronger + " 선수를 이기는 건 쉽지 않겠습니다.");
        } else if (diff >= 50) {
            addLog(state, "commentary", "🎙 " + stronger + " 선수가 조금 유리하지만 방심할 수 없는 상황입니다.");
        } else {
            addLog(state, "commentary", "🎙 " + MY + " 선수와 " + AI + " 선수의 능력치가 비슷하기 때문에 승부를 예측할 수 없습니다.");
        }

        replay.add(deepCopy(state));

        // ── 랜덤 경제/운영 이벤트 스케줄 (각자 1~10회, 1분~30분 랜덤) ──
        Set<Integer> myEcoSchedule = generateEconomySchedule();
        Set<Integer> aiEcoSchedule = generateEconomySchedule();
        // 디버프 종료 시간 추적
        int myGasDebuffUntil    = 0;  // 가스 채집 -20% 종료 시간
        int aiGasDebuffUntil    = 0;
        int myWorkerBanUntil    = 0;  // 일꾼 생산 금지 종료 시간
        int aiWorkerBanUntil    = 0;
        // 전투 디버프 (수비측 전투력 감소) — 해당 전투 1회만 적용
        double myBattleDebuff   = 1.0;
        double aiBattleDebuff   = 1.0;

        boolean gameOver = false;
        for (int time = 1; time <= GAME_DURATION && !gameOver; time++) {
            state.setGameTime(time);
            state.clearLogs();

            processResources(state, myMacroEco, aiMacroEco,
                    time < myGasDebuffUntil, time < aiGasDebuffUntil);
            processLarva(state);
            processQueue(state, false, myAtkMult);
            processQueue(state, true,  aiAtkMult);

            // ── 방어력 성장 (초기 200 → 30분 최대 1000) ──────────────
            double defGrowth = 800.0 / GAME_DURATION;
            state.setDefense(Math.min(1000, state.getDefense() + defGrowth));
            state.setAiDefense(Math.min(1000, state.getAiDefense() + defGrowth));

            String myPhase = getCurrentPhase(time);
            String myNext  = nextPhase(myPhase);

            // ── 랜덤 경제/운영 이벤트 처리 ──────────────────────────
            if (myEcoSchedule.contains(time)) {
                int[] result = applyEconomyEvent(state, false);
                if (result[0] > 0) myGasDebuffUntil   = time + result[0];
                if (result[1] > 0) myWorkerBanUntil   = time + result[1];
            }
            if (aiEcoSchedule.contains(time)) {
                int[] result = applyEconomyEvent(state, true);
                if (result[0] > 0) aiGasDebuffUntil   = time + result[0];
                if (result[1] > 0) aiWorkerBanUntil   = time + result[1];
            }

            // ── 일꾼 생산 최우선 (자원/슬롯 확인 후 즉시 생산) ──────
            if (time >= myWorkerBanUntil) produceWorker(state, myRace, false);
            if (time >= aiWorkerBanUntil) produceWorker(state, aiRace, true);

            // ── 정제소/추출기/동화기: 기지 수에 맞게 2순위 건설 ──────
            autoGasBuilding(state, myRace, false);
            autoGasBuilding(state, aiRace, true);

            // ── 확장 시도: 조건 충족 시 매 틱 바로 시도
            // tryExpand() 내부에서 minerals >= 400 체크 → 돈 있으면 즉시 짓고, 없으면 skip
            // 확장 대기 중일 때는 유닛/건물 생산에 400미네랄 예약 (소프트 예약)
            // 첫 멀티는 쿨타임 미적용 (myLastExpand=0이면 아직 한 번도 안 지은 것)
            boolean myExpandPending = time >= myExpandMin
                    && (myLastExpand == 0 || time - myLastExpand >= myExpandCool)
                    && needsExpand(state, myRace, false, myMaxBases);
            boolean aiExpandPending = time >= aiExpandMin
                    && (aiLastExpand == 0 || time - aiLastExpand >= aiExpandCool)
                    && needsExpand(state, aiRace, true, aiMaxBases);

            if (myExpandPending) {
                if (tryExpand(state, myRace, false, myMaxBases)) {
                    myLastExpand = time;
                    myExpandPending = false;
                }
            }
            if (aiExpandPending) {
                if (tryExpand(state, aiRace, true, aiMaxBases)) {
                    aiLastExpand = time;
                    aiExpandPending = false;
                }
            }

            // 테크/생산건물 건설 + 유닛 생산
            // ── 확장 예약 + 유닛 생산비 동적 예약 ──
            // 확장 대기 중이면 400미네랄 예약 (소프트 예약)
            int myExpandReserve = myExpandPending ? 400 : 0;
            int aiExpandReserve = aiExpandPending ? 400 : 0;
            // 유닛 생산 1회치 비용을 계산해 건물 건설 시 남겨둠 (병력 우선 보장)
            int myTechReserve = calcTechReserve(myUnitPlan.get(myPhase), myRace, state, false, myBuild.getPlayStyle());
            int aiTechReserve = calcTechReserve(aiUnitPlan.get(myPhase), aiRace, state, true,  aiBuild.getPlayStyle());
            int myReserve = myExpandReserve + myTechReserve;
            int aiReserve = aiExpandReserve + aiTechReserve;
            // 유닛 생산 먼저 — 병력 생산을 건물 건설보다 우선 (techReserve는 유닛 생산엔 적용 안 함)
            produceUnits(state, myRace, myUnitPlan.get(myPhase), false, resolveMaxTier(myBuild), myExpandReserve, myPreferredIds, myUnitPrefMap, myNextTarget);
            // 남은 자원으로 건물 건설 (유닛 생산비 예약분 제외)
            autoTech(state, myRace, false, resolveMaxTier(myBuild), myReserve, myMacro, myBuildDelayUntil, myPrefBuildings);
            autoExpandProduction(state, myRace, myUnitPlan.get(myPhase), false, myExpandThr, myReserve, myPrefBuildings);

            produceUnits(state, aiRace, aiUnitPlan.get(myPhase), true, resolveMaxTier(aiBuild), aiExpandReserve, aiPreferredIds, aiUnitPrefMap, aiNextTarget);
            autoTech(state, aiRace, true, resolveMaxTier(aiBuild), aiReserve, aiMacro, aiBuildDelayUntil, aiPrefBuildings);
            autoExpandProduction(state, aiRace, aiUnitPlan.get(myPhase), true, aiExpandThr, aiReserve, aiPrefBuildings);

            // [Fix2] 큐 선반영 제거 — 유닛은 생산 완료 시점에만 전투력에 반영됨

            // 견제 처리 (전투 스케줄과 독립)
            if (myHarasSchedule.contains(time))
                executeHarassment(state, true,  myMicroHar, aiMicroHar);
            if (aiHarasSchedule.contains(time))
                executeHarassment(state, false, myMicroHar, aiMicroHar);

            if (battleSchedule.contains(time)) {
                executeBattleEvent(state, myBuild, aiBuild, time,
                        myMicroEff, aiMicroEff, myLuckCrit, aiLuckCrit,
                        myDefRed, aiDefRed,
                        myUnitPlan.get(myPhase), aiUnitPlan.get(myPhase),
                        myBattleSchedule, aiBattleSchedule,
                        myBattleDebuff, aiBattleDebuff);
                myBattleDebuff = 1.0;
                aiBattleDebuff = 1.0;
            }

            // ── 해설 주입 ─────────────────────────────────────────
            injectCommentary(state, time, myBuild, aiBuild, myRace, aiRace, myMacro, aiMacro);

            if (state.getDefense() <= 0 || state.getAiDefense() <= 0) gameOver = true;
            if (time == GAME_DURATION) {
                // 30분 종료 — 점수 낮은 쪽 방어력/전투력 0으로 강제
                double myScore = state.getDefense() * 0.5 + state.getCombatPower() * 0.5;
                double aiScore = state.getAiDefense() * 0.5 + state.getAiCombatPower() * 0.5;
                if (myScore < aiScore) {
                    state.setDefense(0); state.setCombatPower(0);
                } else if (aiScore < myScore) {
                    state.setAiDefense(0); state.setAiCombatPower(0);
                }
                gameOver = true;
                logGameOver(state, myTotal, aiTotal, true);
            } else if (gameOver) {
                logGameOver(state, myTotal, aiTotal, false);
            }
            replay.add(deepCopy(state));
        }
        return replay;
    }

    private boolean isPreparingForNextPhase(int time) {
        int la = 120;
        return (time >= EARLY_END - la && time < EARLY_END) || (time >= MID_END - la && time < MID_END);
    }

    // =====================================================
    // 랜덤 경제/운영 이벤트
    // =====================================================
    /** 경기당 1~10회, 1분~30분 내 랜덤 타이밍 생성 */
    private Set<Integer> generateEconomySchedule() {
        int count = 1 + rand.nextInt(10);
        Set<Integer> schedule = new TreeSet<>();
        while (schedule.size() < count) {
            schedule.add(60 + rand.nextInt(GAME_DURATION - 60));
        }
        return schedule;
    }

    /**
     * 경제/운영 이벤트 발동
     * @return int[2] — [0]: gasDebuffDuration(초), [1]: workerBanDuration(초)  (0이면 없음)
     */
    private int[] applyEconomyEvent(GameState state, boolean isAi) {
        double roll = rand.nextDouble();
        String name = isAi ? state.getAiPlayerName() : state.getMyPlayerName();
        String logType = isAi ? "ai_action" : "user_action";

        if (roll < 0.15) {
            // 병력 흘림 — 보유 전투력 5% 즉시 손실
            double power = isAi ? state.getAiCombatPower() : state.getCombatPower();
            double loss  = power * 0.05;
            removeUnitsForAttrition(state, loss, isAi);
            if (isAi) state.setAiCombatPower(Math.max(0, power - loss));
            else      state.setCombatPower(Math.max(0, power - loss));
            addLog(state, logType, "⚡ " + name + " 선수, 병력 일부를 흘렸습니다! 전투력 5% 손실.");
            return new int[]{0, 0};

        } else if (roll < 0.25) {
            // 가스 관리 실패 — 60초간 가스 채집 -20%
            addLog(state, logType, "⚡ " + name + " 선수, 가스 일꾼을 제대로 붙이지 않고 있습니다. 60초간 가스 채집량 -20%.");
            return new int[]{60, 0};

        } else if (roll < 0.32) {
            // 일꾼 생산 멈춤 — 60초간 일꾼 생산 금지
            addLog(state, logType, "⚡ " + name + " 선수, 일꾼 생산이 멈췄습니다! 60초간 일꾼 생산 불가.");
            return new int[]{0, 60};
        }

        // 나머지 68% — 아무 일 없음
        return new int[]{0, 0};
    }

    /**
     * 수비측 전투 디버프 주사위
     * @return 전투력 배율 (1.0 = 효과 없음)
     */
    private double rollBattleDefenderDebuff() {
        double roll = rand.nextDouble();
        if (roll < 0.02) return 0.65;  // 2%: 불리한 진형3 -35%
        if (roll < 0.06) return 0.70;  // 4%: 불리한 진형2 -30%
        if (roll < 0.12) return 0.75;  // 6%: 불리한 진형  -25%
        if (roll < 0.20) return 0.80;  // 8%: 기습당함3    -20%
        if (roll < 0.30) return 0.85;  // 10%: 기습당함2   -15%
        if (roll < 0.45) return 0.90;  // 15%: 기습당함    -10%
        return 1.0;                    // 55%: 아무 일 없음
    }

    // =====================================================
    // 전투 이벤트
    // =====================================================
    private void executeBattleEvent(GameState state, BuildDTO myBuild, BuildDTO aiBuild,
                                    int time, double myMicroEff, double aiMicroEff,
                                    double myLuckCrit, double aiLuckCrit,
                                    double myDefRed, double aiDefRed,
                                    List<String> myUnits, List<String> aiUnits,
                                    Set<Integer> myBattleSchedule, Set<Integer> aiBattleSchedule,
                                    double myBattleDebuff, double aiBattleDebuff) {
        String myStyle = myBuild.getPlayStyle() != null ? myBuild.getPlayStyle() : "MID_TIMING";
        String aiStyle = aiBuild.getPlayStyle() != null ? aiBuild.getPlayStyle() : "MID_TIMING";
        boolean myPassive = "LATE_OPS".equals(myStyle) && time < MID_END;
        boolean aiPassive = "LATE_OPS".equals(aiStyle) && time < MID_END;
        if ("TURTLE".equals(myBuild.getAggression()) && time < MID_END) myPassive = true;
        if ("TURTLE".equals(aiBuild.getAggression()) && time < MID_END) aiPassive = true;

        double myPower = state.getCombatPower();
        double aiPower = state.getAiCombatPower();

        boolean myCanFight = myPower > 0 && !myPassive;
        boolean aiCanFight = aiPower > 0 && !aiPassive;
        boolean myForced   = aiPower > 0 && myPower <= 0;
        boolean aiForced   = myPower > 0 && aiPower <= 0;

        if (!myCanFight && !aiCanFight && !myForced && !aiForced) return;

        boolean myIsInitiator = myBattleSchedule.stream().anyMatch(t -> Math.abs(t - time) <= 90);
        boolean aiIsInitiator = aiBattleSchedule.stream().anyMatch(t -> Math.abs(t - time) <= 90);

        // ── 수비측 전투 이벤트 (공격자 제외, 수비자만 발동) ─────────
        // 아군이 수비 = AI가 공격자이고 아군은 아닌 경우
        boolean myIsDefender = aiIsInitiator && !myIsInitiator;
        boolean aiIsDefender = myIsInitiator && !aiIsInitiator;
        // 양측 교전이면 양쪽 모두 수비 이벤트 적용
        if (myIsInitiator && aiIsInitiator) { myIsDefender = true; aiIsDefender = true; }

        double myFinalPower = myPower * myBattleDebuff;
        double aiFinalPower = aiPower * aiBattleDebuff;

        if (myIsDefender) {
            double debuff = rollBattleDefenderDebuff();
            if (debuff < 1.0) {
                myFinalPower *= debuff;
                String[] msgs = {
                    "⚠ " + state.getMyPlayerName() + " 선수 수비 진형이 흔들립니다! 전투력 감소!",
                    "⚠ " + state.getMyPlayerName() + " 선수 기습에 당했습니다! 병력이 대응이 늦어집니다!",
                    "⚠ " + state.getMyPlayerName() + " 선수 진형이 불리합니다! 전투에서 손해를 봅니다!"
                };
                addLog(state, "system", pick(msgs));
            }
        }
        if (aiIsDefender) {
            double debuff = rollBattleDefenderDebuff();
            if (debuff < 1.0) {
                aiFinalPower *= debuff;
                String[] msgs = {
                    "⚠ " + state.getAiPlayerName() + " 선수 수비 진형이 흔들립니다! 전투력 감소!",
                    "⚠ " + state.getAiPlayerName() + " 선수 기습에 당했습니다! 병력이 대응이 늦어집니다!",
                    "⚠ " + state.getAiPlayerName() + " 선수 진형이 불리합니다! 전투에서 손해를 봅니다!"
                };
                addLog(state, "system", pick(msgs));
            }
        }

        // 임시로 state 전투력 교체 후 전투 실행, 복원
        double origMy = state.getCombatPower(), origAi = state.getAiCombatPower();
        state.setCombatPower(myFinalPower);
        state.setAiCombatPower(aiFinalPower);
        executeBattle(state, myMicroEff, aiMicroEff, myLuckCrit, aiLuckCrit, myDefRed, aiDefRed, myUnits, aiUnits);
        // 전투 후 실제 손실분 반영 (디버프 적용된 값 기준으로 이미 처리됨)
    }

    // =====================================================
    // 유닛 플랜 — maxTier 기반 단일 리스트 (3티어 → 2티어 → 1티어 우선순위)
    // =====================================================
    /** maxTier 이하의 모든 유닛 ID 목록 반환 — 높은 티어부터 정렬 */
    private List<String> getUnitsByMaxTier(String race, int maxTier) {
        Map<String, List<String>> RACE_UNITS = new HashMap<>();
        // 일꾼(scv/drone/probe)은 produceWorker()에서 커맨드센터당 8마리 상한으로 전담 생산하므로 여기서 제외
        // 각 종족 리스트는 이미 1→2→3 티어 순으로 기술되어 있으므로 reverse()로 3→2→1 우선순위 적용
        RACE_UNITS.put("T", Arrays.asList("marine","firebat","medic",
                "vulture","tank","goliath","wraith","dropship",
                "ghost","vessel","battlecruiser"));
        RACE_UNITS.put("Z", Arrays.asList(
                "zergling","hydralisk","lurker",
                "mutalisk","scourge","queen",
                "guardian","devourer","ultralisk","defiler"));
        RACE_UNITS.put("P", Arrays.asList("zealot","dragoon","dark_templar",
                "high_templar","dark_templar","shuttle","reaver",
                "corsair","scout","carrier","arbiter"));
        List<String> all = RACE_UNITS.getOrDefault(race, new ArrayList<>());
        // 티어 내림차순 정렬: 3티어 먼저 시도 → 테크 없으면 skip → 2티어 → 1티어
        return all.stream()
                .filter(id -> getTier(id) <= maxTier)
                .sorted(Comparator.comparingInt(this::getTier).reversed())
                .collect(Collectors.toList());
    }

    private Map<String, List<String>> buildUnitPlan(BuildDTO build) {
        int maxTier = resolveMaxTier(build);
        String race = build.getRace() == null ? "T" : build.getRace();
        List<String> allowed = getUnitsByMaxTier(race, maxTier);
        // 모든 페이즈에 동일 리스트 사용 (페이즈 구분 제거)
        Map<String, List<String>> plan = new HashMap<>();
        plan.put("EARLY", new ArrayList<>(allowed));
        plan.put("MID",   new ArrayList<>(allowed));
        plan.put("LATE",  new ArrayList<>(allowed));
        return plan;
    }

    private List<String> combineUnitLists(List<String> current, List<String> upcoming) {
        List<String> result = new ArrayList<>();
        if (current  != null) result.addAll(current);
        if (upcoming != null) for (String u : upcoming) if (!result.contains(u)) result.add(u);
        return result;
    }

    // =====================================================
    // 자원 채취 (미네랄 + 가스)
    // =====================================================
    private void processResources(GameState state, double myMacroEco, double aiMacroEco,
                                   boolean myGasDebuff, boolean aiGasDebuff) {
        int myBases = countBases(state.getBuildingCounts());
        int aiBases = countBases(state.getAiBuildingCounts());
        int myEffW  = Math.min(state.getWorkerCount(),   myBases * 6);
        int aiEffW  = Math.min(state.getAiWorkerCount(), aiBases * 6);
        double myMps = myEffW * 0.75 * (1.0 + myMacroEco);
        double aiMps = aiEffW * 0.75 * (1.0 + aiMacroEco);
        state.setMineralsPerSecond(myMps);  state.setAiMineralsPerSecond(aiMps);
        state.setMinerals(state.getMinerals()   + myMps);
        state.setAiMinerals(state.getAiMinerals() + aiMps);

        int myRef  = countRefineries(state.getBuildingCounts());
        int aiRef  = countRefineries(state.getAiBuildingCounts());
        double myGps = myRef  * 0.6 * (1.0 + myMacroEco) * (myGasDebuff ? 0.80 : 1.0);
        double aiGps = aiRef  * 0.6 * (1.0 + aiMacroEco) * (aiGasDebuff ? 0.80 : 1.0);
        state.setGasPerSecond(myGps);  state.setAiGasPerSecond(aiGps);
        state.setGas(state.getGas()   + myGps);
        state.setAiGas(state.getAiGas() + aiGps);
    }

    private int countBases(Map<String, Integer> b) {
        return b.getOrDefault("커맨드센터", 0) + b.getOrDefault("해처리", 0) + b.getOrDefault("넥서스", 0);
    }

    private int countRefineries(Map<String, Integer> b) {
        return b.getOrDefault("정제소", 0) + b.getOrDefault("추출기", 0) + b.getOrDefault("동화기", 0);
    }

    // ── 저그 라바 ────────────────────────────────────────────
    private void processLarva(GameState state) {
        int hatch = state.getBuildingCounts().getOrDefault("해처리", 0);
        if (hatch > 0) {
            int timer = state.getLarvaTimer() + 1, count = state.getLarvaCount();
            if (count < hatch * 3 && timer >= 14) { count++; timer = 0; }
            state.setLarvaTimer(timer); state.setLarvaCount(count);
        }
        int aiHatch = state.getAiBuildingCounts().getOrDefault("해처리", 0);
        if (aiHatch > 0) {
            int timer = state.getAiLarvaTimer() + 1, count = state.getAiLarvaCount();
            if (count < aiHatch * 3 && timer >= 14) { count++; timer = 0; }
            state.setAiLarvaTimer(timer); state.setAiLarvaCount(count);
        }
    }

    // ── 생산 큐 완료 처리 ─────────────────────────────────────
    private void processQueue(GameState state, boolean isAi, double atkMult) {
        List<ProductionItem> queue = isAi ? state.getAiProductionQueue() : state.getProductionQueue();
        List<ProductionItem> done  = new ArrayList<>();
        for (ProductionItem item : queue) if (state.getGameTime() >= item.getEndTime()) { done.add(item); finishItem(state, item, isAi, atkMult); }
        queue.removeAll(done);
    }

    private void finishItem(GameState state, ProductionItem item, boolean isAi, double atkMult) {
        EntityData entity = ENTITY_DB.get(item.getEntityId());
        if (entity == null) return;
        Map<String, Integer> buildings = isAi ? state.getAiBuildingCounts() : state.getBuildingCounts();
        // [Fix5] 저글링: 라바 1개 = 2마리 생산 (SC1 룰)
        int unitCount = "zergling".equals(entity.id) ? 2 : 1;
        buildings.merge(entity.name, unitCount, Integer::sum);
        if ("unit".equals(entity.type)) {
            String workerId = getWorkerIdByRace(getRaceFromBuildings(buildings));
            if (entity.id.equals(workerId)) {
                if (isAi) state.setAiWorkerCount(state.getAiWorkerCount() + 1);
                else      state.setWorkerCount(state.getWorkerCount() + 1);
            } else {
                double power = entity.combatPower * atkMult * unitCount;
                if (isAi) state.setAiCombatPower(state.getAiCombatPower() + power);
                else      state.setCombatPower(state.getCombatPower() + power);
            }
        }
        // 완성 로그 없음 — 건설/생산 시작 시에만 로그 출력
    }

    // ── 일꾼 생산 ─────────────────────────────────────────────
    private void produceWorker(GameState state, String race, boolean isAi) {
        int workers = isAi ? state.getAiWorkerCount() : state.getWorkerCount();
        Map<String, Integer> blds = isAi ? state.getAiBuildingCounts() : state.getBuildingCounts();
        // 커맨드센터(넥서스/해처리) 1개당 일꾼 8마리 상한
        String baseBldId = getBaseIdByRace(race);
        EntityData baseBld = ENTITY_DB.get(baseBldId);
        int prodBldCount = baseBld != null ? blds.getOrDefault(baseBld.name, 0) : 0;
        int cap = prodBldCount * 8;
        String workerId = getWorkerIdByRace(race);
        List<ProductionItem> queue = isAi ? state.getAiProductionQueue() : state.getProductionQueue();
        long inQueue = queue.stream().filter(q -> q.getEntityId().equals(workerId)).count();
        if (cap <= 0 || workers + inQueue >= cap) return;  // 커맨드센터 1개당 SCV 8마리 상한
        EntityData entity = ENTITY_DB.get(workerId);
        if (entity == null || !isTechAvailable(state, entity, isAi)) return;
        if (!canAfford(state, entity, isAi) || !hasProductionSlot(state, entity, isAi)) return;
        spend(state, entity, isAi);
        enqueue(state, entity, isAi, -1);
    }

    // =====================================================
    // 가스 건물 자동 건설 (기지 수에 맞게 항상 유지)
    // 기지 1개당 정제소/추출기/동화기 1개 상한
    // =====================================================
    private void autoGasBuilding(GameState state, String race,
                                  boolean isAi) {
        int bases = countBases(isAi ? state.getAiBuildingCounts() : state.getBuildingCounts());
        if (bases <= 0) return;

        String gasBldId = getGasBuildingByRace(race);
        EntityData gasBld = ENTITY_DB.get(gasBldId);
        if (gasBld == null) return;

        Map<String, Integer> blds  = isAi ? state.getAiBuildingCounts() : state.getBuildingCounts();
        List<ProductionItem> queue = isAi ? state.getAiProductionQueue() : state.getProductionQueue();

        int built    = blds.getOrDefault(gasBld.name, 0);
        long inQueue = queue.stream().filter(q -> q.getEntityId().equals(gasBldId)).count();
        int total    = built + (int) inQueue;

        if (total >= bases) return;  // 기지 수만큼 이미 있으면 건설 불필요
        if (!isTechAvailable(state, gasBld, isAi)) return;
        if (!canAfford(state, gasBld, isAi)) return;

        spend(state, gasBld, isAi);
        enqueue(state, gasBld, isAi, -1);
    }

    private String getGasBuildingByRace(String race) {
        switch (race) { case "Z": return "extractor"; case "P": return "assimilator"; default: return "refinery"; }
    }

    // ── 테크 트리 자동 건설 ───────────────────────────────────
    // =====================================================
    // 동적 테크 예약금 계산
    // 건물 건설 전에 유닛 생산비 N회치를 미네랄에서 예약해 병력 생산을 우선 보장
    //
    // 기준 배수 (플레이스타일별):
    //   AGGRESSIVE : 2.0회치 — 병력 최우선, 건물은 여유자원으로만
    //   NORMAL     : 1.5회치 — 균형
    //   DEFENSIVE  : 1.0회치 — 건물 건설에 더 유연하게 허용
    //
    // "1회치 비용" = 현재 테크에서 생산 가능한 유닛 중 가장 저렴한 것의 mineralCost
    // (기본 50 보장 — 유닛 풀이 없을 때도 최소한의 예약 유지)
    // =====================================================
    private int calcTechReserve(List<String> unitPool, String race,
                                 GameState state, boolean isAi, String playStyle) {
        // 플레이스타일별 배수
        double mult;
        switch (playStyle == null ? "NORMAL" : playStyle) {
            case "AGGRESSIVE": mult = 2.0; break;
            case "DEFENSIVE":  mult = 1.0; break;
            default:           mult = 1.5; break; // NORMAL + 구버전 호환
        }

        // 현재 테크에서 생산 가능한 유닛 중 최저 미네랄 비용
        int minCost = 50; // 기본 보장값 (마린/드론/프로브 등 티어1 유닛 기준)
        if (unitPool != null) {
            for (String uid : unitPool) {
                EntityData e = ENTITY_DB.get(uid);
                if (e == null || !"unit".equals(e.type)) continue;
                if (!isTechAvailable(state, e, isAi)) continue;
                if (e.mineralCost > 0 && e.mineralCost < minCost) minCost = e.mineralCost;
            }
        }

        return (int) Math.round(minCost * mult);
    }

    private void autoTech(GameState state, String race,
                          boolean isAi, int maxTier, int reserve,
                          double macro, Map<String, Integer> buildDelayUntil,
                          Map<String, dto.pve.BuildDTO.BuildingPref> prefBuildings) {
        List<String> buildOrder   = getBuildOrder(race);
        Map<String, Integer> blds = isAi ? state.getAiBuildingCounts() : state.getBuildingCounts();
        List<ProductionItem> queue = isAi ? state.getAiProductionQueue() : state.getProductionQueue();
        int curTime = state.getGameTime();

        if (prefBuildings.isEmpty()) {
            // ── 선호건물 없음: 빌드오더 순서대로 1개씩 ──
            for (String bid : buildOrder) {
                EntityData b = ENTITY_DB.get(bid);
                if (b == null || !"building".equals(b.type)) continue;
                if (getTier(bid) > maxTier) continue;
                if (!isTechAvailable(state, b, isAi)) continue;
                if (blds.getOrDefault(b.name, 0) > 0) continue;
                if (queue.stream().anyMatch(q -> q.getEntityId().equals(bid))) continue;
                if (!canAfford(state, b, isAi, reserve)) continue;
                String dk = bid + "_0";
                if (!buildDelayUntil.containsKey(dk)) {
                    int md = (int) Math.round((1.0 - Math.min(macro, 150) / 150.0) * 9);
                    buildDelayUntil.put(dk, curTime + (md > 0 ? rand.nextInt(md + 1) : 0));
                }
                if (curTime < buildDelayUntil.get(dk)) break;
                spend(state, b, isAi); enqueue(state, b, isAi, -1);
                addLog(state, isAi ? "ai_action" : "user_action",
                    (isAi ? state.getAiPlayerName() : state.getMyPlayerName()) + " 선수가 " + b.name + "을(를) 건설합니다.");
                break;
            }
            return;
        }

        // ── 선호건물 있음: 목표 미달 건물들 중 가중치 랜덤 선택 ──
        List<String>  candidates = new ArrayList<>();
        List<Integer> weights    = new ArrayList<>();
        for (Map.Entry<String, dto.pve.BuildDTO.BuildingPref> entry : prefBuildings.entrySet()) {
            String bid = entry.getKey();
            dto.pve.BuildDTO.BuildingPref pref = entry.getValue();
            if (pref.count <= 0) continue;
            EntityData b = ENTITY_DB.get(bid);
            if (b == null || !"building".equals(b.type)) continue;
            if (getTier(bid) > maxTier) continue;
            if (!isTechAvailable(state, b, isAi)) continue;
            int total = blds.getOrDefault(b.name, 0)
                      + (int) queue.stream().filter(q -> q.getEntityId().equals(bid)).count();
            if (total >= pref.count) continue;
            if (!canAfford(state, b, isAi, reserve)) continue;
            candidates.add(bid);
            weights.add(pref.weight);
        }
        // 목표 수량 미달 건물이 없으면 → 아직 테크/자원 부족으로 대기 중이거나 모두 달성
        // 어느 쪽이든 autoTech는 여기서 종료 (추가 건설은 autoExpandProduction이 담당)
        if (candidates.isEmpty()) return;

        String picked = weightedRandom(candidates, weights);
        EntityData b  = ENTITY_DB.get(picked);
        if (b == null) return;
        int total = blds.getOrDefault(b.name, 0)
                  + (int) queue.stream().filter(q -> q.getEntityId().equals(picked)).count();
        String dk = picked + "_" + total;
        if (!buildDelayUntil.containsKey(dk)) {
            int md = (int) Math.round((1.0 - Math.min(macro, 150) / 150.0) * 9);
            buildDelayUntil.put(dk, curTime + (md > 0 ? rand.nextInt(md + 1) : 0));
        }
        if (curTime < buildDelayUntil.get(dk)) return;
        spend(state, b, isAi); enqueue(state, b, isAi, -1);
        addLog(state, isAi ? "ai_action" : "user_action",
            (isAi ? state.getAiPlayerName() : state.getMyPlayerName()) + " 선수가 " + b.name + "을(를) 건설합니다.");
    }

    private void autoExpandProduction(GameState state, String race, List<String> targetUnits,
                                      boolean isAi, int expandThreshold, int reserve,
                                      Map<String, dto.pve.BuildDTO.BuildingPref> prefBuildings) {
        if ("Z".equals(race) || targetUnits == null || targetUnits.isEmpty()) return;
        Map<String, Integer> blds  = isAi ? state.getAiBuildingCounts() : state.getBuildingCounts();
        List<ProductionItem> queue = isAi ? state.getAiProductionQueue() : state.getProductionQueue();
        double minerals = isAi ? state.getAiMinerals() : state.getMinerals();
        if (minerals < expandThreshold) return;

        // prefBuildings 있으면 → 그 목록에 있는 생산건물만 후보
        // prefBuildings 없으면 → targetUnits의 생산건물 전체
        List<String> orderedBuildingIds = new LinkedList<>();
        if (!prefBuildings.isEmpty()) {
            for (String bid : prefBuildings.keySet()) {
                EntityData pb = ENTITY_DB.get(bid);
                if (pb == null || !"building".equals(pb.type)) continue;
                // 이 건물이 실제로 유닛을 생산하는 건물인지 확인 (targetUnits 중 하나라도 이 건물을 사용하면 OK)
                boolean isProdBld = targetUnits.stream().anyMatch(uid -> {
                    EntityData u = ENTITY_DB.get(uid);
                    return u != null && bid.equals(u.productionBuilding);
                });
                if (isProdBld && !orderedBuildingIds.contains(bid)) orderedBuildingIds.add(bid);
            }
        } else {
            for (String unitId : targetUnits) {
                EntityData unit = ENTITY_DB.get(unitId);
                if (unit == null || unit.productionBuilding == null) continue;
                EntityData prodB = ENTITY_DB.get(unit.productionBuilding);
                if (prodB == null || !"building".equals(prodB.type)) continue;
                if (!orderedBuildingIds.contains(unit.productionBuilding)) orderedBuildingIds.add(unit.productionBuilding);
            }
        }
        if (orderedBuildingIds.isEmpty()) return;

        if (!prefBuildings.isEmpty()) {
            // 선호건물 가중치 랜덤 추가 건설 — prefBuildings 수량이 상한
            List<String> cands = new ArrayList<>(); List<Integer> ws = new ArrayList<>();
            for (String bid : orderedBuildingIds) {
                if (!prefBuildings.containsKey(bid)) continue;
                EntityData pb = ENTITY_DB.get(bid);
                if (pb == null || blds.getOrDefault(pb.name, 0) == 0) continue;
                if (!isTechAvailable(state, pb, isAi) || !canAfford(state, pb, isAi, reserve)) continue;
                // count=0인 건물은 추가 건설 불가
                // 목표 수량(count)을 이미 달성한 건물도 추가 확장 안 함
                // (목표 달성 후 랜덤 건설은 autoTech fallback이 담당)
                dto.pve.BuildDTO.BuildingPref pref = prefBuildings.get(bid);
                if (pref == null || pref.count <= 0) continue;
                int curTotal = blds.getOrDefault(pb.name, 0)
                        + (int) queue.stream().filter(q -> q.getEntityId().equals(bid)).count();
                if (curTotal >= pref.count) continue;
                long inProg = queue.stream().filter(q -> q.getEntityId().equals(bid)).count();
                long slots  = blds.getOrDefault(pb.name, 0) + inProg;
                long unitsQ = queue.stream().filter(q -> { EntityData qe = ENTITY_DB.get(q.getEntityId()); return qe != null && bid.equals(qe.productionBuilding); }).count();
                if (unitsQ >= slots) { cands.add(bid); ws.add(pref != null ? pref.weight : 3); }
            }
            if (cands.isEmpty()) return;
            EntityData pb = ENTITY_DB.get(weightedRandom(cands, ws));
            if (pb != null && canAfford(state, pb, isAi, reserve)) { spend(state, pb, isAi); enqueue(state, pb, isAi, -1); }
        } else {
            for (String bid : orderedBuildingIds) {
                EntityData pb = ENTITY_DB.get(bid);
                if (pb == null || blds.getOrDefault(pb.name, 0) == 0) continue;
                if (!isTechAvailable(state, pb, isAi)) continue;
                while (true) {
                    double m = isAi ? state.getAiMinerals() : state.getMinerals();
                    if (m < expandThreshold || !canAfford(state, pb, isAi, reserve)) break;
                    long inProg = queue.stream().filter(q -> q.getEntityId().equals(bid)).count();
                    long slots  = blds.getOrDefault(pb.name, 0) + inProg;
                    long unitsQ = queue.stream().filter(q -> { EntityData qe = ENTITY_DB.get(q.getEntityId()); return qe != null && bid.equals(qe.productionBuilding); }).count();
                    if (unitsQ < slots) break;
                    spend(state, pb, isAi); enqueue(state, pb, isAi, -1);
                }
            }
        }
    }

    private void collectRequiredBuildings(String entityId, Set<String> result) {
        EntityData e = ENTITY_DB.get(entityId);
        if (e == null) return;
        if (e.productionBuilding != null && !result.contains(e.productionBuilding)) {
            collectRequiredBuildings(e.productionBuilding, result);
            result.add(e.productionBuilding);
        }
        if (e.techBuilding != null && !result.contains(e.techBuilding)) {
            collectRequiredBuildings(e.techBuilding, result);
            result.add(e.techBuilding);
        }
    }

    // ── 전투 유닛 생산 (타겟팅 + 가중치 비율 라운드로빈) ────────────────
    // 선호 유닛 있으면:
    //   1. 높음 그룹에서 타겟 유닛을 가중치 비율로 순번 지정
    //   2. 타겟 살 수 있으면 → 생산 후 다음 타겟으로 교체
    //   3. 타겟 가스 부족 → 가스 0 유닛만 미네랄 여유분으로 허용
    //   4. 타겟 미네랄 부족 + 가스 충족 → 대기
    //   5. 둘 다 부족 → 하위 우선순위로
    // 선호 유닛 없으면: 기존 가중치 랜덤 방식
    private void produceUnits(GameState state, String race, List<String> unitPool,
                               boolean isAi, int maxTier, int reserve,
                               List<String> preferredUnitIds,
                               java.util.Map<String, dto.pve.BuildDTO.UnitPref> unitPrefMap,
                               String[] nextTargetRef) {
        if (unitPool == null) return;

        List<String> targetPool = (!preferredUnitIds.isEmpty())
            ? unitPool.stream().filter(preferredUnitIds::contains).collect(Collectors.toList())
            : unitPool;

        List<String> candidates = new ArrayList<>();
        List<Integer> weights   = new ArrayList<>();
        for (String uid : targetPool) {
            EntityData e = ENTITY_DB.get(uid);
            if (e == null || !isTechAvailable(state, e, isAi)) continue;
            candidates.add(uid);
            dto.pve.BuildDTO.UnitPref pref = unitPrefMap.get(uid);
            int w = pref != null ? pref.weight
                  : (preferredUnitIds.contains(uid) ? 5 : getTier(uid));
            weights.add(w);
        }
        if (candidates.isEmpty()) return;

        int freeSlots = calcFreeProductionSlots(state, race, candidates, isAi);
        if (freeSlots <= 0) return;

        // 선호 유닛 없으면 기존 단순 방식
        if (preferredUnitIds.isEmpty()) {
            for (int i = 0; i < freeSlots; i++) {
                List<String>  affordable = new ArrayList<>();
                List<Integer> afWeights  = new ArrayList<>();
                for (int j = 0; j < candidates.size(); j++) {
                    EntityData e = ENTITY_DB.get(candidates.get(j));
                    if (canAfford(state, e, isAi, reserve) && hasProductionSlot(state, e, isAi)) {
                        affordable.add(candidates.get(j));
                        afWeights.add(weights.get(j));
                    }
                }
                if (affordable.isEmpty()) break;
                String picked = weightedRandom(affordable, afWeights);
                EntityData entity = ENTITY_DB.get(picked);
                spend(state, entity, isAi);
                enqueue(state, entity, isAi, -1);
            }
            return;
        }

        // 높음 그룹 구성
        int topWeight = weights.stream().max(Integer::compareTo).orElse(0);
        List<String>  topGroup   = new ArrayList<>();
        List<Integer> topWeights = new ArrayList<>();
        for (int j = 0; j < candidates.size(); j++) {
            if (weights.get(j) == topWeight) {
                topGroup.add(candidates.get(j));
                topWeights.add(weights.get(j));
            }
        }

        // 타겟 초기화
        if (nextTargetRef[0] == null || !candidates.contains(nextTargetRef[0])) {
            nextTargetRef[0] = weightedRandom(topGroup, topWeights);
        }

        for (int i = 0; i < freeSlots; i++) {
            String target = nextTargetRef[0];
            EntityData te = ENTITY_DB.get(target);
            if (te == null || !isTechAvailable(state, te, isAi)) {
                produceFromLowerGroups(state, candidates, weights, topWeight, isAi, reserve);
                continue;
            }

            double minerals = isAi ? state.getAiMinerals() : state.getMinerals();
            double gas      = isAi ? state.getAiGas()      : state.getGas();
            boolean minOk = minerals - te.mineralCost >= reserve;
            boolean gasOk = gas >= te.gasCost;

            if (minOk && gasOk && hasProductionSlot(state, te, isAi)) {
                spend(state, te, isAi);
                enqueue(state, te, isAi, -1);
                nextTargetRef[0] = weightedRandom(topGroup, topWeights);

            } else if (!gasOk && te.gasCost > 0) {
                // 가스 부족 → 가스 0 유닛만 타겟 미네랄 건드리지 않는 선에서 허용
                for (int j = 0; j < candidates.size(); j++) {
                    EntityData e = ENTITY_DB.get(candidates.get(j));
                    if (e == null || e.gasCost > 0 || !hasProductionSlot(state, e, isAi)) continue;
                    double m2 = isAi ? state.getAiMinerals() : state.getMinerals();
                    if (m2 - e.mineralCost >= Math.max(reserve, te.mineralCost)) {
                        spend(state, e, isAi);
                        enqueue(state, e, isAi, -1);
                        break;
                    }
                }
                break;

            } else if (!minOk && gasOk) {
                // 미네랄 부족 + 가스 충족 → 대기
                break;

            } else {
                // 둘 다 부족 → 하위 그룹
                boolean produced = produceFromLowerGroups(state, candidates, weights, topWeight, isAi, reserve);
                if (!produced) break;
            }
        }

        // 자원 적체(400+) 시 filler
        double minerals = isAi ? state.getAiMinerals() : state.getMinerals();
        if (minerals >= 400 + reserve) {
            List<String> fillers = !preferredUnitIds.isEmpty()
                ? preferredUnitIds.stream().filter(uid -> !candidates.contains(uid)).collect(Collectors.toList())
                : getFillerUnits(race, maxTier);
            Collections.shuffle(fillers, rand);
            for (String uid : fillers) {
                if (candidates.contains(uid)) continue;
                EntityData entity = ENTITY_DB.get(uid);
                if (entity == null || !isTechAvailable(state, entity, isAi)) continue;
                final String fpbId = entity.productionBuilding;
                Map<String, Integer> blds = isAi ? state.getAiBuildingCounts() : state.getBuildingCounts();
                List<ProductionItem> queue = isAi ? state.getAiProductionQueue() : state.getProductionQueue();
                int built = fpbId != null && ENTITY_DB.containsKey(fpbId)
                        ? blds.getOrDefault(ENTITY_DB.get(fpbId).name, 0) : 1;
                long occ = fpbId != null ? queue.stream().filter(q -> {
                    EntityData qe = ENTITY_DB.get(q.getEntityId());
                    return qe != null && fpbId.equals(qe.productionBuilding);
                }).count() : 0;
                int fs2 = (int) Math.max(0, built - occ);
                for (int k = 0; k < fs2; k++) {
                    if (!canAfford(state, entity, isAi, reserve) || !hasProductionSlot(state, entity, isAi)) break;
                    spend(state, entity, isAi);
                    enqueue(state, entity, isAi, -1);
                }
            }
        }
    }

    /** 하위 우선순위 그룹에서 생산 가능한 유닛 1개 생산. 성공 시 true 반환 */
    private boolean produceFromLowerGroups(GameState state, List<String> candidates,
                                           List<Integer> weights, int topWeight,
                                           boolean isAi, int reserve) {
        List<Integer> lowerWeights = weights.stream()
                .filter(w -> w < topWeight).distinct()
                .sorted(Comparator.reverseOrder())
                .collect(Collectors.toList());
        for (int lw : lowerWeights) {
            List<String>  pool  = new ArrayList<>();
            List<Integer> poolW = new ArrayList<>();
            for (int j = 0; j < candidates.size(); j++) {
                if (!weights.get(j).equals(lw)) continue;
                EntityData e = ENTITY_DB.get(candidates.get(j));
                if (e == null || !hasProductionSlot(state, e, isAi)) continue;
                if (canAfford(state, e, isAi, reserve)) { pool.add(candidates.get(j)); poolW.add(lw); }
            }
            if (!pool.isEmpty()) {
                EntityData entity = ENTITY_DB.get(weightedRandom(pool, poolW));
                spend(state, entity, isAi);
                enqueue(state, entity, isAi, -1);
                return true;
            }
        }
        return false;
    }

        /** 가용 유닛들의 총 빈 생산 슬롯 계산 (저그: 라바 수, 비저그: 생산건물 빈슬롯 합산) */
    private int calcFreeProductionSlots(GameState state, String race,
                                         List<String> candidates, boolean isAi) {
        if ("Z".equals(race)) {
            return isAi ? state.getAiLarvaCount() : state.getLarvaCount();
        }
        Map<String, Integer> blds = isAi ? state.getAiBuildingCounts() : state.getBuildingCounts();
        List<ProductionItem> queue = isAi ? state.getAiProductionQueue() : state.getProductionQueue();
        Set<String> pbIds = candidates.stream()
                .map(ENTITY_DB::get).filter(e -> e != null && e.productionBuilding != null)
                .map(e -> e.productionBuilding)
                .collect(Collectors.toCollection(LinkedHashSet::new));
        int total = 0;
        for (String pbId : pbIds) {
            EntityData pb = ENTITY_DB.get(pbId);
            if (pb == null) continue;
            int built = blds.getOrDefault(pb.name, 0);
            if (built == 0) continue;
            long occ = queue.stream().filter(q -> {
                EntityData qe = ENTITY_DB.get(q.getEntityId());
                return qe != null && pbId.equals(qe.productionBuilding);
            }).count();
            total += Math.max(0, built - (int) occ);
        }
        return total;
    }

    /** 가중치 비례 랜덤 선택 */
    private String weightedRandom(List<String> ids, List<Integer> weights) {
        int total = weights.stream().mapToInt(Integer::intValue).sum();
        if (total <= 0) return ids.get(rand.nextInt(ids.size()));
        int r = rand.nextInt(total);
        int cum = 0;
        for (int i = 0; i < ids.size(); i++) {
            cum += weights.get(i);
            if (r < cum) return ids.get(i);
        }
        return ids.get(ids.size() - 1);
    }

    // ── 종족별 filler 유닛 (자원 남을 때 생산, maxTier 제한 적용) ──
    private List<String> getFillerUnits(String race, int maxTier) {
        Map<String, List<String>> all = new HashMap<>();
        all.put("T", Arrays.asList("marine","firebat","vulture","tank","goliath","wraith","ghost","battlecruiser"));
        all.put("Z", Arrays.asList(
                "zergling","hydralisk",
                "lurker","mutalisk","scourge","queen",
                "guardian","devourer","ultralisk","defiler"));
        all.put("P", Arrays.asList(
                "zealot","dragoon",
                "high_templar","dark_templar","shuttle","reaver",
                "corsair","scout","carrier","arbiter"));
        List<String> candidates = all.getOrDefault(race, new ArrayList<>());
        return candidates.stream().filter(id -> getTier(id) <= maxTier).collect(Collectors.toList());
    }

    // ── 멀티 확장 ─────────────────────────────────────────────
    /** 확장이 필요한 상태인지 판단 (기지 비용 모이기 전부터 저축 시작) */
    private boolean needsExpand(GameState state, String race, boolean isAi, int maxBases) {
        Map<String, Integer> blds  = isAi ? state.getAiBuildingCounts() : state.getBuildingCounts();
        List<ProductionItem> queue = isAi ? state.getAiProductionQueue() : state.getProductionQueue();
        String baseId = getBaseIdByRace(race);
        int completed = countBases(blds);
        long inQueue  = queue.stream().filter(q -> q.getEntityId().equals(baseId)).count();
        return (completed + (int) inQueue) < maxBases;
    }

    private boolean tryExpand(GameState state, String race, boolean isAi, int maxBases) {
        Map<String, Integer> blds  = isAi ? state.getAiBuildingCounts() : state.getBuildingCounts();
        List<ProductionItem> queue = isAi ? state.getAiProductionQueue() : state.getProductionQueue();
        String baseId   = getBaseIdByRace(race);
        EntityData base = ENTITY_DB.get(baseId);
        if (base == null) return false;

        // 완료 + 큐 대기 기지 합산
        int completed = countBases(blds);
        long inQueue  = queue.stream().filter(q -> q.getEntityId().equals(baseId)).count();
        if (completed + (int) inQueue >= maxBases) return false;

        // 기지 비용만 있으면 확장 (버퍼 없음 — 저축 모드에서 이미 모아둔 상태)
        double minerals = isAi ? state.getAiMinerals() : state.getMinerals();
        if (minerals < base.mineralCost) return false;

        spend(state, base, isAi);
        enqueue(state, base, isAi, -1);
        String _exName = isAi ? state.getAiPlayerName() : state.getMyPlayerName();
        int _totalBases = completed + (int) inQueue + 1; // 건설 후 총 기지 수
        int _multiNum   = _totalBases - 1;               // 본진 제외 멀티 번호
        String _multiLabel;
        switch (_multiNum) {
            case 1:  _multiLabel = "앞마당 멀티"; break;
            case 2:  _multiLabel = "트리플 멀티"; break;
            case 3:  _multiLabel = "세 번째 멀티"; break;
            case 4:  _multiLabel = "네 번째 멀티"; break;
            case 5:  _multiLabel = "다섯 번째 멀티"; break;
            default: _multiLabel = _multiNum + " 번째 멀티"; break;
        }
        addLog(state, isAi ? "ai_action" : "user_action",
            _exName + " 선수가 " + _multiLabel + "를 시도합니다. " + base.name + "을(를) 짓습니다.");
        return true;
    }

    // =====================================================
    // 전투 계산
    // [개선1] 랜덤 범위 0.95~1.05 (±5%) 으로 축소
    // [개선2] Luck → 크리티컬 확률로 분리 (luck 50 = 10% 크리, luck 100 = 20%)
    // [개선3] 전투 로그에 유닛 손실 묘사 추가 (역산 표시)
    // [개선4] 유닛 상성 배율 적용 (±15%)
    // =====================================================
    private void executeBattle(GameState state,
                               double myMicroEff, double aiMicroEff,
                               double myLuckCrit, double aiLuckCrit,
                               double myDefRed,   double aiDefRed,
                               List<String> myUnits, List<String> aiUnits) {
        // 파라미터가 이미 티어 테이블에서 계산된 값:
        // myDefRed: 0.0~0.40 (피해 경감률)
        // myMicroEff: -0.10~+0.10 (전투 효율 보정)
        // myLuckCrit: 0.01~0.30 (크리티컬 확률)
        double myDmgReduction = myDefRed;
        double aiDmgReduction = aiDefRed;
        double myPower = state.getCombatPower();
        double aiPower = state.getAiCombatPower();

        if (myPower <= 0 && aiPower <= 0) {

            return;
        }

        // ── 상성 배율 계산 (0.85 ~ 1.15) ──────────────────────
        double myMatchupMult = calcMatchupMult(state.getBuildingCounts(),   state.getAiBuildingCounts());
        double aiMatchupMult = calcMatchupMult(state.getAiBuildingCounts(), state.getBuildingCounts());
        if (Math.abs(myMatchupMult - aiMatchupMult) >= 0.05) {
            if (myMatchupMult > aiMatchupMult) {
                addLog(state, "battle", "⚔️ 유닛 조합 상성상 " + state.getMyPlayerName() + " 선수가 유리한 싸움입니다.");
            } else {
                addLog(state, "battle", "⚔️ 유닛 조합 상성상 " + state.getAiPlayerName() + " 선수가 유리한 싸움입니다.");
            }
        }

        // LUCK → 크리티컬 판정 (myLuckCrit = 티어 테이블 값, 0.01~0.30)
        boolean myCrit = rand.nextDouble() < myLuckCrit;
        boolean aiCrit = rand.nextDouble() < aiLuckCrit;

        // MICRO → 전투 효율 (±10%), 랜덤 변동 (±5%), 상성 배율 적용
        double myEff = myPower
                * myMatchupMult
                * (1.0 + myMicroEff)
                * (0.90 + rand.nextDouble() * 0.20)
                * (myCrit ? 1.60 : 1.0);
        double aiEff = aiPower
                * aiMatchupMult
                * (1.0 + aiMicroEff)
                * (0.90 + rand.nextDouble() * 0.20)
                * (aiCrit ? 1.60 : 1.0);

        // [Fix6] 비대칭 소모전: 승리측 35%, 패배측 65% 손실
        // 전투 규모에 비례한 소모율 (소규모 25% ~ 대규모 60%)
        double combatScale = Math.min(myPower, aiPower);
        double attritionRate = 0.25 + Math.min(0.35, combatScale / 500.0 * 0.35);
        // (myEff, aiEff 이미 계산된 상태에서 winner 판정)
        double totalAttrition = combatScale * attritionRate * 2;
        double myAttrition, aiAttrition;
        if (aiPower <= 0) {
            // 아군 일방 공격: 아군 손실 없음
            myAttrition = 0;
            aiAttrition = 0;
        } else if (myPower <= 0) {
            // AI 일방 공격: AI 손실 없음
            myAttrition = 0;
            aiAttrition = 0;
        } else if (myEff > aiEff) {
            // 아군 승리: 아군 35%, AI 65% 손실
            myAttrition = totalAttrition * 0.35;
            aiAttrition = totalAttrition * 0.65;
        } else if (aiEff > myEff) {
            // AI 승리: 아군 65%, AI 35% 손실
            myAttrition = totalAttrition * 0.65;
            aiAttrition = totalAttrition * 0.35;
        } else {
            // 동률: 균등 손실
            myAttrition = combatScale * attritionRate;
            aiAttrition = combatScale * attritionRate;
        }

        // 소모전 먼저 실행 → 실제 제거된 유닛 목록을 로그에 활용
        Map<String, Integer> myRemoved = removeUnitsForAttrition(state, myAttrition, false);
        Map<String, Integer> aiRemoved = removeUnitsForAttrition(state, aiAttrition, true);
        state.setCombatPower(Math.max(0, myPower - myAttrition));
        state.setAiCombatPower(Math.max(0, aiPower - aiAttrition));

        if (myEff > aiEff || aiPower <= 0) {
            double rawDmg = aiPower <= 0
                    ? myEff * 0.8
                    : (myEff - aiEff) * 0.5;
            double finalDmg = rawDmg * (1.0 - aiDmgReduction);
            state.setAiDefense(Math.max(0, state.getAiDefense() - finalDmg));
            addLog(state, "user_action", describeBattleWin(state, true, myCrit, state.getBuildingCounts(), state.getAiBuildingCounts()));
            // 대규모 패배 시 AI 생산건물 파괴
            int destroyCount = rawDmg > 150 ? 2 : rawDmg > 60 ? 1 : 0;
            for (int i = 0; i < destroyCount; i++)
                destroyProductionBuilding(state, true);
        } else if (aiEff > myEff || myPower <= 0) {
            double rawDmg = myPower <= 0
                    ? aiEff * 0.8
                    : (aiEff - myEff) * 0.5;
            double finalDmg = rawDmg * (1.0 - myDmgReduction);
            state.setDefense(Math.max(0, state.getDefense() - finalDmg));
            addLog(state, "ai_action", describeBattleWin(state, false, aiCrit, state.getBuildingCounts(), state.getAiBuildingCounts()));
            // 대규모 패배 시 아군 생산건물 파괴
            int destroyCount = rawDmg > 150 ? 2 : rawDmg > 60 ? 1 : 0;
            for (int i = 0; i < destroyCount; i++)
                destroyProductionBuilding(state, false);
        } else {
            addLog(state, "system", describeBattleDraw(state, state.getBuildingCounts(), state.getAiBuildingCounts()));
        }
    }

    // =====================================================
    // 생산건물 파괴 (전투 대패 시 호출)
    // 기지·가스건물 제외한 생산건물 중 랜덤 1개 수량 -1
    // 해당 건물에서 생산 중인 큐도 함께 취소
    // =====================================================
    private static final Set<String> PRODUCTION_BUILDINGS = new HashSet<>(Arrays.asList(
        "barracks","factory","starport",                          // 테란
        "spawning_pool","hydralisk_den",                            // 저그 티어1
        "lair","spire","queens_nest",                              // 저그 티어2
        "hive","greater_spire","defiler_mound","ultralisk_cavern", // 저그 티어3
        "gateway","cybernetics_core","citadel_of_adun","templar_archives",  // 프로토스
        "robotics_facility","robotics_support_bay","stargate","fleet_beacon","arbiter_tribunal"
    ));

    private void destroyProductionBuilding(GameState state, boolean isAi) {
        Map<String, Integer> blds  = isAi ? state.getAiBuildingCounts() : state.getBuildingCounts();
        List<ProductionItem> queue = isAi ? state.getAiProductionQueue() : state.getProductionQueue();

        // 현재 보유 중인 파괴 가능 건물 목록 수집
        List<Map.Entry<String, EntityData>> targets = new ArrayList<>();
        for (Map.Entry<String, EntityData> entry : ENTITY_DB.entrySet()) {
            EntityData e = entry.getValue();
            if (!PRODUCTION_BUILDINGS.contains(entry.getKey())) continue;
            if (blds.getOrDefault(e.name, 0) <= 0) continue;
            targets.add(entry);
        }
        if (targets.isEmpty()) return;

        // 랜덤으로 1개 선택
        Map.Entry<String, EntityData> target = targets.get(rand.nextInt(targets.size()));
        String bldId   = target.getKey();
        EntityData bld = target.getValue();

        // 건물 수량 -1
        int current = blds.getOrDefault(bld.name, 0);
        if (current <= 1) blds.remove(bld.name);
        else              blds.put(bld.name, current - 1);

        // 해당 건물에서 생산 중인 큐 1개 취소 (자원 미반환 — 전투 손실)
        queue.stream()
             .filter(q -> { EntityData qe = ENTITY_DB.get(q.getEntityId()); return qe != null && bldId.equals(qe.productionBuilding); })
             .findFirst()
             .ifPresent(queue::remove);

        String name     = isAi ? state.getAiPlayerName() : state.getMyPlayerName();
        String attacker = isAi ? state.getMyPlayerName() : state.getAiPlayerName();
        String[] logs = {
            "💥 " + name + " 선수의 " + bld.name + "을(를) 파괴합니다! " + name + " 선수 많이 위험합니다.",
            "💥 " + name + " 선수의 " + bld.name + "이(가) " + attacker + " 선수의 공격에 파괴되었습니다."
        };
        addLog(state, isAi ? "ai_action" : "user_action", pick(logs));
    }

    // =====================================================
    // 실제 유닛 제거 (buildingCounts 반영)
    // 약한 유닛(전투력 낮은 순)부터 lostPower 소진될 때까지 비례 제거
    // 반환값: 실제로 제거된 유닛명 → 수량 맵 (로그 생성에 사용)
    // =====================================================
    private Map<String, Integer> removeUnitsForAttrition(GameState state, double lostPower, boolean isAi) {
        Map<String, Integer> removed = new LinkedHashMap<>();
        if (lostPower <= 0) return removed;
        Map<String, Integer> counts = isAi ? state.getAiBuildingCounts() : state.getBuildingCounts();

        // 보유 중인 전투 유닛 목록을 전투력 오름차순으로 정렬 (약한 유닛부터 소모)
        List<EntityData> ownedUnits = ENTITY_DB.values().stream()
                .filter(e -> "unit".equals(e.type) && e.combatPower > 0)
                .filter(e -> counts.getOrDefault(e.name, 0) > 0)
                .sorted(Comparator.comparingDouble(e -> e.combatPower))
                .collect(Collectors.toList());

        double remaining = lostPower;
        for (EntityData e : ownedUnits) {
            if (remaining <= 0) break;
            int owned = counts.getOrDefault(e.name, 0);
            if (owned <= 0) continue;
            int toRemove = (int) Math.ceil(remaining / e.combatPower);
            toRemove = Math.min(toRemove, owned);
            int newCount = owned - toRemove;
            if (newCount <= 0) counts.remove(e.name);
            else               counts.put(e.name, newCount);
            remaining -= toRemove * e.combatPower;
            removed.put(e.name, toRemove);
        }
        return removed;
    }

    // =====================================================
    // 유닛 손실 묘사 - removeUnitsForAttrition 의 실제 제거 결과를 그대로 텍스트화
    // =====================================================
    private String describeLoss(Map<String, Integer> removed) {
        if (removed == null || removed.isEmpty()) return "소규모 피해";
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, Integer> entry : removed.entrySet()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(entry.getKey()).append(" ").append(entry.getValue()).append("기");
        }
        sb.append(" 손실");
        return sb.toString();
    }

    // ── 판정 로직 ─────────────────────────────────────────────
    // =====================================================
    // 견제 처리
    // 성공/실패 모두 전투력 소모 발생
    // 성공 시: 상대 일꾼 2~3마리 제거 → 경제 타격이 비용 대비 항상 이상
    // 성공률: 기본 50% ± (공격자 Micro - 방어자 Micro) * 0.5%
    // =====================================================
    // ── 견제 특화 유닛 보너스 계산 ──────────────────────────────────────────
    // 테란: 벌처, 드랍쉽 / 프로토스: 리버, 셔틀(드랍쉽 대체) / 저그: 저글링, 뮤탈리스크
    // 수량 구간별 추가 일꾼 피해:
    //   1~3기  → +1
    //   4~7기  → +2
    //   8기 이상 → +3
    private int calcHarassBonus(Map<String, Integer> counts) {
        int specialCount = counts.getOrDefault("벌처", 0)
                         + counts.getOrDefault("드랍쉽", 0)
                         + counts.getOrDefault("셔틀", 0)
                         + counts.getOrDefault("리버", 0)
                         + counts.getOrDefault("저글링", 0)
                         + counts.getOrDefault("뮤탈리스크", 0)
                         + counts.getOrDefault("스컬지", 0);
        if (specialCount >= 8) return 3;
        if (specialCount >= 4) return 2;
        if (specialCount >= 1) return 1;
        return 0;
    }

    private void executeHarassment(GameState state, boolean isMy,
                                   double myHarRate, double aiHarRate) {
        double atkPower = isMy ? state.getCombatPower() : state.getAiCombatPower();
        Map<String, Integer> atkCounts = isMy ? state.getBuildingCounts() : state.getAiBuildingCounts();

        if (atkPower <= 0) {
            String _atkN = isMy ? state.getMyPlayerName() : state.getAiPlayerName();
            String _harUnit = getHarassUnit(atkCounts);
            String[] _noUnit = {
                _harUnit + "으로 견제를 노렸지만 " + _atkN + " 선수 병력 부족으로 무산됐습니다.",
                _harUnit + " 준비는 됐지만 병력이 없어 " + _atkN + " 선수의 견제가 취소됐습니다. 아쉽네요!",
                _atkN + " 선수 " + _harUnit + " 견제 의도가 있었지만 병력이 부족합니다!"
            };
            addLog(state, isMy ? "user_action" : "ai_action", pick(_noUnit));
            return;
        }

        double cost = Math.max(5, Math.min(30, atkPower * 0.08));

        // MICRO: 견제 성공률 50% 기준, micro 차이 1당 0.5% 보정 (±25% 범위)
        double atkMicro = isMy ? myHarRate : aiHarRate;
        double defMicro = isMy ? aiHarRate : myHarRate;
        double successRate = 0.50 + (atkMicro - defMicro) * 0.005;
        successRate = Math.max(0.20, Math.min(0.80, successRate));

        boolean success = rand.nextDouble() < successRate;

        // 공격측 전투력 소모 (성공/실패 무관)
        if (isMy) state.setCombatPower(Math.max(0, atkPower - cost));
        else      state.setAiCombatPower(Math.max(0, atkPower - cost));

        String _atkN = isMy ? state.getMyPlayerName() : state.getAiPlayerName();
        String _defN = isMy ? state.getAiPlayerName() : state.getMyPlayerName();

        if (success) {
            // 기본 피해 2~3마리 + 견제 특화 유닛 보너스
            int bonus = calcHarassBonus(atkCounts);
            int workerLoss = 2 + rand.nextInt(2) + bonus;
            String bonusDesc = bonus > 0 ? " (특화유닛 +" + bonus + ")" : "";

            if (isMy) {
                int current = state.getAiWorkerCount();
                workerLoss = Math.min(workerLoss, Math.max(0, current - 1));
                state.setAiWorkerCount(Math.max(1, current - workerLoss));
                String aiWorkerName = getWorkerNameByRace(getRaceFromBuildings(state.getAiBuildingCounts()));
                state.getAiBuildingCounts().merge(aiWorkerName, -workerLoss, Integer::sum);
                int _wl = workerLoss;
                String _myHarUnit = getHarassUnit(atkCounts);
                String[] _sl = {
                    "🐝 " + _atkN + " 선수 " + _myHarUnit + " 견제 성공! " + _defN + " 선수 일꾼 " + _wl + "마리를 잡아냈습니다!" + bonusDesc,
                    "🐝 " + _myHarUnit + " 견제 적중! " + _atkN + " 선수가 " + _defN + " 선수의 일꾼 " + _wl + "기를 잡아냅니다!" + bonusDesc,
                    "🐝 " + _atkN + " 선수 " + _myHarUnit + " 날카롭게 들어갑니다! " + _defN + " 선수 일꾼 " + _wl + "마리 손실. 경제 타격이에요!" + bonusDesc
                };
                addLog(state, "user_action", pick(_sl));
            } else {
                int current = state.getWorkerCount();
                workerLoss = Math.min(workerLoss, Math.max(0, current - 1));
                state.setWorkerCount(Math.max(1, current - workerLoss));
                String myWorkerName = getWorkerNameByRace(getRaceFromBuildings(state.getBuildingCounts()));
                state.getBuildingCounts().merge(myWorkerName, -workerLoss, Integer::sum);
                int _wl = workerLoss;
                String _aiHarUnit = getHarassUnit(atkCounts);
                String[] _sl = {
                    "🐝 " + _atkN + " 선수 " + _aiHarUnit + " 견제 성공! " + _defN + " 선수 일꾼 " + _wl + "마리 피해!" + bonusDesc,
                    "🐝 " + _aiHarUnit + " 들어온다! " + _defN + " 선수 일꾼 " + _wl + "기 손실. 경제에 타격이 갑니다!" + bonusDesc,
                    "🐝 " + _atkN + " 선수 " + _aiHarUnit + " 견제가 적중했습니다! " + _defN + " 선수 일꾼 " + _wl + "마리가 잡혔어요!" + bonusDesc
                };
                addLog(state, "ai_action", pick(_sl));
            }
        } else {
            String _harFailUnit = getHarassUnit(atkCounts);
            String _defUnit     = getDefenceUnit(isMy ? state.getAiBuildingCounts() : state.getBuildingCounts());
            String[] _fl = {
                "🐝 " + _atkN + " 선수 " + _harFailUnit + " 견제 시도, 하지만 " + _defN + " 선수 " + _defUnit + "에 막혀 무산됩니다!",
                "🐝 " + _defN + " 선수 " + _defUnit + " 방어 성공! " + _atkN + " 선수의 " + _harFailUnit + " 견제가 돌아갑니다.",
                "🐝 " + _atkN + " 선수 " + _harFailUnit + " 견제, 이번엔 실패했습니다. 약간의 병력을 손해 봤습니다."
            };
            addLog(state, isMy ? "user_action" : "ai_action", pick(_fl));
        }
    }

    private void logGameOver(GameState state, int myStatTotal, int aiStatTotal, boolean isTimeout) {
        double myHP = state.getDefense(), aiHP = state.getAiDefense();
        String MY = state.getMyPlayerName(), AI = state.getAiPlayerName();

        if (myHP <= 0 && aiHP <= 0) { addLog(state, "system", "🤝 동귀어진! 무승부"); return; }

        String winner, loser;
        if (myHP <= 0) { winner = AI; loser = MY; }
        else           { winner = MY; loser = AI; }

        boolean winnerIsMyPlayer = winner.equals(MY);
        int winnerStat = winnerIsMyPlayer ? myStatTotal : aiStatTotal;
        int loserStat  = winnerIsMyPlayer ? aiStatTotal : myStatTotal;
        int statDiff   = loserStat - winnerStat; // 양수 = 승자가 약자

        // 패배자, 승리자 GG
        addLog(state, winnerIsMyPlayer ? "ai_action" : "user_action", loser  + " : GG!!!");
        addLog(state, winnerIsMyPlayer ? "user_action" : "ai_action", winner + " : GG!!!");

        // 종료 해설
        if (isTimeout) {
            if (statDiff >= 100) {
                addLog(state, "system", "🏆 " + winner + " 선수가 장기전 끝에 승리를 가져갑니다. " + winner + " 선수가 엄청난 이변을 만들어 냅니다!");
            } else if (statDiff >= 50) {
                addLog(state, "system", "🏆 " + winner + " 선수가 장기전 끝에 승리를 가져갑니다. " + winner + " 선수가 약간 고전할 것이라 예측했는데 뚝심 있는 운영으로 결국 해냈습니다!");
            } else {
                addLog(state, "system", "🏆 " + winner + " 선수가 장기전 끝에 승리를 가져갑니다.");
            }
        } else {
            addLog(state, winnerIsMyPlayer ? "user_action" : "ai_action",
                "🏆 " + winner + " 선수 승리! " + loser + " 선수 본진을 격파했습니다!");
        }
    }

    // ── AI 기본 빌드 ──────────────────────────────────────────
    @Override
    public BuildDTO generateDefaultBuild(String race, String vsRace) {
        BuildDTO build = new BuildDTO();
        build.setBuildId(0); build.setBuildName("AI 기본 빌드");
        build.setRace(race); build.setVsRace(vsRace);
        build.setPlayStyle("AGGRESSIVE");
        build.setHarassStyle("NORMAL_HARASS");
        build.setAggression("MID_MULTI");
        build.setMaxTier(3);
        build.setPreferredBuildings("");
        return build;
    }

    // ── 헬퍼 ─────────────────────────────────────────────────
    // ── 유닛 상성 배율 계산 ────────────────────────────────────
    // 내 군대 구성과 상대 군대 구성을 비교해 유/불리 비율을 산출
    // 반환값: 0.85 ~ 1.15 (상성 완전 유리 시 +15%, 완전 불리 시 -15%)
    private double calcMatchupMult(Map<String, Integer> myBlds, Map<String, Integer> opBlds) {
        double favorable   = 0;
        double unfavorable = 0;
        double total       = 0;

        for (Map.Entry<String, EntityData> entry : ENTITY_DB.entrySet()) {
            EntityData e = entry.getValue();
            if (!"unit".equals(e.type) || e.combatPower <= 0) continue;
            int myCount = myBlds.getOrDefault(e.name, 0);
            if (myCount == 0) continue;
            total += myCount;

            // 유리한 상대(good)가 상대 군대에 있으면 favorable 가산
            boolean hasFav = false;
            for (String gId : COUNTER_GOOD.getOrDefault(e.id, Collections.emptyList())) {
                EntityData ge = ENTITY_DB.get(gId);
                if (ge != null && opBlds.getOrDefault(ge.name, 0) > 0) { hasFav = true; break; }
            }
            if (hasFav) favorable += myCount;

            // 불리한 상대(bad)가 상대 군대에 있으면 unfavorable 가산
            boolean hasUnfav = false;
            for (String bId : COUNTER_BAD.getOrDefault(e.id, Collections.emptyList())) {
                EntityData be = ENTITY_DB.get(bId);
                if (be != null && opBlds.getOrDefault(be.name, 0) > 0) { hasUnfav = true; break; }
            }
            if (hasUnfav) unfavorable += myCount;
        }

        if (total == 0) return 1.0;
        double score = (favorable - unfavorable) / total; // -1.0 ~ +1.0
        return Math.max(0.85, Math.min(1.15, 1.0 + score * 0.15));
    }

    private boolean isTechAvailable(GameState state, EntityData entity, boolean isAi) {
        Map<String, Integer> blds = isAi ? state.getAiBuildingCounts() : state.getBuildingCounts();
        if (entity.productionBuilding != null) {
            EntityData prod = ENTITY_DB.get(entity.productionBuilding);
            if (prod != null && blds.getOrDefault(prod.name, 0) == 0) return false;
        }
        if (entity.techBuilding != null) {
            EntityData tech = ENTITY_DB.get(entity.techBuilding);
            if (tech != null && blds.getOrDefault(tech.name, 0) == 0) return false;
        }
        return true;
    }

    /** 미네랄 + 가스 동시 충족 확인 */
    private boolean canAfford(GameState state, EntityData entity, boolean isAi) {
        return canAfford(state, entity, isAi, 0);
    }

    /** 미네랄 + 가스 동시 충족 확인 (reserve: 확장 예약금 — 이 금액은 남겨둠) */
    private boolean canAfford(GameState state, EntityData entity, boolean isAi, int reserve) {
        double minerals = isAi ? state.getAiMinerals() : state.getMinerals();
        double gas      = isAi ? state.getAiGas()      : state.getGas();
        return minerals - entity.mineralCost >= reserve && gas >= entity.gasCost;
    }

    /** 미네랄 + 가스 동시 차감 */
    private void spend(GameState state, EntityData entity, boolean isAi) {
        if (isAi) {
            state.setAiMinerals(state.getAiMinerals() - entity.mineralCost);
            state.setAiGas(state.getAiGas() - entity.gasCost);
        } else {
            state.setMinerals(state.getMinerals() - entity.mineralCost);
            state.setGas(state.getGas() - entity.gasCost);
        }
        if ("Z".equals(entity.race) && "unit".equals(entity.type) && !entity.id.equals("drone")) {
            if (isAi) state.setAiLarvaCount(state.getAiLarvaCount() - 1);
            else      state.setLarvaCount(state.getLarvaCount() - 1);
        }
    }

    private boolean hasProductionSlot(GameState state, EntityData entity, boolean isAi) {
        if ("Z".equals(entity.race) && "unit".equals(entity.type) && !entity.id.equals("drone")) {
            return (isAi ? state.getAiLarvaCount() : state.getLarvaCount()) > 0;
        }
        if (entity.productionBuilding != null) {
            EntityData prodB = ENTITY_DB.get(entity.productionBuilding);
            if (prodB != null && "building".equals(prodB.type)) {
                int cnt = (isAi ? state.getAiBuildingCounts() : state.getBuildingCounts())
                        .getOrDefault(prodB.name, 0);
                // ★ 핵심 수정: 같은 생산건물을 쓰는 모든 유닛의 생산 중 수를 합산
                //   (자기 유닛 ID만 세면 배럭스 1개에서 마린+메딕+파이어뱃 동시 생산 버그 발생)
                final String prodBuildingId = entity.productionBuilding;
                long occupiedSlots = (isAi ? state.getAiProductionQueue() : state.getProductionQueue())
                        .stream().filter(q -> {
                            EntityData qe = ENTITY_DB.get(q.getEntityId());
                            return qe != null && prodBuildingId.equals(qe.productionBuilding);
                        }).count();
                return occupiedSlots < cnt;
            }
        }
        return true;
    }

    private void enqueue(GameState state, EntityData entity, boolean isAi, int scriptStep) {
        // 건설/생산 시간은 고정 — macro 스탯 영향 없음
        int time = Math.max(1, entity.buildTime);
        ProductionItem item = new ProductionItem();
        item.setEntityId(entity.id); item.setName(entity.name); item.setType(entity.type);
        item.setEndTime(state.getGameTime() + time);
        item.setScriptStep(scriptStep); item.setQueueStatus(0);
        if (isAi) state.getAiProductionQueue().add(item);
        else      state.getProductionQueue().add(item);
    }

    private String getWorkerIdByRace(String race) {
        switch (race) { case "Z": return "drone"; case "P": return "probe"; default: return "scv"; }
    }

    // 일꾼 표시 이름 (buildingCounts key)
    private String getWorkerNameByRace(String race) {
        switch (race) { case "Z": return "드론"; case "P": return "프로브"; default: return "SCV"; }
    }

    private String getRaceFromBuildings(Map<String, Integer> b) {
        if (b.containsKey("해처리")) return "Z";
        if (b.containsKey("넥서스")) return "P";
        return "T";
    }

    private String getBaseIdByRace(String race) {
        switch (race) { case "Z": return "hatchery"; case "P": return "nexus"; default: return "command_center"; }
    }

    private String playStyleLabel(String s) {
        if (s == null) return "공격스타일";
        switch (s) {
            case "AGGRESSIVE":   return "공격스타일";
            case "NORMAL":       return "일반스타일";
            case "DEFENSIVE":    return "수비스타일";
            // 구버전 호환
            case "HARASS_FOCUS": return "일반스타일";
            case "EARLY_ALLIN": return "초반올인"; case "MID_TIMING": return "중반타이밍";
            case "LATE_OPS": return "후반운영"; case "EARLY": return "초반주도"; case "LATE": return "후반한방";
            default: return "균형";
        }
    }

    private String expandLabel(String s) {
        if (s == null) return "일반멀티";
        switch (s) {
            case "FAST_MULTI":   return "패스트멀티";
            case "NORMAL_MULTI": return "일반멀티";
            case "LATE_MULTI":   return "늦은멀티";
            // 구버전 호환
            case "ONE_BASE": return "원베이스"; case "EARLY": return "빠른멀티";
            case "BALANCED": return "정석멀티"; case "GREEDY": return "욕심멀티";
            default: return "일반멀티";
        }
    }

    private String harassLabel(String s) {
        if (s == null) return "중간멀티";
        switch (s) {
            case "MIN_MULTI": return "최소멀티";
            case "MID_MULTI": return "중간멀티";
            case "MAX_MULTI": return "최대멀티";
            // 구버전 호환
            case "NONE": return "견제없음"; case "LIGHT_HARAS": return "조금견제"; case "HEAVY_HARAS": return "자주견제";
            default: return "중간멀티";
        }
    }

    private String harassStyleLabel(String s) {
        if (s == null) return "일반견제";
        switch (s) {
            case "NO_HARASS":     return "견제없음";
            case "NORMAL_HARASS": return "일반견제";
            case "HEAVY_HARASS":  return "강한견제";
            // 구버전 호환
            case "LIGHT_HARAS": return "일반견제"; case "HEAVY_HARAS": return "강한견제";
            default: return "일반견제";
        }
    }

    private String techLabel(String s) {
        if (s == null) return "중간테크";
        switch (s) {
            case "FAST_TECH": return "빠른테크";
            case "MID_TECH":  return "중간테크";
            case "LATE_TECH": return "느린테크";
            default: return "중간테크";
        }
    }

    // =====================================================
    // 해설 엔진 — 핵심 이벤트만 출력
    // =====================================================
    private final Set<String> commentaryFired = new HashSet<>();
    // 마지막으로 해설한 주력 유닛 추적 (중복 방지)
    private String lastMyTopUnit = null;
    private String lastAiTopUnit = null;

    private void injectCommentary(GameState state, int time, BuildDTO myBuild, BuildDTO aiBuild,
                                   String myRace, String aiRace, double myMacro, double aiMacro) {
        String MY = state.getMyPlayerName();
        String AI = state.getAiPlayerName();
        Map<String, Integer> myBlds = state.getBuildingCounts();
        Map<String, Integer> aiBlds = state.getAiBuildingCounts();
        int myBases = countBases(myBlds);
        int aiBases = countBases(aiBlds);

        // ── 주력 유닛 해설 (4분마다, 변경됐을 때만) ──────────────────────
        if (time % 240 == 0 && time >= 240) {
            String myTop = getTopUnit(myBlds);
            String aiTop = getTopUnit(aiBlds);
            if (myTop != null && !myTop.equals(lastMyTopUnit)) {
                addLog(state, "user_action", MY + " 선수, " + myTop + " 위주로 생산 중입니다.");
                lastMyTopUnit = myTop;
            }
            if (aiTop != null && !aiTop.equals(lastAiTopUnit)) {
                addLog(state, "ai_action",   AI + " 선수, " + aiTop + " 위주로 생산 중입니다.");
                lastAiTopUnit = aiTop;
            }
        }
    }

    // 보유 유닛 중 가장 많은 전투 유닛 이름 반환 (일꾼 제외, 없으면 null)
    private String getTopUnit(Map<String, Integer> counts) {
        if (counts == null) return null;
        return ENTITY_DB.values().stream()
                .filter(e -> "unit".equals(e.type) && e.combatPower > 0)
                .filter(e -> counts.getOrDefault(e.name, 0) >= 3) // 최소 3기 이상
                .max(Comparator.comparingInt(e -> counts.getOrDefault(e.name, 0)))
                .map(e -> e.name)
                .orElse(null);
    }

    private void fire(GameState state, String type, String msg, String key) {
        if (commentaryFired.contains(key)) return;
        commentaryFired.add(key);
        addLog(state, type, msg);
    }

    private String pick(String[] arr) {
        return arr[rand.nextInt(arr.length)];
    }


    // ── 전투 로그: 유닛 이름 기반 묘사 ──────────────────────────────────────

    /** 승리측(atkIsMy) 기준 전투 묘사 — 유닛 조합 참조 */
    private String describeBattleWin(GameState state, boolean atkIsMy, boolean isCrit,
                                     Map<String, Integer> myCounts, Map<String, Integer> aiCounts) {
        String atkN  = atkIsMy ? state.getMyPlayerName() : state.getAiPlayerName();
        String defN  = atkIsMy ? state.getAiPlayerName() : state.getMyPlayerName();
        Map<String, Integer> atkC = atkIsMy ? myCounts : aiCounts;
        Map<String, Integer> defC = atkIsMy ? aiCounts : myCounts;

        String atkUnit = getTopCombatUnit(atkC);
        String defUnit = getTopCombatUnit(defC);
        String scene   = getBattleScene(atkUnit, defUnit);

        if (isCrit) {
            String[] crits = {
                atkN + " 선수 " + atkUnit + " 결정적인 한 방! " + defN + " 선수 " + defUnit + "이(가) 크게 무너집니다!",
                atkN + " 선수 " + atkUnit + "이(가) " + defN + " 선수가 화면을 놓친 사이 공격해서 큰 이득을 봅니다!",
                atkN + " 선수 완벽한 타이밍에 공격 시도합니다! " + defN + " 선수 " + defUnit + "에 큰 피해를 줍니다!"
            };
            return pick(crits);
        }
        if (scene != null) return scene;
        return getAttackDesc(atkUnit, defUnit, atkN, defN);
    }

    /** 팽팽한 교전 묘사 */
    private String describeBattleDraw(GameState state,
                                      Map<String, Integer> myCounts, Map<String, Integer> aiCounts) {
        String myN   = state.getMyPlayerName();
        String aiN   = state.getAiPlayerName();
        String myU   = getTopCombatUnit(myCounts);
        String aiU   = getTopCombatUnit(aiCounts);
        String[] draws = {
            myN + " 선수 " + myU + " vs " + aiN + " 선수 " + aiU + ", 팽팽하게 맞붙었습니다!",
            "치열한 교전! " + myU + "과 " + aiU + "이 서로 물러서지 않습니다.",
            myN + " 선수 " + myU + "이 " + aiN + " 선수 " + aiU + "과 맞붙었지만 결판이 나지 않았습니다!"
        };
        return pick(draws);
    }

    /** 공격 유닛 기준 공격 묘사 (테란 특화, 나머지 범용) */
    private String getAttackDesc(String atkUnit, String defUnit, String atkN, String defN) {
        if (atkUnit == null) atkUnit = "병력";
        if (defUnit == null) defUnit = "병력";
        String a = atkN + " 선수";
        String d = defN + " 선수";

        switch (atkUnit) {
            case "마린": return pick(new String[]{
                a + " 마린이 " + d + " " + defUnit + "을(를) 잡아냅니다!",
                a + " 마린이 " + d + " " + defUnit + " 라인을 뚫어냅니다!",
                a + " 마린이 " + d + " 진영으로 밀고 들어갑니다!",
            });
            case "메딕": return pick(new String[]{
                a + " 마린+메딕이 " + d + " " + defUnit + "을(를) 압박합니다!",
                a + " 마린+메딕 조합이 " + d + " " + defUnit + "을(를) 잡아냅니다!",
            });
            case "파이어뱃": return pick(new String[]{
                a + " 파이어뱃이 " + d + " " + defUnit + "을(를) 불태웁니다!",
                a + " 파이어뱃이 " + d + " " + defUnit + "을(를) 잡아냅니다!",
                a + " 파이어뱃이 " + d + " 진영을 밀어냅니다!",
            });
            case "탱크": return pick(new String[]{
                a + " 탱크가 " + d + " " + defUnit + "을(를) 포격합니다!",
                a + " 탱크 포격에 " + d + " " + defUnit + "이(가) 무너집니다!",
                a + " 탱크 라인이 " + d + " " + defUnit + "을(를) 밀어냅니다.",
            });
            case "벌처": return pick(new String[]{
                a + " 벌처가 " + d + " " + defUnit + " 측면을 파고듭니다!",
                a + " 벌처가 " + d + " " + defUnit + "을(를) 잡아냅니다!",
                a + " 벌처 기동으로 " + d + " " + defUnit + "이(가) 따라잡지 못합니다.",
            });
            case "골리앗": return pick(new String[]{
                a + " 골리앗이 " + d + " " + defUnit + "을(를) 타격합니다!",
                a + " 골리앗 화력에 " + d + " " + defUnit + "이(가) 잡힙니다!",
            });
            case "레이스": return pick(new String[]{
                a + " 레이스가 " + d + " " + defUnit + "을(를) 기습합니다!",
                a + " 레이스가 " + d + " " + defUnit + "을(를) 잡아냅니다!",
            });
            case "사이언스베슬": return pick(new String[]{
                a + " 베슬이 " + d + " " + defUnit + "에 이레디에이트를 겁니다!",
                a + " 사이언스베슬이 " + d + " " + defUnit + "을(를) 무력화합니다!",
            });
            case "배틀크루저": return pick(new String[]{
                a + " 배틀크루저가 " + d + " " + defUnit + "을(를) 격파합니다!",
                a + " 배틀크루저 야마토포에 " + d + " " + defUnit + "이(가) 직격당합니다!",
            });
            default: return pick(new String[]{
                a + " " + atkUnit + "이(가) " + d + " " + defUnit + "을(를) 잡아냅니다!",
                a + " " + atkUnit + "이(가) " + d + " " + defUnit + " 라인을 밀어냅니다.",
            });
        }
    }

        /** 유닛 조합 기반 전투 상황 묘사 (특정 조합에 대한 연출) */
    private String getBattleScene(String atkUnit, String defUnit) {
        if (atkUnit == null || defUnit == null) return null;
        String key = atkUnit + ">" + defUnit;
        Map<String, String[]> scenes = new HashMap<>();
        // 테란 공격
        scenes.put("마린>저글링",   new String[]{"마린 라인이 저글링 물량을 막아내며 역습합니다!", "스팀팩 마린이 저글링을 밀어냅니다!"});
        scenes.put("마린>히드라리스크", new String[]{"마린+메딕이 히드라 라인에 맞서 밀어붙입니다!", "바이오닉 vs 히드라 — 마린 화력이 앞섭니다!"});
        scenes.put("탱크>저글링",   new String[]{"시즈 탱크가 저글링을 완벽하게 막아냅니다!", "탱크 시즈 라인 앞에 저글링이 산화합니다!"});
        scenes.put("탱크>히드라리스크", new String[]{"시즈 탱크가 히드라 라인을 일방적으로 제압합니다!", "탱크 포격으로 히드라가 접근조차 못합니다!"});
        scenes.put("골리앗>뮤탈리스크", new String[]{"골리앗 대공 화력이 뮤탈리스크를 격추합니다!", "뮤탈이 골리앗 대공망에 걸려 손실이 납니다!"});
        scenes.put("레이스>히드라리스크", new String[]{"레이스가 히드라 저격에 나섭니다!", "레이스 클로킹 어택 — 히드라가 제대로 대응하지 못합니다!"});
        scenes.put("배틀크루저>뮤탈리스크", new String[]{"배틀크루저 야마토포가 뮤탈 무리를 강타합니다!"});
        scenes.put("마린>드라군",   new String[]{"마린 화력이 드라군 방어막을 뚫어냅니다!", "집중 사격으로 드라군을 하나씩 처리합니다!"});
        scenes.put("탱크>질럿",     new String[]{"탱크 앞에 달려드는 질럿이 막힙니다!", "시즈 탱크가 질럿 돌격을 완벽히 제지합니다!"});
        // 저그 공격
        scenes.put("저글링>마린",   new String[]{"저글링이 마린 라인을 빠르게 파고듭니다!", "속도 업 저글링이 마린 진형을 흩뜨립니다!"});
        scenes.put("저글링>질럿",   new String[]{"저글링이 질럿 수를 압도합니다!", "물량 저글링이 질럿 라인을 무너뜨립니다!"});
        scenes.put("히드라리스크>마린", new String[]{"히드라 집중 포화에 마린이 쓰러집니다!", "히드라 화력이 바이오닉 라인을 제압합니다!"});
        scenes.put("뮤탈리스크>마린", new String[]{"뮤탈 스택이 마린 무리에 파고듭니다!", "뮤탈리스크가 마린 라인 위를 휩쓸고 지나갑니다!"});
        scenes.put("뮤탈리스크>탱크", new String[]{"뮤탈이 기동력으로 탱크를 교란합니다!", "뮤탈이 탱크 라인 후방을 위협합니다!"});
        scenes.put("러커>마린",     new String[]{"러커가 버로우! 마린이 접근하지 못합니다!", "러커 스파인이 마린 진형을 관통합니다!"});
        scenes.put("러커>질럿",     new String[]{"러커 버로우 앞에 질럿 돌격이 막힙니다!"});
        scenes.put("울트라리스크>마린", new String[]{"울트라리스크가 마린 진형을 짓밟습니다!", "갑옷 울트라가 마린 라인에 돌진합니다!"});
        scenes.put("울트라리스크>질럿", new String[]{"울트라리스크 vs 질럿 — 덩치 차이가 압도적입니다!", "울트라리스크가 질럿을 밀어냅니다!"});
        scenes.put("가디언>마린",   new String[]{"가디언이 안전 사거리 밖에서 포격합니다!", "가디언 폭탄이 마린 라인을 초토화합니다!"});
        scenes.put("가디언>저글링", new String[]{"가디언 폭격 앞에 저글링이 속수무책입니다!"});
        scenes.put("스컬지>레이스", new String[]{"스컬지가 레이스를 향해 자폭 돌진합니다!", "스컬지 자폭! 레이스가 격추됩니다!"});
        scenes.put("스컬지>배틀크루저", new String[]{"스컬지 떼가 배틀크루저에 달려듭니다!", "스컬지 자폭 공격이 배틀크루저를 강타합니다!"});
        scenes.put("디파일러>마린", new String[]{"디파일러 다크 스웜! 마린 사격이 무력화됩니다!", "다크 스웜 아래 저그 병력이 마린을 압도합니다!"});
        // 프로토스 공격
        scenes.put("질럿>마린",     new String[]{"질럿이 마린 라인에 돌격합니다!", "방어막 질럿이 마린을 압박합니다!"});
        scenes.put("질럿>저글링",   new String[]{"질럿이 저글링 물량을 헤치고 나갑니다!", "질럿 일당백 — 저글링을 거침없이 베어냅니다!"});
        scenes.put("드라군>저글링", new String[]{"드라군이 저글링을 안전하게 처리합니다!", "드라군 사격으로 저글링이 접근하지 못합니다!"});
        scenes.put("드라군>탱크",   new String[]{"드라군이 탱크를 타겟팅합니다! 탱크가 흔들립니다!", "드라군 집중 사격에 탱크 라인이 무너집니다!"});
        scenes.put("다크템플러>마린", new String[]{"다크템플러 기습! 마린이 아무것도 못 보고 쓰러집니다!", "다크템플러가 마린 라인을 유린합니다!"});
        scenes.put("다크템플러>저글링", new String[]{"다크템플러가 저글링을 무참히 베어냅니다!", "클로킹 다크템플러 앞에 저글링이 속수무책!"});
        scenes.put("리버>저글링",   new String[]{"리버 스캐럽이 저글링 무리에 작렬합니다!", "리버 스캐럽 적중! 저글링이 대거 희생됩니다!"});
        scenes.put("리버>마린",     new String[]{"리버 스캐럽 한 방에 마린이 줄줄이 쓰러집니다!", "리버 스캐럽 적중! 마린 다수 손실!"});
        scenes.put("하이템플러>저글링", new String[]{"사이오닉 스톰이 저글링 무리를 강타합니다!", "스톰 한 방에 저글링이 쏟아집니다!"});
        scenes.put("하이템플러>히드라리스크", new String[]{"사이오닉 스톰으로 히드라 밀집 진형이 초토화됩니다!"});
        scenes.put("캐리어>저글링", new String[]{"캐리어 인터셉터가 저글링 물량을 일방적으로 제압합니다!"});
        scenes.put("스카우트>뮤탈리스크", new String[]{"스카우트가 뮤탈리스크를 추격합니다!", "스카우트 vs 뮤탈 — 공중전이 펼쳐집니다!"});
        scenes.put("커세어>뮤탈리스크", new String[]{"커세어 디스럽션 웹! 뮤탈리스크가 멈춥니다!", "커세어 집중 포화에 뮤탈 떼가 와해됩니다!"});
        scenes.put("아비터>마린", new String[]{"아비터 리콜! 아군 병력이 순간이동합니다!", "아비터 스테이시스 필드! 마린이 얼어붙습니다!"});
        scenes.put("아비터>저글링", new String[]{"아비터 스테이시스 필드로 저글링 물량을 무력화합니다!"});

        String[] opts = scenes.get(key);
        if (opts != null) return pick(opts);
        return null;
    }

    /** 견제에 사용되는 주력 유닛 반환 */
    private String getHarassUnit(Map<String, Integer> counts) {
        // 견제 성향 유닛 우선순위
        String[] harassPref = {"뮤탈리스크","스컬지","벌처","셔틀","다크템플러","레이스","저글링","마린","드라군"};
        for (String u : harassPref) {
            if (counts.getOrDefault(u, 0) >= 2) return u;
        }
        String top = getTopCombatUnit(counts);
        return top != null ? top : "병력";
    }

    /** 수비에 나서는 주력 유닛 반환 */
    private String getDefenceUnit(Map<String, Integer> counts) {
        String[] defPref = {"탱크","골리앗","울트라리스크","러커","드라군","리버","커세어","히드라리스크","마린","질럿"};
        for (String u : defPref) {
            if (counts.getOrDefault(u, 0) >= 1) return u;
        }
        String top = getTopCombatUnit(counts);
        return top != null ? top : "수비 병력";
    }

    /** 전투 병력 중 가장 많은 유닛 반환 */
    private String getTopCombatUnit(Map<String, Integer> counts) {
        if (counts == null || counts.isEmpty()) return null;
        return ENTITY_DB.values().stream()
                .filter(e -> "unit".equals(e.type) && e.combatPower > 0)
                .filter(e -> counts.getOrDefault(e.name, 0) >= 1)
                .max(Comparator.comparingInt(e -> counts.getOrDefault(e.name, 0)))
                .map(e -> e.name)
                .orElse(null);
    }

    private void addLog(GameState state, String type, String msg) {
        state.getNewLogs().add(new GameLog(state.getGameTime(), msg, type));
    }

    // ── deepCopy (가스 필드 포함) ─────────────────────────────
    private GameState deepCopy(GameState o) {
        GameState c = new GameState();
        c.setGameTime(o.getGameTime());
        c.setMinerals(o.getMinerals());           c.setAiMinerals(o.getAiMinerals());
        c.setGas(o.getGas());                     c.setAiGas(o.getAiGas());
        c.setGasPerSecond(o.getGasPerSecond());   c.setAiGasPerSecond(o.getAiGasPerSecond());
        c.setWorkerCount(o.getWorkerCount());     c.setAiWorkerCount(o.getAiWorkerCount());
        c.setCombatPower(o.getCombatPower());     c.setAiCombatPower(o.getAiCombatPower());
        c.setDefense(o.getDefense());             c.setAiDefense(o.getAiDefense());
        c.setMineralsPerSecond(o.getMineralsPerSecond());
        c.setAiMineralsPerSecond(o.getAiMineralsPerSecond());
        c.setLarvaCount(o.getLarvaCount());       c.setAiLarvaCount(o.getAiLarvaCount());
        c.setLarvaTimer(o.getLarvaTimer());       c.setAiLarvaTimer(o.getAiLarvaTimer());
        c.setBuildingCounts(new HashMap<>(o.getBuildingCounts()));
        c.setAiBuildingCounts(new HashMap<>(o.getAiBuildingCounts()));
        c.setProductionQueue(deepCopyQueue(o.getProductionQueue()));
        c.setAiProductionQueue(deepCopyQueue(o.getAiProductionQueue()));
        c.setNewLogs(new ArrayList<>(o.getNewLogs()));
        c.setMyPlayerName(o.getMyPlayerName());
        c.setAiPlayerName(o.getAiPlayerName());
        return c;
    }

    private List<ProductionItem> deepCopyQueue(List<ProductionItem> src) {
        List<ProductionItem> copy = new ArrayList<>();
        for (ProductionItem p : src) {
            ProductionItem n = new ProductionItem();
            n.setEntityId(p.getEntityId()); n.setName(p.getName());
            n.setType(p.getType()); n.setEndTime(p.getEndTime());
            n.setQueueStatus(p.getQueueStatus()); n.setScriptStep(p.getScriptStep());
            copy.add(n);
        }
        return copy;
    }
}