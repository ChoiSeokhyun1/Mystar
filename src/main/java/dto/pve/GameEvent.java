package dto.pve;

import lombok.Data;

/**
 * ATB 전투 시뮬레이션 타임라인 이벤트 하나를 표현하는 DTO.
 *
 * 백엔드 시뮬레이션 엔진이 List<GameEvent> 로 타임라인을 구성하고,
 * 이를 JSON 으로 직렬화하여 프론트엔드에 전달한다.
 * 프론트엔드는 이 배열을 순서대로 읽어 애니메이션만 재생한다.
 *
 * eventType 종류:
 *   ATTACK     – 일반 공격 (drawTacticalArrow 호출)
 *   COMBO      – 콤보 공격 (drawAirStrikeArrow + drawTacticalArrow 호출)
 *   SHIELD     – 방패 방어 난입 (showShieldDeflect 호출)
 *   DEATH      – 전사 (기지 블랙아웃)
 *   BATTLE_END – 전투 종료
 */
@Data
public class GameEvent {

    // ── 이벤트 분류 ──
    private String  eventType;        // "ATTACK" | "COMBO" | "SHIELD" | "DEATH" | "BATTLE_END"
    private int     tick;             // 시뮬레이션 틱 번호

    // ── 행동 주체 ──
    private String  actorId;          // "b1" ~ "b3", "r1" ~ "r3"
    private String  actorName;
    private String  actorTeam;        // "blue" | "red"
    private double  actorX;
    private double  actorY;

    // ── 콤보 파트너 (COMBO 이벤트일 때) ──
    private String  comboPartnerId;
    private String  comboPartnerName;
    private double  comboPartnerX;
    private double  comboPartnerY;

    // ── 피격 대상 ──
    private String  targetId;
    private String  targetName;
    private String  targetTeam;
    private double  targetX;
    private double  targetY;

    // ── 전투 수치 ──
    private int     damage;           // 최종 적용 데미지
    private int     currentHp;        // 피격 후 대상의 현재 HP
    private int     maxHp;            // 대상의 최대 HP
    private boolean lethal;           // 이 공격으로 사망하면 true  (JS: isLethal)
    private boolean shieldBlocked;    // 방패 경감 여부

    // ── ATB 스냅샷 (이벤트 발생 직후 전체 전투원 ATB 상태) ──
    // JSON 배열: [{"id":"b1","atb":0,"hp":1500}, ...]
    private String  atbSnapshotJson;

    // ── 로그 메시지 (Combat Log 패널에 표시) ──
    private String  logMessage;
    private String  logType;          // "blue" | "red" | "neutral" | "kill"

    // ── BATTLE_END 전용 ──
    private String  winner;           // "blue" | "red"
    private String  winnerName;

    // ── 팩토리 메서드 ──

    public static GameEvent attack(int tick, BattleFighterDTO actor, BattleFighterDTO target,
                                   int damage, boolean lethal) {
        GameEvent ev = new GameEvent();
        ev.eventType   = "ATTACK";
        ev.tick        = tick;
        ev.actorId     = actor.getId();
        ev.actorName   = actor.getName();
        ev.actorTeam   = actor.getTeam();
        ev.actorX      = actor.getX();
        ev.actorY      = actor.getY();
        ev.targetId    = target.getId();
        ev.targetName  = target.getName();
        ev.targetTeam  = target.getTeam();
        ev.targetX     = target.getX();
        ev.targetY     = target.getY();
        ev.damage      = damage;
        ev.currentHp   = Math.max(0, target.getHp());
        ev.maxHp       = target.getMaxHp();
        ev.lethal      = lethal;
        ev.logMessage  = "<strong>[" + actor.getName() + "]</strong> → "
                       + "<strong>[" + target.getName() + "]</strong> "
                       + "<b>-" + damage + "</b> 데미지!"
                       + (lethal ? " 💀 전사!" : "");
        ev.logType     = actor.getTeam();
        return ev;
    }

    public static GameEvent shield(int tick, BattleFighterDTO actor, BattleFighterDTO target,
                                   BattleFighterDTO interceptor, int reducedDamage) {
        GameEvent ev = new GameEvent();
        ev.eventType        = "SHIELD";
        ev.tick             = tick;
        ev.actorId          = actor.getId();
        ev.actorName        = actor.getName();
        ev.actorTeam        = actor.getTeam();
        ev.actorX           = actor.getX();
        ev.actorY           = actor.getY();
        ev.targetId         = target.getId();
        ev.targetName       = target.getName();
        ev.targetTeam       = target.getTeam();
        ev.targetX          = interceptor.getX();  // 방패는 방어자 위치
        ev.targetY          = interceptor.getY();
        ev.damage           = reducedDamage;
        ev.currentHp        = Math.max(0, target.getHp());
        ev.maxHp            = target.getMaxHp();
        ev.shieldBlocked    = true;
        ev.comboPartnerId   = interceptor.getId();
        ev.comboPartnerName = interceptor.getName();
        ev.logMessage       = "🛡 <strong>[" + interceptor.getName() + "]</strong> 가 "
                            + "<strong>[" + target.getName() + "]</strong> 엄호! "
                            + "<strong>[" + actor.getName() + "]</strong> 의 공격 경감 → "
                            + "<b>-" + reducedDamage + "</b>";
        ev.logType          = target.getTeam();
        return ev;
    }

    public static GameEvent combo(int tick, BattleFighterDTO actor, BattleFighterDTO partner,
                                  BattleFighterDTO target, int damage, boolean lethal) {
        GameEvent ev = new GameEvent();
        ev.eventType        = "COMBO";
        ev.tick             = tick;
        ev.actorId          = actor.getId();
        ev.actorName        = actor.getName();
        ev.actorTeam        = actor.getTeam();
        ev.actorX           = actor.getX();
        ev.actorY           = actor.getY();
        ev.comboPartnerId   = partner.getId();
        ev.comboPartnerName = partner.getName();
        ev.comboPartnerX    = partner.getX();
        ev.comboPartnerY    = partner.getY();
        ev.targetId         = target.getId();
        ev.targetName       = target.getName();
        ev.targetTeam       = target.getTeam();
        ev.targetX          = target.getX();
        ev.targetY          = target.getY();
        ev.damage           = damage;
        ev.currentHp        = Math.max(0, target.getHp());
        ev.maxHp            = target.getMaxHp();
        ev.lethal           = lethal;
        ev.logMessage       = "⚡ <strong>[" + actor.getName() + "]</strong> + "
                            + "<strong>[" + partner.getName() + "]</strong> 콤보! → "
                            + "<strong>[" + target.getName() + "]</strong> <b>-" + damage + "</b>"
                            + (lethal ? " 💀 전사!" : "");
        ev.logType          = actor.getTeam();
        return ev;
    }

    public static GameEvent battleEnd(int tick, String winner, String winnerName) {
        GameEvent ev = new GameEvent();
        ev.eventType  = "BATTLE_END";
        ev.tick       = tick;
        ev.winner     = winner;
        ev.winnerName = winnerName;
        ev.logMessage = "🏆 <b style=\"color:#eab308;font-size:15px\">"
                      + winnerName + " TEAM 승리!</b>";
        ev.logType    = "neutral";
        return ev;
    }
}