<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MODE SELECT - My Star League</title>
    <link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@300;400;600;700;800;900&family=Barlow:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --green: #00e676;
            --green-dim: #00c853;
            --navy: #0a0f1e;
            --panel: #0d1422;
            --panel2: #111827;
            --border: rgba(255,255,255,0.07);
            --text: #c9d4e8;
            --text-dim: #5a6a85;
            --gold: #ffd600;
        }

        html, body {
            height: 100%;
            background: var(--navy);
            color: var(--text);
            font-family: 'Barlow', sans-serif;
            overflow: hidden;
        }

        /* ── GRID NOISE OVERLAY ── */
        body::before {
            content: '';
            position: fixed; inset: 0;
            background-image:
                linear-gradient(rgba(0,230,118,0.02) 1px, transparent 1px),
                linear-gradient(90deg, rgba(0,230,118,0.02) 1px, transparent 1px);
            background-size: 60px 60px;
            pointer-events: none; z-index: 0;
        }

        /* ── TOP BAR ── */
        .topbar {
            position: fixed; top: 0; left: 0; right: 0; z-index: 100;
            height: 56px;
            background: rgba(10,15,30,0.95);
            border-bottom: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 2.5rem;
            backdrop-filter: blur(12px);
        }
        .topbar-logo {
            font-family: 'Barlow Condensed', sans-serif;
            font-size: 1.2rem; font-weight: 800;
            letter-spacing: 0.15em;
            color: #fff;
        }
        .topbar-logo span { color: var(--green); }
        .topbar-user {
            display: flex; align-items: center; gap: 1.5rem;
            font-size: 0.85rem; color: var(--text-dim);
        }
        .topbar-user strong { color: var(--text); font-size: 0.9rem; }
        .crystal-badge {
            display: flex; align-items: center; gap: 0.4rem;
            background: rgba(255,214,0,0.08);
            border: 1px solid rgba(255,214,0,0.2);
            border-radius: 6px;
            padding: 0.3rem 0.8rem;
            font-family: 'Barlow Condensed', sans-serif;
            font-size: 1rem; font-weight: 700; color: var(--gold);
        }
        .btn-logout {
            font-size: 0.8rem; color: var(--text-dim);
            text-decoration: none; padding: 0.35rem 0.9rem;
            border: 1px solid var(--border); border-radius: 5px;
            transition: all 0.2s;
        }
        .btn-logout:hover { color: #fff; border-color: rgba(255,255,255,0.2); }

        /* ── MAIN LAYOUT ── */
        .page {
            position: fixed; inset: 56px 0 0 0;
            display: flex; flex-direction: column;
            align-items: center; justify-content: center;
            gap: 3rem;
            padding: 2rem;
            z-index: 1;
        }

        .page-title {
            text-align: center;
        }
        .page-title h1 {
            font-family: 'Barlow Condensed', sans-serif;
            font-size: clamp(1.4rem, 3vw, 2rem);
            font-weight: 300; letter-spacing: 0.5em;
            color: var(--text-dim);
            text-transform: uppercase;
        }
        .page-title p {
            font-family: 'Barlow Condensed', sans-serif;
            font-size: clamp(2.5rem, 6vw, 4.5rem);
            font-weight: 900; letter-spacing: 0.05em;
            color: #fff;
            line-height: 1;
            margin-top: 0.25rem;
        }

        /* ── MODE CARDS ── */
        .mode-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem;
            width: 100%;
            max-width: 900px;
        }

        .mode-card {
            position: relative;
            background: var(--panel);
            border: 1px solid var(--border);
            border-radius: 4px;
            padding: 3rem 2.5rem;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
            display: flex; flex-direction: column;
            gap: 1rem;
            transition: all 0.3s cubic-bezier(0.4,0,0.2,1);
            overflow: hidden;
        }

        /* Left green line accent */
        .mode-card::before {
            content: '';
            position: absolute; left: 0; top: 0; bottom: 0;
            width: 3px;
            background: var(--green);
            transform: scaleY(0);
            transform-origin: bottom;
            transition: transform 0.3s ease;
        }
        .mode-card:hover::before { transform: scaleY(1); }

        /* Glow bg on hover */
        .mode-card::after {
            content: '';
            position: absolute; inset: 0;
            background: radial-gradient(ellipse at 30% 50%, rgba(0,230,118,0.05) 0%, transparent 65%);
            opacity: 0; transition: opacity 0.3s;
        }
        .mode-card:hover::after { opacity: 1; }
        .mode-card:hover {
            border-color: rgba(0,230,118,0.25);
            transform: translateY(-4px);
            box-shadow: 0 20px 60px rgba(0,0,0,0.5), 0 0 0 1px rgba(0,230,118,0.1);
        }

        .mode-card.pvp-card::before { background: #5c6bc0; }
        .mode-card.pvp-card::after {
            background: radial-gradient(ellipse at 30% 50%, rgba(92,107,192,0.05) 0%, transparent 65%);
        }
        .mode-card.pvp-card:hover {
            border-color: rgba(92,107,192,0.25);
            box-shadow: 0 20px 60px rgba(0,0,0,0.5), 0 0 0 1px rgba(92,107,192,0.1);
        }

        .card-mode-label {
            font-family: 'Barlow Condensed', sans-serif;
            font-size: 0.75rem; font-weight: 700;
            letter-spacing: 0.25em; text-transform: uppercase;
            color: var(--green);
            display: flex; align-items: center; gap: 0.5rem;
        }
        .pvp-card .card-mode-label { color: #7986cb; }
        .card-mode-label::before {
            content: '';
            width: 20px; height: 1px;
            background: currentColor;
        }

        .card-title {
            font-family: 'Barlow Condensed', sans-serif;
            font-size: clamp(2rem, 4vw, 3rem);
            font-weight: 800; line-height: 1;
            color: #fff;
        }

        .card-desc {
            font-size: 0.9rem; color: var(--text-dim);
            line-height: 1.6; max-width: 320px;
        }

        .card-features {
            margin-top: 0.5rem;
            display: flex; flex-direction: column; gap: 0.4rem;
        }
        .feature-item {
            font-size: 0.82rem; color: var(--text-dim);
            display: flex; align-items: center; gap: 0.6rem;
        }
        .feature-item::before {
            content: '—';
            color: var(--green); font-size: 0.7rem;
        }
        .pvp-card .feature-item::before { color: #7986cb; }

        .card-cta {
            margin-top: auto;
            padding-top: 1.5rem;
            display: flex; align-items: center; justify-content: space-between;
        }
        .cta-btn {
            font-family: 'Barlow Condensed', sans-serif;
            font-size: 0.85rem; font-weight: 700;
            letter-spacing: 0.1em; text-transform: uppercase;
            color: var(--green);
            display: flex; align-items: center; gap: 0.5rem;
            transition: gap 0.2s;
        }
        .mode-card:hover .cta-btn { gap: 0.9rem; }
        .pvp-card .cta-btn { color: #7986cb; }

        .coming-soon-badge {
            font-family: 'Barlow Condensed', sans-serif;
            font-size: 0.7rem; font-weight: 700;
            letter-spacing: 0.15em; text-transform: uppercase;
            background: rgba(92,107,192,0.15);
            border: 1px solid rgba(92,107,192,0.3);
            color: #9fa8da;
            padding: 0.25rem 0.7rem;
            border-radius: 3px;
        }

        /* Disabled state for PVP */
        .mode-card.disabled {
            pointer-events: none;
            opacity: 0.65;
        }
        .mode-card.disabled::before { display: none; }

        /* ── SEASON INFO ── */
        .season-bar {
            display: flex; align-items: center; gap: 2rem;
            font-size: 0.78rem; color: var(--text-dim);
            font-family: 'Barlow Condensed', sans-serif;
            letter-spacing: 0.08em;
        }
        .season-bar span { color: var(--text); }
        .dot { width: 6px; height: 6px; border-radius: 50%; background: var(--green); }

        /* ── ANIMATIONS ── */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .page-title { animation: fadeUp 0.5s ease both; }
        .mode-card { animation: fadeUp 0.5s ease both; }
        .mode-card:nth-child(1) { animation-delay: 0.1s; }
        .mode-card:nth-child(2) { animation-delay: 0.2s; }
        .season-bar { animation: fadeUp 0.5s 0.3s ease both; }
    </style>
</head>
<body>

<!-- TOP BAR -->
<header class="topbar">
    <div class="topbar-logo">MY STAR <span>LEAGUE</span></div>
    <div class="topbar-user">
        <span>환영합니다, <strong>${sessionScope.loginUser.userNick}</strong></span>
        <div class="crystal-badge">💎 ${sessionScope.loginUser.crystal}</div>
        <a href="<c:url value='/logout' />" class="btn-logout">LOGOUT</a>
    </div>
</header>

<!-- MAIN -->
<main class="page">
    <div class="page-title">
        <h1>GAME MODE SELECT</h1>
        <p>전장을 선택하세요</p>
    </div>

    <div class="mode-grid">

        <!-- PVE -->
        <a href="<c:url value='/pve/lobby' />" class="mode-card pve-card">
            <div class="card-mode-label">PLAYER VS ENVIRONMENT</div>
            <div class="card-title">PVE<br>시나리오</div>
            <p class="card-desc">AI 팀을 상대로 스테이지를 공략하고 선수를 성장시키세요. 전략적인 빌드 오더가 승패를 결정합니다.</p>
            <div class="card-features">
                <div class="feature-item">스테이지별 AI 도전</div>
                <div class="feature-item">빌드 오더 전략전</div>
                <div class="feature-item">선수 스탯 성장 시스템</div>
            </div>
            <div class="card-cta">
                <div class="cta-btn">입장하기 →</div>
            </div>
        </a>

        <!-- PVP (준비중) -->
        <div class="mode-card pvp-card disabled">
            <div class="card-mode-label">PLAYER VS PLAYER</div>
            <div class="card-title">PVP<br>랭크매치</div>
            <p class="card-desc">실제 유저와 빌드 오더로 맞대결. 랭킹 시스템을 통해 최고의 감독이 되세요.</p>
            <div class="card-features">
                <div class="feature-item">실시간 유저 매칭</div>
                <div class="feature-item">시즌 랭킹 시스템</div>
                <div class="feature-item">빌드 공유 커뮤니티</div>
            </div>
            <div class="card-cta">
                <div class="cta-btn">준비중</div>
                <div class="coming-soon-badge">COMING SOON</div>
            </div>
        </div>

    </div>

    <div class="season-bar">
        <div class="dot"></div>
        <span>현재 시즌:</span> 2024 MSL PRE-SEASON
        <span>|</span>
        <span>서버</span> ONLINE
    </div>
</main>

</body>
</html>
