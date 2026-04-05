<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>전략 생성 - My Star League</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/buildCreate.css' />">
</head>
<body>
<header class="msl-topbar">
    <div class="msl-topbar-logo">MY STAR <span>LEAGUE</span></div>
    <div class="msl-topbar-center">
        <nav class="msl-breadcrumb">
            <a href="<c:url value='/mode-select' />">홈</a><span class="sep">/</span>
            <a href="<c:url value='/build/manage' />">전략 수립</a><span class="sep">/</span>
            <span class="current">새 전략 생성</span>
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
    <div class="msl-page-header msl-animate">
        <div class="msl-page-header-left">
            <div class="msl-page-eyebrow">BUILD STRATEGY</div>
            <div class="msl-page-title">새 전략 생성</div>
        </div>
        <div class="msl-page-actions">
            <a href="<c:url value='/build/manage' />" class="msl-btn msl-btn-secondary">← 취소</a>
            <button type="button" class="msl-btn msl-btn-primary" onclick="submitBuild()">💾 저장하기</button>
        </div>
    </div>
    <div class="build-create-grid msl-animate msl-animate-d1">

        <!-- 왼쪽: 기본 정보 -->
        <div class="msl-panel">
            <div class="msl-panel-head"><div class="msl-panel-title">✏️ 전략 기본 정보</div></div>
            <div class="msl-panel-body">
                <form id="buildCreateForm">
                    <input type="hidden" id="preferredUnits" name="preferredUnits" value="">
                    <div class="msl-form-group">
                        <label class="msl-label">전략 이름</label>
                        <input type="text" id="buildName" name="buildName" class="msl-input" placeholder="예: 5배럭 마린메딕 러시" required>
                    </div>
                    <div class="msl-form-group">
                        <label class="msl-label">내 종족</label>
                        <select id="race" name="race" class="msl-select" required onchange="onRaceChange()">
                            <option value="" disabled selected>종족 선택</option>
                            <option value="T">테란 (Terran)</option>
                            <option value="Z">저그 (Zerg)</option>
                            <option value="P">프로토스 (Protoss)</option>
                        </select>
                    </div>
                    <div class="msl-form-group">
                        <label class="msl-label">상대 종족 맞춤</label>
                        <select id="vsRace" name="vsRace" class="msl-select">
                            <option value="A">모든 종족 (공통)</option>
                            <option value="T">vs 테란</option>
                            <option value="Z">vs 저그</option>
                            <option value="P">vs 프로토스</option>
                        </select>
                    </div>
                    <div class="msl-form-group">
                        <label class="msl-label">플레이 스타일</label>
                        <select id="playStyle" name="playStyle" class="msl-select">
                            <option value="AGGRESSIVE" selected>⚔️ 공격 스타일</option>
                            <option value="NORMAL">⚖️ 일반 스타일</option>
                            <option value="DEFENSIVE">🛡️ 수비 스타일</option>
                        </select>
                    </div>
                    <div class="msl-form-group">
                        <label class="msl-label">견제 성향</label>
                        <select id="harassStyle" name="harassStyle" class="msl-select">
                            <option value="NO_HARASS">🚫 견제 안 함</option>
                            <option value="NORMAL_HARASS" selected>🐝 일반 견제 (2~6회)</option>
                            <option value="HEAVY_HARASS">🔥 강한 견제 (7~11회)</option>
                        </select>
                    </div>
                    <div class="msl-form-group">
                        <label class="msl-label">멀티 성향</label>
                        <select id="aggression" name="aggression" class="msl-select">
                            <option value="MIN_MULTI">🏠 최소 멀티 (멀티 1개)</option>
                            <option value="MID_MULTI" selected>⚖️ 중간 멀티 (멀티 3개)</option>
                            <option value="MAX_MULTI">💰 다수 멀티 (멀티 5개)</option>
                        </select>
                    </div>
                </form>
            </div>
        </div>

        <!-- 오른쪽: 선호 유닛 + 선호 건물 -->
        <div style="display:flex;flex-direction:column;gap:1rem;min-width:0;width:100%">

        <div class="msl-panel">
            <div class="msl-panel-head">
                <div class="msl-panel-title">⭐ 선호 유닛 설정</div>
                <div style="font-size:0.72rem;color:#555;font-weight:600;">
                    <span class="slot-dot" id="slot0"></span>
                    <span class="slot-dot" id="slot1"></span>
                    <span class="slot-dot" id="slot2"></span>
                    <span class="slot-dot" id="slot3"></span>
                    <span class="slot-dot" id="slot4"></span>
                    <span class="slot-label">최대 5개 · 우선순위 설정 가능</span>
                </div>
            </div>
            <div class="msl-panel-body preferred-panel" style="overflow-y:auto;max-height:320px;">
                <div>
                    <div class="punit-section-title" id="unitGridTitle">— 유닛 목록 —</div>
                    <div class="punit-grid" id="punitGrid">
                        <div style="color:#555;font-size:.82em;padding:10px 0">왼쪽에서 종족을 선택하세요.</div>
                    </div>
                </div>
                <div id="counterPanel" style="display:none;margin-top:8px;border-radius:6px;background:#0f0f1a;border:1px solid #2a2a3a;padding:8px 12px;">
                    <div style="display:flex;align-items:flex-start;gap:12px;">
                        <div id="counterUnitPreview" style="flex-shrink:0;display:flex;align-items:center;gap:6px;min-width:80px;"></div>
                        <div style="flex:1;display:flex;gap:16px;">
                            <div style="flex:1;">
                                <div style="font-size:0.65rem;font-weight:700;color:#5ec46e;letter-spacing:0.06em;margin-bottom:4px;">✅ 유리한 상대</div>
                                <div id="counterGood" style="display:flex;flex-wrap:wrap;gap:4px;"></div>
                            </div>
                            <div style="flex:1;">
                                <div style="font-size:0.65rem;font-weight:700;color:#e05555;letter-spacing:0.06em;margin-bottom:4px;">❌ 불리한 상대</div>
                                <div id="counterBad" style="display:flex;flex-wrap:wrap;gap:4px;"></div>
                            </div>
                        </div>
                    </div>
                    <div id="priorityRow" style="display:none;margin-top:8px;padding-top:8px;border-top:1px solid #2a2a3a;flex-direction:column;gap:6px;">
                        <div style="display:flex;align-items:center;gap:8px;">
                            <span style="font-size:0.68rem;color:#aaa;font-weight:600;min-width:56px;">우선순위</span>
                            <button type="button" id="prioHigh" onclick="setPriority(activeId,'high')" style="font-size:0.7rem;padding:2px 10px;border-radius:4px;border:1px solid #e8a020;background:transparent;color:#e8a020;cursor:pointer;font-weight:700;">높음</button>
                            <button type="button" id="prioMid"  onclick="setPriority(activeId,'mid')"  style="font-size:0.7rem;padding:2px 10px;border-radius:4px;border:1px solid #4e9de0;background:transparent;color:#4e9de0;cursor:pointer;font-weight:700;">보통</button>
                            <button type="button" id="prioLow"  onclick="setPriority(activeId,'low')"  style="font-size:0.7rem;padding:2px 10px;border-radius:4px;border:1px solid #888;background:transparent;color:#888;cursor:pointer;font-weight:700;">낮음</button>
                        </div>
                        <div style="display:flex;align-items:center;gap:8px;">
                            <span style="font-size:0.68rem;color:#aaa;font-weight:600;min-width:56px;">그룹 내 비율</span>
                            <input type="number" id="ratioInput" min="1" max="10" value="5"
                                   onchange="setRatio(activeId,this.value);"
                                   style="width:52px;padding:2px 6px;border-radius:4px;border:1px solid #c9a44e;background:#111;color:#c9a44e;font-size:0.8rem;font-weight:700;text-align:center;">
                            <span style="font-size:0.65rem;color:#555;">/ 10 (그룹 합계)</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 선호 건물 설정 -->
        <div class="msl-panel">
            <div class="msl-panel-head"><div class="msl-panel-title">🏗 선호 건물 설정</div></div>
            <div class="msl-panel-body">
                <div style="font-size:0.8rem;color:#888;margin-bottom:10px">건물별 목표 건설 수량을 설정합니다. 0은 건설하지 않음.</div>
                <input type="hidden" id="preferredBuildings" name="preferredBuildings" value="">
                <div id="buildingGrid" style="color:#555;font-size:.82em;padding:10px 0">왼쪽에서 종족을 먼저 선택하세요.</div>
            </div>
        </div>

        </div><!-- /right column -->
</main>
<script>
const UNIT_DATA = {
    T:[
        {id:'marine',       name:'마린',       tier:1, emoji:'🪖'},
        {id:'firebat',      name:'파이어뱃',   tier:1, emoji:'🔥'},
        {id:'medic',        name:'메딕',       tier:1, emoji:'💊'},
        {id:'vulture',      name:'벌처',       tier:2, emoji:'🏍️'},
        {id:'tank',         name:'탱크',       tier:2, emoji:'🛡️'},
        {id:'goliath',      name:'골리앗',     tier:2, emoji:'🤖'},
        {id:'wraith',       name:'레이스',     tier:2, emoji:'✈️'},
        {id:'ghost',        name:'고스트',     tier:3, emoji:'👻'},
        {id:'vessel',       name:'베슬',       tier:3, emoji:'🛸'},
        {id:'battlecruiser',name:'배틀크루저', tier:3, emoji:'🚀'}
    ],
    Z:[
        {id:'zergling',  name:'저글링',    tier:1, emoji:'🦎'},
        {id:'hydralisk', name:'히드라',     tier:1, emoji:'🐍'},
        {id:'lurker',    name:'러커',       tier:2, emoji:'🦟'},
        {id:'mutalisk',  name:'뮤탈',       tier:2, emoji:'🦇'},
        {id:'scourge',   name:'스컬지',     tier:2, emoji:'💀'},
        {id:'queen',     name:'퀸',         tier:2, emoji:'👑'},
        {id:'guardian',  name:'가디언',     tier:3, emoji:'🛡️'},
        {id:'devourer',  name:'디바우러',   tier:3, emoji:'🌀'},
        {id:'ultralisk', name:'울트라리스크',tier:3, emoji:'🦏'},
        {id:'defiler',   name:'디파일러',   tier:3, emoji:'☠️'}
    ],
    P:[
        {id:'zealot',      name:'질럿',      tier:1, emoji:'⚔️'},
        {id:'dragoon',     name:'드라군',    tier:1, emoji:'🤺'},
        {id:'high_templar',name:'하이템플러',tier:2, emoji:'⚡'},
        {id:'dark_templar',name:'다크템플러',tier:2, emoji:'🌑'},
        {id:'shuttle',     name:'셔틀',      tier:2, emoji:'🚁'},
        {id:'reaver',      name:'리버',      tier:2, emoji:'🥚'},
        {id:'corsair',     name:'커세어',    tier:2, emoji:'🛩️'},
        {id:'scout',       name:'스카우트',  tier:2, emoji:'🛸'},
        {id:'carrier',     name:'캐리어',    tier:3, emoji:'🚀'},
        {id:'arbiter',     name:'아비터',    tier:3, emoji:'⭐'}
    ]
};
const ALL_UNITS = Object.values(UNIT_DATA).flat();

const COUNTER = {
    marine:       {good:['zergling','zealot','mutalisk'],         bad:['lurker','tank','reaver','dark_templar']},
    firebat:      {good:['zergling','zealot','hydralisk'],        bad:['tank','dragoon','lurker']},
    medic:        {good:[],                                        bad:['lurker','tank','reaver']},
    vulture:      {good:['zergling','zealot'],                    bad:['hydralisk','dragoon','reaver']},
    tank:         {good:['hydralisk','zealot','dragoon','lurker'], bad:['mutalisk','dark_templar','wraith']},
    goliath:      {good:['mutalisk','wraith','corsair','carrier'], bad:['zealot','zergling']},
    wraith:       {good:['mutalisk','corsair','zergling'],         bad:['goliath','hydralisk','dragoon']},
    ghost:        {good:['lurker','high_templar','carrier'],       bad:['zergling','zealot','hydralisk']},
    vessel:       {good:['lurker','zergling','dark_templar'],      bad:['mutalisk','corsair']},
    battlecruiser:{good:['zealot','hydralisk','mutalisk'],         bad:['goliath','wraith','corsair']},
    zergling:     {good:['marine','firebat','medic'],              bad:['vulture','tank','zealot','dark_templar']},
    hydralisk:    {good:['marine','wraith','zealot'],              bad:['tank','lurker','reaver','high_templar']},
    mutalisk:     {good:['marine','tank','vessel','reaver'],       bad:['goliath','wraith','corsair']},
    lurker:       {good:['marine','firebat','zealot','dragoon'],   bad:['vessel','ghost','high_templar']},
    scourge:      {good:['wraith','corsair','carrier','battlecruiser'], bad:['goliath','hydralisk','devourer']},
    queen:        {good:['marine','zealot','zergling'],              bad:['vessel','ghost','goliath']},
    guardian:     {good:['marine','zealot','zergling','hydralisk'],  bad:['goliath','corsair','scout','wraith']},
    devourer:     {good:['mutalisk','wraith','corsair','carrier'],   bad:['goliath','corsair','hydralisk']},
    ultralisk:    {good:['marine','firebat','zergling','zealot'],    bad:['lurker','reaver','tank']},
    defiler:      {good:['marine','zealot','hydralisk'],             bad:['vessel','ghost','corsair']},
    zealot:       {good:['marine','firebat','zergling','vulture'], bad:['lurker','tank','reaver','high_templar']},
    dragoon:      {good:['wraith','vulture','mutalisk'],           bad:['lurker','zealot','zergling']},
    dark_templar: {good:['marine','zergling','hydralisk'],         bad:['vessel','ghost']},
    reaver:       {good:['marine','vulture','zergling','hydralisk'],bad:['mutalisk','wraith']},
    high_templar: {good:['zergling','hydralisk','marine','lurker'], bad:['dark_templar','lurker']},
    corsair:      {good:['mutalisk','wraith'],                     bad:['goliath','hydralisk']},
    carrier:      {good:['zergling','hydralisk','marine'],         bad:['goliath','ghost','corsair']},
    shuttle:      {good:['zergling','hydralisk'],                  bad:['goliath','wraith','corsair','hydralisk']},
    scout:        {good:['mutalisk','corsair','wraith'],            bad:['goliath','corsair','hydralisk']},
    arbiter:      {good:['marine','zergling','hydralisk'],          bad:['goliath','corsair','hydralisk']}
};
const BUILDING_DATA = {
    T:[
        {id:'barracks',         name:'배럭스',           tier:1},
        {id:'academy',          name:'아카데미',         tier:1},
        {id:'factory',          name:'팩토리',           tier:2},
        {id:'machine_shop',     name:'머신샵',           tier:2},
        {id:'armory',           name:'아머리',           tier:2},
        {id:'starport',         name:'스타포트',         tier:2},
        {id:'science_facility', name:'사이언스 퍼실리티',tier:3},
        {id:'nuclear_silo',     name:'뉴클리어 어댑터',  tier:3},
        {id:'battle_adaptor',   name:'배틀 어댑터',      tier:3}
    ],
    Z:[
        {id:'spawning_pool',   name:'스포닝풀',           tier:1},
        {id:'hydralisk_den',   name:'히드라덴',           tier:1},
        {id:'lair',            name:'레어',               tier:2},
        {id:'spire',           name:'스파이어',           tier:2},
        {id:'queens_nest',     name:'퀸즈 네스트',        tier:2},
        {id:'hive',            name:'하이브',             tier:3},
        {id:'greater_spire',   name:'그레이트 스파이어',  tier:3},
        {id:'defiler_mound',   name:'디파일러 마운드',    tier:3},
        {id:'ultralisk_cavern',name:'울트라리스크 케이번',tier:3}
    ],
    P:[
        {id:'gateway',              name:'게이트웨이',           tier:1},
        {id:'cybernetics_core',     name:'사이버코어',           tier:1},
        {id:'citadel_of_adun',      name:'시타델 아둔',          tier:2},
        {id:'templar_archives',     name:'템플러 아카이브',      tier:2},
        {id:'robotics_facility',    name:'로보틱스 퍼실리티',    tier:2},
        {id:'robotics_support_bay', name:'로보틱스 서포트베이',  tier:2},
        {id:'stargate',             name:'스타게이트',           tier:2},
        {id:'fleet_beacon',         name:'플릿 비콘',            tier:3},
        {id:'arbiter_tribunal',     name:'아비터 트리뷰널',      tier:3}
    ]
};

const TIER_COLOR = {1:'#4e9de0', 2:'#c9a44e', 3:'#c96ad3'};

// 선호 건물 수량 상태
let buildingCounts = {};
let buildingPriority = {}; // {buildingId: 'low'|'mid'|'high'}

function renderBuildingGrid() {
    const race = document.getElementById('race').value;
    const maxTier = 3;
    const grid = document.getElementById('buildingGrid');
    if (!race) {
        grid.innerHTML = '<div style="color:#555;font-size:.82em;padding:10px 0">왼쪽에서 종족을 먼저 선택하세요.</div>';
        return;
    }
    const buildings = (BUILDING_DATA[race] || []).filter(b => b.tier <= maxTier);
    const byTier = {1:[], 2:[], 3:[]};
    buildings.forEach(function(b) { (byTier[b.tier] || byTier[1]).push(b); });

    var html = '<div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:10px;">';
    [1,2,3].forEach(function(tier) {
        var tierColor = TIER_COLOR[tier];
        html += '<div>';
        html += '<div style="font-size:0.65rem;font-weight:700;letter-spacing:0.1em;color:' + tierColor + ';margin-bottom:6px;padding-bottom:4px;border-bottom:1px solid rgba(255,255,255,0.06);">TIER ' + tier + '</div>';
        if (byTier[tier].length === 0) {
            html += '<div style="color:#444;font-size:0.75rem;padding:4px 0;">없음</div>';
        } else {
            byTier[tier].forEach(function(b) {
                var cnt = buildingCounts[b.id] || 0;
                var pri = buildingPriority[b.id] || 'mid';
                var required = getRequiredBuildingsForUnits();
                var isRequired = required.has(b.id);
                var minusDis = isRequired && cnt <= 1;
                html += '<div style="display:flex;align-items:center;gap:5px;margin-bottom:8px;">'
                    + '<span style="flex:1;font-size:0.85rem;color:' + (isRequired?'#f0c040':'#ddd') + ';font-weight:' + (isRequired?'700':'400') + ';overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">'
                    + b.name + (isRequired ? ' ★' : '') + '</span>'
                    + '<button type="button" onclick="changePriority(\'' + b.id + '\',\'low\')" style="padding:3px 6px;border-radius:3px;border:1px solid rgba(255,255,255,0.12);font-size:0.68rem;cursor:pointer;background:' + (pri==='low'?'#555':'rgba(255,255,255,0.03)') + ';color:' + (pri==='low'?'#fff':'#666') + ';">낮음</button>'
                    + '<button type="button" onclick="changePriority(\'' + b.id + '\',\'mid\')" style="padding:3px 6px;border-radius:3px;border:1px solid rgba(255,255,255,0.12);font-size:0.68rem;cursor:pointer;background:' + (pri==='mid'?'#c9a44e':'rgba(255,255,255,0.03)') + ';color:' + (pri==='mid'?'#000':'#666') + ';">보통</button>'
                    + '<button type="button" onclick="changePriority(\'' + b.id + '\',\'high\')" style="padding:3px 6px;border-radius:3px;border:1px solid rgba(255,255,255,0.12);font-size:0.68rem;cursor:pointer;background:' + (pri==='high'?'#4e9de0':'rgba(255,255,255,0.03)') + ';color:' + (pri==='high'?'#000':'#666') + ';">높음</button>'
                    + '<button type="button" onclick="changeBldCount(\'' + b.id + '\',-1)" ' + (minusDis ? 'disabled style="width:24px;height:24px;border:1px solid rgba(255,255,255,0.08);background:rgba(255,255,255,0.02);color:#333;border-radius:3px;cursor:not-allowed;font-size:1rem;line-height:1;"' : 'style="width:24px;height:24px;border:1px solid rgba(255,255,255,0.2);background:rgba(255,255,255,0.05);color:#fff;border-radius:3px;cursor:pointer;font-size:1rem;line-height:1;"') + '>−</button>'
                    + '<span style="width:22px;text-align:center;font-size:0.9rem;font-weight:700;color:' + (isRequired?'#f0c040':'#fff') + ';">' + cnt + '</span>'
                    + '<button type="button" onclick="changeBldCount(\'' + b.id + '\',1)" style="width:24px;height:24px;border:1px solid rgba(255,255,255,0.2);background:rgba(255,255,255,0.05);color:#fff;border-radius:3px;cursor:pointer;font-size:1rem;line-height:1;">＋</button>'
                    + '</div>';
            });
        }
        html += '</div>';
    });
    html += '</div>';
    grid.innerHTML = html;
    saveBuildingCounts();
}

function changeBldCount(id, delta) {
    const required = getRequiredBuildingsForUnits();
    const cur = buildingCounts[id] || 0;
    const next = Math.max(0, cur + delta);
    if (required.has(id) && next < 1) {
        alert('선호 유닛 생산에 필요한 건물은 최소 1개 이상이어야 합니다.');
        return;
    }
    buildingCounts[id] = next;
    saveBuildingCounts();
    renderBuildingGrid();
}

function changePriority(id, pri) {
    buildingPriority[id] = pri;
    renderBuildingGrid();
}

function saveBuildingCounts() {
    const parts = Object.entries(buildingCounts)
        .filter(function(e) { return e[1] > 0; })
        .map(function(e) { return e[0] + ':' + e[1] + ':' + (buildingPriority[e[0]] || 'mid'); });
    document.getElementById('preferredBuildings').value = parts.join(',');
}


const TIER_LABEL = {1:'T1', 2:'T2', 3:'T3'};

// 유닛 → 필수 건물 맵 (생산에 필요한 건물들)
const UNIT_REQUIRED_BUILDINGS = {
    marine:       ['barracks'],
    firebat:      ['barracks','academy'],
    medic:        ['barracks','academy'],
    vulture:      ['factory'],
    tank:         ['factory','machine_shop'],
    goliath:      ['factory','armory'],
    wraith:       ['starport'],
    dropship:     ['starport'],
    ghost:        ['barracks','nuclear_silo'],
    vessel:       ['starport','science_facility'],
    battlecruiser:['starport','battle_adaptor'],
    zergling:     ['spawning_pool'],
    hydralisk:    ['hydralisk_den'],
    lurker:       ['hydralisk_den','lair'],
    mutalisk:     ['spire'],
    scourge:      ['spire'],
    queen:        ['queens_nest'],
    guardian:     ['greater_spire'],
    devourer:     ['greater_spire'],
    ultralisk:    ['ultralisk_cavern'],
    defiler:      ['defiler_mound'],
    zealot:       ['gateway'],
    dragoon:      ['cybernetics_core'],
    high_templar: ['templar_archives'],
    dark_templar: ['templar_archives'],
    shuttle:      ['robotics_facility'],
    reaver:       ['robotics_support_bay'],
    corsair:      ['stargate'],
    scout:        ['stargate'],
    carrier:      ['fleet_beacon'],
    arbiter:      ['arbiter_tribunal']
};

// 건물 선행 조건 맵
const BUILDING_PREREQS = {
    academy:          ['barracks'],
    factory:          ['barracks'],
    machine_shop:     ['factory'],
    armory:           ['factory'],
    starport:         ['factory'],
    science_facility: ['starport'],
    nuclear_silo:     ['science_facility'],
    battle_adaptor:   ['science_facility'],
    hydralisk_den:    ['hatchery'],
    lair:             ['spawning_pool'],
    spire:            ['lair'],
    queens_nest:      ['lair'],
    hive:             ['queens_nest'],
    greater_spire:    ['hive'],
    defiler_mound:    ['hive'],
    ultralisk_cavern: ['hive'],
    cybernetics_core:     ['gateway'],
    citadel_of_adun:      ['cybernetics_core'],
    templar_archives:     ['citadel_of_adun'],
    robotics_facility:    ['cybernetics_core'],
    robotics_support_bay: ['robotics_facility'],
    stargate:             ['cybernetics_core'],
    fleet_beacon:         ['stargate'],
    arbiter_tribunal:     ['stargate']
};

function collectAllRequired(bid, result) {
    if (result.has(bid)) return;
    result.add(bid);
    var prereqs = BUILDING_PREREQS[bid] || [];
    prereqs.forEach(function(p) { collectAllRequired(p, result); });
}

function getRequiredBuildingsForUnits() {
    var required = new Set();
    selectedUnits.forEach(function(uid) {
        var reqs = UNIT_REQUIRED_BUILDINGS[uid] || [];
        reqs.forEach(function(bid) { collectAllRequired(bid, required); });
    });
    return required;
}

function updateRequiredBuildings() {
    var required = getRequiredBuildingsForUnits();
    required.forEach(function(bid) {
        if (!buildingCounts[bid] || buildingCounts[bid] < 1) {
            buildingCounts[bid] = 1;
        }
    });
    saveBuildingCounts();
    renderBuildingGrid();
}

let selectedUnits  = [];
let unitPriority   = {}; // {id: 'high'|'mid'|'low'}
let unitRatio      = {}; // {id: 1~10}
let activeId       = null;

function serializePreferredUnits() {
    return selectedUnits.map(id => id + ':' + (unitPriority[id]||'mid') + ':' + (unitRatio[id]||5)).join(',');
}

function setPriority(id, p) {
    unitPriority[id] = p;
    document.getElementById('preferredUnits').value = serializePreferredUnits();
    renderCounter();
    render();
}

function setRatio(id, val) {
    const v = parseInt(val);
    unitRatio[id] = (!isNaN(v) && v >= 1 && v <= 10) ? v : (unitRatio[id]||5);
    document.getElementById('preferredUnits').value = serializePreferredUnits();
    render();
}

function mkIcon(u, size) {
    const s = size || 48;
    const img = document.createElement('img');
    img.src = '/image/units/' + u.id + '.png';
    img.width = s; img.height = s;
    img.style.cssText = 'object-fit:cover;border-radius:5px';
    img.onerror = function(){ const sp = document.createElement('span'); sp.textContent = u.emoji; sp.style.fontSize = Math.round(s*0.55)+'px'; sp.style.lineHeight='1'; this.replaceWith(sp); };
    return img.outerHTML;
}

function onRaceChange() {
    selectedUnits = [];
    unitPriority  = {};
    unitRatio     = {};
    activeId = null;
    buildingCounts = {};
    buildingPriority = {};
    document.getElementById('preferredUnits').value = '';
    document.getElementById('preferredBuildings').value = '';
    render();
    renderBuildingGrid();
}

function render() {
    const race    = document.getElementById('race').value;
    const maxTier = 3;
    const units   = (UNIT_DATA[race]||[]).filter(u=>u.tier<=maxTier);

    // 슬롯 닷
    [0,1,2,3,4].forEach(i=>{
        document.getElementById('slot'+i).className = 'slot-dot'+(i<selectedUnits.length?' filled':'');
    });

    // 요약 칩 (엘리먼트 없으면 skip)
    const box = document.getElementById('selectedSummary');
    if(box) {
        if(!race) { box.innerHTML='<span class="summary-empty">종족을 먼저 선택하세요</span>'; }
        else if(selectedUnits.length===0) { box.innerHTML='<span class="summary-empty">선택 없음 — 티어 가중치만 적용</span>'; }
        else {
            box.innerHTML = selectedUnits.map(id=>{
                const u = ALL_UNITS.find(x=>x.id===id)||{id:id,name:id,emoji:'?'};
                return '<div class="selected-unit-chip" onclick="removeUnit(\'' + id + '\')" title="클릭하여 제거">'
                     + '<div class="chip-icon">' + mkIcon(u,20) + '</div>' + u.name + ' ✕</div>';
            }).join('');
        }
    }

    // 그리드 타이틀
    const rn = {T:'테란',Z:'저그',P:'프로토스'};
    document.getElementById('unitGridTitle').textContent =
        race ? (rn[race] + ' — ' + maxTier + '티어 이하 유닛') : '— 유닛 목록 —';

    // 그리드
    const grid = document.getElementById('punitGrid');
    if(!race){ grid.innerHTML='<div style="color:#555;font-size:.82em;padding:10px 0">왼쪽에서 종족을 선택하세요.</div>'; document.getElementById('counterPanel').style.display='none'; return; }
    const orderNum = selectedUnits.reduce((o,id,i)=>{o[id]=i+1;return o;},{});
    const PRIO_LABEL = {high:'높음', mid:'보통', low:'낮음'};
    const PRIO_COLOR = {high:'#e8a020', mid:'#4e9de0', low:'#888'};
    grid.innerHTML = units.map(u=>{
        const sel = selectedUnits.includes(u.id);
        const dis = !sel && selectedUnits.length>=5;
        const num = orderNum[u.id];
        const prio = unitPriority[u.id] || 'mid';
        const ratio = unitRatio[u.id] || 5;
        const prioBadge = sel
            ? '<div style="position:absolute;bottom:4px;left:0;right:0;text-align:center;">'
            + '<span style="font-size:0.6rem;font-weight:700;color:' + PRIO_COLOR[prio] + ';background:#111;border-radius:3px;padding:1px 5px;border:1px solid ' + PRIO_COLOR[prio] + '">' + PRIO_LABEL[prio] + ' ' + ratio + '</span>'
            + '</div>' : '';
        return '<div class="punit-card' + (sel?' selected':'') + (dis?' disabled':'') + '" style="position:relative"'
             + ' onclick="onUnitClick(\'' + u.id + '\')">'
             + (num ? '<div class="punit-selected-num">' + num + '</div>' : '')
             + '<div class="punit-tier-badge" style="background:' + TIER_COLOR[u.tier] + '">' + TIER_LABEL[u.tier] + '</div>'
             + '<div class="punit-icon">' + mkIcon(u,48) + '</div>'
             + '<div class="punit-name">' + u.name + '</div>'
             + prioBadge
             + '</div>';
    }).join('');

    // 상성 패널
    if(activeId) renderCounter();
    else document.getElementById('counterPanel').style.display='none';
}

function onUnitClick(id) {
    if(selectedUnits.includes(id)){
        selectedUnits = selectedUnits.filter(x=>x!==id);
        delete unitPriority[id];
    } else {
        if(selectedUnits.length>=5){ alert('최대 5개까지 선택할 수 있습니다.'); activeId=id; render(); return; }
        selectedUnits.push(id);
        if(!unitPriority[id]) unitPriority[id] = 'mid';
        if(!unitRatio[id]) unitRatio[id] = 5;
    }
    activeId = id;
    document.getElementById('preferredUnits').value = serializePreferredUnits();
    updateRequiredBuildings();
    render();
}

function removeUnit(id) {
    selectedUnits = selectedUnits.filter(x=>x!==id);
    delete unitPriority[id];
    delete unitRatio[id];
    if(activeId===id) activeId=null;
    document.getElementById('preferredUnits').value = serializePreferredUnits();
    updateRequiredBuildings();
    render();
}

function renderCounter() {
    const u  = ALL_UNITS.find(x=>x.id===activeId);
    if(!u){ document.getElementById('counterPanel').style.display='none'; return; }
    const ct = COUNTER[activeId]||{good:[],bad:[]};

    document.getElementById('counterUnitPreview').innerHTML =
        '<div class="counter-sel-icon">' + mkIcon(u,28) + '</div>'
        + '<div style="font-size:0.75rem;color:#ccc;font-weight:700;margin-top:2px;">' + u.name + '</div>';

    const makeChips = ids => ids.length ? ids.map(cid=>{
        const cu = ALL_UNITS.find(x=>x.id===cid)||{id:cid,name:cid,emoji:'?'};
        return '<div style="display:flex;align-items:center;gap:3px;background:rgba(255,255,255,0.05);border-radius:4px;padding:2px 5px;">'
            + '<div style="width:18px;height:18px;border-radius:3px;overflow:hidden;flex-shrink:0;">' + mkIcon(cu,18) + '</div>'
            + '<span style="font-size:0.7rem;color:#ccc;">' + cu.name + '</span></div>';
    }).join('') : '<span style="font-size:0.72rem;color:#444;">없음</span>';

    document.getElementById('counterGood').innerHTML = makeChips(ct.good);
    document.getElementById('counterBad').innerHTML  = makeChips(ct.bad);

    // 우선순위 버튼: 선택된 유닛일 때만 표시, 현재 설정값 하이라이트
    const prioRow = document.getElementById('priorityRow');
    if(selectedUnits.includes(activeId)) {
        const cur = unitPriority[activeId] || 'mid';
        const curRatio = unitRatio[activeId] || 5;
        const ACTIVE_BG = {high:'#e8a020', mid:'#4e9de0', low:'#888'};
        ['high','mid','low'].forEach(p => {
            const btn = document.getElementById('prio' + p.charAt(0).toUpperCase() + p.slice(1));
            btn.style.background = (cur===p) ? ACTIVE_BG[p] : 'transparent';
            btn.style.color      = (cur===p) ? '#111' : ACTIVE_BG[p];
        });
        document.getElementById('ratioInput').value = curRatio;
        prioRow.style.display = 'flex';
    } else {
        prioRow.style.display = 'none';
    }

    document.getElementById('counterPanel').style.display = 'block';
}

function submitBuild() {
    const form = document.getElementById('buildCreateForm');
    if(!form.checkValidity()){ form.reportValidity(); return; }

    // 그룹별 비율 합계 검증 (각 그룹 합 ≤ 10)
    const groups = ['high', 'mid', 'low'];
    const groupLabel = {high:'높음', mid:'보통', low:'낮음'};
    for (const g of groups) {
        const sum = selectedUnits
            .filter(id => (unitPriority[id]||'mid') === g)
            .reduce((s, id) => s + (unitRatio[id]||5), 0);
        if (sum > 10) {
            alert('우선순위 [' + groupLabel[g] + '] 그룹의 비율 합계가 ' + sum + '입니다. 10 이하로 설정해주세요.');
            return;
        }
    }

    // 필수 건물 검증
    const required = getRequiredBuildingsForUnits();
    const race = document.getElementById('race').value;
    const bldNames = {};
    (BUILDING_DATA[race]||[]).forEach(function(b){ bldNames[b.id] = b.name; });
    for (const bid of required) {
        if (!buildingCounts[bid] || buildingCounts[bid] < 1) {
            alert('[' + (bldNames[bid]||bid) + '] 은(는) 선호 유닛 생산에 필요한 건물입니다. 최소 1개 이상 설정해주세요.');
            return;
        }
    }
    const d = Object.fromEntries(new FormData(form).entries());
    d.maxTier            = 3;
    d.preferredUnits     = document.getElementById('preferredUnits').value;
    d.preferredBuildings = document.getElementById('preferredBuildings').value;
    d.units = [];
    fetch('<c:url value="/build/create" />', {method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(d)})
    .then(r=>r.json())
    .then(res=>{ if(res.success){alert('전략이 등록되었습니다.');location.href='<c:url value="/build/manage" />';}else alert('등록 실패: '+res.message); })
    .catch(e=>{console.error(e);alert('서버 오류가 발생했습니다.');});
}

document.addEventListener('DOMContentLoaded', () => { render(); renderBuildingGrid(); });
</script>
</body>
</html>
