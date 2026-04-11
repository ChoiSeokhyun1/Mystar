<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>대본 관리</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/adminStage.css' />">
    <style>
        .script-container {
            max-width: 1400px;
            margin: 40px auto;
            padding: 20px;
            height: calc(100vh - 60px);
            overflow-y: auto;
        }
        .script-container::-webkit-scrollbar { width: 6px; }
        .script-container::-webkit-scrollbar-thumb { background: #555; border-radius: 3px; }
        .script-container::-webkit-scrollbar-track { background: #1a1a1a; }
        .script-header {
            color: #00ff88;
            margin-bottom: 30px;
        }
        .selector-panel {
            background: #1a1a1a;
            padding: 30px;
            border-radius: 8px;
            margin-bottom: 30px;
            border: 2px solid #00ff88;
        }
        .selector-row {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }
        .selector-group label {
            display: block;
            color: #00ff88;
            margin-bottom: 10px;
            font-weight: bold;
        }
        .selector-group select {
            width: 100%;
            padding: 12px;
            background: #2a2a2a;
            border: 1px solid #444;
            border-radius: 4px;
            color: #fff;
            font-size: 14px;
        }
        .script-editor {
            background: #1a1a1a;
            padding: 30px;
            border-radius: 8px;
            border: 2px solid #00ff88;
        }
        .main-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
        .main-tab-btn {
            padding: 12px 24px;
            background: #2a2a2a;
            border: 2px solid #444;
            border-radius: 4px 4px 0 0;
            color: #fff;
            cursor: pointer;
            transition: all 0.2s;
            font-weight: bold;
        }
        .main-tab-btn.active {
            background: #00ff88;
            color: #000;
            border-color: #00ff88;
        }
        .main-tab-content {
            display: none;
        }
        .main-tab-content.active {
            display: block;
        }
        .sub-tabs {
            display: flex;
            gap: 5px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        .sub-tab-btn {
            padding: 10px 20px;
            background: #2a2a2a;
            border: 1px solid #444;
            border-radius: 4px;
            color: #fff;
            cursor: pointer;
            transition: all 0.2s;
        }
        .sub-tab-btn.active {
            background: #3498db;
            color: #fff;
            border-color: #3498db;
        }
        .sub-tab-content {
            display: none;
        }
        .sub-tab-content.active {
            display: block;
        }
        .script-lines {
            background: #2a2a2a;
            padding: 20px;
            border-radius: 4px;
            margin-bottom: 15px;
            max-height: 400px;
            overflow-y: auto;
        }
        .script-lines::-webkit-scrollbar { width: 6px; }
        .script-lines::-webkit-scrollbar-thumb { background: #555; border-radius: 3px; }
        .script-lines::-webkit-scrollbar-track { background: #1a1a1a; }
        .script-line {
            display: grid;
            grid-template-columns: 1fr auto auto;
            gap: 10px;
            margin-bottom: 10px;
            align-items: center;
        }
        .script-line input[type="text"] {
            padding: 10px;
            background: #1a1a1a;
            border: 1px solid #444;
            border-radius: 4px;
            color: #fff;
            font-size: 14px;
        }
        .script-line select {
            padding: 10px;
            background: #1a1a1a;
            border: 1px solid #444;
            border-radius: 4px;
            color: #fff;
            font-size: 13px;
            min-width: 130px;
        }
        .btn-add-line {
            background: #27ae60;
            color: #fff;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        .btn-remove-line {
            background: #e74c3c;
            color: #fff;
            border: none;
            padding: 10px 16px;
            border-radius: 4px;
            cursor: pointer;
        }
        .btn-save {
            background: #00ff88;
            color: #000;
            border: none;
            padding: 12px 32px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
        }
        .btn-save:hover {
            background: #00dd77;
        }
        .matchup-info {
            background: #2a2a2a;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
            color: #00ff88;
            font-size: 18px;
            font-weight: bold;
            text-align: center;
        }
        .btn-load {
            background: #00ff88;
            color: #000;
            border: none;
            padding: 12px 24px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            font-weight: bold;
            width: 100%;
        }
        .btn-load:hover {
            background: #00dd77;
        }
        .guide {
            background: #2a2a2a;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 15px;
            color: #fff;
            font-size: 13px;
            line-height: 1.6;
        }
        .guide strong {
            color: #00ff88;
        }
    </style>
</head>
<body>
<c:set var="adminCurrentPage" value="script" />
<%@ include file="/WEB-INF/views/layout/adminHeader.jsp" %>

<div class="script-container">
    <h1 class="script-header">📝 대본 관리</h1>

    <div class="selector-panel">
        <div class="selector-row">
            <div class="selector-group">
                <label>빌드 A 선택</label>
                <select id="buildASelect" onchange="loadBuildB()">
                    <option value="">먼저 빌드를 선택하세요</option>
                    <c:forEach items="${builds}" var="build">
                        <option value="${build.buildId}" data-race="${build.race}">
                            ${build.buildName} (${build.race})
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="selector-group">
                <label>빌드 B 선택</label>
                <select id="buildBSelect" onchange="updateMatchupInfo()" style="font-size:13px;">
                    <option value="">먼저 빌드 A를 선택하세요</option>
                </select>
            </div>

            <div class="selector-group">
                <label style="opacity:0;">-</label>
                <button class="btn-load" onclick="loadScripts()">
                    대본 불러오기
                </button>
            </div>
        </div>

        <div id="matchupInfo" class="matchup-info" style="display:none;">
            <div id="matchupText" style="margin-bottom: 15px;"></div>
            
            <div style="background: #1a1a1a; padding: 10px; border-radius: 4px; border: 1px dashed #00ff88; text-align: center;">
                <span style="color: #fff; font-size: 14px; margin-right: 15px;">⚔️ 현재 빌드 상성:</span>
                <label style="color: #fff; margin-right: 10px; cursor:pointer;"><input type="radio" name="matchupStatus" value="GOOD"> 유리함 (GOOD)</label>
                <label style="color: #fff; margin-right: 10px; cursor:pointer;"><input type="radio" name="matchupStatus" value="NORMAL" checked> 보통 (NORMAL)</label>
                <label style="color: #fff; margin-right: 15px; cursor:pointer;"><input type="radio" name="matchupStatus" value="BAD"> 불리함 (BAD)</label>
                <button type="button" class="btn-add-line" onclick="saveMatchupData()" style="padding: 5px 15px;">상성 저장</button>
            </div>
        </div>
    </div>

    <div class="script-editor" id="scriptEditor" style="display:none;">
        
        <div class="guide">
            <strong>💡 사용법:</strong><br>
            • 각 대본은 최대 4개씩 만들 수 있습니다 (랜덤 선택됨)<br>
            • <strong>해설:</strong> 경기 시작! (선수 이름 없음)<br>
            • <strong>빌드 A 선수:</strong> 금선 선수가 4드론을 시전합니다<br>
            • <strong>빌드 B 선수:</strong> 이영호 선수가 8배럭으로 압박합니다
        </div>
        
        <div class="main-tabs">
            <button class="main-tab-btn active" onclick="switchMainTab('win')">빌드 A 승리 대본</button>
            <button class="main-tab-btn" onclick="switchMainTab('lose')">빌드 A 패배 대본</button>
        </div>

        <div id="winMainTab" class="main-tab-content active">
            <div class="sub-tabs">
                <button class="sub-tab-btn active" onclick="switchSubTab('win', 0)">승리 대본 #1</button>
                <button class="sub-tab-btn" onclick="switchSubTab('win', 1)">승리 대본 #2</button>
                <button class="sub-tab-btn" onclick="switchSubTab('win', 2)">승리 대본 #3</button>
                <button class="sub-tab-btn" onclick="switchSubTab('win', 3)">승리 대본 #4</button>
            </div>
            
            <div id="winSub0" class="sub-tab-content active">
                <div class="script-lines" id="winLines0"></div>
                <button class="btn-add-line" onclick="addLine('win', 0)">+ 줄 추가</button>
            </div>
            <div id="winSub1" class="sub-tab-content">
                <div class="script-lines" id="winLines1"></div>
                <button class="btn-add-line" onclick="addLine('win', 1)">+ 줄 추가</button>
            </div>
            <div id="winSub2" class="sub-tab-content">
                <div class="script-lines" id="winLines2"></div>
                <button class="btn-add-line" onclick="addLine('win', 2)">+ 줄 추가</button>
            </div>
            <div id="winSub3" class="sub-tab-content">
                <div class="script-lines" id="winLines3"></div>
                <button class="btn-add-line" onclick="addLine('win', 3)">+ 줄 추가</button>
            </div>
        </div>

        <div id="loseMainTab" class="main-tab-content">
            <div class="sub-tabs">
                <button class="sub-tab-btn active" onclick="switchSubTab('lose', 0)">패배 대본 #1</button>
                <button class="sub-tab-btn" onclick="switchSubTab('lose', 1)">패배 대본 #2</button>
                <button class="sub-tab-btn" onclick="switchSubTab('lose', 2)">패배 대본 #3</button>
                <button class="sub-tab-btn" onclick="switchSubTab('lose', 3)">패배 대본 #4</button>
            </div>
            
            <div id="loseSub0" class="sub-tab-content active">
                <div class="script-lines" id="loseLines0"></div>
                <button class="btn-add-line" onclick="addLine('lose', 0)">+ 줄 추가</button>
            </div>
            <div id="loseSub1" class="sub-tab-content">
                <div class="script-lines" id="loseLines1"></div>
                <button class="btn-add-line" onclick="addLine('lose', 1)">+ 줄 추가</button>
            </div>
            <div id="loseSub2" class="sub-tab-content">
                <div class="script-lines" id="loseLines2"></div>
                <button class="btn-add-line" onclick="addLine('lose', 2)">+ 줄 추가</button>
            </div>
            <div id="loseSub3" class="sub-tab-content">
                <div class="script-lines" id="loseLines3"></div>
                <button class="btn-add-line" onclick="addLine('lose', 3)">+ 줄 추가</button>
            </div>
        </div>

        <div style="text-align:center; margin-top:30px;">
            <button class="btn-save" onclick="saveScripts()">💾 대본 저장</button>
        </div>
    </div>
</div>

<script>
let buildAId = 0;
let buildBId = 0;

// 승리 대본 4개 (각각 줄 배열)
let winScripts = [
    [{text: '', speaker: 'narration'}],
    [{text: '', speaker: 'narration'}],
    [{text: '', speaker: 'narration'}],
    [{text: '', speaker: 'narration'}]
];

// 패배 대본 4개
let loseScripts = [
    [{text: '', speaker: 'narration'}],
    [{text: '', speaker: 'narration'}],
    [{text: '', speaker: 'narration'}],
    [{text: '', speaker: 'narration'}]
];

function loadBuildB() {
    const buildASelect = document.getElementById('buildASelect');
    const buildBSelect = document.getElementById('buildBSelect');

    buildAId = buildASelect.value;

    if (!buildAId) {
        buildBSelect.innerHTML = '<option value="">먼저 빌드 A를 선택하세요</option>';
        document.getElementById('scriptEditor').style.display = 'none';
        document.getElementById('matchupInfo').style.display = 'none';
        return;
    }

    buildBSelect.innerHTML = '<option value="">빌드 B를 선택하세요</option>';
    // 모든 빌드를 빌드B 후보로 추가 (동족전, 자기 자신 빌드 포함)
    document.querySelectorAll('#buildASelect option').forEach(opt => {
        if (opt.value) {
            const newOpt = document.createElement('option');
            newOpt.value = opt.value;
            newOpt.text = opt.text;
            newOpt.dataset.scriptStatus = 'loading';
            buildBSelect.appendChild(newOpt);
        }
    });

    // 대본 작성 여부 조회 후 미작성 표시
    fetch('<c:url value="/admin/script/has-scripts" />?buildAId=' + buildAId)
        .then(res => res.json())
        .then(data => {
            if (!data.success) return;
            const status = data.scriptStatus || {};
            buildBSelect.querySelectorAll('option[value]').forEach(opt => {
                if (!opt.value) return;
                const s = status[opt.value];
                const hasWin  = s && s.hasWin;
                const hasLose = s && s.hasLose;
                if (!hasWin || !hasLose) {
                    const missing = [];
                    if (!hasWin)  missing.push('승리');
                    if (!hasLose) missing.push('패배');
                    opt.text = opt.text.replace(' ⚠️ 미작성', '') + ' ⚠️ 미작성(' + missing.join('/') + ')';
                    opt.style.color = '#e67e22';
                }
            });
        })
        .catch(() => {});
}

function updateMatchupInfo() {
    const buildASelect = document.getElementById('buildASelect');
    const buildBSelect = document.getElementById('buildBSelect');
    
    buildBId = buildBSelect.value;
    if (buildAId && buildBId) {
        const nameA = buildASelect.options[buildASelect.selectedIndex].text;
        const nameB = buildBSelect.options[buildBSelect.selectedIndex].text;
        document.getElementById('matchupText').textContent = nameA + ' vs ' + nameB;
        document.getElementById('matchupInfo').style.display = 'block';
    } else {
        document.getElementById('matchupInfo').style.display = 'none';
    }
}

//서버에서 대본 불러오기
function loadScripts() {
    if (!buildAId || !buildBId) {
        alert('빌드를 먼저 선택하세요!');
        return;
    }
    document.getElementById('scriptEditor').style.display = 'block';

    // 상성 정보 같이 불러오기 추가
    fetch('<c:url value="/admin/script/matchup/load" />?buildA=' + buildAId + '&buildB=' + buildBId)
        .then(res => res.json())
        .then(data => {
            if(data.success && data.status) {
                document.querySelector('input[name="matchupStatus"][value="'+data.status+'"]').checked = true;
            } else {
                document.querySelector('input[name="matchupStatus"][value="NORMAL"]').checked = true;
            }
        });

    const firstId = Math.min(parseInt(buildAId), parseInt(buildBId));
    const secondId = Math.max(parseInt(buildAId), parseInt(buildBId));
    const isSwapped = (firstId != buildAId);
    
    fetch('<c:url value="/admin/script/load" />', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ myBuildId: firstId, oppBuildId: secondId })
    })
    .then(res => res.json())
    .then(data => {
        // 1. 4개 탭 초기화
        for (let i = 0; i < 4; i++) {
            winScripts[i] = [{text: '', speaker: 'narration'}];
            loseScripts[i] = [{text: '', speaker: 'narration'}];
        }

        // 2. /// 로 묶여있던 통짜 데이터를 4개 탭으로 분리해서 쏙쏙 넣기
        if (data.success && data.scripts) {
            data.scripts.forEach(dto => {
                const tabs = dto.content.split('///'); 
                
                let currentResult = dto.result;
                if (isSwapped) {
                    currentResult = (dto.result === 'WIN') ? 'LOSE' : 'WIN';
                }
                
                let targetArray = (currentResult === 'WIN') ? winScripts : loseScripts;
                
                for (let i = 0; i < 4; i++) {
                    if (tabs[i] && tabs[i].trim() !== '') {
                        const lines = tabs[i].split('\n').filter(l => l.trim() !== '');
                        targetArray[i] = parseScriptSet(lines, isSwapped);
                    }
                }
            });
        }
        renderAllScripts();
    })
    .catch(err => {
        console.error('대본 로드 실패:', err);
        renderAllScripts();
    });
}

function parseScriptSet(lines, isSwapped) {
    return lines.map(line => {
        let text = line;
        let speaker = 'narration';
        
        if (line.startsWith('[빌드A] ')) {
            text = line.substring(6);
            speaker = isSwapped ? 'buildB' : 'buildA';  // swap되었으면 반전
        } else if (line.startsWith('[빌드B] ')) {
            text = line.substring(6);
            speaker = isSwapped ? 'buildA' : 'buildB';  // swap되었으면 반전
        }
        
        return {text: text, speaker: speaker};
    });
}

function renderAllScripts() {
    for (let i = 0; i < 4; i++) {
        renderScript('win', i, winScripts[i]);
        renderScript('lose', i, loseScripts[i]);
    }
}

function renderScript(type, setIdx, scriptLines) {
    const container = document.getElementById(type + 'Lines' + setIdx);
    container.innerHTML = '';
    
    scriptLines.forEach((script, lineIdx) => {
        const lineDiv = document.createElement('div');
        lineDiv.className = 'script-line';
        
        const input = document.createElement('input');
        input.type = 'text';
        input.value = script.text || '';
        input.placeholder = '대본 내용을 입력하세요';
        input.onchange = function() {
            updateLine(type, setIdx, lineIdx, 'text', this.value);
        };
        
        const select = document.createElement('select');
        select.innerHTML = `
            <option value="narration">해설</option>
            <option value="buildA">빌드 A 선수</option>
            <option value="buildB">빌드 B 선수</option>
        `;
        select.value = script.speaker || 'narration';
        select.onchange = function() {
            updateLine(type, setIdx, lineIdx, 'speaker', this.value);
        };
        
        const btn = document.createElement('button');
        btn.className = 'btn-remove-line';
        btn.textContent = '✕';
        btn.onclick = function() {
            removeLine(type, setIdx, lineIdx);
        };
        
        lineDiv.appendChild(input);
        lineDiv.appendChild(select);
        lineDiv.appendChild(btn);
        container.appendChild(lineDiv);
    });
}

function addLine(type, setIdx) {
    if (type === 'win') {
        winScripts[setIdx].push({text: '', speaker: 'narration'});
        renderScript('win', setIdx, winScripts[setIdx]);
    } else {
        loseScripts[setIdx].push({text: '', speaker: 'narration'});
        renderScript('lose', setIdx, loseScripts[setIdx]);
    }
    // 자동 스크롤
    const container = document.getElementById(type + 'Lines' + setIdx);
    setTimeout(() => { container.scrollTop = container.scrollHeight; }, 50);
}

function removeLine(type, setIdx, lineIdx) {
    if (type === 'win') {
        winScripts[setIdx].splice(lineIdx, 1);
        if (winScripts[setIdx].length === 0) winScripts[setIdx] = [{text: '', speaker: 'narration'}];
        renderScript('win', setIdx, winScripts[setIdx]);
    } else {
        loseScripts[setIdx].splice(lineIdx, 1);
        if (loseScripts[setIdx].length === 0) loseScripts[setIdx] = [{text: '', speaker: 'narration'}];
        renderScript('lose', setIdx, loseScripts[setIdx]);
    }
}

function updateLine(type, setIdx, lineIdx, field, value) {
    if (type === 'win') {
        winScripts[setIdx][lineIdx][field] = value;
    } else {
        loseScripts[setIdx][lineIdx][field] = value;
    }
}

function switchMainTab(type) {
    document.querySelectorAll('.main-tab-btn').forEach(btn => btn.classList.remove('active'));
    document.querySelectorAll('.main-tab-content').forEach(content => content.classList.remove('active'));
    if (type === 'win') {
        document.querySelector('.main-tab-btn:nth-child(1)').classList.add('active');
        document.getElementById('winMainTab').classList.add('active');
    } else {
        document.querySelector('.main-tab-btn:nth-child(2)').classList.add('active');
        document.getElementById('loseMainTab').classList.add('active');
    }
}

function switchSubTab(type, idx) {
    const parent = document.getElementById(type + 'MainTab');
    parent.querySelectorAll('.sub-tab-btn').forEach(btn => btn.classList.remove('active'));
    parent.querySelectorAll('.sub-tab-content').forEach(content => content.classList.remove('active'));
    
    parent.querySelectorAll('.sub-tab-btn')[idx].classList.add('active');
    document.getElementById(type + 'Sub' + idx).classList.add('active');
}

function saveScripts() {
    if (!buildAId || !buildBId) {
        alert('빌드를 먼저 선택하세요!');
        return;
    }

    const serializeTabs = (scriptArray) => {
        return scriptArray.map(set => {
            let lines = [];
            set.forEach(s => {
                if (s.text.trim() !== '') {
                    let prefix = '';
                    if (s.speaker === 'buildA') prefix = '[빌드A] ';
                    if (s.speaker === 'buildB') prefix = '[빌드B] ';
                    lines.push(prefix + s.text);
                }
            });
            return lines.join('\n');
        }).join('\n///\n');
    };

    const winContent = serializeTabs(winScripts);
    const loseContent = serializeTabs(loseScripts);

    if (winContent.replace(/\/\/\//g, '').trim() === '' && loseContent.replace(/\/\/\//g, '').trim() === '') {
        alert('최소 하나의 대본을 작성하세요!');
        return;
    }

    const firstId = Math.min(parseInt(buildAId), parseInt(buildBId));
    const secondId = Math.max(parseInt(buildAId), parseInt(buildBId));
    
    const data = {
        myBuildId: firstId,
        oppBuildId: secondId,
        scripts: [
            { resultType: 'WIN', content: winContent },
            { resultType: 'LOSE', content: loseContent }
        ]
    };
    
    fetch('<c:url value="/admin/script/save" />', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(data)
    })
    .then(res => res.json())
    .then(result => {
        if (result.success) {
            alert('대본이 성공적으로 저장되었습니다!');
        } else {
            alert('저장 실패: ' + result.message);
        }
    })
    .catch(err => {
        console.error('저장 실패:', err);
        alert('저장 중 오류가 발생했습니다.');
    });
}

// 상성 저장 함수 추가
function saveMatchupData() {
    if (!buildAId || !buildBId) return alert('빌드를 선택하세요.');
    if (buildAId === buildBId) return alert('동일 빌드는 상성을 설정할 수 없습니다.');

    let status = document.querySelector('input[name="matchupStatus"]:checked').value;

    fetch('<c:url value="/admin/script/matchup/save" />', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ buildA: buildAId, buildB: buildBId, status: status })
    })
    .then(res => res.json())
    .then(data => {
        if(data.success) alert('상성이 양방향으로 완벽하게 저장되었습니다!');
        else alert('저장 실패: ' + data.message);
    });
}
</script>

</body>
</html>