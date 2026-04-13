package dto.pve;

import lombok.Data;

/**
 * 3:3 ATB 전투용 전투원 DTO.
 * 기존 5스탯(Attack, Defense, Macro, Micro, Luck)을
 * 4스탯(HP, ATK, DEF, SPD) 체계로 변환하여 프론트엔드에 JSON으로 전달한다.
 *
 * ── 스탯 변환 공식 ──
 *   HP  = (Attack + Defense + Macro) * 10        → 체력 (1500~3000 범위)
 *   ATK = (Attack * 2) + Micro                   → 공격력
 *   DEF = (Defense * 2) + Macro                  → 방어력
 *   SPD = (Micro + Luck) / 2 + 5                 → 속도 (ATB 게이지 충전 속도)
 */
@Data
public class BattleFighterDTO {

    // ── 식별 ──
    private String id;          // "b1","b2","b3","r1","r2","r3"
    private int    playerSeq;   // 원본 PLAYER_SEQ
    private int    ownedPlayerSeq; // 소유 선수 SEQ (블루팀만 해당, 레드팀은 0)
    private String name;        // 선수 이름
    private String team;        // "blue" | "red"
    private String race;        // "T","P","Z"
    private String rarity;      // "N","R","SR","SSR","UR"
    private String imgUrl;      // 선수 이미지 URL

    // ── ATB 전투 스탯 ──
    private int hp;             // 현재 체력
    private int maxHp;          // 최대 체력
    private int atk;            // 공격력
    private int def;            // 방어력
    private int spd;            // 속도

    // ── 맵 배치 좌표 (%) ──
    private double x;
    private double y;

    // ── ATB 게이지 (프론트에서 0으로 시작) ──
    private int atb;

    // ── 원본 스탯 (참조용) ──
    private int origAttack;
    private int origDefense;
    private int origMacro;
    private int origMicro;
    private int origLuck;

    /**
     * 기존 5스탯으로부터 ATB 전투 스탯을 산출하는 팩토리 메서드
     */
    public static BattleFighterDTO fromStats(
            String id, String name, String team, String race, String rarity, String imgUrl,
            int playerSeq, int ownedPlayerSeq,
            int attack, int defense, int macro, int micro, int luck,
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

        // ── 스탯 변환 ──
        int hp  = (attack + defense + macro) * 10;
        int atk = (attack * 2) + micro;
        int def2 = (defense * 2) + macro;
        int spd = (micro + luck) / 2 + 5;

        dto.setHp(hp);
        dto.setMaxHp(hp);
        dto.setAtk(atk);
        dto.setDef(def2);
        dto.setSpd(spd);

        dto.setX(x);
        dto.setY(y);
        dto.setAtb(0);

        dto.setOrigAttack(attack);
        dto.setOrigDefense(defense);
        dto.setOrigMacro(macro);
        dto.setOrigMicro(micro);
        dto.setOrigLuck(luck);

        return dto;
    }
}