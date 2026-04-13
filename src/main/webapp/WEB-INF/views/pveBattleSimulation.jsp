<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>MYSTAR - 3v3 LIVE TACTICAL SIMULATION</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:wght@500;700&family=Noto+Sans+KR:wght@300;400;500;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        /* --- 3v3 ATB Core Styles --- */
        :root {
            --bg-base: #050810; 
            --panel-bg: rgba(16, 22, 36, 0.85);
            --panel-border: rgba(56, 189, 248, 0.2); 
            --blue-glow: rgba(56, 189, 248, 0.9);
            --red-glow: rgba(244, 63, 94, 0.9); 
            --text-main: #e2e8f0; 
            --text-muted: #94a3b8; 
        }
        body {
            background-color: var(--bg-base); color: var(--text-main);
            font-family: 'Noto Sans KR', sans-serif;
            height: 100vh; width: 100vw; overflow: hidden; margin: 0;
            display: flex; flex-direction: column;
            background-image: radial-gradient(circle at 50% 0%, rgba(56, 189, 248, 0.05), transparent 60%);
        }
        .hud-wrapper {
            width: 100%; max-width: 1920px; height: 100%; margin: 0 auto; padding: 20px;
            display: flex; flex-direction: column; gap: 20px; box-sizing: border-box;
        }

        /* Top Header */
        .top-scoreboard {
            display: flex; justify-content: space-between; align-items: center;
            background: var(--panel-bg); border: 1px solid var(--panel-border);
            border-radius: 12px; padding: 15px 30px; flex-shrink: 0; box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        }
        .team-name { font-size: 24px; font-weight: 900; letter-spacing: 2px; }
        .team-name.blue { color: var(--blue-glow); text-shadow: 0 0 10px rgba(56, 189, 248, 0.5); }
        .team-name.red { color: var(--red-glow); text-shadow: 0 0 10px rgba(244, 63, 94, 0.5); }
        .vs-badge { background: #0f172a; border: 1px solid #475569; padding: 5px 15px; border-radius: 6px; font-weight: 900; }

        /* Main Stage */
        .main-stage { display: flex; gap: 20px; flex-grow: 1; height: 0; }

        /* Left: Tactical Board (Map) */
        .map-section {
            height: 100%; aspect-ratio: 1 / 1; flex-shrink: 0;
            background-color: rgba(5, 8, 16, 0.95);
            border: 1px solid rgba(255,255,255,0.1); border-radius: 12px;
            position: relative; overflow: hidden; box-shadow: inset 0 0 50px rgba(0,0,0,0.8);
        }
        #hexCanvas { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 1; }
        #svgOverlay { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 5; pointer-events: none; }
        #entityLayer { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 10; }

        /* Base Node UI */
        .tactical-base { position: absolute; transform: translate(-50%, -50%); display: flex; flex-direction: column; align-items: center; gap: 4px; transition: opacity 0.5s; }
        .tactical-base.dead { opacity: 0.3; filter: grayscale(100%); }
        .base-icon {
            width: 45px; height: 45px; border-radius: 8px; border: 2px solid;
            display: flex; justify-content: center; align-items: center; font-size: 20px;
            background: rgba(0,0,0,0.6); backdrop-filter: blur(4px); z-index: 2; color: #fff;
        }
        .tactical-base.blue .base-icon { border-color: var(--blue-glow); box-shadow: 0 0 15px rgba(56, 189, 248, 0.4); }
        .tactical-base.red .base-icon { border-color: var(--red-glow); box-shadow: 0 0 15px rgba(244, 63, 94, 0.4); }
        .base-label { font-size: 12px; font-weight: 700; text-shadow: 0 2px 4px #000; }
        
        .bars-wrapper { width: 60px; display: flex; flex-direction: column; gap: 3px; }
        .bar-track { width: 100%; background: rgba(255,255,255,0.1); border-radius: 2px; overflow: hidden; }
        .hp-fill { height: 5px; background: #22c55e; transition: width 0.3s ease-out; }

        /* Right Panel */
        .right-section { flex-grow: 1; display: flex; flex-direction: column; gap: 15px; height: 100%; }

        /* Squad Status */
        .squad-status-panel { display: flex; gap: 15px; flex-shrink: 0; }
        .team-column { flex: 1; display: flex; flex-direction: column; gap: 10px; background: var(--panel-bg); border: 1px solid var(--panel-border); border-radius: 12px; padding: 15px; }
        .team-column.red { border-color: rgba(244, 63, 94, 0.2); }
        .col-header { font-size: 12px; font-weight: 700; color: var(--text-muted); text-align: center; margin-bottom: 5px; letter-spacing: 2px; }
        
        .player-card {
            background: rgba(0,0,0,0.4); border: 1px solid rgba(255,255,255,0.05); border-radius: 8px; padding: 10px; position: relative; overflow: hidden;
        }
        .player-card.dead { opacity: 0.4; }
        .player-card::before { content: ''; position: absolute; left: 0; top: 0; width: 4px; height: 100%; }
        .team-column.blue .player-card::before { background: var(--blue-glow); }
        .team-column.red .player-card::before { background: var(--red-glow); }
        .card-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; }
        .p-name { font-size: 15px; font-weight: 900; }
        .p-hp-text { font-family: 'Roboto Mono', monospace; font-size: 12px; color: #22c55e; font-weight: 700; }
        .card-hp-bar { width: 100%; height: 4px; background: rgba(255,255,255,0.1); border-radius: 2px; margin-bottom: 8px; }
        .card-hp-fill { height: 100%; background: #22c55e; transition: width 0.3s; }
        .card-stats { display: flex; justify-content: space-between; font-family: 'Roboto Mono', monospace; font-size: 11px; color: var(--text-muted); }
        .card-stats span span { color: #fff; font-weight: 700; margin-left: 4px; }

        /* Momentum Tug of War */
        .momentum-panel { background: var(--panel-bg); border: 1px solid rgba(255,255,255,0.1); border-radius: 12px; padding: 15px; flex-shrink: 0; }
        .momentum-header { display: flex; justify-content: space-between; font-size: 12px; font-weight: 700; margin-bottom: 8px; }
        .tug-of-war-bg { width: 100%; height: 16px; background: #1e293b; border-radius: 8px; position: relative; overflow: hidden; display: flex; }
        .tug-blue { height: 100%; background: linear-gradient(90deg, rgba(56,189,248,0.5), var(--blue-glow)); transition: width 0.5s ease-out; }
        .tug-red { height: 100%; background: linear-gradient(270deg, rgba(244,63,94,0.5), var(--red-glow)); transition: width 0.5s ease-out; }
        .tug-center { position: absolute; left: 50%; top: -2px; bottom: -2px; width: 4px; background: #fff; box-shadow: 0 0 10px #fff; z-index: 2; transform: translateX(-50%); }

        /* Combat Log */
        .log-panel { flex-grow: 1; background: rgba(0,0,0,0.5); border: 1px solid rgba(255,255,255,0.05); border-radius: 12px; padding: 15px; display: flex; flex-direction: column; overflow: hidden; }
        .log-container { flex-grow: 1; overflow-y: auto; display: flex; flex-direction: column; gap: 8px; font-size: 14px; font-weight: 500; color: #cbd5e1; }
        .log-container::-webkit-scrollbar { width: 4px; }
        .log-container::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.2); }
        .log-line { animation: fadeIn 0.3s ease-out; }
        .log-line.blue { color: #38bdf8; }
        .log-line.red { color: #f43f5e; }
        .log-line.kill { color: #eab308; font-weight: 900; }
        .log-line.system { color: #a855f7; font-style: italic; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(5px); } to { opacity: 1; transform: translateY(0); } }

        /* Modal */
        .modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.8); backdrop-filter: blur(5px); z-index: 1000; display: none; justify-content: center; align-items: center; }
        .modal-content { background: var(--bg-base); border: 1px solid var(--blue-glow); padding: 40px; border-radius: 16px; text-align: center; box-shadow: 0 0 50px rgba(56, 189, 248, 0.3); }
        .modal-content h1 { font-size: 36px; margin-bottom: 20px; }
        .modal-content.victory h1 { color: #22c55e; }
        .modal-content.defeat h1 { color: #f43f5e; border-color: var(--red-glow); box-shadow: 0 0 50px rgba(244, 63, 94, 0.3); }
        .modal-btn { padding: 12px 30px; font-size: 16px; font-weight: 700; background: var(--blue-glow); color: #000; border: none; border-radius: 8px; cursor: pointer; text-decoration: none; margin-top: 20px; display: inline-block; }
    </style>
</head>
<body>

<div class="hud-wrapper">
    <header class="top-scoreboard">
        <div class="team-name blue">${myTeamName}</div>
        <div class="vs-badge">VS</div>
        <div class="team-name red">${opponentTeamName}</div>
    </header>

    <main class="main-stage">
        <section class="map-section" id="tacticalBoard">
            <canvas id="hexCanvas"></canvas>
            <svg id="svgOverlay"></svg>
            <div id="entityLayer"></div>
        </section>

        <section class="right-section">
            <div class="squad-status-panel">
                <div class="team-column blue" id="blueSquadPanel">
                    <div class="col-header">BLUE SQUADRON</div>
                </div>
                <div class="team-column red" id="redSquadPanel">
                    <div class="col-header">RED SQUADRON</div>
                </div>
            </div>

            <div class="momentum-panel">
                <div class="momentum-header">
                    <span style="color:#38bdf8;" id="blueTotalHpTxt">BLUE HP: 0</span>
                    <span style="color:#94a3b8;">SURVIVAL MOMENTUM</span>
                    <span style="color:#f43f5e;" id="redTotalHpTxt">RED HP: 0</span>
                </div>
                <div class="tug-of-war-bg">
                    <div class="tug-blue" id="tugBlueBar" style="width: 50%;"></div>
                    <div class="tug-red" id="tugRedBar" style="width: 50%;"></div>
                    <div class="tug-center"></div>
                </div>
            </div>

            <div class="log-panel">
                <div class="log-container" id="logBox"></div>
            </div>
        </section>
    </main>
</div>

<div class="modal-overlay" id="resultModal">
    <div class="modal-content" id="modalBox">
        <h1 id="modalTitle">VICTORY</h1>
        <p id="modalMsg">데이터를 서버에 동기화 중...</p>
        <a href="${pageContext.request.contextPath}/pve/lobby" class="modal-btn">로비로 돌아가기</a>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<script>
    // ==========================================
    // 1. 데이터 수신 및 초기화
    // ==========================================
    const battleData = ${battleDataJson};   // 6명의 초기 선수 데이터 (Array)
    const eventTimeline = ${eventLogJson};  // 타임라인 로그 (Array)
    const simWinner = '${simWinner}';       // 'blue' or 'red'
    const stageLevel = ${stageLevel};
    const subLevel = ${subLevel};
    
    const svgOverlay = document.getElementById('svgOverlay');
    const entityLayer = document.getElementById('entityLayer');
    const logBox = document.getElementById('logBox');
    
    // UI 상태 관리용 객체
    let hpState = {};
    let maxHpState = {};
    let totalBlueMaxHp = 0, totalRedMaxHp = 0;
    
    // 스타팅 위치 (API에서 동적으로 로드, 실패 시 폴백)
    const fallbackPositions = [
        {x: 20, y: 25}, {x: 15, y: 55}, {x: 35, y: 80},
        {x: 80, y: 20}, {x: 85, y: 60}, {x: 65, y: 85}
    ];

    function initBattleUI() {
        battleData.forEach(f => {
            hpState[f.id] = f.hp;
            maxHpState[f.id] = f.maxHp;
            
            if (f.team === 'blue') totalBlueMaxHp += f.maxHp;
            else totalRedMaxHp += f.maxHp;

            // 1. 맵 위에 기지 생성
            // startX/startY는 loadMapAndAssignPositions()에서 사전 할당됨
            let pos = (f.startX != null) ? { x: f.startX, y: f.startY } : fallbackPositions.shift() || {x: 50, y: 50};
            f.x = pos.x; f.y = pos.y; // 좌표 저장
            
            let baseHtml = `
                <div class="tactical-base ${f.team}" id="base_${f.id}" style="left: ${pos.x}%; top: ${pos.y}%;">
                    <div class="base-icon"><i class="fa-solid fa-${f.team === 'blue' ? 'jet-fighter' : 'skull'}"></i></div>
                    <div class="bars-wrapper">
                        <div class="bar-track"><div class="hp-fill" id="maphp_${f.id}" style="width: 100%;"></div></div>
                    </div>
                    <div class="base-label">${f.name}</div>
                </div>
            `;
            entityLayer.insertAdjacentHTML('beforeend', baseHtml);

            // 2. 우측 패널 카드 생성
            let cardHtml = `
                <div class="player-card" id="card_${f.id}">
                    <div class="card-top">
                        <span class="p-name">${f.name}</span>
                        <span class="p-hp-text" id="cardhptext_${f.id}">${f.hp}/${f.maxHp}</span>
                    </div>
                    <div class="card-hp-bar"><div class="card-hp-fill" id="cardhpbar_${f.id}" style="width: 100%;"></div></div>
                    <div class="card-stats">
                        <span>ATK<span>${f.atk}</span></span>
                        <span>DEF<span>${f.def}</span></span>
                        <span>SPD<span>${f.spd}</span></span>
                    </div>
                </div>
            `;
            document.getElementById(f.team + 'SquadPanel').insertAdjacentHTML('beforeend', cardHtml);
        });

        updateMomentumUI();
        initHexMap(); // 헥사곤 맵 그리기
    }

    function addLog(text, typeClass) {
        const div = document.createElement('div');
        div.className = 'log-line ' + (typeClass || '');
        div.innerText = text;
        logBox.appendChild(div);
        logBox.scrollTop = logBox.scrollHeight;
    }

    // ==========================================
    // 2. UI 실시간 업데이트 함수
    // ==========================================
    function updateHP(targetId, newHp) {
        hpState[targetId] = Math.max(0, newHp);
        const maxHp = maxHpState[targetId];
        const pct = (hpState[targetId] / maxHp) * 100;
        
        // 맵 위 HP바, 카드 HP바, 카드 텍스트 업데이트
        document.getElementById('maphp_' + targetId).style.width = pct + '%';
        document.getElementById('cardhpbar_' + targetId).style.width = pct + '%';
        document.getElementById('cardhptext_' + targetId).innerText = hpState[targetId] + '/' + maxHp;

        if (hpState[targetId] <= 0) {
            document.getElementById('base_' + targetId).classList.add('dead');
            document.getElementById('card_' + targetId).classList.add('dead');
        }
        updateMomentumUI();
    }

    function updateMomentumUI() {
        let curBlueHp = 0, curRedHp = 0;
        battleData.forEach(f => {
            if (f.team === 'blue') curBlueHp += hpState[f.id];
            else curRedHp += hpState[f.id];
        });
        
        document.getElementById('blueTotalHpTxt').innerText = 'BLUE HP: ' + curBlueHp;
        document.getElementById('redTotalHpTxt').innerText = 'RED HP: ' + curRedHp;

        let totalCur = curBlueHp + curRedHp;
        if (totalCur === 0) return;
        
        let bluePct = (curBlueHp / totalCur) * 100;
        document.getElementById('tugBlueBar').style.width = bluePct + '%';
        document.getElementById('tugRedBar').style.width = (100 - bluePct) + '%';
        
        renderHexMap(); // HP 변화에 따라 영토 다시 그리기
    }

    // ==========================================
    // 3. 시각적 이펙트 함수 (화살표 & 폭발)
    // ==========================================
    function getCenterCoords(el) {
        const rect = el.getBoundingClientRect();
        const mapRect = document.getElementById('tacticalBoard').getBoundingClientRect();
        return {
            x: ((rect.left + rect.width/2 - mapRect.left) / mapRect.width) * 100,
            y: ((rect.top + rect.height/2 - mapRect.top) / mapRect.height) * 100
        };
    }

    function drawTacticalArrow(actorId, targetId, team) {
        const p1 = getCenterCoords(document.getElementById('base_' + actorId));
        const p2 = getCenterCoords(document.getElementById('base_' + targetId));
        const color = team === 'blue' ? 'rgba(56, 189, 248, 0.8)' : 'rgba(244, 63, 94, 0.8)';
        
        const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
        line.setAttribute('x1', p1.x + '%'); line.setAttribute('y1', p1.y + '%');
        line.setAttribute('x2', p1.x + '%'); line.setAttribute('y2', p1.y + '%'); // 처음엔 점
        line.setAttribute('stroke', color);
        line.setAttribute('stroke-width', '0.6');
        svgOverlay.appendChild(line);

        // 0.8초간 늘어나는 애니메이션
        let startTime = performance.now();
        function animateLine(time) {
            let progress = (time - startTime) / 800;
            if (progress < 1) {
                line.setAttribute('x2', p1.x + (p2.x - p1.x) * progress + '%');
                line.setAttribute('y2', p1.y + (p2.y - p1.y) * progress + '%');
                requestAnimationFrame(animateLine);
            } else {
                line.setAttribute('x2', p2.x + '%'); line.setAttribute('y2', p2.y + '%');
                line.style.transition = 'opacity 0.3s';
                line.style.opacity = '0';
                setTimeout(() => line.remove(), 300);
            }
        }
        requestAnimationFrame(animateLine);
    }

    function showExplosion(targetId) {
        const target = document.getElementById('base_' + targetId);
        const effect = document.createElement('div');
        effect.style.position = 'absolute';
        effect.style.width = '60px'; effect.style.height = '60px';
        effect.style.background = 'radial-gradient(circle, #facc15 0%, rgba(244,63,94,0) 70%)';
        effect.style.borderRadius = '50%';
        effect.style.left = '50%'; effect.style.top = '50%';
        effect.style.transform = 'translate(-50%, -50%) scale(0.5)';
        effect.style.zIndex = '20';
        effect.style.transition = 'transform 0.3s ease-out, opacity 0.3s ease-out';
        
        target.appendChild(effect);
        
        setTimeout(() => { effect.style.transform = 'translate(-50%, -50%) scale(1.5)'; effect.style.opacity = '0'; }, 10);
        setTimeout(() => effect.remove(), 300);
    }

    // ==========================================
    // 4. 헥사곤 인플루언스 맵 렌더링
    // ==========================================
    const canvas = document.getElementById('hexCanvas');
    const ctx = canvas.getContext('2d');
    let hexRadius = 15;
    
    function initHexMap() {
        const rect = canvas.parentElement.getBoundingClientRect();
        canvas.width = rect.width; canvas.height = rect.height;
        renderHexMap();
    }

    function renderHexMap() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        const hexHeight = hexRadius * Math.sqrt(3);
        const cols = Math.ceil(canvas.width / (hexRadius * 1.5)) + 1;
        const rows = Math.ceil(canvas.height / hexHeight) + 1;

        for (let col = 0; col < cols; col++) {
            for (let row = 0; row < rows; row++) {
                let x = col * hexRadius * 1.5;
                let y = row * hexHeight + (col % 2 === 1 ? hexHeight / 2 : 0);
                
                // 해당 셀과 각 기지와의 거리 계산하여 지배력(Influence) 산출
                let maxInf = 0; let domTeam = null;
                battleData.forEach(f => {
                    if (hpState[f.id] <= 0) return; // 죽은 놈은 영향력 0
                    
                    let bx = (f.x / 100) * canvas.width;
                    let by = (f.y / 100) * canvas.height;
                    let dist = Math.sqrt(Math.pow(x - bx, 2) + Math.pow(y - by, 2));
                    
                    // HP 비율에 비례하는 영향력 반경 (기본 150px ~ 풀피 250px)
                    let hpRatio = hpState[f.id] / maxHpState[f.id];
                    let powerRadius = 100 + (hpRatio * 150); 
                    let inf = Math.max(0, 1 - (dist / powerRadius));
                    
                    if (inf > maxInf) { maxInf = inf; domTeam = f.team; }
                });

                if (maxInf > 0) {
                    ctx.beginPath();
                    for (let i = 0; i < 6; i++) {
                        let angle = (Math.PI / 180) * (60 * i);
                        let hx = x + hexRadius * Math.cos(angle);
                        let hy = y + hexRadius * Math.sin(angle);
                        if (i === 0) ctx.moveTo(hx, hy); else ctx.lineTo(hx, hy);
                    }
                    ctx.closePath();
                    
                    let alpha = Math.min(0.6, maxInf * 0.8);
                    ctx.fillStyle = domTeam === 'blue' ? `rgba(56, 189, 248, ${alpha})` : `rgba(244, 63, 94, ${alpha})`;
                    ctx.fill();
                    ctx.strokeStyle = `rgba(255, 255, 255, ${alpha * 0.2})`;
                    ctx.lineWidth = 1;
                    ctx.stroke();
                }
            }
        }
    }

    // ==========================================
    // 5. 비동기 시뮬레이션 플레이어 (Main Loop)
    // ==========================================
    const sleep = ms => new Promise(r => setTimeout(r, ms));

    // ==========================================
    // 5-0. 맵 스타팅 포인트 로드 및 랜덤 배치
    // ==========================================
    async function loadMapAndAssignPositions() {
        try {
            const resp = await fetch('${pageContext.request.contextPath}/api/map/info?stageLevel=${stageLevel}&subLevel=${subLevel}&setNum=1');
            const data = await resp.json();

            if (!data.success) return;

            // 맵 배경 이미지 설정
            if (data.bgImageUrl) {
                const board = document.getElementById('tacticalBoard');
                board.style.backgroundImage = "url('" + data.bgImageUrl + "')";
                board.style.backgroundSize  = 'cover';
                board.style.backgroundPosition = 'center';
            }

            // STARTING 타입 지점만 필터링
            const startingPoints = (data.points || []).filter(p => p.pointType === 'STARTING');
            if (startingPoints.length < battleData.length) return; // 포인트 수 부족 시 폴백

            // 이미지 자연 크기 로드 후 % 좌표 계산
            await new Promise(resolve => {
                const img = new Image();
                img.onload = function() {
                    const W = img.naturalWidth  || 1;
                    const H = img.naturalHeight || 1;

                    // Fisher-Yates 셔플
                    for (let i = startingPoints.length - 1; i > 0; i--) {
                        const j = Math.floor(Math.random() * (i + 1));
                        [startingPoints[i], startingPoints[j]] = [startingPoints[j], startingPoints[i]];
                    }

                    // battleData 순서대로 스타팅 위치 할당
                    battleData.forEach((fighter, idx) => {
                        if (idx < startingPoints.length) {
                            fighter.startX = (startingPoints[idx].pixelX / W) * 100;
                            fighter.startY = (startingPoints[idx].pixelY / H) * 100;
                        }
                    });
                    resolve();
                };
                img.onerror = resolve; // 이미지 로드 실패 시 폴백 사용
                img.src = data.bgImageUrl || '';
            });

        } catch(e) {
            console.warn('[MSL] 맵 정보 로드 실패, 기본 위치 사용:', e);
        }
    }

    async function startReplay() {
        await loadMapAndAssignPositions(); // 맵 로드 및 스타팅 위치 할당
        initBattleUI();
        addLog("SYSTEM: 3v3 전술 교전 데이터를 수신했습니다.", "system");
        await sleep(1500);
        addLog("SYSTEM: 전투 시뮬레이션을 시작합니다...", "system");
        await sleep(1000);

        for (let i = 0; i < eventTimeline.length; i++) {
            const event = eventTimeline[i];
            
            if (event.eventType === 'ATTACK') {
                drawTacticalArrow(event.actorId, event.targetId, event.actorTeam);
                await sleep(800); // 투사체 비행 시간 대기
                
                showExplosion(event.targetId);
                updateHP(event.targetId, event.targetHp);
                addLog(event.logMessage, event.logType);
                
            } else if (event.eventType === 'DEATH') {
                addLog(event.logMessage, "kill");
            }
            
            await sleep(400); // 다음 행동까지의 숨고르기
        }

        addLog("SYSTEM: 전투가 모두 종료되었습니다.", "system");
        await sleep(1000);
        finishBattleAPI();
    }

    // ==========================================
    // 6. 결과 DB 전송 및 모달창
    // ==========================================
    function finishBattleAPI() {
        // MainController의 /pve/battle/finish 로 승패를 전달
        $.ajax({
            url: '${pageContext.request.contextPath}/pve/battle/finish',
            type: 'POST',
            data: { level: stageLevel, subLevel: subLevel, winner: simWinner },
            success: function(res) {
                const mBox = document.getElementById('modalBox');
                const mTitle = document.getElementById('modalTitle');
                const mMsg = document.getElementById('modalMsg');
                
                document.getElementById('resultModal').style.display = 'flex';
                
                if (simWinner === 'blue') {
                    mBox.className = 'modal-content victory';
                    mTitle.innerText = "VICTORY";
                    mMsg.innerText = "스테이지를 성공적으로 클리어했습니다!";
                } else {
                    mBox.className = 'modal-content defeat';
                    mTitle.innerText = "DEFEAT";
                    mMsg.innerText = "작전 실패. 편성을 변경하여 다시 도전하세요.";
                }
            },
            error: function() {
                alert("결과 저장 중 오류가 발생했습니다.");
                location.href = '${pageContext.request.contextPath}/pve/lobby';
            }
        });
    }

    // 창 크기가 바뀌면 헥사곤 맵 다시 그리기
    window.addEventListener('resize', initHexMap);
    
    // 페이지 로드 완료 시 재생 시작!
    window.onload = startReplay;

</script>
</body>
</html>