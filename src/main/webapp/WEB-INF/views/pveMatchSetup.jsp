<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>전술 배치 - My Star League</title>

    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/pveMatchSetup.css' />">
    <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@400;600;700;800;900&family=Barlow:wght@300;400;500;600&display=swap" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>

<header class="msl-topbar">
    <div class="msl-topbar-logo">MY STAR <span>LEAGUE</span></div>
    <div class="msl-topbar-center">
        <nav class="msl-breadcrumb">
            <a href="<c:url value='/mode-select' />">홈</a>
            <span class="sep">/</span>
            <a href="<c:url value='/pve/lobby' />">PVE 시나리오</a>
            <span class="sep">/</span>
            <span class="current">전술 배치</span>
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

<main class="msl-main">

<form id="battleForm" action="<c:url value='/pve/battle/start' />" method="post">
        <input type="hidden" name="level"    value="${stageLevel}">
        <input type="hidden" name="subLevel" value="${subLevel}">
        
        <input type="hidden" name="set1Player" id="hidden_p1" value="">
        <input type="hidden" name="set2Player" id="hidden_p2" value="">
        <input type="hidden" name="set3Player" id="hidden_p3" value="">
        
        <input type="hidden" name="p4" id="hidden_p4" value="">
        <input type="hidden" name="p5" id="hidden_p5" value="">
        <input type="hidden" name="p6" id="hidden_p6" value="">
        <input type="hidden" name="p7" id="hidden_p7" value="">
        <input type="hidden" name="p8" id="hidden_p8" value="">
        <input type="hidden" name="p9" id="hidden_p9" value="">
    </form>

    <div class="match-layout">

        <div class="match-header">
            <div>
                <div class="match-eyebrow">TACTICAL SETUP · 3v3 · BO3</div>
                <div class="match-title">전술 배치</div>
                <div class="match-subtitle">3개 세트에 출전할 9명의 선수를 중복 없이 배치하세요</div>
            </div>
            
            <div class="match-header-right">
                <div class="placement-progress">
                    <span class="progress-label">배치 현황</span>
                    <div class="progress-dots">
                        <c:forEach var="i" begin="1" end="9">
                            <div class="progress-dot" id="dot_${i}"></div>
                        </c:forEach>
                    </div>
                </div>
                <button class="start-btn-new" id="startBtn" disabled onclick="submitBattle()">
                    ⚔ 전투 개시 (0/9)
                </button>
            </div>
        </div>

        <div class="pool-panel">
            <div class="pool-header">
                <span class="pool-title">내 선수단</span>
                <span class="pool-count">
                    <span class="available" id="availableCount">${fn:length(myEntryList)}</span> / ${fn:length(myEntryList)}
                </span>
            </div>
            <div class="pool-filter">
                <button class="filter-btn f-all active" onclick="filterPool('all', this, 'poolList')">ALL</button>
                <button class="filter-btn f-T"          onclick="filterPool('T',   this, 'poolList')">테란</button>
                <button class="filter-btn f-P"          onclick="filterPool('P',   this, 'poolList')">프토</button>
                <button class="filter-btn f-Z"          onclick="filterPool('Z',   this, 'poolList')">저그</button>
            </div>
            <div class="pool-list" id="poolList">
                <c:forEach var="my" items="${myEntryList}">
                    <c:set var="condVal"   value="${empty my.condition ? 'NORMAL' : my.condition}" />
                    <c:set var="condLabel" value="${condVal == 'PEAK' ? '최상' : condVal == 'GOOD' ? '양호' : condVal == 'NORMAL' ? '보통' : condVal == 'TIRED' ? '피로' : '최악'}" />
                    
                    <%-- [수정] DTO 새 이름 적용 --%>
                    <c:set var="sAtk"  value="${my.totalAttack}"  />
                    <c:set var="sDef"  value="${my.totalDefense}" />
                    <c:set var="sHp"   value="${my.totalHp}"      />
                    <c:set var="sHrss" value="${my.totalHarass}"  />
                    <c:set var="sSpd"  value="${my.totalSpeed}"   />

                    <div class="player-card"
                         id="card_${my.ownedPlayerSeq}"
                         data-seq="${my.ownedPlayerSeq}"
                         data-race="${my.race}"
                         data-name="${my.playerName}"
                         data-atk="${sAtk}"
                         data-def="${sDef}"
                         data-hp="${sHp}"
                         data-hrss="${sHrss}"
                         data-spd="${sSpd}"
                         style="--race-color: var(--${my.race == 'T' ? 't' : my.race == 'P' ? 'p' : 'z'}-color)"
                         onclick="assignPlayer(this)">

                        <div class="card-header-row">
                            <span class="card-race-badge ${my.race}">${my.race}</span>
                            <span class="card-name">${my.playerName}</span>
                            <c:if test="${my.enhanceLevel > 0}">
                                <span class="card-enhance">+${my.enhanceLevel}</span>
                            </c:if>
                            <span class="card-rarity ${my.currentRarity}">${my.currentRarity}</span>
                            <span class="card-condition ${condVal}">${condLabel}</span>
                            <c:if test="${my.winStreak >= 2}">
                                <span class="card-winstreak">🔥${my.winStreak}연승</span>
                            </c:if>
                        </div>

                        <div class="card-stats">
                            <div class="stat-row">
                                <span class="stat-label">공격</span>
                                <div class="stat-bar"><div class="stat-fill" style="width:${sAtk > 100 ? 100 : sAtk}%;background:#ef5350;"></div></div>
                                <span class="stat-val">${sAtk}</span>
                            </div>
                            <div class="stat-row">
                                <span class="stat-label">방어</span>
                                <div class="stat-bar"><div class="stat-fill" style="width:${sDef > 100 ? 100 : sDef}%;background:#448aff;"></div></div>
                                <span class="stat-val">${sDef}</span>
                            </div>
                            <div class="stat-row">
                                <span class="stat-label">체력</span>
                                <div class="stat-bar"><div class="stat-fill" style="width:${sHp > 100 ? 100 : sHp}%;background:#00e676;"></div></div>
                                <span class="stat-val">${sHp}</span>
                            </div>
                            <div class="stat-row">
                                <span class="stat-label">방해</span>
                                <div class="stat-bar"><div class="stat-fill" style="width:${sHrss > 100 ? 100 : sHrss}%;background:#ff6d00;"></div></div>
                                <span class="stat-val">${sHrss}</span>
                            </div>
                            <div class="stat-row">
                                <span class="stat-label">스피드</span>
                                <div class="stat-bar"><div class="stat-fill" style="width:${sSpd > 100 ? 100 : sSpd}%;background:#ffd600;"></div></div>
                                <span class="stat-val">${sSpd}</span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>

        <div class="board-panel">

            <c:forEach var="setIndex" begin="1" end="3">
                <div class="set-block" id="setBlock_${setIndex}">
                    <div class="set-label">
                        <span class="set-number">SET ${setIndex}</span>
                        <span class="set-status" id="setStatus_${setIndex}">0 / 3 배치 완료</span>
                        <span class="set-vs-badge">${myTeamName} VS ${opponentTeamName}</span>
                    </div>
                    <div class="matchup-grid">

                        <div class="team-col-new">
                            <c:forEach var="slot" begin="1" end="3">
                                <c:set var="gSlot" value="${(setIndex-1)*3 + slot}" />
                                <div class="battle-slot my-slot"
                                     id="slot_${gSlot}"
                                     data-gslot="${gSlot}"
                                     data-set="${setIndex}"
                                     onclick="activateSlot(this)">
                                    <div class="slot-empty-display">
                                        <span class="slot-index">P${slot}</span>
                                        <span class="slot-empty-label">선수 미배치</span>
                                        <span class="slot-click-hint">← 클릭</span>
                                    </div>
                                    <span class="slot-remove-hint">✕</span>
                                </div>
                            </c:forEach>
                        </div>

                        <div class="vs-divider">
                            <div class="vs-line"></div>
                            <span class="vs-text">VS</span>
                            <div class="vs-line"></div>
                        </div>

                        <div class="team-col-new">
                            <c:forEach var="slot" begin="1" end="3">
                                <c:set var="gSlot" value="${(setIndex-1)*3 + slot}" />
                                <div class="battle-slot opp-slot">
                                    <div class="slot-filled-display">
                                        <c:choose>
                                            <c:when test="${not empty aiPlayerMap[gSlot]}">
                                                <c:set var="ai" value="${aiPlayerMap[gSlot]}" />
                                                <span class="filled-race ${ai.race}">${ai.race}</span>
                                                <span class="filled-name">${ai.playerName}</span>
                                                <div class="filled-stats-mini">
                                                    <span class="stat-chip"><strong>${ai.statAttack}</strong>공격</span>
                                                    <span class="stat-chip"><strong>${ai.statDefense}</strong>방어</span>
                                                    <%-- [수정] DTO 새 이름 적용 --%>
                                                    <span class="stat-chip"><strong>${ai.statHp}</strong>체력</span>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="slot-index">E${slot}</span>
                                                <span class="slot-empty-label" style="color:rgba(244,63,94,0.3);">AI 미배정</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                    </div>
                </div>
            </c:forEach>

        </div>

        <div class="ai-pool-panel">
            <div class="pool-header">
                <span class="pool-title">${opponentTeamName}</span>
                <span class="pool-count">${fn:length(opponentEntryList)}명</span>
            </div>
            <div class="pool-filter">
                <button class="filter-btn f-all active" onclick="filterPool('all', this, 'aiPoolList')">ALL</button>
                <button class="filter-btn f-T"          onclick="filterPool('T',   this, 'aiPoolList')">테란</button>
                <button class="filter-btn f-P"          onclick="filterPool('P',   this, 'aiPoolList')">프토</button>
                <button class="filter-btn f-Z"          onclick="filterPool('Z',   this, 'aiPoolList')">저그</button>
            </div>
            <div class="pool-list" id="aiPoolList">
                <c:forEach var="ai" items="${opponentEntryList}">
                    <div class="player-card ai-card"
                         data-race="${ai.race}"
                         style="--race-color: var(--${ai.race == 'T' ? 't' : ai.race == 'P' ? 'p' : 'z'}-color)">

                        <div class="card-header-row">
                            <span class="card-race-badge ${ai.race}">${ai.race}</span>
                            <span class="card-name">${ai.playerName}</span>
                            <span class="card-rarity ${ai.rarity}">${ai.rarity}</span>
                            <c:choose>
                                <c:when test="${ai.setNumber > 0}">
                                    <span class="card-winstreak" style="color:var(--gold);">SET ${(ai.setNumber - 1) / 3 + 1}·P${((ai.setNumber - 1) mod 3) + 1}</span>
                                </c:when>
                                <c:otherwise>
                                    <span style="font-family:'Barlow Condensed',sans-serif;font-size:10px;color:var(--text-dim);flex-shrink:0;">벤치</span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="card-stats">
                            <div class="stat-row">
                                <span class="stat-label">공격</span>
                                <div class="stat-bar"><div class="stat-fill" style="width:${ai.statAttack > 100 ? 100 : ai.statAttack}%;background:#ef5350;"></div></div>
                                <span class="stat-val">${ai.statAttack}</span>
                            </div>
                            <div class="stat-row">
                                <span class="stat-label">방어</span>
                                <div class="stat-bar"><div class="stat-fill" style="width:${ai.statDefense > 100 ? 100 : ai.statDefense}%;background:#448aff;"></div></div>
                                <span class="stat-val">${ai.statDefense}</span>
                            </div>
                            <%-- [수정] DTO 새 이름 적용 --%>
                            <div class="stat-row">
                                <span class="stat-label">체력</span>
                                <div class="stat-bar"><div class="stat-fill" style="width:${ai.statHp > 100 ? 100 : ai.statHp}%;background:#00e676;"></div></div>
                                <span class="stat-val">${ai.statHp}</span>
                            </div>
                            <div class="stat-row">
                                <span class="stat-label">방해</span>
                                <div class="stat-bar"><div class="stat-fill" style="width:${ai.statHarass > 100 ? 100 : ai.statHarass}%;background:#ff6d00;"></div></div>
                                <span class="stat-val">${ai.statHarass}</span>
                            </div>
                            <div class="stat-row">
                                <span class="stat-label">스피드</span>
                                <div class="stat-bar"><div class="stat-fill" style="width:${ai.statSpeed > 100 ? 100 : ai.statSpeed}%;background:#ffd600;"></div></div>
                                <span class="stat-val">${ai.statSpeed}</span>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>

    </div><div class="select-hint" id="selectHint">선수 카드를 클릭하여 배치하세요</div>

</main>

<script>
$(function() {
    var activeSlot  = null;
    var assignments = {};
    var hintTimeout = null;

    // ── 슬롯 활성화 ──
    window.activateSlot = function(slotEl) {
        var gSlot = parseInt($(slotEl).data('gslot'));
        if (assignments[gSlot]) { removeAssignment(gSlot); return; }
        if (activeSlot === slotEl) { $(slotEl).removeClass('active-slot'); activeSlot = null; hideHint(); return; }
        if (activeSlot) $(activeSlot).removeClass('active-slot');
        activeSlot = slotEl;
        $(slotEl).addClass('active-slot');
        showHint('선수 카드를 클릭하여 배치하세요');
    };

    // ── 선수 카드 클릭 → 배치 ──
    window.assignPlayer = function(cardEl) {
        if ($(cardEl).hasClass('used')) return;
        var seq  = $(cardEl).data('seq');
        var name = $(cardEl).data('name');
        var race = $(cardEl).data('race');
        var atk  = $(cardEl).data('atk');
        var def  = $(cardEl).data('def');
        var hp   = $(cardEl).data('hp');
        var spd  = $(cardEl).data('spd');

        if (!activeSlot) {
            for (var g = 1; g <= 9; g++) { if (!assignments[g]) { activeSlot = $('#slot_' + g)[0]; break; } }
            if (!activeSlot) { showHint('모든 슬롯이 채워졌습니다'); return; }
        }

        var gSlot = parseInt($(activeSlot).data('gslot'));
        assignments[gSlot] = { seq: seq, name: name, race: race, atk: atk, def: def, hp: hp, spd: spd };
        $('#hidden_p' + gSlot).val(seq);
        renderSlot(gSlot);
        $(cardEl).addClass('used');
        $(activeSlot).removeClass('active-slot');
        activeSlot = null;
        updateAll();
        hideHint();
    };

    // ── 배치 해제 ──
    function removeAssignment(gSlot) {
        var a = assignments[gSlot];
        if (!a) return;
        $('#card_' + a.seq).removeClass('used');
        delete assignments[gSlot];
        $('#hidden_p' + gSlot).val('');
        renderSlot(gSlot);
        if (activeSlot) { $(activeSlot).removeClass('active-slot'); activeSlot = null; }
        updateAll();
    }

    // ── 슬롯 렌더 ──
    function renderSlot(gSlot) {
        var $slot   = $('#slot_' + gSlot);
        var setIdx  = $slot.data('set');
        var slotIdx = gSlot - (setIdx - 1) * 3;
        var a = assignments[gSlot];
        if (a) {
            $slot.addClass('filled').removeClass('active-slot');
            $slot.find('.slot-empty-display').replaceWith(
                '<div class="slot-filled-display">' +
                  '<span class="slot-index">P' + slotIdx + '</span>' +
                  '<span class="filled-race ' + a.race + '">' + a.race + '</span>' +
                  '<span class="filled-name">' + a.name + '</span>' +
                  '<div class="filled-stats-mini">' +
                    '<span class="stat-chip"><strong>' + a.atk + '</strong>공격</span>' +
                    '<span class="stat-chip"><strong>' + a.def + '</strong>방어</span>' +
                    '<span class="stat-chip"><strong>' + a.hp  + '</strong>체력</span>' +
                  '</div>' +
                '</div>'
            );
        } else {
            $slot.removeClass('filled active-slot');
            $slot.find('.slot-filled-display').replaceWith(
                '<div class="slot-empty-display">' +
                  '<span class="slot-index">P' + slotIdx + '</span>' +
                  '<span class="slot-empty-label">선수 미배치</span>' +
                  '<span class="slot-click-hint">← 클릭</span>' +
                '</div>'
            );
        }
    }

    // ── 전체 UI 갱신 ──
    function updateAll() {
        var total = Object.keys(assignments).length;
        var all   = parseInt('${fn:length(myEntryList)}');

        for (var g = 1; g <= 9; g++) {
            if (assignments[g]) $('#dot_' + g).addClass('filled');
            else                 $('#dot_' + g).removeClass('filled');
        }
        $('#availableCount').text(all - total);
        
        for (var s = 1; s <= 3; s++) {
            var cnt = 0;
            for (var sl = 1; sl <= 3; sl++) { if (assignments[(s-1)*3 + sl]) cnt++; }
            var $st = $('#setStatus_' + s);
            $st.text(cnt + ' / 3 배치 완료');
            cnt === 3 ? $st.addClass('complete') : $st.removeClass('complete');
            (cnt > 0 && cnt < 3) ? $('#setBlock_' + s).addClass('has-active') : $('#setBlock_' + s).removeClass('has-active');
        }

        // [수정] 상단 버튼 텍스트 업데이트 로직 변경
        if (total === 9) {
            $('#startBtn').prop('disabled', false).text('⚔ 전투 개시 — SIMULATE').addClass('ready');
        } else {
            $('#startBtn').prop('disabled', true).text('⚔ 전투 개시 (' + total + '/9)').removeClass('ready');
        }
    }

    // ── 풀 필터 (좌/우 구분) ──
    window.filterPool = function(race, btn, listId) {
        $(btn).closest('.pool-filter').find('.filter-btn').removeClass('active');
        $(btn).addClass('active');
        $('#' + listId + ' .player-card').each(function() {
            $(this).css('display', (race === 'all' || $(this).data('race') === race) ? '' : 'none');
        });
    };

    window.submitBattle = function() {
        if (Object.keys(assignments).length < 9) return;
        $('#battleForm').submit();
    };

    function showHint(msg) {
        clearTimeout(hintTimeout);
        $('#selectHint').text(msg).addClass('visible');
    }
    function hideHint() {
        hintTimeout = setTimeout(function() { $('#selectHint').removeClass('visible'); }, 1500);
    }
});
</script>
</body>
</html>