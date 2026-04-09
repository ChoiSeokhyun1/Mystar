<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>MYSTAR - LIVE TACTICAL SIMULATION</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:wght@500;700&family=Noto+Sans+KR:wght@300;400;500;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        /* ==========================================================================
           1. CORE VARIABLES & RESET
           ========================================================================== */
        :root {
            --bg-base: #0a0e17; 
            --panel-bg: rgba(16, 22, 36, 0.9);
            --panel-border: rgba(56, 189, 248, 0.15); 
            --blue-glow: rgba(56, 189, 248, 0.8); 
            --red-glow: rgba(244, 63, 94, 0.8); 
            --text-main: #e2e8f0; 
            --text-muted: #94a3b8; 
            --text-accent: #f1f5f9; 
            --log-text: #f8fafc; 
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }
        
        body {
            background-color: var(--bg-base);
            color: var(--text-main);
            font-family: 'Noto Sans KR', sans-serif;
            height: 100vh; width: 100vw;
            overflow: hidden;
            display: flex; flex-direction: column;
        }

        /* 옅은 전술 그리드 배경 효과 */
        body::before {
            content: ""; position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background-image: 
                radial-gradient(circle at 50% 0%, rgba(56, 189, 248, 0.03), transparent 50%),
                linear-gradient(rgba(255, 255, 255, 0.01) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255, 255, 255, 0.01) 1px, transparent 1px),
                repeating-linear-gradient(0deg, rgba(0, 0, 0, 0.03), rgba(0, 0, 0, 0.03) 1px, transparent 1px, transparent 2px);
            background-size: 100% 100%, 50px 50px, 50px 50px, 100% 4px;
            pointer-events: none; z-index: -1;
        }

        .hud-wrapper {
            width: 100%; max-width: 1920px; height: 100%;
            margin: 0 auto; padding: 25px;
            display: flex; flex-direction: column; gap: 30px;
            position: relative; z-index: 10;
        }

        /* ==========================================================================
           2. 💡수정됨: 깨지지 않는 견고한 스코어보드
           ========================================================================== */
        .top-scoreboard {
            position: relative;
            display: flex; justify-content: space-between; align-items: center;
            background: var(--panel-bg);
            border: 1px solid var(--panel-border);
            border-radius: 16px; padding: 20px 40px;
            box-shadow: 0 15px 50px rgba(0,0,0,0.6);
            backdrop-filter: blur(15px);
        }

        /* 상단 데코레이션 라인 */
        .top-scoreboard::before, .top-scoreboard::after {
            content: ''; position: absolute; top: -1px; width: 25%; height: 2px;
        }
        .top-scoreboard::before { left: 10%; background: linear-gradient(90deg, transparent, var(--blue-glow), transparent); }
        .top-scoreboard::after { right: 10%; background: linear-gradient(90deg, transparent, var(--red-glow), transparent); }

        /* 좌우 팀 블록 (Flex: 1로 동일한 비율 차지) */
        .team-block { display: flex; flex-direction: column; flex: 1; }
        .team-block.blue { align-items: flex-end; text-align: right; }
        .team-block.red { align-items: flex-start; text-align: left; }

        .team-name { font-size: 15px; color: var(--text-muted); font-weight: 500; letter-spacing: 2px; margin-bottom: 5px;}
        .player-name { font-size: 32px; font-weight: 900; color: var(--text-accent); letter-spacing: 1px; text-transform: uppercase;}
        .team-block.blue .player-name { text-shadow: 0 0 15px rgba(56, 189, 248, 0.4); }
        .team-block.red .player-name { text-shadow: 0 0 15px rgba(244, 63, 94, 0.4); }

        /* 💡수정됨: 겹침 방지를 위해 Gap을 줄이고 넓이 고정 */
        .score-center { 
            display: flex; align-items: center; justify-content: center; gap: 30px; 
            min-width: 300px; /* 좁아져도 깨지지 않게 최소 너비 보장 */
        }
        
        .score-num { font-size: 70px; font-weight: 700; font-family: 'Roboto Mono', monospace; line-height: 1; }
        .score-num.blue { color: var(--text-accent); text-shadow: 0 0 20px rgba(56, 189, 248, 0.8); }
        .score-num.red { color: var(--text-accent); text-shadow: 0 0 20px rgba(244, 63, 94, 0.8); }
        
        /* 💡수정됨: Absolute 제거하고 Flex로 정렬하여 겹침 완전 해결 */
        .match-info { display: flex; flex-direction: column; align-items: center; gap: 8px; z-index: 2;}
        .vs-badge {
            background: rgba(15, 23, 42, 0.9); border: 1px solid #475569; border-radius: 8px;
            padding: 8px 20px; font-size: 22px; color: var(--text-accent); font-weight: 900; letter-spacing: 1px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.5);
        }
        .set-status { 
            background: #eab308; color: #0f172a; padding: 4px 15px; border-radius: 4px; 
            font-size: 13px; font-weight: 700; letter-spacing: 1.5px; box-shadow: 0 3px 10px rgba(234, 179, 8, 0.3);
        }

        /* ==========================================================================
           3. MAIN STAGE (MAP & LOGS)
           ========================================================================== */
        .main-stage {
            display: flex; gap: 30px;
            flex-grow: 1; height: 0; min-height: 0;
        }

        /* --- LEFT: 완벽한 정사각형 미니맵 --- */
        .map-section {
            height: 100%; aspect-ratio: 1 / 1; flex-shrink: 0;
            background-color: rgba(10, 14, 23, 0.95);
            border: 1px solid var(--panel-border);
            border-radius: 12px; position: relative; overflow: hidden;
            box-shadow: 0 15px 40px rgba(0,0,0,0.6), inset 0 0 50px rgba(0,0,0,0.8);
            padding: 15px;
        }

        .minimap-container {
            width: 100%; height: 100%;
            background-color: #050810;
            background-image: 
                linear-gradient(rgba(255,255,255,0.03) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255,255,255,0.03) 1px, transparent 1px);
            background-size: 5% 5%;
            border-radius: 8px; position: relative; overflow: hidden;
            border: 1px solid rgba(255,255,255,0.05);
        }

        #entityLayer { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 10; }
        
        .entity {
            position: absolute; transform: translate(-50%, -50%);
            transition: top 1s cubic-bezier(0.4, 0, 0.2, 1), left 1s cubic-bezier(0.4, 0, 0.2, 1);
            display: flex; justify-content: center; align-items: center;
        }
        
        .building { width: 40px; height: 40px; border: 2px solid rgba(255,255,255,0.8); border-radius: 6px; position: relative; }
        .building.blue { background: rgba(56, 189, 248, 0.2); border-color: var(--blue-glow); box-shadow: 0 0 15px rgba(56, 189, 248, 0.5); }
        .building.red { background: rgba(244, 63, 94, 0.2); border-color: var(--red-glow); box-shadow: 0 0 15px rgba(244, 63, 94, 0.5); }
        
        .unit { width: 22px; height: 22px; border-radius: 50%; border: 2px solid rgba(255,255,255,0.9); }
        .unit.blue { background: var(--blue-glow); box-shadow: 0 0 10px rgba(56, 189, 248, 0.6); }
        .unit.red { background: var(--red-glow); box-shadow: 0 0 10px rgba(244, 63, 94, 0.6); }

        .attack-fx {
            position: absolute; color: #f59e0b; font-size: 40px;
            transform: translate(-50%, -50%); z-index: 20; text-shadow: 0 0 20px #f59e0b;
            animation: blast 0.5s ease-out forwards;
        }
        @keyframes blast {
            0% { transform: translate(-50%, -50%) scale(0.5); opacity: 1; }
            50% { transform: translate(-50%, -50%) scale(1.3) rotate(15deg); opacity: 1; }
            100% { transform: translate(-50%, -50%) scale(1.8); opacity: 0; }
        }

        /* --- RIGHT: 모멘텀 & 로그 --- */
        .right-section {
            flex-grow: 1; display: flex; flex-direction: column; gap: 20px; height: 100%;
        }

        /* 직관적인 주도권(모멘텀) 바 */
        .momentum-panel {
            background: var(--panel-bg);
            border: 1px solid var(--panel-border);
            border-radius: 12px; padding: 20px 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            backdrop-filter: blur(10px);
        }
        .momentum-title { text-align: center; font-size: 13px; color: var(--text-muted); font-weight: 500; letter-spacing: 2px; margin-bottom: 12px;}
        
        .momentum-labels { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 8px; }
        .m-name { font-size: 20px; font-weight: 900; text-transform: uppercase; letter-spacing: 1px;}
        .m-name.blue { color: var(--blue-glow); }
        .m-name.red { color: var(--red-glow); }
        .m-center { font-size: 11px; color: var(--text-muted); font-weight: 500; letter-spacing: 2px;}

        .momentum-bar-bg {
            width: 100%; height: 16px; background: rgba(244, 63, 94, 0.6);
            border-radius: 8px; overflow: hidden; position: relative;
            box-shadow: inset 0 0 8px rgba(0,0,0,0.7); border: 1px solid rgba(255,255,255,0.05);
        }
        #momentumFill {
            height: 100%; width: 50%; background: rgba(56, 189, 248, 0.7);
            transition: width 0.3s ease-out; border-right: 2px solid #fff;
            box-shadow: 0 0 15px rgba(56, 189, 248, 0.4);
        }

        /* 배경 없는 깔끔한 대본 영역 */
        .log-panel {
            flex-grow: 1;
            background: rgba(16, 22, 36, 0.4); 
            border: 1px solid rgba(255,255,255,0.05); border-radius: 12px;
            padding: 20px; display: flex; flex-direction: column; gap: 12px;
            overflow: hidden; 
        }

        .log-container {
            flex-grow: 1; overflow-y: auto; display: flex; flex-direction: column; gap: 10px;
            padding-right: 15px;
            -webkit-mask-image: linear-gradient(to bottom, transparent, black 5%, black 95%, transparent);
            mask-image: linear-gradient(to bottom, transparent, black 5%, black 95%, transparent);
        }
        .log-container::-webkit-scrollbar { width: 5px; }
        .log-container::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.1); border-radius: 3px; }

        .log-line {
            padding: 10px 12px; font-size: 18px; line-height: 1.6; font-weight: 600;
            color: var(--log-text);
            opacity: 0; transform: translateY(12px);
            animation: slideIn 0.3s ease-out forwards;
            word-break: keep-all;
            text-shadow: 0 1px 4px rgba(0,0,0,0.9); /* 가독성을 위한 강한 섀도우 */
        }
        @keyframes slideIn { to { opacity: 1; transform: translateY(0); } }

        .log-line.blue strong { color: var(--blue-glow); font-size: 20px; font-weight: 800; margin-right: 6px;}
        .log-line.red strong { color: var(--red-glow); font-size: 20px; font-weight: 800; margin-right: 6px;}
        .log-line.neutral { color: var(--text-muted); font-weight: 400; font-size: 16px; }

        /* 하단 진행 상태 및 액션 버튼 */
        .control-panel {
            background: var(--panel-bg); border-radius: 12px; padding: 20px;
            border: 1px solid var(--panel-border); backdrop-filter: blur(10px);
        }
        .progress-track { width: 100%; height: 6px; background: rgba(255,255,255,0.05); border-radius: 3px; overflow: hidden; margin-bottom: 15px;}
        #simProgressBar { height: 100%; width: 0%; background: #eab308; transition: width 0.2s; box-shadow: 0 0 10px rgba(234, 179, 8, 0.4);}

        .btn-action-wrapper { display: none; }
        .btn-action {
            width: 100%; background: rgba(10, 14, 23, 0.8); color: var(--blue-glow);
            border: 2px solid var(--blue-glow); padding: 15px; font-size: 20px; font-weight: 800;
            border-radius: 8px; cursor: pointer; transition: all 0.2s ease; letter-spacing: 2px; text-transform: uppercase;
        }
        .btn-action:hover { background: var(--blue-glow); color: #0a0e17; box-shadow: 0 0 25px rgba(56, 189, 248, 0.5); }
        .btn-final { border-color: #eab308; color: #eab308; }
        .btn-final:hover { background: #eab308; color: #0a0e17; box-shadow: 0 0 25px rgba(234, 179, 8, 0.5); }

    </style>
</head>
<body>

<script type="application/json" id="replayJsonData">${replayJson}</script>
<c:set var="idx" value="${currentSet - 1}" />
<c:set var="curMatchup" value="${matchupList[idx]}" />

<div class="hud-wrapper">
    <header class="top-scoreboard">
        <div class="team-block blue">
            <div class="team-name">${not empty myTeamName ? myTeamName : 'BLUE SQUADRON'}</div>
            <div class="player-name">${curMatchup.myPlayerName}</div>
        </div>
        
        <div class="score-center">
            <div class="score-num blue" id="userWins">${myWins}</div>
            <div class="match-info">
                <div class="vs-badge">VS</div>
                <div class="set-status">SET <span id="currentSetText">${currentSet}</span></div>
            </div>
            <div class="score-num red" id="aiWins">${aiWins}</div>
        </div>
        
        <div class="team-block red">
            <div class="team-name">${not empty opponentTeamName ? opponentTeamName : 'RED SQUADRON'}</div>
            <div class="player-name">${curMatchup.aiPlayerName}</div>
        </div>
    </header>

    <main class="main-stage">
        
        <section class="map-section">
            <div class="minimap-container" id="mapContainer">
                <div id="entityLayer"></div>
            </div>
        </section>

        <section class="right-section">
            
            <div class="momentum-panel">
                <div class="momentum-title">LIVE TACTICAL DOMINANCE</div>
                <div class="momentum-labels">
                    <span class="m-name blue">${curMatchup.myPlayerName}</span>
                    <span class="m-center">주도권</span>
                    <span class="m-name red">${curMatchup.aiPlayerName}</span>
                </div>
                <div class="momentum-bar-bg">
                    <div id="momentumFill"></div>
                </div>
            </div>

            <div class="log-panel">
                <div class="log-container" id="logContainer"></div>
            </div>

            <div class="control-panel">
                <div class="progress-track"><div id="simProgressBar"></div></div>
                <div class="btn-action-wrapper" id="actionArea">
                    <button id="btnNextSet" class="btn-action" onclick="nextSet()">ENGAGE NEXT SET ▶</button>
                    <button id="btnFinalResult" class="btn-action btn-final" onclick="showFinalResult()">VIEW FINAL REPORT 🏆</button>
                </div>
            </div>

        </section>
    </main>
</div>

<script>
    // --- 1. 데이터 로드 ---
    const replayJsonRaw = document.getElementById('replayJsonData').textContent;
    let replayData = {};
    try { replayData = JSON.parse(replayJsonRaw); } catch(e) {}

    const scriptLines = replayData.lines || [];
    const myWinFlag = replayData.myWin;
    const myName = replayData.myName || "${curMatchup.myPlayerName}";
    const aiName = replayData.aiName || "${curMatchup.aiPlayerName}";

    // --- 2. 💡수정됨: 2인용 맵 랜덤 스타팅 시스템 ---
    // 2개의 스폰 구역 (11시 방향 vs 5시 방향)
    const SPOT_A = { main: { x: 20, y: 20 }, exp: { x: 35, y: 20 }, rally: { x: 35, y: 35 } }; // 11시
    const SPOT_B = { main: { x: 80, y: 80 }, exp: { x: 65, y: 80 }, rally: { x: 65, y: 65 } }; // 5시
    
    const COORDS = { center: { x: 50, y: 50 } };

    // 50% 확률로 블루와 레드의 위치를 랜덤 배정
    if (Math.random() < 0.5) {
        COORDS.blue = SPOT_A;
        COORDS.red = SPOT_B;
    } else {
        COORDS.blue = SPOT_B;
        COORDS.red = SPOT_A;
    }

    const entityLayer = document.getElementById('entityLayer');

    function spawnEntity(id, type, team, startPos) {
        if(document.getElementById(id)) document.getElementById(id).remove();
        const el = document.createElement('div');
        el.id = id; el.className = 'entity ' + type + ' ' + team;
        el.style.left = startPos.x + '%'; el.style.top = startPos.y + '%';
        entityLayer.appendChild(el);
        return el;
    }

    function moveEntity(id, targetPos) {
        const el = document.getElementById(id);
        if(el) { el.style.left = targetPos.x + '%'; el.style.top = targetPos.y + '%'; }
    }

    function playAttackEffect(pos) {
        const fx = document.createElement('div');
        fx.className = 'attack-fx';
        fx.innerHTML = '<i class="fa-solid fa-crosshairs"></i>'; 
        fx.style.left = pos.x + '%'; fx.style.top = pos.y + '%';
        entityLayer.appendChild(fx);
        setTimeout(() => { fx.remove(); }, 600);
    }

    // 본진 배치
    spawnEntity('blue_main', 'building', 'blue', COORDS.blue.main);
    spawnEntity('red_main', 'building', 'red', COORDS.red.main);

    // --- 3. Simulation Logic ---
    let currentLineIdx = 0;
    let currentMomentum = 50; 
    const logContainer = document.getElementById('logContainer');
    const momentumFill = document.getElementById('momentumFill');
    const progressBar = document.getElementById('simProgressBar');

    function parseMapAction(line, isBlue) {
        const myCoords = isBlue ? COORDS.blue : COORDS.red;
        const enemyCoords = isBlue ? COORDS.red : COORDS.blue;
        const teamStr = isBlue ? 'blue' : 'red';
        
        if(line.includes("멀티") || line.includes("해처리") || line.includes("넥서스") || line.includes("커맨드")) {
            spawnEntity(teamStr + '_exp', 'building', teamStr, myCoords.exp);
        }
        if(line.includes("마린") || line.includes("질럿") || line.includes("저글링") || line.includes("병력")) {
            spawnEntity(teamStr + '_army', 'unit', teamStr, myCoords.main);
            setTimeout(() => { moveEntity(teamStr + '_army', myCoords.rally); }, 400);
        }
        if(line.includes("공격") || line.includes("압박") || line.includes("러시") || line.includes("돌파")) {
            moveEntity(teamStr + '_army', COORDS.center);
            setTimeout(() => { moveEntity(teamStr + '_army', enemyCoords.rally); }, 1000);
            setTimeout(() => { playAttackEffect(enemyCoords.rally); }, 1600);
        }
    }

    function startSimulation() {
        if(scriptLines.length === 0) { finishSet(); return; }
        
        const interval = setInterval(() => {
            if (currentLineIdx < scriptLines.length) {
                const line = scriptLines[currentLineIdx];
                const entry = document.createElement('div');
                entry.className = 'log-line';
                
                let shift = 0;
                let isBlueAction = null;

                if (line.startsWith('[빌드A]')) {
                    isBlueAction = true;
                    entry.classList.add('blue'); 
                    entry.innerHTML = "<strong>[" + myName + "]</strong> : " + line.replace('[빌드A]', '').trim();
                    shift = 15;
                } else if (line.startsWith('[빌드B]')) {
                    isBlueAction = false;
                    entry.classList.add('red'); 
                    entry.innerHTML = "<strong>[" + aiName + "]</strong> : " + line.replace('[빌드B]', '').trim();
                    shift = -15;
                } else {
                    entry.classList.add('neutral'); 
                    entry.innerText = line;
                    shift = myWinFlag ? 5 : -5; 
                }

                if(isBlueAction !== null) parseMapAction(line, isBlueAction);

                // 모멘텀 바 조절
                currentMomentum += shift;
                if(currentMomentum > 90) currentMomentum = 90;
                if(currentMomentum < 10) currentMomentum = 10;
                if(currentLineIdx === scriptLines.length - 1) currentMomentum = myWinFlag ? 100 : 0;
                momentumFill.style.width = currentMomentum + '%';

                // 로그 스크롤
                logContainer.appendChild(entry);
                logContainer.scrollTop = logContainer.scrollHeight;
                
                currentLineIdx++;
                progressBar.style.width = (currentLineIdx / scriptLines.length * 100) + '%';
            } else {
                clearInterval(interval); finishSet();
            }
        }, 2100); 
    }

    function finishSet() {
        document.getElementById('actionArea').style.display = 'block';
        
        const finalMyWins = myWinFlag ? parseInt("${myWins}") + 1 : parseInt("${myWins}");
        const finalAiWins = !myWinFlag ? parseInt("${aiWins}") + 1 : parseInt("${aiWins}");
        
        if(finalMyWins >= 3 || finalAiWins >= 3) {
            document.getElementById('btnNextSet').style.display = 'none';
            document.getElementById('btnFinalResult').style.display = 'block';
        }
    }

    function nextSet() { location.href = "<c:url value='/pve/finish' />?winner=" + (myWinFlag ? "player" : "ai"); }
    function showFinalResult() { location.href = "<c:url value='/pve/finish' />?winner=" + (myWinFlag ? "player" : "ai"); }

    window.onload = function() { setTimeout(startSimulation, 800); };
</script>

</body>
</html>