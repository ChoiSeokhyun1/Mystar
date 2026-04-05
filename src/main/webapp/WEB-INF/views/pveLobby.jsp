<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PVE 로비 - My Star League</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/pveLobby.css' />">
</head>
<body>

<header class="msl-topbar">
    <div class="msl-topbar-logo">MY STAR <span>LEAGUE</span></div>
    <div class="msl-topbar-center">
        <nav class="msl-breadcrumb">
            <a href="<c:url value='/mode-select' />">홈</a>
            <span class="sep">/</span>
            <span class="current">PVE 시나리오</span>
        </nav>
    </div>
    <div class="msl-topbar-right">
        <div class="msl-crystal">💎 ${sessionScope.loginUser.crystal}</div>
        <div class="msl-user-label"><strong>${sessionScope.loginUser.userNick}</strong></div>
        <c:if test="${sessionScope.loginUser.userId == 'testuser3'}">
            <a href="<c:url value='/admin/stage' />" class="msl-btn-nav" style="background:rgba(239,68,68,0.15);border-color:#7f1d1d;color:#f87171;">⚙ 관리자</a>
        </c:if>
        <a href="<c:url value='/logout' />" class="msl-btn-nav">LOGOUT</a>
    </div>
</header>

<c:set var="activeMenu" value="pve-lobby" />
<%@ include file="/WEB-INF/views/layout/sideBar.jsp" %>

<main class="msl-main">

    <div class="msl-page-header msl-animate">
        <div class="msl-page-header-left">
            <div class="msl-page-eyebrow">PVE SCENARIO MODE</div>
            <div class="msl-page-title">${not empty sessionScope.loginUser.teamName ? sessionScope.loginUser.teamName : sessionScope.loginUser.userNick}</div>
        </div>

    </div>

    <div class="lobby-grid msl-animate msl-animate-d1">

        <div class="msl-panel stage-panel">
            <div class="msl-panel-body">
                <table class="stage-table">
                    <thead>
                        <tr>
                            <th style="width:64px;">STAGE</th>
                            <th>대결</th>
                            <th style="width:130px;">진행도</th>
                            <th style="width:110px;">상태</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty stageStatusMap}">
                                <c:forEach var="entry" items="${stageStatusMap}">
                                    <tr class="${entry.value == 'IN_PROGRESS' ? 'active-row clickable-row' : ''}" data-level="${entry.key}" data-status="${entry.value}">
                                        <td><span class="stage-num">${entry.key}</span></td>
                                        <td>
                                            <div class="stage-name">제 ${entry.key}장</div>
                                            <div class="stage-sub">AI 시나리오 도전</div>
                                        </td>
                                        <td>
                                            <c:set var="pct" value="${stageProgressMap[entry.key]}" />
                                            <c:choose>
                                                <c:when test="${entry.value == 'CLEARED'}">
                                                    <div class="stage-bar-wrap">
                                                        <div class="stage-bar-fill cleared" style="width:100%"></div>
                                                    </div>
                                                    <div class="stage-bar-label cleared">100.0%</div>
                                                </c:when>
                                                <c:when test="${entry.value == 'IN_PROGRESS'}">
                                                    <div class="stage-bar-wrap">
                                                        <div class="stage-bar-fill in-progress" style="width:${pct}%"></div>
                                                    </div>
                                                    <div class="stage-bar-label in-progress">${pct}%</div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="stage-bar-wrap">
                                                        <div class="stage-bar-fill locked" style="width:0%"></div>
                                                    </div>
                                                    <div class="stage-bar-label locked">0.0%</div>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${entry.value == 'CLEARED'}">
                                                    <span class="status-pill cleared">✓ 클리어</span>
                                                </c:when>
                                                <c:when test="${entry.value == 'IN_PROGRESS'}">
                                                    <span class="status-pill in-progress">▶ 진행중</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="status-pill locked">🔒 잠금</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr class="active-row">
                                    <td><span class="stage-num">1</span></td>
                                    <td><div class="stage-name">제 1장 — 새벽의 전쟁</div><div class="stage-sub">첫 번째 AI 도전</div></td>
                                    <td>
                                        <div class="stage-bar-wrap"><div class="stage-bar-fill in-progress" style="width:0%"></div></div>
                                        <div class="stage-bar-label in-progress">진행중</div>
                                    </td>
                                    <td><span class="status-pill in-progress">▶ 진행중</span></td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="side-col">

            <div class="msl-panel side-panel-ad">
                <div class="msl-panel-head">
                    <div class="msl-panel-title">ADVERTISEMENT</div>
                </div>
                <div class="msl-panel-body ad-body">
                    <div class="ad-placeholder">
                        <div class="ad-icon">📢</div>
                        <div class="ad-text">광고 영역</div>
                    </div>
                </div>
            </div>

            <div class="msl-panel side-panel-rank">
                <div class="msl-panel-head">
                    <div class="msl-panel-title" id="rankTitle">MOST PLAYED</div>
                    <div class="rank-nav">
                        <button class="rank-nav-btn" id="rankPrev">&#8249;</button>
                        <span class="rank-dots">
                            <span class="rank-dot active" data-idx="0"></span>
                            <span class="rank-dot" data-idx="1"></span>
                            <span class="rank-dot" data-idx="2"></span>
                        </span>
                        <button class="rank-nav-btn" id="rankNext">&#8250;</button>
                    </div>
                </div>
                <div class="msl-panel-body rank-slider-body">

                    <%-- 슬라이드 0: 최다 출전 --%>
                    <div class="rank-slide active" data-slide="0">
                        <c:choose>
                            <c:when test="${not empty mostPlayed}">
                                <div class="rank-card">
                                    <div class="rank-card-row">
                                        <div class="rank-card-left">
                                            <span class="rank-card-name">${mostPlayed.playerName}</span>
                                            <span class="msl-rarity ${fn:toLowerCase(mostPlayed.currentRarity)}">${mostPlayed.currentRarity}</span>
                                            <span class="msl-race ${mostPlayed.race}">${mostPlayed.race}</span>
                                        </div>
                                        <div class="rank-card-big">${mostPlayed.gamesPlayed}<span>경기</span></div>
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise><div class="rank-empty">전적 데이터가 없습니다</div></c:otherwise>
                        </c:choose>
                    </div>

                    <%-- 슬라이드 1: 최고 승률 --%>
                    <div class="rank-slide" data-slide="1">
                        <c:choose>
                            <c:when test="${not empty bestWinRate}">
                                <div class="rank-card">
                                    <div class="rank-card-label">최고 승률 <small>(3경기↑)</small></div>
                                    <div class="rank-card-row">
                                        <div class="rank-card-left">
                                            <span class="rank-card-name">${bestWinRate.playerName}</span>
                                            <span class="msl-rarity ${fn:toLowerCase(bestWinRate.currentRarity)}">${bestWinRate.currentRarity}</span>
                                            <span class="msl-race ${bestWinRate.race}">${bestWinRate.race}</span>
                                        </div>
                                        <div class="rank-card-big green">${bestWinRate.winRate}<span>%</span></div>
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise><div class="rank-empty">3경기 이상 출전한 선수가 없습니다</div></c:otherwise>
                        </c:choose>
                    </div>

                    <%-- 슬라이드 2: 최다 승리 --%>
                    <div class="rank-slide" data-slide="2">
                        <c:choose>
                            <c:when test="${not empty mostWins}">
                                <div class="rank-card">
                                    <div class="rank-card-row">
                                        <div class="rank-card-left">
                                            <span class="rank-card-name">${mostWins.playerName}</span>
                                            <span class="msl-rarity ${fn:toLowerCase(mostWins.currentRarity)}">${mostWins.currentRarity}</span>
                                            <span class="msl-race ${mostWins.race}">${mostWins.race}</span>
                                        </div>
                                        <div class="rank-card-big gold">${mostWins.wins}<span>승</span></div>
                                    </div>
                                </div>
                            </c:when>
                            <c:otherwise><div class="rank-empty">전적 데이터가 없습니다</div></c:otherwise>
                        </c:choose>
                    </div>

                </div>
            </div>

            <div class="msl-panel side-panel-quest">
                <div class="msl-panel-head">
                    <div class="msl-panel-title">DAILY QUEST</div>
                    <span class="coming-soon-chip">준비중</span>
                </div>
                <div class="msl-panel-body quest-body">
                    <div class="quest-item">
                        <div class="quest-icon">⚔️</div>
                        <div class="quest-info">
                            <div class="quest-name">오늘 3승 달성하기</div>
                            <div class="quest-reward">💎 +50</div>
                        </div>
                        <div class="quest-prog">0/3</div>
                    </div>
                    <div class="quest-item">
                        <div class="quest-icon">🧪</div>
                        <div class="quest-info">
                            <div class="quest-name">빌드 사용해서 승리</div>
                            <div class="quest-reward">💎 +30</div>
                        </div>
                        <div class="quest-prog">0/1</div>
                    </div>
                    <div class="quest-item">
                        <div class="quest-icon">🌟</div>
                        <div class="quest-info">
                            <div class="quest-name">선수 영입 1회</div>
                            <div class="quest-reward">💎 +20</div>
                        </div>
                        <div class="quest-prog">0/1</div>
                    </div>
                </div>
            </div>

        </div></div></main>

<script>
    const contextPath = '${pageContext.request.contextPath}';
    window.addEventListener('DOMContentLoaded', function() {
        // 스테이지 행 클릭
        document.querySelectorAll('tr[data-level]').forEach(function(row) {
            if (row.dataset.status === 'IN_PROGRESS') {
                row.style.cursor = 'pointer';
                row.addEventListener('click', function() {
                    location.href = contextPath + '/pve/stage?level=' + row.dataset.level;
                });
            }
        });

        // ── 선수단 랭킹 슬라이더 ──
        const titles = ['MOST PLAYED', 'BEST WIN RATE', 'MOST WINS'];
        const slides = document.querySelectorAll('.rank-slide');
        const dots   = document.querySelectorAll('.rank-dot');
        const title  = document.getElementById('rankTitle');
        let cur = 0;

        function goTo(idx) {
            slides[cur].classList.remove('active');
            dots[cur].classList.remove('active');
            cur = (idx + slides.length) % slides.length;
            slides[cur].classList.add('active');
            dots[cur].classList.add('active');
            title.textContent = titles[cur];
        }

        document.getElementById('rankPrev').addEventListener('click', () => goTo(cur - 1));
        document.getElementById('rankNext').addEventListener('click', () => goTo(cur + 1));
        dots.forEach(d => d.addEventListener('click', () => goTo(parseInt(d.dataset.idx))));
    }); // DOMContentLoaded
</script>

</body>
</html>