<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %> <!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>특성 관리 - My Star League</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/traitManagement.css' />">
</head>
<body>

<header class="msl-topbar">
    <div class="msl-topbar-logo">MY STAR <span>LEAGUE</span></div>
    <div class="msl-topbar-center">
        <nav class="msl-breadcrumb">
            <a href="<c:url value='/mode-select' />">홈</a>
            <span class="sep">/</span>
            <span class="current">특성 관리</span>
        </nav>
    </div>
    <div class="msl-topbar-right">
        <div class="msl-crystal">💎 ${sessionScope.loginUser.crystal}</div>
        <div class="msl-user-label"><strong>${sessionScope.loginUser.userNick}</strong></div>
        <a href="<c:url value='/logout' />" class="msl-btn-nav">LOGOUT</a>
    </div>
</header>

<c:set var="activeMenu" value="trait" />
<%@ include file="/WEB-INF/views/layout/sideBar.jsp" %>

<main class="msl-main">

    <header class="msl-page-header msl-animate">
        <div class="msl-page-header-left">
            <div class="msl-page-eyebrow">TRAIT MANAGEMENT</div>
            <div class="msl-page-title">특성 관리</div>
            <div class="msl-page-sub">선수들의 전투 행동 우선도를 설정하세요. 공격·수비·도움·견제 가중치가 높을수록 해당 행동을 더 자주 선택합니다.</div>
        </div>
    </header>

    <div class="trait-grid msl-animate msl-animate-d1">

        <!-- ── 좌측: 선수 목록 ─────────────────────────── -->
        <div class="msl-panel">
            <div class="msl-panel-header">
                <span class="msl-panel-title">보유 선수 목록</span>
                <span style="font-size:12px;color:#64748b;">${fn:length(traitList)}명</span>
            </div>
            <div class="msl-panel-body" style="padding:12px;">
                <c:choose>
                    <c:when test="${empty traitList}">
                        <div class="trait-placeholder">
                            <div class="ph-icon">📭</div>
                            <p>보유 중인 선수가 없습니다.<br>선수를 영입한 후 특성을 설정하세요.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <ul class="trait-player-list" id="playerList">
                            <c:forEach var="t" items="${traitList}" varStatus="st">
                                <li class="trait-player-item ${t.slotNumber > 0 ? '' : 'no-entry'}"
                                    data-seq="${t.ownedPlayerSeq}"
                                    data-atk="${t.atkWeight}"
                                    data-def="${t.defWeight}"
                                    data-assist="${t.assistWeight}"
                                    data-harass="${t.harassWeight}"
                                    data-name="${t.playerName}"
                                    data-race="${t.race}"
                                    data-rarity="${t.rarity}"
                                    data-img="${not empty t.playerImgUrl ? t.playerImgUrl : ''}"
                                    data-hp="${t.currentHp}"
                                    data-atk-stat="${t.currentAttack}"
                                    data-def-stat="${t.currentDefense}"
                                    data-spd="${t.currentSpeed}"
                                    data-condition="${not empty t.condition ? t.condition : 'NORMAL'}"
                                    data-saved="true"
                                    onclick="selectPlayer(this)">

                                    <c:choose>
                                        <c:when test="${not empty t.playerImgUrl}">
                                            <img class="trait-player-img" src="${t.playerImgUrl}" alt="${t.playerName}"
                                                 onerror="this.style.display='none'">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="trait-player-img" style="display:flex;align-items:center;justify-content:center;font-size:20px;">
                                                ${t.race == 'T' ? '🪖' : t.race == 'P' ? '⚔️' : '🦎'}
                                            </div>
                                        </c:otherwise>
                                    </c:choose>

                                    <div class="trait-player-info">
                                        <div class="trait-player-name">${t.playerName}</div>
                                        <div class="trait-player-meta">
                                            <span class="race-badge ${t.race}">${t.race}</span>
                                            <span class="rarity-badge ${t.rarity}">${t.rarity}</span>
                                            <c:if test="${t.slotNumber <= 0}">
                                                <span class="no-entry-tag">엔트리 외</span>
                                            </c:if>
                                        </div>
                                    </div>
                                    <div class="trait-saved-dot" id="dot_${t.ownedPlayerSeq}"></div>
                                </li>
                            </c:forEach>
                        </ul>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- ── 우측: 편집 패널 ────────────────────────── -->
        <div class="msl-panel trait-detail-panel">
            <div class="msl-panel-body">

                <!-- 플레이스홀더 -->
                <div class="trait-placeholder" id="traitPlaceholder">
                    <div class="ph-icon">👈</div>
                    <p>좌측에서 선수를 선택하면<br>특성을 편집할 수 있습니다.</p>
                </div>

                <!-- 편집 카드 -->
                <div class="trait-edit-card" id="traitEditCard">

                    <!-- 선수 헤더 -->
                    <div class="trait-card-header">
                        <img class="trait-card-img" id="editImg" src="" alt="">
                        <div class="trait-card-meta">
                            <div class="trait-card-name" id="editName">-</div>
                            <div class="trait-card-sub">
                                <span class="race-badge" id="editRace">-</span>
                                <span class="rarity-badge" id="editRarity">-</span>
                                <span class="cond-badge" id="editCond">-</span>
                            </div>
                        </div>
                    </div>

                    <!-- 기본 스탯 미니 바 -->
                    <div class="trait-card-stats">
                        <div class="stat-mini-row">
                            <span class="stat-mini-label">ATK</span>
                            <div class="stat-mini-bar-bg"><div class="stat-mini-bar-fill" id="barAtk" style="width:0%"></div></div>
                            <span class="stat-mini-val" id="valAtk">0</span>
                        </div>
                        <div class="stat-mini-row">
                            <span class="stat-mini-label">DEF</span>
                            <div class="stat-mini-bar-bg"><div class="stat-mini-bar-fill" id="barDef" style="width:0%"></div></div>
                            <span class="stat-mini-val" id="valDef">0</span>
                        </div>
                        <div class="stat-mini-row">
                            <span class="stat-mini-label">HP</span>
                            <div class="stat-mini-bar-bg"><div class="stat-mini-bar-fill" id="barHp" style="width:0%"></div></div>
                            <span class="stat-mini-val" id="valHp">0</span>
                        </div>
                        <div class="stat-mini-row">
                            <span class="stat-mini-label">SPD</span>
                            <div class="stat-mini-bar-bg"><div class="stat-mini-bar-fill" id="barSpd" style="width:0%"></div></div>
                            <span class="stat-mini-val" id="valSpd">0</span>
                        </div>
                    </div>

                    <!-- 행동 우선도 슬라이더 -->
                    <div class="trait-actions-section">
                        <div class="trait-section-title">⚡ 행동 우선도 설정</div>
                        <div class="action-rows">

                            <div class="action-row atk">
                                <div class="action-label">
                                    <span class="action-name">🗡 공격</span>
                                    <span class="action-name-en">ATTACK</span>
                                </div>
                                <div class="action-slider-wrap">
                                    <input type="range" class="action-slider" id="sliderAtk"
                                           min="1" max="10" value="5" oninput="onSliderChange()">
                                </div>
                                <span class="action-value" id="numAtk">5</span>
                            </div>

                            <div class="action-row def">
                                <div class="action-label">
                                    <span class="action-name">🛡 수비</span>
                                    <span class="action-name-en">DEFEND</span>
                                </div>
                                <div class="action-slider-wrap">
                                    <input type="range" class="action-slider" id="sliderDef"
                                           min="1" max="10" value="5" oninput="onSliderChange()">
                                </div>
                                <span class="action-value" id="numDef">5</span>
                            </div>

                            <div class="action-row assist">
                                <div class="action-label">
                                    <span class="action-name">🤝 도움</span>
                                    <span class="action-name-en">ASSIST</span>
                                </div>
                                <div class="action-slider-wrap">
                                    <input type="range" class="action-slider" id="sliderAssist"
                                           min="1" max="10" value="3" oninput="onSliderChange()">
                                </div>
                                <span class="action-value" id="numAssist">3</span>
                            </div>

                            <div class="action-row harass">
                                <div class="action-label">
                                    <span class="action-name">💢 견제</span>
                                    <span class="action-name-en">HARASS</span>
                                </div>
                                <div class="action-slider-wrap">
                                    <input type="range" class="action-slider" id="sliderHarass"
                                           min="1" max="10" value="3" oninput="onSliderChange()">
                                </div>
                                <span class="action-value" id="numHarass">3</span>
                            </div>

                        </div>

                        <!-- 확률 미리보기 -->
                        <div class="prob-preview">
                            <div class="prob-preview-title">📊 행동 선택 확률 미리보기</div>
                            <div class="prob-bar">
                                <div class="prob-seg atk"    id="probAtk"></div>
                                <div class="prob-seg def"    id="probDef"></div>
                                <div class="prob-seg assist" id="probAssist"></div>
                                <div class="prob-seg harass" id="probHarass"></div>
                            </div>
                            <div class="prob-legend">
                                <span class="prob-legend-item"><span class="prob-legend-dot atk"></span><span id="legAtk">공격 --%</span></span>
                                <span class="prob-legend-item"><span class="prob-legend-dot def"></span><span id="legDef">수비 --%</span></span>
                                <span class="prob-legend-item"><span class="prob-legend-dot assist"></span><span id="legAssist">도움 --%</span></span>
                                <span class="prob-legend-item"><span class="prob-legend-dot harass"></span><span id="legHarass">견제 --%</span></span>
                            </div>
                        </div>
                    </div>

                    <!-- 저장 버튼 -->
                    <div class="trait-save-area">
                        <button class="trait-reset-btn" onclick="resetSliders()">초기화</button>
                        <button class="trait-save-btn" id="btnSave" onclick="saveTrait()">💾 저장</button>
                        <span class="save-status-msg" id="saveMsg"></span>
                    </div>

                </div><!-- /trait-edit-card -->
            </div>
        </div><!-- /detail-panel -->

    </div><!-- /trait-grid -->
</main>

<script>
const CTX = '${pageContext.request.contextPath}';
let currentSeq = null;
let currentItem = null;

// ──────────────────────────────────────────
// 선수 선택
// ──────────────────────────────────────────
function selectPlayer(el) {
    // 이전 선택 해제
    document.querySelectorAll('.trait-player-item').forEach(i => i.classList.remove('active'));
    el.classList.add('active');
    currentItem = el;
    currentSeq  = parseInt(el.dataset.seq);

    // 플레이스홀더 숨기고 편집 카드 표시
    document.getElementById('traitPlaceholder').style.display = 'none';
    const card = document.getElementById('traitEditCard');
    card.classList.add('visible');

    // 이미지 & 이름
    const img = document.getElementById('editImg');
    if (el.dataset.img) {
        img.src = el.dataset.img;
        img.style.display = '';
    } else {
        img.style.display = 'none';
    }
    document.getElementById('editName').textContent = el.dataset.name;

    // 종족/레어도/컨디션 뱃지
    const raceEl = document.getElementById('editRace');
    raceEl.textContent = el.dataset.race;
    raceEl.className = 'race-badge ' + el.dataset.race;

    const rarEl = document.getElementById('editRarity');
    rarEl.textContent = el.dataset.rarity;
    rarEl.className = 'rarity-badge ' + el.dataset.rarity;

    const cond = el.dataset.condition || 'NORMAL';
    const condEl = document.getElementById('editCond');
    const condMap = { PEAK:'🔥 PEAK', GOOD:'😊 GOOD', NORMAL:'😐 NORMAL', TIRED:'😴 TIRED', WORST:'💀 WORST' };
    condEl.textContent = condMap[cond] || cond;
    condEl.className   = 'cond-badge ' + cond;

    // 스탯 미니 바 (최대 999 기준)
    const MAX = 999;
    setStatBar('Atk', parseInt(el.dataset.atkStat)  || 0, MAX);
    setStatBar('Def', parseInt(el.dataset.defStat)  || 0, MAX);
    setStatBar('Hp',  parseInt(el.dataset.hp)       || 0, MAX);
    setStatBar('Spd', parseInt(el.dataset.spd)      || 0, MAX);

    // 슬라이더 값 설정
    setSlider('Atk',    parseInt(el.dataset.atk)    || 5);
    setSlider('Def',    parseInt(el.dataset.def)    || 5);
    setSlider('Assist', parseInt(el.dataset.assist) || 3);
    setSlider('Harass', parseInt(el.dataset.harass) || 3);

    updateProbBar();
    clearMsg();
}

function setStatBar(key, val, max) {
    const pct = Math.min(100, Math.round((val / max) * 100));
    document.getElementById('bar' + key).style.width = pct + '%';
    document.getElementById('val' + key).textContent = val;
}
function setSlider(key, val) {
    document.getElementById('slider' + key).value = val;
    document.getElementById('num'    + key).textContent = val;
}

// ──────────────────────────────────────────
// 슬라이더 변경 → 숫자 & 확률 바 갱신
// ──────────────────────────────────────────
function onSliderChange() {
    ['Atk','Def','Assist','Harass'].forEach(k => {
        document.getElementById('num' + k).textContent =
            document.getElementById('slider' + k).value;
    });
    updateProbBar();
    markUnsaved();
}

function updateProbBar() {
    const w = {
        atk:    parseInt(document.getElementById('sliderAtk').value),
        def:    parseInt(document.getElementById('sliderDef').value),
        assist: parseInt(document.getElementById('sliderAssist').value),
        harass: parseInt(document.getElementById('sliderHarass').value)
    };
    const total = w.atk + w.def + w.assist + w.harass;
    if (total === 0) return;

    const pct = k => Math.round((w[k] / total) * 100);
    const pa = pct('atk'), pd = pct('def'), pss = pct('assist'), ph = pct('harass');

    document.getElementById('probAtk').style.width    = pa  + '%';
    document.getElementById('probDef').style.width    = pd  + '%';
    document.getElementById('probAssist').style.width = pss + '%';
    document.getElementById('probHarass').style.width = ph  + '%';

    document.getElementById('probAtk').textContent    = pa  > 8 ? pa  + '%' : '';
    document.getElementById('probDef').textContent    = pd  > 8 ? pd  + '%' : '';
    document.getElementById('probAssist').textContent = pss > 8 ? pss + '%' : '';
    document.getElementById('probHarass').textContent = ph  > 8 ? ph  + '%' : '';

    document.getElementById('legAtk').textContent    = '공격 '  + pa  + '%';
    document.getElementById('legDef').textContent    = '수비 '  + pd  + '%';
    document.getElementById('legAssist').textContent = '도움 '  + pss + '%';
    document.getElementById('legHarass').textContent = '견제 '  + ph  + '%';
}

function markUnsaved() {
    if (!currentSeq) return;
    const dot = document.getElementById('dot_' + currentSeq);
    if (dot) { dot.classList.add('unsaved'); }
}

// ──────────────────────────────────────────
// 슬라이더 초기화 (기본값)
// ──────────────────────────────────────────
function resetSliders() {
    setSlider('Atk',    5);
    setSlider('Def',    5);
    setSlider('Assist', 3);
    setSlider('Harass', 3);
    updateProbBar();
    markUnsaved();
}

// ──────────────────────────────────────────
// 저장 (AJAX POST)
// ──────────────────────────────────────────
function saveTrait() {
    if (!currentSeq) return;

    const payload = {
        ownedPlayerSeq: currentSeq,
        atkWeight:      parseInt(document.getElementById('sliderAtk').value),
        defWeight:      parseInt(document.getElementById('sliderDef').value),
        assistWeight:   parseInt(document.getElementById('sliderAssist').value),
        harassWeight:   parseInt(document.getElementById('sliderHarass').value)
    };

    const btn = document.getElementById('btnSave');
    btn.disabled = true;
    btn.textContent = '저장 중...';

    fetch(CTX + '/trait/save', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            showMsg('✅ 저장 완료', false);
            // 리스트 data 속성 갱신
            if (currentItem) {
                currentItem.dataset.atk    = payload.atkWeight;
                currentItem.dataset.def    = payload.defWeight;
                currentItem.dataset.assist = payload.assistWeight;
                currentItem.dataset.harass = payload.harassWeight;
                currentItem.dataset.saved  = 'true';
            }
            const dot = document.getElementById('dot_' + currentSeq);
            if (dot) { dot.classList.remove('unsaved'); }
        } else {
            showMsg('❌ ' + (data.msg || '저장 실패'), true);
        }
    })
    .catch(e => {
        showMsg('❌ 오류 발생', true);
        console.error(e);
    })
    .finally(() => {
        btn.disabled = false;
        btn.textContent = '💾 저장';
    });
}

function showMsg(msg, isError) {
    const el = document.getElementById('saveMsg');
    el.textContent = msg;
    el.className = 'save-status-msg' + (isError ? ' error' : '');
    setTimeout(() => { el.textContent = ''; }, 3000);
}
function clearMsg() {
    document.getElementById('saveMsg').textContent = '';
}

// ── 페이지 로드 시 첫 번째 선수 자동 선택 ──
document.addEventListener('DOMContentLoaded', function() {
    const first = document.querySelector('.trait-player-item');
    if (first) selectPlayer(first);
});
</script>

<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
</body>
</html>
