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
    <textarea id="hiddenReplayJson"><c:out value="${replayJson}" default="[]" escapeXml="true"/></textarea>
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

<%-- ═══ SCRIPT (원본 그대로) ════════════════════════════════════════════ --%>
<script>
const GAME_DATA={},META_DATA={};let REPLAY_DATA=[],MATCHUP_INFO={};
const contextPath='${pageContext.request.contextPath}';

const ENT_TYPE={
  '커맨드센터':'building','정제소':'building','배럭스':'building','아카데미':'building',
  '팩토리':'building','머신샵':'building','아머리':'building','스타포트':'building',
  '사이언스 퍼실리티':'building','뉴클리어 어댑터':'building','배틀 어댑터':'building',
  '해처리':'building','추출기':'building','스포닝풀':'building','히드라덴':'building','스파이어':'building','러커어스펙트':'building',
  '넥서스':'building','동화기':'building','게이트웨이':'building','사이버네틱스코어':'building','시타델':'building','로보틱스':'building',
  'SCV':'unit','마린':'unit','파이어뱃':'unit','메딕':'unit',
  '벌처':'unit','탱크':'unit','골리앗':'unit','레이스':'unit','드랍쉽':'unit',
  '고스트':'unit','사이언스베슬':'unit','배틀크루저':'unit',
  '드론':'unit','저글링':'unit','히드라리스크':'unit','뮤탈리스크':'unit','러커':'unit',
  '프로브':'unit','질럿':'unit','드라군':'unit','다크템플러':'unit','리버':'unit','하이템플러':'unit','커세어':'unit','캐리어':'unit'
};
const ENT_ID={
  '커맨드센터':'command_center','정제소':'refinery','배럭스':'barracks','아카데미':'academy',
  '팩토리':'factory','머신샵':'machine_shop','아머리':'armory','스타포트':'starport',
  '사이언스 퍼실리티':'science_facility','뉴클리어 어댑터':'nuclear_silo','배틀 어댑터':'battle_adaptor',
  '해처리':'hatchery','추출기':'extractor','스포닝풀':'spawning_pool','히드라덴':'hydralisk_den','스파이어':'spire','러커어스펙트':'lurker_aspect',
  '넥서스':'nexus','동화기':'assimilator','게이트웨이':'gateway','사이버네틱스코어':'cybernetics_core','시타델':'citadel','로보틱스':'robotics',
  'SCV':'scv','마린':'marine','파이어뱃':'firebat','메딕':'medic',
  '벌처':'vulture','탱크':'tank','골리앗':'goliath','레이스':'wraith','드랍쉽':'dropship',
  '고스트':'ghost','사이언스베슬':'vessel','배틀크루저':'battlecruiser',
  '드론':'drone','저글링':'zergling','히드라리스크':'hydralisk','뮤탈리스크':'mutalisk','러커':'lurker',
  '프로브':'probe','질럿':'zealot','드라군':'dragoon','다크템플러':'dark_templar','리버':'reaver','하이템플러':'high_templar','커세어':'corsair','캐리어':'carrier'
};
const RACE_ENT={
  T:{
    buildings:[
      {tier:1, items:['커맨드센터','정제소','배럭스','아카데미']},
      {tier:2, items:['팩토리','머신샵','아머리','스타포트']},
      {tier:3, items:['사이언스 퍼실리티','뉴클리어 어댑터','배틀 어댑터']}
    ],
    units:[
      {tier:1, items:['SCV','마린','파이어뱃','메딕']},
      {tier:2, items:['벌처','탱크','골리앗','레이스','드랍쉽']},
      {tier:3, items:['고스트','사이언스베슬','배틀크루저']}
    ]
  },
  P:{
    buildings:[
      {tier:1, items:['넥서스','동화기','게이트웨이']},
      {tier:2, items:['사이버네틱스코어','시타델','로보틱스']}
    ],
    units:[
      {tier:1, items:['프로브','질럿','드라군']},
      {tier:2, items:['다크템플러','리버','하이템플러','커세어','캐리어']}
    ]
  },
  Z:{
    buildings:[
      {tier:1, items:['해처리','추출기','스포닝풀']},
      {tier:2, items:['히드라덴','스파이어','러커어스펙트']}
    ],
    units:[
      {tier:1, items:['드론','저글링','히드라리스크']},
      {tier:2, items:['뮤탈리스크','러커']}
    ]
  }
};
const LOG_META={
  battle:    {badge:'⚔ 교전',    cls:'rr-battle'},
  harass:    {badge:'🐝 견제',    cls:'rr-harass'},
  user_action:{badge:'▶ 내팀',   cls:'rr-my'},
  ai_action:  {badge:'◀ 상대',   cls:'rr-ai'},
  commentary: {badge:'💬 해설',   cls:'rr-commentary'},
  system:     {badge:'📡 시스템', cls:'rr-system'}
};

(function(){
    try{
        META_DATA.stageLevel=document.getElementById('meta-stageLevel').value;
        META_DATA.subLevel=document.getElementById('meta-subLevel').value;
        META_DATA.currentSet=parseInt(document.getElementById('meta-currentSet').value)||1;
        META_DATA.myRace=document.getElementById('meta-myRace').value||'T';
        META_DATA.aiRace=document.getElementById('meta-aiRace').value||'T';
        const ms=document.getElementById('hiddenMatchupData').value;
        if(ms)MATCHUP_INFO=JSON.parse(ms);
        JSON.parse(document.getElementById('hiddenGameEntities').value||'[]').forEach(e=>{GAME_DATA[e.id]=e;});
        const rs=document.getElementById('hiddenReplayJson').value;
        if(rs&&rs.trim()!=='[]'&&rs.trim()!=='')REPLAY_DATA=JSON.parse(rs);
        else{const f=document.getElementById('live-log');if(f)f.innerHTML='<div class="relay-row rr-system"><span class="rr-time">00:00</span><span class="rr-badge rr-system-badge">⚠ 오류</span><span class="rr-msg" style="color:#ff6b6b">데이터 없음</span></div>';}
    }catch(e){console.error(e);}
})();

let replayIdx=0,ticker=null,finished=false,curTime=0;

document.addEventListener('DOMContentLoaded',()=>{
    initCharts();setupEvents();initGrids();initImages();initStatPanels();
    if(REPLAY_DATA.length>0)setTimeout(startGame,500);
});

function initImages(){
    ['my','ai'].forEach(w=>{
        const img=document.getElementById(w+'-player-img'),ini=document.getElementById(w+'-init');
        if(!img||!ini)return;
        if(!img.src||img.src===window.location.href||img.src.endsWith('/')){img.style.display='none';ini.style.display='flex';}
    });
}

function startGame(){
    ticker = setInterval(nextFrame, 30);
}
function nextFrame(){
    if(replayIdx>=REPLAY_DATA.length){endGame();return;}
    const f=REPLAY_DATA[replayIdx],p=replayIdx>0?REPLAY_DATA[replayIdx-1]:null;
    if(f.newLogs){const bl=f.newLogs.find(l=>l.type==='battle'&&l.message&&l.message.includes('교전'));if(bl&&p)battleFX(p,f,bl.message);}
    updateUI(f);replayIdx++;
}
function skipToResult(){
    if(finished)return;
    const sb=document.getElementById('skipButton');if(sb){sb.disabled=true;sb.textContent='처리 중…';}
    clearInterval(ticker);finished=true;
    const lf=REPLAY_DATA[REPLAY_DATA.length-1];
    if(lf){replayIdx=REPLAY_DATA.length;updateUI(lf);}
    document.getElementById('nextMatchButton').style.display='none';
    sendResult(winner(lf));
}
function endGame(){
    if(finished)return;finished=true;clearInterval(ticker);
    const sb=document.getElementById('skipButton');if(sb)sb.style.display='none';
    const btn=document.getElementById('nextMatchButton');if(btn){btn.style.display='block';btn.textContent='다음 경기 →';}
    addLog('system','경기 종료.');
}
function winner(s){
    if(!s)return'ai';
    if(s.defense>0&&s.aiDefense<=0)return'player';
    if(s.defense>s.aiDefense)return'player';
    if(s.defense===s.aiDefense&&s.combatPower>=s.aiCombatPower)return'player';
    return'ai';
}

function updateUI(s){
    if(!s)return; curTime=s.gameTime||0;
    $('game-minerals',Math.floor(s.minerals));$('bn-my-min',Math.floor(s.minerals));
    $('game-minerals-per-second',s.mineralsPerSecond.toFixed(0));
    $('game-gas',Math.floor(s.gas||0));$('bn-my-gas',Math.floor(s.gas||0));
    $('game-gas-per-second',(s.gasPerSecond||0).toFixed(1));
    $('bn-my-workers',s.workerCount||0);
    $('game-ai-minerals',Math.floor(s.aiMinerals));$('bn-ai-min',Math.floor(s.aiMinerals));
    $('game-ai-minerals-per-second',s.aiMineralsPerSecond.toFixed(0));
    $('game-ai-gas',Math.floor(s.aiGas||0));$('bn-ai-gas',Math.floor(s.aiGas||0));
    $('bn-ai-workers',s.aiWorkerCount||0);$('disp-ai-workers',s.aiWorkerCount||0);
    $('game-my-power',s.combatPower.toFixed(0));$('game-ai-power',s.aiCombatPower.toFixed(0));
    $('game-my-defense',Math.max(0,Math.floor(s.defense)));$('game-ai-defense',Math.max(0,Math.floor(s.aiDefense)));
    $('disp-my-defense',Math.max(0,Math.floor(s.defense)));$('disp-ai-defense',Math.max(0,Math.floor(s.aiDefense)));
    $('disp-my-power',s.combatPower.toFixed(0));$('disp-ai-power',s.aiCombatPower.toFixed(0));
    const min=Math.floor(s.gameTime/60),sec=s.gameTime%60;
    const ts=min+':'+(sec<10?'0'+sec:sec);
    $('log-game-time',ts);$('relay-time-hud',ts);
    updateGrids(s.buildingCounts,s.productionQueue,false,s.gameTime);
    updateGrids(s.aiBuildingCounts,s.aiProductionQueue,true,s.gameTime);
    if(s.newLogs&&s.newLogs.length>0)s.newLogs.forEach(l=>addLog(l.type,l.message));
    updateCharts(s);
}
function $(id,v){const e=document.getElementById(id);if(e)e.textContent=v;}
function bar(id,pct,cls){
    const e=document.getElementById(id);
    if(!e)return;
    e.style.width=pct+'%';
    if(cls)e.className=cls;
}

function battleFX(pf,cf,msg){
    const mL=pf.buildingCounts||{},aL=pf.aiBuildingCounts||{},mC=cf.buildingCounts||{},aC=cf.aiBuildingCounts||{};
    if(hasLoss(mL,mC))applyHit('my-unit-grid',mL,mC);
    if(hasLoss(aL,aC))applyHit('ai-unit-grid',aL,aC);
    const myA=!msg.includes('AI 공격')||msg.includes('양측'),aiA=msg.includes('AI 공격')||msg.includes('양측');
    if(myA)flash('my-unit-grid');if(aiA)flash('ai-unit-grid');
}
function hasLoss(p,c){for(const n in p)if(ENT_TYPE[n]==='unit'&&(c[n]||0)<(p[n]||0))return true;return false;}
function applyHit(gid,pc,cc){
    document.getElementById(gid)?.querySelectorAll('.entity-card').forEach(card=>{
        const n=card.dataset.name;if(ENT_TYPE[n]!=='unit')return;
        if((pc[n]||0)-(cc[n]||0)>0){card.classList.remove('card-hit');void card.offsetWidth;card.classList.add('card-hit');setTimeout(()=>card.classList.remove('card-hit'),700);}
    });
}
function flash(gid){
    document.getElementById(gid)?.querySelectorAll('.entity-card:not(.inactive)').forEach(c=>{
        if(c.dataset.type!=='unit')return;
        c.classList.remove('card-flash');void c.offsetWidth;c.classList.add('card-flash');setTimeout(()=>c.classList.remove('card-flash'),500);
    });
}
function cntDown(badge,from,to){
    const steps=Math.min(Math.abs(from-to),12),st=600/steps;let cur=from;badge.style.display='block';
    const iv=setInterval(()=>{
        if(cur>to){cur=Math.max(to,cur-Math.ceil((from-to)/steps));badge.textContent=cur>0?cur:'';badge.classList.add('count-flash');setTimeout(()=>badge.classList.remove('count-flash'),80);}
        if(cur<=to){badge.textContent=to>0?to:'';badge.style.display=to>0?'block':'none';clearInterval(iv);}
    },st);
}

const UNITS=['SCV','마린','파이어뱃','메딕','벌처','탱크','골리앗','드론','저글링','히드라리스크','뮤탈리스크','러커','프로브','질럿','드라군','다크템플러','리버','하이템플러','커세어','캐리어'];
const PROD_KW=['전장 투입','완성','출격 대기','생산 시작','생산'];
const seenProd=new Set();
function isProd(msg){return PROD_KW.some(k=>msg.includes(k));}
function unitKey(type,msg){for(const u of UNITS)if(msg.includes(u))return type+':'+u;return null;}
function addLog(type,msg){
    if(type==='user_action'||type==='ai_action'){
        if(isProd(msg)){const k=unitKey(type,msg);if(k){if(seenProd.has(k))return;seenProd.add(k);}}
        if(msg.includes('🐝'))type='harass';
    }
    const t=curTime||0,min=Math.floor(t/60),sec=t%60;
    const ts=min+':'+(sec<10?'0'+sec:sec);
    const meta=LOG_META[type]||{badge:'기타',cls:'rr-system'};
    const row=document.createElement('div');
    row.className='relay-row '+meta.cls;
    row.innerHTML='<span class="rr-time">'+ts+'</span>'
        +'<span class="rr-badge '+meta.cls+'-badge">'+meta.badge+'</span>'
        +'<span class="rr-msg">'+msg+'</span>';
    const feed=document.getElementById('live-log');
    if(!feed)return;
    feed.appendChild(row);
    feed.scrollTop=feed.scrollHeight;
}

function initCharts(){ /* horizontal bars — no canvas init needed */ }
function updateCharts(s){
    const maxDef=1000, maxPow=Math.max(3000,s.combatPower||0,s.aiCombatPower||0);
    const myDefPct=Math.max(0,Math.min(100,(s.defense/maxDef)*100));
    const myPowPct=Math.max(0,Math.min(100,(s.combatPower/maxPow)*100));
    const aiDefPct=Math.max(0,Math.min(100,(s.aiDefense/maxDef)*100));
    const aiPowPct=Math.max(0,Math.min(100,(s.aiCombatPower/maxPow)*100));
    hbar('bar-my-defense','bar-my-def-num',myDefPct,Math.max(0,Math.floor(s.defense)));
    hbar('bar-my-power',  'bar-my-pow-num',myPowPct,(s.combatPower||0).toFixed(0));
    hbar('bar-ai-defense','bar-ai-def-num',aiDefPct,Math.max(0,Math.floor(s.aiDefense)));
    hbar('bar-ai-power',  'bar-ai-pow-num',aiPowPct,(s.aiCombatPower||0).toFixed(0));
}
function hbar(fillId,numId,pct,val){
    const f=document.getElementById(fillId);if(f)f.style.width=pct+'%';
    const n=document.getElementById(numId);if(n)n.textContent=val;
}

function sendResult(w){
    const p=new URLSearchParams();p.append('level',META_DATA.stageLevel);p.append('subLevel',META_DATA.subLevel);p.append('winner',w);
    fetch(contextPath+'/pve/battle/finish',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:p})
    .then(r=>r.json()).then(data=>{
        if(data.success){if(data.victory===true||data.victory===false)showResultModal(data);else setTimeout(()=>{window.location.href=contextPath+'/pve/battle/result?level='+META_DATA.stageLevel+'&subLevel='+META_DATA.subLevel;},1500);}
        else{alert('오류: '+data.message);window.location.href=contextPath+'/pve/stage?level='+META_DATA.stageLevel;}
    });
}

function setupEvents(){
    document.getElementById('nextMatchButton')?.addEventListener('click',function(){this.disabled=true;this.textContent='처리 중…';sendResult(winner(REPLAY_DATA[REPLAY_DATA.length-1]));});
    document.getElementById('myPlayerStatsHeader')?.addEventListener('click',()=>showStatModal('my'));
    document.getElementById('aiPlayerStatsHeader')?.addEventListener('click',()=>showStatModal('ai'));
}

function showStatModal(who){
    const pfx=who==='my'?'myPlayer':'aiPlayer';
    document.getElementById('playerStatDetailTitle').textContent=(MATCHUP_INFO[pfx+'Name']||'선수')+' 스탯';
    const defs=[{k:'Attack',l:'공격',i:'⚔'},{k:'Defense',l:'방어',i:'🛡'},{k:'Macro',l:'운영',i:'🏗'},{k:'Micro',l:'컨트롤',i:'🎯'},{k:'Luck',l:'운',i:'🍀'}];
    let html='<div class="stat-detail-grid">';
    defs.forEach(s=>{const v=MATCHUP_INFO[pfx+s.k]||0,pct=Math.min(100,v);html+='<div class="sdr"><div class="sdr-label">'+s.i+' '+s.l+'</div><div class="sdr-track"><div class="sdr-fill" style="width:'+pct+'%"></div></div><div class="sdr-val">'+v+'</div></div>';});
    html+='</div>';
    document.getElementById('playerStatDetailContent').innerHTML=html;
    document.getElementById('playerStatDetailModal').style.display='flex';
}
function showResultModal(data){
    const tc=data.victory?'var(--green)':'var(--ai)',tt=data.victory?'VICTORY!':'DEFEAT…';
    let html='<div class="result-hero" style="color:'+tc+'">'+tt+'</div><p style="text-align:center;color:var(--text-dim);margin-bottom:1.2rem">'+(data.message||'')+'</p>';
    if(data.playerChanges&&data.playerChanges.length>0){
        data.playerChanges.forEach(p=>{
            const r=(p.rarity||'N').toUpperCase(),rc=r==='UR'?'#ffd600':r==='SSR'?'#ff9800':r==='SR'?'#448aff':r==='R'?'#00e676':'#607d8b';
            html+='<div class="result-block"><div class="rb-head" style="color:'+rc+'">['+r+'] '+p.playerName+'</div><div class="rb-stats">';
            [{k:'Attack',l:'공격'},{k:'Defense',l:'방어'},{k:'Macro',l:'운영'},{k:'Micro',l:'컨트롤'},{k:'Luck',l:'운'}].forEach(s=>{
                const inc=p[s.k.toLowerCase()+'Inc'];
                if(inc!==0){const c=inc>0?'var(--green)':'var(--ai)',a=inc>0?'▲':'▼';html+='<div class="rb-row"><span class="rb-label">'+s.l+'</span><span class="rb-val">'+p['before'+s.k]+' → <strong>'+p['after'+s.k]+'</strong> <span style="color:'+c+'">'+a+Math.abs(inc)+'</span></span></div>';}
            });
            html+='</div></div>';
        });
    }else html+='<p style="text-align:center;color:var(--text-dim)">변동 없음</p>';
    document.getElementById('statChangeContent').innerHTML=html;
    document.getElementById('statChangeModal').style.display='flex';
}
function closeStatModal(){window.location.href=contextPath+'/pve/lobby';}

function initStatPanels(){
    const defs=[{k:'Attack',l:'공격',i:'⚔'},{k:'Defense',l:'방어',i:'🛡'},{k:'Macro',l:'운영',i:'🏗'},{k:'Micro',l:'컨트롤',i:'🎯'},{k:'Luck',l:'운',i:'🍀'}];
    ['my','ai'].forEach(who=>{
        const pfx=who==='my'?'myPlayer':'aiPlayer';
        const panel=document.getElementById(who+'-stat-panel');
        if(!panel)return;
        let html='<div class="fp-sec-label">'+(who==='my'?'📊 스탯':'스탯 📊')+'</div><div class="inline-stat-grid">';
        defs.forEach(s=>{
            const v=MATCHUP_INFO[pfx+s.k]||0,pct=Math.min(100,v);
            html+='<div class="isg-row">'
                +'<span class="isg-label">'+s.i+' '+s.l+'</span>'
                +'<div class="isg-track"><div class="isg-fill" style="width:'+pct+'%"></div></div>'
                +'<span class="isg-val">'+v+'</span>'
                +'</div>';
        });
        html+='</div>';
        panel.innerHTML=html;
    });
}

function initGrids(){
    [['my-building-grid',META_DATA.myRace,'building',false],['my-unit-grid',META_DATA.myRace,'unit',false],
     ['ai-building-grid',META_DATA.aiRace,'building',true],['ai-unit-grid',META_DATA.aiRace,'unit',true]]
    .forEach(([id,race,type,isAi])=>{
        const g=document.getElementById(id);if(!g)return;
        const raceData=(RACE_ENT[race]||RACE_ENT['T']);
        const tiers=raceData[type==='building'?'buildings':'units'];
        g.innerHTML='';
        tiers.forEach(({tier,items})=>{
            const lbl=document.createElement('div');
            lbl.className='tier-label tier-'+tier;
            lbl.textContent={1:'TIER 1',2:'TIER 2',3:'TIER 3'}[tier]||('TIER '+tier);
            g.appendChild(lbl);
            const row=document.createElement('div');
            row.className='tier-row';
            items.forEach(n=>{const c=mkCard(n,isAi,type);c.classList.add('inactive');row.appendChild(c);});
            g.appendChild(row);
        });
    });
}
let prevCnt={};
function updateGrids(counts,queue,isAi,ct){
    const bg=isAi?'ai-building-grid':'my-building-grid',ug=isAi?'ai-unit-grid':'my-unit-grid',pfx=isAi?'ai_':'my_';
    const cm={},pm={};
    queue.forEach(item=>{const r=Math.max(0,item.endTime-ct);if(item.type==='building')cm[item.name]=r;else pm[item.name]=(pm[item.name]||0)+1;});
    [bg,ug].forEach(gid=>{
        document.getElementById(gid)?.querySelectorAll('.entity-card').forEach(card=>{
            const nm=card.dataset.name,cnt=counts[nm]||0,key=pfx+nm,prev=prevCnt[key]??cnt;
            const isCon=cm[nm]!==undefined,isPro=(pm[nm]||0)>0,proCnt=pm[nm]||0;
            const hasAny=cnt>0||isCon;
            card.classList.toggle('inactive',!hasAny);
            card.classList.remove('constructing','producing','idle');
            if(hasAny)card.classList.add(isCon?'constructing':isPro?'producing':'idle');
            const badge=card.querySelector('.entity-count');
            if(badge){
                if(cnt<prev&&prev>0)cntDown(badge,prev,cnt);
                else{badge.textContent=cnt>0?cnt:'';badge.className='entity-count'+(isPro?' producing':'');badge.style.display=cnt>0?'block':'none';}
            }
            const pb=card.querySelector('.entity-producing');if(pb){pb.style.display=isPro?'block':'none';if(isPro)pb.textContent='+'+proCnt;}
            const tb=card.querySelector('.entity-timer');if(tb){tb.style.display=isCon?'block':'none';if(isCon)tb.textContent=cm[nm]+'s';}
            prevCnt[key]=cnt;
        });
    });
}
function mkCard(name,isAi,type){
    const card=document.createElement('div');card.className='entity-card';card.dataset.name=name;card.dataset.type=type;
    const eid=ENT_ID[name]||name,iw=document.createElement('div');iw.className='entity-icon';
    const img=document.createElement('img');img.src=contextPath+'/resources/image/entities/'+eid+'.png';img.alt=name;
    img.onerror=function(){iw.removeChild(img);const fb=document.createElement('span');fb.className='entity-icon-fallback';fb.textContent=name.charAt(0).toUpperCase();iw.appendChild(fb);};
    iw.appendChild(img);card.appendChild(iw);
    const ne=document.createElement('div');ne.className='entity-name';ne.textContent=name;card.appendChild(ne);
    const b=document.createElement('div');b.className='entity-count';b.style.display='none';card.appendChild(b);
    const pb=document.createElement('div');pb.className='entity-producing';pb.style.display='none';card.appendChild(pb);
    const tb=document.createElement('div');tb.className='entity-timer';tb.style.display='none';card.appendChild(tb);
    return card;
}
</script>
</body>
</html>
