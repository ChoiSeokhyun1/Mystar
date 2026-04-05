<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>관리자 - 선수 관리</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/adminStage.css' />">
    <link rel="stylesheet" href="<c:url value='/css/adminPlayer.css' />">
</head>
<body>

<c:set var="adminCurrentPage" value="player" />
<%@ include file="/WEB-INF/views/layout/adminHeader.jsp" %>

<div class="admin-page-wrap">

    <div class="admin-top-bar">
        <div>
            <div style="color:#6366f1;font-size:10px;font-weight:700;letter-spacing:0.1em;text-transform:uppercase;margin-bottom:2px;">ADMIN PANEL</div>
            <h1 style="color:#e2e8f0;font-size:18px;font-weight:800;margin:0;">선수 관리</h1>
        </div>
        <button class="btn btn-primary" onclick="openEditModal(null)">+ 선수 추가</button>
    </div>

    <div class="player-toolbar">
        <input type="text" id="searchInput" placeholder="🔍 선수 이름 검색..." oninput="renderTable()">
        <div class="toolbar-sep"></div>
        <select id="filterRace" onchange="renderTable()">
            <option value="">종족 전체</option>
            <option value="T">🔵 테란</option>
            <option value="P">💜 프로토스</option>
            <option value="Z">🟢 저그</option>
        </select>
        <select id="filterRarity" onchange="renderTable()">
            <option value="">등급 전체</option>
            <option value="UR">UR</option>
            <option value="SSR">SSR</option>
            <option value="SR">SR</option>
            <option value="R">R</option>
            <option value="N">N</option>
        </select>
        <select id="filterPack" onchange="renderTable()">
            <option value="">팩 전체</option>
        </select>
        <div class="toolbar-sep"></div>
        <select id="sortBy" onchange="renderTable()">
            <option value="rarity">등급순</option>
            <option value="name">이름순</option>
            <option value="total">스탯합계순</option>
            <option value="atk">ATK순</option>
        </select>
        <span class="player-count" id="countLabel"></span>
    </div>

    <div class="player-table-wrap">
        <table class="player-table">
            <thead>
                <tr>
                    <th style="width:40px">사진</th>
                    <th>이름</th>
                    <th>종족</th>
                    <th>등급</th>
                    <th>ATK</th><th>DEF</th><th>MAC</th><th>MIC</th><th>LCK</th>
                    <th>합계</th>
                    <th>비용</th>
                    <th>소속 팩</th>
                    <th style="width:120px">관리</th>
                </tr>
            </thead>
            <tbody id="playerTableBody"></tbody>
        </table>
    </div>
</div>

<!-- 편집 모달 -->
<div class="modal-overlay" id="editModal">
    <div class="edit-modal">
        <div class="edit-modal-header">
            <h2 id="editModalTitle">선수 추가</h2>
            <button class="modal-close" onclick="closeEditModal()">✕</button>
        </div>
        <div class="edit-modal-body">
            <input type="hidden" id="editSeq">
            <div class="edit-grid">
                <div>
                    <label class="form-label">이름 *</label>
                    <input type="text" class="form-input" id="editName" placeholder="선수 이름">
                </div>
                <div>
                    <label class="form-label">종족 *</label>
                    <select class="form-select" id="editRace">
                        <option value="T">테란 (T)</option>
                        <option value="P">프로토스 (P)</option>
                        <option value="Z">저그 (Z)</option>
                    </select>
                </div>
                <div>
                    <label class="form-label">등급 *</label>
                    <select class="form-select" id="editRarity">
                        <option value="UR">UR</option>
                        <option value="SSR">SSR</option>
                        <option value="SR">SR</option>
                        <option value="R">R</option>
                        <option value="N">N</option>
                    </select>
                </div>
                <div>
                    <label class="form-label">비용 (크리스탈)</label>
                    <input type="number" class="form-input" id="editCost" value="0" min="0">
                </div>
                <div class="full">
                    <label class="form-label">이미지 URL</label>
                    <input type="text" class="form-input" id="editImgUrl" placeholder="https://...">
                </div>
                <div class="full">
                    <label class="form-label" style="margin-bottom:8px;">스탯</label>
                    <div class="stat-grid">
                        <div class="stat-item">
                            <label style="color:#f87171">ATK</label>
                            <input type="number" id="editAtk" value="50" min="0" max="999">
                        </div>
                        <div class="stat-item">
                            <label style="color:#60a5fa">DEF</label>
                            <input type="number" id="editDef" value="50" min="0" max="999">
                        </div>
                        <div class="stat-item">
                            <label style="color:#34d399">MAC</label>
                            <input type="number" id="editMac" value="50" min="0" max="999">
                        </div>
                        <div class="stat-item">
                            <label style="color:#fbbf24">MIC</label>
                            <input type="number" id="editMic" value="50" min="0" max="999">
                        </div>
                        <div class="stat-item">
                            <label style="color:#a78bfa">LCK</label>
                            <input type="number" id="editLck" value="50" min="0" max="999">
                        </div>
                    </div>
                </div>
                <div class="full">
                    <label class="form-label" style="margin-bottom:6px;">소속 팩 (중복 선택 가능)</label>
                    <div class="pack-checkbox-list" id="packCheckboxList"></div>
                </div>
            </div>
        </div>
        <div class="edit-modal-footer">
            <button class="btn btn-secondary" onclick="closeEditModal()">취소</button>
            <button class="btn btn-primary" onclick="submitEdit()">💾 저장</button>
        </div>
    </div>
</div>

<!-- 확인 모달 -->
<div class="modal-overlay" id="confirmModal">
    <div class="confirm-modal">
        <div style="font-size:32px;margin-bottom:10px;" id="confirmIcon">⚠️</div>
        <p id="confirmMsg"></p>
        <div class="confirm-actions">
            <button class="btn btn-secondary" onclick="closeConfirm()">취소</button>
            <button class="btn btn-danger" id="confirmOkBtn">삭제</button>
        </div>
    </div>
</div>

<div class="toast" id="toast"></div>

<script id="playerDataScript" type="application/json">
${playerJsonData}
</script>
<script id="packDataScript" type="application/json">
${packJsonData}
</script>

<script>
var ALL_PLAYERS = [];
var ALL_PACKS   = [];
try {
    ALL_PLAYERS = JSON.parse(document.getElementById('playerDataScript').textContent);
    ALL_PACKS   = JSON.parse(document.getElementById('packDataScript').textContent);
} catch(e) { console.error(e); }

var RARITY_ORDER = {UR:1, SSR:2, SR:3, R:4, N:5};
var RACE_ICON    = {T:'🔵', P:'💜', Z:'🟢'};
var confirmCallback = null;

/* 팩 필터 셀렉트 채우기 */
(function() {
    var sel = document.getElementById('filterPack');
    ALL_PACKS.forEach(function(pk) {
        var o = document.createElement('option');
        o.value = pk.seq; o.textContent = '📦 ' + pk.name;
        sel.appendChild(o);
    });
})();

/* 팩 체크박스 목록 채우기 */
function buildPackCheckboxes(checkedPacks) {
    // checkedPacks: [{seq, prob}] 형태
    var wrap = document.getElementById('packCheckboxList');
    wrap.innerHTML = '';
    if (ALL_PACKS.length === 0) {
        wrap.innerHTML = '<span style="color:#4a5568;font-size:11px;">등록된 팩 없음</span>';
        return;
    }
    var checkedMap = {};
    (checkedPacks || []).forEach(function(cp) { checkedMap[cp.seq] = cp.prob; });

    ALL_PACKS.forEach(function(pk) {
        var isChecked = checkedMap.hasOwnProperty(pk.seq);
        var prob = isChecked ? checkedMap[pk.seq] : 0.1;

        var item = document.createElement('div');
        item.className = 'pack-checkbox-item' + (isChecked ? ' checked' : '');

        var cb = document.createElement('input');
        cb.type = 'checkbox';
        cb.value = pk.seq;
        cb.checked = isChecked;
        cb.addEventListener('change', function() {
            if (this.checked) item.classList.add('checked');
            else item.classList.remove('checked');
        });

        var lbl = document.createElement('label');
        lbl.className = 'pack-cb-label';
        lbl.textContent = '📦 ' + safeStr(pk.name);
        lbl.addEventListener('click', function() { cb.click(); });

        var probWrap = document.createElement('div');
        probWrap.className = 'prob-input-wrap';

        var probInput = document.createElement('input');
        probInput.type = 'number';
        probInput.className = 'prob-input';
        probInput.value = prob;
        probInput.min = '0.0001';
        probInput.max = '1';
        probInput.step = '0.0001';
        probInput.dataset.packSeq = pk.seq;

        var unit = document.createElement('span');
        unit.className = 'prob-unit';
        unit.textContent = '확률 (0~1)';

        probWrap.appendChild(probInput);
        probWrap.appendChild(unit);
        item.appendChild(cb);
        item.appendChild(lbl);
        item.appendChild(probWrap);
        wrap.appendChild(item);
    });
}

/* ============================================================
   테이블 렌더
   ============================================================ */
function renderTable() {
    var q      = document.getElementById('searchInput').value.trim().toLowerCase();
    var race   = document.getElementById('filterRace').value;
    var rarity = document.getElementById('filterRarity').value;
    var packF  = parseInt(document.getElementById('filterPack').value) || 0;
    var sortBy = document.getElementById('sortBy').value;

    var list = ALL_PLAYERS.filter(function(p) {
        var nameOk  = !q      || p.name.toLowerCase().indexOf(q) >= 0;
        var raceOk  = !race   || p.race === race;
        var rarOk   = !rarity || p.rarity === rarity;
        var packOk  = !packF  || p.packs.some(function(pk){ return pk.seq === packF; });
        return nameOk && raceOk && rarOk && packOk;
    });

    list.sort(function(a,b) {
        if (sortBy === 'name')  return a.name.localeCompare(b.name,'ko');
        if (sortBy === 'total') return total(b)-total(a);
        if (sortBy === 'atk')   return b.atk-a.atk;
        return (RARITY_ORDER[a.rarity]||9)-(RARITY_ORDER[b.rarity]||9);
    });

    document.getElementById('countLabel').textContent = list.length + '명';

    var html = list.map(function(p) {
        var t = total(p);
        var imgCell = p.imgUrl
            ? '<img class="player-img-thumb" src="'+safeStr(p.imgUrl)+'" onerror="this.outerHTML=\'<div class=no-img>👤</div>\'">'
            : '<div class="no-img">👤</div>';
        var packHtml = p.packs && p.packs.length > 0
            ? p.packs.map(function(pk){ return '<span class="pack-badge">' + safeStr(pk.name) + '</span>'; }).join('')
            : '<span class="no-pack">-</span>';
        return '<tr>'
            +'<td>'+imgCell+'</td>'
            +'<td style="font-weight:600;color:#e2e8f0">'+safeStr(p.name)+'</td>'
            +'<td>'+(RACE_ICON[p.race]||'?')+' '+p.race+'</td>'
            +'<td><span class="slot-player-rarity rarity-'+p.rarity+'">'+p.rarity+'</span></td>'
            +'<td style="color:#f87171">'+p.atk+'</td>'
            +'<td style="color:#60a5fa">'+p.def+'</td>'
            +'<td style="color:#34d399">'+p.mac+'</td>'
            +'<td style="color:#fbbf24">'+p.mic+'</td>'
            +'<td style="color:#a78bfa">'+p.lck+'</td>'
            +'<td style="color:#94a3b8;font-weight:700">'+t+'</td>'
            +'<td style="color:#94a3b8">'+p.cost+'</td>'
            +'<td><div class="pack-list">'+packHtml+'</div></td>'
            +'<td><div class="row-actions">'
            +'<button class="btn-edit" onclick="openEditModal('+p.seq+')">✏ 수정</button>'
            +'<button class="btn-del" onclick="confirmDelete('+p.seq+',\''+safeAttr(p.name)+'\')">🗑 삭제</button>'
            +'</div></td>'
            +'</tr>';
    }).join('');

    document.getElementById('playerTableBody').innerHTML = html
        || '<tr><td colspan="13" style="text-align:center;padding:30px;color:#4a5568">검색 결과가 없습니다</td></tr>';
}
function total(p){ return p.atk+p.def+p.mac+p.mic+p.lck; }

/* ============================================================
   편집 모달
   ============================================================ */
function openEditModal(seq) {
    var p = seq ? ALL_PLAYERS.filter(function(x){ return x.seq===seq; })[0] : null;
    document.getElementById('editModalTitle').textContent = p ? '선수 수정' : '선수 추가';
    document.getElementById('editSeq').value    = p ? p.seq   : '';
    document.getElementById('editName').value   = p ? p.name  : '';
    document.getElementById('editRace').value   = p ? p.race  : 'T';
    document.getElementById('editRarity').value = p ? p.rarity: 'R';
    document.getElementById('editCost').value   = p ? p.cost  : 0;
    document.getElementById('editImgUrl').value = p ? (p.imgUrl||'') : '';
    document.getElementById('editAtk').value    = p ? p.atk : 50;
    document.getElementById('editDef').value    = p ? p.def : 50;
    document.getElementById('editMac').value    = p ? p.mac : 50;
    document.getElementById('editMic').value    = p ? p.mic : 50;
    document.getElementById('editLck').value    = p ? p.lck : 50;

    var checkedPacks = p ? p.packs.map(function(pk){ return {seq:pk.seq, prob:pk.prob||0.1}; }) : [];
    buildPackCheckboxes(checkedPacks);

    document.getElementById('editModal').classList.add('visible');
    setTimeout(function(){ document.getElementById('editName').focus(); }, 100);
}
function closeEditModal() { document.getElementById('editModal').classList.remove('visible'); }

function getCheckedPacks() {
    var checked = document.querySelectorAll('#packCheckboxList input[type=checkbox]:checked');
    return Array.prototype.map.call(checked, function(cb) {
        var probInput = document.querySelector('.prob-input[data-pack-seq="' + cb.value + '"]');
        var prob = probInput ? parseFloat(probInput.value) : 0.1;
        if (isNaN(prob) || prob <= 0) prob = 0.1;
        if (prob > 1) prob = 1;
        return { seq: parseInt(cb.value), prob: prob };
    });
}

function submitEdit() {
    var name = document.getElementById('editName').value.trim();
    if (!name) { showToast('이름을 입력하세요','error'); return; }

    var seq = document.getElementById('editSeq').value;
    var payload = {
        playerName:  name,
        race:        document.getElementById('editRace').value,
        rarity:      document.getElementById('editRarity').value,
        statAttack:  parseInt(document.getElementById('editAtk').value)||0,
        statDefense: parseInt(document.getElementById('editDef').value)||0,
        statMacro:   parseInt(document.getElementById('editMac').value)||0,
        statMicro:   parseInt(document.getElementById('editMic').value)||0,
        statLuck:    parseInt(document.getElementById('editLck').value)||0,
        playerImgUrl: document.getElementById('editImgUrl').value.trim(),
        playerCost:  parseInt(document.getElementById('editCost').value)||0,
        packInfos:   getCheckedPacks()
    };

    var isEdit = !!seq;
    if (isEdit) payload.playerSeq = parseInt(seq);
    var url = isEdit ? '<c:url value="/admin/player/edit"/>' : '<c:url value="/admin/player/add"/>';

    fetchPost(url, payload, function(data) {
        if (data.success) {
            showToast(isEdit ? '수정됨 ✓' : '추가됨 ✓','success');
            closeEditModal();
            if (isEdit) {
                // 로컬 데이터 갱신
                var idx = ALL_PLAYERS.findIndex(function(p){ return p.seq===parseInt(seq); });
                if (idx >= 0) {
                    var packsData = payload.packInfos.map(function(pi){
                        var found = ALL_PACKS.filter(function(pk){ return pk.seq===pi.seq; })[0];
                        return found ? {seq:found.seq, name:found.name, prob:pi.prob} : null;
                    }).filter(Boolean);
                    ALL_PLAYERS[idx] = Object.assign(ALL_PLAYERS[idx], {
                        name:payload.playerName, race:payload.race, rarity:payload.rarity,
                        atk:payload.statAttack, def:payload.statDefense,
                        mac:payload.statMacro, mic:payload.statMicro, lck:payload.statLuck,
                        imgUrl:payload.playerImgUrl, cost:payload.playerCost,
                        packs:packsData
                    });
                }
                renderTable();
            } else {
                setTimeout(function(){ location.reload(); }, 600);
            }
        } else {
            showToast(data.message||'저장 실패','error');
        }
    });
}

/* ============================================================
   삭제
   ============================================================ */
function confirmDelete(seq, name) {
    showConfirm('🗑', '<strong>' + safeStr(name) + '</strong> 선수를 삭제합니다.',
        function() {
            fetchPost('<c:url value="/admin/player/delete"/>', {playerSeq:seq}, function(data) {
                if (data.success) {
                    ALL_PLAYERS = ALL_PLAYERS.filter(function(p){ return p.seq!==seq; });
                    renderTable();
                    showToast('삭제됨','success');
                } else {
                    showToast(data.message||'삭제 실패','error');
                }
            });
        }
    );
}

/* ============================================================
   공통
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
    var cb = confirmCallback; closeConfirm(); if(cb) cb();
});

var _tt;
function showToast(msg, type) {
    var t = document.getElementById('toast');
    t.textContent = msg; t.className = 'toast '+(type||'')+' show';
    clearTimeout(_tt); _tt = setTimeout(function(){ t.classList.remove('show'); }, 3000);
}
function fetchPost(url, body, cb) {
    fetch(url, {method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(body)})
        .then(function(r){ return r.json(); }).then(cb)
        .catch(function(e){ console.error(e); showToast('서버 오류','error'); });
}
function safeStr(s) {
    return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}
function safeAttr(s) {
    return String(s||'').replace(/\\/g,'\\\\').replace(/'/g,"\\'");
}

document.addEventListener('keydown', function(e){ if(e.key==='Escape'){ closeEditModal(); closeConfirm(); } });

renderTable();
</script>
</body>
</html>
