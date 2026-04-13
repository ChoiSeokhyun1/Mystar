<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>종족 상성 관리</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/adminStage.css' />">
    <style>
        .matchup-container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 20px;
            height: calc(100vh - 60px);
            overflow-y: auto;
        }
        .matchup-container::-webkit-scrollbar { width: 6px; }
        .matchup-container::-webkit-scrollbar-thumb { background: #555; border-radius: 3px; }
        .matchup-header { color: #00ff88; margin-bottom: 10px; }
        .matchup-subtitle { color: #888; font-size: 13px; margin-bottom: 28px; line-height: 1.6; }
        .matchup-subtitle b { color: #00ff88; }

        /* ── 입력 폼 ── */
        .form-panel {
            background: #1a1a1a;
            border: 2px solid #00ff88;
            border-radius: 8px;
            padding: 28px 30px;
            margin-bottom: 30px;
        }
        .form-panel h2 { color: #00ff88; font-size: 16px; margin-bottom: 20px; letter-spacing: 1px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr 1fr 1fr auto; gap: 14px; align-items: end; }
        .form-group label { display: block; color: #aaa; font-size: 12px; margin-bottom: 6px; letter-spacing: 0.5px; }
        .race-selector {
            display: flex; gap: 4px;
        }
        .race-btn {
            flex: 1;
            padding: 10px 4px;
            background: #2a2a2a;
            border: 1px solid #444;
            border-radius: 4px;
            color: #888;
            cursor: pointer;
            font-size: 13px;
            font-weight: bold;
            text-align: center;
            transition: all 0.15s;
            user-select: none;
        }
        .race-btn:hover { border-color: #666; color: #ccc; }
        .race-btn.T.sel { background: #1a3a5c; border-color: #38bdf8; color: #38bdf8; }
        .race-btn.P.sel { background: #2d1a5c; border-color: #a78bfa; color: #a78bfa; }
        .race-btn.Z.sel { background: #1a3a1a; border-color: #4ade80; color: #4ade80; }
        .combo-display {
            padding: 10px 12px;
            background: #2a2a2a;
            border: 1px solid #444;
            border-radius: 4px;
            color: #fff;
            font-size: 13px;
            margin-top: 6px;
            text-align: center;
            letter-spacing: 2px;
            min-height: 38px;
            display: flex; align-items: center; justify-content: center;
        }
        .multiplier-input {
            width: 100%;
            padding: 10px 12px;
            background: #2a2a2a;
            border: 1px solid #444;
            border-radius: 4px;
            color: #fff;
            font-size: 15px;
            font-family: 'Courier New', monospace;
        }
        .multiplier-input:focus { outline: none; border-color: #00ff88; }
        .btn-submit {
            background: #00ff88; color: #000;
            border: none; padding: 11px 28px;
            border-radius: 4px; cursor: pointer;
            font-size: 15px; font-weight: bold;
            white-space: nowrap; transition: all 0.15s;
        }
        .btn-submit:hover { background: #00dd77; }

        /* ── 목록 테이블 ── */
        .table-panel {
            background: #1a1a1a;
            border: 1px solid #333;
            border-radius: 8px;
            overflow: hidden;
        }
        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 20px;
            background: #222;
            border-bottom: 1px solid #333;
        }
        .table-header h2 { color: #00ff88; font-size: 15px; margin: 0; }
        .table-count { color: #888; font-size: 13px; }
        table { width: 100%; border-collapse: collapse; }
        th { padding: 12px 16px; background: #222; color: #888; font-size: 11px; text-align: left; letter-spacing: 1px; text-transform: uppercase; border-bottom: 1px solid #333; }
        td { padding: 12px 16px; border-bottom: 1px solid #222; color: #ddd; font-size: 13px; vertical-align: middle; }
        tr:hover td { background: rgba(255,255,255,0.02); }
        .combo-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            font-size: 13px;
            font-weight: bold;
            letter-spacing: 2px;
        }
        .combo-badge.my  { background: rgba(56,189,248,0.1); color: #38bdf8; border: 1px solid rgba(56,189,248,0.2); }
        .combo-badge.opp { background: rgba(244,63,94,0.1);  color: #f43f5e; border: 1px solid rgba(244,63,94,0.2); }
        .vs-arrow { color: #555; margin: 0 6px; }
        .mult-badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 12px;
            font-family: 'Courier New', monospace;
            font-size: 13px;
            font-weight: bold;
        }
        .mult-badge.good    { background: rgba(74,222,128,0.12); color: #4ade80; border: 1px solid rgba(74,222,128,0.25); }
        .mult-badge.bad     { background: rgba(248,113,113,0.12); color: #f87171; border: 1px solid rgba(248,113,113,0.25); }
        .mult-badge.neutral { background: rgba(148,163,184,0.08); color: #94a3b8; border: 1px solid rgba(148,163,184,0.15); }
        .btn-edit   { background: #2a4a6a; color: #38bdf8; border: 1px solid #38bdf8; padding: 5px 14px; border-radius: 4px; cursor: pointer; font-size: 12px; transition: all 0.15s; }
        .btn-edit:hover { background: #38bdf8; color: #000; }
        .btn-delete { background: #4a1a1a; color: #f43f5e; border: 1px solid #f43f5e; padding: 5px 14px; border-radius: 4px; cursor: pointer; font-size: 12px; transition: all 0.15s; }
        .btn-delete:hover { background: #f43f5e; color: #fff; }
        .empty-row { text-align: center; color: #555; padding: 40px 0 !important; font-size: 14px; }

        /* ── 필터 ── */
        .filter-bar {
            display: flex; gap: 10px; align-items: center;
            padding: 12px 20px;
            background: #1e1e1e;
            border-bottom: 1px solid #2a2a2a;
        }
        .filter-bar label { color: #888; font-size: 12px; }
        .filter-select {
            padding: 5px 10px;
            background: #2a2a2a;
            border: 1px solid #444;
            border-radius: 4px;
            color: #fff;
            font-size: 12px;
        }
        .btn-filter-clear { background: none; border: 1px solid #444; color: #888; padding: 5px 12px; border-radius: 4px; cursor: pointer; font-size: 12px; }
        .btn-filter-clear:hover { border-color: #666; color: #ccc; }

        /* ── 편집 모달 ── */
        .modal-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.75); z-index: 1000; align-items: center; justify-content: center; }
        .modal-overlay.open { display: flex; }
        .modal-box { background: #1a1a1a; border: 2px solid #00ff88; border-radius: 10px; padding: 30px; width: 500px; max-width: 95vw; }
        .modal-box h3 { color: #00ff88; margin-bottom: 20px; }
        .modal-field { margin-bottom: 16px; }
        .modal-field label { display: block; color: #aaa; font-size: 12px; margin-bottom: 6px; }
        .modal-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 20px; }
        .btn-cancel { background: #333; color: #aaa; border: 1px solid #444; padding: 10px 20px; border-radius: 4px; cursor: pointer; }
        .btn-save   { background: #00ff88; color: #000; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-weight: bold; }

        /* ── 알림 토스트 ── */
        .toast {
            position: fixed; bottom: 30px; right: 30px; z-index: 9999;
            padding: 12px 22px; border-radius: 6px; font-size: 14px; font-weight: bold;
            opacity: 0; transform: translateY(10px);
            transition: all 0.25s ease;
            pointer-events: none;
        }
        .toast.show { opacity: 1; transform: translateY(0); }
        .toast.success { background: #00ff88; color: #000; }
        .toast.error   { background: #f43f5e; color: #fff; }
    </style>
</head>
<body>
<c:set var="adminCurrentPage" value="matchup" />
<%@ include file="/WEB-INF/views/layout/adminHeader.jsp" %>

<div class="matchup-container">
    <h1 class="matchup-header">⚔️ 종족 팀 상성 관리</h1>
    <p class="matchup-subtitle">
        3:3 팀 구성의 종족 조합(예: <b>TTZ</b>)에 따른 상성 보너스 배율을 설정합니다.<br>
        배율은 <b>블루팀(내 팀)</b> 전체 스탯(HP·ATK·DEF·SPD)에 곱해집니다.
        <b>1.2</b> = +20% 유리 / <b>0.85</b> = -15% 불리
    </p>

    <!-- ── 입력 폼 ── -->
    <div class="form-panel">
        <h2>➕ 새 상성 추가 / 수정 (UPSERT)</h2>
        <div class="form-row">
            <div class="form-group">
                <label>내 팀 조합 (3명 종족 선택)</label>
                <div class="race-selector" id="myRaceSelector">
                    <div class="race-btn T" data-team="my" data-race="T" onclick="toggleRace(this)">T<br><small>테란</small></div>
                    <div class="race-btn P" data-team="my" data-race="P" onclick="toggleRace(this)">P<br><small>프토</small></div>
                    <div class="race-btn Z" data-team="my" data-race="Z" onclick="toggleRace(this)">Z<br><small>저그</small></div>
                </div>
                <div class="combo-display" id="myComboDisplay">---</div>
                <input type="hidden" id="myTeamCombo" value="">
            </div>
            <div class="form-group">
                <label>상대 팀 조합 (3명 종족 선택)</label>
                <div class="race-selector" id="oppRaceSelector">
                    <div class="race-btn T" data-team="opp" data-race="T" onclick="toggleRace(this)">T<br><small>테란</small></div>
                    <div class="race-btn P" data-team="opp" data-race="P" onclick="toggleRace(this)">P<br><small>프토</small></div>
                    <div class="race-btn Z" data-team="opp" data-race="Z" onclick="toggleRace(this)">Z<br><small>저그</small></div>
                </div>
                <div class="combo-display" id="oppComboDisplay">---</div>
                <input type="hidden" id="oppTeamCombo" value="">
            </div>
            <div class="form-group">
                <label>보너스 배율 (예: 1.20)</label>
                <input type="number" id="bonusMultiplier" class="multiplier-input"
                       step="0.01" min="0.50" max="2.00" value="1.00" placeholder="1.00">
            </div>
            <div class="form-group">
                <label>설명 (선택)</label>
                <input type="text" id="bonusDesc" class="multiplier-input"
                       placeholder="예) 테란 vs 저그 유리" style="font-size:13px;">
            </div>
            <div class="form-group">
                <label style="opacity:0">-</label>
                <button class="btn-submit" onclick="submitMatchup()">저장</button>
            </div>
        </div>
        <div id="formError" style="color:#f43f5e;font-size:13px;margin-top:12px;display:none;"></div>
    </div>

    <!-- ── 목록 테이블 ── -->
    <div class="table-panel">
        <div class="table-header">
            <h2>📋 등록된 상성 목록</h2>
            <span class="table-count" id="tableCount">0개</span>
        </div>
        <div class="filter-bar">
            <label>내 팀 필터</label>
            <select class="filter-select" id="filterMy" onchange="filterTable()">
                <option value="">전체</option>
                <option value="T">T 포함</option>
                <option value="P">P 포함</option>
                <option value="Z">Z 포함</option>
            </select>
            <label>결과 필터</label>
            <select class="filter-select" id="filterResult" onchange="filterTable()">
                <option value="">전체</option>
                <option value="good">유리 (>1.0)</option>
                <option value="bad">불리 (<1.0)</option>
                <option value="neutral">보통 (=1.0)</option>
            </select>
            <button class="btn-filter-clear" onclick="clearFilter()">초기화</button>
        </div>
        <table id="matchupTable">
            <thead>
                <tr>
                    <th>#</th>
                    <th>내 팀 조합</th>
                    <th>상대 팀 조합</th>
                    <th>배율</th>
                    <th>결과</th>
                    <th>설명</th>
                    <th>액션</th>
                </tr>
            </thead>
            <tbody id="tableBody">
                <tr><td colspan="7" class="empty-row">로딩 중...</td></tr>
            </tbody>
        </table>
    </div>
</div>

<!-- ── 편집 모달 ── -->
<div class="modal-overlay" id="editModal">
    <div class="modal-box">
        <h3>✏️ 상성 수정</h3>
        <input type="hidden" id="editMatchupId">
        <div class="modal-field">
            <label>내 팀 조합</label>
            <div class="combo-display" id="editMyComboDisp" style="justify-content:flex-start; font-size:16px;"></div>
        </div>
        <div class="modal-field">
            <label>상대 팀 조합</label>
            <div class="combo-display" id="editOppComboDisp" style="justify-content:flex-start; font-size:16px;"></div>
        </div>
        <div class="modal-field">
            <label>보너스 배율</label>
            <input type="number" id="editMultiplier" class="multiplier-input"
                   step="0.01" min="0.50" max="2.00">
        </div>
        <div class="modal-field">
            <label>설명</label>
            <input type="text" id="editDesc" class="multiplier-input" style="font-size:13px;">
        </div>
        <div class="modal-actions">
            <button class="btn-cancel" onclick="closeModal()">취소</button>
            <button class="btn-save" onclick="saveEdit()">저장</button>
        </div>
    </div>
</div>

<div class="toast" id="toast"></div>

<script>
// ── 종족 버튼 선택 상태 ──
const mySelections  = [];
const oppSelections = [];

function toggleRace(btn) {
    const team = btn.dataset.team;
    const race = btn.dataset.race;
    const arr  = team === 'my' ? mySelections : oppSelections;

    const idx = arr.indexOf(race);
    if (idx !== -1) {
        arr.splice(idx, 1);
        btn.classList.remove('sel');
    } else {
        if (arr.length >= 3) {
            showToast('종족은 3개까지만 선택할 수 있습니다.', 'error');
            return;
        }
        arr.push(race);
        btn.classList.add('sel');
    }
    updateComboDisplay(team);
}

function updateComboDisplay(team) {
    const arr     = team === 'my' ? mySelections : oppSelections;
    const dispEl  = document.getElementById(team === 'my' ? 'myComboDisplay'  : 'oppComboDisplay');
    const inputEl = document.getElementById(team === 'my' ? 'myTeamCombo'     : 'oppTeamCombo');

    if (arr.length < 3) {
        dispEl.textContent  = arr.length === 0 ? '---' : arr.join('') + '...' + (3 - arr.length) + '개 더';
        dispEl.style.color  = '#555';
        inputEl.value       = '';
        return;
    }
    const sorted = [...arr].sort().join('');
    dispEl.textContent  = sorted + ' (' + formatCombo(sorted) + ')';
    dispEl.style.color  = team === 'my' ? '#38bdf8' : '#f43f5e';
    inputEl.value       = sorted;
}

function formatCombo(c) {
    const m = { T: '테란', P: '프토', Z: '저그' };
    return c.split('').map(ch => m[ch] || ch).join('+');
}

// ── UPSERT 제출 ──
function submitMatchup() {
    const my   = document.getElementById('myTeamCombo').value;
    const opp  = document.getElementById('oppTeamCombo').value;
    const mult = parseFloat(document.getElementById('bonusMultiplier').value);
    const desc = document.getElementById('bonusDesc').value.trim();
    const errEl = document.getElementById('formError');

    if (!my  || my.length  !== 3) { showFormError('내 팀 종족을 3개 선택하세요.'); return; }
    if (!opp || opp.length !== 3) { showFormError('상대 팀 종족을 3개 선택하세요.'); return; }
    if (isNaN(mult) || mult < 0.5 || mult > 2.0) { showFormError('배율은 0.50 ~ 2.00 사이로 입력하세요.'); return; }
    errEl.style.display = 'none';

    fetch('<c:url value="/admin/matchup/save" />', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ myTeamCombo: my, oppTeamCombo: opp, bonusMultiplier: mult, description: desc })
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            showToast('저장되었습니다!', 'success');
            resetForm();
            loadTable();
        } else {
            showFormError(data.message || '저장 실패');
        }
    })
    .catch(() => showFormError('서버 통신 오류'));
}

function showFormError(msg) {
    const el = document.getElementById('formError');
    el.textContent = '⚠ ' + msg;
    el.style.display = 'block';
}

function resetForm() {
    mySelections.length  = 0;
    oppSelections.length = 0;
    document.querySelectorAll('.race-btn').forEach(b => b.classList.remove('sel'));
    document.getElementById('myComboDisplay').textContent  = '---';
    document.getElementById('oppComboDisplay').textContent = '---';
    document.getElementById('myTeamCombo').value     = '';
    document.getElementById('oppTeamCombo').value    = '';
    document.getElementById('bonusMultiplier').value = '1.00';
    document.getElementById('bonusDesc').value       = '';
    document.getElementById('formError').style.display = 'none';
}

// ── 테이블 로드 ──
let allRows = [];

function loadTable() {
    fetch('<c:url value="/admin/matchup/list" />')
        .then(r => r.json())
        .then(data => {
            allRows = data.list || [];
            document.getElementById('tableCount').textContent = allRows.length + '개';
            renderTable(allRows);
        })
        .catch(() => {
            document.getElementById('tableBody').innerHTML =
                '<tr><td colspan="7" class="empty-row">로드 실패</td></tr>';
        });
}

function renderTable(rows) {
    const tbody = document.getElementById('tableBody');
    if (rows.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="empty-row">등록된 상성이 없습니다.</td></tr>';
        return;
    }

    tbody.innerHTML = rows.map((r, i) => {
        const mult     = parseFloat(r.bonusMultiplier);
        const multCls  = mult > 1.0 ? 'good' : (mult < 1.0 ? 'bad' : 'neutral');
        const resultLbl = mult > 1.0
            ? '유리 (+' + Math.round((mult - 1) * 100) + '%)'
            : (mult < 1.0 ? '불리 (-' + Math.round((1 - mult) * 100) + '%)' : '보통');

        return '<tr>' +
            '<td style="color:#555">' + (i + 1) + '</td>' +
            '<td><span class="combo-badge my">' + r.myTeamCombo + '</span></td>' +
            '<td><span class="combo-badge opp">' + r.oppTeamCombo + '</span></td>' +
            '<td><span class="combo-badge" style="font-size:15px;color:#fff;background:none;border:none;">' +
                mult.toFixed(2) + '</span></td>' +
            '<td><span class="mult-badge ' + multCls + '">' + resultLbl + '</span></td>' +
            '<td style="color:#888;max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">' +
                escHtml(r.description || '') + '</td>' +
            '<td style="white-space:nowrap;">' +
                '<button class="btn-edit"   onclick="openEdit(' + JSON.stringify(r) + ')">수정</button> ' +
                '<button class="btn-delete" onclick="deleteMatchup(' + r.matchupId + ')">삭제</button>' +
            '</td>' +
        '</tr>';
    }).join('');
}

function escHtml(s) {
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

// ── 필터 ──
function filterTable() {
    const myF  = document.getElementById('filterMy').value;
    const resF = document.getElementById('filterResult').value;

    const filtered = allRows.filter(r => {
        if (myF && !r.myTeamCombo.includes(myF)) return false;
        const m = parseFloat(r.bonusMultiplier);
        if (resF === 'good'    && m <= 1.0) return false;
        if (resF === 'bad'     && m >= 1.0) return false;
        if (resF === 'neutral' && m !== 1.0) return false;
        return true;
    });

    renderTable(filtered);
    document.getElementById('tableCount').textContent = filtered.length + '개 (전체 ' + allRows.length + '개)';
}

function clearFilter() {
    document.getElementById('filterMy').value     = '';
    document.getElementById('filterResult').value = '';
    renderTable(allRows);
    document.getElementById('tableCount').textContent = allRows.length + '개';
}

// ── 편집 모달 ──
let editingId = null;

function openEdit(row) {
    editingId = row.matchupId;
    document.getElementById('editMatchupId').value   = row.matchupId;
    document.getElementById('editMyComboDisp').textContent  =
        row.myTeamCombo + ' (' + formatCombo(row.myTeamCombo) + ')';
    document.getElementById('editOppComboDisp').textContent =
        row.oppTeamCombo + ' (' + formatCombo(row.oppTeamCombo) + ')';
    document.getElementById('editMultiplier').value = parseFloat(row.bonusMultiplier).toFixed(2);
    document.getElementById('editDesc').value       = row.description || '';
    document.getElementById('editModal').classList.add('open');
}

function closeModal() {
    document.getElementById('editModal').classList.remove('open');
}

function saveEdit() {
    const id   = parseInt(document.getElementById('editMatchupId').value);
    const mult = parseFloat(document.getElementById('editMultiplier').value);
    const desc = document.getElementById('editDesc').value.trim();

    if (isNaN(mult) || mult < 0.5 || mult > 2.0) {
        showToast('배율은 0.50 ~ 2.00 사이로 입력하세요.', 'error');
        return;
    }

    fetch('<c:url value="/admin/matchup/update" />', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ matchupId: id, bonusMultiplier: mult, description: desc })
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            showToast('수정되었습니다!', 'success');
            closeModal();
            loadTable();
        } else {
            showToast(data.message || '수정 실패', 'error');
        }
    })
    .catch(() => showToast('서버 통신 오류', 'error'));
}

// ── 삭제 ──
function deleteMatchup(id) {
    if (!confirm('이 상성 설정을 삭제하시겠습니까?')) return;
    fetch('<c:url value="/admin/matchup/delete/" />' + id, { method: 'DELETE' })
        .then(r => r.json())
        .then(data => {
            if (data.success) { showToast('삭제되었습니다.', 'success'); loadTable(); }
            else showToast(data.message || '삭제 실패', 'error');
        })
        .catch(() => showToast('서버 통신 오류', 'error'));
}

// ── 토스트 ──
function showToast(msg, type) {
    const el = document.getElementById('toast');
    el.textContent = msg;
    el.className = 'toast ' + type + ' show';
    setTimeout(() => el.classList.remove('show'), 2500);
}

// ── 모달 외부 클릭 닫기 ──
document.getElementById('editModal').addEventListener('click', function(e) {
    if (e.target === this) closeModal();
});

// ── 초기 로드 ──
loadTable();
</script>
</body>
</html>
