<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>빌드 관리</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/adminStage.css' />">
    <style>
        .build-container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 20px;
        }
        .build-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        .build-table {
            width: 100%;
            border-collapse: collapse;
            background: #1a1a1a;
            border-radius: 8px;
            overflow: hidden;
        }
        .build-table th {
            background: #2a2a2a;
            color: #00ff88;
            padding: 15px;
            text-align: left;
            font-weight: bold;
        }
        .build-table td {
            padding: 12px 15px;
            border-bottom: 1px solid #333;
            color: #fff;
        }
        .build-table tr:hover {
            background: #252525;
        }
        .race-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
        }
        .race-zerg { background: #9b59b6; color: #fff; }
        .race-terran { background: #3498db; color: #fff; }
        .race-protoss { background: #f1c40f; color: #000; }
        .race-all { background: #95a5a6; color: #fff; } /* 전체 종족용 배지 */
        
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.2s;
        }
        .btn-primary {
            background: #00ff88;
            color: #000;
        }
        .btn-primary:hover {
            background: #00dd77;
        }
        .btn-danger {
            background: #e74c3c;
            color: #fff;
        }
        .btn-danger:hover {
            background: #c0392b;
        }
        .btn-edit {
            background: #3498db;
            color: #fff;
            margin-right: 5px;
        }
        .btn-edit:hover {
            background: #2980b9;
        }
        
        /* 모달 */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.8);
            z-index: 1000;
        }
        .modal-content {
            position: relative;
            background: #1a1a1a;
            margin: 60px auto;
            padding: 30px;
            width: 640px;
            border-radius: 8px;
            border: 2px solid #00ff88;
        }
        .modal-header {
            font-size: 24px;
            color: #00ff88;
            margin-bottom: 20px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            color: #00ff88;
            margin-bottom: 8px;
            font-weight: bold;
        }
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 10px;
            background: #2a2a2a;
            border: 1px solid #444;
            border-radius: 4px;
            color: #fff;
            font-size: 14px;
        }
        .form-actions {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
            margin-top: 30px;
        }

        /* 능력치 가산점 */
        .stat-bonus-section { margin-bottom: 20px; }
        .stat-bonus-section > label { display: block; color: #00ff88; margin-bottom: 10px; font-weight: bold; }
        .stat-bonus-grid { display: flex; flex-direction: column; gap: 8px; }
        .stat-bonus-row {
            display: flex; align-items: center; gap: 12px;
            padding: 8px 12px; background: #222; border-radius: 6px;
            border: 1px solid #333; transition: border-color 0.2s;
        }
        .stat-bonus-row.active { border-color: #00ff88; }
        .stat-bonus-row input[type="checkbox"] {
            width: 16px; height: 16px; accent-color: #00ff88; cursor: pointer; flex-shrink: 0;
        }
        .stat-name-label { flex: 1; color: #ccc; font-size: 14px; }
        .stat-bonus-row.active .stat-name-label { color: #fff; font-weight: bold; }
        .stat-mult-wrap input[type="number"] {
            width: 70px; padding: 4px 8px; background: #2a2a2a;
            border: 1px solid #555; border-radius: 4px; color: #fff; font-size: 13px; text-align: center;
        }
        .stat-mult-wrap input[type="number"]:disabled { opacity: 0.3; }
        .stat-mult-wrap .mult-hint { font-size: 11px; color: #888; }

        /* 능력치 버프 배지 */
        .stat-badges { display: flex; flex-wrap: wrap; gap: 4px; }
        .stat-badge {
            display: inline-flex; align-items: center; gap: 3px;
            padding: 2px 8px; border-radius: 10px; font-size: 11px; font-weight: bold;
            background: #1a3a2a; border: 1px solid #00ff88; color: #00ff88;
        }
        .stat-attack  { background:#2a1a1a; border-color:#ff6b6b; color:#ff6b6b; }
        .stat-defense { background:#1a2a3a; border-color:#4fc3f7; color:#4fc3f7; }
        .stat-macro   { background:#2a2a1a; border-color:#ffd54f; color:#ffd54f; }
        .stat-micro   { background:#2a1a2a; border-color:#ce93d8; color:#ce93d8; }
        .stat-luck    { background:#1a3a2a; border-color:#69f0ae; color:#69f0ae; }
        .stat-badge .mult { color: #ffdd55; font-size: 10px; }
        .no-bonus { color: #555; font-size: 12px; }
    </style>
</head>
<body>
<c:set var="adminCurrentPage" value="build" />
<%@ include file="/WEB-INF/views/layout/adminHeader.jsp" %>

<div class="build-container">
    <div class="build-header">
        <h1 style="color:#00ff88;">빌드 관리</h1>
        <button class="btn btn-primary" onclick="openCreateModal()">
            ➕ 새 빌드 만들기
        </button>
    </div>

    <table class="build-table">
        <thead>
            <tr>
                <th>ID</th>
                <th>빌드 이름</th>
                <th>내 종족</th>
                <th>상대 종족 (VS)</th> <th>승 / 패</th>
                <th>승률</th>
                <th>생성일</th>
                <th>능력치 버프</th>
                <th>관리</th>
            </tr>
        </thead>
        <tbody id="buildTableBody">
            <c:forEach items="${builds}" var="build">
                <tr>
                    <td>${build.buildId}</td>
                    <td><strong>${build.buildName}</strong></td>
                    
                    <td>
                        <c:choose>
                            <c:when test="${build.race == 'Z'}">
                                <span class="race-badge race-zerg">저그</span>
                            </c:when>
                            <c:when test="${build.race == 'T'}">
                                <span class="race-badge race-terran">테란</span>
                            </c:when>
                            <c:when test="${build.race == 'P'}">
                                <span class="race-badge race-protoss">프로토스</span>
                            </c:when>
                        </c:choose>
                    </td>

                    <td>
                        <c:choose>
                            <c:when test="${build.vsRace == 'Z'}">
                                <span class="race-badge race-zerg">VS 저그</span>
                            </c:when>
                            <c:when test="${build.vsRace == 'T'}">
                                <span class="race-badge race-terran">VS 테란</span>
                            </c:when>
                            <c:when test="${build.vsRace == 'P'}">
                                <span class="race-badge race-protoss">VS 토스</span>
                            </c:when>
                            <c:otherwise>
                                <span class="race-badge">-</span>
                            </c:otherwise>
                        </c:choose>
                    </td>

                    <td>${build.winCount} / ${build.loseCount}</td>
                    <td>${String.format("%.1f", build.winRate)}%</td>
                    <td>${build.createdAt}</td>
                    <td>
                        <div class="stat-badges">
                            <c:choose>
                                <c:when test="${empty build.statBonuses}">
                                    <span class="no-bonus">-</span>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach items="${build.statBonuses}" var="sb">
                                        <span class="stat-badge stat-${sb.statName}">
                                            <c:choose>
                                                <c:when test="${sb.statName == 'attack'}">공격</c:when>
                                                <c:when test="${sb.statName == 'defense'}">방어</c:when>
                                                <c:when test="${sb.statName == 'macro'}">운영</c:when>
                                                <c:when test="${sb.statName == 'micro'}">컨트롤</c:when>
                                                <c:when test="${sb.statName == 'luck'}">행운</c:when>
                                                <c:otherwise>${sb.statName}</c:otherwise>
                                            </c:choose>
                                            <span class="mult">x${sb.bonusMult}</span>
                                        </span>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </td>
                    <td>
                        <button class="btn btn-edit" onclick="editBuild(${build.buildId}, '${build.buildName}', '${build.race}', '${build.vsRace}')">
                            수정
                        </button>
                        <button class="btn btn-danger" onclick="deleteBuild(${build.buildId}, '${build.buildName}')">
                            삭제
                        </button>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>

<div id="buildModal" class="modal">
    <div class="modal-content">
        <div class="modal-header" id="modalTitle">새 빌드 만들기</div>
        <div>
            <input type="hidden" id="buildId" value="0">
            
            <div class="form-group">
                <label>빌드 이름</label>
                <input type="text" id="buildName" placeholder="예: 4드론, 8배럭" required>
            </div>
            
            <div style="display: flex; gap: 15px;">
                <div class="form-group" style="flex: 1;">
                    <label>내 종족</label>
                    <select id="race" required>
                        <option value="">선택하세요</option>
                        <option value="Z">저그</option>
                        <option value="T">테란</option>
                        <option value="P">프로토스</option>
                    </select>
                </div>
                
                <div class="form-group" style="flex: 1;">
                    <label>상대 가능한 종족 (VS)</label>
                    <select id="vsRace" required>
                        <option value="">선택하세요</option>
                        <option value="Z">저그전 전용</option>
                        <option value="T">테란전 전용</option>
                        <option value="P">토스전 전용</option>
                    </select>
                </div>
            </div>


            <!-- 능력치 가산점 섹션 -->
            <div class="stat-bonus-section">
                <label>능력치 버프 (선택사항)</label>
                <div class="stat-bonus-grid">
                    <div class="stat-bonus-row" id="row-attack">
                        <input type="checkbox" id="chk-attack" onchange="toggleStat('attack')">
                        <span class="stat-name-label">공격력 (attack)</span>
                        <div class="stat-mult-wrap">
                            <input type="number" id="mult-attack" value="1.2" min="1.0" max="3.0" step="0.1" disabled>
                            <span class="mult-hint">배율</span>
                        </div>
                    </div>
                    <div class="stat-bonus-row" id="row-defense">
                        <input type="checkbox" id="chk-defense" onchange="toggleStat('defense')">
                        <span class="stat-name-label">방어력 (defense)</span>
                        <div class="stat-mult-wrap">
                            <input type="number" id="mult-defense" value="1.2" min="1.0" max="3.0" step="0.1" disabled>
                            <span class="mult-hint">배율</span>
                        </div>
                    </div>
                    <div class="stat-bonus-row" id="row-macro">
                        <input type="checkbox" id="chk-macro" onchange="toggleStat('macro')">
                        <span class="stat-name-label">운영력 (macro)</span>
                        <div class="stat-mult-wrap">
                            <input type="number" id="mult-macro" value="1.2" min="1.0" max="3.0" step="0.1" disabled>
                            <span class="mult-hint">배율</span>
                        </div>
                    </div>
                    <div class="stat-bonus-row" id="row-micro">
                        <input type="checkbox" id="chk-micro" onchange="toggleStat('micro')">
                        <span class="stat-name-label">컨트롤 (micro)</span>
                        <div class="stat-mult-wrap">
                            <input type="number" id="mult-micro" value="1.2" min="1.0" max="3.0" step="0.1" disabled>
                            <span class="mult-hint">배율</span>
                        </div>
                    </div>
                    <div class="stat-bonus-row" id="row-luck">
                        <input type="checkbox" id="chk-luck" onchange="toggleStat('luck')">
                        <span class="stat-name-label">행운 (luck)</span>
                        <div class="stat-mult-wrap">
                            <input type="number" id="mult-luck" value="1.2" min="1.0" max="3.0" step="0.1" disabled>
                            <span class="mult-hint">배율</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="form-actions">
                <button type="button" class="btn" onclick="closeModal()" style="background:#666;">
                    취소
                </button>
                <button type="button" class="btn btn-primary" onclick="saveBuild()">
                    저장
                </button>
            </div>
        </div>
    </div>
</div>

<script>
const STAT_LIST = ['attack','defense','macro','micro','luck'];

function toggleStat(statName) {
    const chk = document.getElementById('chk-' + statName);
    const inp = document.getElementById('mult-' + statName);
    const row = document.getElementById('row-' + statName);
    inp.disabled = !chk.checked;
    row.classList.toggle('active', chk.checked);
}

function resetStatBonuses() {
    STAT_LIST.forEach(s => {
        document.getElementById('chk-' + s).checked = false;
        document.getElementById('mult-' + s).value = '1.2';
        document.getElementById('mult-' + s).disabled = true;
        document.getElementById('row-' + s).classList.remove('active');
    });
}

function applyStatBonuses(bonuses) {
    resetStatBonuses();
    if (!bonuses) return;
    bonuses.forEach(b => {
        const chk = document.getElementById('chk-' + b.statName);
        const inp = document.getElementById('mult-' + b.statName);
        const row = document.getElementById('row-' + b.statName);
        if (chk) {
            chk.checked = true;
            inp.value = b.bonusMult;
            inp.disabled = false;
            row.classList.add('active');
        }
    });
}

function collectStatBonuses() {
    const result = [];
    STAT_LIST.forEach(s => {
        if (document.getElementById('chk-' + s).checked) {
            result.push({
                statName: s,
                bonusMult: parseFloat(document.getElementById('mult-' + s).value) || 1.2
            });
        }
    });
    return result;
}

let isEditMode = false;

function openCreateModal() {
    isEditMode = false;
    document.getElementById('modalTitle').textContent = '새 빌드 만들기';
    document.getElementById('buildId').value = '0';
    document.getElementById('buildName').value = '';
    document.getElementById('race').value = '';
    document.getElementById('vsRace').value = '';
    resetStatBonuses();
    document.getElementById('buildModal').style.display = 'block';
}

// ★ 파라미터에 vsRace 추가
function editBuild(id, name, race, vsRace) {
    isEditMode = true;
    document.getElementById('modalTitle').textContent = '빌드 수정';
    document.getElementById('buildId').value = id;
    document.getElementById('buildName').value = name;
    document.getElementById('race').value = race;
    document.getElementById('vsRace').value = vsRace || '';
    resetStatBonuses();
    document.getElementById('buildModal').style.display = 'block';

    // 기존 statBonuses 서버에서 불러오기
    fetch('<c:url value="/admin/builds/" />' + id)
        .then(r => r.json())
        .then(res => {
            if (res.success && res.build && res.build.statBonuses) {
                applyStatBonuses(res.build.statBonuses);
            }
        })
        .catch(err => console.error('stat bonus 로드 실패:', err));
}

function closeModal() {
    document.getElementById('buildModal').style.display = 'none';
}

function saveBuild() {
    const buildId   = parseInt(document.getElementById('buildId').value);
    const buildName = document.getElementById('buildName').value.trim();
    const race      = document.getElementById('race').value;
    const vsRace    = document.getElementById('vsRace').value;

    if (!buildName || !race || !vsRace) {
        alert('모든 항목을 입력하세요!');
        return;
    }

    const data = {
        buildId,
        buildName,
        race,
        vsRace,
        statBonuses: collectStatBonuses()
    };

    const url = isEditMode
        ? '<c:url value="/admin/build/update" />'
        : '<c:url value="/admin/build/create" />';

    fetch(url, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(data)
    })
    .then(res => res.json())
    .then(result => {
        if (result.success) {
            alert(isEditMode ? '수정되었습니다!' : '생성되었습니다!');
            location.reload();
        } else {
            alert('실패: ' + result.message);
        }
    })
    .catch(err => { console.error(err); alert('오류 발생!'); });
}

function deleteBuild(id, name) {
    if (!confirm(name + ' 빌드를 삭제하시겠습니까?')) return;

    fetch('<c:url value="/admin/build/delete" />', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'buildId=' + id
    })
    .then(res => res.json())
    .then(result => {
        if (result.success) {
            alert('삭제되었습니다!');
            location.reload();
        } else {
            alert('실패: ' + result.message);
        }
    })
    .catch(err => {
        console.error(err);
        alert('오류 발생!');
    });
}

// 모달 외부 클릭 시 닫기
window.onclick = function(event) {
    const modal = document.getElementById('buildModal');
    if (event.target == modal) {
        closeModal();
    }
}
</script>

</body>
</html>