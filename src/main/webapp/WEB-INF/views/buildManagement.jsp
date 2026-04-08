<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>전략 수립 - My Star League</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/build_Management.css' />">
</head>
<body>

<header class="msl-topbar">
    <div class="msl-topbar-logo">MY STAR <span>LEAGUE</span></div>
    <div class="msl-topbar-center">
        <nav class="msl-breadcrumb">
            <a href="<c:url value='/mode-select' />">홈</a>
            <span class="sep">/</span>
            <span class="current">전략 수립</span>
        </nav>
    </div>
    <div class="msl-topbar-right">
        <div class="msl-crystal">💎 ${sessionScope.loginUser.crystal}</div>
        <div class="msl-user-label"><strong>${sessionScope.loginUser.userNick}</strong></div>
        <a href="<c:url value='/logout' />" class="msl-btn-nav">LOGOUT</a>
    </div>
</header>

<c:set var="activeMenu" value="build" />
<%@ include file="/WEB-INF/views/layout/sideBar.jsp" %>

<main class="msl-main">

    <header class="msl-page-header msl-animate">
        <div class="msl-page-header-left">
            <div class="msl-page-eyebrow">STRATEGY MANAGEMENT</div>
            <div class="msl-page-title">전략 수립</div>
            <div class="msl-page-sub">선수들에게 부여할 종족별 맞춤 빌드와 운영 방식을 설정하세요.</div>
        </div>
        <div class="msl-page-actions">
            <a href="<c:url value='/build/create' />" class="msl-btn msl-btn-primary">➕ 새 전략 생성</a>
        </div>
    </header>

    <div class="build-grid msl-animate msl-animate-d1">
        
        <div class="msl-panel">
            <div class="build-toolbar">
                <div class="filter-row">
                    <span class="filter-label">MY RACE</span>
                    <div class="filter-group">
                        <button class="filter-btn active" onclick="setMyRaceFilter('ALL', this)">ALL</button>
                        <button class="filter-btn" onclick="setMyRaceFilter('T', this)">T</button>
                        <button class="filter-btn" onclick="setMyRaceFilter('P', this)">P</button>
                        <button class="filter-btn" onclick="setMyRaceFilter('Z', this)">Z</button>
                    </div>
                </div>
                <div class="filter-row">
                    <span class="filter-label">VS RACE</span>
                    <div class="filter-group">
                        <button class="filter-btn active" onclick="setVsRaceFilter('ALL', this)">ALL</button>
                        <button class="filter-btn" onclick="setVsRaceFilter('T', this)">vs T</button>
                        <button class="filter-btn" onclick="setVsRaceFilter('P', this)">vs P</button>
                        <button class="filter-btn" onclick="setVsRaceFilter('Z', this)">vs Z</button>
                    </div>
                </div>
            </div>

            <div class="build-list-header">
                <span class="b-col-race">종족</span>
                <span class="b-col-vs">상대</span>
                <span class="b-col-name">전략 이름</span>
                <span class="b-col-win">승리</span>
                <span class="b-col-lose">패배</span>
                <span class="b-col-rate">승률</span>
            </div>

            <div class="msl-panel-body">
                <ul class="build-list-ul" id="buildList">
                    <c:choose>
                        <c:when test="${empty myBuilds}">
                            <li class="empty-list">생성된 전략이 없습니다.<br>우측 상단의 버튼을 눌러 새 전략을 만드세요.</li>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="build" items="${myBuilds}">
                                <li class="build-list-item" 
                                    data-build-id="${build.buildId}" 
                                    data-race="${build.race}" 
                                    data-vs-race="${build.vsRace}"
                                    onclick="loadBuildDetail(this, ${build.buildId})">
                                    <span class="msl-race ${build.race} b-col-race">${build.race}</span>
                                    <span class="vs-badge b-col-vs">vs ${build.vsRace == 'A' ? 'ALL' : build.vsRace}</span>
                                    <span class="build-name b-col-name">${build.buildName}</span>
                                    <span class="b-col-win">${build.winCount}</span>
                                    <span class="b-col-lose">${build.loseCount}</span>
                                    <span class="b-col-rate">
                                        <c:choose>
                                            <c:when test="${build.winCount + build.loseCount > 0}">
                                                <fmt:formatNumber value="${build.winCount * 100.0 / (build.winCount + build.loseCount)}" maxFractionDigits="0" />%
                                            </c:when>
                                            <c:otherwise>-</c:otherwise>
                                        </c:choose>
                                    </span>
                                </li>
                            </c:forEach>
                            <li id="noFilterResult" class="empty-list" style="display:none;">조건에 맞는 전략이 없습니다.</li>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </div>
        </div>

        <div class="msl-panel detail-panel">
            <div class="msl-panel-body" id="cardPlaceholder">
                <div class="placeholder-icon">👈</div>
                <p>좌측 목록에서 전략을 선택해주세요.</p>
            </div>
            
            <div class="msl-panel-body detail-body" id="cardContent" style="display:none;">
                <!-- 헤더: 이름 + 종족vs종족 한 줄 + 생성일 + 버튼 -->
                <div class="dt-header">
                    <div class="dt-header-left">
                        <div class="dt-header-inline">
                            <span class="dt-matchup" id="dtMatchup"></span>
                            <h2 class="dt-name" id="dtBuildName"></h2>
                            <span class="dt-created" id="dtCreated"></span>
                        </div>
                    </div>
                    <div class="dt-header-actions">
                        <button class="msl-btn msl-btn-secondary" id="btnEditBuild">✏️ 수정</button>
                        <button class="msl-btn msl-btn-danger" id="btnDeleteBuild">🗑️ 삭제</button>
                    </div>
                </div>

                <!-- 작전 성향 + 선호 유닛 + 선호 건물: 통합 섹션 -->
                <div class="dt-unified-section">
                    <div class="dt-unified-title">작전 성향 &amp; 선호 구성</div>

                    <div class="dt-tendency-inline">
                        <span class="t-badge t-badge-play" id="dtPlayStyle"></span>
                        <span class="dt-tend-sep">·</span>
                        <span class="t-badge t-badge-harass" id="dtHarassStyle"></span>
                        <span class="dt-tend-sep">·</span>
                        <span class="t-badge t-badge-agg" id="dtAggression"></span>
                        <span class="dt-tend-sep">·</span>
                        <span class="t-badge t-badge-agg" id="dtMaxBases"></span>
                        <span class="dt-tend-sep">·</span>
                        <span class="t-badge t-badge-agg" id="dtFocusTime"></span>
                    </div>

                    <div class="dt-pref-columns">
                        <div class="dt-pref-col">
                            <div class="dt-sub-title">선호 유닛</div>
                            <div class="dt-pref-list" id="dtPreferredUnits">
                                <span class="dt-empty">선호 유닛 없음</span>
                            </div>
                        </div>
                        <div class="dt-pref-col">
                            <div class="dt-sub-title">선호 건물</div>
                            <div class="dt-pref-list" id="dtPreferredBuildings">
                                <span class="dt-empty">선호 건물 없음</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 빌드 분석 -->
                <div class="dt-section">
                    <div class="dt-section-title">빌드 분석</div>
                    <div class="dt-analysis" id="dtAnalysis">
                        <span class="dt-empty">유닛 정보가 있으면 분석이 표시됩니다.</span>
                    </div>
                </div>
            </div>
        </div>

    </div> </main>

<script>
    const CTX = '${pageContext.request.contextPath}';
    let currentMyRace = 'ALL';
    let currentVsRace = 'ALL';

    const UNIT_DATA_FLAT = {
        marine:'마린', firebat:'파이어뱃', medic:'메딕', vulture:'벌처',
        tank:'탱크', goliath:'골리앗', wraith:'레이스', ghost:'고스트',
        vessel:'베슬', battlecruiser:'배틀크루저',
        zergling:'저글링', hydralisk:'히드라리스크', mutalisk:'뮤탈리스크', lurker:'러커',
        zealot:'질럿', dragoon:'드라군', dark_templar:'다크템플러',
        reaver:'리버', high_templar:'하이템플러', corsair:'커세어', carrier:'캐리어'
    };
    const UNIT_EMOJI = {
        marine:'🪖', firebat:'🔥', medic:'💊', vulture:'🏍️', tank:'🛡️',
        goliath:'🤖', wraith:'✈️', ghost:'👻', vessel:'🛸', battlecruiser:'🚀',
        zergling:'🦎', hydralisk:'🐍', mutalisk:'🦇', lurker:'🦟',
        zealot:'⚔️', dragoon:'🤺', dark_templar:'🌑', reaver:'🥚',
        high_templar:'⚡', corsair:'🛩️', carrier:'🛸'
    };
    const pStyleMap = { 'AGGRESSIVE':'⚔️ 공격 스타일 — 교전 자주, 초반 집중', 'NORMAL':'⚖️ 일반 스타일 — 균형 운영', 'DEFENSIVE':'🛡️ 수비 스타일 — 교전 적게, 후반 결전' };
    const hStyleMap = { 'NO_HARASS':'🚫 견제 안 함', 'NORMAL_HARASS':'🐝 일반 견제 (2~6회)', 'HEAVY_HARASS':'🔥 강한 견제 (7~11회)' };
    const aMap      = { 'FAST_MULTI':'⚡ 빠른 멀티 — 빠른 확장 타이밍', 'NORMAL_MULTI':'⚖️ 일반 멀티 — 평균 확장 타이밍', 'SLOW_MULTI':'🐢 느린 멀티 — 병력 집중 후 확장' };
    const PRIO_LABEL = { high:'높음', mid:'보통', low:'낮음' };
    const PRIO_COLOR = { high:'#e8a020', mid:'#4e9de0', low:'#888' };
    const BUILDING_NAME = {
        barracks:'배럭스', factory:'팩토리', starport:'스타포트', academy:'아카데미',
        machine_shop:'머신샵', armory:'아머리', science_facility:'사이언스 퍼실리티',
        nuclear_silo:'뉴클리어 어댑터', battle_adaptor:'배틀 어댑터',
        hatchery:'해처리', spawning_pool:'스포닝풀', hydralisk_den:'히드라덴', spire:'스파이어', lurker_aspect:'러커어스펙트',
        gateway:'게이트웨이', cybernetics_core:'사이버네틱스코어', citadel:'시타델', robotics:'로보틱스'
    };

    function setMyRaceFilter(race, btn) {
        currentMyRace = race;
        btn.parentElement.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        applyFilter();
    }

    function setVsRaceFilter(race, btn) {
        currentVsRace = race;
        btn.parentElement.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        applyFilter();
    }

    function applyFilter() {
        const items = document.querySelectorAll('.build-list-item');
        let visibleCount = 0;
        items.forEach(item => {
            let show = true;
            if (currentMyRace !== 'ALL' && item.dataset.race !== currentMyRace) show = false;
            if (currentVsRace !== 'ALL' && item.dataset.vsRace !== 'A' && item.dataset.vsRace !== currentVsRace) show = false;
            
            if (show) { item.style.display = 'flex'; visibleCount++; }
            else { item.style.display = 'none'; }
        });
        const emptyMsg = document.getElementById('noFilterResult');
        if(emptyMsg) emptyMsg.style.display = (visibleCount === 0) ? 'block' : 'none';
        
        document.getElementById('cardPlaceholder').style.display = 'flex';
        document.getElementById('cardContent').style.display = 'none';
        items.forEach(item => item.classList.remove('active'));
    }

    function loadBuildDetail(element, buildId) {
        document.querySelectorAll('.build-list-item').forEach(item => item.classList.remove('active'));
        element.classList.add('active');

        fetch(CTX + '/build/detail?id=' + buildId)
        .then(response => response.json())
        .then(data => {
            if (data.success) updateDetailView(data.build);
            else alert(data.message);
        })
        .catch(error => console.error("Error:", error));
    }

    function updateDetailView(build) {
        document.getElementById('cardPlaceholder').style.display = 'none';
        document.getElementById('cardContent').style.display = 'flex';

        // 헤더 (한 줄)
        document.getElementById('dtBuildName').textContent = build.buildName;
        var raceMap = {T:'테란', P:'프로토스', Z:'저그', A:'ALL'};
        document.getElementById('dtMatchup').innerHTML =
            '<span class="mu-race mu-' + build.race + '">' + (raceMap[build.race]||build.race) + '</span>' +
            '<span class="mu-vs">vs</span>' +
            '<span class="mu-race mu-' + build.vsRace + '">' + (build.vsRace === 'A' ? 'ALL' : (raceMap[build.vsRace]||build.vsRace)) + '</span>';

        // 생성일
        var createdEl = document.getElementById('dtCreated');
        if (build.createdAt) {
            var d = new Date(build.createdAt);
            var ds = d.getFullYear() + '-' + String(d.getMonth()+1).padStart(2,'0') + '-' + String(d.getDate()).padStart(2,'0');
            createdEl.textContent = ds;
        } else {
            createdEl.textContent = '';
        }

        // 성향 배지
        document.getElementById('dtPlayStyle').textContent   = pStyleMap[build.playStyle]   || build.playStyle   || '-';
        document.getElementById('dtHarassStyle').textContent = hStyleMap[build.harassStyle] || build.harassStyle || '🐝 일반 견제 (2~6회)';
        document.getElementById('dtAggression').textContent  = aMap[build.aggression]       || build.aggression  || '-';
        document.getElementById('dtMaxBases').textContent    = build.maxBases > 0 ? '🏗 멀티 ' + (build.maxBases - 1) + '개' : '🏗 멀티 설정 없음';
        document.getElementById('dtFocusTime').textContent   = build.focusAttackTime > 0 ? '⚔️ 집중타이밍 ' + Math.round(build.focusAttackTime / 60) + '분' : '⚔️ 전구간 균등';

        // 선호 유닛
        var puWrap = document.getElementById('dtPreferredUnits');
        var rawUnits = (build.preferredUnits || '').split(',').map(function(s){return s.trim();}).filter(Boolean);
        if (rawUnits.length === 0) {
            puWrap.innerHTML = '<span class="dt-empty">선호 유닛 없음</span>';
        } else {
            puWrap.innerHTML = rawUnits.map(function(entry) {
                var parts = entry.split(':');
                var uid = parts[0] || '', grp = parts[1] || 'mid', ratio = parts[2] || '5';
                var color = PRIO_COLOR[grp] || '#888';
                var label = PRIO_LABEL[grp] || grp;
                return '<div class="dt-chip" style="border-left:3px solid ' + color + ';">' +
                    '<span class="dt-chip-emoji">' + (UNIT_EMOJI[uid] || '⚙️') + '</span>' +
                    '<span class="dt-chip-name">' + (UNIT_DATA_FLAT[uid] || uid) + '</span>' +
                    '<span class="dt-chip-meta" style="color:' + color + '">' + label + ' ' + ratio + '</span>' +
                '</div>';
            }).join('');
        }

        // 선호 건물
        var pbWrap = document.getElementById('dtPreferredBuildings');
        var rawBlds = (build.preferredBuildings || '').split(',').map(function(s){return s.trim();}).filter(Boolean);
        if (rawBlds.length === 0) {
            pbWrap.innerHTML = '<span class="dt-empty">선호 건물 없음</span>';
        } else {
            pbWrap.innerHTML = rawBlds.map(function(entry) {
                var parts = entry.split(':');
                var bid = parts[0] || '', cnt = parts[1] || '0', prio = parts[2] || 'mid';
                var color = PRIO_COLOR[prio] || '#888';
                return '<div class="dt-chip" style="border-left:3px solid ' + color + ';">' +
                    '<span class="dt-chip-name">' + (BUILDING_NAME[bid] || bid) + '</span>' +
                    '<span class="dt-chip-meta">목표 <b style="color:#fff">' + cnt + '</b>개</span>' +
                '</div>';
            }).join('');
        }

        // 빌드 분석
        var anaEl = document.getElementById('dtAnalysis');
        var unitIds = rawUnits.map(function(e){ return e.split(':')[0]; });
        
        if (unitIds.length === 0) {
            anaEl.innerHTML = '<span class="dt-empty">유닛 정보가 있으면 분석이 표시됩니다.</span>';
        } else {
            anaEl.innerHTML = analyzeBuild(unitIds, build.playStyle, build.aggression, build.race);
        }

        document.getElementById('btnEditBuild').onclick = function() { location.href = CTX + '/build/edit?id=' + build.buildId; };
        document.getElementById('btnDeleteBuild').onclick = function() {
            if (confirm('정말로 이 전략을 삭제하시겠습니까?')) {
                fetch(CTX + '/build/delete', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ buildId: build.buildId })
                })
                .then(function(r){ return r.json(); })
                .then(function(d) {
                    if (d.success) { alert('삭제되었습니다.'); location.reload(); }
                    else alert(d.message);
                });
            }
        };
    }

    // ============================================================
    //  빌드 분석 엔진
    // ============================================================
    var UNIT_TRAITS = {
        // 테란
        marine:       {type:'bio',role:'주력', strong:['mutalisk','zergling','interceptor'], weak:['lurker','high_templar','reaver'], tags:['지상','경량']},
        firebat:      {type:'bio',role:'근접', strong:['zergling','zealot'], weak:['dragoon','tank','lurker'], tags:['지상','근접']},
        medic:        {type:'bio',role:'지원', strong:[], weak:[], tags:['지원','힐']},
        vulture:      {type:'mech',role:'정찰', strong:['zealot','zergling','hydralisk'], weak:['dragoon','mutalisk'], tags:['지상','기동']},
        tank:         {type:'mech',role:'화력', strong:['hydralisk','dragoon','zealot','lurker'], weak:['mutalisk','wraith','zergling'], tags:['지상','포위']},
        goliath:      {type:'mech',role:'대공', strong:['mutalisk','wraith','corsair','carrier','battlecruiser'], weak:['tank','zealot'], tags:['지상','대공']},
        wraith:       {type:'air',role:'공중', strong:['mutalisk','vessel','medic'], weak:['goliath','corsair','hydralisk','dragoon'], tags:['공중','기동']},
        ghost:        {type:'bio',role:'특수', strong:['battlecruiser','carrier'], weak:['zergling','zealot'], tags:['특수']},
        vessel:       {type:'air',role:'지원', strong:['lurker','dark_templar'], weak:['wraith','corsair'], tags:['공중','지원']},
        battlecruiser:{type:'air',role:'최종', strong:['hydralisk','dragoon','zealot'], weak:['ghost','mutalisk'], tags:['공중','중장갑']},
        // 저그
        zergling:     {type:'bio',role:'쇄도', strong:['tank','marine','high_templar'], weak:['firebat','vulture','reaver'], tags:['지상','경량','쇄도']},
        hydralisk:    {type:'bio',role:'주력', strong:['mutalisk','wraith','zealot','corsair'], weak:['tank','reaver','lurker'], tags:['지상','대공']},
        mutalisk:     {type:'air',role:'견제', strong:['tank','marine','high_templar','medic'], weak:['goliath','corsair','hydralisk'], tags:['공중','기동','견제']},
        lurker:       {type:'bio',role:'수비', strong:['marine','zealot','zergling'], weak:['tank','reaver','vessel'], tags:['지상']},
        // 프로토스
        zealot:       {type:'bio',role:'근접', strong:['marine','firebat','zergling','vulture'], weak:['tank','reaver','lurker'], tags:['지상','근접']},
        dragoon:      {type:'mech',role:'주력', strong:['vulture','wraith','mutalisk'], weak:['tank','zergling'], tags:['지상','대공']},
        dark_templar: {type:'bio',role:'특수', strong:['marine','hydralisk','zergling'], weak:['vessel','corsair'], tags:['지상']},
        reaver:       {type:'mech',role:'화력', strong:['marine','zergling','hydralisk','zealot'], weak:['mutalisk','wraith'], tags:['지상']},
        high_templar: {type:'bio',role:'특수', strong:['marine','hydralisk','zergling','tank'], weak:['dark_templar','ghost'], tags:['지상','마법']},
        corsair:      {type:'air',role:'대공', strong:['mutalisk','wraith','vessel'], weak:['goliath','hydralisk'], tags:['공중','대공']},
        carrier:      {type:'air',role:'최종', strong:['hydralisk','marine','zergling'], weak:['ghost','goliath'], tags:['공중','중장갑']}
    };

    function analyzeBuild(unitIds, playStyle, aggression, race) {
        var items = [];
        var strongSet = {}, weakSet = {};
        var tagCounts = {};
        var hasAir = false, hasGround = false;

        unitIds.forEach(function(uid) {
            var t = UNIT_TRAITS[uid];
            if (!t) return;
            t.strong.forEach(function(s){ strongSet[s] = (strongSet[s]||0) + 1; });
            t.weak.forEach(function(w){ weakSet[w] = (weakSet[w]||0) + 1; });
            t.tags.forEach(function(tag){ tagCounts[tag] = (tagCounts[tag]||0) + 1; });
            if (t.tags.indexOf('공중') >= 0) hasAir = true;
            if (t.tags.indexOf('지상') >= 0) hasGround = true;
        });

        // 상성 유리 — ▲ 화살표
        var strongArr = Object.keys(strongSet).sort(function(a,b){ return strongSet[b]-strongSet[a]; }).slice(0,4);
        if (strongArr.length > 0) {
            var strongHtml = strongArr.map(function(uid){
                return '<span class="ana-unit-tag good">▲ ' + (UNIT_EMOJI[uid]||'') + ' ' + (UNIT_DATA_FLAT[uid]||uid) + '</span>';
            }).join('');
            items.push({icon:'▲', title:'상성 유리', html: strongHtml});
        }

        // 공통 취약점 — 텍스트에 붉은색
        var sharedWeak = Object.keys(weakSet).filter(function(k){ return weakSet[k] >= 2; })
            .sort(function(a,b){ return weakSet[b]-weakSet[a]; }).slice(0,4);
        if (sharedWeak.length > 0) {
            var weakHtml = sharedWeak.map(function(uid){
                var vulnUnits = unitIds.filter(function(myUid){
                    var t = UNIT_TRAITS[myUid];
                    return t && t.weak.indexOf(uid) >= 0;
                }).map(function(myUid){ return UNIT_DATA_FLAT[myUid]||myUid; });
                return '<div class="ana-vuln-row">' +
                    '<span class="ana-unit-tag bad">⚠️ ' + (UNIT_EMOJI[uid]||'') + ' ' + (UNIT_DATA_FLAT[uid]||uid) + '</span>' +
                    '<span class="ana-vuln-detail">' + vulnUnits.join(', ') + ' 취약</span>' +
                '</div>';
            }).join('');
            items.push({icon:'⚠️', title:'공통 취약점', html: weakHtml});
        }

        // 구성 특성
        var traits = [];
        if (hasAir && hasGround) traits.push('<span class="ana-trait">🌐 지상+공중 복합</span>');
        else if (hasAir && !hasGround) traits.push('<span class="ana-trait air">✈️ 공중 집중</span>');
        else if (hasGround && !hasAir) traits.push('<span class="ana-trait ground">🏔️ 지상 집중</span>');

        if (tagCounts['기동'] >= 2) traits.push('<span class="ana-trait mobile">⚡ 기동력 중심</span>');
        if (tagCounts['쇄도'] >= 1 && tagCounts['경량'] >= 1) traits.push('<span class="ana-trait rush">🐝 물량 러시형</span>');
        if (tagCounts['중장갑'] >= 1) traits.push('<span class="ana-trait heavy">🛡️ 최종 병기 보유</span>');
        if (tagCounts['견제'] >= 1) traits.push('<span class="ana-trait mobile">🐝 견제 특화</span>');

        if (traits.length > 0) {
            items.push({icon:'🔍', title:'구성 특성', html: traits.join('')});
        }

        // 약점 경고
        var warnings = [];
        if (!hasAir && !unitIds.some(function(u){ var t=UNIT_TRAITS[u]; return t && t.tags.indexOf('대공')>=0; })) {
            warnings.push('대공 수단이 부족합니다. 공중 유닛에 취약할 수 있습니다.');
        }
        if (!hasGround && unitIds.length >= 2) {
            warnings.push('지상 유닛이 없습니다. 지상 전투력이 부족할 수 있습니다.');
        }
        if (warnings.length > 0) {
            items.push({icon:'🚨', title:'약점 경고', html: warnings.map(function(w){
                return '<div class="ana-warning"><span>⚠️</span><span>' + w + '</span></div>';
            }).join('')});
        }

        return '<div class="ana-grid">' + items.map(function(item) {
            return '<div class="ana-card">' +
                '<div class="ana-card-head"><span class="ana-card-icon">' + item.icon + '</span><span class="ana-card-title">' + item.title + '</span></div>' +
                '<div class="ana-card-body">' + item.html + '</div>' +
            '</div>';
        }).join('') + '</div>';
    }
</script>

</body>
</html>