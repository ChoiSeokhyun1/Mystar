<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${stageLevel}-${subLevel} 전투 준비 - My Star League</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/pveMatchSetup.css' />">
</head>
<body>

<header class="msl-topbar">
    <div class="msl-topbar-logo">MY STAR <span>LEAGUE</span></div>
    <div class="msl-topbar-center">
        <nav class="msl-breadcrumb">
            <a href="<c:url value='/mode-select' />">홈</a>
            <span class="sep">/</span>
            <a href="<c:url value='/pve/lobby' />">스테이지 목록</a>
            <span class="sep">/</span>
            <a href="<c:url value='/pve/stage?level=${stageLevel}' />">Stage ${stageLevel}</a>
            <span class="sep">/</span>
            <span class="current">${stageLevel}-${subLevel} 전투 준비</span>
        </nav>
    </div>
    <div class="msl-topbar-right">
        <div class="msl-crystal">💎 ${sessionScope.loginUser.crystal}</div>
        <div class="msl-user-label"><strong>${sessionScope.loginUser.userNick}</strong></div>
        <a href="<c:url value='/logout' />" class="msl-btn-nav">LOGOUT</a>
    </div>
</header>

<c:set var="activeMenu" value="pve-lobby" />
<%@ include file="/WEB-INF/views/layout/sideBar.jsp" %>

<main class="msl-main battle-main">

    <div class="msl-page-header msl-animate">
        <div class="msl-page-header-left">
            <div class="msl-page-eyebrow">STAGE ${stageLevel}-${subLevel} · 전투 준비</div>
        </div>
        <div class="msl-page-actions">
            <a href="<c:url value='/pve/stage?level=${stageLevel}' />" class="msl-btn msl-btn-secondary">← 뒤로</a>
            <button class="msl-btn msl-btn-primary" id="startBattleButton" disabled>
                ⚔️ 전투 시작 <span id="readyCount">(0/5)</span>
            </button>
        </div>
    </div>

    <div class="battle-layout msl-animate msl-animate-d1">

        <%-- 1. 왼쪽: 내 팀 엔트리 --%>
        <div class="msl-panel battle-col">
            <div class="squad-list-header">
                <div class="header-left">
                    <span class="h-rarity">등급</span>
                    <span class="h-race">종족</span>
                    <span class="h-name">이름</span>
                </div>
                <div class="header-right">
                    <div class="header-stats">
                        <span class="h-win">승리</span>
                        <span class="h-lose">패배</span>
                        <span class="h-rate">승률</span>
                    </div>
                </div>
            </div>

            <ul class="squad-list-ul" id="myEntryBody">
                <c:choose>
                    <c:when test="${not empty myEntryList}">
                        <c:forEach var="player" items="${myEntryList}">
                            <li class="squad-list-item my-player"
                                data-seq="${player.ownedPlayerSeq}"
                                data-name="${player.playerName}"
                                data-race="${player.race}"
                                data-rarity="${player.currentRarity}"
                                onclick="selectMyPlayer(this)">
                                
                                <div class="list-item-left">
                                    <span class="msl-rarity ${fn:toLowerCase(player.currentRarity)}">${player.currentRarity}</span>
                                    <span class="msl-race ${player.race}">${player.race}</span>
                                    <span class="list-player-name">${player.playerName}</span>
                                </div>
                                <div class="list-item-right">
                                    <div class="list-stats">
                                        <span class="stat-win">${player.wins}승</span>
                                        <span class="stat-lose">${player.losses}패</span>
                                        <span class="stat-rate">${player.winRate}%</span>
                                    </div>
                                </div>
                            </li>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <li class="empty-list">1군 엔트리가 비어있습니다.<br><br><a href="<c:url value='/my-team/entry' />">엔트리 설정하기 →</a></li>
                    </c:otherwise>
                </c:choose>
            </ul>

            <div class="player-detail" id="myPlayerDetail">
                <div class="player-detail-hint" id="myPlayerHint">내 선수를 클릭하여 선택하세요</div>
                <div class="player-detail-content" id="myPlayerContent" style="display:none;"></div>
            </div>
        </div>

        <%-- 2. 가운데: 5세트 맵 배정 --%>
        <div class="msl-panel battle-col-center">
            <div class="msl-panel-head">
                <div class="msl-panel-title">🗺️ 5세트 맵 배정</div>
            </div>
            <div class="msl-panel-body sets-body">
                <ul class="set-list" id="setList">
                    <c:forEach var="map" items="${mapList}" varStatus="status">
                        <c:set var="aiPlayer" value="${aiPlayerMap[map.setNumber]}" />
                        <li class="set-item" data-set-number="${map.setNumber}">
                            <div class="set-header">
                                <span class="set-num">SET ${map.setNumber}</span>
                                <span class="set-map-name">${map.mapName}</span>
                                <div class="set-winrates">
                                    <span class="wr t">T <fmt:formatNumber value="${map.winRateT}" maxFractionDigits="1"/>%</span>
                                    <span class="wr p">P <fmt:formatNumber value="${map.winRateP}" maxFractionDigits="1"/>%</span>
                                    <span class="wr z">Z <fmt:formatNumber value="${map.winRateZ}" maxFractionDigits="1"/>%</span>
                                </div>
                            </div>
                            <div class="set-matchup">
                                <div class="matchup-slot my-slot assignable-slot empty"
                                     data-slot-player-seq=""
                                     data-slot-build-id=""
                                     onclick="onSlotClick(this)">
                                    <span class="slot-hint">← 선수 선택 후 클릭</span>
                                </div>
                                
                                <div class="matchup-vs">VS</div>
                                
                                <c:choose>
                                    <c:when test="${not empty aiPlayer}">
                                        <div class="matchup-slot opp-slot">
                                            <span class="msl-rarity ${fn:toLowerCase(aiPlayer.rarity)}">${aiPlayer.rarity}</span>
                                            <span class="msl-race ${aiPlayer.race}">${aiPlayer.race}</span>
                                            <span class="slot-name">${aiPlayer.playerName}</span>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="matchup-slot opp-slot empty"><span class="slot-hint">상대 미정</span></div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </li>
                    </c:forEach>
                </ul>
            </div>
        </div>

        <%-- 3. 오른쪽: 상대 팀 --%>
        <div class="msl-panel battle-col">
            <div class="squad-list-header">
                <div class="header-left">
                    <span class="h-rarity">등급</span>
                    <span class="h-race">종족</span>
                    <span class="h-name">이름</span>
                </div>
            </div>

            <ul class="squad-list-ul">
                <c:forEach var="player" items="${opponentEntryList}">
                    <li class="squad-list-item opp-player"
                        data-seq="${player.playerSeq}"
                        onclick="selectOppPlayer(this)">
                        
                        <div class="list-item-left">
                            <span class="msl-rarity ${fn:toLowerCase(player.rarity)}">${player.rarity}</span>
                            <span class="msl-race ${player.race}">${player.race}</span>
                            <span class="list-player-name">${player.playerName}</span>
                        </div>
                    </li>
                </c:forEach>
            </ul>

            <div class="player-detail" id="oppPlayerDetail">
                <div class="player-detail-hint" id="oppPlayerHint">상대 선수를 클릭해 정보 확인</div>
                <div class="player-detail-content" id="oppPlayerContent" style="display:none;"></div>
            </div>
        </div>

    </div>
</main>

<%-- 전략 선택 모달 --%>
<div class="battle-modal-overlay" id="buildSelectModal" style="display:none;">
    <div class="battle-modal">
        <div class="battle-modal-head">
            <div class="battle-modal-title">📜 전략 선택</div>
            <div class="battle-modal-sub" id="modalRaceInfo"></div>
        </div>
        <div class="battle-modal-body">
            <p class="modal-desc">선택한 선수에게 부여할 맞춤 전략을 선택하세요.</p>
            <ul id="modalBuildList"></ul>
        </div>
        <div class="battle-modal-foot">
            <button class="msl-btn msl-btn-secondary" id="closeBuildModal">취소</button>
        </div>
    </div>
</div>

<%-- 전투 폼 --%>
<form id="battleStartForm" method="POST" action="<c:url value='/pve/battle/start' />" style="display:none;">
    <input type="hidden" name="level"    value="${stageLevel}">
    <input type="hidden" name="subLevel" value="${subLevel}">
    <c:forEach var="i" begin="1" end="5">
        <input type="hidden" name="set${i}Player" id="set${i}Player">
        <input type="hidden" name="set${i}Build"  id="set${i}Build">
    </c:forEach>
</form>

<script>
    // 빌드 리스트
    const myBuilds = [
        <c:forEach var="build" items="${myBuilds}" varStatus="s">
            { id:"${build.buildId}", name:"${fn:escapeXml(build.buildName)}", race:"${build.race}", vsRace:"${build.vsRace}", playStyle:"${build.playStyle}", harassStyle:"${build.harassStyle}" }<c:if test="${!s.last}">,</c:if>
        </c:forEach>
    ];

    // ★ JS 에러(Syntax Error) 원천 차단: 모든 EL 태그를 "" 따옴표로 감싸서 문자열로 처리
    const myPlayerData = {
        <c:forEach var="p" items="${myEntryList}" varStatus="s">
            "${p.ownedPlayerSeq}": {
                name: "${fn:escapeXml(p.playerName)}", race: "${p.race}", rarity: "${p.currentRarity}",
                atk: "${p.currentAttack}", def: "${p.currentDefense}", mac: "${p.currentMacro}", mic: "${p.currentMicro}", luk: "${p.currentLuck}"
            }<c:if test="${!s.last}">,</c:if>
        </c:forEach>
    };

    // 상대 데이터도 기존에 작동했던 statAttack을 안전하게 문자열로 매핑
    const oppPlayerData = {
        <c:forEach var="p" items="${opponentEntryList}" varStatus="s">
            "${p.playerSeq}": {
                name: "${fn:escapeXml(p.playerName)}", race: "${p.race}", rarity: "${p.rarity}",
                atk: "${p.statAttack}", def: "${p.statDefense}", mac: "${p.statMacro}", mic: "${p.statMicro}", luk: "${p.statLuck}"
            }<c:if test="${!s.last}">,</c:if>
        </c:forEach>
    };

    let selectedMyPlayerEl = null;
    let currentTargetSlot  = null;

    /* ── 1. 내 선수 클릭 ── */
    function selectMyPlayer(el) {
        if (el.classList.contains('used')) return;
        
        if (selectedMyPlayerEl) selectedMyPlayerEl.classList.remove('selected');
        selectedMyPlayerEl = (el === selectedMyPlayerEl) ? null : el;
        
        if (selectedMyPlayerEl) {
            selectedMyPlayerEl.classList.add('selected');
            renderPlayerDetail('my', selectedMyPlayerEl.dataset.seq);
        } else {
            showDetailHint('my');
        }
    }

    /* ── 2. 상대 선수 클릭 ── */
    function selectOppPlayer(el) {
        document.querySelectorAll('.squad-list-item.opp-player').forEach(i => i.classList.remove('selected'));
        el.classList.add('selected');
        renderPlayerDetail('opp', el.dataset.seq);
    }

    function renderPlayerDetail(side, seq) {
        const data = side === 'my' ? myPlayerData[seq] : oppPlayerData[seq];
        const hint    = document.getElementById(side === 'my' ? 'myPlayerHint'    : 'oppPlayerHint');
        const content = document.getElementById(side === 'my' ? 'myPlayerContent' : 'oppPlayerContent');
        if (!data) return;
        
        hint.style.display    = 'none';
        content.style.display = 'block';
        const rarityClass = data.rarity ? data.rarity.toLowerCase() : '';
        
        // 빈 값이면 0 출력 처리 (data.atk || 0)
        content.innerHTML =
            '<div class="detail-header">' +
                '<span class="msl-rarity ' + rarityClass + '">' + data.rarity + '</span>' +
                '<span class="msl-race '   + data.race   + '">' + data.race   + '</span>' +
                '<span class="detail-name">' + data.name + '</span>' +
            '</div>' +
            '<div class="detail-stats">' +
                '<div class="stat-cell"><div class="stat-label">ATK</div><div class="stat-val">' + (data.atk || 0) + '</div></div>' +
                '<div class="stat-cell"><div class="stat-label">DEF</div><div class="stat-val">' + (data.def || 0) + '</div></div>' +
                '<div class="stat-cell"><div class="stat-label">MAC</div><div class="stat-val">' + (data.mac || 0) + '</div></div>' +
                '<div class="stat-cell"><div class="stat-label">MIC</div><div class="stat-val">' + (data.mic || 0) + '</div></div>' +
                '<div class="stat-cell"><div class="stat-label">LUK</div><div class="stat-val">' + (data.luk || 0) + '</div></div>' +
            '</div>';
    }

    function showDetailHint(side) {
        document.getElementById(side === 'my' ? 'myPlayerHint'    : 'oppPlayerHint').style.display    = 'block';
        document.getElementById(side === 'my' ? 'myPlayerContent' : 'oppPlayerContent').style.display = 'none';
    }

    /* ── 3. 슬롯 클릭 (매치업 배정) ── */
    function onSlotClick(slot) {
        if (!slot.classList.contains('empty')) {
            const removedSeq = slot.dataset.slotPlayerSeq;
            slot.classList.add('empty');
            slot.dataset.slotPlayerSeq = '';
            slot.dataset.slotBuildId   = '';
            slot.innerHTML = '<span class="slot-hint">← 선수 선택 후 클릭</span>';
            
            const el = document.querySelector('.squad-list-item.my-player[data-seq="' + removedSeq + '"]');
            if (el) el.classList.remove('used');
            updateReady();
            return;
        }
        
        if (!selectedMyPlayerEl) {
            alert('좌측에서 매치업에 출전시킬 선수를 먼저 클릭해주세요!');
            return;
        }

        currentTargetSlot = slot;
        const myRace = selectedMyPlayerEl.dataset.race;
        const filtered = myBuilds.filter(b => b.race === myRace);

        const list = document.getElementById('modalBuildList');
        document.getElementById('modalRaceInfo').textContent = '선택된 선수: ' + selectedMyPlayerEl.dataset.name + ' (' + myRace + ')';
        list.innerHTML = '';
        
        if (filtered.length === 0) {
            list.innerHTML = '<li class="modal-empty">사용 가능한 전략이 없습니다.<br>전략 수립 메뉴에서 먼저 전략을 생성하세요.</li>';
        } else {
            filtered.forEach(b => {
                const li = document.createElement('li');
                li.className = 'modal-build-item';
                li.innerHTML =
                    '<div class="modal-build-info">' +
                        '<div class="modal-build-name">' + b.name + '</div>' +
                        '<div class="modal-build-sub">vs ' + b.vsRace + ' · ' + localizePlayStyle(b.playStyle) + ' · ' + localizeHarassStyle(b.harassStyle) + '</div>' +
                    '</div>' +
                    '<button class="msl-btn msl-btn-primary modal-select-btn">선택</button>';
                li.querySelector('.modal-select-btn').addEventListener('click', () => assignSlot(slot, b));
                list.appendChild(li);
            });
        }
        document.getElementById('buildSelectModal').style.display = 'flex';
    }

    /* ── 스타일 한글 변환 헬퍼 ── */
    function localizePlayStyle(s) {
        const map = { AGGRESSIVE: '공격스타일', NORMAL: '일반스타일', DEFENSIVE: '수비스타일' };
        return map[s] || s || '일반스타일';
    }
    function localizeHarassStyle(s) {
        const map = { NO_HARASS: '견제없음', NORMAL_HARASS: '일반견제', HEAVY_HARASS: '강한견제' };
        return map[s] || s || '일반견제';
    }

    /* ── 4. 모달에서 전략 선택 후 실제 배정 ── */
    function assignSlot(slot, build) {
        const p = selectedMyPlayerEl.dataset;
        const ownedSeq = p.seq;
        
        slot.classList.remove('empty');
        slot.dataset.slotPlayerSeq = ownedSeq;
        slot.dataset.slotBuildId   = build.id;
        
        const rarityClass = p.rarity ? p.rarity.toLowerCase() : '';
        slot.innerHTML =
            '<span class="msl-rarity ' + rarityClass + '">' + p.rarity + '</span>' +
            '<span class="msl-race '   + p.race      + '">' + p.race   + '</span>' +
            '<span class="slot-name">' + p.name + '</span>' +
            '<span class="slot-build">⚙ ' + build.name + '</span>';

        selectedMyPlayerEl.classList.add('used');
        selectedMyPlayerEl.classList.remove('selected');
        selectedMyPlayerEl = null;
        showDetailHint('my');
        
        document.getElementById('buildSelectModal').style.display = 'none';
        currentTargetSlot = null;
        updateReady();
    }

    document.getElementById('closeBuildModal').addEventListener('click', () => {
        document.getElementById('buildSelectModal').style.display = 'none';
        currentTargetSlot = null;
    });

    /* ── 5. 출격 가능 여부 검사 ── */
    function updateReady() {
        const assigned = document.querySelectorAll('.assignable-slot:not(.empty)').length;
        const btn = document.getElementById('startBattleButton');
        document.getElementById('readyCount').textContent = '(' + assigned + '/5)';
        btn.disabled = assigned !== 5;
    }

    document.getElementById('startBattleButton').addEventListener('click', function() {
        if (this.disabled) return;
        document.querySelectorAll('.assignable-slot').forEach((slot, idx) => {
            document.getElementById('set' + (idx+1) + 'Player').value = slot.dataset.slotPlayerSeq;
            document.getElementById('set' + (idx+1) + 'Build').value  = slot.dataset.slotBuildId;
        });
        document.getElementById('battleStartForm').submit();
    });
</script>

</body>
</html>