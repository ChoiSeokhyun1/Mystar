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
                        <span id="unsavedBadge" style="display:none;color:#f59e0b;font-size:11px;font-weight:700;margin-right:8px;">● 미저장 변경사항</span>
                        <button class="btn btn-success" onclick="saveRoundInfo()">💾 저장</button>
                    </div>
                </div>

                <div class="detail-body">
                    <div class="round-info-card">
                        <h3>라운드 정보</h3>
                        <div class="info-row">
                            <div class="form-group">
                                <label>라운드 제목</label>
                                <input type="text" id="inputSubTitle" placeholder="예: 오프닝 매치" oninput="markDirty()">
                            </div>
                            <div class="form-group" style="max-width:220px;">
                                <label>상대팀 이름</label>
                                <input type="text" id="inputTeamName" placeholder="예: AI Team" oninput="markDirty()">
                            </div>
                        </div>
                    </div>

                    <div class="matchup-section">
                        <h3>매치업 구성 (3세트 × 3선수 = 9명)</h3>
                        <div id="matchupGrid">
                            <c:forEach begin="1" end="3" var="setIdx">
                                <div class="set-group" id="set-group-${setIdx}">
                                    <div class="set-group-header">
                                        <span class="set-group-label">SET ${setIdx}</span>
                                        <div class="set-map-row">
                                            <select id="slot-map-select-${setIdx}" class="map-select">
                                                <option value="">🗺 맵 선택...</option>
                                            </select>
                                            <button class="btn btn-sm btn-secondary" onclick="assignMap(${setIdx})">배정</button>
                                            <span id="slot-map-label-${setIdx}" class="map-label"></span>
                                        </div>
                                    </div>
                                    <div class="set-players">
                                        <c:forEach begin="1" end="3" var="p">
                                            <c:set var="gSlot" value="${(setIdx-1)*3 + p}" />
                                            <div class="matchup-slot" id="slot-${gSlot}">
                                                <div class="slot-number">P${p}</div>
                                                <div class="slot-player-info" id="slot-info-${gSlot}">
                                                    <div class="slot-empty-text">미배정</div>
                                                </div>
                                                <div class="slot-actions">
                                                    <button class="btn btn-sm btn-secondary" onclick="openPlayerModal(${gSlot})">선수 선택</button>
                                                    <button class="btn btn-sm btn-danger" id="remove-btn-${gSlot}" style="display:none" onclick="removeOpponent(${gSlot})">제거</button>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
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
    <div class="modal" style="width:660px;">
        <div class="modal-header">
            <h2 id="modalTitle">선수 선택</h2>
            <button class="modal-close" onclick="closePlayerModal()">✕</button>
        </div>

        <div style="padding:12px 16px;border-bottom:1px solid #1e293b;display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
            <input type="text" id="playerSearch" placeholder="선수 이름 검색..."
                style="background:#111827;border:1px solid #2d3748;border-radius:6px;color:#e2e8f0;padding:7px 10px;font-size:12px;width:160px;"
                oninput="filterPlayers()">
            <select id="packSelect" onchange="filterPlayers()"
                style="background:#111827;border:1px solid #2d3748;border-radius:6px;color:#e2e8f0;padding:7px 10px;font-size:12px;cursor:pointer;">
                <option value="">📦 전체 팩</option>
            </select>
            <div class="modal-filter" style="margin:0;">
                <button class="filter-btn" onclick="setRaceFilter('T',this)">테란 T</button>
                <button class="filter-btn" onclick="setRaceFilter('P',this)">프로토스 P</button>
                <button class="filter-btn" onclick="setRaceFilter('Z',this)">저그 Z</button>
            </div>
        </div>

        <div class="modal-body" style="max-height:420px;overflow-y:auto;">
            <table class="player-list-table">
                <thead>
                    <tr>
                        <th>이름</th><th>종족</th><th>등급</th>
                        <th>ATK</th><th>DEF</th><th>HP</th><th>HARASS</th><th>SPD</th><th>합계</th>
                    </tr>
                </thead>
                <tbody id="playerTableBody"></tbody>
            </table>
        </div>

        <div class="modal-footer">
            <div class="modal-footer-label">
                선수: <span id="selectedPlayerLabel" style="color:#00ff88;font-weight:700;">미선택</span>
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

<script>
var ALL_PLAYERS = [];
var ROUND_MAP   = {};
var ALL_PACKS   = [];
var ALL_MAPS    = [];
try {
    var pd  = document.getElementById('playerDataScript');
    var rd  = document.getElementById('roundDataScript');
    var pkd = document.getElementById('packDataScript');
    var mpd = document.getElementById('mapDataScript');
    if (pd)  ALL_PLAYERS = JSON.parse(pd.textContent || pd.innerHTML);
    if (rd)  ROUND_MAP   = JSON.parse(rd.textContent || rd.innerHTML);
    if (pkd) ALL_PACKS   = JSON.parse(pkd.textContent || pkd.innerHTML);
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
var raceFilter         = 'T';
var selectedPlayerSeq  = null;
var slotData           = {1:null,2:null,3:null,4:null,5:null,6:null,7:null,8:null,9:null};

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
    clearDirty();

    for (var i = 1; i <= 9; i++) { slotData[i] = null; renderSlot(i); }
    loadOpponents(stageLevel, subLevel);
    loadMaps(stageLevel, subLevel);
}

/* ============================================================
   세트별 맵 로드 / 배정
   ============================================================ */
function loadMaps(stageLevel, subLevel) {
    for (var i = 1; i <= 3; i++) {
        document.getElementById('slot-map-label-' + i).textContent = '';
        document.getElementById('slot-map-select-' + i).value = '';
    }
    fetch('<c:url value="/admin/round/maps"/>?stageLevel=' + stageLevel + '&subLevel=' + subLevel)
        .then(function(r){ return r.json(); })
        .then(function(data) {
            if (!data.success || !data.maps) return;
            data.maps.forEach(function(m) {
                var n = m.setNumber;
                if (n >= 1 && n <= 3) {
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
	                // 👇 9번 슬롯(전체)까지 불러오도록 수정
	                if (opp.setNumber >= 1 && opp.setNumber <= 9) {
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
    var total = (p.statAttack||0)+(p.statDefense||0)+(p.statHp||0)+(p.statHarass||0)+(p.statSpeed||0);
    info.innerHTML =
        '<div class="slot-player-race">' + (RACE_ICON[p.race]||'?') + '</div>' +
        '<div class="slot-player-name">' + safeStr(p.playerName) + '</div>' +
        '<span class="slot-player-rarity rarity-' + (p.rarity||'N') + '">' + (p.rarity||'N') + '</span>' +
        '<div class="slot-stats">' +
            'ATK ' + (p.statAttack||0) + ' / DEF ' + (p.statDefense||0) + '<br>' +
            'HP ' + (p.statHp||0) + ' / HRS ' + (p.statHarass||0) + ' / SPD ' + (p.statSpeed||0) + '<br>' +
            '합계 ' + total +
        '</div>';
}

/* ============================================================
   저장
   ============================================================ */
var _isDirty = false;
function markDirty() {
    _isDirty = true;
    var badge = document.getElementById('unsavedBadge');
    if (badge) badge.style.display = 'inline';
}
function clearDirty() {
    _isDirty = false;
    var badge = document.getElementById('unsavedBadge');
    if (badge) badge.style.display = 'none';
}

function saveRoundInfo() {
    if (!currentStageLevel) { showToast('라운드를 먼저 선택하세요','error'); return; }
    var subTitle = document.getElementById('inputSubTitle').value.trim();
    var teamName = document.getElementById('inputTeamName').value.trim();
    if (!subTitle) { showToast('라운드 제목을 입력하세요','error'); return; }

    // 선수 슬롯 데이터 수집
    var slots = [];
    for (var i = 1; i <= 9; i++) {
        if (slotData[i] && slotData[i].playerSeq) {
            slots.push({ setNumber: i, playerSeq: slotData[i].playerSeq });
        }
    }

    var savedCount = 0;
    var totalCalls = 2;
    var errors = [];

    function onDone() {
        savedCount++;
        if (savedCount < totalCalls) return;
        if (errors.length > 0) {
            showToast(errors[0], 'error');
        } else {
            showToast('저장됨 ✓', 'success');
            clearDirty();
            var el = document.getElementById('round-'+currentStageLevel+'-'+currentSubLevel);
            if (el) el.querySelector('.round-label').textContent = 'R' + currentSubLevel + ' · ' + subTitle;
            document.getElementById('detailSubtitle').textContent = subTitle;
            if (ROUND_MAP[currentStageLevel] && ROUND_MAP[currentStageLevel][currentSubLevel]) {
                ROUND_MAP[currentStageLevel][currentSubLevel].title = subTitle;
                ROUND_MAP[currentStageLevel][currentSubLevel].team  = teamName;
            }
        }
    }

    // 라운드 정보 저장
    fetchPost('<c:url value="/admin/round/edit"/>', {
        stageLevel: currentStageLevel, subLevel: currentSubLevel,
        subTitle: subTitle, opponentTeamName: teamName
    }, function(data) {
        if (!data.success) errors.push(data.message || '라운드 정보 저장 실패');
        onDone();
    });

    // 선수 배정 저장
    fetchPost('<c:url value="/admin/round/opponents/save"/>', {
        stageLevel: currentStageLevel, subLevel: currentSubLevel, slots: slots
    }, function(data) {
        if (!data.success) errors.push(data.message || '선수 저장 실패');
        onDone();
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
   선수 모달
   ============================================================ */
function openPlayerModal(setNum) {
    currentSetSlot = setNum;
    selectedPlayerSeq = null;

    var setIdx = Math.ceil(setNum / 3);
    var pIdx   = ((setNum - 1) % 3) + 1;
    document.getElementById('modalTitle').textContent = 'SET ' + setIdx + ' — P' + pIdx + ' 선수 선택';
    document.getElementById('playerSearch').value = '';
    document.getElementById('packSelect').value = '';
    document.getElementById('selectedPlayerLabel').textContent = '미선택';
    document.getElementById('assignBtn').disabled = true;

    // 기존 배정된 선수 미리 선택
    var existingOpp = slotData[setNum];
    if (existingOpp && existingOpp.playerSeq) {
        selectedPlayerSeq = existingOpp.playerSeq;
        var player = ALL_PLAYERS.find(function(p){ return p.seq === selectedPlayerSeq; });
        if (player) {
            document.getElementById('selectedPlayerLabel').textContent = player.name + ' (' + player.race + ')';
            document.getElementById('assignBtn').disabled = false;
        }
    }

    raceFilter = 'T';
    document.querySelectorAll('.modal-filter .filter-btn').forEach(function(b,i){
        b.classList.toggle('active', i===0);
    });

    renderPlayerTable();
    document.getElementById('playerModal').classList.add('visible');
}
function closePlayerModal() { document.getElementById('playerModal').classList.remove('visible'); }

function setRaceFilter(race, btn) {
    raceFilter = race;
    document.querySelectorAll('.modal-filter .filter-btn').forEach(function(b){ b.classList.remove('active'); });
    btn.classList.add('active');
    renderPlayerTable();
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
        var tot = (p.atk||0)+(p.def||0)+(p.hp||0)+(p.harass||0)+(p.speed||0);
        var sel = (p.seq === selectedPlayerSeq);
        return '<tr onclick="selectPlayerRow('+p.seq+')" style="cursor:pointer;'+(sel?'background:rgba(0,230,118,0.07);':'')+'">'
            +'<td class="player-name-cell">'+(sel?'<span style="color:#00e676">✔ </span>':'')+safeStr(p.name)+'</td>'
            +'<td>'+(rLabel[p.race]||p.race)+'</td>'
            +'<td><span class="slot-player-rarity rarity-'+p.rarity+'">'+p.rarity+'</span></td>'
            +'<td style="color:#f87171">'+(p.atk||0)+'</td>'
            +'<td style="color:#60a5fa">'+(p.def||0)+'</td>'
            +'<td style="color:#34d399">'+(p.hp||0)+'</td>'
            +'<td style="color:#fb923c">'+(p.harass||0)+'</td>'
            +'<td style="color:#fbbf24">'+(p.speed||0)+'</td>'
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
    }
    renderPlayerTable();
}


function confirmAssign() {
    if (!selectedPlayerSeq) { showToast('선수를 먼저 선택하세요','error'); return; }

    var p = ALL_PLAYERS.find(function(pl){ return pl.seq === selectedPlayerSeq; });
    if (!p) return;

    slotData[currentSetSlot] = {
        playerSeq:  selectedPlayerSeq,
        playerName: p.name,
        race:       p.race,
        rarity:     p.rarity,
        setNumber:  currentSetSlot,
        statAttack:  p.atk,
        statDefense: p.def,
        statHp:      p.hp,
        statHarass:  p.harass,
        statSpeed:   p.speed
    };

    renderSlot(currentSetSlot);
    markDirty();
    closePlayerModal();
    showToast('SET' + Math.ceil(currentSetSlot/3) + ' P' + (((currentSetSlot-1)%3)+1) + ' — ' + p.name + ' 배정 (미저장)', 'info');
}
function removeOpponent(setNum) {
    if (!currentStageLevel) return;
    slotData[setNum] = null;
    renderSlot(setNum);
    markDirty();
    showToast('SET ' + setNum + ' 제거됨 (미저장)', 'info');
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

/* 맵 셀렉트 옵션 채우기 (SET 1~3) */
(function() {
    for (var s = 1; s <= 3; s++) {
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

</script>

</body>
</html>
