<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>관리자 - 팩 관리</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/adminStage.css' />">
    <link rel="stylesheet" href="<c:url value='/css/adminPack.css' />">
</head>
<body>

<c:set var="adminCurrentPage" value="pack" />
<%@ include file="/WEB-INF/views/layout/adminHeader.jsp" %>

<div class="admin-page-wrap">

    <div class="admin-top-bar">
        <div>
            <div style="color:#6366f1;font-size:10px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;margin-bottom:2px;">ADMIN PANEL</div>
            <h1 style="color:#e2e8f0;font-size:18px;font-weight:800;margin:0;">팩 관리</h1>
        </div>
        <button class="btn btn-primary" onclick="openEditModal(null)">+ 팩 추가</button>
    </div>

    <div class="pack-layout">

        <!-- ── 왼쪽: 팩 목록 ── -->
        <div class="pack-list-panel">
            <div class="pack-list-header">
                <h3>📦 팩 목록</h3>
                <span class="pack-count-badge" id="packCountBadge">0</span>
            </div>
            <div class="pack-scroll" id="packListContainer">
                <div style="color:#2d3748;font-size:12px;text-align:center;padding:30px;">불러오는 중...</div>
            </div>
        </div>

        <!-- ── 오른쪽: 팩 상세 ── -->
        <div class="pack-detail-panel" id="packDetailPanel">
            <div class="pack-detail-empty" id="packDetailEmpty">
                <div class="icon">📦</div>
                <p>왼쪽에서 팩을 선택하세요</p>
            </div>
            <div id="packDetailContent" style="display:none;flex-direction:column;height:100%;">
                <div class="pack-detail-header">
                    <div>
                        <div class="pack-detail-title" id="detailTitle">-</div>
                        <div class="pack-detail-subtitle" id="detailSubtitle">-</div>
                    </div>
                    <div style="display:flex;gap:6px;">
                        <button class="btn btn-sm btn-secondary" id="detailToggleBtn" onclick="toggleSelectedPack()">판매 ON</button>
                        <button class="btn btn-sm btn-secondary" onclick="editSelectedPack()">✏ 수정</button>
                        <button class="btn btn-sm btn-danger" onclick="deleteSelectedPack()">🗑 삭제</button>
                    </div>
                </div>
                <div class="pack-detail-body">

                    <!-- 팩 정보 -->
                    <div class="pack-info-card">
                        <h4>팩 정보</h4>
                        <div class="pack-info-row">
                            <div id="detailBannerWrap">
                                <div class="pack-banner-preview-placeholder">📦</div>
                            </div>
                            <div class="pack-info-details">
                                <div class="info-item">
                                    <label>팩 이름</label>
                                    <span id="detailName">-</span>
                                </div>
                                <div class="info-item">
                                    <label>뽑기 비용</label>
                                    <span id="detailCost" style="color:#fbbf24;">-</span>
                                </div>
                                <div class="info-item" style="grid-column:1/-1;">
                                    <label>설명</label>
                                    <span id="detailDesc">-</span>
                                </div>
                                <div class="info-item">
                                    <label>판매 여부</label>
                                    <span id="detailAvail">-</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 소속 선수 -->
                    <div class="players-section">
                        <h4>소속 선수 <span class="player-cnt" id="detailPlayerCnt">0</span></h4>
                        <div class="player-chips" id="detailPlayerChips">
                            <span class="no-players-msg">소속 선수 없음</span>
                        </div>
                    </div>

                </div>
            </div>
        </div>

    </div><!-- end pack-layout -->
</div>

<!-- ── 편집 모달 ── -->
<div class="modal-overlay" id="editModal">
    <div class="edit-modal">
        <div class="edit-modal-header">
            <h2 id="editModalTitle">팩 추가</h2>
            <button class="modal-close" onclick="closeEditModal()">✕</button>
        </div>
        <div class="edit-modal-body">
            <input type="hidden" id="editSeq">
            <div class="edit-grid">

                <!-- 이름 -->
                <div class="full">
                    <label class="form-label">팩 이름 *</label>
                    <input type="text" class="form-input" id="editName" placeholder="예) 시즌 1 팩">
                </div>

                <!-- 설명 -->
                <div class="full">
                    <label class="form-label">설명</label>
                    <textarea class="form-textarea" id="editDesc" placeholder="팩 설명을 입력하세요"></textarea>
                </div>

                <!-- 비용 -->
                <div>
                    <label class="form-label">뽑기 비용 (크리스탈)</label>
                    <input type="number" class="form-input" id="editCost" value="100" min="0">
                </div>

                <!-- 판매 여부 -->
                <div>
                    <label class="form-label">판매 여부</label>
                    <div class="toggle-wrap">
                        <label class="toggle-switch">
                            <input type="checkbox" id="editAvailable" checked>
                            <span class="toggle-slider"></span>
                        </label>
                        <span class="toggle-label"><strong id="availLabel">판매 중</strong></span>
                    </div>
                </div>

                <!-- 배너 이미지 -->
                <div class="full">
                    <label class="form-label">배너 이미지</label>
                    <div class="img-upload-wrap">
                        <div class="img-preview-row">
                            <div id="modalImgPreviewWrap">
                                <div class="modal-img-placeholder">📦</div>
                            </div>
                            <div class="img-input-group">
                                <div class="img-url-row">
                                    <input type="text" class="form-input" id="editBannerUrl"
                                           placeholder="이미지 URL 직접 입력"
                                           oninput="onUrlInput()">
                                </div>
                                <div style="display:flex;align-items:center;gap:8px;">
                                    <label class="file-upload-label">
                                        📁 파일 선택
                                        <input type="file" id="bannerFileInput" accept="image/*" onchange="handleFileSelect(this)">
                                    </label>
                                    <span class="upload-status" id="uploadStatus">또는 파일을 선택하세요</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
        <div class="edit-modal-footer">
            <button class="btn btn-secondary" onclick="closeEditModal()">취소</button>
            <button class="btn btn-primary" onclick="submitEdit()">💾 저장</button>
        </div>
    </div>
</div>

<!-- ── 확인 모달 ── -->
<div class="modal-overlay" id="confirmModal">
    <div class="confirm-modal">
        <div style="font-size:32px;margin-bottom:10px;" id="confirmIcon">⚠️</div>
        <p id="confirmMsg"></p>
        <div class="confirm-actions">
            <button class="btn btn-secondary" onclick="closeConfirm()">취소</button>
            <button class="btn btn-danger" id="confirmOkBtn">확인</button>
        </div>
    </div>
</div>

<div class="toast" id="toast"></div>

<!-- 서버에서 내려온 초기 데이터 -->
<script id="packDataScript" type="application/json">${packJsonData}</script>
<script id="allPlayersScript" type="application/json">${allPlayersJson}</script>

<script>
/* ============================================================
   데이터 초기화
   ============================================================ */
var ALL_PACKS = [];
var ALL_PLAYERS = [];
try {
    ALL_PACKS   = JSON.parse(document.getElementById('packDataScript').textContent);
    ALL_PLAYERS = JSON.parse(document.getElementById('allPlayersScript').textContent);
} catch(e) { console.error(e); }

var selectedPackSeq = null;
var confirmCallback = null;

var UPLOAD_URL  = '<c:url value="/admin/pack/upload"/>';
var ADD_URL     = '<c:url value="/admin/pack/add"/>';
var EDIT_URL    = '<c:url value="/admin/pack/edit"/>';
var DELETE_URL  = '<c:url value="/admin/pack/delete"/>';
var TOGGLE_URL  = '<c:url value="/admin/pack/toggle"/>';

var RARITY_ORDER = {UR:1, SSR:2, SR:3, R:4, N:5};
var RACE_ICON    = {T:'🔵', P:'💜', Z:'🟢'};

/* ============================================================
   팩 목록 렌더
   ============================================================ */
function renderPackList() {
    var container = document.getElementById('packListContainer');
    document.getElementById('packCountBadge').textContent = ALL_PACKS.length;

    if (ALL_PACKS.length === 0) {
        container.innerHTML = '<div style="color:#2d3748;font-size:12px;text-align:center;padding:40px;">등록된 팩이 없습니다<br><br><button class="btn btn-primary btn-sm" onclick="openEditModal(null)">+ 팩 추가</button></div>';
        return;
    }

    container.innerHTML = ALL_PACKS.map(function(pk) {
        var isOn = pk.isAvailable === 'Y';
        var imgHtml = pk.bannerImgUrl
            ? '<img class="pack-banner-thumb" src="' + safeStr(pk.bannerImgUrl) + '" onerror="this.outerHTML=\'<div class=pack-banner-placeholder>📦</div>\'">'
            : '<div class="pack-banner-placeholder">📦</div>';
        var selected = (pk.packSeq === selectedPackSeq) ? ' selected' : '';
        var unavail  = !isOn ? ' unavailable' : '';
        var playerCount = getPlayersInPack(pk.packSeq).length;

        return '<div class="pack-card' + selected + unavail + '" onclick="selectPack(' + pk.packSeq + ')" id="packCard_' + pk.packSeq + '">'
            + '<div class="pack-card-top">'
            + imgHtml
            + '<div class="pack-card-info">'
            + '<div class="pack-card-name">' + safeStr(pk.packName) + '</div>'
            + '<div class="pack-card-meta">'
            + '<span class="pack-meta-cost">💎 ' + pk.costCrystal + '</span>'
            + '<span class="pack-meta-crystal">크리스탈</span>'
            + '<span class="pack-status-badge ' + (isOn ? 'on' : 'off') + '">' + (isOn ? '판매 중' : '판매 중지') + '</span>'
            + '</div>'
            + '</div>'
            + '</div>'
            + '<div class="pack-card-actions">'
            + '<button class="btn btn-sm btn-secondary" onclick="event.stopPropagation();editPackById(' + pk.packSeq + ')">✏ 수정</button>'
            + '<button class="btn btn-sm ' + (isOn ? 'btn-secondary' : 'btn-success') + '" onclick="event.stopPropagation();quickToggle(' + pk.packSeq + ')">' + (isOn ? '⏸ 중지' : '▶ 판매') + '</button>'
            + '<button class="btn btn-sm btn-danger" onclick="event.stopPropagation();confirmDeletePack(' + pk.packSeq + ',\'' + safeAttr(pk.packName) + '\')">🗑</button>'
            + '</div>'
            + '</div>';
    }).join('');
}

/* ============================================================
   팩 선택 → 디테일 패널
   ============================================================ */
function selectPack(seq) {
    selectedPackSeq = seq;
    renderPackList(); // 선택 표시 갱신

    var pk = ALL_PACKS.filter(function(p){ return p.packSeq === seq; })[0];
    if (!pk) return;

    document.getElementById('packDetailEmpty').style.display = 'none';
    var content = document.getElementById('packDetailContent');
    content.style.display = 'flex';

    // 헤더
    document.getElementById('detailTitle').textContent = pk.packName;
    var isOn = pk.isAvailable === 'Y';
    document.getElementById('detailSubtitle').textContent = (isOn ? '✅ 판매 중' : '⛔ 판매 중지') + ' · 💎 ' + pk.costCrystal + ' 크리스탈';

    var toggleBtn = document.getElementById('detailToggleBtn');
    if (isOn) {
        toggleBtn.textContent = '⏸ 판매 중지';
        toggleBtn.className = 'btn btn-sm btn-secondary';
    } else {
        toggleBtn.textContent = '▶ 판매 시작';
        toggleBtn.className = 'btn btn-sm btn-success';
    }

    // 배너 이미지
    var bannerWrap = document.getElementById('detailBannerWrap');
    if (pk.bannerImgUrl) {
        bannerWrap.innerHTML = '<img class="pack-banner-preview" src="' + safeStr(pk.bannerImgUrl)
            + '" onerror="this.outerHTML=\'<div class=pack-banner-preview-placeholder>📦</div>\'">';
    } else {
        bannerWrap.innerHTML = '<div class="pack-banner-preview-placeholder">📦</div>';
    }

    // 정보
    document.getElementById('detailName').textContent = pk.packName;
    document.getElementById('detailCost').textContent = '💎 ' + pk.costCrystal + ' 크리스탈';
    document.getElementById('detailDesc').textContent = pk.description || '(설명 없음)';
    document.getElementById('detailAvail').innerHTML = isOn
        ? '<span style="color:#4ade80;font-weight:700;">● 판매 중</span>'
        : '<span style="color:#9ca3af;font-weight:700;">○ 판매 중지</span>';

    // 소속 선수
    renderDetailPlayers(seq);
}

function renderDetailPlayers(packSeq) {
    var players = getPlayersInPack(packSeq);
    var pk = ALL_PACKS.filter(function(p){ return p.packSeq === packSeq; })[0];
    if (!pk) return;

    document.getElementById('detailPlayerCnt').textContent = players.length;

    if (players.length === 0) {
        document.getElementById('detailPlayerChips').innerHTML = '<span class="no-players-msg">소속 선수 없음 — 선수 관리 페이지에서 팩을 연결할 수 있습니다</span>';
        return;
    }

    var sorted = players.slice().sort(function(a, b) {
        return (RARITY_ORDER[a.rarity]||9) - (RARITY_ORDER[b.rarity]||9) || a.name.localeCompare(b.name, 'ko');
    });

    document.getElementById('detailPlayerChips').innerHTML = sorted.map(function(p) {
        var imgHtml = p.imgUrl
            ? '<img class="player-chip-img" src="' + safeStr(p.imgUrl) + '" onerror="this.outerHTML=\'<div class=player-chip-avatar>' + (RACE_ICON[p.race]||'?') + '</div>\'">'
            : '<div class="player-chip-avatar">' + (RACE_ICON[p.race]||'?') + '</div>';
        return '<div class="player-chip">'
            + imgHtml
            + '<span class="player-chip-name">' + safeStr(p.name) + '</span>'
            + '<span class="player-chip-rarity slot-player-rarity rarity-' + p.rarity + '">' + p.rarity + '</span>'
            + '</div>';
    }).join('');
}

function getPlayersInPack(packSeq) {
    return ALL_PLAYERS.filter(function(p) {
        return p.packs && p.packs.some(function(pk){ return pk.seq === packSeq; });
    });
}

/* ============================================================
   편집 모달
   ============================================================ */
function openEditModal(seq) {
    var pk = seq ? ALL_PACKS.filter(function(p){ return p.packSeq === seq; })[0] : null;
    document.getElementById('editModalTitle').textContent = pk ? '팩 수정' : '팩 추가';
    document.getElementById('editSeq').value       = pk ? pk.packSeq : '';
    document.getElementById('editName').value      = pk ? pk.packName : '';
    document.getElementById('editDesc').value      = pk ? (pk.description || '') : '';
    document.getElementById('editCost').value      = pk ? pk.costCrystal : 100;
    document.getElementById('editBannerUrl').value = pk ? (pk.bannerImgUrl || '') : '';
    document.getElementById('editAvailable').checked = pk ? (pk.isAvailable === 'Y') : true;
    document.getElementById('availLabel').textContent = document.getElementById('editAvailable').checked ? '판매 중' : '판매 중지';
    document.getElementById('uploadStatus').textContent = '또는 파일을 선택하세요';
    document.getElementById('uploadStatus').className = 'upload-status';
    document.getElementById('bannerFileInput').value = '';
    updateModalPreview(pk ? (pk.bannerImgUrl || '') : '');
    document.getElementById('editModal').classList.add('visible');
    setTimeout(function(){ document.getElementById('editName').focus(); }, 100);
}

function closeEditModal() {
    document.getElementById('editModal').classList.remove('visible');
}

function editPackById(seq) {
    openEditModal(seq);
}

function editSelectedPack() {
    if (selectedPackSeq) openEditModal(selectedPackSeq);
}

/* ── 이미지 URL 입력 시 미리보기 갱신 ── */
function onUrlInput() {
    updateModalPreview(document.getElementById('editBannerUrl').value.trim());
}

function updateModalPreview(url) {
    var wrap = document.getElementById('modalImgPreviewWrap');
    if (url) {
        wrap.innerHTML = '<img class="modal-img-preview" src="' + safeStr(url)
            + '" onerror="this.outerHTML=\'<div class=modal-img-placeholder>📦</div>\'">';
    } else {
        wrap.innerHTML = '<div class="modal-img-placeholder">📦</div>';
    }
}

/* ── 파일 선택 → 업로드 ── */
function handleFileSelect(input) {
    if (!input.files || !input.files[0]) return;
    var file = input.files[0];
    var status = document.getElementById('uploadStatus');
    status.textContent = '업로드 중...';
    status.className = 'upload-status uploading';

    var formData = new FormData();
    formData.append('file', file);

    fetch(UPLOAD_URL, { method: 'POST', body: formData })
        .then(function(r){ return r.json(); })
        .then(function(data) {
            if (data.success) {
                document.getElementById('editBannerUrl').value = data.url;
                updateModalPreview(data.url);
                status.textContent = '✓ 업로드 완료';
                status.className = 'upload-status done';
            } else {
                status.textContent = '✗ ' + (data.message || '업로드 실패');
                status.className = 'upload-status error';
            }
        })
        .catch(function() {
            status.textContent = '✗ 서버 오류';
            status.className = 'upload-status error';
        });
}

/* ── 토글 레이블 ── */
document.getElementById('editAvailable').addEventListener('change', function() {
    document.getElementById('availLabel').textContent = this.checked ? '판매 중' : '판매 중지';
});

/* ── 저장 ── */
function submitEdit() {
    var name = document.getElementById('editName').value.trim();
    if (!name) { showToast('팩 이름을 입력하세요', 'error'); return; }

    var seq = document.getElementById('editSeq').value;
    var payload = {
        packName:    name,
        description: document.getElementById('editDesc').value.trim(),
        costCrystal: parseInt(document.getElementById('editCost').value) || 0,
        bannerImgUrl: document.getElementById('editBannerUrl').value.trim(),
        isAvailable: document.getElementById('editAvailable').checked ? 'Y' : 'N'
    };

    var isEdit = !!seq;
    if (isEdit) payload.packSeq = parseInt(seq);
    var url = isEdit ? EDIT_URL : ADD_URL;

    fetchPost(url, payload, function(data) {
        if (data.success) {
            showToast(isEdit ? '수정됨 ✓' : '팩 추가됨 ✓', 'success');
            closeEditModal();
            // 로컬 데이터 갱신
            if (isEdit) {
                var idx = ALL_PACKS.findIndex(function(p){ return p.packSeq === parseInt(seq); });
                if (idx >= 0) {
                    ALL_PACKS[idx] = Object.assign(ALL_PACKS[idx], payload);
                }
            } else {
                payload.packSeq = data.newSeq;
                ALL_PACKS.push(payload);
            }
            renderPackList();
            if (selectedPackSeq === parseInt(seq) || (!isEdit && data.newSeq)) {
                selectPack(isEdit ? parseInt(seq) : data.newSeq);
            }
        } else {
            showToast(data.message || '저장 실패', 'error');
        }
    });
}

/* ============================================================
   삭제
   ============================================================ */
function confirmDeletePack(seq, name) {
    showConfirm('🗑', '<strong>' + safeStr(name) + '</strong> 팩을 삭제합니다.<br><small style="color:#ef4444">팩에 연결된 선수 정보는 유지됩니다.</small>',
        function() {
            fetchPost(DELETE_URL, {packSeq: seq}, function(data) {
                if (data.success) {
                    ALL_PACKS = ALL_PACKS.filter(function(p){ return p.packSeq !== seq; });
                    if (selectedPackSeq === seq) {
                        selectedPackSeq = null;
                        document.getElementById('packDetailEmpty').style.display = '';
                        document.getElementById('packDetailContent').style.display = 'none';
                    }
                    renderPackList();
                    showToast('팩 삭제됨', 'success');
                } else {
                    showToast(data.message || '삭제 실패', 'error');
                }
            });
        }
    );
}

function deleteSelectedPack() {
    if (!selectedPackSeq) return;
    var pk = ALL_PACKS.filter(function(p){ return p.packSeq === selectedPackSeq; })[0];
    if (pk) confirmDeletePack(pk.packSeq, pk.packName);
}

/* ============================================================
   판매 ON/OFF 토글
   ============================================================ */
function quickToggle(seq) {
    var pk = ALL_PACKS.filter(function(p){ return p.packSeq === seq; })[0];
    if (!pk) return;
    var newVal = pk.isAvailable === 'Y' ? 'N' : 'Y';
    fetchPost(TOGGLE_URL, {packSeq: seq, isAvailable: newVal}, function(data) {
        if (data.success) {
            pk.isAvailable = newVal;
            renderPackList();
            if (selectedPackSeq === seq) selectPack(seq);
            showToast(newVal === 'Y' ? '판매 시작 ✓' : '판매 중지 ✓', 'success');
        } else {
            showToast(data.message || '변경 실패', 'error');
        }
    });
}

function toggleSelectedPack() {
    if (selectedPackSeq) quickToggle(selectedPackSeq);
}

/* ============================================================
   공통 유틸
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

document.getElementById('confirmOkBtn').addEventListener('click', function() {
    var cb = confirmCallback;
    closeConfirm();
    if (cb) cb();
});

var _tt;
function showToast(msg, type) {
    var t = document.getElementById('toast');
    t.textContent = msg;
    t.className = 'toast ' + (type || '') + ' show';
    clearTimeout(_tt);
    _tt = setTimeout(function(){ t.classList.remove('show'); }, 3000);
}

function fetchPost(url, body, cb) {
    fetch(url, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(body)
    })
    .then(function(r){ return r.json(); })
    .then(cb)
    .catch(function(e){
        console.error(e);
        showToast('서버 오류', 'error');
    });
}

function safeStr(s) {
    return String(s || '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

function safeAttr(s) {
    return String(s || '').replace(/\\/g,'\\\\').replace(/'/g,"\\'");
}

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') { closeEditModal(); closeConfirm(); }
});

/* 초기 렌더 */
renderPackList();
</script>
</body>
</html>
