<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>관리자 - 유닛/건물 이미지 관리</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/adminStage.css' />">
    <link rel="stylesheet" href="<c:url value='/css/adminEntity.css' />">
</head>
<body>

<c:set var="adminCurrentPage" value="entity" />
<%@ include file="/WEB-INF/views/layout/adminHeader.jsp" %>

<div class="admin-page-wrap">

    <div class="admin-top-bar">
        <div>
            <div style="color:#6366f1;font-size:10px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;margin-bottom:2px;">ADMIN PANEL</div>
            <h1 style="color:#e2e8f0;font-size:18px;font-weight:800;margin:0;">유닛 / 건물 이미지 관리</h1>
        </div>
        <div style="color:#4a5568;font-size:11px;text-align:right;">
            카드를 클릭하면 이미지를 업로드할 수 있습니다.<br>
            이미지는 <code style="color:#6366f1;">/resources/image/entities/</code> 에 저장됩니다.
        </div>
    </div>

    <!-- 필터 바 -->
    <div class="filter-bar">
        <button class="filter-btn active" onclick="setFilter('all',this)">전체</button>
        <div class="sep-line"></div>
        <button class="filter-btn race-T" onclick="setFilter('T',this)">테란</button>
        <button class="filter-btn race-Z" onclick="setFilter('Z',this)">저그</button>
        <button class="filter-btn race-P" onclick="setFilter('P',this)">프로토스</button>
        <div class="sep-line"></div>
        <button class="filter-btn" onclick="setFilter('unit',this)">유닛만</button>
        <button class="filter-btn" onclick="setFilter('building',this)">건물만</button>
        <div class="sep-line"></div>
        <button class="filter-btn" onclick="setFilter('nok',this)">이미지 없음</button>
        <span class="filter-count" id="countLabel"></span>
    </div>

    <!-- 엔티티 그리드 -->
    <div class="entity-grid" id="entityGrid"></div>

</div>

<!-- 업로드 모달 -->
<div class="modal-overlay" id="modalOverlay" onclick="closeModal(event)">
    <div class="modal-box" onclick="event.stopPropagation()">
        <div>
            <div class="modal-title" id="modalTitle">이미지 업로드</div>
            <div class="modal-subtitle" id="modalSubtitle"></div>
        </div>

        <div class="modal-preview" id="modalPreview" onclick="document.getElementById('fileInput').click()">
            <div class="ph" id="previewPh">🖼</div>
            <img id="previewImg" src="" style="display:none;">
        </div>

        <input type="file" id="fileInput" accept="image/*" onchange="onFileSelected(event)">

        <div class="progress-bar" id="progressBar">
            <div class="progress-fill" id="progressFill"></div>
        </div>

        <div class="modal-actions">
            <button class="btn btn-danger" id="btnDelete" onclick="deleteImage()" style="display:none;">삭제</button>
            <button class="btn btn-ghost" onclick="closeModal()">닫기</button>
            <button class="btn btn-primary" onclick="document.getElementById('fileInput').click()">📁 파일 선택</button>
            <button class="btn btn-primary" id="btnUpload" onclick="uploadImage()" style="display:none;">업로드</button>
        </div>
    </div>
</div>

<div class="toast" id="toast"></div>

<script>
const CTX = '<c:url value="/" />'.replace(/\/$/, '');
const ENTITIES = ${entitiesJson};
let currentFilter = 'all';
let selectedEntity = null;
let selectedFile = null;

// ── 렌더링 ──────────────────────────────────────────────────────
function render() {
    const grid = document.getElementById('entityGrid');
    const filtered = ENTITIES.filter(e => {
        if (currentFilter === 'all')      return true;
        if (currentFilter === 'unit')     return e.type === 'unit';
        if (currentFilter === 'building') return e.type === 'building';
        if (currentFilter === 'nok')      return !e.imageUrl;
        return e.race === currentFilter;
    });
    document.getElementById('countLabel').textContent = filtered.length + '개';

    grid.innerHTML = filtered.map(e => {
        const imgHtml = e.imageUrl
            ? '<img src="' + e.imageUrl + '?v=' + Date.now() + '" onerror="this.style.display=\'none\';this.nextElementSibling.style.display=\'flex\'">'
            : '';
        const phHtml = '<div class="entity-img-placeholder" style="' + (e.imageUrl ? 'display:none' : '') + '">' + typeIcon(e.type) + '</div>';
        return '<div class="entity-card ' + (e.imageUrl ? 'has-image' : '') + '" onclick="openModal(\'' + e.id + '\')">' +
            '<span class="type-badge ' + e.type + '">' + (e.type === 'unit' ? 'U' : 'B') + '</span>' +
            '<span class="race-badge ' + e.race + '">' + e.race + '</span>' +
            '<div class="entity-img-wrap">' +
                imgHtml + phHtml +
                '<div class="entity-img-overlay">✏️</div>' +
            '</div>' +
            '<div class="entity-name">' + e.displayName + '</div>' +
            '<div class="entity-id">' + e.id + '</div>' +
            '<div class="img-status ' + (e.imageUrl ? 'ok' : 'nok') + '"></div>' +
        '</div>';
    }).join('');
}

function typeIcon(type) { return type === 'unit' ? '⚔️' : '🏛'; }

function setFilter(f, btn) {
    currentFilter = f;
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    render();
}

// ── 모달 ────────────────────────────────────────────────────────
function openModal(id) {
    selectedEntity = ENTITIES.find(e => e.id === id);
    selectedFile = null;
    if (!selectedEntity) return;

    document.getElementById('modalTitle').textContent = selectedEntity.displayName + ' 이미지';
    document.getElementById('modalSubtitle').textContent =
        '[' + selectedEntity.race + '] ' + selectedEntity.type + '  ·  ID: ' + selectedEntity.id;

    const img = document.getElementById('previewImg');
    const ph  = document.getElementById('previewPh');
    if (selectedEntity.imageUrl) {
        img.src = selectedEntity.imageUrl + '?v=' + Date.now();
        img.style.display = 'block';
        ph.style.display  = 'none';
        document.getElementById('btnDelete').style.display = 'inline-block';
    } else {
        img.src = '';
        img.style.display = 'none';
        ph.style.display  = 'flex';
        document.getElementById('btnDelete').style.display = 'none';
    }
    document.getElementById('btnUpload').style.display = 'none';
    document.getElementById('fileInput').value = '';
    document.getElementById('progressBar').classList.remove('show');
    document.getElementById('modalOverlay').classList.add('open');
}

function closeModal(e) {
    if (e && e.target !== document.getElementById('modalOverlay')) return;
    document.getElementById('modalOverlay').classList.remove('open');
    selectedEntity = null; selectedFile = null;
}

function onFileSelected(e) {
    const file = e.target.files[0];
    if (!file) return;
    selectedFile = file;
    const reader = new FileReader();
    reader.onload = ev => {
        const img = document.getElementById('previewImg');
        const ph  = document.getElementById('previewPh');
        img.src = ev.target.result;
        img.style.display = 'block';
        ph.style.display  = 'none';
        document.getElementById('btnUpload').style.display = 'inline-block';
    };
    reader.readAsDataURL(file);
}

// ── 업로드 ──────────────────────────────────────────────────────
function uploadImage() {
    if (!selectedFile || !selectedEntity) return;
    const bar  = document.getElementById('progressBar');
    const fill = document.getElementById('progressFill');
    bar.classList.add('show');
    fill.style.width = '30%';

    const fd = new FormData();
    fd.append('file', selectedFile);
    fd.append('entityId', selectedEntity.id);

    fetch(CTX + '/admin/entity/upload', { method: 'POST', body: fd })
        .then(r => r.json())
        .then(data => {
            fill.style.width = '100%';
            setTimeout(() => bar.classList.remove('show'), 400);
            if (data.success) {
                // 로컬 캐시 업데이트
                selectedEntity.imageUrl = data.url;
                const ent = ENTITIES.find(e => e.id === selectedEntity.id);
                if (ent) ent.imageUrl = data.url;
                document.getElementById('btnDelete').style.display = 'inline-block';
                document.getElementById('btnUpload').style.display = 'none';
                render();
                toast('업로드 완료!', 'success');
            } else {
                toast('업로드 실패: ' + (data.message || ''), 'error');
            }
        })
        .catch(() => toast('네트워크 오류', 'error'));
}

function deleteImage() {
    if (!selectedEntity) return;
    if (!confirm(selectedEntity.displayName + ' 이미지를 삭제할까요?')) return;

    fetch(CTX + '/admin/entity/delete', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'entityId=' + encodeURIComponent(selectedEntity.id)
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            selectedEntity.imageUrl = null;
            const ent = ENTITIES.find(e => e.id === selectedEntity.id);
            if (ent) ent.imageUrl = null;
            document.getElementById('previewImg').style.display = 'none';
            document.getElementById('previewPh').style.display  = 'flex';
            document.getElementById('btnDelete').style.display  = 'none';
            render();
            toast('이미지 삭제됨', 'success');
        } else {
            toast('삭제 실패', 'error');
        }
    });
}

// ── 토스트 ──────────────────────────────────────────────────────
function toast(msg, type) {
    const el = document.getElementById('toast');
    el.textContent = msg;
    el.className = 'toast ' + (type || '');
    el.classList.add('show');
    setTimeout(() => el.classList.remove('show'), 2500);
}

render();
</script>
</body>
</html>
