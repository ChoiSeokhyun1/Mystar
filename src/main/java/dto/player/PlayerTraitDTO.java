package dto.player;

import lombok.Data;

@Data
public class PlayerTraitDTO {

    private int traitSeq;
    private int ownedPlayerSeq;

    // ── 행동 우선도 (1 ~ 10) ──────────────────
    private int atkWeight;      // 공격
    private int defWeight;      // 수비
    private int assistWeight;   // 도움
    private int harassWeight;   // 견제

    // ── 특성 레벨 (1 ~ 5) ────────────────────
    private int traitLevel;

    // ── 조인용 선수 정보 (Mapper에서 직접 매핑) ──
    private String playerName;
    private String race;
    private String rarity;
    private String playerImgUrl;
    private int    currentAttack;
    private int    currentDefense;
    private int    currentHp;
    private int    currentSpeed;
    private String condition;
    private int    slotNumber;
}
