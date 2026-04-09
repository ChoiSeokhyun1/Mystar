<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PVE ${stageLevel}-${subLevel} 경기 · My Star League</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css'/>">
    <link rel="stylesheet" href="<c:url value='/css/pveBattleSimulation.css'/>">
</head>
<body>
<c:set var="cm" value="${matchupList[currentSet - 1]}"/>

<%-- ═══ TOPBAR ══════════════════════════════════════════════════════════ --%>
<header class="msl-topbar sim-topbar">
    <div class="sim-topbar-logo">MY STAR <span>LEAGUE</span></div>
    <nav class="msl-breadcrumb sim-breadcrumb">
        <a href="<c:url value='/mode-select'/>">홈</a><span class="sep">/</span>
        <a href="<c:url value='/pve/lobby'/>">PVE</a><span class="sep">/</span>
        <span class="current">STAGE ${stageLevel}-${subLevel} · SET ${currentSet}</span>
    </nav>
    <div class="msl-topbar-right">
        <div class="sim-live-badge">● LIVE</div>
        <div class="msl-crystal">💎 ${sessionScope.loginUser.crystal}</div>
        <div class="msl-user-label"><strong>${sessionScope.loginUser.userNick}</strong></div>
    </div>
</header>

<%-- ═══ HIDDEN DATA (변경 없음) ══════════════════════════════════════════ --%>
<div id="data-storage" style="display:none">
    <textarea id="hiddenScriptJson"><c:out value="${replayJson}" default="{}" escapeXml="true"/></textarea>
    <input type="hidden" id="meta-stageLevel" value="${stageLevel}"/>
    <input type="hidden" id="meta-subLevel"   value="${subLevel}"/>
    <input type="hidden" id="meta-currentSet" value="${currentSet}"/>
    <input type="hidden" id="meta-myRace"     value="${cm.myPlayerRace}"/>
    <input type="hidden" id="meta-aiRace"     value="${cm.aiPlayerRace}"/>
    <textarea id="hiddenMatchupData">{"myPlayerName":"${cm.myPlayerName}","aiPlayerName":"${cm.aiPlayerName}","myPlayerImgUrl":"${cm.myPlayerImgUrl}","aiPlayerImgUrl":"${cm.aiPlayerImgUrl}","myPlayerRarity":"${cm.myPlayerRarity}","aiPlayerRarity":"${cm.aiPlayerRarity}","myPlayerRace":"${cm.myPlayerRace}","aiPlayerRace":"${cm.aiPlayerRace}","myPlayerAttack":${cm.myPlayerAttack!=null?cm.myPlayerAttack:0},"myPlayerDefense":${cm.myPlayerDefense!=null?cm.myPlayerDefense:0},"myPlayerMacro":${cm.myPlayerMacro!=null?cm.myPlayerMacro:0},"myPlayerMicro":${cm.myPlayerMicro!=null?cm.myPlayerMicro:0},"myPlayerLuck":${cm.myPlayerLuck!=null?cm.myPlayerLuck:0},"aiPlayerAttack":${cm.aiPlayerAttack!=null?cm.aiPlayerAttack:0},"aiPlayerDefense":${cm.aiPlayerDefense!=null?cm.aiPlayerDefense:0},"aiPlayerMacro":${cm.aiPlayerMacro!=null?cm.aiPlayerMacro:0},"aiPlayerMicro":${cm.aiPlayerMicro!=null?cm.aiPlayerMicro:0},"aiPlayerLuck":${cm.aiPlayerLuck!=null?cm.aiPlayerLuck:0}}</textarea>
    <textarea id="hiddenGameEntities">[<c:forEach var="b" items="${buildings}" varStatus="st">{"id":"${b.id}","name":"${b.name}","type":"building","mineral":${b.cost},"req":"${b.requiredBuilding}"}<c:if test="${!st.last}">,</c:if></c:forEach><c:if test="${not empty buildings and not empty units}">,</c:if><c:forEach var="u" items="${units}" varStatus="st">{"id":"${u.id}","name":"${u.name}","type":"unit","mineral":${u.cost},"req":"${u.requiredBuilding}"}<c:if test="${!st.last}">,</c:if></c:forEach>]</textarea>
    <%-- JS에서 읽는 표시용 요소 (화면 밖) --%>
    <span id="game-minerals">50</span><span id="game-gas">0</span>
    <span id="game-minerals-per-second">0</span><span id="game-gas-per-second">0</span>
    <span id="game-my-defense">1000</span><span id="game-ai-defense">1000</span>
    <span id="game-my-power">0</span><span id="game-ai-power">0</span>
    <span id="game-ai-minerals">50</span><span id="game-ai-gas">0</span>
    <span id="game-ai-minerals-per-second">0</span>
    <span id="disp-ai-workers">0</span>
    <span id="log-game-time">00:00</span>
</div>

<%-- ═══ MAIN ════════════════════════════════════════════════════════════ --%>
<main class="sim-layout">

    <%-- ══════════════════════════════════════════════════════════════════
         FIGHT HUD  —  내 선수 ←[HP/PWR 바]→ 스코어 ←[HP/PWR 바]→ 상대 선수
    ══════════════════════════════════════════════════════════════════ --%>
    <div class="fight-hud">

        <%-- 내 선수 --%>
        <div class="fh-side fh-side-my">

            <%-- 사진 (클릭 → 스탯 모달) --%>
            <div class="fhp-photo fhp-photo-my" id="myPlayerStatsHeader" title="스탯 보기">
                <img id="my-player-img"
                     src="<c:choose><c:when test='${not empty cm.myPlayerImgUrl}'><c:url value='${cm.myPlayerImgUrl}'/></c:when><c:otherwise></c:otherwise></c:choose>"
                     alt="${cm.myPlayerName}"
                     onerror="this.style.display='none';document.getElementById('my-init').style.display='flex'"/>
                <div class="fhp-initial" id="my-init" style="display:none">${fn:substring(cm.myPlayerName,0,1)}</div>
                <div class="fhp-photo-hint">STATS</div>
            </div>

            <%-- 이름 + 뱃지 + 바 + 자원 --%>
            <div class="fhp-info">
                <div class="fhp-namerow">
                    <span class="fhp-name">${cm.myPlayerName}</span>
                    <span class="msl-rarity ${fn:toLowerCase(cm.myPlayerRarity)}">${cm.myPlayerRarity}</span>
                    <span class="msl-race ${cm.myPlayerRace}">${cm.myPlayerRace}</span>
                </div>

                <div class="fhp-bars">
                    <%-- BASE HP --%>
                    <div class="fhb-row">
                        <span class="fhb-lbl">HP</span>
                        <div class="fhb-track">
                            <div id="bar-my-defense" class="fhb-fill" style="width:100%"></div>
                            <span id="bar-my-def-num" class="fhb-num-hidden">1000</span>
                        </div>
                        <span id="disp-my-defense" class="fhb-val fhb-val-my">1000</span>
                    </div>
                    <%-- 전투력 --%>
                    <div class="fhb-row">
                        <span class="fhb-lbl">PWR</span>
                        <div class="fhb-track">
                            <div id="bar-my-power" class="fhb-fill" style="width:0%"></div>
                            <span id="bar-my-pow-num" class="fhb-num-hidden">0</span>
                        </div>
                        <span id="disp-my-power" class="fhb-val fhb-val-my">0</span>
                    </div>
                </div>

                <div class="fhp-res">
                    <span class="fhp-res-item">💎 <span id="bn-my-min">50</span></span>
                    <span class="fhp-res-item">⛽ <span id="bn-my-gas">0</span></span>
                    <span class="fhp-res-item">👷 <span id="bn-my-workers">0</span></span>
                </div>
            </div>
        </div>

        <%-- 중앙 스코어 --%>
        <div class="fh-center">
            <div class="fhc-stage">STAGE ${stageLevel}-${subLevel} · ${cm.mapName}</div>

            <div class="fhc-score">
                <span id="hud-my-wins" class="fhc-n fhc-n-my">${myWins}</span>
                <span class="fhc-colon">:</span>
                <span id="hud-ai-wins" class="fhc-n fhc-n-ai">${aiWins}</span>
            </div>

            <div class="fhc-sets">
                <c:forEach begin="1" end="5" var="i">
                    <span class="fhc-dot ${i<=currentSet?(i<currentSet?'dot-done':'dot-active'):''}"></span>
                </c:forEach>
            </div>

            <div class="fhc-time" id="relay-time-hud">00:00</div>

            <div class="fhc-ctrl">
                <button id="skipButton" onclick="skipToResult()" class="btn-skip">⏩ 결과 보기</button>
                <button id="nextMatchButton" class="btn-next" style="display:none">다음 경기 →</button>
            </div>
        </div>

        <%-- 상대 선수 (좌우 반전) --%>
        <div class="fh-side fh-side-ai">

            <div class="fhp-info fhp-info-ai">
                <div class="fhp-namerow fhp-namerow-ai">
                    <span class="msl-race ${cm.aiPlayerRace}">${cm.aiPlayerRace}</span>
                    <span class="msl-rarity ${fn:toLowerCase(cm.aiPlayerRarity)}">${cm.aiPlayerRarity}</span>
                    <span class="fhp-name">${cm.aiPlayerName}</span>
                </div>

                <div class="fhp-bars fhp-bars-ai">
                    <%-- BASE HP (오른쪽→왼쪽으로 감소) --%>
                    <div class="fhb-row fhb-row-ai">
                        <span id="disp-ai-defense" class="fhb-val fhb-val-ai">1000</span>
                        <div class="fhb-track">
                            <div id="bar-ai-defense" class="fhb-fill" style="width:100%"></div>
                            <span id="bar-ai-def-num" class="fhb-num-hidden">1000</span>
                        </div>
                        <span class="fhb-lbl">HP</span>
                    </div>
                    <%-- 전투력 --%>
                    <div class="fhb-row fhb-row-ai">
                        <span id="disp-ai-power" class="fhb-val fhb-val-ai">0</span>
                        <div class="fhb-track">
                            <div id="bar-ai-power" class="fhb-fill" style="width:0%"></div>
                            <span id="bar-ai-pow-num" class="fhb-num-hidden">0</span>
                        </div>
                        <span class="fhb-lbl">PWR</span>
                    </div>
                </div>

                <div class="fhp-res fhp-res-ai">
                    <span class="fhp-res-item">👷 <span id="bn-ai-workers">0</span></span>
                    <span class="fhp-res-item">⛽ <span id="bn-ai-gas">0</span></span>
                    <span class="fhp-res-item">💎 <span id="bn-ai-min">50</span></span>
                </div>
            </div>

            <div class="fhp-photo fhp-photo-ai" id="aiPlayerStatsHeader" title="스탯 보기">
                <img id="ai-player-img"
                     src="<c:choose><c:when test='${not empty cm.aiPlayerImgUrl}'><c:url value='${cm.aiPlayerImgUrl}'/></c:when><c:otherwise></c:otherwise></c:choose>"
                     alt="${cm.aiPlayerName}"
                     onerror="this.style.display='none';document.getElementById('ai-init').style.display='flex'"/>
                <div class="fhp-initial" id="ai-init" style="display:none">${fn:substring(cm.aiPlayerName,0,1)}</div>
                <div class="fhp-photo-hint">STATS</div>
            </div>
        </div>

    </div><%-- /fight-hud --%>


    <%-- ══════════════════════════════════════════════════════════════════
         ARENA  —  3열 : [내 진영] [문자 중계] [상대 진영]
    ══════════════════════════════════════════════════════════════════ --%>
    <div class="arena">

        <%-- ▌내 진영 ─────────────────────────────────────────────────── --%>
        <div class="field-panel my-panel">

            <div class="fp-team-bar">
                <span class="fp-team-name fp-team-name-my">${myTeamName}</span>
            </div>

            <%-- 스탯 --%>
            <div class="fp-section fp-stat-panel" id="my-stat-panel"></div>

            <%-- 건물 --%>
            <div class="fp-section">
                <div class="fp-sec-label">🏗 건물</div>
                <div id="my-building-grid" class="entity-grid"></div>
            </div>

            <%-- 유닛 --%>
            <div class="fp-section">
                <div class="fp-sec-label">⚔ 유닛</div>
                <div id="my-unit-grid" class="entity-grid"></div>
            </div>
        </div>

        <%-- ▌문자 중계 ──────────────────────────────────────────────── --%>
        <div class="relay-panel">
            <div class="relay-head">
                <span class="relay-dot"></span>
                <span class="relay-title">실시간 문자 중계</span>
            </div>
            <div class="relay-feed" id="live-log">
                <div class="relay-row rr-system">
                    <span class="rr-time">00:00</span>
                    <span class="rr-badge rr-system-badge">시스템</span>
                    <span class="rr-msg">데이터 로딩 중…</span>
                </div>
            </div>
        </div>

        <%-- ▌상대 진영 ─────────────────────────────────────────────── --%>
        <div class="field-panel ai-panel">

            <div class="fp-team-bar fp-team-bar-ai">
                <span class="fp-team-name fp-team-name-ai">${opponentTeamName}</span>
            </div>

            <%-- 스탯 --%>
            <div class="fp-section fp-stat-panel" id="ai-stat-panel"></div>

            <%-- 건물 --%>
            <div class="fp-section">
                <div class="fp-sec-label fp-sec-label-ai">건물 🏗</div>
                <div id="ai-building-grid" class="entity-grid"></div>
            </div>

            <%-- 유닛 --%>
            <div class="fp-section">
                <div class="fp-sec-label fp-sec-label-ai">유닛 ⚔</div>
                <div id="ai-unit-grid" class="entity-grid"></div>
            </div>
        </div>

    </div><%-- /arena --%>

</main>

<%-- ═══ 경기 결과 모달 ════════════════════════════════════════════════ --%>
<div id="statChangeModal" class="msl-modal-back" style="display:none">
    <div class="msl-modal result-modal">
        <div class="msl-modal-head"><h2>📊 경기 결과</h2></div>
        <div class="msl-modal-body" id="statChangeContent"></div>
        <div class="msl-modal-foot">
            <button class="msl-btn msl-btn-primary" onclick="closeStatModal()">확인 후 나가기</button>
        </div>
    </div>
</div>

<%-- ═══ 스탯 상세 모달 ══════════════════════════════════════════════════ --%>
<div id="playerStatDetailModal" class="msl-modal-back" style="display:none">
    <div class="msl-modal" style="max-width:460px">
        <div class="msl-modal-head"><h2 id="playerStatDetailTitle">스탯 상세</h2></div>
        <div class="msl-modal-body" id="playerStatDetailContent"></div>
        <div class="msl-modal-foot">
            <button class="msl-btn msl-btn-secondary" onclick="document.getElementById('playerStatDetailModal').style.display='none'">닫기</button>
        </div>
    </div>
</div>

<script>
const META_DATA = {};
const SCRIPT_RAW = document.getElementById('hiddenScriptJson');
const SCRIPT_DATA = SCRIPT_RAW ? JSON.parse(SCRIPT_RAW.value || '{}') : {};
const SCRIPT_LINES = SCRIPT_DATA.lines || [];
const MY_WIN  = SCRIPT_DATA.myWin  || false;
const contextPath = '${pageContext.request.contextPath}';

// 메타 데이터 세팅
(function(){
    try{
        META_DATA.stageLevel = document.getElementById('meta-stageLevel').value;
        META_DATA.subLevel = document.getElementById('meta-subLevel').value;
        META_DATA.currentSet = parseInt(document.getElementById('meta-currentSet').value) || 1;
    } catch(e) {
        console.error("메타 데이터 파싱 오류:", e);
    }
})();

let scriptIdx = 0;
let scriptTicker = null;
let scriptFinished = false;

document.addEventListener('DOMContentLoaded', () => {
    // 삭제된 과거 함수들은 호출하지 않음 (JS 에러 방지)
    startScript();
});

/* ── 1. 대본 출력 시작 ── */
function startScript() {
    const logBox = document.getElementById('live-log');
    
    if (SCRIPT_LINES.length === 0) { 
        if(logBox) logBox.innerHTML = '';
        appendLog('대본 데이터가 없습니다. (기본 경기 처리)');
        endScript(); 
        return; 
    }
    
    scriptIdx = 0;
    if(logBox) logBox.innerHTML = ''; // 초기 "데이터 로딩 중..." 텍스트 삭제
    
    scriptTicker = setInterval(stepScript, 3000); // 3초마다 한 줄씩
    stepScript(); // 첫 줄은 즉시 출력
}

function stepScript() {
    if (scriptIdx >= SCRIPT_LINES.length) {
        endScript();
        return;
    }
    appendLog(SCRIPT_LINES[scriptIdx]);
    scriptIdx++;
}

/* ── 2. 화면에 문자 중계 추가 ── */
function appendLog(line) {
    const logBox = document.getElementById('live-log'); // 정확한 ID로 매칭
    if (!logBox) return;
    
    const el = document.createElement('div');
    el.className = 'relay-row rr-commentary';
    
    // 시간 표시 (3초씩 증가)
    const totalSec = scriptIdx * 3;
    const m = String(Math.floor(totalSec / 60)).padStart(2, '0');
    const s = String(totalSec % 60).padStart(2, '0');

    el.innerHTML = '<span class="rr-time">' + m + ':' + s + '</span>' +
                   '<span class="rr-badge rr-commentary-badge" style="background:#555; color:#fff; padding:2px 6px; border-radius:4px; font-size:0.8rem; margin-right:8px;">💬 해설</span>' +
                   '<span class="rr-msg">' + line + '</span>';
                   
    logBox.appendChild(el);
    logBox.scrollTop = logBox.scrollHeight;
}

/* ── 3. ⏩ 결과 보기 (스킵) ── */
function skipToResult() {
    if (scriptFinished) return;
    clearInterval(scriptTicker);
    
    // 아직 안 나온 대본들 한 번에 전부 쏟아내기
    while(scriptIdx < SCRIPT_LINES.length) {
        appendLog(SCRIPT_LINES[scriptIdx]);
        scriptIdx++;
    }
    endScript();
}

/* ── 4. 경기 종료 및 다음 버튼 활성화 ── */
function endScript() {
    if (scriptFinished) return;
    scriptFinished = true;
    clearInterval(scriptTicker);
    
    // 스킵 버튼 숨기기
    const skipBtn = document.getElementById('skipButton');
    if (skipBtn) skipBtn.style.display = 'none';

    // 다음 경기 버튼 띄우기
    const nextBtn = document.getElementById('nextMatchButton');
    if (nextBtn) {
        nextBtn.style.display = 'inline-block';
        nextBtn.textContent = MY_WIN ? '🏆 승리! 다음으로 →' : '💀 패배... 다음으로 →';
        nextBtn.style.backgroundColor = MY_WIN ? '#00cc66' : '#cc3333';
        nextBtn.style.color = '#ffffff';
        nextBtn.style.border = 'none';
        
        nextBtn.onclick = function() {
            finishMatch();
        };
    }
}

/* ── 5. 서버로 승패 전송 후 다음 세트 진행 ── */
function finishMatch() {
    const level = META_DATA.stageLevel;
    const subLevel = META_DATA.subLevel;
    const winner = MY_WIN ? 'player' : 'ai';
    
    fetch(contextPath + '/pve/battle/finish', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'level=' + level + '&subLevel=' + subLevel + '&winner=' + winner
    })
    .then(res => res.json())
    .then(result => {
        if (result.success) {
            if (result.victory !== null) { 
                // 최종 매치가 끝났을 경우 (승리 또는 패배)
                alert(result.message);
                location.href = contextPath + '/pve/lobby';
            } else {
                // 아직 남은 세트가 있을 경우 화면 새로고침하여 다음 세트 진행
                location.reload(); 
            }
        } else {
            alert('오류: ' + result.message);
        }
    })
    .catch(err => {
        console.error(err);
        alert('서버와의 통신 오류가 발생했습니다.');
    });
}
</script>
</body>
</html>
