package dto.pve;

import lombok.Data;
import java.util.Date;
import java.util.List;

@Data
public class BuildDTO {
    private int buildId;
    private String userId;
    private String buildName;
    private String race;
    private String vsRace;
    private String playStyle;         // AGGRESSIVE(공격) / NORMAL(일반) / DEFENSIVE(수비)
    private String harassStyle;       // NO_HARASS(견제없음) / NORMAL_HARASS(일반견제) / HEAVY_HARASS(강견제)
    private String aggression;        // FAST_MULTI(빠른멀티) / NORMAL_MULTI(일반멀티) / SLOW_MULTI(느린멀티) — 멀티 타이밍 제어
    private int    maxBases;           // 최대 기지 수 (본진 포함, 0이면 기본값 4 사용)
    private int    maxTier;           // 최대 티어 제한: 1 / 2 / 3 (0이면 무제한=3)
    private int    winCount;
    private int    loseCount;
    private String preferredUnits;    // 선호 유닛 최대 5개 (쉼표 구분 ID)
    private String preferredBuildings;// 선호 건물 (e.g. "barracks:3:high,factory:2:mid")
    private Date createdAt;

    // Mapper JOIN용 (TBL_BUILD_UNITS 목록)
    private List<BuildUnitDTO> units;

    /** 선호 유닛 우선순위 + 그룹 내 비율 */
    public static class UnitPref {
        public final String group;  // "high" / "mid" / "low"
        public final int    ratio;  // 그룹 내 비율 1~10
        public final int    weight; // 시뮬레이션용 최종 가중치 (group 기반 오프셋 + ratio)
        public UnitPref(String group, int ratio) {
            this.group  = group;
            this.ratio  = Math.max(1, Math.min(10, ratio));
            // high=300~310, mid=200~210, low=100~110 → 그룹 간 완전 분리
            int offset = "high".equals(group) ? 300 : "mid".equals(group) ? 200 : 100;
            this.weight = offset + this.ratio;
        }
    }

    private static String normalizeGroup(String p) {
        if ("high".equals(p)) return "high";
        if ("low".equals(p))  return "low";
        return "mid";
    }

    /**
     * preferredUnits 파싱 → Map<unitId, UnitPref>
     * 형식: "tank:high:8,goliath:high:3,vulture:mid:5"
     * 구버전: "tank:high" → ratio=5 기본값, "tank" → mid:5
     */
    public java.util.Map<String, UnitPref> getPreferredUnitMap() {
        java.util.Map<String, UnitPref> map = new java.util.LinkedHashMap<>();
        if (preferredUnits == null || preferredUnits.trim().isEmpty()) return map;
        for (String entry : preferredUnits.split(",")) {
            String[] parts = entry.trim().split(":");
            if (parts.length == 0 || parts[0].trim().isEmpty()) continue;
            String unitId = parts[0].trim();
            String group  = parts.length >= 2 ? normalizeGroup(parts[1].trim()) : "mid";
            int ratio = 5; // 기본값
            if (parts.length >= 3) {
                try { ratio = Integer.parseInt(parts[2].trim()); } catch (NumberFormatException ignored) {}
            }
            map.put(unitId, new UnitPref(group, ratio));
        }
        return map;
    }

    /** 하위 호환용 — 선호 유닛 ID 목록만 반환 */
    public java.util.List<String> getPreferredUnitIds() {
        return new java.util.ArrayList<>(getPreferredUnitMap().keySet());
    }

    /** 선호 건물 정보 */
    public static class BuildingPref {
        public final int count;    // 최소 목표 수량
        public final int weight;   // 추가 건설 가중치 (high=10, mid=3, low=1)
        public BuildingPref(int count, int weight) { this.count = count; this.weight = weight; }
    }

    private static int priorityToWeight(String p) {
        if ("high".equals(p)) return 10;
        if ("low".equals(p))  return 1;
        return 3; // mid (기본)
    }

    /** preferredBuildings 파싱 → Map<buildingId, BuildingPref> */
    public java.util.Map<String, BuildingPref> getPreferredBuildingMap() {
        java.util.Map<String, BuildingPref> map = new java.util.LinkedHashMap<>();
        if (preferredBuildings == null || preferredBuildings.trim().isEmpty()) return map;
        for (String entry : preferredBuildings.split(",")) {
            String[] parts = entry.trim().split(":");
            if (parts.length >= 2) {
                try {
                    int count  = Integer.parseInt(parts[1].trim());
                    int weight = parts.length >= 3 ? priorityToWeight(parts[2].trim()) : 3;
                    map.put(parts[0].trim(), new BuildingPref(count, weight));
                } catch (NumberFormatException ignored) {}
            }
        }
        return map;
    }
}