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
            margin: 100px auto;
            padding: 30px;
            width: 500px;
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
                            <c:when test="${build.race == 'ZERG'}">
                                <span class="race-badge race-zerg">저그</span>
                            </c:when>
                            <c:when test="${build.race == 'TERRAN'}">
                                <span class="race-badge race-terran">테란</span>
                            </c:when>
                            <c:when test="${build.race == 'PROTOSS'}">
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
let isEditMode = false;

function openCreateModal() {
    isEditMode = false;
    document.getElementById('modalTitle').textContent = '새 빌드 만들기';
    document.getElementById('buildId').value = '0';
    document.getElementById('buildName').value = '';
    document.getElementById('race').value = '';
    document.getElementById('vsRace').value = ''; // ★ 초기화 추가
    document.getElementById('buildModal').style.display = 'block';
}

// ★ 파라미터에 vsRace 추가
function editBuild(id, name, race, vsRace) {
    isEditMode = true;
    document.getElementById('modalTitle').textContent = '빌드 수정';
    document.getElementById('buildId').value = id;
    document.getElementById('buildName').value = name;
    document.getElementById('race').value = race;
    document.getElementById('vsRace').value = vsRace || ''; // ★ 기존 값 세팅
    document.getElementById('buildModal').style.display = 'block';
}

function closeModal() {
    document.getElementById('buildModal').style.display = 'none';
}

function saveBuild() {
    const buildId = parseInt(document.getElementById('buildId').value);
    const buildName = document.getElementById('buildName').value.trim();
    const race = document.getElementById('race').value;
    const vsRace = document.getElementById('vsRace').value; // ★ 상대 종족 값 가져오기
    
    if (!buildName || !race || !vsRace) {
        alert('모든 항목을 입력하세요!');
        return;
    }
    
    // ★ data 객체에 vsRace 추가
    const data = {
        buildId: buildId,
        buildName: buildName,
        race: race,
        vsRace: vsRace
    };

    const url = isEditMode ? 
        '<c:url value="/admin/build/update" />' :
        '<c:url value="/admin/build/create" />';

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
    .catch(err => {
        console.error(err);
        alert('오류 발생!');
    });
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