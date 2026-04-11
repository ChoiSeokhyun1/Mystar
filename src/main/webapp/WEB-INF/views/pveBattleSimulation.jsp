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
                linear-gradient(90deg, rgba(255,255,255,0.01) 1px, transparent 1px),
                repeating-linear-gradient(0deg, rgba(0,0,0,0.03), rgba(0,0,0,0.03) 1px, transparent 1px, transparent 2px);
            background-size: 100% 100%, 50px 50px, 50px 50px, 100% 4px;
            pointer-events: none; z-index: -1;
        }
        .hud-wrapper {
            width: 100%; max-width: 1920px; height: 100%;
            margin: 0 auto; padding: 25px;
            display: flex; flex-direction: column; gap: 20px;
            position: relative; z-index: 10;
        }

        .top-scoreboard {
            position: relative;
            display: flex; justify-content: space-between; align-items: center;
            background: var(--panel-bg); border: 1px solid var(--panel-border);
            border-radius: 16px; padding: 18px 40px;
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
        .team-name   { font-size: 14px; color: var(--text-muted); font-weight: 500; letter-spacing: 2px; margin-bottom: 4px; }
        .player-name { font-size: 28px; font-weight: 900; color: var(--text-accent); letter-spacing: 1px; text-transform: uppercase; }
        .team-block.blue .player-name { text-shadow: 0 0 15px rgba(56,189,248,0.4); }
        .team-block.red  .player-name { text-shadow: 0 0 15px rgba(244,63,94,0.4); }
        .score-center { display: flex; align-items: center; justify-content: center; gap: 25px; min-width: 280px; }
        .score-num { font-size: 65px; font-weight: 700; font-family: 'Roboto Mono', monospace; line-height: 1; }
        .score-num.blue { color: var(--text-accent); text-shadow: 0 0 20px rgba(56,189,248,0.8); }
        .score-num.red  { color: var(--text-accent); text-shadow: 0 0 20px rgba(244,63,94,0.8); }
        .match-info { display: flex; flex-direction: column; align-items: center; gap: 8px; }
        .vs-badge { background: rgba(15,23,42,0.9); border: 1px solid #475569; border-radius: 8px; padding: 8px 18px; font-size: 20px; color: var(--text-accent); font-weight: 900; }
        .set-status { background: #eab308; color: #0f172a; padding: 4px 14px; border-radius: 4px; font-size: 12px; font-weight: 700; letter-spacing: 1.5px; }

        .main-stage { display: flex; gap: 25px; flex-grow: 1; height: 0; min-height: 0; }

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
        .entity { position: absolute; transform: translate(-50%,-50%); transition: top 1s cubic-bezier(0.4,0,0.2,1), left 1s cubic-bezier(0.4,0,0.2,1); display: flex; justify-content: center; align-items: center; background-position: center; }
        .building { width: 50px; height: 50px; border: 2px solid rgba(255,255,255,0.8); border-radius: 6px; }
        .building.blue { background-color: rgba(56,189,248,0.2); border-color: var(--blue-glow); box-shadow: 0 0 15px rgba(56,189,248,0.5); }
        .building.red  { background-color: rgba(244,63,94,0.2);  border-color: var(--red-glow);  box-shadow: 0 0 15px rgba(244,63,94,0.5); }
        #svgOverlay { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 15; pointer-events: none; }

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

        .shield-container { position: absolute; transform: translate(-50%,-50%); z-index: 30; pointer-events: none; display: flex; flex-direction: column; align-items: center; gap: 4px; }
        .shield-icon { width: 90px; height: 90px; display: flex; justify-content: center; align-items: center; font-size: 55px; color: rgba(56,189,248,0.95); filter: drop-shadow(0 0 18px rgba(56,189,248,0.8)); animation: shieldAppear 0.35s cubic-bezier(0.34,1.56,0.64,1) forwards; }
        .shield-icon.red-shield { color: rgba(244,63,94,0.95); filter: drop-shadow(0 0 18px rgba(244,63,94,0.8)); }
        @keyframes shieldAppear { 0%{transform:scale(0) rotate(-15deg);opacity:0} 60%{transform:scale(1.3) rotate(5deg);opacity:1} 100%{transform:scale(1) rotate(0);opacity:1} }
        .shield-ripple { position: absolute; top: 50%; left: 50%; transform: translate(-50%,-50%) scale(0); width: 110px; height: 110px; border-radius: 50%; border: 2px solid rgba(56,189,248,0.6); animation: shieldRipple 0.8s ease-out forwards; }
        .shield-ripple.red-shield { border-color: rgba(244,63,94,0.6); }
        .shield-ripple:nth-child(2) { animation-delay: 0.15s; }
        .shield-ripple:nth-child(3) { animation-delay: 0.3s; width: 140px; height: 140px; }
        @keyframes shieldRipple { 0%{transform:translate(-50%,-50%) scale(0.5);opacity:1} 100%{transform:translate(-50%,-50%) scale(2);opacity:0} }
        .shield-label { font-family: 'Roboto Mono', monospace; font-size: 14px; font-weight: 900; letter-spacing: 3px; color: rgba(56,189,248,0.95); text-shadow: 0 0 10px rgba(56,189,248,0.6); animation: shieldLabelPop 0.5s ease-out 0.3s both; }
        .shield-container.red-team .shield-label { color: rgba(244,63,94,0.95); text-shadow: 0 0 8px rgba(244,63,94,0.5); }
        @keyframes shieldLabelPop { 0%{opacity:0;transform:translateY(5px)} 100%{opacity:1;transform:translateY(0)} }
        .shield-fadeout { animation: shieldFadeOut 0.5s ease-in forwards; }
        @keyframes shieldFadeOut { 0%{opacity:1;transform:translate(-50%,-50%) scale(1)} 100%{opacity:0;transform:translate(-50%,-50%) scale(0.7)} }

        .hologram-container { position: absolute; top: 50%; left: 50%; transform: translate(-50%,-50%); z-index: 30; pointer-events: none; display: flex; flex-direction: column; align-items: center; gap: 8px; animation: hologramFadeInOut 2.5s ease-in-out forwards; }
        @keyframes hologramFadeInOut { 0%{opacity:0;transform:translate(-50%,-50%) scale(0.5) translateY(10px)} 15%{opacity:1;transform:translate(-50%,-50%) scale(1.1) translateY(-5px)} 25%{opacity:1;transform:translate(-50%,-50%) scale(1) translateY(0)} 70%{opacity:1;transform:translate(-50%,-50%) scale(1) translateY(0)} 85%{opacity:0.5;transform:translate(-50%,-50%) scale(1.05) translateY(-3px)} 100%{opacity:0;transform:translate(-50%,-50%) scale(0.8) translateY(-15px)} }
        .hologram-icon-wrap { width: 65px; height: 65px; border: 2px solid rgba(56,189,248,0.6); border-radius: 12px; background: rgba(56,189,248,0.08); display: flex; justify-content: center; align-items: center; position: relative; overflow: hidden; box-shadow: 0 0 25px rgba(56,189,248,0.3), inset 0 0 15px rgba(56,189,248,0.1); }
        .hologram-icon-wrap::before { content: ''; position: absolute; top: -50%; left: 0; width: 100%; height: 200%; background: repeating-linear-gradient(0deg, transparent, transparent 3px, rgba(56,189,248,0.06) 3px, rgba(56,189,248,0.06) 4px); animation: scanline 2s linear infinite; }
        @keyframes scanline { 0%{transform:translateY(0)} 100%{transform:translateY(50%)} }
        .hologram-icon-wrap.red-holo { border-color: rgba(244,63,94,0.6); background: rgba(244,63,94,0.08); box-shadow: 0 0 25px rgba(244,63,94,0.3), inset 0 0 15px rgba(244,63,94,0.1); }
        .hologram-icon-wrap.red-holo::before { background: repeating-linear-gradient(0deg, transparent, transparent 3px, rgba(244,63,94,0.06) 3px, rgba(244,63,94,0.06) 4px); }
        .hologram-icon { font-size: 28px; z-index: 2; position: relative; color: rgba(56,189,248,0.9); text-shadow: 0 0 10px rgba(56,189,248,0.6); }
        .red-holo .hologram-icon { color: rgba(244,63,94,0.9); text-shadow: 0 0 10px rgba(244,63,94,0.6); }
        .hologram-label { font-family: 'Roboto Mono', monospace; font-size: 10px; font-weight: 700; letter-spacing: 2px; color: rgba(56,189,248,0.9); background: rgba(56,189,248,0.08); padding: 3px 10px; border-radius: 4px; border: 1px solid rgba(56,189,248,0.2); }
        .hologram-container.red-team .hologram-label { color: rgba(244,63,94,0.9); background: rgba(244,63,94,0.08); border-color: rgba(244,63,94,0.2); }

        /* ── 공중 그림자 (에어 스트라이크) ── */
        .airstrike-shadow {
            position: absolute; z-index: 12; pointer-events: none;
            width: 30px; height: 12px; border-radius: 50%;
            background: radial-gradient(ellipse, rgba(0,0,0,0.5) 0%, transparent 70%);
            transform: translate(-50%,-50%);
            animation: shadowPulse 0.6s ease-in-out infinite alternate;
        }
        @keyframes shadowPulse { 0%{transform:translate(-50%,-50%) scale(1);opacity:0.5} 100%{transform:translate(-50%,-50%) scale(0.7);opacity:0.3} }

        .right-section { flex-grow: 1; display: flex; flex-direction: column; gap: 16px; height: 100%; }

        .stats-panel {
            background: var(--panel-bg); border: 1px solid var(--panel-border);
            border-radius: 12px; padding: 16px 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5); backdrop-filter: blur(10px);
            display: grid; grid-template-columns: 1fr 1fr; gap: 0;
        }
        .stat-col { display: flex; flex-direction: column; gap: 10px; padding: 0 16px; }
        .stat-col.blue { border-right: 1px solid rgba(255,255,255,0.06); }
        .stat-col-header { font-size: 12px; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; margin-bottom: 2px; }
        .stat-col.blue .stat-col-header { color: rgba(56,189,248,0.7); }
        .stat-col.red  .stat-col-header { color: rgba(244,63,94,0.7); text-align: right; }
        .stat-row { display: flex; flex-direction: column; gap: 4px; }
        .stat-label-row { display: flex; justify-content: space-between; align-items: center; }
        .stat-col.red .stat-label-row { flex-direction: row-reverse; }
        .stat-label { font-size: 10px; font-weight: 600; letter-spacing: 1.5px; color: var(--text-muted); text-transform: uppercase; }
        .stat-val { font-family: 'Roboto Mono', monospace; font-size: 12px; font-weight: 700; }
        .stat-col.blue .stat-val { color: rgba(56,189,248,0.9); }
        .stat-col.red  .stat-val { color: rgba(244,63,94,0.9); }
        .stat-bar-bg { height: 8px; border-radius: 4px; overflow: hidden; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.04); position: relative; }
        .stat-bar-fill { height: 100%; border-radius: 4px; transition: width 0.5s cubic-bezier(0.34,1.56,0.64,1); position: relative; }
        .blue-growth-fill { background: linear-gradient(90deg, rgba(56,189,248,0.5), rgba(56,189,248,1)); box-shadow: 0 0 10px rgba(56,189,248,0.5); }
        .red-growth-fill { background: linear-gradient(90deg, rgba(244,63,94,1), rgba(244,63,94,0.5)); box-shadow: 0 0 10px rgba(244,63,94,0.5); float: right; }
        .stat-col.red .stat-bar-bg { direction: rtl; }
        .blue-momentum-fill { background: linear-gradient(90deg, rgba(56,189,248,0.4), rgba(56,189,248,0.9)); box-shadow: 0 0 8px rgba(56,189,248,0.4); }
        .red-momentum-fill { background: linear-gradient(90deg, rgba(244,63,94,0.9), rgba(244,63,94,0.4)); box-shadow: 0 0 8px rgba(244,63,94,0.4); float: right; }
        .multi-badge { display: flex; gap: 3px; align-items: center; margin-top: 2px; }
        .stat-col.red .multi-badge { justify-content: flex-end; }
        .multi-dot { width: 8px; height: 8px; border-radius: 2px; background: rgba(56,189,248,0.3); border: 1px solid rgba(56,189,248,0.5); transition: background 0.3s, box-shadow 0.3s; }
        .multi-dot.active { background: rgba(56,189,248,0.9); box-shadow: 0 0 6px rgba(56,189,248,0.7); }
        .stat-col.red .multi-dot { background: rgba(244,63,94,0.3); border-color: rgba(244,63,94,0.5); }
        .stat-col.red .multi-dot.active { background: rgba(244,63,94,0.9); box-shadow: 0 0 6px rgba(244,63,94,0.7); }

        .log-panel { flex-grow: 1; background: rgba(16,22,36,0.4); border: 1px solid rgba(255,255,255,0.05); border-radius: 12px; padding: 20px; display: flex; flex-direction: column; overflow: hidden; }
        .log-container { flex-grow: 1; overflow-y: auto; display: flex; flex-direction: column; gap: 10px; padding-right: 15px; -webkit-mask-image: linear-gradient(to bottom, transparent, black 5%, black 95%, transparent); mask-image: linear-gradient(to bottom, transparent, black 5%, black 95%, transparent); }
        .log-container::-webkit-scrollbar { width: 5px; }
        .log-container::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.1); border-radius: 3px; }
        .log-line { padding: 10px 12px; font-size: 17px; line-height: 1.6; font-weight: 600; color: var(--log-text); opacity: 0; transform: translateY(12px); animation: slideIn 0.3s ease-out forwards; word-break: keep-all; text-shadow: 0 1px 4px rgba(0,0,0,0.9); }
        @keyframes slideIn { to { opacity: 1; transform: translateY(0); } }
        .log-line.blue strong { color: var(--blue-glow); font-size: 19px; font-weight: 800; margin-right: 6px; }
        .log-line.red  strong { color: var(--red-glow);  font-size: 19px; font-weight: 800; margin-right: 6px; }
        .log-line.neutral { color: var(--text-muted); font-weight: 400; font-size: 15px; }

        .control-panel { background: var(--panel-bg); border-radius: 12px; padding: 18px; border: 1px solid var(--panel-border); backdrop-filter: blur(10px); }
        .progress-track { width: 100%; height: 6px; background: rgba(255,255,255,0.05); border-radius: 3px; overflow: hidden; margin-bottom: 14px; }
        #simProgressBar { height: 100%; width: 0%; background: #eab308; transition: width 0.2s; box-shadow: 0 0 10px rgba(234,179,8,0.4); }
        .btn-action-wrapper { display: none; }
        .btn-action { width: 100%; background: rgba(10,14,23,0.8); color: var(--blue-glow); border: 2px solid var(--blue-glow); padding: 14px; font-size: 19px; font-weight: 800; border-radius: 8px; cursor: pointer; transition: all 0.2s; letter-spacing: 2px; text-transform: uppercase; }
        .btn-action:hover { background: var(--blue-glow); color: #0a0e17; box-shadow: 0 0 25px rgba(56,189,248,0.5); }
        .btn-final { border-color: #eab308; color: #eab308; }
        .btn-final:hover { background: #eab308; color: #0a0e17; box-shadow: 0 0 25px rgba(234,179,8,0.5); }
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
            </div>
        </section>

        <section class="right-section">
            <div class="stats-panel">
                <div class="stat-col blue">
                    <div class="stat-col-header" id="blueStatName">${curMatchup.myPlayerName}</div>
                    <div class="stat-row">
                        <div class="stat-label-row"><span class="stat-label">성장력</span><span class="stat-val" id="blueGrowthVal">0</span></div>
                        <div class="stat-bar-bg"><div class="stat-bar-fill blue-growth-fill" id="blueGrowthFill" style="width:10%"></div></div>
                        <div class="multi-badge" id="blueMultiBadge"><div class="multi-dot" id="blueDot0"></div><div class="multi-dot" id="blueDot1"></div><div class="multi-dot" id="blueDot2"></div></div>
                    </div>
                    <div class="stat-row">
                        <div class="stat-label-row"><span class="stat-label">주도권</span><span class="stat-val" id="blueMomentumVal">0</span></div>
                        <div class="stat-bar-bg"><div class="stat-bar-fill blue-momentum-fill" id="blueMomentumFill" style="width:30%"></div></div>
                    </div>
                </div>
                <div class="stat-col red">
                    <div class="stat-col-header" id="redStatName">${curMatchup.aiPlayerName}</div>
                    <div class="stat-row">
                        <div class="stat-label-row"><span class="stat-label">성장력</span><span class="stat-val" id="redGrowthVal">0</span></div>
                        <div class="stat-bar-bg"><div class="stat-bar-fill red-growth-fill" id="redGrowthFill" style="width:10%"></div></div>
                        <div class="multi-badge" id="redMultiBadge"><div class="multi-dot" id="redDot0"></div><div class="multi-dot" id="redDot1"></div><div class="multi-dot" id="redDot2"></div></div>
                    </div>
                    <div class="stat-row">
                        <div class="stat-label-row"><span class="stat-label">주도권</span><span class="stat-val" id="redMomentumVal">0</span></div>
                        <div class="stat-bar-bg"><div class="stat-bar-fill red-momentum-fill" id="redMomentumFill" style="width:30%"></div></div>
                    </div>
                </div>
            </div>
            <div class="log-panel"><div class="log-container" id="logContainer"></div></div>
            <div class="control-panel">
                <div class="progress-track"><div id="simProgressBar"></div></div>
                <div class="btn-action-wrapper" id="actionArea">
                    <button id="btnNextSet" class="btn-action" onclick="nextSet()">ENGAGE NEXT SET ▶</button>
                    <button id="btnFinalResult" class="btn-action btn-final" style="display:none" onclick="showFinalResult()">VIEW FINAL REPORT 🏆</button>
                </div>
            </div>
        </section>
    </main>
</div>

<script>
// ── 1. 데이터 ──
const replayJsonRaw = document.getElementById('replayJsonData').textContent;
let replayData = {}; try { replayData = JSON.parse(replayJsonRaw); } catch(e) {}
const scriptLines = replayData.lines || [];
const myWinFlag   = replayData.myWin;
const myName      = replayData.myName || "${curMatchup.myPlayerName}";
const aiName      = replayData.aiName || "${curMatchup.aiPlayerName}";
const mapId       = replayData.mapId  || "${curMatchup.mapId}";
const myRace = "${curMatchup.myRace}".toUpperCase();
const aiRace = "${curMatchup.aiRace}".toUpperCase();

// ── 2. 맵 좌표 ──
let COORDS = { blue: {}, red: {} };
const entityLayer = document.getElementById('entityLayer');
let terranCommandImageUrl="", zergHatcheryImageUrl="", protossNexusImageUrl="";
function getBuildingImage(race) {
    if(race==="Z"||race==="ZERG") return zergHatcheryImageUrl;
    if(race==="P"||race==="PROTOSS") return protossNexusImageUrl;
    return terranCommandImageUrl;
}
async function loadMapData() {
    if(!mapId){setupDefaultCoords();setupEntities();startSimulation();return;}
    try {
        const url=`${pageContext.request.contextPath}/api/map/info?mapId=`+mapId;
        const res=await fetch(url); if(!res.ok) throw 0;
        const d=await res.json(); if(!d.success) throw 0;
        const mc=document.getElementById('mapContainer');
        let imgW=0,imgH=0;
        if(d.bgImageUrl){mc.style.backgroundImage="url('"+d.bgImageUrl+"')";mc.style.backgroundSize='100% 100%';try{await new Promise((r,j)=>{const img=new Image();img.onload=()=>{imgW=img.naturalWidth;imgH=img.naturalHeight;r();};img.onerror=j;img.src=d.bgImageUrl;});}catch(e){}}
        if(d.terranCommandUrl) terranCommandImageUrl=d.terranCommandUrl;
        if(d.zergHatcheryUrl) zergHatcheryImageUrl=d.zergHatcheryUrl;
        if(d.protossNexusUrl) protossNexusImageUrl=d.protossNexusUrl;
        parseMapPoints(d.points,imgW,imgH);
    } catch(e){setupDefaultCoords();}
    setupEntities(); startSimulation();
}
function parseMapPoints(points,imgW,imgH) {
    if(!points||!points.length){setupDefaultCoords();return;}
    const a={},b={};
    points.forEach(pt=>{
        const name=(pt.pointName||"").toUpperCase();
        let px=pt.pixelX,py=pt.pixelY;
        if(imgW>0&&imgH>0){px=(px/imgW)*100;py=(py/imgH)*100;}else{const d=(px>100||py>100)?10:1;px/=d;py/=d;}
        const pos={x:px,y:py};
        if(name.includes("A스타팅")||name.includes("A 스타팅")) a.main=pos;
        else if(name.includes("B스타팅")||name.includes("B 스타팅")) b.main=pos;
        else if(name.includes("A멀티2")||name.includes("A 멀티2")) a.exp2=pos;
        else if(name.includes("B멀티2")||name.includes("B 멀티2")) b.exp2=pos;
        else if(name.includes("A멀티")||name.includes("A 멀티")) a.exp1=pos;
        else if(name.includes("B멀티")||name.includes("B 멀티")) b.exp1=pos;
    });
    if(!a.rally&&a.main) a.rally={x:a.main.x+5,y:a.main.y+5};
    if(!b.rally&&b.main) b.rally={x:b.main.x-5,y:b.main.y-5};
    if(Math.random()<0.5){COORDS.blue=a;COORDS.red=b;}else{COORDS.blue=b;COORDS.red=a;}
    if(!COORDS.blue.main||!COORDS.red.main) setupDefaultCoords();
}
function setupDefaultCoords() {
    const A={main:{x:20,y:20},exp1:{x:35,y:20},exp2:null,rally:{x:35,y:35}};
    const B={main:{x:80,y:80},exp1:{x:65,y:80},exp2:null,rally:{x:65,y:65}};
    if(Math.random()<0.5){COORDS.blue=A;COORDS.red=B;}else{COORDS.blue=B;COORDS.red=A;}
}

// ── 3. 엔티티 ──
function spawnEntity(id,type,team,pos,imageUrl) {
    if(!pos) return null;
    const old=document.getElementById(id);if(old)old.remove();
    const el=document.createElement('div');el.id=id;el.className='entity '+type+' '+team;
    el.style.left=pos.x+'%';el.style.top=pos.y+'%';
    if(imageUrl){el.style.backgroundImage="url('"+imageUrl+"')";el.style.backgroundSize='contain';el.style.backgroundRepeat='no-repeat';el.style.border='none';el.style.backgroundColor='transparent';el.style.boxShadow='none';}
    entityLayer.appendChild(el);return el;
}
function setupEntities() {
    spawnEntity('blue_main','building','blue',COORDS.blue.main,getBuildingImage(myRace));
    spawnEntity('red_main','building','red',COORDS.red.main,getBuildingImage(aiRace));
    initTerritory();
}

// ── 4. 화살표 ──
const svgOverlay = document.getElementById('svgOverlay');
const ARROW_EDGE = 7;
function getArrowEdge(from,to) {
    if(!from.main||!to.main) return from.rally||from.main;
    const dx=to.main.x-from.main.x,dy=to.main.y-from.main.y,len=Math.sqrt(dx*dx+dy*dy);
    if(len<0.001) return from.main;
    return {x:from.main.x+(dx/len)*ARROW_EDGE, y:from.main.y+(dy/len)*ARROW_EDGE};
}

// ★ 직선 화살표
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

    const drawDur=blocked?1100:1300, startT=performance.now(), allEls=[bgPath,mainPath,arrowHead];
    const arrowId='arr_'+Date.now()+'_'+Math.random();
    const mNode={x:x1*6,y:y1*6,team:team,power:1.2,id:arrowId,mobile:true};
    _mobileInfluence.push(mNode); let lastTrail=0;

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

// ★ 에어 스트라이크 (모든 주요 공중 유닛 포함 및 포물선 동적 계산 적용)
function drawAirStrikeArrow(x1,y1,x2,y2,team,options) {
    options=options||{};
    const onArrival=options.onArrival||null;
    const color=team==='blue'?'rgba(56,189,248,0.7)':'rgba(244,63,94,0.7)';
    const fillColor=team==='blue'?'#38bdf8':'#f43f5e';

    const dx = x2 - x1, dy = y2 - y1;
    const distance = Math.sqrt(dx * dx + dy * dy);
    const mx = (x1 + x2) / 2;
    // 거리에 비례하여 높이(Peak) 동적 계산
    const peakY = Math.min(y1, y2) - (distance * 0.25);
    const pathD = 'M ' + x1 + ' ' + y1 + ' Q ' + mx + ' ' + peakY + ' ' + x2 + ' ' + y2;

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

    const drawDur=1500, startT=performance.now(), allEls=[mainPath,arrowHead];
    const arrowId='air_'+Date.now();
    const mNode={x:x1*6,y:y1*6,team:team,power:0.8,id:arrowId,mobile:true};
    _mobileInfluence.push(mNode); let lastTrail=0;

    function animateAir(now){
        const t=Math.min((now-startT)/drawDur,1);
        const ease=t<0.5?2*t*t:1-Math.pow(-2*t+2,2)/2;
        const drawTo=ease*0.95;

        mainPath.style.strokeDashoffset=totalLen*(1-drawTo);
        if(drawTo>0.01){
            arrowHead.setAttribute('opacity','1');
            updateHead(totalLen*drawTo);
            const tp=mainPath.getPointAtLength(totalLen*drawTo);
            mNode.x=tp.x*6;mNode.y=tp.y*6;
            if(now-lastTrail>70){_arrowTrails.push({x:tp.x*6,y:tp.y*6,team:team,time:now});lastTrail=now;}
            const groundX=x1+(x2-x1)*drawTo, groundY=y1+(y2-y1)*drawTo;
            shadow.style.left=groundX+'%';shadow.style.top=groundY+'%';
            const height=Math.abs(tp.y-((1-drawTo)*y1+drawTo*y2));
            const shadowScale=Math.max(0.4, 1-height*0.03);
            shadow.style.transform='translate(-50%,-50%) scale('+shadowScale+')';
            shadow.style.opacity=String(Math.max(0.15, 0.5-height*0.02));
        }
        if(t<1){requestAnimationFrame(animateAir);}else{
            _mobileInfluence=_mobileInfluence.filter(m=>m.id!==arrowId);
            shadow.remove();
            const tp=mainPath.getPointAtLength(totalLen*0.95);
            arrowHead.setAttribute('opacity','0');
            showExplosion(tp.x,tp.y,'AIR STRIKE');
            if(typeof onArrival==='function') onArrival();
            setTimeout(()=>fadeAndRemove(allEls),800);
        }
    }
    requestAnimationFrame(animateAir);
}

function fadeAndRemove(els){els.forEach(e=>{e.style.transition='opacity 0.5s ease';e.style.opacity='0';});setTimeout(()=>els.forEach(e=>e.remove()),600);}
function shatterArrow(els){let c=0;const iv=setInterval(()=>{els.forEach(e=>{e.style.opacity=(c%2===0)?'0.3':'0.7';});if(++c>5){clearInterval(iv);els.forEach(e=>{e.style.transition='opacity 0.3s';e.style.opacity='0';});setTimeout(()=>els.forEach(e=>e.remove()),400);}},60);}

// ── 5. FX ──
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
function showHologram(unitName,team){
    const ex=entityLayer.querySelector('.hologram-container');if(ex)ex.remove();
    const isRed=team==='red';const c=document.createElement('div');c.className='hologram-container'+(isRed?' red-team':'');
    const iw=document.createElement('div');iw.className='hologram-icon-wrap'+(isRed?' red-holo':'');
    const ic=document.createElement('div');ic.className='hologram-icon';
    const iconMap={'마린':'fa-person-rifle','메딕':'fa-suitcase-medical','탱크':'fa-truck-monster','배틀':'fa-jet-fighter','레이스':'fa-jet-fighter','발키리':'fa-shuttle-space','골리앗':'fa-robot','벌쳐':'fa-motorcycle','질럿':'fa-shield-halved','드라군':'fa-crosshairs','템플러':'fa-hat-wizard','아칸':'fa-sun','리버':'fa-bomb','캐리어':'fa-rocket','커세어':'fa-plane','옵저버':'fa-eye','저글링':'fa-bugs','히드라':'fa-dragon','뮤탈':'fa-dove','럴커':'fa-worm','울트라':'fa-hippo','디파일':'fa-biohazard','가디언':'fa-shield','디바우':'fa-skull','스커지':'fa-explosion','오버':'fa-parachute-box','드론':'fa-bug','SCV':'fa-wrench','프로브':'fa-gem','병력':'fa-users'};
    let cls='fa-solid fa-star';for(const [k,v] of Object.entries(iconMap)){if(unitName.includes(k)){cls='fa-solid '+v;break;}}
    ic.innerHTML='<i class="'+cls+'"></i>';iw.appendChild(ic);c.appendChild(iw);
    const lb=document.createElement('div');lb.className='hologram-label';lb.textContent=unitName;c.appendChild(lb);
    entityLayer.appendChild(c);setTimeout(()=>c.remove(),2600);
}
function extractUnitName(line){
    const units=['마린','메딕','탱크','시즈탱크','배틀크루저','레이스','발키리','골리앗','벌쳐','파이어뱃','SCV','질럿','드라군','하이템플러','다크템플러','아칸','다크아칸','리버','캐리어','커세어','옵저버','셔틀','스카웃','아비터','프로브','저글링','히드라리스크','히드라','뮤탈리스크','뮤탈','럴커','울트라리스크','울트라','디파일러','디파일','가디언','디바우러','디바우','스커지','오버로드','오버','드론','병력'];
    for(const u of units){if(line.includes(u))return u;}return null;
}

// ── 6. 헥스 캔버스 ──
let territoryCanvas,territoryCtx,_animFrame=null,_hexGrid=[];
const HEX_R=14,HEX_PAD=1.5;
let _mobileInfluence=[],_combatEvents=[],_arrowTrails=[];
function initTerritory(){
    territoryCanvas=document.getElementById('territoryCanvas');
    territoryCanvas.width=600;territoryCanvas.height=600;
    territoryCtx=territoryCanvas.getContext('2d');
    _buildHexGrid();
    if(_animFrame) cancelAnimationFrame(_animFrame);
    (function loop(now){_renderHexGrid(now);_animFrame=requestAnimationFrame(loop);})(performance.now());
}
function _buildHexGrid(){
    _hexGrid=[];const w=territoryCanvas.width,h=territoryCanvas.height;
    const hexW=Math.sqrt(3)*(HEX_R+HEX_PAD),hexH=1.5*(HEX_R+HEX_PAD);
    const cols=Math.ceil(w/hexW)+1,rows=Math.ceil(h/hexH)+1;
    for(let row=-1;row<rows;row++)for(let col=-1;col<cols;col++){const x=col*hexW+(row%2===1?hexW/2:0),y=row*hexH;if(x>-HEX_R&&x<w+HEX_R&&y>-HEX_R&&y<h+HEX_R)_hexGrid.push({x,y});}
}

// ★ 헥스 렌더링 - 투명도(Alpha) 한계치 대폭 하향 적용
function _renderHexGrid(now){
    const ctx=territoryCtx,w=territoryCanvas.width,h=territoryCanvas.height;ctx.clearRect(0,0,w,h);
    const blueNodes=[],redNodes=[];
    const bm=COORDS.blue.main,rm=COORDS.red.main;if(!bm||!rm)return;
    const bmX=bm.x/100*w, bmY=bm.y/100*h;
    const rmX=rm.x/100*w, rmY=rm.y/100*h;

    blueNodes.push({x:bmX,y:bmY,power:1.0});redNodes.push({x:rmX,y:rmY,power:1.0});
    if(COORDS.blue.exp1&&document.getElementById('blue_exp1'))blueNodes.push({x:COORDS.blue.exp1.x/100*w,y:COORDS.blue.exp1.y/100*h,power:0.7});
    if(COORDS.blue.exp2&&document.getElementById('blue_exp2'))blueNodes.push({x:COORDS.blue.exp2.x/100*w,y:COORDS.blue.exp2.y/100*h,power:0.55});
    if(COORDS.red.exp1&&document.getElementById('red_exp1'))redNodes.push({x:COORDS.red.exp1.x/100*w,y:COORDS.red.exp1.y/100*h,power:0.7});
    if(COORDS.red.exp2&&document.getElementById('red_exp2'))redNodes.push({x:COORDS.red.exp2.x/100*w,y:COORDS.red.exp2.y/100*h,power:0.55});
    for(const m of _mobileInfluence){const n={x:m.x,y:m.y,power:m.power,mobile:true};if(m.team==='blue')blueNodes.push(n);else redNodes.push(n);}
    
    // ★ 1000 한계치 기준 비율 (0~1)
    const bGrRatio = _blueGrowth/1000, rGrRatio = _redGrowth/1000;
    const bMoRatio = _blueMomentum/1000, rMoRatio = _redMomentum/1000;

    const blueRange=60+bGrRatio*350, redRange=60+rGrRatio*350;
    const blueBaseMult=0.4+bMoRatio*3.0, redBaseMult=0.4+rMoRatio*3.0;
    const mobileRange=55;

    _combatEvents=_combatEvents.filter(ev=>now-ev.time<2000);_arrowTrails=_arrowTrails.filter(tr=>now-tr.time<1200);
    const tick=now*0.001,hexPath=_hexPath(HEX_R-0.5);

    ctx.strokeStyle='rgba(255,255,255,0.3)';ctx.fillStyle='rgba(255,255,255,0.06)';ctx.lineWidth=0.7;
    for(const hex of _hexGrid){ctx.beginPath();for(let i=0;i<6;i++){const px=hex.x+hexPath[i][0],py=hex.y+hexPath[i][1];i===0?ctx.moveTo(px,py):ctx.lineTo(px,py);}ctx.closePath();ctx.fill();ctx.stroke();}

    ctx.globalCompositeOperation='screen';
    for(const hex of _hexGrid){
        let blueInf=0;
        for(const n of blueNodes){
            const dx=hex.x-n.x, dy=hex.y-n.y, d=Math.sqrt(dx*dx+dy*dy);
            const range=n.mobile?mobileRange:blueRange;
            if(d===0) { blueInf += n.power*blueBaseMult; continue; }

            let shapeWarp=1.0, densMult=1.0;
            // ★ 2안: 주도권에 따른 창과 방패 형태 변화 (방향성 왜곡)
            if(!n.mobile) {
                let dirX=rmX-n.x, dirY=rmY-n.y;
                let dirLen=Math.sqrt(dirX*dirX+dirY*dirY)||1;
                let dot=(dx*(dirX/dirLen) + dy*(dirY/dirLen))/d;
                if(bMoRatio > 0.5) { shapeWarp = 1 - Math.max(0,dot)*(bMoRatio-0.5)*1.2; }
                else { shapeWarp = 1 + (0.5-bMoRatio)*0.6; densMult = 1 + (0.5-bMoRatio)*2.0; }
            }
            let effD = d * shapeWarp;
            if(effD<range){ const f=1-(effD/range); blueInf+=f*f*n.power*blueBaseMult*densMult; }
        }

        let redInf=0;
        for(const n of redNodes){
            const dx=hex.x-n.x, dy=hex.y-n.y, d=Math.sqrt(dx*dx+dy*dy);
            const range=n.mobile?mobileRange:redRange;
            if(d===0) { redInf += n.power*redBaseMult; continue; }

            let shapeWarp=1.0, densMult=1.0;
            if(!n.mobile) {
                let dirX=bmX-n.x, dirY=bmY-n.y;
                let dirLen=Math.sqrt(dirX*dirX+dirY*dirY)||1;
                let dot=(dx*(dirX/dirLen) + dy*(dirY/dirLen))/d;
                if(rMoRatio > 0.5) { shapeWarp = 1 - Math.max(0,dot)*(rMoRatio-0.5)*1.2; }
                else { shapeWarp = 1 + (0.5-rMoRatio)*0.6; densMult = 1 + (0.5-rMoRatio)*2.0; }
            }
            let effD = d * shapeWarp;
            if(effD<range){ const f=1-(effD/range); redInf+=f*f*n.power*redBaseMult*densMult; }
        }

        let nearTrailTeam=null,nearTrailStr=0;
        for(const tr of _arrowTrails){const dx=hex.x-tr.x,dy=hex.y-tr.y,d=Math.sqrt(dx*dx+dy*dy);if(d<45){const age=(now-tr.time)/1000,v=(1-d/45)*Math.max(0,1-age*0.85);if(v>nearTrailStr){nearTrailStr=v;nearTrailTeam=tr.team;}}}
        for(const m of _mobileInfluence){const dx=hex.x-m.x,dy=hex.y-m.y,d=Math.sqrt(dx*dx+dy*dy);if(d<50){const v=(1-d/50)*1.2;if(v>nearTrailStr){nearTrailStr=v;nearTrailTeam=m.team;}}}
        if(blueInf<0.02&&redInf<0.02&&nearTrailStr<0.05)continue;
        
        const isFrontline=(blueInf>0.15&&redInf>0.15);
        let dominant,dominance,strength;
        if(blueInf>=0.02||redInf>=0.02){dominant=blueInf>=redInf?'blue':'red';const dom=dominant==='blue'?blueInf:redInf,sub=dominant==='blue'?redInf:blueInf;dominance=dom-sub*0.4;if(dominance<0.02&&nearTrailStr<0.05)continue;strength=Math.min(Math.max(dominance,0),1.5);}else{dominant=nearTrailTeam;strength=0;dominance=0;}
        
        let alpha,pulseSpeed,pulseAmt;
        // ★ Alpha (투명도) Base 대폭 하향
        if(strength>1.0){alpha=0.35+strength*0.05;pulseSpeed=1.5;pulseAmt=0.02;}
        else if(strength>0.5){alpha=0.15+strength*0.2;pulseSpeed=2.5;pulseAmt=0.05;}
        else{alpha=strength*0.3;pulseSpeed=4.0;pulseAmt=0.1;}
        
        alpha*=1+Math.sin(tick*pulseSpeed+hex.x*0.04+hex.y*0.06)*pulseAmt;
        
        let combatMod=1,combatFlash=0;
        for(const ev of _combatEvents){const dx=hex.x-ev.x,dy=hex.y-ev.y,d=Math.sqrt(dx*dx+dy*dy),age=(now-ev.time)/1000;if(ev.type==='blackout'&&d<100){const p=1-(d/100),f=Math.max(0,1-age*1.2);combatMod*=(1-p*f*0.85);}if(ev.type==='fortify'&&d<90&&dominant===ev.team){const p=1-(d/90),f=Math.max(0,1-age*0.8);combatFlash+=p*f*0.3;}}
        
        alpha=alpha*combatMod+combatFlash;
        // ★ Alpha (투명도) 상한선(Cap) 0.62 -> 0.45 로 하향 (지형 가림 방지)
        alpha=Math.max(0,Math.min(alpha,0.45));
        if(alpha<0.01)continue;
        
        // 이동 궤적 타일 상한선 하향
        alpha=Math.min(alpha+nearTrailStr*0.2,0.55);
        
        let wobX=0,wobY=0;if(nearTrailStr>0.1){const w2=nearTrailStr*2.5;wobX=Math.sin(tick*25+hex.x*0.3)*w2;wobY=Math.cos(tick*30+hex.y*0.3)*w2;}
        ctx.save();ctx.translate(hex.x+wobX,hex.y+wobY);
        
        if(isFrontline){
            // ★ 3안: 국경선 충돌 스파크 (성장력이 높을수록 과부하 심해짐)
            let intensity = (_blueGrowth + _redGrowth) / 2000; 
            const cs=Math.min(blueInf,redInf), phase=tick*22+hex.x*0.25+hex.y*0.31;
            const noise=Math.sin(phase)*0.5+Math.sin(phase*1.73+1.1)*0.3+Math.sin(phase*3.17+2.3)*0.2;
            const overloadAlpha=Math.max(0,noise)*cs*(1.0 + intensity*1.5);
            
            ctx.fillStyle='rgba(56,189,248,'+Math.min(alpha*0.5,0.2).toFixed(3)+')';ctx.strokeStyle='rgba(56,189,248,0.1)';ctx.lineWidth=0.5;ctx.beginPath();for(let i=0;i<6;i++){i===0?ctx.moveTo(hexPath[i][0],hexPath[i][1]):ctx.lineTo(hexPath[i][0],hexPath[i][1]);}ctx.closePath();ctx.fill();
            ctx.fillStyle='rgba(244,63,94,'+Math.min(alpha*0.5,0.2).toFixed(3)+')';ctx.fill();ctx.stroke();
            if(overloadAlpha>0.02){
                const isWhite=overloadAlpha>0.18;
                ctx.fillStyle=isWhite?'rgba(255,255,255,'+Math.min(overloadAlpha*1.2,0.5).toFixed(3)+')':'rgba(255,210,50,'+Math.min(overloadAlpha*0.9,0.3).toFixed(3)+')';
                ctx.beginPath();for(let i=0;i<6;i++){i===0?ctx.moveTo(hexPath[i][0],hexPath[i][1]):ctx.lineTo(hexPath[i][0],hexPath[i][1]);}ctx.closePath();ctx.fill();
                ctx.strokeStyle=isWhite?'rgba(255,255,255,'+Math.min(overloadAlpha*1.5,0.6).toFixed(3)+')':'rgba(255,200,80,'+Math.min(overloadAlpha*1.2,0.4).toFixed(3)+')';
                ctx.lineWidth=0.8;ctx.stroke();
            }
        }
        else{
            ctx.fillStyle=dominant==='blue'?'rgba(56,189,248,'+alpha.toFixed(3)+')':'rgba(244,63,94,'+alpha.toFixed(3)+')';
            ctx.strokeStyle=dominant==='blue'?'rgba(56,189,248,'+Math.min(alpha+0.15,0.4).toFixed(3)+')':'rgba(244,63,94,'+Math.min(alpha+0.15,0.4).toFixed(3)+')';
            ctx.lineWidth=0.6;ctx.beginPath();for(let i=0;i<6;i++){i===0?ctx.moveTo(hexPath[i][0],hexPath[i][1]):ctx.lineTo(hexPath[i][0],hexPath[i][1]);}ctx.closePath();ctx.fill();ctx.stroke();
        }
        ctx.restore();
    }
    ctx.globalCompositeOperation='source-over';
}
function _hexPath(r){const p=[];for(let i=0;i<6;i++){const a=Math.PI/180*(60*i-30);p.push([r*Math.cos(a),r*Math.sin(a)]);}return p;}

// ── 7. 성장력 / 주도권 (한계치 1000) ──
let _blueGrowth=100,_redGrowth=100,_blueMomentum=300,_redMomentum=300,_blueMultiCount=0,_redMultiCount=0;
let _simFinished = false; 
let _growthTickId = null;

const blueGrowthFill=document.getElementById('blueGrowthFill'),redGrowthFill=document.getElementById('redGrowthFill');
const blueGrowthVal=document.getElementById('blueGrowthVal'),redGrowthVal=document.getElementById('redGrowthVal');
const blueMomentumFill=document.getElementById('blueMomentumFill'),redMomentumFill=document.getElementById('redMomentumFill');
const blueMomentumVal=document.getElementById('blueMomentumVal'),redMomentumVal=document.getElementById('redMomentumVal');

function clamp(v,min,max){return Math.max(min,Math.min(max,v));}
function updateStats(){
    _blueGrowth=clamp(_blueGrowth,0,1000);_redGrowth=clamp(_redGrowth,0,1000);
    _blueMomentum=clamp(_blueMomentum,0,1000);_redMomentum=clamp(_redMomentum,0,1000);
    
    // UI 퍼센트는 1000 기준이므로 10으로 나눔
    blueGrowthFill.style.width=(_blueGrowth/10)+'%';redGrowthFill.style.width=(_redGrowth/10)+'%';
    blueMomentumFill.style.width=(_blueMomentum/10)+'%';redMomentumFill.style.width=(_redMomentum/10)+'%';
    
    blueGrowthVal.textContent=Math.floor(_blueGrowth);redGrowthVal.textContent=Math.floor(_redGrowth);
    blueMomentumVal.textContent=Math.floor(_blueMomentum);redMomentumVal.textContent=Math.floor(_redMomentum);
    
    for(let i=0;i<3;i++){document.getElementById('blueDot'+i).classList.toggle('active',i<_blueMultiCount);document.getElementById('redDot'+i).classList.toggle('active',i<_redMultiCount);}
}

// ★ 성장 틱 밸런스 조정 (0.5초마다 아주 조금씩)
_growthTickId = setInterval(()=>{
    if(_simFinished) return;
    const gB=0.5, gM=1.0;  // 기존 3, 4에서 대폭 하향 (16분 지속 게임에 맞춤)
    _blueGrowth+=gB+_blueMultiCount*gM;
    _redGrowth+=gB+_redMultiCount*gM;
    updateStats();
},500);

const MULTI_DESTROY_KW=['파괴','박살','날려','뚫어','전멸','전진기지 붕괴','앞마당 박살','멀티 파괴'];
function isMultiDestroy(line){return MULTI_DESTROY_KW.some(k=>line.includes(k))&&(line.includes('멀티')||line.includes('앞마당')||line.includes('해처리')||line.includes('넥서스')||line.includes('커맨드')||line.includes('기지'));}

// ★ 주요 공중 유닛 확대
const AIR_UNIT_KW = ['뮤탈','뮤탈리스크','가디언','디바우러','스커지','레이스','배틀크루저','배틀','발키리','캐리어','커세어','스카웃','아비터'];
function isAirAttack(line) { return AIR_UNIT_KW.some(k=>line.includes(k)); }

function parseMapAction(line,isBlue){
    const myCoords=isBlue?COORDS.blue:COORDS.red,enemyCoords=isBlue?COORDS.red:COORDS.blue;
    const teamStr=isBlue?'blue':'red',enemyTeamStr=isBlue?'red':'blue';

    const isMultiBuild=line.includes("앞마당")||line.includes("멀티")||line.includes("해처리")||line.includes("넥서스")||line.includes("커맨드");
    if(isMultiBuild&&!isMultiDestroy(line)){
        const race=isBlue?myRace:aiRace,img=getBuildingImage(race);
        const isTriple=line.includes("트리플")||line.includes("서드")||line.includes("3멀티");
        if(isTriple){if(myCoords.exp2)spawnEntity(teamStr+'_exp2','building',teamStr,myCoords.exp2,img);}
        else{if(myCoords.exp1)spawnEntity(teamStr+'_exp1','building',teamStr,myCoords.exp1,img);}
        // ★ 멀티 건설 획득량 하향
        if(isBlue){_blueMultiCount=Math.min(_blueMultiCount+1,3);_blueGrowth+=30;}else{_redMultiCount=Math.min(_redMultiCount+1,3);_redGrowth+=30;}
        updateStats();
    }
    
    // ★ 1안: 파괴 시 타격감 폭발 + 성장력 수축 (수치 하향)
    if(isMultiDestroy(line)){
        if(isBlue){
            _redMultiCount=Math.max(_redMultiCount-1,0);_redGrowth-=50;_redMomentum-=60;
            let tgt = document.getElementById('red_exp2') || document.getElementById('red_exp1');
            if(tgt){ showExplosion(parseFloat(tgt.style.left), parseFloat(tgt.style.top), 'BASE DESTROYED'); tgt.remove(); }
        } else {
            _blueMultiCount=Math.max(_blueMultiCount-1,0);_blueGrowth-=50;_blueMomentum-=60;
            let tgt = document.getElementById('blue_exp2') || document.getElementById('blue_exp1');
            if(tgt){ showExplosion(parseFloat(tgt.style.left), parseFloat(tgt.style.top), 'BASE DESTROYED'); tgt.remove(); }
        }
        updateStats();
    }
    
    if(line.includes("생산")||line.includes("확보")||line.includes("조합")||line.includes("편성")||line.includes("합류")){
        const unitName=extractUnitName(line)||'병력';showHologram(unitName,teamStr);
        if(isBlue)_blueMomentum+=10;else _redMomentum+=10;updateStats(); // 40 -> 10 하향
    }

    if(line.includes("공격")||line.includes("압박")||line.includes("러시")||line.includes("돌파")||line.includes("진출")||line.includes("진격")||line.includes("올킬")||line.includes("견제")){
        const sp=getArrowEdge(myCoords,enemyCoords),ep=getArrowEdge(enemyCoords,myCoords);
        if(isAirAttack(line)) drawAirStrikeArrow(sp.x,sp.y,ep.x,ep.y,teamStr);
        else drawTacticalArrow(sp.x,sp.y,ep.x,ep.y,teamStr);
        // ★ 공격 성공 딜레이 페널티 하향
        setTimeout(()=>{if(isBlue)_redMomentum-=25;else _blueMomentum-=25;updateStats();},1400); 
    }

    if(line.includes("방어")||line.includes("수비")||line.includes("저지")||line.includes("격퇴")||line.includes("막아")){
        const as=getArrowEdge(enemyCoords,myCoords),dp=getArrowEdge(myCoords,enemyCoords);
        drawTacticalArrow(as.x,as.y,dp.x,dp.y,enemyTeamStr,{blocked:true,onArrival:(tx,ty)=>{showShieldDeflect(tx,ty,teamStr);}});
        if(isBlue)_blueMomentum+=20;else _redMomentum+=20;updateStats(); // 70 -> 20 하향
    }
}

// ── 8. 시뮬레이션 루프 ──
let currentLineIdx=0;
const logContainer=document.getElementById('logContainer'),progressBar=document.getElementById('simProgressBar');

// ★ 로그당 주도권 보너스도 전체적으로 하향 (1000 게이지 밸런스에 맞춤)
function getMomentumBonus(line){
    if(line.includes('올킬')||line.includes('전멸')||line.includes('완전'))return 40;
    if(line.includes('공격')||line.includes('러시')||line.includes('진격'))return 25;
    if(line.includes('방어')||line.includes('격퇴')||line.includes('막아'))return 20;
    if(line.includes('멀티')||line.includes('앞마당'))return 15;
    if(line.includes('생산')||line.includes('편성'))return 10;
    return 5;
}

function startSimulation(){
    if(scriptLines.length===0){finishSet();return;}
    const interval=setInterval(()=>{
        if(currentLineIdx<scriptLines.length){
            const line=scriptLines[currentLineIdx];const entry=document.createElement('div');entry.className='log-line';
            let isBlueAction=null;
            if(line.startsWith('[빌드A]')){isBlueAction=true;entry.classList.add('blue');entry.innerHTML="<strong>["+myName+"]</strong> : "+line.replace('[빌드A]','').trim();_blueMomentum+=getMomentumBonus(line);updateStats();}
            else if(line.startsWith('[빌드B]')){isBlueAction=false;entry.classList.add('red');entry.innerHTML="<strong>["+aiName+"]</strong> : "+line.replace('[빌드B]','').trim();_redMomentum+=getMomentumBonus(line);updateStats();}
            else{entry.classList.add('neutral');entry.innerText=line;}
            if(isBlueAction!==null)parseMapAction(line,isBlueAction);
            logContainer.appendChild(entry);logContainer.scrollTop=logContainer.scrollHeight;
            currentLineIdx++;progressBar.style.width=(currentLineIdx/scriptLines.length*100)+'%';
        }else{clearInterval(interval);finishSet();}
    },2100);
}
function finishSet(){
    _simFinished = true;
    if(_growthTickId) { clearInterval(_growthTickId); _growthTickId = null; }

    document.getElementById('actionArea').style.display='block';
    const fm=myWinFlag?parseInt("${myWins}")+1:parseInt("${myWins}");
    const fa=!myWinFlag?parseInt("${aiWins}")+1:parseInt("${aiWins}");
    if(fm>=3||fa>=3){document.getElementById('btnNextSet').style.display='none';document.getElementById('btnFinalResult').style.display='block';}
}
function nextSet(){location.href="${pageContext.request.contextPath}/pve/finish?winner="+(myWinFlag?"player":"ai");}
function showFinalResult(){location.href="${pageContext.request.contextPath}/pve/finish?winner="+(myWinFlag?"player":"ai");}
window.onload=function(){loadMapData();};
</script>
</body>
</html>