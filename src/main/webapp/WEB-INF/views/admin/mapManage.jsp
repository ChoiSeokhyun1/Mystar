<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>맵 관리</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/adminStage.css' />">
    <style>
        /* ── 레이아웃 ── */
        .map-container { max-width: 1400px; margin: 40px auto; padding: 20px; }
        .map-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
        .map-header h2 { color: #00ff88; font-size: 22px; margin: 0; }

        /* ── 맵 목록 테이블 ── */
        .map-table { width: 100%; border-collapse: collapse; background: #1a1a1a; border-radius: 8px; overflow: hidden; }
        .map-table th { background: #2a2a2a; color: #00ff88; padding: 14px 16px; text-align: left; font-size: 13px; }
        .map-table td { padding: 11px 16px; border-bottom: 1px solid #2d2d2d; color: #ddd; font-size: 13px; vertical-align: middle; }
        .map-table tr:hover td { background: #222; }
        .map-thumb { width: 80px; height: 52px; object-fit: cover; border-radius: 4px; border: 1px solid #333; cursor: pointer; }
        .map-thumb-empty { width: 80px; height: 52px; background: #2a2a2a; border-radius: 4px; border: 1px dashed #444;
                           display: flex; align-items: center; justify-content: center; color: #555; font-size: 11px; }
        .win-badge { display: inline-block; padding: 2px 8px; border-radius: 10px; font-size: 11px; font-weight: bold; margin: 0 2px; }
        .win-t { background: #1a3a5c; color: #5bc0ff; }
        .win-p { background: #3a2a00; color: #ffd700; }
        .win-z { background: #2d0050; color: #cc88ff; }

        /* ── 버튼 ── */
        .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; font-size: 13px; transition: all .2s; }
        .btn-primary { background: #00ff88; color: #000; font-weight: bold; }
        .btn-primary:hover { background: #00dd77; }
        .btn-edit { background: #3498db; color: #fff; margin-right: 4px; }
        .btn-edit:hover { background: #2980b9; }
        .btn-point { background: #9b59b6; color: #fff; margin-right: 4px; }
        .btn-point:hover { background: #8e44ad; }
        .btn-danger { background: #e74c3c; color: #fff; }
        .btn-danger:hover { background: #c0392b; }
        .btn-secondary { background: #444; color: #ccc; }
        .btn-secondary:hover { background: #555; }
        .btn-sm { padding: 5px 11px; font-size: 12px; }

        /* ── 모달 공통 ── */
        .modal { display: none; position: fixed; inset: 0; background: rgba(0,0,0,.82); z-index: 1000; overflow-y: auto; }
        .modal.active { display: flex; align-items: flex-start; justify-content: center; padding: 40px 20px; }
        .modal-box { background: #1a1a1a; border: 1px solid #333; border-radius: 10px; width: 100%; max-width: 560px;
                     padding: 28px 32px; position: relative; }
        .modal-box.wide { max-width: 1100px; }
        .modal-title { color: #00ff88; font-size: 18px; font-weight: bold; margin-bottom: 22px; }
        .modal-close { position: absolute; top: 16px; right: 20px; background: none; border: none;
                       color: #888; font-size: 20px; cursor: pointer; line-height: 1; }
        .modal-close:hover { color: #fff; }

        /* ── 폼 ── */
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; color: #aaa; font-size: 12px; margin-bottom: 6px; }
        .form-group input[type="text"],
        .form-group input[type="number"],
        .form-group textarea,
        .form-group select {
            width: 100%; padding: 9px 12px; background: #111; border: 1px solid #444; border-radius: 5px;
            color: #fff; font-size: 13px; box-sizing: border-box;
        }
        .form-group textarea { resize: vertical; min-height: 70px; }
        .form-row { display: flex; gap: 12px; }
        .form-row .form-group { flex: 1; }
        .form-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 22px; }

        /* ── 이미지 업로드 ── */
        .img-upload-zone { border: 2px dashed #444; border-radius: 8px; padding: 20px;
                           text-align: center; cursor: pointer; transition: border-color .2s; }
        .img-upload-zone:hover { border-color: #00ff88; }
        .img-upload-zone input[type="file"] { display: none; }
        .img-upload-zone .zone-label { color: #888; font-size: 13px; }
        .img-preview { max-width: 100%; max-height: 200px; border-radius: 6px; margin-top: 10px; display: none; }

        /* ── 지점 편집 모달 (맵 이미지 + 지점 패널) ── */
        .point-editor { display: flex; gap: 20px; align-items: flex-start; }
        .point-canvas-wrap {
            flex: 1; position: relative; background: #111; border-radius: 8px;
            overflow: hidden; cursor: crosshair; min-width: 0;
        }
        .point-canvas-wrap img { display: block; width: 100%; height: auto; max-height: 600px; object-fit: contain; user-select: none; }
        .point-dot {
            position: absolute; width: 18px; height: 18px; border-radius: 50%;
            transform: translate(-50%, -50%);
            border: 2px solid #fff; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            font-size: 9px; font-weight: bold; color: #fff;
            box-shadow: 0 0 6px rgba(0,0,0,.8);
            transition: transform .15s;
        }
        .point-dot:hover { transform: translate(-50%, -50%) scale(1.3); }
        .point-dot.type-STARTING  { background: #e74c3c; }
        .point-dot.type-RESOURCE  { background: #f39c12; }
        .point-dot.type-RAMP      { background: #3498db; }
        .point-dot.type-CUSTOM    { background: #9b59b6; }
        .point-dot.selected       { box-shadow: 0 0 0 3px #00ff88, 0 0 8px #00ff88; }
        .point-tooltip {
            position: absolute; background: rgba(0,0,0,.85); color: #fff;
            padding: 3px 8px; border-radius: 4px; font-size: 11px;
            white-space: nowrap; pointer-events: none;
            transform: translate(-50%, -130%);
        }
        /* 지점 사이드 패널 */
        .point-panel { width: 260px; flex-shrink: 0; }
        .point-panel-title { color: #00ff88; font-size: 14px; font-weight: bold; margin-bottom: 12px; }
        .point-list { max-height: 480px; overflow-y: auto; }
        .point-item {
            background: #222; border: 1px solid #333; border-radius: 6px;
            padding: 9px 12px; margin-bottom: 8px; display: flex; align-items: center; gap: 8px;
            cursor: pointer; transition: border-color .15s;
        }
        .point-item:hover, .point-item.selected { border-color: #00ff88; }
        .point-color-dot { width: 12px; height: 12px; border-radius: 50%; flex-shrink: 0; }
        .point-item-info { flex: 1; min-width: 0; }
        .point-item-name { color: #ddd; font-size: 13px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .point-item-coord { color: #666; font-size: 11px; margin-top: 2px; }
        .point-item-actions { display: flex; gap: 4px; flex-shrink: 0; }
        .point-form { background: #161616; border: 1px solid #333; border-radius: 6px; padding: 14px; margin-top: 14px; }
        .point-form-title { color: #aaa; font-size: 12px; margin-bottom: 10px; }
        .coord-display { color: #00ff88; font-size: 12px; margin-bottom: 10px; }
        .type-legend { display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 12px; }
        .type-chip {
            display: flex; align-items: center; gap: 5px;
            padding: 3px 9px; border-radius: 10px; font-size: 11px;
            background: #222; border: 1px solid #333; cursor: pointer; transition: border-color .15s;
        }
        .type-chip.active { border-color: #00ff88; }
        .type-chip .dot { width: 8px; height: 8px; border-radius: 50%; }
        .hint-text { color: #666; font-size: 11px; margin-bottom: 10px; line-height: 1.5; }

        /* ── 반응형 ── */
        @media (max-width: 800px) {
            .point-editor { flex-direction: column; }
            .point-panel { width: 100%; }
        }
    </style>
</head>
<body>
<c:set var="adminCurrentPage" value="map" />
<%@ include file="/WEB-INF/views/layout/adminHeader.jsp" %>

<div class="map-container">
    <div class="map-header">
        <h2>🗺️ 맵 관리</h2>
        <button class="btn btn-primary" onclick="openCreateModal()">+ 새 맵 등록</button>
    </div>

    <table class="map-table" id="mapTable">
        <thead>
            <tr>
                <th style="width:90px">썸네일</th>
                <th>맵 ID</th>
                <th>맵 이름</th>
                <th>설명</th>
                <th>종족 승률</th>
                <th>지점 수</th>
                <th style="width:200px">관리</th>
            </tr>
        </thead>
        <tbody id="mapTbody"></tbody>
    </table>
</div>

<!-- ======================================================
     모달 1: 맵 등록 / 수정
====================================================== -->
<div class="modal" id="mapModal">
    <div class="modal-box">
        <button class="modal-close" onclick="closeModal('mapModal')">✕</button>
        <div class="modal-title" id="mapModalTitle">새 맵 등록</div>

        <div class="form-group">
            <label>맵 이름 *</label>
            <input type="text" id="fMapName" placeholder="예) 파이팅 스피릿">
        </div>
        <div class="form-group">
            <label>설명</label>
            <textarea id="fMapDesc" placeholder="맵 특징, 출처 등"></textarea>
        </div>
        <div class="form-group">
            <label>맵 이미지</label>
            <div class="img-upload-zone" onclick="document.getElementById('mapImgFile').click()">
                <input type="file" id="mapImgFile" accept="image/*" onchange="previewMapImg(this)">
                <div class="zone-label" id="uploadZoneLabel">클릭하여 이미지 업로드 (PNG / JPG / GIF)</div>
                <img id="mapImgPreview" class="img-preview" alt="미리보기">
            </div>
            <input type="hidden" id="fMapImgUrl">
        </div>
        <div class="form-row">
            <div class="form-group">
                <label>테란 승률 (%)</label>
                <input type="number" id="fWinRateT" value="50" min="0" max="100" step="0.01">
            </div>
            <div class="form-group">
                <label>프로토스 승률 (%)</label>
                <input type="number" id="fWinRateP" value="50" min="0" max="100" step="0.01">
            </div>
            <div class="form-group">
                <label>저그 승률 (%)</label>
                <input type="number" id="fWinRateZ" value="50" min="0" max="100" step="0.01">
            </div>
        </div>
        <div class="form-actions">
            <button class="btn btn-secondary" onclick="closeModal('mapModal')">취소</button>
            <button class="btn btn-primary" onclick="saveMap()">저장</button>
        </div>
    </div>
</div>

<!-- ======================================================
     모달 2: 지점 편집
====================================================== -->
<div class="modal" id="pointModal">
    <div class="modal-box wide">
        <button class="modal-close" onclick="closeModal('pointModal')">✕</button>
        <div class="modal-title" id="pointModalTitle">지점 편집</div>

        <div class="point-editor">
            <!-- 맵 이미지 + 오버레이 -->
            <div class="point-canvas-wrap" id="mapCanvas" onclick="handleCanvasClick(event)">
                <img id="canvasImg" src="" alt="맵 이미지" draggable="false">
                <!-- 지점 dot들이 JS로 여기에 추가됨 -->
                <div id="dotContainer"></div>
            </div>

            <!-- 우측 패널 -->
            <div class="point-panel">
                <div class="point-panel-title">📍 등록된 지점</div>

                <!-- 범례 -->
                <div class="type-legend">
                    <div class="type-chip" data-type="STARTING">
                        <span class="dot" style="background:#e74c3c"></span>스타팅
                    </div>
                    <div class="type-chip" data-type="RESOURCE">
                        <span class="dot" style="background:#f39c12"></span>멀티
                    </div>
                    <div class="type-chip" data-type="RAMP">
                        <span class="dot" style="background:#3498db"></span>램프
                    </div>
                    <div class="type-chip" data-type="CUSTOM">
                        <span class="dot" style="background:#9b59b6"></span>기타
                    </div>
                </div>

                <!-- 지점 목록 -->
                <div class="point-list" id="pointList"></div>

                <!-- 지점 입력 폼 -->
                <div class="point-form" id="pointForm" style="display:none">
                    <div class="point-form-title" id="pointFormTitle">새 지점 추가</div>
                    <div class="coord-display" id="coordDisplay">클릭한 위치: —</div>
                    <div class="form-group">
                        <label>지점 이름 *</label>
                        <input type="text" id="fPointName" placeholder="예) 스타팅1, 멀티2, 중앙 램프">
                    </div>
                    <div class="form-group">
                        <label>유형</label>
                        <select id="fPointType">
                            <option value="STARTING">스타팅</option>
                            <option value="RESOURCE">멀티(자원)</option>
                            <option value="RAMP">램프</option>
                            <option value="CUSTOM">기타</option>
                        </select>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>X (픽셀)</label>
                            <input type="number" id="fPointX" min="0">
                        </div>
                        <div class="form-group">
                            <label>Y (픽셀)</label>
                            <input type="number" id="fPointY" min="0">
                        </div>
                    </div>
                    <input type="hidden" id="fPointId" value="0">
                    <input type="hidden" id="fPointMapId">
                    <div class="form-actions" style="margin-top:12px">
                        <button class="btn btn-secondary btn-sm" onclick="cancelPointEdit()">취소</button>
                        <button class="btn btn-primary btn-sm" onclick="savePoint()">지점 저장</button>
                    </div>
                </div>

                <p class="hint-text" id="canvasHint" style="margin-top:10px">
                    💡 맵 이미지를 <strong>클릭</strong>하면 해당 좌표에 지점을 추가합니다.
                </p>
            </div>
        </div>
    </div>
</div>

<script>
/* ============================================================
   데이터 초기화
============================================================ */
var ALL_MAPS = ${mapJson};

/* ============================================================
   유틸
============================================================ */
function ctxPath() { return '<c:url value="/" />'.replace(/\/$/, ''); }

function typeColor(t) {
    return { STARTING:'#e74c3c', RESOURCE:'#f39c12', RAMP:'#3498db', CUSTOM:'#9b59b6' }[t] || '#888';
}
function typeLabel(t) {
    return { STARTING:'스타팅', RESOURCE:'멀티', RAMP:'램프', CUSTOM:'기타' }[t] || t;
}

/* ============================================================
   맵 목록 렌더
============================================================ */
function renderMapTable() {
    var tbody = document.getElementById('mapTbody');
    if (ALL_MAPS.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;color:#555;padding:40px">등록된 맵이 없습니다.</td></tr>';
        return;
    }
    var html = '';
    ALL_MAPS.forEach(function(m) {
        var thumb = m.mapImgUrl
            ? '<img class="map-thumb" src="' + m.mapImgUrl + '" alt="" onclick="previewFull(\'' + m.mapImgUrl + '\')">'
            : '<div class="map-thumb-empty">NO IMG</div>';
        html += '<tr id="map-row-' + m.mapId + '">'
            + '<td>' + thumb + '</td>'
            + '<td style="color:#888;font-size:12px">' + m.mapId + '</td>'
            + '<td style="color:#fff;font-weight:bold">' + escHtml(m.mapName) + '</td>'
            + '<td style="color:#aaa">' + escHtml(m.description || '-') + '</td>'
            + '<td>'
            +   '<span class="win-badge win-t">T ' + m.winRateT + '%</span>'
            +   '<span class="win-badge win-p">P ' + m.winRateP + '%</span>'
            +   '<span class="win-badge win-z">Z ' + m.winRateZ + '%</span>'
            + '</td>'
            + '<td id="map-ptcount-' + m.mapId + '" style="color:#aaa">-</td>'
            + '<td>'
            +   '<button class="btn btn-edit btn-sm" onclick="openEditModal(\'' + m.mapId + '\')">수정</button>'
            +   '<button class="btn btn-point btn-sm" onclick="openPointModal(\'' + m.mapId + '\')">지점 편집</button>'
            +   '<button class="btn btn-danger btn-sm" onclick="deleteMap(\'' + m.mapId + '\', \'' + escHtml(m.mapName) + '\')">삭제</button>'
            + '</td>'
            + '</tr>';
    });
    tbody.innerHTML = html;
    // 각 맵의 지점 수 비동기 로드
    ALL_MAPS.forEach(function(m) { loadPointCount(m.mapId); });
}

function loadPointCount(mapId) {
    fetch(ctxPath() + '/admin/map/points?mapId=' + encodeURIComponent(mapId))
        .then(function(r){ return r.json(); })
        .then(function(d){
            var el = document.getElementById('map-ptcount-' + mapId);
            if (el) el.textContent = d.success ? (d.points.length + '개') : '-';
        });
}

function escHtml(s) {
    if (!s) return '';
    return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

function previewFull(url) {
    window.open(url, '_blank');
}

/* ============================================================
   모달 공통
============================================================ */
function openModal(id) { document.getElementById(id).classList.add('active'); }
function closeModal(id) { document.getElementById(id).classList.remove('active'); }

/* ============================================================
   맵 등록/수정 모달
============================================================ */
var _editMapId = null;

function resetMapForm() {
    document.getElementById('fMapName').value = '';
    document.getElementById('fMapDesc').value = '';
    document.getElementById('fMapImgUrl').value = '';
    document.getElementById('fWinRateT').value = 50;
    document.getElementById('fWinRateP').value = 50;
    document.getElementById('fWinRateZ').value = 50;
    document.getElementById('mapImgPreview').style.display = 'none';
    document.getElementById('uploadZoneLabel').textContent = '클릭하여 이미지 업로드 (PNG / JPG / GIF)';
}

function openCreateModal() {
    _editMapId = null;
    resetMapForm();
    document.getElementById('mapModalTitle').textContent = '새 맵 등록';
    openModal('mapModal');
}

function openEditModal(mapId) {
    _editMapId = mapId;
    var m = ALL_MAPS.find(function(x){ return x.mapId === mapId; });
    if (!m) return;
    document.getElementById('mapModalTitle').textContent = '맵 수정 — ' + m.mapName;
    document.getElementById('fMapName').value    = m.mapName || '';
    document.getElementById('fMapDesc').value    = m.description || '';
    document.getElementById('fMapImgUrl').value  = m.mapImgUrl || '';
    document.getElementById('fWinRateT').value   = m.winRateT || 50;
    document.getElementById('fWinRateP').value   = m.winRateP || 50;
    document.getElementById('fWinRateZ').value   = m.winRateZ || 50;
    if (m.mapImgUrl) {
        document.getElementById('mapImgPreview').src = m.mapImgUrl;
        document.getElementById('mapImgPreview').style.display = 'block';
        document.getElementById('uploadZoneLabel').textContent = '이미지 변경 (클릭)';
    } else {
        document.getElementById('mapImgPreview').style.display = 'none';
        document.getElementById('uploadZoneLabel').textContent = '클릭하여 이미지 업로드';
    }
    openModal('mapModal');
}

function previewMapImg(input) {
    if (!input.files || !input.files[0]) return;
    var file = input.files[0];
    // 미리보기
    var reader = new FileReader();
    reader.onload = function(e) {
        var preview = document.getElementById('mapImgPreview');
        preview.src = e.target.result;
        preview.style.display = 'block';
        document.getElementById('uploadZoneLabel').textContent = '이미지 변경 (클릭)';
    };
    reader.readAsDataURL(file);
    // 서버 업로드
    var formData = new FormData();
    formData.append('file', file);
    fetch(ctxPath() + '/admin/map/upload-image', { method: 'POST', body: formData })
        .then(function(r){ return r.json(); })
        .then(function(d){
            if (d.success) {
                document.getElementById('fMapImgUrl').value = d.url;
            } else {
                alert('이미지 업로드 실패: ' + (d.message || ''));
            }
        });
}

function saveMap() {
    var name = document.getElementById('fMapName').value.trim();
    if (!name) { alert('맵 이름을 입력하세요.'); return; }

    var payload = {
        mapName:     name,
        description: document.getElementById('fMapDesc').value.trim(),
        mapImgUrl:   document.getElementById('fMapImgUrl').value || null,
        winRateT:    parseFloat(document.getElementById('fWinRateT').value) || 50,
        winRateP:    parseFloat(document.getElementById('fWinRateP').value) || 50,
        winRateZ:    parseFloat(document.getElementById('fWinRateZ').value) || 50
    };

    if (_editMapId) {
        payload.mapId = _editMapId;
        fetch(ctxPath() + '/admin/map/update', {
            method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify(payload)
        }).then(function(r){ return r.json(); }).then(function(d){
            if (d.success) {
                var m = ALL_MAPS.find(function(x){ return x.mapId === _editMapId; });
                if (m) Object.assign(m, payload);
                renderMapTable();
                closeModal('mapModal');
            } else { alert('수정 실패: ' + (d.message || '')); }
        });
    } else {
        fetch(ctxPath() + '/admin/map/create', {
            method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify(payload)
        }).then(function(r){ return r.json(); }).then(function(d){
            if (d.success) {
                payload.mapId = d.mapId;
                ALL_MAPS.push(payload);
                renderMapTable();
                closeModal('mapModal');
            } else { alert('등록 실패: ' + (d.message || '')); }
        });
    }
}

function deleteMap(mapId, mapName) {
    if (!confirm('[' + mapName + '] 맵을 삭제하시겠습니까?\n연결된 모든 지점 데이터도 삭제됩니다.')) return;
    fetch(ctxPath() + '/admin/map/delete', {
        method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify({mapId: mapId})
    }).then(function(r){ return r.json(); }).then(function(d){
        if (d.success) {
            ALL_MAPS = ALL_MAPS.filter(function(m){ return m.mapId !== mapId; });
            renderMapTable();
        } else { alert('삭제 실패: ' + (d.message || '')); }
    });
}

/* ============================================================
   지점 편집 모달
============================================================ */
var _ptMapId    = null;
var _ptImgW     = 1;   // 이미지 원본 픽셀 너비
var _ptImgH     = 1;   // 이미지 원본 픽셀 높이
var _points     = [];  // { pointId, mapId, pointName, pointType, pixelX, pixelY }
var _pendingX   = null;
var _pendingY   = null;
var _editPtId   = null;

function openPointModal(mapId) {
    var m = ALL_MAPS.find(function(x){ return x.mapId === mapId; });
    if (!m) return;
    _ptMapId = mapId;
    _editPtId = null;
    _pendingX = null;
    _pendingY = null;

    document.getElementById('pointModalTitle').textContent = '지점 편집 — ' + m.mapName;
    document.getElementById('fPointMapId').value = mapId;

    var img = document.getElementById('canvasImg');
    if (m.mapImgUrl) {
        img.src = m.mapImgUrl;
        img.style.display = 'block';
        document.getElementById('canvasHint').style.display = 'block';
        img.onload = function() {
            _ptImgW = img.naturalWidth;
            _ptImgH = img.naturalHeight;
        };
    } else {
        img.src = '';
        img.style.display = 'none';
        document.getElementById('canvasHint').innerHTML =
            '⚠️ 이 맵에 이미지가 등록되지 않았습니다.<br>수정 메뉴에서 이미지를 먼저 업로드하세요.';
    }

    document.getElementById('pointForm').style.display = 'none';
    loadPoints(mapId);
    openModal('pointModal');
}

function loadPoints(mapId) {
    fetch(ctxPath() + '/admin/map/points?mapId=' + encodeURIComponent(mapId))
        .then(function(r){ return r.json(); })
        .then(function(d){
            _points = d.success ? d.points : [];
            renderPoints();
        });
}

/* 캔버스 클릭 → 픽셀 좌표 계산 */
function handleCanvasClick(e) {
    var img = document.getElementById('canvasImg');
    if (!img.src || img.src === window.location.href) return;
    var rect = img.getBoundingClientRect();
    // 렌더 사이즈 대비 원본 사이즈 비율
    var scaleX = _ptImgW / rect.width;
    var scaleY = _ptImgH / rect.height;
    var rx = Math.round((e.clientX - rect.left) * scaleX);
    var ry = Math.round((e.clientY - rect.top)  * scaleY);
    // 기존 선택 해제
    _editPtId = null;
    _pendingX = rx;
    _pendingY = ry;
    document.getElementById('fPointId').value   = 0;
    document.getElementById('fPointName').value = '';
    document.getElementById('fPointType').value = 'STARTING';
    document.getElementById('fPointX').value    = rx;
    document.getElementById('fPointY').value    = ry;
    document.getElementById('coordDisplay').textContent = 'X: ' + rx + '  Y: ' + ry;
    document.getElementById('pointFormTitle').textContent = '새 지점 추가';
    document.getElementById('pointForm').style.display = 'block';
    renderPoints(); // 점 강조 해제
}

/* 지점 렌더 (dot + 목록) */
function renderPoints() {
    var dotCont = document.getElementById('dotContainer');
    var listEl  = document.getElementById('pointList');
    var img     = document.getElementById('canvasImg');
    dotCont.innerHTML = '';
    listEl.innerHTML  = '';

    if (_points.length === 0) {
        listEl.innerHTML = '<p style="color:#555;font-size:12px;text-align:center;padding:20px 0">등록된 지점이 없습니다</p>';
    }

    var rect = img.getBoundingClientRect();
    var scaleX = rect.width  / _ptImgW;
    var scaleY = rect.height / _ptImgH;

    _points.forEach(function(pt, idx) {
        // dot
        var dot = document.createElement('div');
        dot.className = 'point-dot type-' + pt.pointType + (_editPtId === pt.pointId ? ' selected' : '');
        dot.style.left = (pt.pixelX * scaleX) + 'px';
        dot.style.top  = (pt.pixelY * scaleY) + 'px';
        dot.textContent = idx + 1;
        dot.title = pt.pointName;
        dot.onclick = function(e) { e.stopPropagation(); selectPoint(pt.pointId); };

        // tooltip
        var tip = document.createElement('div');
        tip.className = 'point-tooltip';
        tip.textContent = pt.pointName;
        dot.appendChild(tip);
        dotCont.appendChild(dot);

        // list item
        var item = document.createElement('div');
        item.className = 'point-item' + (_editPtId === pt.pointId ? ' selected' : '');
        item.id = 'ptitem-' + pt.pointId;
        item.innerHTML =
            '<span class="point-color-dot" style="background:' + typeColor(pt.pointType) + '"></span>'
            + '<div class="point-item-info">'
            +   '<div class="point-item-name">' + (idx+1) + '. ' + escHtml(pt.pointName) + '</div>'
            +   '<div class="point-item-coord">' + typeLabel(pt.pointType) + ' | X:' + pt.pixelX + ' Y:' + pt.pixelY + '</div>'
            + '</div>'
            + '<div class="point-item-actions">'
            +   '<button class="btn btn-edit btn-sm" onclick="selectPoint(' + pt.pointId + ')">수정</button>'
            +   '<button class="btn btn-danger btn-sm" onclick="deletePoint(' + pt.pointId + ')">삭제</button>'
            + '</div>';
        listEl.appendChild(item);
    });
}

/* 이미지 리사이즈 시 dot 위치 재조정 */
var _resizeTimer;
window.addEventListener('resize', function(){
    clearTimeout(_resizeTimer);
    _resizeTimer = setTimeout(function(){ if (_ptMapId) renderPoints(); }, 100);
});

function selectPoint(pointId) {
    var pt = _points.find(function(p){ return p.pointId === pointId; });
    if (!pt) return;
    _editPtId = pointId;
    document.getElementById('fPointId').value    = pt.pointId;
    document.getElementById('fPointName').value  = pt.pointName;
    document.getElementById('fPointType').value  = pt.pointType;
    document.getElementById('fPointX').value     = pt.pixelX;
    document.getElementById('fPointY').value     = pt.pixelY;
    document.getElementById('coordDisplay').textContent = 'X: ' + pt.pixelX + '  Y: ' + pt.pixelY;
    document.getElementById('pointFormTitle').textContent = '지점 수정 — ' + pt.pointName;
    document.getElementById('pointForm').style.display = 'block';
    renderPoints();
}

function cancelPointEdit() {
    _editPtId = null;
    _pendingX = null;
    _pendingY = null;
    document.getElementById('pointForm').style.display = 'none';
    renderPoints();
}

function savePoint() {
    var name = document.getElementById('fPointName').value.trim();
    if (!name) { alert('지점 이름을 입력하세요.'); return; }
    var px = parseInt(document.getElementById('fPointX').value);
    var py = parseInt(document.getElementById('fPointY').value);
    if (isNaN(px) || isNaN(py)) { alert('좌표를 확인하세요.'); return; }

    var payload = {
        pointId:   parseInt(document.getElementById('fPointId').value) || 0,
        mapId:     _ptMapId,
        pointName: name,
        pointType: document.getElementById('fPointType').value,
        pixelX:    px,
        pixelY:    py
    };

    fetch(ctxPath() + '/admin/map/point/save', {
        method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify(payload)
    }).then(function(r){ return r.json(); }).then(function(d){
        if (d.success) {
            loadPoints(_ptMapId);
            loadPointCount(_ptMapId);
            cancelPointEdit();
        } else { alert('저장 실패: ' + (d.message || '')); }
    });
}

function deletePoint(pointId) {
    var pt = _points.find(function(p){ return p.pointId === pointId; });
    if (!pt) return;
    if (!confirm('[' + pt.pointName + '] 지점을 삭제하시겠습니까?')) return;
    fetch(ctxPath() + '/admin/map/point/delete', {
        method: 'POST', headers: {'Content-Type':'application/json'}, body: JSON.stringify({pointId: pointId})
    }).then(function(r){ return r.json(); }).then(function(d){
        if (d.success) {
            loadPoints(_ptMapId);
            loadPointCount(_ptMapId);
            if (_editPtId === pointId) cancelPointEdit();
        } else { alert('삭제 실패: ' + (d.message || '')); }
    });
}

/* ============================================================
   초기화
============================================================ */
renderMapTable();
</script>
</body>
</html>