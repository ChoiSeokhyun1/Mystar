package dto.pve;

import lombok.Data;

@Data
public class BattleFighterDTO {

    // ── 식별 ──
    private String id;          // "b1","b2","b3","r1","r2","r3"
    private int    playerSeq;   // 원본 PLAYER_SEQ
    private int    ownedPlayerSeq; // 소유 선수 SEQ
    private String name;        // 선수 이름
    private String team;        // "blue" | "red"
    private String race;        // "T","P","Z"
    private String rarity;      // "N","R","SR","SSR","UR"
    private String imgUrl;      // 선수 이미지 URL

    // ── ATB 전투 스탯 (변경된 체계 적용) ──
    private int hp;             // 현재 체력
    private int maxHp;          // 최대 체력
    private int atk;            // 공격력
    private int def;            // 방어력
    private int harass;         // 견제력
    private int spd;            // 속도

    // ── 맵 배치 좌표 (%) ──
    private double x;
    private double y;

    // ── ATB 게이지 ──
    private int atb;

    // ── 원본 스탯 (참조용) ──
    private int origAttack;
    private int origDefense;
    private int origHp;
    private int origHarass;
    private int origSpeed;

    public static BattleFighterDTO fromStats(
            String id, String name, String team, String race, String rarity, String imgUrl,
            int playerSeq, int ownedPlayerSeq,
            int attack, int defense, int hp, int harass, int speed,
            double x, double y) {

        BattleFighterDTO dto = new BattleFighterDTO();
        dto.setId(id);
        dto.setPlayerSeq(playerSeq);
        dto.setOwnedPlayerSeq(ownedPlayerSeq);
        dto.setName(name);
        dto.setTeam(team);
        dto.setRace(race);
        dto.setRarity(rarity);
        dto.setImgUrl(imgUrl);

        // ── 스탯 매핑 (필요시 체력을 10배 뻥튀기하는 등 기획에 맞게 수정 가능) ──
        dto.setHp(hp);
        dto.setMaxHp(hp);
        dto.setAtk(attack);
        dto.setDef(defense);
        dto.setHarass(harass);
        dto.setSpd(speed);

        dto.setX(x);
        dto.setY(y);
        dto.setAtb(0);

        dto.setOrigAttack(attack);
        dto.setOrigDefense(defense);
        dto.setOrigHp(hp);
        dto.setOrigHarass(harass);
        dto.setOrigSpeed(speed);

        return dto;
    }
}