<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>MYSTAR - 3v3 LIVE TACTICAL SIMULATION</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:wght@500;700&family=Noto+Sans+KR:wght@300;400;500;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="<c:url value='/css/pveBattleSimulation.css' />">
</head>
<body>

<div class="hud-wrapper">
    <header class="top-scoreboard">
        <div class="team-name blue">${myTeamName}</div>
        <div class="vs-badge">
            <span id="setScoreBlue">${myWins}</span>
            <span style="font-size:0.75rem;opacity:0.6;">SET</span>
            <span id="setScoreRed">${aiWins}</span>
        </div>
        <div class="team-name red">${opponentTeamName}</div>
        <div class="set-badge" id="setBadge">SET ${currentSet}</div>
    </header>

    <main class="main-stage">
        <section class="map-section" id="tacticalBoard">
            <canvas id="hexCanvas"></canvas>
            <svg id="svgOverlay"></svg>
            <div id="entityLayer"></div>
        </section>

        <section class="right-section">
            <div class="squad-status-panel">
                <div class="team-column blue" id="blueSquadPanel">
                    <div class="col-header">BLUE SQUADRON</div>
                </div>
                <div class="team-column red" id="redSquadPanel">
                    <div class="col-header">RED SQUADRON</div>
                </div>
            </div>

            <div class="momentum-panel">
                <div class="momentum-header">
                    <span style="color:#38bdf8;" id="blueTotalHpTxt">BLUE HP: 0</span>
                    <span style="color:#94a3b8;">SURVIVAL MOMENTUM</span>
                    <span style="color:#f43f5e;" id="redTotalHpTxt">RED HP: 0</span>
                </div>
                <div class="tug-of-war-bg">
                    <div class="tug-blue" id="tugBlueBar" style="width:50%;"></div>
                    <div class="tug-red"  id="tugRedBar"  style="width:50%;"></div>
                    <div class="tug-center"></div>
                </div>
            </div>

            <div class="log-panel">
                <div class="log-container" id="logBox"></div>
            </div>
        </section>
    </main>
</div>

<div class="modal-overlay" id="resultModal">
    <div class="modal-content" id="modalBox">
        <h1 id="modalTitle">VICTORY</h1>
        <p id="modalMsg">데이터를 서버에 동기화 중...</p>
        <a href="${pageContext.request.contextPath}/pve/lobby" class="modal-btn">로비로 돌아가기</a>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
// ============================================================
// 1. 서버 데이터 수신
// ============================================================
const battleData    = ${battleDataJson};   // BattleFighterDTO 배열 (6명)
const eventTimeline = ${eventLogJson};     // GameEvent 배열
const simWinner     = '${simWinner}';
const stageLevel    = ${stageLevel};
const subLevel      = ${subLevel};
const currentSet    = ${currentSet};
const myWins        = ${myWins};
const aiWins        = ${aiWins};

const svgOverlay = document.getElementById('svgOverlay');
const entityLayer = document.getElementById('entityLayer');
const logBox      = document.getElementById('logBox');

let hpState  = {};
let maxHpState = {};
let atbState = {};   // 각 선수의 현재 ATB (0~100)
let totalBlueMaxHp = 0, totalRedMaxHp = 0;

// 행동 배지 설정
const ACTION_BADGE = {
    ATK:    { label:'🗡 공격', cls:'ATK'    },
    DEF:    { label:'🛡 수비', cls:'DEF'    },
    ASSIST: { label:'🤝 도움', cls:'ASSIST' },
    HARASS: { label:'💢 견제', cls:'HARASS' },
    COMBO:  { label:'⚡ 콤보', cls:'COMBO'  }
};

const fallbackPositions = [
    {x:20,y:25},{x:15,y:55},{x:35,y:80},
    {x:80,y:20},{x:85,y:60},{x:65,y:85}
];

// ============================================================
// 2. UI 초기화
// ============================================================
function initBattleUI() {
    battleData.forEach(f => {
        hpState[f.id]  = f.maxHp;
        maxHpState[f.id] = f.maxHp;
        atbState[f.id] = 0;

        if (f.team === 'blue') totalBlueMaxHp += f.maxHp;
        else                    totalRedMaxHp  += f.maxHp;

        let pos = (f.startX != null) ? {x: f.startX, y: f.startY} : fallbackPositions.shift() || {x:50,y:50};
        f.x = pos.x; f.y = pos.y;

        // ── 맵 위 기지 ──
        entityLayer.insertAdjacentHTML('beforeend', `
            <div class="tactical-base \${f.team}" id="base_\${f.id}" style="left:\${pos.x}%;top:\${pos.y}%;">
                <div class="base-icon"><i class="fa-solid fa-\${f.team==='blue'?'jet-fighter':'skull'}"></i></div>
                <div class="bars-wrapper">
                    <div class="bar-track"><div class="hp-fill" id="maphp_\${f.id}" style="width:100%;"></div></div>
                </div>
                <div class="base-label">\${f.name}</div>
            </div>
        `);

        // ── 우측 패널 카드 (HP바 + ATB바) ──
        document.getElementById(f.team + 'SquadPanel').insertAdjacentHTML('beforeend', `
            <div class="player-card" id="card_\${f.id}">
                <div class="card-top">
                    <span class="p-name">\${f.name}</span>
                    <span class="p-hp-text" id="cardhptext_\${f.id}">\${f.maxHp}/\${f.maxHp}</span>
                </div>
                <div class="card-hp-bar">
                    <div class="card-hp-fill" id="cardhpbar_\${f.id}" style="width:100%;"></div>
                </div>
                <div class="card-atb-wrap">
                    <span class="card-atb-label">ATB</span>
                    <div class="card-atb-bg">
                        <div class="card-atb-fill" id="cardatb_\${f.id}" style="width:0%;"></div>
                    </div>
                </div>
                <div class="card-stats">
                    <span>ATK<span>\${f.atk}</span></span>
                    <span>DEF<span>\${f.def}</span></span>
                    <span>SPD<span>\${f.spd}</span></span>
                </div>
            </div>
        `);
    });

    updateMomentumUI();
    initHexMap();
}

// ============================================================
// 3. UI 업데이트 함수
// ============================================================
function updateHP(targetId, newHp) {
    hpState[targetId] = Math.max(0, newHp);
    const maxHp = maxHpState[targetId];
    const pct   = (hpState[targetId] / maxHp) * 100;

    const mhp = document.getElementById('maphp_' + targetId);
    const chb  = document.getElementById('cardhpbar_' + targetId);
    const cht  = document.getElementById('cardhptext_' + targetId);
    if (mhp) mhp.style.width = pct + '%';
    if (chb) chb.style.width = pct + '%';
    if (cht) cht.innerText  = hpState[targetId] + '/' + maxHp;

    if (hpState[targetId] <= 0) {
        const base = document.getElementById('base_' + targetId);
        const card = document.getElementById('card_' + targetId);
        if (base) base.classList.add('dead');
        if (card) card.classList.add('dead');
    }
    updateMomentumUI();
}

/** ATB 스냅샷(JSON 문자열)으로 전체 게이지 갱신 */
function updateATBSnapshot(snapshotJson) {
    if (!snapshotJson) return;
    try {
        const snapshot = JSON.parse(snapshotJson);
        snapshot.forEach(s => {
            atbState[s.id] = s.atb;
            const el = document.getElementById('cardatb_' + s.id);
            if (!el) return;
            const pct = (s.atb / 100) * 100;
            el.style.width = pct + '%';
            if (s.atb >= 100) {
                el.classList.add('full');
                setTimeout(() => el.classList.remove('full'), 500);
            }
        });
    } catch(e) {}
}

function updateMomentumUI() {
    let curBlue = 0, curRed = 0;
    battleData.forEach(f => {
        if (f.team === 'blue') curBlue += hpState[f.id];
        else                    curRed  += hpState[f.id];
    });
    document.getElementById('blueTotalHpTxt').innerText = 'BLUE HP: ' + curBlue;
    document.getElementById('redTotalHpTxt').innerText  = 'RED HP: '  + curRed;

    const total = curBlue + curRed;
    if (total === 0) return;
    const bluePct = (curBlue / total) * 100;
    document.getElementById('tugBlueBar').style.width = bluePct + '%';
    document.getElementById('tugRedBar').style.width  = (100 - bluePct) + '%';

    renderHexMap();
}

function addLog(htmlText, typeClass, actionType) {
    const div = document.createElement('div');
    div.className = 'log-line ' + (typeClass || '');

    // 행동 배지
    if (actionType && ACTION_BADGE[actionType]) {
        const badge = ACTION_BADGE[actionType];
        div.innerHTML = `<span class="action-badge \${badge.cls}">\${badge.label}</span><span class="log-text">\${htmlText}</span>`;
    } else {
        div.innerHTML = `<span class="log-text">\${htmlText}</span>`;
    }
    logBox.appendChild(div);
    logBox.scrollTop = logBox.scrollHeight;
}

// ============================================================
// 4. 시각 이펙트
// ============================================================
function getCenterCoords(el) {
    const rect    = el.getBoundingClientRect();
    const mapRect = document.getElementById('tacticalBoard').getBoundingClientRect();
    return {
        x: ((rect.left + rect.width/2  - mapRect.left) / mapRect.width)  * 100,
        y: ((rect.top  + rect.height/2 - mapRect.top)  / mapRect.height) * 100
    };
}

function drawTacticalArrow(actorId, targetId, team, color) {
    const baseActor  = document.getElementById('base_' + actorId);
    const baseTarget = document.getElementById('base_' + targetId);
    if (!baseActor || !baseTarget) return;

    const p1 = getCenterCoords(baseActor);
    const p2 = getCenterCoords(baseTarget);
    const strokeColor = color || (team === 'blue' ? 'rgba(56,189,248,0.8)' : 'rgba(244,63,94,0.8)');

    const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
    line.setAttribute('x1', p1.x+'%'); line.setAttribute('y1', p1.y+'%');
    line.setAttribute('x2', p1.x+'%'); line.setAttribute('y2', p1.y+'%');
    line.setAttribute('stroke', strokeColor);
    line.setAttribute('stroke-width', '0.6');
    svgOverlay.appendChild(line);

    let startTime = performance.now();
    function animate(time) {
        let p = (time - startTime) / 800;
        if (p < 1) {
            line.setAttribute('x2', p1.x + (p2.x - p1.x) * p + '%');
            line.setAttribute('y2', p1.y + (p2.y - p1.y) * p + '%');
            requestAnimationFrame(animate);
        } else {
            line.setAttribute('x2', p2.x+'%'); line.setAttribute('y2', p2.y+'%');
            line.style.transition = 'opacity 0.3s'; line.style.opacity = '0';
            setTimeout(() => line.remove(), 300);
        }
    }
    requestAnimationFrame(animate);
}

function showExplosion(targetId) {
    const target = document.getElementById('base_' + targetId);
    if (!target) return;
    const effect = document.createElement('div');
    effect.style.cssText = 'position:absolute;width:60px;height:60px;background:radial-gradient(circle,#facc15 0%,rgba(244,63,94,0) 70%);border-radius:50%;left:50%;top:50%;transform:translate(-50%,-50%) scale(0.5);z-index:20;transition:transform 0.3s ease-out,opacity 0.3s ease-out;';
    target.appendChild(effect);
    setTimeout(() => { effect.style.transform = 'translate(-50%,-50%) scale(1.5)'; effect.style.opacity='0'; }, 10);
    setTimeout(() => effect.remove(), 300);
}

function showHealEffect(targetId) {
    const target = document.getElementById('base_' + targetId);
    if (!target) return;
    const effect = document.createElement('div');
    effect.className = 'heal-effect';
    effect.innerText = '+HP';
    target.appendChild(effect);
    setTimeout(() => effect.remove(), 900);
}

function showDrainEffect(targetId) {
    const target = document.getElementById('base_' + targetId);
    if (!target) return;
    const effect = document.createElement('div');
    effect.className = 'drain-effect';
    effect.innerText = '-ATB';
    target.appendChild(effect);
    setTimeout(() => effect.remove(), 900);
}

function flashCard(id, cls) {
    const card = document.getElementById('card_' + id);
    if (!card) return;
    card.classList.add(cls);
    setTimeout(() => card.classList.remove(cls), 600);
}

function setShieldIcon(id, on) {
    const base = document.getElementById('base_' + id);
    if (!base) return;
    if (on) base.classList.add('shielded');
    else    base.classList.remove('shielded');
}

// ============================================================
// 5. 헥사곤 인플루언스 맵
// ============================================================
const canvas = document.getElementById('hexCanvas');
const ctx    = canvas.getContext('2d');
const hexRadius  = 15;
const fixedAlpha = 0.55;

function initHexMap() {
    requestAnimationFrame(() => {
        const el = canvas.parentElement;
        const w  = el.offsetWidth  || el.getBoundingClientRect().width;
        const h  = el.offsetHeight || el.getBoundingClientRect().height;
        if (w > 0 && h > 0) { canvas.width = w; canvas.height = h; renderHexMap(); }
        else setTimeout(initHexMap, 100);
    });
}

function renderHexMap() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    if (canvas.width === 0 || canvas.height === 0) return;

    const fixedPR = Math.min(canvas.width, canvas.height) * 0.12;
    const hh   = hexRadius * Math.sqrt(3);
    const cols = Math.ceil(canvas.width  / (hexRadius * 1.5)) + 1;
    const rows = Math.ceil(canvas.height / hh) + 1;

    for (let col = 0; col < cols; col++) {
        for (let row = 0; row < rows; row++) {
            let x = col * hexRadius * 1.5;
            let y = row * hh + (col % 2 === 1 ? hh / 2 : 0);

            let maxInf = 0, domTeam = null;
            battleData.forEach(f => {
                if (hpState[f.id] <= 0) return;
                let bx = (f.x / 100) * canvas.width;
                let by = (f.y / 100) * canvas.height;
                let dist = Math.sqrt(Math.pow(x - bx, 2) + Math.pow(y - by, 2));
                let inf  = Math.max(0, 1 - (dist / fixedPR));
                if (inf > maxInf) { maxInf = inf; domTeam = f.team; }
            });

            if (maxInf > 0 && domTeam) {
                ctx.beginPath();
                for (let i = 0; i < 6; i++) {
                    let angle = (Math.PI / 180) * (60 * i);
                    let hx = x + hexRadius * Math.cos(angle);
                    let hy = y + hexRadius * Math.sin(angle);
                    if (i === 0) ctx.moveTo(hx, hy); else ctx.lineTo(hx, hy);
                }
                ctx.closePath();
                ctx.fillStyle   = domTeam === 'blue' ? \`rgba(56,189,248,\${fixedAlpha})\` : \`rgba(244,63,94,\${fixedAlpha})\`;
                ctx.strokeStyle = \`rgba(255,255,255,\${fixedAlpha*0.1})\`;
                ctx.lineWidth   = 1;
                ctx.fill(); ctx.stroke();
            }
        }
    }
}

// ============================================================
// 6. 비동기 시뮬레이션 플레이어
// ============================================================
const sleep = ms => new Promise(r => setTimeout(r, ms));

async function loadMapAndAssignPositions() {
    try {
        const resp = await fetch('${pageContext.request.contextPath}/api/map/info?stageLevel=${stageLevel}&subLevel=${subLevel}&setNum=' + currentSet);
        const data = await resp.json();
        if (!data.success) return;

        if (data.bgImageUrl) {
            const board = document.getElementById('tacticalBoard');
            board.style.backgroundImage    = "url('" + data.bgImageUrl + "')";
            board.style.backgroundSize     = 'cover';
            board.style.backgroundPosition = 'center';
        }

        const startingPoints = (data.points || []).filter(p => p.pointType === 'STARTING');
        if (startingPoints.length < battleData.length) return;

        await new Promise(resolve => {
            const img = new Image();
            img.onload = function() {
                const W = img.naturalWidth || 1, H = img.naturalHeight || 1;
                for (let i = startingPoints.length - 1; i > 0; i--) {
                    const j = Math.floor(Math.random() * (i + 1));
                    [startingPoints[i], startingPoints[j]] = [startingPoints[j], startingPoints[i]];
                }
                battleData.forEach((f, idx) => {
                    if (idx < startingPoints.length) {
                        f.startX = (startingPoints[idx].pixelX / W) * 100;
                        f.startY = (startingPoints[idx].pixelY / H) * 100;
                    }
                });
                resolve();
            };
            img.onerror = resolve;
            img.src = data.bgImageUrl || '';
        });
    } catch(e) { console.warn('[MSL] 맵 정보 로드 실패:', e); }
}

async function startReplay() {
    await loadMapAndAssignPositions();
    initBattleUI();

    addLog('SYSTEM: 3v3 전술 교전 데이터를 수신했습니다.', 'system');
    await sleep(1200);
    addLog('SYSTEM: 전투 시뮬레이션을 시작합니다...', 'system');
    await sleep(800);

    for (let i = 0; i < eventTimeline.length; i++) {
        const ev = eventTimeline[i];
        const actionType = ev.actionType || null;

        // ATB 스냅샷 업데이트
        if (ev.atbSnapshotJson) updateATBSnapshot(ev.atbSnapshotJson);

        // ── 이벤트 타입별 처리 ──
        switch (ev.eventType) {

            case 'ATTACK': {
                flashCard(ev.actorId, 'acting');
                drawTacticalArrow(ev.actorId, ev.targetId, ev.actorTeam);
                await sleep(800);
                showExplosion(ev.targetId);
                updateHP(ev.targetId, ev.currentHp);  // ★ 버그 수정: targetHp → currentHp
                addLog(ev.logMessage, ev.logType, 'ATK');
                await sleep(350);
                break;
            }

            case 'COMBO': {
                flashCard(ev.actorId,       'acting');
                flashCard(ev.comboPartnerId,'acting');
                drawTacticalArrow(ev.actorId,        ev.targetId, ev.actorTeam, 'rgba(250,204,21,0.9)');
                drawTacticalArrow(ev.comboPartnerId, ev.targetId, ev.actorTeam, 'rgba(250,204,21,0.7)');
                await sleep(900);
                showExplosion(ev.targetId);
                updateHP(ev.targetId, ev.currentHp);
                addLog(ev.logMessage, ev.logType, 'COMBO');
                await sleep(350);
                break;
            }

            case 'SHIELD': {
                drawTacticalArrow(ev.actorId, ev.targetId, ev.actorTeam);
                await sleep(600);
                updateHP(ev.targetId, ev.currentHp);
                addLog(ev.logMessage, ev.logType, 'DEF');
                await sleep(300);
                break;
            }

            case 'DEFEND': {
                flashCard(ev.actorId,  'acting');
                flashCard(ev.targetId, 'defending');
                setShieldIcon(ev.targetId, true);
                setTimeout(() => setShieldIcon(ev.targetId, false), 3000);
                addLog(ev.logMessage, ev.logType, 'DEF');
                await sleep(500);
                break;
            }

            case 'ASSIST': {
                flashCard(ev.actorId,  'acting');
                flashCard(ev.targetId, 'healing');
                drawTacticalArrow(ev.actorId, ev.targetId, ev.actorTeam, 'rgba(74,222,128,0.8)');
                await sleep(600);
                showHealEffect(ev.targetId);
                // HP 회복 반영
                updateHP(ev.targetId, ev.currentHp);
                addLog(ev.logMessage, ev.logType, 'ASSIST');
                await sleep(350);
                break;
            }

            case 'HARASS': {
                flashCard(ev.actorId, 'acting');
                drawTacticalArrow(ev.actorId, ev.targetId, ev.actorTeam, 'rgba(251,146,60,0.8)');
                await sleep(700);
                showExplosion(ev.targetId);
                showDrainEffect(ev.targetId);
                updateHP(ev.targetId, ev.currentHp);
                addLog(ev.logMessage, ev.logType, 'HARASS');
                await sleep(350);
                break;
            }

            case 'DEATH': {
                addLog(ev.logMessage, 'kill', null);
                await sleep(300);
                break;
            }

            case 'BATTLE_END': {
                addLog(ev.logMessage, 'neutral', null);
                break;
            }

            default:
                addLog(ev.logMessage || '', ev.logType || '', actionType);
                await sleep(300);
        }
    }

    addLog('SYSTEM: 전투가 모두 종료되었습니다.', 'system');
    await sleep(1000);
    finishBattleAPI();
}

// ============================================================
// 7. 결과 DB 전송 & 모달
// ============================================================
function finishBattleAPI() {
    $.ajax({
        url:  '${pageContext.request.contextPath}/pve/battle/finish',
        type: 'POST',
        data: { level: stageLevel, subLevel: subLevel, winner: simWinner },
        success: function(res) {
            if (!res.success) {
                alert('오류: ' + (res.message || '알 수 없는 오류'));
                return;
            }

            if (!res.matchOver) {
                // ── 세트 종료, 다음 세트로 이동 ──
                const nextSet = res.nextSet;
                const blueScore = res.myWins;
                const redScore  = res.aiWins;

                const mBox  = document.getElementById('modalBox');
                const mTitle= document.getElementById('modalTitle');
                const mMsg  = document.getElementById('modalMsg');

                mBox.className   = 'modal-content set-end';
                mTitle.innerText = (simWinner === 'blue' ? '✔ SET WIN' : '✖ SET LOSE');
                mMsg.innerText   = blueScore + ' : ' + redScore + '  →  ' + nextSet + '세트를 시작합니다...';
                document.getElementById('resultModal').style.display = 'flex';

                // 2초 후 자동으로 다음 세트 페이지로 이동
                setTimeout(function() {
                    location.href = '${pageContext.request.contextPath}/pve/battle/result?level=' + stageLevel + '&subLevel=' + subLevel;
                }, 2000);

            } else {
                // ── 매치 최종 결과 ──
                const mBox  = document.getElementById('modalBox');
                const mTitle= document.getElementById('modalTitle');
                const mMsg  = document.getElementById('modalMsg');
                document.getElementById('resultModal').style.display = 'flex';

                if (res.victory) {
                    mBox.className   = 'modal-content victory';
                    mTitle.innerText = 'VICTORY';
                    mMsg.innerText   = res.myWins + ' : ' + res.aiWins + '  스테이지 클리어!';
                } else {
                    mBox.className   = 'modal-content defeat';
                    mTitle.innerText = 'DEFEAT';
                    mMsg.innerText   = res.myWins + ' : ' + res.aiWins + '  작전 실패. 다시 도전하세요.';
                }
            }
        },
        error: function() {
            alert('결과 저장 중 오류가 발생했습니다.');
            location.href = '${pageContext.request.contextPath}/pve/lobby';
        }
    });
}

window.addEventListener('resize', initHexMap);
window.onload = startReplay;
</script>
</body>
</html>
