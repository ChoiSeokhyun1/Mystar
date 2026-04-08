<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관리자 - 스테이지 관리</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/adminStage.css' />">
</head>
<body>

<c:set var="adminCurrentPage" value="stage" />
<%@ include file="/WEB-INF/views/layout/adminHeader.jsp" %>

<div class="admin-page-wrap">

    <div class="admin-top-bar">
        <div>
            <div style="color:#6366f1;font-size:10px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;margin-bottom:2px;">ADMIN PANEL</div>
            <h1 style="color:#e2e8f0;font-size:18px;font-weight:800;margin:0;">스테이지 &amp; 라운드 관리</h1>
        </div>
        <div style="display:flex;gap:8px;">
            <button class="btn btn-primary" onclick="addStage()">+ 스테이지 추가</button>
        </div>
    </div>

    <div class="admin-layout">

        <!-- 왼쪽 트리 -->
        <div class="stage-tree-panel" id="stageTree">
            <div class="stage-tree-header">
                <h3>스테이지 목록</h3>
                <span style="color:#4a5568;font-size:11px;">${fn:length(stageLevels)}개</span>
            </div>

            <c:choose>
                <c:when test="${empty stageLevels}">
                    <div style="padding:30px;text-align:center;color:#2d3748;font-size:13px;">
                        스테이지가 없습니다.<br>위 버튼으로 추가하세요.
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="level" items="${stageLevels}">
                        <div class="stage-item" id="stage-item-${level}">
                            <div class="stage-item-header" onclick="toggleStage(${level})">
                                <div class="stage-label">
                                    <span>⚔ STAGE ${level}</span>
                                    <span class="stage-badge">${fn:length(stageSubstageMap[level])}R</span>
                                </div>
                                <div class="stage-actions" onclick="event.stopPropagation()">
                                    <button class="btn-icon danger" onclick="confirmDeleteStage(${level})">🗑</button>
                                </div>
                            </div>
                            <div class="round-list" id="rounds-${level}">
                                <c:forEach var="sub" items="${stageSubstageMap[level]}">
                                    <div class="round-item" id="round-${level}-${sub.subLevel}"
                                         onclick="selectRound(${level}, ${sub.subLevel})">
                                        <div class="round-label">R${sub.subLevel} · <c:out value="${sub.subTitle}"/></div>
                                        <div class="round-item-actions" onclick="event.stopPropagation()">
                                            <button class="btn-icon danger" onclick="confirmDeleteRound(${level}, ${sub.subLevel})">🗑</button>
                                        </div>
                                    </div>
                                </c:forEach>
                                <button class="add-round-btn" onclick="showAddRoundModal(${level})">+ 라운드 추가</button>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- 오른쪽 디테일 -->
        <div class="detail-panel" id="detailPanel">
            <div class="detail-empty" id="detailEmpty">
                <div class="icon">🗂</div>
                <p>왼쪽에서 라운드를 선택하세요</p>
            </div>

            <div id="detailContent">
                <div class="detail-header">
                    <div class="detail-title-area">
                        <h2 id="detailTitle">–</h2>
                        <div class="detail-subtitle" id="detailSubtitle">–</div>
                    </div>
                    <div class="detail-header-actions">
                        <button class="btn btn-success" onclick="saveRoundInfo()">💾 저장</button>
                    </div>
                </div>

                <div class="detail-body">
                    <div class="round-info-card">
                        <h3>라운드 정보</h3>
                        <div class="info-row">
                            <div class="form-group">
                                <label>라운드 제목</label>
                                <input type="text" id="inputSubTitle" placeholder="예: 오프닝 매치">
                            </div>
                            <div class="form-group" style="max-width:220px;">
                                <label>상대팀 이름</label>
                                <input type="text" id="inputTeamName" placeholder="예: AI Team">
                            </div>
                        </div>
                    </div>

                    <div class="matchup-section">
                        <h3>매치업 구성 (1~5세트)</h3>
                        <div class="matchup-grid" id="matchupGrid">
                            <c:forEach begin="1" end="5" var="s">
                                <div class="matchup-slot" id="slot-${s}">
                                    <div class="slot-number">SET ${s}</div>
                                    <div class="slot-player-info" id="slot-info-${s}">
                                        <div class="slot-empty-text">미배정</div>
                                    </div>
                                    <div class="slot-actions">
                                        <button class="btn btn-sm btn-secondary" onclick="openPlayerModal(${s})">선수 선택</button>
                                        <button class="btn btn-sm btn-danger" id="remove-btn-${s}" style="display:none" onclick="removeOpponent(${s})">제거</button>
                                    </div>
                                    <div class="slot-map-row" style="margin-top:8px;display:flex;gap:6px;align-items:center;">
                                        <select id="slot-map-select-${s}"
                                            style="flex:1;background:#111827;border:1px solid #2d3748;border-radius:6px;color:#e2e8f0;padding:5px 8px;font-size:11px;cursor:pointer;">
                                            <option value="">🗺 맵 선택...</option>
                                        </select>
                                        <button class="btn btn-sm btn-secondary" onclick="assignMap(${s})">배정</button>
                                    </div>
                                    <div id="slot-map-label-${s}" style="font-size:10px;color:#6366f1;margin-top:4px;min-height:14px;"></div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<!-- 선수 선택 모달 -->
<div class="modal-overlay" id="playerModal">
    <div class="modal">
        <div class="modal-header">
            <h2 id="modalTitle">선수 선택</h2>
            <button class="modal-close" onclick="closePlayerModal()">✕</button>
        </div>

        <div class="modal-split-body">
            <!-- 좌측: 선수 목록 -->
            <div class="modal-left-col">
                <div class="modal-col-header">👤 선수 선택</div>
                <div class="modal-search">
                    <input type="text" id="playerSearch" placeholder="선수 이름 검색..." oninput="filterPlayers()">
                </div>
                <div class="modal-pack-filter">
                    <select id="packSelect" onchange="filterPlayers()" style="background:#111827;border:1px solid #2d3748;border-radius:6px;color:#e2e8f0;padding:6px 10px;font-size:12px;width:100%;cursor:pointer;">
                        <option value="">📦 전체 팩 (필터 없음)</option>
                    </select>
                </div>
                <div class="modal-filter">
                    <!-- 전체 버튼 제거됨 -->
                    <button class="filter-btn" onclick="setRaceFilter('T',this)">테란 T</button>
                    <button class="filter-btn" onclick="setRaceFilter('P',this)">프로토스 P</button>
                    <button class="filter-btn" onclick="setRaceFilter('Z',this)">저그 Z</button>
                </div>
                <div class="modal-body">
                    <table class="player-list-table">
                        <thead>
                            <tr>
                                <th>이름</th><th>종족</th><th>등급</th>
                                <th>ATK</th><th>DEF</th><th>MAC</th><th>MIC</th><th>LCK</th><th>합계</th>
                            </tr>
                        </thead>
                        <tbody id="playerTableBody"></tbody>
                    </table>
                </div>
            </div>

            <!-- 우측: 종족별 빌드 선택 -->
            <div class="modal-right-col">
                <div class="modal-col-header">🧪 빌드 설정 (종족별)</div>
                <div style="padding:20px;">
                    <div style="margin-bottom:15px;">
                        <label style="display:block;color:#00ff88;margin-bottom:8px;font-size:13px;">vs 테란 (T)</label>
                        <select id="buildSelectT" style="width:100%;background:#111827;border:1px solid #2d3748;border-radius:6px;color:#e2e8f0;padding:10px;font-size:13px;">
                            <option value="">빌드 미지정 (랜덤)</option>
                        </select>
                    </div>
                    <div style="margin-bottom:15px;">
                        <label style="display:block;color:#00ff88;margin-bottom:8px;font-size:13px;">vs 저그 (Z)</label>
                        <select id="buildSelectZ" style="width:100%;background:#111827;border:1px solid #2d3748;border-radius:6px;color:#e2e8f0;padding:10px;font-size:13px;">
                            <option value="">빌드 미지정 (랜덤)</option>
                        </select>
                    </div>
                    <div style="margin-bottom:15px;">
                        <label style="display:block;color:#00ff88;margin-bottom:8px;font-size:13px;">vs 프로토스 (P)</label>
                        <select id="buildSelectP" style="width:100%;background:#111827;border:1px solid #2d3748;border-radius:6px;color:#e2e8f0;padding:10px;font-size:13px;">
                            <option value="">빌드 미지정 (랜덤)</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>

        <!-- 하단 푸터: 선택 현황 + 배정 버튼 -->
        <div class="modal-footer">
            <div class="selected-build-label">
                선수: <span id="selectedPlayerLabel" style="color:#00ff88;font-weight:700;">미선택</span>
                &nbsp;/&nbsp;
                빌드: <span style="color:#aaa;font-size:12px;">종족별 선택 →</span>
            </div>
            <button class="btn btn-primary" id="assignBtn" disabled onclick="confirmAssign()">배정</button>
        </div>
    </div>
</div>

<!-- 라운드 추가 모달 -->
<div class="modal-overlay" id="addRoundModal">
    <div class="modal" style="width:420px;max-height:300px;">
        <div class="modal-header">
            <h2>라운드 추가</h2>
            <button class="modal-close" onclick="closeAddRoundModal()">✕</button>
        </div>
        <div style="padding:20px;">
            <div class="form-group" style="margin-bottom:14px;">
                <label>라운드 제목 *</label>
                <input type="text" id="newRoundTitle" placeholder="예: 예선 첫 경기"
                    style="width:100%;background:#111827;border:1px solid #2d3748;border-radius:6px;color:#e2e8f0;padding:8px 12px;font-size:13px;box-sizing:border-box;">
            </div>
            <div class="form-group" style="margin-bottom:20px;">
                <label>상대팀 이름</label>
                <input type="text" id="newRoundTeam" value="AI Team"
                    style="width:100%;background:#111827;border:1px solid #2d3748;border-radius:6px;color:#e2e8f0;padding:8px 12px;font-size:13px;box-sizing:border-box;">
            </div>
            <div style="display:flex;gap:10px;justify-content:flex-end;">
                <button class="btn btn-secondary" onclick="closeAddRoundModal()">취소</button>
                <button class="btn btn-primary" onclick="submitAddRound()">추가</button>
            </div>
        </div>
    </div>
</div>

<!-- 확인 모달 -->
<div class="modal-overlay" id="confirmModal">
    <div class="confirm-modal">
        <div style="font-size:36px;margin-bottom:12px;" id="confirmIcon">⚠️</div>
        <p id="confirmMsg">정말 삭제하시겠습니까?</p>
        <div class="confirm-actions">
            <button class="btn btn-secondary" onclick="closeConfirm()">취소</button>
            <button class="btn btn-danger" id="confirmOkBtn">삭제</button>
        </div>
    </div>
</div>

<div class="toast" id="toast"></div>

<!-- ===== 빌드 관리 모달 ===== -->
<div class="modal-overlay" id="buildManagerModal">
    <div class="modal" style="width:920px;max-height:88vh;">
        <div class="modal-header">
            <h2 id="buildManagerTitle">🧪 AI 빌드 관리</h2>
            <button class="modal-close" onclick="closeBuildManagerModal()">✕</button>
        </div>
        <div class="modal-split-body" style="height:calc(88vh - 60px);">

            <!-- 좌측: 빌드 목록 -->
            <div class="modal-left-col" style="width:280px;flex:none;">
                <div class="modal-col-header" style="display:flex;justify-content:space-between;align-items:center;">
                    <span>빌드 목록</span>
                    <button class="btn btn-primary" style="font-size:11px;padding:3px 10px;" onclick="openBuildForm(0)">+ 새 빌드</button>
                </div>
                <div style="padding:8px;border-bottom:1px solid #1e293b;display:flex;gap:4px;" id="buildListRaceFilter">
                    <button class="filter-btn active" onclick="setBuildListFilter('ALL',this)">전체</button>
                    <button class="filter-btn" onclick="setBuildListFilter('T',this)">T</button>
                    <button class="filter-btn" onclick="setBuildListFilter('P',this)">P</button>
                    <button class="filter-btn" onclick="setBuildListFilter('Z',this)">Z</button>
                </div>
                <div style="flex:1;overflow-y:auto;padding:6px;display:flex;flex-direction:column;gap:4px;" id="buildManagerList"></div>
            </div>

            <!-- 우측: 빌드 폼 -->
            <div class="modal-right-col" style="flex:1;width:auto;background:#0a1020;">
                <div id="buildFormPlaceholder" style="flex:1;display:flex;align-items:center;justify-content:center;color:#2d3748;font-size:13px;">
                    ← 빌드를 선택하거나 새 빌드를 만드세요
                </div>
                <div id="buildFormPanel" style="display:none;flex-direction:column;height:100%;">
                    <div class="modal-col-header" style="display:flex;justify-content:space-between;align-items:center;">
                        <span id="buildFormPanelTitle">새 빌드 생성</span>
                        <div style="display:flex;gap:6px;">
                            <button class="btn btn-danger" id="buildDeleteBtn" style="font-size:11px;padding:3px 10px;display:none;" onclick="deleteBuildFromManager()">🗑 삭제</button>
                            <button class="btn btn-primary" style="font-size:11px;padding:3px 10px;" onclick="saveBuildFromManager()">💾 저장</button>
                        </div>
                    </div>
                    <div style="flex:1;overflow-y:auto;padding:14px;display:flex;flex-direction:column;gap:12px;">

                        <!-- 기본 정보 -->
                        <input type="hidden" id="bfBuildId">
                        <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;">
                            <div style="grid-column:1/-1;">
                                <label class="bf-label">빌드 이름</label>
                                <input type="text" id="bfName" class="bf-input" placeholder="예: 5배럭 마린메딕 러시">
                            </div>
                            <div>
                                <label class="bf-label">종족</label>
                                <select id="bfRace" class="bf-select" onchange="bfUpdateUnits()">
                                    <option value="">선택</option>
                                    <option value="T">테란 (T)</option>
                                    <option value="Z">저그 (Z)</option>
                                    <option value="P">프로토스 (P)</option>
                                </select>
                            </div>
                            <div>
                                <label class="bf-label">상대 종족</label>
                                <select id="bfVsRace" class="bf-select">
                                    <option value="A">공통 (ALL)</option>
                                    <option value="T">vs 테란</option>
                                    <option value="Z">vs 저그</option>
                                    <option value="P">vs 프로토스</option>
                                </select>
                            </div>
                            <div>
                                <label class="bf-label">플레이 스타일</label>
                                <select id="bfPlayStyle" class="bf-select">
                                    <option value="AGGRESSIVE" selected>⚔️ 공격 스타일</option>
                                    <option value="NORMAL">⚖️ 일반 스타일</option>
                                    <option value="DEFENSIVE">🛡️ 수비 스타일</option>
                                </select>
                            </div>
                            <div>
                                <label class="bf-label">견제 성향</label>
                                <select id="bfHarassStyle" class="bf-select">
                                    <option value="NO_HARASS">🚫 견제 안 함</option>
                                    <option value="NORMAL_HARASS" selected>🐝 일반 견제 (2~6회)</option>
                                    <option value="HEAVY_HARASS">🔥 강한 견제 (7~11회)</option>
                                </select>
                            </div>
                            <div>
                                <label class="bf-label">확장 성향</label>
                                <select id="bfAggression" class="bf-select">
                                    <option value="MIN_MULTI">🏠 최소 멀티</option>
                                    <option value="MID_MULTI" selected>⚖️ 중간 멀티</option>
                                    <option value="MAX_MULTI">💰 최대 멀티</option>
                                </select>
                            </div>
                            <div style="grid-column:1/-1;">
                                <label class="bf-label">최종 테크 제한</label>
                                <select id="bfMaxTier" class="bf-select">
                                    <option value="1">🔰 1티어</option>
                                    <option value="2">⚙️ 2티어</option>
                                    <option value="3" selected>🚀 3티어 (전체)</option>
                                </select>
                            </div>
                        </div>

                        <!-- 선호 유닛 -->
                        <div>
                            <label class="bf-label">⭐ 선호 유닛 <span style="color:#555;font-weight:400;font-size:0.75rem;">(최대 5개)</span></label>
                            <input type="hidden" id="bfPreferredUnits" value="">
                            <div id="bfUnitGrid" style="display:flex;flex-wrap:wrap;gap:6px;margin-top:6px;min-height:32px;"></div>
                            <div id="bfSelectedUnits" style="display:flex;flex-wrap:wrap;gap:5px;margin-top:6px;"></div>
                        </div>

                        <!-- 선호 건물 -->
                        <div>
                            <label class="bf-label">🏗 선호 건물 <span style="color:#555;font-weight:400;font-size:0.75rem;">(수량 설정)</span></label>
                            <input type="hidden" id="bfPreferredBuildings" value="">
                            <div id="bfBuildingGrid" style="margin-top:6px;"></div>
                        </div>

                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- ===== Controller가 생성한 JSON을 그대로 출력 (fn:replace 없음) ===== --%>
<script id="mapDataScript" type="application/json">
${mapJsonData}
</script>

<script id="playerDataScript" type="application/json">
${playerJsonData}
</script>

<script id="roundDataScript" type="application/json">
${roundJsonData}
</script>

<script id="packDataScript" type="application/json">
${packJsonData}
</script>

<script id="buildDataScript" type="application/json">
${buildJsonData}
</script>

<script>
var ALL_PLAYERS = [];
var ROUND_MAP   = {};
var ALL_PACKS   = [];
var ALL_BUILDS  = [];
var ALL_MAPS    = [];
try {
    var pd  = document.getElementById('playerDataScript');
    var rd  = document.getElementById('roundDataScript');
    var pkd = document.getElementById('packDataScript');
    var bdd = document.getElementById('buildDataScript');
    var mpd = document.getElementById('mapDataScript');
    if (pd)  ALL_PLAYERS = JSON.parse(pd.textContent || pd.innerHTML);
    if (rd)  ROUND_MAP   = JSON.parse(rd.textContent || rd.innerHTML);
    if (pkd) ALL_PACKS   = JSON.parse(pkd.textContent || pkd.innerHTML);
    if (bdd) ALL_BUILDS  = JSON.parse(bdd.textContent || bdd.innerHTML);
    if (mpd) ALL_MAPS    = JSON.parse(mpd.textContent || mpd.innerHTML);
} catch(e) { console.error('데이터 파싱 오류:', e); }

/* ============================================================
   전역 상태
   ============================================================ */
var currentStageLevel  = null;
var currentSubLevel    = null;
var currentSetSlot     = null;
var addRoundStageLevel = null;
var confirmCallback    = null;
var raceFilter         = 'T';  // 기본값을 T로 변경
var selectedPlayerSeq  = null;
var selectedBuildIdT   = null;
var selectedBuildIdZ   = null;
var selectedBuildIdP   = null;
var slotData           = {1:null,2:null,3:null,4:null,5:null};

/* ============================================================
   스테이지 토글
   ============================================================ */
function toggleStage(level) {
    var rounds = document.getElementById('rounds-' + level);
    var header = rounds.previousElementSibling;
    var open   = rounds.classList.contains('expanded');
    rounds.classList.toggle('expanded', !open);
    header.classList.toggle('active', !open);
}

/* ============================================================
   라운드 선택
   ============================================================ */
function selectRound(stageLevel, subLevel) {
    currentStageLevel = stageLevel;
    currentSubLevel   = subLevel;

    var info     = (ROUND_MAP[stageLevel] && ROUND_MAP[stageLevel][subLevel]) || {};
    var subTitle = info.title || '';
    var teamName = info.team  || '';

    document.querySelectorAll('.round-item.selected').forEach(function(el){ el.classList.remove('selected'); });
    var el = document.getElementById('round-' + stageLevel + '-' + subLevel);
    if (el) el.classList.add('selected');

    document.getElementById('detailTitle').textContent    = 'STAGE ' + stageLevel + ' - ROUND ' + subLevel;
    document.getElementById('detailSubtitle').textContent = subTitle;
    document.getElementById('inputSubTitle').value        = subTitle;
    document.getElementById('inputTeamName').value        = teamName;

    document.getElementById('detailEmpty').style.display = 'none';
    document.getElementById('detailContent').classList.add('active');

    for (var i = 1; i <= 5; i++) { slotData[i] = null; renderSlot(i); }
    loadOpponents(stageLevel, subLevel);
    loadMaps(stageLevel, subLevel);
}

/* ============================================================
   세트별 맵 로드 / 배정
   ============================================================ */
function loadMaps(stageLevel, subLevel) {
    // 맵 라벨 초기화
    for (var i = 1; i <= 5; i++) {
        document.getElementById('slot-map-label-' + i).textContent = '';
        document.getElementById('slot-map-select-' + i).value = '';
    }
    fetch('<c:url value="/admin/round/maps"/>?stageLevel=' + stageLevel + '&subLevel=' + subLevel)
        .then(function(r){ return r.json(); })
        .then(function(data) {
            if (!data.success || !data.maps) return;
            data.maps.forEach(function(m) {
                var n = m.setNumber;
                if (n >= 1 && n <= 5) {
                    var sel = document.getElementById('slot-map-select-' + n);
                    if (sel) sel.value = m.mapId;
                    renderMapLabel(n, m.mapId, m.mapName);
                }
            });
        })
        .catch(function(e){ console.error(e); });
}

function renderMapLabel(setNum, mapId, mapName) {
    var label = document.getElementById('slot-map-label-' + setNum);
    if (!label) return;
    label.textContent = mapId ? ('🗺 ' + mapName) : '';
}

function assignMap(setNum) {
    if (!currentStageLevel) { showToast('라운드를 먼저 선택하세요', 'error'); return; }
    var sel = document.getElementById('slot-map-select-' + setNum);
    var mapId = sel ? sel.value : '';
    if (!mapId) {
        // 맵 선택 해제 → 제거
        fetchPost('<c:url value="/admin/round/map/remove"/>', {
            stageLevel: currentStageLevel, subLevel: currentSubLevel, setNumber: setNum
        }, function(data) {
            if (data.success) { renderMapLabel(setNum, '', ''); showToast('SET ' + setNum + ' 맵 제거됨', 'success'); }
            else showToast(data.message || '실패', 'error');
        });
        return;
    }
    var found = ALL_MAPS.filter(function(m){ return m.id === mapId; })[0];
    fetchPost('<c:url value="/admin/round/map/assign"/>', {
        stageLevel: currentStageLevel, subLevel: currentSubLevel, setNumber: setNum, mapId: mapId
    }, function(data) {
        if (data.success) {
            renderMapLabel(setNum, mapId, found ? found.name : mapId);
            showToast('SET ' + setNum + ' 맵 배정 ✓', 'success');
        } else { showToast(data.message || '맵 배정 실패', 'error'); }
    });
}

/* ============================================================
   AI 선수 로드
   ============================================================ */
function loadOpponents(stageLevel, subLevel) {
    fetch('<c:url value="/admin/round/opponents"/>?stageLevel=' + stageLevel + '&subLevel=' + subLevel)
        .then(function(r){ return r.json(); })
        .then(function(data) {
            if (!data.success || !data.opponents) return;
            data.opponents.forEach(function(opp) {
                if (opp.setNumber >= 1 && opp.setNumber <= 5) {
                    slotData[opp.setNumber] = opp;
                    renderSlot(opp.setNumber);
                }
            });
        })
        .catch(function(e){ console.error(e); });
}

/* ============================================================
   슬롯 렌더링 (innerHTML 사용 - EL 없음)
   ============================================================ */
var RACE_ICON = {T:'🔵',P:'💜',Z:'🟢'};

function renderSlot(n) {
    var info   = document.getElementById('slot-info-' + n);
    var slotEl = document.getElementById('slot-' + n);
    var rmBtn  = document.getElementById('remove-btn-' + n);
    var p = slotData[n];

    if (!p) {
        slotEl.classList.remove('filled');
        rmBtn.style.display = 'none';
        info.innerHTML = '<div class="slot-empty-text">미배정</div>';
        return;
    }
    slotEl.classList.add('filled');
    rmBtn.style.display = 'inline-block';
    var total = (p.statAttack||0)+(p.statDefense||0)+(p.statMacro||0)+(p.statMicro||0)+(p.statLuck||0);
    var buildLabel = '';
    var buildLabel = '';
    var buildInfo = [];
    
    if (p.buildIdVsT) {
        var bt = ALL_BUILDS.find(function(b){ return b.id == p.buildIdVsT; });
        if (bt) buildInfo.push('T:' + bt.name);
    }
    if (p.buildIdVsZ) {
        var bz = ALL_BUILDS.find(function(b){ return b.id == p.buildIdVsZ; });
        if (bz) buildInfo.push('Z:' + bz.name);
    }
    if (p.buildIdVsP) {
        var bp = ALL_BUILDS.find(function(b){ return b.id == p.buildIdVsP; });
        if (bp) buildInfo.push('P:' + bp.name);
    }
    
    if (buildInfo.length > 0) {
        buildLabel = '<div style=\"font-size:11px;color:#6366f1;margin-top:4px;padding:2px 6px;background:rgba(99,102,241,0.15);border-radius:4px;display:inline-block;\">🧪 ' + buildInfo.join(' / ') + '</div>';
    } else {
        buildLabel = '<div style=\"font-size:11px;color:#64748b;margin-top:4px;padding:2px 6px;background:rgba(100,116,139,0.15);border-radius:4px;display:inline-block;\">🎲 빌드 없음 (랜덤)</div>';
    }
        '<div class="slot-player-race">' + (RACE_ICON[p.race]||'?') + '</div>' +
        '<div class="slot-player-name">' + safeStr(p.playerName) + '</div>' +
        '<span class="slot-player-rarity rarity-' + (p.rarity||'N') + '">' + (p.rarity||'N') + '</span>' +
        '<div class="slot-stats">ATK ' + (p.statAttack||0) + ' / DEF ' + (p.statDefense||0) + '<br>합계 ' + total + '</div>' +
        buildLabel;
}

/* ============================================================
   저장
   ============================================================ */
function saveRoundInfo() {
    if (!currentStageLevel) { showToast('라운드를 먼저 선택하세요','error'); return; }
    var subTitle = document.getElementById('inputSubTitle').value.trim();
    var teamName = document.getElementById('inputTeamName').value.trim();
    if (!subTitle) { showToast('라운드 제목을 입력하세요','error'); return; }

    fetchPost('<c:url value="/admin/round/edit"/>', {
        stageLevel: currentStageLevel, subLevel: currentSubLevel,
        subTitle: subTitle, opponentTeamName: teamName
    }, function(data) {
        if (data.success) {
            showToast('저장됨 ✓','success');
            var el = document.getElementById('round-'+currentStageLevel+'-'+currentSubLevel);
            if (el) el.querySelector('.round-label').textContent = 'R' + currentSubLevel + ' · ' + subTitle;
            document.getElementById('detailSubtitle').textContent = subTitle;
            if (ROUND_MAP[currentStageLevel] && ROUND_MAP[currentStageLevel][currentSubLevel]) {
                ROUND_MAP[currentStageLevel][currentSubLevel].title = subTitle;
                ROUND_MAP[currentStageLevel][currentSubLevel].team  = teamName;
            }
        } else { showToast(data.message||'저장 실패','error'); }
    });
}

/* ============================================================
   스테이지 추가/삭제
   ============================================================ */
function addStage() {
    fetchPost('<c:url value="/admin/stage/add"/>', {}, function(data) {
        if (data.success) { showToast('STAGE '+data.newLevel+' 추가됨','success'); reload(); }
        else               showToast(data.message||'실패','error');
    });
}
function confirmDeleteStage(level) {
    showConfirm('⚠️','<strong>STAGE '+level+'</strong> 및 모든 라운드를 삭제합니다.',
        function(){ fetchPost('<c:url value="/admin/stage/delete"/>', {stageLevel:level}, function(d){
            if(d.success){ showToast('삭제됨','success'); reload(); } else showToast(d.message||'실패','error');
        }); }
    );
}

/* ============================================================
   라운드 추가/삭제
   ============================================================ */
function showAddRoundModal(level) {
    addRoundStageLevel = level;
    document.getElementById('newRoundTitle').value = '';
    document.getElementById('newRoundTeam').value  = 'AI Team';
    document.getElementById('addRoundModal').classList.add('visible');
    setTimeout(function(){ document.getElementById('newRoundTitle').focus(); }, 100);
}
function closeAddRoundModal() { document.getElementById('addRoundModal').classList.remove('visible'); }
function submitAddRound() {
    var t = document.getElementById('newRoundTitle').value.trim();
    var n = document.getElementById('newRoundTeam').value.trim() || 'AI Team';
    if (!t) { showToast('제목을 입력하세요','error'); return; }
    fetchPost('<c:url value="/admin/round/add"/>', {stageLevel:addRoundStageLevel,subTitle:t,opponentTeamName:n}, function(d){
        if(d.success){ showToast('라운드 '+d.newSubLevel+' 추가됨','success'); closeAddRoundModal(); reload(); }
        else showToast(d.message||'실패','error');
    });
}
function confirmDeleteRound(level, subLevel) {
    showConfirm('⚠️','<strong>STAGE '+level+' R'+subLevel+'</strong> 라운드를 삭제합니다.',
        function(){ fetchPost('<c:url value="/admin/round/delete"/>', {stageLevel:level,subLevel:subLevel}, function(d){
            if(d.success){ showToast('삭제됨','success'); reload(); } else showToast(d.message||'실패','error');
        }); }
    );
}

/* ============================================================
   선수 모달 (2단: 좌=선수, 우=빌드)
   ============================================================ */
function openPlayerModal(setNum) {
    currentSetSlot = setNum;
    selectedPlayerSeq = null;
    selectedBuildIdT = null;
    selectedBuildIdZ = null;
    selectedBuildIdP = null;
    
    document.getElementById('modalTitle').textContent = '선수 선택 — SET ' + setNum;
    document.getElementById('playerSearch').value = '';
    document.getElementById('packSelect').value = '';
    document.getElementById('selectedPlayerLabel').textContent = '미선택';
    document.getElementById('assignBtn').disabled = true;
    
    // 빌드 셀렉트박스 초기화
    document.getElementById('buildSelectT').value = '';
    document.getElementById('buildSelectZ').value = '';
    document.getElementById('buildSelectP').value = '';
    
    // 기존 데이터 로드
    var existingOpp = slotData[setNum];
    if (existingOpp && existingOpp.playerSeq) {
        selectedPlayerSeq = existingOpp.playerSeq;
        selectedBuildIdT = existingOpp.buildIdVsT || null;
        selectedBuildIdZ = existingOpp.buildIdVsZ || null;
        selectedBuildIdP = existingOpp.buildIdVsP || null;
        
        var player = ALL_PLAYERS.find(function(p){ return p.seq === selectedPlayerSeq; });
        if (player) {
            document.getElementById('selectedPlayerLabel').textContent = player.name;
            document.getElementById('assignBtn').disabled = false;
            
            if (selectedBuildIdT) document.getElementById('buildSelectT').value = selectedBuildIdT;
            if (selectedBuildIdZ) document.getElementById('buildSelectZ').value = selectedBuildIdZ;
            if (selectedBuildIdP) document.getElementById('buildSelectP').value = selectedBuildIdP;
        }
    }
    
    raceFilter = 'T';
    document.querySelectorAll('.modal-left-col .filter-btn').forEach(function(b,i){ 
        b.classList.toggle('active', i===0); 
    });
    
    renderPlayerTable();
    loadBuildOptions();
    document.getElementById('playerModal').classList.add('visible');
}
function closePlayerModal() { document.getElementById('playerModal').classList.remove('visible'); }

function setRaceFilter(race, btn) {
    raceFilter = race;
    document.querySelectorAll('.modal-left-col .filter-btn').forEach(function(b){ b.classList.remove('active'); });
    btn.classList.add('active');
    renderPlayerTable();
}
function loadBuildOptions() {
    var selectT = document.getElementById('buildSelectT');
    var selectZ = document.getElementById('buildSelectZ');
    var selectP = document.getElementById('buildSelectP');
    
    selectT.innerHTML = '<option value="">빌드 미지정 (랜덤)</option>';
    selectZ.innerHTML = '<option value="">빌드 미지정 (랜덤)</option>';
    selectP.innerHTML = '<option value="">빌드 미지정 (랜덤)</option>';
    
    if (!selectedPlayerSeq) return;
    
    var player = ALL_PLAYERS.find(function(p){ return p.seq === selectedPlayerSeq; });
    if (!player) return;
    
    var playerRace = player.race;
    
    ALL_BUILDS.forEach(function(build){
        if (build.race === playerRace) {
            var opt = document.createElement('option');
            opt.value = build.id;
            opt.textContent = build.name;
            
            selectT.appendChild(opt.cloneNode(true));
            selectZ.appendChild(opt.cloneNode(true));
            selectP.appendChild(opt.cloneNode(true));
        }
    });
    
    selectT.onchange = function(){ selectedBuildIdT = this.value || null; };
    selectZ.onchange = function(){ selectedBuildIdZ = this.value || null; };
    selectP.onchange = function(){ selectedBuildIdP = this.value || null; };
}
function filterPlayers() { renderPlayerTable(); }

function renderPlayerTable() {
    var q = document.getElementById('playerSearch').value.trim().toLowerCase();
    var tbody = document.getElementById('playerTableBody');
    var rLabel = {T:'<span class="race-T">테란</span>',P:'<span class="race-P">프로토스</span>',Z:'<span class="race-Z">저그</span>'};

    var packSeq = parseInt(document.getElementById('packSelect').value) || 0;
    var packSeqSet = null;
    if (packSeq > 0) {
        var found = ALL_PACKS.filter(function(pk){ return pk.seq === packSeq; });
        if (found.length > 0) packSeqSet = found[0].players;
    }
    var list = ALL_PLAYERS.filter(function(p){
        var raceOk = (raceFilter==='ALL'||p.race===raceFilter);
        var nameOk = (!q||p.name.toLowerCase().indexOf(q)>=0);
        var packOk = !packSeqSet || packSeqSet.indexOf(p.seq) >= 0;
        return raceOk && nameOk && packOk;
    });

    tbody.innerHTML = list.map(function(p){
        var tot = p.atk+p.def+p.mac+p.mic+p.lck;
        var sel = (p.seq === selectedPlayerSeq);
        return '<tr onclick="selectPlayerRow('+p.seq+')" style="cursor:pointer;'+(sel?'background:rgba(0,230,118,0.07);':'')+'">'
            +'<td class="player-name-cell">'+(sel?'<span style="color:#00e676">✔ </span>':'')+safeStr(p.name)+'</td>'
            +'<td>'+(rLabel[p.race]||p.race)+'</td>'
            +'<td><span class="slot-player-rarity rarity-'+p.rarity+'">'+p.rarity+'</span></td>'
            +'<td style="color:#f87171">'+p.atk+'</td>'
            +'<td style="color:#60a5fa">'+p.def+'</td>'
            +'<td style="color:#34d399">'+p.mac+'</td>'
            +'<td style="color:#fbbf24">'+p.mic+'</td>'
            +'<td style="color:#a78bfa">'+p.lck+'</td>'
            +'<td style="color:#94a3b8;font-weight:700">'+tot+'</td>'
            +'</tr>';
    }).join('');
}

function selectPlayerRow(seq) {
    selectedPlayerSeq = seq;
    document.getElementById('assignBtn').disabled = false;

    var p = ALL_PLAYERS.filter(function(p){ return p.seq === seq; })[0];
    if (p) {
        document.getElementById('selectedPlayerLabel').textContent = p.name + ' (' + p.race + ')';
        
        // 빌드 옵션 재로드
        selectedBuildIdT = null;
        selectedBuildIdZ = null;
        selectedBuildIdP = null;
        loadBuildOptions();
    }

    renderPlayerTable();
}


function confirmAssign() {
    if (!selectedPlayerSeq) { showToast('선수를 먼저 선택하세요','error'); return; }
    
    var p = ALL_PLAYERS.find(function(pl){ return pl.seq === selectedPlayerSeq; });
    if (!p) return;
    
    // slotData 업데이트
    slotData[currentSetSlot] = {
        playerSeq: selectedPlayerSeq,
        playerName: p.name,
        race: p.race,
        rarity: p.rarity,
        setNumber: currentSetSlot,
        buildIdVsT: selectedBuildIdT,
        buildIdVsZ: selectedBuildIdZ,
        buildIdVsP: selectedBuildIdP
    };
    
    // UI 업데이트
    renderSlot(currentSetSlot);
    closePlayerModal();
    
    var buildInfo = [];
    if (selectedBuildIdT) {
        var bt = ALL_BUILDS.find(function(b){ return b.id == selectedBuildIdT; });
        if (bt) buildInfo.push('T:'+bt.name);
    }
    if (selectedBuildIdZ) {
        var bz = ALL_BUILDS.find(function(b){ return b.id == selectedBuildIdZ; });
        if (bz) buildInfo.push('Z:'+bz.name);
    }
    if (selectedBuildIdP) {
        var bp = ALL_BUILDS.find(function(b){ return b.id == selectedBuildIdP; });
        if (bp) buildInfo.push('P:'+bp.name);
    }
    
    var msg = 'SET '+currentSetSlot+' 배정 완료 ✓';
    if (buildInfo.length > 0) msg += ' ['+buildInfo.join(' / ')+']';
    showToast(msg, 'success');
}
function removeOpponent(setNum) {
    if (!currentStageLevel) return;
    fetchPost('<c:url value="/admin/round/opponent/remove"/>', {
        stageLevel:currentStageLevel, subLevel:currentSubLevel, setNumber:setNum
    }, function(data){
        if(data.success){ slotData[setNum]=null; renderSlot(setNum); showToast('SET '+setNum+' 제거됨','success'); }
        else showToast(data.message||'실패','error');
    });
}

/* ============================================================
   확인 모달
   ============================================================ */
function showConfirm(icon, msg, cb) {
    document.getElementById('confirmIcon').textContent = icon;
    document.getElementById('confirmMsg').innerHTML = msg;
    confirmCallback = cb;
    document.getElementById('confirmModal').classList.add('visible');
}
function closeConfirm() {
    document.getElementById('confirmModal').classList.remove('visible');
    confirmCallback = null;
}
document.getElementById('confirmOkBtn').addEventListener('click', function(){
    var cb = confirmCallback;  // 먼저 저장
    closeConfirm();            // null로 초기화
    if (cb) cb();              // 저장해둔 콜백 실행
});

/* ============================================================
   토스트
   ============================================================ */
var _tt = null;
function showToast(msg, type) {
    var t = document.getElementById('toast');
    t.textContent = msg;
    t.className = 'toast ' + (type||'') + ' show';
    clearTimeout(_tt);
    _tt = setTimeout(function(){ t.classList.remove('show'); }, 3000);
}

/* ============================================================
   유틸
   ============================================================ */
function fetchPost(url, body, cb) {
    fetch(url, {method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(body)})
        .then(function(r){ return r.json(); })
        .then(cb)
        .catch(function(e){ console.error(e); showToast('서버 오류','error'); });
}
function safeStr(s) {
    return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}
function reload() { setTimeout(function(){ location.reload(); }, 700); }

/* 키보드 */
document.addEventListener('keydown', function(e){
    if(e.key==='Escape'){ closePlayerModal(); closeAddRoundModal(); closeConfirm(); }
});

/* 팩 셀렉트 옵션 채우기 */
(function() {
    var sel = document.getElementById('packSelect');
    if (!sel) return;
    ALL_PACKS.forEach(function(pk) {
        var opt = document.createElement('option');
        opt.value = pk.seq;
        opt.textContent = '📦 ' + pk.name;
        sel.appendChild(opt);
    });
})();

/* 맵 셀렉트 옵션 채우기 (슬롯 1~5) */
(function() {
    for (var s = 1; s <= 5; s++) {
        var sel = document.getElementById('slot-map-select-' + s);
        if (!sel) continue;
        ALL_MAPS.forEach(function(m) {
            var opt = document.createElement('option');
            opt.value = m.id;
            opt.textContent = '🗺 ' + m.name;
            sel.appendChild(opt);
        });
    }
})();

/* 첫 스테이지 자동 펼치기 */
document.addEventListener('DOMContentLoaded', function(){
    var first = document.querySelector('.stage-item-header');
    if (first) first.click();
});

/* ============================================================
   빌드 관리 모달
   ============================================================ */
var buildListFilter  = 'ALL';
var editingBuildId   = null;

var unitDict = {
    T: [
        {id:'marine',  name:'마린 (티어1)'},
        {id:'medic',   name:'메딕 (티어1·아카데미)'},
        {id:'firebat', name:'파이어뱃 (티어1·아카데미)'},
        {id:'vulture', name:'벌처 (티어2·팩토리)'},
        {id:'tank',    name:'탱크 (티어2·팩토리+머신샵)'},
        {id:'goliath', name:'골리앗 (티어2·팩토리+아머리)'},
        {id:'wraith',  name:'레이스 (티어2·스타포트)'},
        {id:'dropship',name:'드랍쉽 (티어2·스타포트)'},
        {id:'ghost',        name:'고스트 (티어3·뉴클리어어댑터)'},
        {id:'vessel',       name:'사이언스베슬 (티어3·사이언스퍼실리티)'},
        {id:'battlecruiser',name:'배틀크루저 (티어3·배틀어댑터)'}
    ],
    Z: [{id:'zergling',name:'저글링'},{id:'hydralisk',name:'히드라리스크'},{id:'lurker',name:'럴커'},{id:'mutalisk',name:'뮤탈리스크'},{id:'ultralisk',name:'울트라리스크'}],
    P: [{id:'zealot',name:'질럿'},{id:'dragoon',name:'드라군'},{id:'high_templar',name:'하이템플러'},{id:'dark_templar',name:'다크템플러'},{id:'shuttle',name:'셔틀'},{id:'reaver',name:'리버'},{id:'corsair',name:'커세어'},{id:'scout',name:'스카우트'},{id:'carrier',name:'캐리어'},{id:'arbiter',name:'아비터'}]
};

function openBuildManagerModal() {
    renderBuildManagerList();
    openBuildForm(null);  // 폼 초기화
    document.getElementById('buildManagerModal').classList.add('visible');
}
function closeBuildManagerModal() {
    document.getElementById('buildManagerModal').classList.remove('visible');
    // ALL_BUILDS를 서버에서 갱신
    reloadBuildData();
}

function reloadBuildData() {
    fetch('<c:url value="/admin/builds/json"/>')
        .then(function(r){ return r.json(); })
        .then(function(data){ if (data && data.builds) ALL_BUILDS = data.builds; })
        .catch(function(){});
}

function setBuildListFilter(race, btn) {
    buildListFilter = race;
    document.querySelectorAll('#buildListRaceFilter .filter-btn').forEach(function(b){ b.classList.remove('active'); });
    btn.classList.add('active');
    renderBuildManagerList();
}

function renderBuildManagerList() {
    var MULTI_LABEL2 = {MIN_MULTI:'🏠최소멀티', MID_MULTI:'⚖️중간멀티', MAX_MULTI:'💰최대멀티'};
    var list = ALL_BUILDS.filter(function(b){
        return buildListFilter === 'ALL' || b.race === buildListFilter;
    });
    var html = list.length === 0
        ? '<div style="color:#2d3748;font-size:12px;text-align:center;padding:2rem;">빌드 없음</div>'
        : list.map(function(b){
            var active = (editingBuildId === b.id) ? ' active' : '';
            var aggr  = b.aggression || b.AGGRESSION || '';
            var vsRace = b.vsRace || b.vsrace || b.VSRACE || 'A';
            var vsLabel = (vsRace === 'A' || vsRace === 'ALL') ? 'ALL' : vsRace;
            var agTag  = '<span class="build-tag agg">'+(MULTI_LABEL2[aggr]||aggr||'-')+'</span>';
            var vsTag  = '<span class="build-tag race-'+vsRace+'">vs '+vsLabel+'</span>';
            return '<div class="build-manager-item'+active+'" onclick="openBuildForm('+b.id+')">'
                + '<div class="build-manager-item-name">'+safeStr(b.name)+'</div>'
                + '<div class="build-manager-item-tags">'
                + '<span class="build-tag race-'+b.race+'">'+b.race+'</span>'
                + vsTag + agTag
                + '</div></div>';
        }).join('');
    document.getElementById('buildManagerList').innerHTML = html;
}

/* ── 빌드 폼용 유닛/건물 데이터 ── */
var BF_UNIT_DATA = {
    T:[{id:'marine',name:'마린',emoji:'🪖'},{id:'firebat',name:'파이어뱃',emoji:'🔥'},{id:'medic',name:'메딕',emoji:'💊'},
       {id:'vulture',name:'벌처',emoji:'🏍️'},{id:'tank',name:'탱크',emoji:'🛡️'},{id:'goliath',name:'골리앗',emoji:'🤖'},
       {id:'wraith',name:'레이스',emoji:'✈️'},{id:'ghost',name:'고스트',emoji:'👻'},{id:'vessel',name:'베슬',emoji:'🛸'},
       {id:'battlecruiser',name:'배틀크루저',emoji:'🚀'}],
    Z:[{id:'zergling',name:'저글링',emoji:'🦎'},{id:'hydralisk',name:'히드라',emoji:'🐍'},
       {id:'lurker',name:'러커',emoji:'🦟'},{id:'mutalisk',name:'뮤탈',emoji:'🦇'},
       {id:'scourge',name:'스컬지',emoji:'💀'},{id:'queen',name:'퀸',emoji:'👑'},
       {id:'guardian',name:'가디언',emoji:'🛡️'},{id:'devourer',name:'디바우러',emoji:'🌀'},
       {id:'ultralisk',name:'울트라리스크',emoji:'🦏'},{id:'defiler',name:'디파일러',emoji:'☠️'}],
    P:[{id:'zealot',name:'질럿',emoji:'⚔️'},{id:'dragoon',name:'드라군',emoji:'🤺'},{id:'high_templar',name:'하이템플러',emoji:'⚡'},{id:'dark_templar',name:'다크템플러',emoji:'🌑'},{id:'shuttle',name:'셔틀',emoji:'🚁'},{id:'reaver',name:'리버',emoji:'🥚'},{id:'corsair',name:'커세어',emoji:'🛩️'},{id:'scout',name:'스카우트',emoji:'🛸'},{id:'carrier',name:'캐리어',emoji:'🚀'},{id:'arbiter',name:'아비터',emoji:'⭐'}]
};
var BF_BUILDING_DATA = {
    T:[{id:'barracks',name:'배럭스'},{id:'academy',name:'아카데미'},{id:'factory',name:'팩토리'},
       {id:'machine_shop',name:'머신샵'},{id:'armory',name:'아머리'},{id:'starport',name:'스타포트'},
       {id:'science_facility',name:'사이언스 퍼실리티'}],
    Z:[{id:'spawning_pool',name:'스포닝풀'},{id:'hydralisk_den',name:'히드라덴'},
       {id:'lair',name:'레어'},{id:'spire',name:'스파이어'},{id:'queens_nest',name:'퀸즈 네스트'},
       {id:'hive',name:'하이브'},{id:'greater_spire',name:'그레이트 스파이어'},
       {id:'defiler_mound',name:'디파일러 마운드'},{id:'ultralisk_cavern',name:'울트라리스크 케이번'}],
    P:[{id:'gateway',name:'게이트웨이'},{id:'cybernetics_core',name:'사이버코어'},
       {id:'citadel_of_adun',name:'시타델 아둔'},{id:'templar_archives',name:'템플러 아카이브'},
       {id:'robotics_facility',name:'로보틱스 퍼실리티'},{id:'robotics_support_bay',name:'로보틱스 서포트베이'},
       {id:'stargate',name:'스타게이트'},{id:'fleet_beacon',name:'플릿 비콘'},{id:'arbiter_tribunal',name:'아비터 트리뷰널'}]
};
var bfSelectedUnits = []; // [{id, priority:'high'|'mid'|'low', ratio:5}]
var bfBuildingCounts = {}; // {id: count}

function bfRenderUnitGrid() {
    var race = document.getElementById('bfRace').value;
    var grid = document.getElementById('bfUnitGrid');
    if (!race) { grid.innerHTML = '<span style="color:#555;font-size:0.78rem;">종족을 먼저 선택하세요.</span>'; return; }
    var units = BF_UNIT_DATA[race] || [];
    grid.innerHTML = units.map(function(u) {
        var sel = bfSelectedUnits.find(function(s){ return s.id === u.id; });
        var bg  = sel ? '#1e3a2a' : 'rgba(255,255,255,0.04)';
        var bc  = sel ? '#4caf7d' : 'rgba(255,255,255,0.1)';
        var PRIO_COLOR = {high:'#e8a020', mid:'#4e9de0', low:'#888'};
        var PRIO_LABEL = {high:'높음', mid:'보통', low:'낮음'};
        var prioBadge = sel
            ? ' <span style="font-size:0.6rem;font-weight:700;color:' + PRIO_COLOR[sel.priority||'mid'] + ';border:1px solid ' + PRIO_COLOR[sel.priority||'mid'] + ';border-radius:3px;padding:0 4px;">'
              + PRIO_LABEL[sel.priority||'mid'] + ' ' + (sel.ratio||5) + '</span>' : '';
        return '<button type="button" onclick="bfToggleUnit(\'' + u.id + '\')" '
             + 'style="padding:4px 8px;border-radius:4px;border:1px solid ' + bc + ';background:' + bg + ';color:#ddd;font-size:0.78rem;cursor:pointer;">'
             + u.emoji + ' ' + u.name + prioBadge + '</button>';
    }).join('');
    bfRenderSelectedUnits();
}

function bfToggleUnit(id) {
    var idx = bfSelectedUnits.findIndex(function(s){ return s.id === id; });
    if (idx >= 0) {
        bfSelectedUnits.splice(idx, 1);
    } else {
        if (bfSelectedUnits.length >= 5) { showToast('최대 5개까지 선택 가능합니다.', 'error'); return; }
        bfSelectedUnits.push({id: id, priority: 'mid', ratio: 5});
    }
    bfSavePreferredUnits();
    bfRenderUnitGrid();
}

function bfRenderSelectedUnits() {
    var race = document.getElementById('bfRace').value;
    var units = BF_UNIT_DATA[race] || [];
    var el = document.getElementById('bfSelectedUnits');
    if (bfSelectedUnits.length === 0) { el.innerHTML = ''; return; }
    el.innerHTML = bfSelectedUnits.map(function(s) {
        var u = units.find(function(u){ return u.id === s.id; }) || {name: s.id, emoji: '⚙️'};
        var prioColor = s.priority === 'high' ? '#e8a020' : s.priority === 'low' ? '#888' : '#4e9de0';
        var ratio = s.ratio || 5;
        return '<div style="display:flex;align-items:center;gap:5px;padding:4px 8px;border-radius:4px;border:1px solid ' + prioColor + ';background:rgba(0,0,0,0.3);font-size:0.75rem;">'
             + '<span>' + u.emoji + ' ' + u.name + '</span>'
             + '<select onchange="bfSetPrio(\'' + s.id + '\',this.value)" style="background:#1a1a2a;border:1px solid rgba(255,255,255,0.1);border-radius:3px;color:' + prioColor + ';font-size:0.7rem;cursor:pointer;padding:1px 2px;">'
             + ['high','mid','low'].map(function(p){ return '<option value="' + p + '"' + (s.priority===p?' selected':'') + '>' + {high:'높음',mid:'보통',low:'낮음'}[p] + '</option>'; }).join('')
             + '</select>'
             + '<span style="font-size:0.65rem;color:#555;">비율</span>'
             + '<input type="number" min="1" max="10" value="' + ratio + '" '
             + 'onchange="bfSetRatio(\'' + s.id + '\',this.value)" '
             + 'style="width:40px;padding:1px 4px;border-radius:3px;border:1px solid #c9a44e;background:#111;color:#c9a44e;font-size:0.78rem;font-weight:700;text-align:center;">'
             + '<span style="font-size:0.65rem;color:#555;">/10</span>'
             + '<button type="button" onclick="bfToggleUnit(\'' + s.id + '\')" style="background:none;border:none;color:#666;cursor:pointer;font-size:0.8rem;margin-left:2px;">✕</button>'
             + '</div>';
    }).join('');
}

function bfSetPrio(id, prio) {
    var s = bfSelectedUnits.find(function(s){ return s.id === id; });
    if (s) s.priority = prio;
    bfSavePreferredUnits();
    bfRenderSelectedUnits();
}

function bfSetRatio(id, val) {
    var s = bfSelectedUnits.find(function(s){ return s.id === id; });
    var v = parseInt(val);
    if (s) s.ratio = (!isNaN(v) && v >= 1 && v <= 10) ? v : (s.ratio || 5);
    bfSavePreferredUnits();
}

function bfSavePreferredUnits() {
    var val = bfSelectedUnits.map(function(s){ return s.id + ':' + s.priority + ':' + s.ratio; }).join(',');
    document.getElementById('bfPreferredUnits').value = val;
}

function bfRenderBuildingGrid() {
    var race = document.getElementById('bfRace').value;
    var el = document.getElementById('bfBuildingGrid');
    if (!race) { el.innerHTML = '<span style="color:#555;font-size:0.78rem;">종족을 먼저 선택하세요.</span>'; return; }
    var buildings = BF_BUILDING_DATA[race] || [];
    el.innerHTML = '<div style="display:flex;flex-wrap:wrap;gap:8px;">' + buildings.map(function(b) {
        var cnt = bfBuildingCounts[b.id] || 0;
        return '<div style="display:flex;align-items:center;gap:5px;background:rgba(255,255,255,0.03);padding:4px 8px;border-radius:4px;border:1px solid rgba(255,255,255,0.07);">'
             + '<span style="font-size:0.78rem;color:#ccc;">' + b.name + '</span>'
             + '<button type="button" onclick="bfChangeBldCount(\'' + b.id + '\',-1)" style="width:20px;height:20px;border:1px solid rgba(255,255,255,0.15);background:rgba(255,255,255,0.05);color:#fff;border-radius:3px;cursor:pointer;font-size:0.85rem;line-height:1;">−</button>'
             + '<span style="min-width:18px;text-align:center;font-size:0.88rem;font-weight:700;color:' + (cnt>0?'#fbbf24':'#555') + ';">' + cnt + '</span>'
             + '<button type="button" onclick="bfChangeBldCount(\'' + b.id + '\',1)" style="width:20px;height:20px;border:1px solid rgba(255,255,255,0.15);background:rgba(255,255,255,0.05);color:#fff;border-radius:3px;cursor:pointer;font-size:0.85rem;line-height:1;">＋</button>'
             + '</div>';
    }).join('') + '</div>';
}

function bfChangeBldCount(id, delta) {
    bfBuildingCounts[id] = Math.max(0, (bfBuildingCounts[id] || 0) + delta);
    bfSaveBuildingCounts();
    bfRenderBuildingGrid();
}

function bfSaveBuildingCounts() {
    var parts = [];
    Object.keys(bfBuildingCounts).forEach(function(id) {
        if (bfBuildingCounts[id] > 0) parts.push(id + ':' + bfBuildingCounts[id] + ':mid');
    });
    document.getElementById('bfPreferredBuildings').value = parts.join(',');
}

function bfLoadFromStrings(preferredUnits, preferredBuildings) {
    bfSelectedUnits = [];
    if (preferredUnits) {
        preferredUnits.split(',').forEach(function(e) {
            var p = e.trim().split(':');
            if (p[0]) bfSelectedUnits.push({id: p[0], priority: p[1]||'mid', ratio: parseInt(p[2])||5});
        });
    }
    bfBuildingCounts = {};
    if (preferredBuildings) {
        preferredBuildings.split(',').forEach(function(e) {
            var p = e.trim().split(':');
            if (p[0] && parseInt(p[1]) > 0) bfBuildingCounts[p[0]] = parseInt(p[1]);
        });
    }
    bfSavePreferredUnits();
    bfSaveBuildingCounts();
}

function openBuildForm(buildId) {
    editingBuildId = buildId;
    document.getElementById('buildFormPlaceholder').style.display = buildId === null ? 'flex' : 'none';
    document.getElementById('buildFormPanel').style.display = buildId !== null || buildId === 0 ? 'flex' : 'none';

    // 빈 폼으로 시작할 때 (새 빌드)
    if (buildId === null) {
        // 목록 강조 해제
        document.querySelectorAll('.build-manager-item').forEach(function(el){ el.classList.remove('active'); });
        return;
    }

    // 새 빌드 (buildId = 0 의미)
    document.getElementById('buildFormPanel').style.display = 'flex';
    document.getElementById('buildFormPlaceholder').style.display = 'none';

    // buildId === 0 → 새 빌드 폼 초기화
    if (buildId === 0) {
        document.getElementById('bfBuildId').value = '';
        document.getElementById('bfName').value = '';
        document.getElementById('bfRace').value = '';
        document.getElementById('bfVsRace').value = 'A';
        document.getElementById('bfPlayStyle').value   = 'AGGRESSIVE';
        document.getElementById('bfHarassStyle').value = 'NORMAL_HARASS';
        document.getElementById('bfAggression').value  = 'MID_MULTI';
        document.getElementById('bfMaxTier').value    = '3';
        document.getElementById('bfMaxTier').value = '3';
        document.getElementById('buildFormPanelTitle').textContent = '새 빌드 생성';
        document.getElementById('buildDeleteBtn').style.display = 'none';
        bfLoadFromStrings('', '');
        if(typeof bfResetMatchups==='function'){ bfResetMatchups(); bfInitStatBonusRow(); bfInitScriptTabs(); }
        bfRenderUnitGrid();
        bfRenderBuildingGrid();
        editingBuildId = 0;
        document.querySelectorAll('.build-manager-item').forEach(function(el){ el.classList.remove('active'); });
        return;
    }

    // 기존 빌드 로드
    fetch('<c:url value="/admin/builds/"/>' + buildId)
        .then(function(r){ return r.json(); })
        .then(function(data){
            if (!data.success) { showToast('빌드 로드 실패','error'); return; }
            var b = data.build;
            document.getElementById('bfBuildId').value = b.buildId;
            document.getElementById('bfName').value = b.buildName || '';
            document.getElementById('bfRace').value = b.race || '';
            document.getElementById('bfVsRace').value = b.vsRace || 'A';
            document.getElementById('bfPlayStyle').value   = b.playStyle   || 'AGGRESSIVE';
            document.getElementById('bfHarassStyle').value = b.harassStyle || 'NORMAL_HARASS';
            document.getElementById('bfAggression').value  = b.aggression  || 'MID_MULTI';
            document.getElementById('bfMaxTier').value = b.maxTier || 3;
            document.getElementById('buildFormPanelTitle').textContent = '빌드 수정';
            document.getElementById('buildDeleteBtn').style.display = 'inline-block';
            bfLoadFromStrings(b.preferredUnits || '', b.preferredBuildings || '');
            bfRenderUnitGrid();
            bfRenderBuildingGrid();
            // 목록 강조
            document.querySelectorAll('.build-manager-item').forEach(function(el){ el.classList.remove('active'); });
            document.querySelectorAll('.build-manager-item').forEach(function(el){
                if (el.onclick && el.onclick.toString().indexOf('openBuildForm('+buildId+')') >= 0) el.classList.add('active');
            });
        });
}



// ── 상성 / 가산점 / 대본 함수 ──────────────────────────────────
function bfResetMatchups() {
    ['T','Z','P'].forEach(function(r){
        var el=document.getElementById('bfMatchup'+r); if(el) el.value='NORMAL';
    });
}
function bfLoadMatchups(list) {
    bfResetMatchups();
    list.forEach(function(m){ var el=document.getElementById('bfMatchup'+m.vsRace); if(el) el.value=m.matchup||'NORMAL'; });
}
function bfInitStatBonusRow() {
    var row=document.getElementById('bfStatBonusRow'); if(!row) return;
    var stats=[['attack','공격력'],['defense','수비력'],['macro','매크로'],['micro','마이크로'],['luck','운']];
    row.innerHTML=stats.map(function(s){
        return '<div style="display:flex;align-items:center;gap:4px;">'
            +'<span style="font-size:0.78rem;min-width:48px;">'+s[1]+'</span>'
            +'<select class="bf-select bf-stat-bonus" data-stat="'+s[0]+'" style="width:90px;">'
            +'<option value="1.0">없음</option><option value="1.1">+10%</option>'
            +'<option value="1.2">+20%</option><option value="1.3">+30%</option><option value="1.5">+50%</option>'
            +'</select></div>';
    }).join('');
}
function bfLoadStatBonuses(list) {
    bfInitStatBonusRow();
    list.forEach(function(b){
        var el=document.querySelector('.bf-stat-bonus[data-stat="'+b.statName+'"]');
        if(el) el.value=parseFloat(b.bonusMult).toFixed(1);
    });
}
var BF_STABS=[{v:'T',l:'vs 테란'},{v:'Z',l:'vs 저그'},{v:'P',l:'vs 프로토스'},{v:'A',l:'공통'}];
var BF_RES=['WIN','LOSE'];
function bfInitScriptTabs() {
    var bar=document.getElementById('bfScriptTabBar'), content=document.getElementById('bfScriptTabContent');
    if(!bar||!content) return;
    bar.innerHTML=''; content.innerHTML='';
    var tabs=[];
    BF_STABS.forEach(function(v){ BF_RES.forEach(function(r){ tabs.push({vsRace:v.v,label:v.l,result:r}); }); });
    tabs.forEach(function(t,i){
        var btn=document.createElement('button');
        btn.type='button'; btn.style.fontSize='11px';
        btn.className='btn '+(i===0?'btn-primary':'btn-secondary');
        btn.textContent=t.label+' '+(t.result==='WIN'?'🏆승':'💀패');
        btn.onclick=(function(idx){ return function(){ bfShowSTab(idx,tabs.length); }; })(i);
        bar.appendChild(btn);
        var area=document.createElement('div');
        area.id='bfSA-'+i; area.style.display=i===0?'block':'none';
        var ta=document.createElement('textarea');
        ta.className='bf-select bf-script-ta'; ta.dataset.vsRace=t.vsRace; ta.dataset.result=t.result;
        ta.style.cssText='width:100%;height:140px;resize:vertical;font-size:0.8rem;margin-top:4px;';
        ta.placeholder='경기 시작합니다...';
        area.appendChild(ta); content.appendChild(area);
    });
}
function bfShowSTab(idx, total) {
    for(var i=0;i<total;i++){
        var a=document.getElementById('bfSA-'+i); if(a) a.style.display=i===idx?'block':'none';
        var b=document.getElementById('bfScriptTabBar').children[i];
        if(b) b.className='btn '+(i===idx?'btn-primary':'btn-secondary');
    }
}
function bfLoadScripts(list) {
    bfInitScriptTabs();
    var tabs=[];
    BF_STABS.forEach(function(v){ BF_RES.forEach(function(r){ tabs.push({vsRace:v.v,result:r}); }); });
    list.forEach(function(s){
        tabs.forEach(function(t,i){
            if(t.vsRace===s.vsRace && t.result===s.result){
                var ta=document.querySelector('#bfSA-'+i+' .bf-script-ta');
                if(ta) ta.value=s.content||'';
            }
        });
    });
}
document.addEventListener('DOMContentLoaded', function(){ bfInitStatBonusRow(); bfInitScriptTabs(); });

function saveBuildFromManager() {
    var name  = document.getElementById('bfName').value.trim();
    var race  = document.getElementById('bfRace').value;
    if (!name) { showToast('빌드 이름을 입력하세요','error'); return; }
    if (!race) { showToast('종족을 선택하세요','error'); return; }

    var payload = {
        buildName:           name,
        race:                race,
        vsRace:              document.getElementById('bfVsRace').value,
        playStyle:    document.getElementById('bfPlayStyle').value,
        harassStyle:  document.getElementById('bfHarassStyle').value,
        aggression:   document.getElementById('bfAggression').value,
        maxTier:             parseInt(document.getElementById('bfMaxTier').value) || 3,
        preferredUnits:      document.getElementById('bfPreferredUnits').value,
        preferredBuildings:  document.getElementById('bfPreferredBuildings').value,
        units:               []
    };

    var isEdit = editingBuildId && editingBuildId > 0;
    if (isEdit) payload.buildId = editingBuildId;

    var url = isEdit
        ? '<c:url value="/admin/builds/update"/>'
        : '<c:url value="/admin/builds/create"/>';

    fetchPost(url, payload, function(data){
        if (data.success) {
            showToast(isEdit ? '빌드 수정됨 ✓' : '빌드 생성됨 ✓', 'success');
            // ALL_BUILDS 갱신
            if (isEdit) {
                for (var i = 0; i < ALL_BUILDS.length; i++) {
                    if (ALL_BUILDS[i].id === editingBuildId) {
                        ALL_BUILDS[i].name = name;
                        ALL_BUILDS[i].race = race;
                        ALL_BUILDS[i].vsRace = payload.vsRace;
                        ALL_BUILDS[i].aggression = payload.aggression;
                        ALL_BUILDS[i].playStyle   = payload.playStyle;
                        ALL_BUILDS[i].harassStyle = payload.harassStyle;
                        break;
                    }
                }
            } else {
                ALL_BUILDS.push({id: data.buildId, name: name, race: race, vsRace: payload.vsRace, aggression: payload.aggression, playStyle: payload.playStyle, harassStyle: payload.harassStyle});
                editingBuildId = data.buildId;
                document.getElementById('bfBuildId').value = data.buildId;
                document.getElementById('buildDeleteBtn').style.display = 'inline-block';
                document.getElementById('buildFormPanelTitle').textContent = '빌드 수정';
            }
            renderBuildManagerList();
        } else {
            showToast(data.message || '저장 실패', 'error');
        }
    });
}

function deleteBuildFromManager() {
    if (!editingBuildId || editingBuildId <= 0) return;
    showConfirm('🗑', '이 빌드를 삭제하시겠습니까?<br><small style="color:#64748b;">이 빌드가 배정된 라운드에는 영향이 없습니다.</small>', function(){
        fetchPost('<c:url value="/admin/builds/delete"/>', {buildId: editingBuildId}, function(data){
            if (data.success) {
                showToast('빌드 삭제됨', 'success');
                ALL_BUILDS = ALL_BUILDS.filter(function(b){ return b.id !== editingBuildId; });
                editingBuildId = null;
                openBuildForm(null);
                renderBuildManagerList();
            } else {
                showToast(data.message || '삭제 실패', 'error');
            }
        });
    });
}
</script>

</body>
</html>
