<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>MYSTAR - 3v3 ATB TACTICAL BATTLE</title>
    <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:wght@500;700&family=Noto+Sans+KR:wght@300;400;500;700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
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
            background-color: var(--bg-base); color: var(--text-main);
            font-family: 'Noto Sans KR', sans-serif;
            height: 100vh; width: 100vw; overflow: hidden;
            display: flex; flex-direction: column;
        }
        body::before {
            content: ""; position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background-image:
                radial-gradient(circle at 50% 0%, rgba(56,189,248,0.03), transparent 50%),
                linear-gradient(rgba(255,255,255,0.01) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255,255,255,0.01) 1px, transparent 1px);
            background-size: 100% 100%, 50px 50px, 50px 50px;
            pointer-events: none; z-index: -1;
        }
        .hud-wrapper {
            width: 100%; max-width: 1920px; height: 100%;
            margin: 0 auto; padding: 25px;
            display: flex; flex-direction: column; gap: 16px;
            position: relative; z-index: 10;
        }

        /* ── TOP SCOREBOARD ── */
        .top-scoreboard {
            position: relative;
            display: flex; justify-content: space-between; align-items: center;
            background: var(--panel-bg); border: 1px solid var(--panel-border);
            border-radius: 16px; padding: 14px 40px;
            box-shadow: 0 15px 50px rgba(0,0,0,0.6); backdrop-filter: blur(15px);
        }
        .top-scoreboard::before, .top-scoreboard::after {
            content: ''; position: absolute; top: -1px; width: 25%; height: 2px;
        }
        .top-scoreboard::before { left: 10%; background: linear-gradient(90deg, transparent, var(--blue-glow), transparent); }
        .top-scoreboard::after  { right: 10%; background: linear-gradient(90deg, transparent, var(--red-glow), transparent); }
        .team-block { display: flex; flex-direction: column; flex: 1; }
        .team-block.blue { align-items: flex-end; text-align: right; }
        .team-block.red  { align-items: flex-start; text-align: left; }
        .team-name   { font-size: 13px; color: var(--text-muted); font-weight: 500; letter-spacing: 2px; margin-bottom: 2px; }
        .player-name { font-size: 22px; font-weight: 900; color: var(--text-accent); letter-spacing: 1px; text-transform: uppercase; }
        .team-block.blue .player-name { text-shadow: 0 0 15px rgba(56,189,248,0.4); }
        .team-block.red  .player-name { text-shadow: 0 0 15px rgba(244,63,94,0.4); }
        .score-center { display: flex; align-items: center; justify-content: center; gap: 25px; min-width: 240px; }
        .score-num { font-size: 55px; font-weight: 700; font-family: 'Roboto Mono', monospace; line-height: 1; }
        .score-num.blue { color: var(--text-accent); text-shadow: 0 0 20px rgba(56,189,248,0.8); }
        .score-num.red  { color: var(--text-accent); text-shadow: 0 0 20px rgba(244,63,94,0.8); }
        .match-info { display: flex; flex-direction: column; align-items: center; gap: 6px; }
        .vs-badge { background: rgba(15,23,42,0.9); border: 1px solid #475569; border-radius: 8px; padding: 6px 16px; font-size: 18px; color: var(--text-accent); font-weight: 900; }
        .set-status { background: #eab308; color: #0f172a; padding: 3px 12px; border-radius: 4px; font-size: 11px; font-weight: 700; letter-spacing: 1.5px; }

        .main-stage { display: flex; gap: 20px; flex-grow: 1; height: 0; min-height: 0; }

        /* ── MAP ── */
        .map-section {
            height: 100%; aspect-ratio: 1/1; flex-shrink: 0;
            background-color: rgba(10,14,23,0.95);
            border: 1px solid var(--panel-border); border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 15px 40px rgba(0,0,0,0.6), inset 0 0 50px rgba(0,0,0,0.8);
            padding: 15px;
        }
        .minimap-container {
            width: 100%; height: 100%; background-color: #050810;
            background-image:
                linear-gradient(rgba(255,255,255,0.03) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255,255,255,0.03) 1px, transparent 1px);
            background-size: 5% 5%;
            border-radius: 8px; position: relative; overflow: hidden;
            border: 1px solid rgba(255,255,255,0.05);
        }
        #entityLayer { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 10; }
        #territoryCanvas { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 2; pointer-events: none; border-radius: 8px; }
        .entity { position: absolute; transform: translate(-50%,-50%); display: flex; justify-content: center; align-items: center; }
        .building { width: 50px; height: 50px; border: 2px solid rgba(255,255,255,0.8); border-radius: 6px; }
        .building.blue { background-color: rgba(56,189,248,0.2); border-color: var(--blue-glow); box-shadow: 0 0 15px rgba(56,189,248,0.5); }
        .building.red  { background-color: rgba(244,63,94,0.2);  border-color: var(--red-glow);  box-shadow: 0 0 15px rgba(244,63,94,0.5); }
        .building.dead { opacity: 0.15; filter: grayscale(1); border-color: #333; box-shadow: none; }
        .mini-bars { position: absolute; bottom: -18px; left: 50%; transform: translateX(-50%); width: 46px; display: flex; flex-direction: column; gap: 2px; z-index: 20; }
        .mini-bar { height: 3px; border-radius: 2px; overflow: hidden; background: rgba(255,255,255,0.1); }
        .mini-bar-fill { height: 100%; border-radius: 2px; transition: width 0.4s cubic-bezier(0.4,0,0.2,1); }
        .mini-hp-fill.blue { background: #38bdf8; } .mini-hp-fill.red { background: #f43f5e; }
        .mini-atb-fill { background: #eab308; }
        .mini-name { font-size: 8px; color: rgba(255,255,255,0.7); text-align: center; white-space: nowrap; font-weight: 700; letter-spacing: 0.5px; margin-top: 1px; }
        #svgOverlay { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 15; pointer-events: none; }

        /* ── FX: 폭발 ── */
        .explosion-container { position: absolute; transform: translate(-50%,-50%); z-index: 25; pointer-events: none; width: 80px; height: 80px; }
        .explosion-ring { position: absolute; top: 50%; left: 50%; transform: translate(-50%,-50%) scale(0); width: 100%; height: 100%; border-radius: 50%; border: 3px solid rgba(255,200,50,0.9); animation: explosionRing 0.8s ease-out forwards; }
        .explosion-ring:nth-child(2) { animation-delay: 0.1s; border-color: rgba(255,120,30,0.7); }
        .explosion-ring:nth-child(3) { animation-delay: 0.2s; border-color: rgba(255,60,60,0.5); width: 130%; height: 130%; }
        @keyframes explosionRing { 0%{transform:translate(-50%,-50%) scale(0);opacity:1} 60%{opacity:1} 100%{transform:translate(-50%,-50%) scale(1.8);opacity:0} }
        .explosion-flash { position: absolute; top: 50%; left: 50%; transform: translate(-50%,-50%) scale(0); width: 40px; height: 40px; border-radius: 50%; background: radial-gradient(circle, #fff 0%, rgba(255,200,50,0.9) 30%, rgba(255,80,20,0.6) 60%, transparent 100%); animation: explosionFlash 0.5s ease-out forwards; }
        @keyframes explosionFlash { 0%{transform:translate(-50%,-50%) scale(0);opacity:1} 30%{transform:translate(-50%,-50%) scale(2.5);opacity:1} 100%{transform:translate(-50%,-50%) scale(3.5);opacity:0} }
        .explosion-spark { position: absolute; top: 50%; left: 50%; width: 4px; height: 4px; border-radius: 50%; background: #ffd700; animation: sparkFly 0.6s ease-out forwards; }
        @keyframes sparkFly { 0%{transform:translate(-50%,-50%) translate(0,0) scale(1);opacity:1} 100%{transform:translate(-50%,-50%) translate(var(--sx),var(--sy)) scale(0);opacity:0} }
        .explosion-text { position: absolute; top: 50%; left: 50%; transform: translate(-50%,-50%); font-family: 'Roboto Mono', monospace; font-size: 14px; font-weight: 900; color: #fff; text-shadow: 0 0 10px #f59e0b, 0 0 20px #f59e0b; animation: explosionTextPop 0.8s ease-out forwards; white-space: nowrap; }
        @keyframes explosionTextPop { 0%{transform:translate(-50%,-50%) scale(0.3) translateY(0);opacity:0} 20%{transform:translate(-50%,-50%) scale(1.3) translateY(-5px);opacity:1} 50%{transform:translate(-50%,-50%) scale(1) translateY(-15px);opacity:1} 100%{transform:translate(-50%,-50%) scale(0.8) translateY(-30px);opacity:0} }

        /* ── FX: 방패 ── */
        .shield-container { position: absolute; transform: translate(-50%,-50%); z-index: 30; pointer-events: none; display: flex; flex-direction: column; align-items: center; gap: 4px; }
        .shield-icon { width: 90px; height: 90px; display: flex; justify-content: center; align-items: center; font-size: 55px; color: rgba(56,189,248,0.95); filter: drop-shadow(0 0 18px rgba(56,189,248,0.8)); animation: shieldAppear 0.35s cubic-bezier(0.34,1.56,0.64,1) forwards; }
        .shield-icon.red-shield { color: rgba(244,63,94,0.95); filter: drop-shadow(0 0 18px rgba(244,63,94,0.8)); }
        @keyframes shieldAppear { 0%{transform:scale(0) rotate(-15deg);opacity:0} 60%{transform:scale(1.3) rotate(5deg);opacity:1} 100%{transform:scale(1) rotate(0);opacity:1} }
        .shield-ripple { position: absolute; top: 50%; left: 50%; transform: translate(-50%,-50%) scale(0); width: 110px; height: 110px; border-radius: 50%; border: 2px solid rgba(56,189,248,0.6); animation: shieldRipple 0.8s ease-out forwards; }
        .shield-ripple.red-shield { border-color: rgba(244,63,94,0.6); }
        .shield-ripple:nth-child(2) { animation-delay: 0.15s; } .shield-ripple:nth-child(3) { animation-delay: 0.3s; width: 140px; height: 140px; }
        @keyframes shieldRipple { 0%{transform:translate(-50%,-50%) scale(0.5);opacity:1} 100%{transform:translate(-50%,-50%) scale(2);opacity:0} }
        .shield-label { font-family: 'Roboto Mono', monospace; font-size: 14px; font-weight: 900; letter-spacing: 3px; color: rgba(56,189,248,0.95); text-shadow: 0 0 10px rgba(56,189,248,0.6); animation: shieldLabelPop 0.5s ease-out 0.3s both; }
        .shield-container.red-team .shield-label { color: rgba(244,63,94,0.95); text-shadow: 0 0 8px rgba(244,63,94,0.5); }
        @keyframes shieldLabelPop { 0%{opacity:0;transform:translateY(5px)} 100%{opacity:1;transform:translateY(0)} }
        .shield-fadeout { animation: shieldFadeOut 0.5s ease-in forwards; }
        @keyframes shieldFadeOut { 0%{opacity:1} 100%{opacity:0;transform:translate(-50%,-50%) scale(0.7)} }

        /* ── FX: 에어 스트라이크 그림자 ── */
        .airstrike-shadow { position: absolute; z-index: 12; pointer-events: none; width: 30px; height: 12px; border-radius: 50%; background: radial-gradient(ellipse, rgba(0,0,0,0.5) 0%, transparent 70%); transform: translate(-50%,-50%); animation: shadowPulse 0.6s ease-in-out infinite alternate; }
        @keyframes shadowPulse { 0%{transform:translate(-50%,-50%) scale(1);opacity:0.5} 100%{transform:translate(-50%,-50%) scale(0.7);opacity:0.3} }

        /* ── 재생 진행 바 ── */
        .replay-progress-wrap {
            position: absolute; bottom: 8px; left: 8px; right: 8px;
            height: 4px; background: rgba(255,255,255,0.06);
            border-radius: 2px; z-index: 50; overflow: hidden;
        }
        .replay-progress-fill {
            height: 100%; background: linear-gradient(90deg, #38bdf8, #eab308);
            border-radius: 2px; transition: width 0.3s;
            width: 0%;
        }

        /* ── RIGHT SECTION ── */
        .right-section { flex-grow: 1; display: flex; flex-direction: column; gap: 10px; height: 100%; overflow: hidden; }
        .squad-panel { background: var(--panel-bg); border: 1px solid var(--panel-border); border-radius: 12px; padding: 12px 16px; box-shadow: 0 10px 30px rgba(0,0,0,0.5); backdrop-filter: blur(10px); }
        .squad-panel-header { font-size: 10px; font-weight: 700; letter-spacing: 2px; color: var(--text-muted); margin-bottom: 8px; text-transform: uppercase; }
        .squad-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
        .squad-team-col { display: flex; flex-direction: column; gap: 6px; }
        .fighter-card { display: flex; align-items: center; gap: 8px; padding: 8px 10px; border-radius: 8px; background: rgba(255,255,255,0.02); border: 1px solid rgba(255,255,255,0.04); transition: all 0.3s; }
        .fighter-card.blue-card { border-left: 3px solid rgba(56,189,248,0.6); }
        .fighter-card.red-card  { border-left: 3px solid rgba(244,63,94,0.6); }
        .fighter-card.dead-card { opacity: 0.25; filter: grayscale(0.9); }
        .fighter-card.acting    { border-color: #eab308; box-shadow: 0 0 14px rgba(234,179,8,0.4); background: rgba(234,179,8,0.04); }
        .fc-info { flex: 1; min-width: 0; }
        .fc-name { font-size: 12px; font-weight: 800; color: var(--text-accent); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .fc-hp-bar { height: 6px; border-radius: 3px; background: rgba(255,255,255,0.06); margin-top: 3px; overflow: hidden; }
        .fc-hp-fill { height: 100%; border-radius: 3px; transition: width 0.4s cubic-bezier(0.4,0,0.2,1); }
        .fc-hp-fill.blue { background: linear-gradient(90deg, #38bdf8, #7dd3fc); }
        .fc-hp-fill.red  { background: linear-gradient(90deg, #f43f5e, #fb7185); }
        .fc-stats { display: flex; gap: 6px; margin-top: 3px; }
        .fc-stat { font-family: 'Roboto Mono', monospace; font-size: 9px; color: var(--text-muted); }
        .fc-stat b { color: var(--text-accent); }
        .fc-atb-bar { height: 3px; border-radius: 2px; background: rgba(255,255,255,0.04); margin-top: 2px; overflow: hidden; }
        .fc-atb-fill { height: 100%; border-radius: 2px; background: #eab308; transition: width 0.2s; }

        /* MOMENTUM */
        .momentum-panel { background: var(--panel-bg); border: 1px solid var(--panel-border); border-radius: 10px; padding: 10px 16px; backdrop-filter: blur(10px); }
        .momentum-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; }
        .momentum-label { font-size: 10px; font-weight: 700; letter-spacing: 2px; color: var(--text-muted); text-transform: uppercase; }
        .momentum-hp { font-family: 'Roboto Mono', monospace; font-size: 11px; font-weight: 700; }
        .momentum-hp.blue { color: rgba(56,189,248,0.9); } .momentum-hp.red { color: rgba(244,63,94,0.9); }
        .tug-bar { height: 14px; border-radius: 7px; background: rgba(255,255,255,0.05); overflow: hidden; display: flex; position: relative; border: 1px solid rgba(255,255,255,0.06); }
        .tug-blue { background: linear-gradient(90deg, rgba(56,189,248,0.3), rgba(56,189,248,0.8)); transition: width 0.5s cubic-bezier(0.4,0,0.2,1); }
        .tug-red  { background: linear-gradient(90deg, rgba(244,63,94,0.8), rgba(244,63,94,0.3)); transition: width 0.5s cubic-bezier(0.4,0,0.2,1); }
        .tug-center-mark { position: absolute; left: 50%; top: 0; bottom: 0; width: 2px; background: rgba(255,255,255,0.15); transform: translateX(-50%); z-index: 2; }

        /* COMBAT LOG */
        .log-panel { flex-grow: 1; background: rgba(16,22,36,0.4); border: 1px solid rgba(255,255,255,0.05); border-radius: 10px; padding: 12px; display: flex; flex-direction: column; overflow: hidden; }
        .log-header { font-size: 10px; font-weight: 700; letter-spacing: 2px; color: var(--text-muted); margin-bottom: 6px; text-transform: uppercase; }
        .log-container { flex-grow: 1; overflow-y: auto; display: flex; flex-direction: column; gap: 4px; padding-right: 10px; -webkit-mask-image: linear-gradient(to bottom, transparent, black 3%, black 97%, transparent); mask-image: linear-gradient(to bottom, transparent, black 3%, black 97%, transparent); }
        .log-container::-webkit-scrollbar { width: 4px; }
        .log-container::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.1); border-radius: 2px; }
        .log-line { padding: 5px 8px; font-size: 12px; line-height: 1.5; font-weight: 500; color: var(--log-text); opacity: 0; transform: translateY(8px); animation: slideIn 0.25s ease-out forwards; word-break: keep-all; border-radius: 4px; }
        @keyframes slideIn { to { opacity: 1; transform: translateY(0); } }
        .log-line.blue { background: rgba(56,189,248,0.05); }
        .log-line.blue strong { color: var(--blue-glow); font-weight: 800; }
        .log-line.red { background: rgba(244,63,94,0.05); }
        .log-line.red strong { color: var(--red-glow); font-weight: 800; }
        .log-line.neutral { color: var(--text-muted); font-weight: 400; font-size: 11px; }
        .log-line.kill { background: rgba(234,179,8,0.08); color: #fbbf24; font-weight: 700; }
        .log-line.system { background: rgba(168,85,247,0.08); color: #c084fc; font-size: 11px; }

        /* CONTROL */
        .control-panel { background: var(--panel-bg); border-radius: 10px; padding: 12px 16px; border: 1px solid var(--panel-border); backdrop-filter: blur(10px); }
        .battle-status-text { text-align: center; font-family: 'Roboto Mono', monospace; font-size: 11px; color: var(--text-muted); letter-spacing: 1px; margin-bottom: 8px; }
        .btn-action-wrapper { display: none; }
        .btn-action { width: 100%; background: rgba(10,14,23,0.8); color: var(--blue-glow); border: 2px solid var(--blue-glow); padding: 12px; font-size: 17px; font-weight: 800; border-radius: 8px; cursor: pointer; transition: all 0.2s; letter-spacing: 2px; text-transform: uppercase; }
        .btn-action:hover { background: var(--blue-glow); color: #0a0e17; box-shadow: 0 0 25px rgba(56,189,248,0.5); }
        .btn-final { border-color: #eab308; color: #eab308; }
        .btn-final:hover { background: #eab308; color: #0a0e17; box-shadow: 0 0 25px rgba(234,179,8,0.5); }

        /* 재생 속도 컨트롤 */
        .speed-control { display: flex; align-items: center; gap: 8px; margin-bottom: 8px; justify-content: center; }
        .speed-label { font-size: 10px; color: var(--text-muted); letter-spacing: 1px; }
        .speed-btn { background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); color: var(--text-muted); padding: 3px 10px; border-radius: 4px; cursor: pointer; font-size: 11px; transition: all 0.15s; }
        .speed-btn.active { background: rgba(56,189,248,0.15); border-color: rgba(56,189,248,0.4); color: #38bdf8; }
        .speed-btn:hover { border-color: rgba(255,255,255,0.2); color: var(--text-accent); }
    </style>
</head>
<body>

<%-- ★ 서버에서 넘어온 데이터 --%>
<script type="application/json" id="battleDataRaw">${battleDataJson}</script>
<script type="application/json" id="eventLogRaw">${eventLogJson}</script>

<div class="hud-wrapper">
    <header class="top-scoreboard">
        <div class="team-block blue">
            <div class="team-name">${not empty myTeamName ? myTeamName : 'BLUE SQUADRON'}</div>
            <div class="player-name">BLUE TEAM</div>
        </div>
        <div class="score-center">
            <div class="score-num blue" id="userWins">${myWins}</div>
            <div class="match-info">
                <div class="vs-badge">3 vs 3</div>
                <div class="set-status">ATB BATTLE</div>
            </div>
            <div class="score-num red" id="aiWins">${aiWins}</div>
        </div>
        <div class="team-block red">
            <div class="team-name">${not empty opponentTeamName ? opponentTeamName : 'RED SQUADRON'}</div>
            <div class="player-name">RED TEAM</div>
        </div>
    </header>

    <main class="main-stage">
        <section class="map-section">
            <div class="minimap-container" id="mapContainer">
                <canvas id="territoryCanvas"></canvas>
                <div id="entityLayer"></div>
                <svg id="svgOverlay" viewBox="0 0 100 100" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg">
                    <defs>
                        <filter id="arrowGlow" x="-50%" y="-50%" width="200%" height="200%">
                            <feGaussianBlur stdDeviation="1.2" result="blur"/>
                            <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
                        </filter>
                    </defs>
                </svg>
                <div class="replay-progress-wrap">
                    <div class="replay-progress-fill" id="replayProgress"></div>
                </div>
            </div>
        </section>

        <section class="right-section">
            <div class="squad-panel">
                <div class="squad-panel-header"><i class="fa-solid fa-users"></i> SQUAD STATUS</div>
                <div class="squad-grid">
                    <div class="squad-team-col" id="blueSquadCol"></div>
                    <div class="squad-team-col" id="redSquadCol"></div>
                </div>
            </div>

            <div class="momentum-panel">
                <div class="momentum-header">
                    <span class="momentum-hp blue" id="blueHpTotal">0</span>
                    <span class="momentum-label">BATTLE MOMENTUM</span>
                    <span class="momentum-hp red" id="redHpTotal">0</span>
                </div>
                <div class="tug-bar">
                    <div class="tug-blue" id="tugBlue" style="width:50%"></div>
                    <div class="tug-red"  id="tugRed"  style="width:50%"></div>
                    <div class="tug-center-mark"></div>
                </div>
            </div>

            <div class="log-panel">
                <div class="log-header"><i class="fa-solid fa-scroll"></i> COMBAT LOG</div>
                <div class="log-container" id="logContainer"></div>
            </div>

            <div class="control-panel">
                <div class="speed-control">
                    <span class="speed-label">SPEED</span>
                    <button class="speed-btn" onclick="setSpeed(2000)">0.5×</button>
                    <button class="speed-btn active" id="spd1x" onclick="setSpeed(900)">1×</button>
                    <button class="speed-btn" onclick="setSpeed(450)">2×</button>
                    <button class="speed-btn" onclick="setSpeed(150)">4×</button>
                </div>
                <div class="battle-status-text" id="battleStatusText">LOADING BATTLE REPLAY...</div>
                <div class="btn-action-wrapper" id="actionArea">
                    <button id="btnNextSet"    class="btn-action"             onclick="nextSet()">ENGAGE NEXT SET ▶</button>
                    <button id="btnFinalResult" class="btn-action btn-final" style="display:none" onclick="showFinalResult()">VIEW FINAL REPORT 🏆</button>
                </div>
            </div>
        </section>
    </main>
</div>

<script>
// ══════════════════════════════════════════════════════════════════════
// 0. 전역 상태
// ══════════════════════════════════════════════════════════════════════
let fighters = [];
let eventLog  = [];
let replayDelay = 900;       // ms — 기본 1× 속도
let replayRunning = false;

try { fighters = JSON.parse(document.getElementById('battleDataRaw').textContent); } catch(e){ console.error('battleData parse error', e); }
try { eventLog  = JSON.parse(document.getElementById('eventLogRaw').textContent);  } catch(e){ console.error('eventLog parse error', e); }

const blueTeam     = fighters.filter(f => f.team === 'blue');
const redTeam      = fighters.filter(f => f.team === 'red');
const entityLayer  = document.getElementById('entityLayer');
const svgOverlay   = document.getElementById('svgOverlay');
const logContainer = document.getElementById('logContainer');

// 현재 HP 상태 (리플레이 중 갱신)
const hpState = {};
const atbState = {};
fighters.forEach(f => {
    hpState[f.id]  = f.hp;
    atbState[f.id] = 0;
});

// ══════════════════════════════════════════════════════════════════════
// 1. 재생 속도 설정
// ══════════════════════════════════════════════════════════════════════
function setSpeed(ms) {
    replayDelay = ms;
    document.querySelectorAll('.speed-btn').forEach(b => b.classList.remove('active'));
    const map = {2000:'0.5×', 900:'1×', 450:'2×', 150:'4×'};
    document.querySelectorAll('.speed-btn').forEach(b => {
        if (b.textContent === (map[ms] || '1×')) b.classList.add('active');
    });
}

// ══════════════════════════════════════════════════════════════════════
// 2. 맵 엔티티 배치 (기존 함수 100% 유지)
// ══════════════════════════════════════════════════════════════════════
function setupFighterEntities() {
    fighters.forEach(f => {
        const el = document.createElement('div');
        el.id = 'base_' + f.id;
        el.className = 'entity building ' + f.team;
        el.style.left = f.x + '%';
        el.style.top  = f.y + '%';
        entityLayer.appendChild(el);

        const bars = document.createElement('div');
        bars.className = 'mini-bars';

        const hpBar = document.createElement('div');
        hpBar.className = 'mini-bar';
        const hpFill = document.createElement('div');
        hpFill.className = 'mini-bar-fill mini-hp-fill ' + f.team;
        hpFill.id = 'miniHp_' + f.id;
        hpFill.style.width = '100%';
        hpBar.appendChild(hpFill);
        bars.appendChild(hpBar);

        const atbBar = document.createElement('div');
        atbBar.className = 'mini-bar';
        const atbFill = document.createElement('div');
        atbFill.className = 'mini-bar-fill mini-atb-fill';
        atbFill.id = 'miniAtb_' + f.id;
        atbFill.style.width = '0%';
        atbBar.appendChild(atbFill);
        bars.appendChild(atbBar);

        const nameTag = document.createElement('div');
        nameTag.className = 'mini-name';
        nameTag.textContent = f.name;
        bars.appendChild(nameTag);

        el.appendChild(bars);
    });
}

// ══════════════════════════════════════════════════════════════════════
// 3. SQUAD STATUS 카드 렌더링 (기존 함수 100% 유지)
// ══════════════════════════════════════════════════════════════════════
function renderSquadCards() {
    const blueCol = document.getElementById('blueSquadCol');
    const redCol  = document.getElementById('redSquadCol');
    blueCol.innerHTML = '';
    redCol.innerHTML  = '';

    function makeCard(f) {
        const card = document.createElement('div');
        card.className = 'fighter-card ' + f.team + '-card';
        card.id = 'card_' + f.id;
        const hpPct = f.maxHp > 0 ? Math.max(0, f.hp / f.maxHp * 100) : 0;
        card.innerHTML =
            '<div class="fc-info">' +
                '<div class="fc-name">' + f.name + '</div>' +
                '<div class="fc-hp-bar"><div class="fc-hp-fill ' + f.team + '" id="cardHp_' + f.id + '" style="width:' + hpPct + '%"></div></div>' +
                '<div class="fc-stats">' +
                    '<span class="fc-stat">HP <b id="cardHpVal_' + f.id + '">' + f.hp + '</b></span>' +
                    '<span class="fc-stat">ATK <b>' + f.atk + '</b></span>' +
                    '<span class="fc-stat">DEF <b>' + f.def + '</b></span>' +
                    '<span class="fc-stat">SPD <b>' + f.spd + '</b></span>' +
                '</div>' +
                '<div class="fc-atb-bar"><div class="fc-atb-fill" id="cardAtb_' + f.id + '" style="width:0%"></div></div>' +
            '</div>';
        return card;
    }

    blueTeam.forEach(f => blueCol.appendChild(makeCard(f)));
    redTeam.forEach(f  => redCol.appendChild(makeCard(f)));
}

// ══════════════════════════════════════════════════════════════════════
// 4. 모멘텀 / UI 동기화 (기존 함수 100% 유지)
// ══════════════════════════════════════════════════════════════════════
function updateMomentum() {
    let blueTotal = 0, redTotal = 0;
    fighters.forEach(f => {
        const hp = hpState[f.id] || 0;
        if (f.team === 'blue') blueTotal += Math.max(0, hp);
        else                   redTotal  += Math.max(0, hp);
    });
    const total = blueTotal + redTotal;
    const bluePct = total > 0 ? blueTotal / total * 100 : 50;
    document.getElementById('tugBlue').style.width = bluePct + '%';
    document.getElementById('tugRed').style.width  = (100 - bluePct) + '%';
    document.getElementById('blueHpTotal').textContent = blueTotal;
    document.getElementById('redHpTotal').textContent  = redTotal;
}

function syncUIFromState() {
    fighters.forEach(f => {
        const hp    = hpState[f.id]  !== undefined ? hpState[f.id]  : f.hp;
        const atb   = atbState[f.id] !== undefined ? atbState[f.id] : 0;
        const hpPct = f.maxHp > 0 ? Math.max(0, hp / f.maxHp * 100) : 0;
        const atbPct = Math.min(100, Math.max(0, atb));
        const isDead = hp <= 0;

        const cardHp    = document.getElementById('cardHp_'    + f.id);
        const cardHpVal = document.getElementById('cardHpVal_' + f.id);
        const cardAtb   = document.getElementById('cardAtb_'   + f.id);
        const card      = document.getElementById('card_'      + f.id);
        if (cardHp)    cardHp.style.width    = hpPct + '%';
        if (cardHpVal) cardHpVal.textContent = Math.max(0, Math.floor(hp));
        if (cardAtb)   cardAtb.style.width   = atbPct + '%';
        if (card)      card.classList.toggle('dead-card', isDead);

        const miniHp  = document.getElementById('miniHp_'  + f.id);
        const miniAtb = document.getElementById('miniAtb_' + f.id);
        if (miniHp)  miniHp.style.width  = hpPct + '%';
        if (miniAtb) miniAtb.style.width = atbPct + '%';

        const base = document.getElementById('base_' + f.id);
        if (base) base.classList.toggle('dead', isDead);
    });
    updateMomentum();
}

// ── ATB 스냅샷 반영 ──
function applyAtbSnapshot(snapshotJson) {
    if (!snapshotJson) return;
    try {
        const snap = JSON.parse(snapshotJson);
        snap.forEach(s => {
            atbState[s.id] = s.atb;
            hpState[s.id]  = s.hp;
        });
    } catch(e) {}
}

// ══════════════════════════════════════════════════════════════════════
// 5. Combat Log
// ══════════════════════════════════════════════════════════════════════
function addLog(html, type) {
    const el = document.createElement('div');
    el.className = 'log-line ' + (type || 'neutral');
    el.innerHTML = html;
    logContainer.appendChild(el);
    logContainer.scrollTop = logContainer.scrollHeight;
}

// ══════════════════════════════════════════════════════════════════════
// 6. ★ 기존 FX 함수 100% 재활용 (변경 없음)
// ══════════════════════════════════════════════════════════════════════
let _mobileInfluence = [], _combatEvents = [], _arrowTrails = [];

function drawTacticalArrow(x1,y1,x2,y2,team,options) {
    options=options||{};
    const blocked=options.blocked||false, onArrival=options.onArrival||null;
    const stopRatio=blocked?0.78:0.95;
    const color=team==='blue'?'rgba(56,189,248,0.85)':'rgba(244,63,94,0.85)';
    const glowColor=team==='blue'?'rgba(56,189,248,0.15)':'rgba(244,63,94,0.15)';
    const fillColor=team==='blue'?'#38bdf8':'#f43f5e';
    const pathD='M '+x1+' '+y1+' L '+x2+' '+y2;
    const bgPath=document.createElementNS('http://www.w3.org/2000/svg','path');
    bgPath.setAttribute('d',pathD);bgPath.setAttribute('stroke',glowColor);
    bgPath.setAttribute('stroke-width','2');bgPath.setAttribute('fill','none');
    svgOverlay.appendChild(bgPath);
    const bgLen=bgPath.getTotalLength();
    bgPath.style.strokeDasharray=bgLen;bgPath.style.strokeDashoffset=bgLen;
    const mainPath=document.createElementNS('http://www.w3.org/2000/svg','path');
    mainPath.setAttribute('d',pathD);mainPath.setAttribute('stroke',color);
    mainPath.setAttribute('stroke-width','0.6');mainPath.setAttribute('fill','none');
    mainPath.setAttribute('stroke-dasharray','2 1.5');
    svgOverlay.appendChild(mainPath);
    const totalLen=mainPath.getTotalLength();
    mainPath.style.strokeDasharray=totalLen;mainPath.style.strokeDashoffset=totalLen;
    const arrowHead=document.createElementNS('http://www.w3.org/2000/svg','polygon');
    arrowHead.setAttribute('fill',fillColor);arrowHead.setAttribute('opacity','0');
    arrowHead.setAttribute('filter','url(#arrowGlow)');svgOverlay.appendChild(arrowHead);
    function updateArrowHead(len){const tp=mainPath.getPointAtLength(len),bp=mainPath.getPointAtLength(Math.max(0,len-0.5));const ang=Math.atan2(tp.y-bp.y,tp.x-bp.x),s=2.2;arrowHead.setAttribute('points',(tp.x+Math.cos(ang)*s)+','+(tp.y+Math.sin(ang)*s)+' '+(tp.x+Math.cos(ang+2.5)*s*0.7)+','+(tp.y+Math.sin(ang+2.5)*s*0.7)+' '+(tp.x+Math.cos(ang-2.5)*s*0.7)+','+(tp.y+Math.sin(ang-2.5)*s*0.7));}
    const drawDur=blocked?1100:1300,startT=performance.now(),allEls=[bgPath,mainPath,arrowHead];
    const arrowId='arr_'+Date.now()+'_'+Math.random();
    const mNode={x:x1*6,y:y1*6,team:team,power:1.2,id:arrowId,mobile:true};
    _mobileInfluence.push(mNode);let lastTrail=0;
    function animateArrow(now){
        const t=Math.min((now-startT)/drawDur,1),ease=t<0.5?4*t*t*t:1-Math.pow(-2*t+2,3)/2,drawTo=ease*stopRatio;
        bgPath.style.strokeDashoffset=bgLen*(1-drawTo);mainPath.style.strokeDashoffset=totalLen*(1-drawTo);
        if(drawTo>0.01){arrowHead.setAttribute('opacity','1');updateArrowHead(totalLen*drawTo);const tp=mainPath.getPointAtLength(totalLen*drawTo);mNode.x=tp.x*6;mNode.y=tp.y*6;if(now-lastTrail>70){_arrowTrails.push({x:tp.x*6,y:tp.y*6,team:team,time:now});lastTrail=now;}}
        if(t<1){requestAnimationFrame(animateArrow);}else{
            _mobileInfluence=_mobileInfluence.filter(m=>m.id!==arrowId);
            if(blocked){const tp=mainPath.getPointAtLength(totalLen*stopRatio);shatterArrow(allEls);if(typeof onArrival==='function')onArrival(tp.x,tp.y);}
            else{const tp=mainPath.getPointAtLength(totalLen*stopRatio);arrowHead.setAttribute('opacity','0');showExplosion(tp.x,tp.y);if(typeof onArrival==='function')onArrival();setTimeout(()=>fadeAndRemove(allEls),800);}
        }
    }
    requestAnimationFrame(animateArrow);
}

function drawAirStrikeArrow(x1,y1,x2,y2,team,options) {
    options=options||{};
    const onArrival=options.onArrival||null;
    const color=team==='blue'?'rgba(56,189,248,0.7)':'rgba(244,63,94,0.7)';
    const fillColor=team==='blue'?'#38bdf8':'#f43f5e';
    const dx=x2-x1,dy=y2-y1,distance=Math.sqrt(dx*dx+dy*dy),mx=(x1+x2)/2;
    const peakY=Math.min(y1,y2)-(distance*0.25);
    const pathD='M '+x1+' '+y1+' Q '+mx+' '+peakY+' '+x2+' '+y2;
    const mainPath=document.createElementNS('http://www.w3.org/2000/svg','path');
    mainPath.setAttribute('d',pathD);mainPath.setAttribute('stroke',color);
    mainPath.setAttribute('stroke-width','0.5');mainPath.setAttribute('fill','none');
    mainPath.setAttribute('stroke-dasharray','1.5 2.5');mainPath.setAttribute('stroke-linecap','round');
    svgOverlay.appendChild(mainPath);
    const totalLen=mainPath.getTotalLength();
    mainPath.style.strokeDasharray=totalLen;mainPath.style.strokeDashoffset=totalLen;
    const arrowHead=document.createElementNS('http://www.w3.org/2000/svg','polygon');
    arrowHead.setAttribute('fill',fillColor);arrowHead.setAttribute('opacity','0');
    arrowHead.setAttribute('filter','url(#arrowGlow)');svgOverlay.appendChild(arrowHead);
    function updateHead(len){const tp=mainPath.getPointAtLength(len),bp=mainPath.getPointAtLength(Math.max(0,len-0.5));const ang=Math.atan2(tp.y-bp.y,tp.x-bp.x),s=2;arrowHead.setAttribute('points',(tp.x+Math.cos(ang)*s)+','+(tp.y+Math.sin(ang)*s)+' '+(tp.x+Math.cos(ang+2.5)*s*0.7)+','+(tp.y+Math.sin(ang+2.5)*s*0.7)+' '+(tp.x+Math.cos(ang-2.5)*s*0.7)+','+(tp.y+Math.sin(ang-2.5)*s*0.7));}
    const shadow=document.createElement('div');shadow.className='airstrike-shadow';
    entityLayer.appendChild(shadow);
    const drawDur=1500,startT=performance.now(),allEls=[mainPath,arrowHead];
    const arrowId='air_'+Date.now();
    const mNode={x:x1*6,y:y1*6,team:team,power:0.8,id:arrowId,mobile:true};
    _mobileInfluence.push(mNode);let lastTrail=0;
    function animateAir(now){
        const t=Math.min((now-startT)/drawDur,1),ease=t<0.5?2*t*t:1-Math.pow(-2*t+2,2)/2,drawTo=ease*0.95;
        mainPath.style.strokeDashoffset=totalLen*(1-drawTo);
        if(drawTo>0.01){
            arrowHead.setAttribute('opacity','1');updateHead(totalLen*drawTo);
            const tp=mainPath.getPointAtLength(totalLen*drawTo);
            mNode.x=tp.x*6;mNode.y=tp.y*6;
            if(now-lastTrail>70){_arrowTrails.push({x:tp.x*6,y:tp.y*6,team:team,time:now});lastTrail=now;}
            const groundX=x1+(x2-x1)*drawTo,groundY=y1+(y2-y1)*drawTo;
            shadow.style.left=groundX+'%';shadow.style.top=groundY+'%';
            const height=Math.abs(tp.y-((1-drawTo)*y1+drawTo*y2));
            shadow.style.transform='translate(-50%,-50%) scale('+Math.max(0.4,1-height*0.03)+')';
            shadow.style.opacity=String(Math.max(0.15,0.5-height*0.02));
        }
        if(t<1){requestAnimationFrame(animateAir);}else{
            _mobileInfluence=_mobileInfluence.filter(m=>m.id!==arrowId);
            shadow.remove();
            const tp=mainPath.getPointAtLength(totalLen*0.95);
            arrowHead.setAttribute('opacity','0');
            showExplosion(tp.x,tp.y,'AIR STRIKE');
            if(typeof onArrival==='function')onArrival();
            setTimeout(()=>fadeAndRemove(allEls),800);
        }
    }
    requestAnimationFrame(animateAir);
}

function fadeAndRemove(els){els.forEach(e=>{e.style.transition='opacity 0.5s ease';e.style.opacity='0';});setTimeout(()=>els.forEach(e=>e.remove()),600);}
function shatterArrow(els){let c=0;const iv=setInterval(()=>{els.forEach(e=>{e.style.opacity=(c%2===0)?'0.3':'0.7';});if(++c>5){clearInterval(iv);els.forEach(e=>{e.style.transition='opacity 0.3s';e.style.opacity='0';});setTimeout(()=>els.forEach(e=>e.remove()),400);}},60);}

function showExplosion(x,y,label){
    _combatEvents.push({x:x*6,y:y*6,type:'blackout',time:performance.now(),team:null});
    const c=document.createElement('div');c.className='explosion-container';c.style.left=x+'%';c.style.top=y+'%';
    for(let i=0;i<3;i++){const r=document.createElement('div');r.className='explosion-ring';c.appendChild(r);}
    const fl=document.createElement('div');fl.className='explosion-flash';c.appendChild(fl);
    for(let i=0;i<8;i++){const sp=document.createElement('div');sp.className='explosion-spark';const ang=(Math.PI*2/8)*i+(Math.random()*0.5-0.25),dist=25+Math.random()*20;sp.style.setProperty('--sx',(Math.cos(ang)*dist)+'px');sp.style.setProperty('--sy',(Math.sin(ang)*dist)+'px');sp.style.animationDelay=(Math.random()*0.15)+'s';c.appendChild(sp);}
    if(label){const t=document.createElement('div');t.className='explosion-text';t.textContent=label;c.appendChild(t);}
    entityLayer.appendChild(c);setTimeout(()=>c.remove(),1500);
}

function showShieldDeflect(x,y,team){
    _combatEvents.push({x:x*6,y:y*6,type:'fortify',time:performance.now(),team:team});
    const isRed=team==='red';const c=document.createElement('div');c.className='shield-container'+(isRed?' red-team':'');c.style.left=x+'%';c.style.top=y+'%';
    const ic=document.createElement('div');ic.className='shield-icon'+(isRed?' red-shield':'');ic.innerHTML='<i class="fa-solid fa-shield-halved"></i>';c.appendChild(ic);
    for(let i=0;i<3;i++){const r=document.createElement('div');r.className='shield-ripple'+(isRed?' red-shield':'');c.appendChild(r);}
    const lb=document.createElement('div');lb.className='shield-label';lb.textContent='BLOCKED';c.appendChild(lb);
    entityLayer.appendChild(c);setTimeout(()=>{c.classList.add('shield-fadeout');setTimeout(()=>c.remove(),600);},1800);
}

// ══════════════════════════════════════════════════════════════════════
// 7. 헥사곤 맵 (기존 코드 100% 유지, HP 비율 연동)
// ══════════════════════════════════════════════════════════════════════
let territoryCanvas, territoryCtx, _animFrame = null, _hexGrid = [];
const HEX_R = 14, HEX_PAD = 1.5;

function initTerritory(){
    territoryCanvas = document.getElementById('territoryCanvas');
    territoryCanvas.width = 600; territoryCanvas.height = 600;
    territoryCtx = territoryCanvas.getContext('2d');
    _buildHexGrid();
    if(_animFrame) cancelAnimationFrame(_animFrame);
    (function loop(now){ _renderHexGrid(now); _animFrame = requestAnimationFrame(loop); })(performance.now());
}
function _buildHexGrid(){
    _hexGrid=[];const w=territoryCanvas.width,h=territoryCanvas.height;
    const hexW=Math.sqrt(3)*(HEX_R+HEX_PAD),hexH=1.5*(HEX_R+HEX_PAD);
    const cols=Math.ceil(w/hexW)+1,rows=Math.ceil(h/hexH)+1;
    for(let row=-1;row<rows;row++)for(let col=-1;col<cols;col++){const x=col*hexW+(row%2===1?hexW/2:0),y=row*hexH;if(x>-HEX_R&&x<w+HEX_R&&y>-HEX_R&&y<h+HEX_R)_hexGrid.push({x,y});}
}

function _renderHexGrid(now){
    const ctx=territoryCtx,w=territoryCanvas.width,h=territoryCanvas.height;
    ctx.clearRect(0,0,w,h);
    const blueNodes=[], redNodes=[];
    fighters.forEach(f => {
        const hp = hpState[f.id] !== undefined ? hpState[f.id] : f.hp;
        const hpRatio = f.maxHp > 0 ? Math.max(0, hp) / f.maxHp : 0;
        const node = { x: f.x/100*w, y: f.y/100*h, power: hpRatio, mobile: false };
        if(f.team==='blue') blueNodes.push(node); else redNodes.push(node);
    });
    for(const m of _mobileInfluence){
        const n={x:m.x,y:m.y,power:m.power,mobile:true};
        if(m.team==='blue')blueNodes.push(n);else redNodes.push(n);
    }
    const baseRange=120, mobileRange=55;
    _combatEvents=_combatEvents.filter(ev=>now-ev.time<2000);
    _arrowTrails=_arrowTrails.filter(tr=>now-tr.time<1200);
    const tick=now*0.001,hexPath=_hexPath(HEX_R-0.5);
    ctx.strokeStyle='rgba(255,255,255,0.3)';ctx.fillStyle='rgba(255,255,255,0.06)';ctx.lineWidth=0.7;
    for(const hex of _hexGrid){ctx.beginPath();for(let i=0;i<6;i++){const px=hex.x+hexPath[i][0],py=hex.y+hexPath[i][1];i===0?ctx.moveTo(px,py):ctx.lineTo(px,py);}ctx.closePath();ctx.fill();ctx.stroke();}
    ctx.globalCompositeOperation='screen';
    for(const hex of _hexGrid){
        let blueInf=0;
        for(const n of blueNodes){if(n.power<=0)continue;const dx=hex.x-n.x,dy=hex.y-n.y,d=Math.sqrt(dx*dx+dy*dy);const range=n.mobile?mobileRange:(baseRange*n.power);if(d===0){blueInf+=n.power*1.5;continue;}if(d<range){const f2=1-(d/range);blueInf+=f2*f2*n.power*1.5;}}
        let redInf=0;
        for(const n of redNodes){if(n.power<=0)continue;const dx=hex.x-n.x,dy=hex.y-n.y,d=Math.sqrt(dx*dx+dy*dy);const range=n.mobile?mobileRange:(baseRange*n.power);if(d===0){redInf+=n.power*1.5;continue;}if(d<range){const f2=1-(d/range);redInf+=f2*f2*n.power*1.5;}}
        let nearTrailStr=0,nearTrailTeam=null;
        for(const tr of _arrowTrails){const dx=hex.x-tr.x,dy=hex.y-tr.y,d=Math.sqrt(dx*dx+dy*dy);if(d<45){const age=(now-tr.time)/1000,v=(1-d/45)*Math.max(0,1-age*0.85);if(v>nearTrailStr){nearTrailStr=v;nearTrailTeam=tr.team;}}}
        for(const m of _mobileInfluence){const dx=hex.x-m.x,dy=hex.y-m.y,d=Math.sqrt(dx*dx+dy*dy);if(d<50){const v=(1-d/50)*1.2;if(v>nearTrailStr){nearTrailStr=v;nearTrailTeam=m.team;}}}
        if(blueInf<0.02&&redInf<0.02&&nearTrailStr<0.05)continue;
        const isFrontline=(blueInf>0.15&&redInf>0.15);
        let dominant,strength;
        if(blueInf>=0.02||redInf>=0.02){dominant=blueInf>=redInf?'blue':'red';const dom=dominant==='blue'?blueInf:redInf,sub=dominant==='blue'?redInf:blueInf;const dominance=dom-sub*0.4;if(dominance<0.02&&nearTrailStr<0.05)continue;strength=Math.min(Math.max(dominance,0),1.5);}
        else{dominant=nearTrailTeam;strength=0;}
        let alpha;
        if(strength>1.0)alpha=0.35+strength*0.05;else if(strength>0.5)alpha=0.15+strength*0.2;else alpha=strength*0.3;
        alpha*=1+Math.sin(tick*2.5+hex.x*0.04+hex.y*0.06)*0.05;
        let combatMod=1,combatFlash=0;
        for(const ev of _combatEvents){const dx=hex.x-ev.x,dy=hex.y-ev.y,d=Math.sqrt(dx*dx+dy*dy),age=(now-ev.time)/1000;if(ev.type==='blackout'&&d<100){const p=1-(d/100),f2=Math.max(0,1-age*1.2);combatMod*=(1-p*f2*0.85);}if(ev.type==='fortify'&&d<90&&dominant===ev.team){const p=1-(d/90),f2=Math.max(0,1-age*0.8);combatFlash+=p*f2*0.3;}}
        alpha=alpha*combatMod+combatFlash;alpha=Math.max(0,Math.min(alpha,0.45));
        if(alpha<0.01)continue;alpha=Math.min(alpha+nearTrailStr*0.2,0.55);
        let wobX=0,wobY=0;if(nearTrailStr>0.1){const w2=nearTrailStr*2.5;wobX=Math.sin(tick*25+hex.x*0.3)*w2;wobY=Math.cos(tick*30+hex.y*0.3)*w2;}
        ctx.save();ctx.translate(hex.x+wobX,hex.y+wobY);
        if(isFrontline){const cs=Math.min(blueInf,redInf),phase=tick*22+hex.x*0.25+hex.y*0.31;const noise=Math.sin(phase)*0.5+Math.sin(phase*1.73+1.1)*0.3+Math.sin(phase*3.17+2.3)*0.2;const overloadAlpha=Math.max(0,noise)*cs*1.5;ctx.fillStyle='rgba(56,189,248,'+Math.min(alpha*0.5,0.2).toFixed(3)+')';ctx.strokeStyle='rgba(56,189,248,0.1)';ctx.lineWidth=0.5;ctx.beginPath();for(let i=0;i<6;i++){i===0?ctx.moveTo(hexPath[i][0],hexPath[i][1]):ctx.lineTo(hexPath[i][0],hexPath[i][1]);}ctx.closePath();ctx.fill();ctx.fillStyle='rgba(244,63,94,'+Math.min(alpha*0.5,0.2).toFixed(3)+')';ctx.fill();ctx.stroke();if(overloadAlpha>0.02){const isWhite=overloadAlpha>0.18;ctx.fillStyle=isWhite?'rgba(255,255,255,'+Math.min(overloadAlpha*1.2,0.5).toFixed(3)+')':'rgba(255,210,50,'+Math.min(overloadAlpha*0.9,0.3).toFixed(3)+')';ctx.beginPath();for(let i=0;i<6;i++){i===0?ctx.moveTo(hexPath[i][0],hexPath[i][1]):ctx.lineTo(hexPath[i][0],hexPath[i][1]);}ctx.closePath();ctx.fill();}}
        else{ctx.fillStyle=dominant==='blue'?'rgba(56,189,248,'+alpha.toFixed(3)+')':'rgba(244,63,94,'+alpha.toFixed(3)+')';ctx.strokeStyle=dominant==='blue'?'rgba(56,189,248,'+Math.min(alpha+0.15,0.4).toFixed(3)+')':'rgba(244,63,94,'+Math.min(alpha+0.15,0.4).toFixed(3)+')';ctx.lineWidth=0.6;ctx.beginPath();for(let i=0;i<6;i++){i===0?ctx.moveTo(hexPath[i][0],hexPath[i][1]):ctx.lineTo(hexPath[i][0],hexPath[i][1]);}ctx.closePath();ctx.fill();ctx.stroke();}
        ctx.restore();
    }
    ctx.globalCompositeOperation='source-over';
}
function _hexPath(r){const p=[];for(let i=0;i<6;i++){const a=Math.PI/180*(60*i-30);p.push([r*Math.cos(a),r*Math.sin(a)]);}return p;}

// ══════════════════════════════════════════════════════════════════════
// 8. 행동자 카드 하이라이트
// ══════════════════════════════════════════════════════════════════════
function highlightActor(id) {
    const card = document.getElementById('card_' + id);
    if (!card) return;
    card.classList.add('acting');
    setTimeout(() => card.classList.remove('acting'), replayDelay * 0.8);
}

// ══════════════════════════════════════════════════════════════════════
// 9. ★★★ 지시사항 3: 이벤트 재생기 (Playback) ★★★
// ══════════════════════════════════════════════════════════════════════

/** Promise 기반 sleep 유틸리티 */
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * playReplay(events)
 * 백엔드에서 받은 GameEvent 배열을 순서대로 순회하며
 * 기존 애니메이션 함수를 호출하고 Combat Log를 출력한다.
 * setInterval 로 게이지를 직접 계산하지 않는다.
 */
async function playReplay(events) {
    replayRunning = true;
    document.getElementById('battleStatusText').textContent = 'BATTLE REPLAYING...';
    addLog('⚔️ 3:3 ATB 배틀 시뮬레이션 재생 시작!', 'system');

    const total = events.length;

    for (let i = 0; i < total; i++) {
        if (!replayRunning) break;

        const event = events[i];

        // ── 진행률 바 업데이트 ──
        const pct = Math.min(100, Math.round((i / Math.max(total - 1, 1)) * 100));
        document.getElementById('replayProgress').style.width = pct + '%';

        // ── ATB 스냅샷 반영 (게이지 시각화) ──
        if (event.atbSnapshotJson) applyAtbSnapshot(event.atbSnapshotJson);

        // ──────────────────────────────────────────────────────────
        //  이벤트 타입별 처리
        // ──────────────────────────────────────────────────────────

        if (event.eventType === 'ATTACK') {
            // ① 행동자 카드 하이라이트
            highlightActor(event.actorId);

            // ② HP 상태 즉시 갱신
            hpState[event.targetId] = event.currentHp;

            // ③ 화살표 애니메이션 (기존 drawTacticalArrow)
            //    lethal 이면 타겟 도달 시 폭발 + 블랙아웃
            const dmgLabel = '-' + event.damage;
            drawTacticalArrow(
                event.actorX, event.actorY,
                event.targetX, event.targetY,
                event.actorTeam,
                {
                    blocked: false,
                    onArrival: () => {
                        showExplosion(event.targetX, event.targetY, dmgLabel);
                        // lethal 이면 기지 블랙아웃
                        if (event.lethal) {
                            const base = document.getElementById('base_' + event.targetId);
                            if (base) base.classList.add('dead');
                        }
                    }
                }
            );

            // ④ UI 동기화 (HP바 즉시 반영)
            syncUIFromState();

            // ⑤ Combat Log
            addLog(event.logMessage, event.logType);
        }

        else if (event.eventType === 'SHIELD') {
            highlightActor(event.actorId);
            hpState[event.targetId] = event.currentHp;

            // 화살표가 방어자 위치에서 막힘 → showShieldDeflect 호출
            drawTacticalArrow(
                event.actorX, event.actorY,
                event.targetX, event.targetY,   // targetX/Y = 방어자(interceptor) 좌표
                event.actorTeam,
                {
                    blocked: true,
                    onArrival: (tx, ty) => {
                        showShieldDeflect(tx, ty, event.targetTeam);
                    }
                }
            );

            syncUIFromState();
            addLog(event.logMessage, event.logType);
        }

        else if (event.eventType === 'COMBO') {
            highlightActor(event.actorId);
            highlightActor(event.comboPartnerId);
            hpState[event.targetId] = event.currentHp;

            const dmgLabel = 'COMBO! -' + event.damage;

            // 에어 스트라이크 (주 공격자)
            drawAirStrikeArrow(
                event.actorX, event.actorY,
                event.targetX, event.targetY,
                event.actorTeam,
                {
                    onArrival: () => {
                        showExplosion(event.targetX, event.targetY, dmgLabel);
                        if (event.lethal) {
                            const base = document.getElementById('base_' + event.targetId);
                            if (base) base.classList.add('dead');
                        }
                    }
                }
            );
            // 파트너 화살표
            drawTacticalArrow(
                event.comboPartnerX, event.comboPartnerY,
                event.targetX, event.targetY,
                event.actorTeam
            );

            syncUIFromState();
            addLog(event.logMessage, event.logType);
        }

        else if (event.eventType === 'DEATH') {
            // 기지 블랙아웃 + 헥사곤 빛 끄기
            hpState[event.actorId] = 0;
            const base = document.getElementById('base_' + event.actorId);
            if (base) base.classList.add('dead');

            // 사망 폭발 이펙트 (기지 위치 기반)
            const deadFighter = fighters.find(f => f.id === event.actorId);
            if (deadFighter) {
                showExplosion(deadFighter.x, deadFighter.y, 'K.O.');
            }

            syncUIFromState();
            addLog(event.logMessage, 'kill');

            // 사망 시 약간 더 긴 딜레이
            await sleep(replayDelay * 0.5);
        }

        else if (event.eventType === 'BATTLE_END') {
            // 진행률 100%
            document.getElementById('replayProgress').style.width = '100%';
            addLog('', 'neutral');
            addLog(event.logMessage, event.winner === 'blue' ? 'blue' : 'red');

            const statusText = event.winner === 'blue' ? 'BLUE TEAM VICTORY!' : 'RED TEAM VICTORY!';
            document.getElementById('battleStatusText').textContent = statusText;

            replayRunning = false;
            onReplayFinished(event.winner);
            return; // 루프 종료
        }

        // ── 이벤트 간 딜레이 ──
        await sleep(replayDelay);
    }

    // 이벤트 배열이 BATTLE_END 없이 끝난 경우 처리
    if (replayRunning) {
        replayRunning = false;
        document.getElementById('replayProgress').style.width = '100%';
        addLog('⚔️ 전투 종료', 'neutral');
        document.getElementById('battleStatusText').textContent = 'BATTLE COMPLETE';
        onReplayFinished(null);
    }
}

// ── 재생 완료 후 처리 ──
function onReplayFinished(winner) {
    document.getElementById('actionArea').style.display = 'block';

    const myWins = parseInt('${myWins}') || 0;
    const aiWins = parseInt('${aiWins}') || 0;
    const blueWon = (winner === 'blue');

    const projectedMy = blueWon ? myWins + 1 : myWins;
    const projectedAi = blueWon ? aiWins     : aiWins + 1;

    if (projectedMy >= 3 || projectedAi >= 3) {
        document.getElementById('btnNextSet').style.display    = 'none';
        document.getElementById('btnFinalResult').style.display = 'block';
    }
}

// ══════════════════════════════════════════════════════════════════════
// 10. 세트 종료 / 최종 결과 (기존 흐름 유지)
// ══════════════════════════════════════════════════════════════════════
function processSetFinish(isFinal) {
    // 재생이 끝난 시점의 생존 여부로 승자 판단
    const blueAlive = fighters
        .filter(f => f.team === 'blue')
        .some(f => (hpState[f.id] || 0) > 0);
    const winner = blueAlive ? 'player' : 'ai';

    const formData = new URLSearchParams();
    formData.append('level',    '${stageLevel}');
    formData.append('subLevel', '${subLevel}');
    formData.append('winner',   winner);

    fetch('${pageContext.request.contextPath}/pve/battle/finish', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: formData
    })
    .then(r => r.json())
    .then(data => {
        if (data.success) {
            if (isFinal) {
                alert(data.message);
                location.href = '${pageContext.request.contextPath}/pve/lobby';
            } else {
                location.href = '${pageContext.request.contextPath}/pve/battle/result?level=${stageLevel}&subLevel=${subLevel}';
            }
        } else {
            alert(data.message || '세트 결과 처리 중 오류가 발생했습니다.');
        }
    })
    .catch(err => { console.error(err); alert('통신 중 오류가 발생했습니다.'); });
}

function nextSet() {
    document.getElementById('btnNextSet').disabled = true;
    document.getElementById('btnNextSet').innerText = 'PROCESSING...';
    processSetFinish(false);
}
function showFinalResult() {
    document.getElementById('btnFinalResult').disabled = true;
    document.getElementById('btnFinalResult').innerText = 'PROCESSING...';
    processSetFinish(true);
}

// ══════════════════════════════════════════════════════════════════════
// 11. 초기화
// ══════════════════════════════════════════════════════════════════════
window.onload = function () {
    if (fighters.length === 0) {
        addLog('전투 데이터가 없습니다. 로비로 돌아가세요.', 'neutral');
        document.getElementById('battleStatusText').textContent = 'NO BATTLE DATA';
        return;
    }

    setupFighterEntities();
    renderSquadCards();
    syncUIFromState();
    initTerritory();

    if (eventLog.length === 0) {
        addLog('이벤트 로그가 없습니다.', 'neutral');
        document.getElementById('battleStatusText').textContent = 'NO EVENT LOG';
        return;
    }

    // 1.5초 딜레이 후 재생 시작
    document.getElementById('battleStatusText').textContent = 'PREPARING REPLAY...';
    setTimeout(() => {
        playReplay(eventLog);
    }, 1500);
};
</script>
</body>
</html>
