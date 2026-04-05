<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Stage ${mainStageLevel} - My Star League</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/pveStageDetail.css' />">
</head>
<body>

<header class="msl-topbar">
    <div class="msl-topbar-logo">MY STAR <span>LEAGUE</span></div>
    <div class="msl-topbar-center">
        <nav class="msl-breadcrumb">
            <a href="<c:url value='/mode-select' />">홈</a>
            <span class="sep">/</span>
            <a href="<c:url value='/pve/lobby' />">스테이지 목록</a>
            <span class="sep">/</span>
            <span class="current">Stage ${mainStageLevel}</span>
        </nav>
    </div>
    <div class="msl-topbar-right">
        <div class="msl-crystal">💎 ${sessionScope.loginUser.crystal}</div>
        <div class="msl-user-label"><strong>${sessionScope.loginUser.userNick}</strong></div>
        <a href="<c:url value='/logout' />" class="msl-btn-nav">LOGOUT</a>
    </div>
</header>

<c:set var="activeMenu" value="pve-lobby" />
<%@ include file="/WEB-INF/views/layout/sideBar.jsp" %>

<main class="msl-main">

    <div class="msl-page-header msl-animate">
        <div class="msl-page-header-left">
            <div class="msl-page-eyebrow">STAGE ${mainStageLevel} · 라운드 목록</div>
            <div class="msl-page-title">제 ${mainStageLevel}장 도전</div>
        </div>
        <div class="msl-page-actions">
            <a href="<c:url value='/pve/lobby' />" class="msl-btn msl-btn-secondary">← 스테이지 목록</a>
        </div>
    </div>

    <div class="detail-layout msl-animate msl-animate-d1">

        <%-- 왼쪽: 라운드 목록 --%>
        <div class="substage-list">
            <c:forEach var="subStage" items="${subStageList}">
                <div class="substage-item ${fn:toLowerCase(subStage.status)}"
                     data-sub="${subStage.subLevel}"
                     data-status="${subStage.status}"
                     onclick="selectRound(this)">
                    <div class="substage-left">
                        <div class="substage-num">${mainStageLevel}-${subStage.subLevel}</div>
                        <div class="substage-info">
                            <div class="substage-title">${subStage.title}</div>
                            <div class="substage-sub">라운드 ${subStage.subLevel} · vs ${subStage.opponentTeamName}</div>
                        </div>
                    </div>
                    <div class="substage-right">
                        <c:choose>
                            <c:when test="${subStage.status == 'IN_PROGRESS'}">
                                <a href="<c:url value='/pve/battle?level=${mainStageLevel}&subLevel=${subStage.subLevel}' />"
                                   class="substage-btn go"
                                   onclick="event.stopPropagation()">도전하기 →</a>
                            </c:when>
                            <c:when test="${subStage.status == 'CLEARED'}">
                                <span class="substage-status cleared">✓ 클리어</span>
                            </c:when>
                            <c:otherwise>
                                <span class="substage-status locked">🔒 잠김</span>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:forEach>
        </div>

        <%-- 오른쪽: 상대팀 프리뷰 패널 --%>
        <div class="msl-panel preview-panel">
            <div class="msl-panel-head">
                <div class="msl-panel-title">상대팀 정보</div>
            </div>

            <%-- 이미지 미리보기 영역 --%>
            <div class="preview-img-wrap">
                <div class="preview-placeholder" id="previewPlaceholder">
                    <div class="preview-placeholder-icon">🖼️</div>
                    <div class="preview-placeholder-text">이미지 없음</div>
                </div>
                <img id="previewImg" class="preview-img" src="" alt="" style="display:none;">
            </div>

            <%-- 팀명 --%>
            <div class="preview-team-block" id="previewTeamBlock" style="display:none;">
                <div class="preview-team-label">VS</div>
                <div class="preview-team-name" id="previewTeamName">—</div>
            </div>

            <div class="msl-panel-body preview-body" id="previewBody">

                <%-- 초기 안내 --%>
                <div class="preview-guide" id="previewGuide">
                    <div class="preview-guide-icon">👈</div>
                    <div>라운드를 클릭하면<br>상대팀 정보가 표시됩니다</div>
                </div>

                <%-- 로딩 --%>
                <div class="preview-loading" id="previewLoading" style="display:none;">
                    <div class="loading-dots"><span></span><span></span><span></span></div>
                </div>

                <%-- 선수 목록 --%>
                <div id="playerList" style="display:none;">
                    <div class="player-list-header">
                        <span class="player-list-col-label">선수</span>
                        <span class="player-list-col-label right">세트</span>
                    </div>
                    <div id="playerListBody"></div>
                </div>

                <%-- 선수 없음 --%>
                <div class="preview-empty" id="previewEmpty" style="display:none;">
                    등록된 선수 정보가 없습니다
                </div>

            </div>
        </div>

    </div>
</main>

<script>
    const ctxPath = '<c:url value="/" />';
    const stageLevel = ${mainStageLevel};

    const rarityOrder = { 'UR': 0, 'SSR': 1, 'SR': 2, 'R': 3, 'N': 4 };

    window.addEventListener('DOMContentLoaded', function() {
        const first = document.querySelector('.substage-item');
        if (first) selectRound(first);
    });

    function selectRound(el) {
        if (el.classList.contains('locked')) return;

        document.querySelectorAll('.substage-item').forEach(i => i.classList.remove('selected'));
        el.classList.add('selected');

        const sub = el.dataset.sub;
        loadOpponents(stageLevel, sub);
    }

    function loadOpponents(level, sub) {
        document.getElementById('previewGuide').style.display    = 'none';
        document.getElementById('playerList').style.display      = 'none';
        document.getElementById('previewEmpty').style.display    = 'none';
        document.getElementById('previewLoading').style.display  = 'flex';
        document.getElementById('previewTeamBlock').style.display = 'none';

        // 이미지 미리보기
        const fname = 'stage_' + level + '_' + sub + '.jpg';
        const img = document.getElementById('previewImg');
        const placeholder = document.getElementById('previewPlaceholder');
        img.onload  = function() { placeholder.style.display = 'none';  img.style.display = 'block'; };
        img.onerror = function() { img.style.display = 'none'; placeholder.style.display = 'flex'; };
        img.src = ctxPath + 'resources/image/stages/' + fname;

        fetch(ctxPath + '/pve/stage/opponents?level=' + level + '&subLevel=' + sub)
        .then(res => res.json())
        .then(data => {
            document.getElementById('previewLoading').style.display = 'none';

            // 팀명
            document.getElementById('previewTeamName').textContent = data.teamName || 'AI Team';
            document.getElementById('previewTeamBlock').style.display = 'flex';

            const players = data.players || [];
            if (players.length === 0) {
                document.getElementById('previewEmpty').style.display = 'block';
                return;
            }

            players.sort((a, b) => (a.setNumber || 0) - (b.setNumber || 0));

            const body = document.getElementById('playerListBody');
            body.innerHTML = '';
            players.forEach(p => {
                const row = document.createElement('div');
                row.className = 'player-row';
                const raceClass   = p.race   ? p.race.toUpperCase()   : '';
                const rarityClass = p.rarity ? p.rarity.toLowerCase() : '';
                row.innerHTML =
                    '<div class="player-row-left">' +
                        '<span class="msl-rarity ' + rarityClass + '">' + (p.rarity || '?') + '</span>' +
                        '<span class="msl-race '   + raceClass   + '">' + (p.race   || '?') + '</span>' +
                        '<span class="player-name">' + (p.playerName || '?') + '</span>' +
                    '</div>' +
                    '<div class="player-row-right">' +
                        '<span class="player-set">' + (p.setNumber > 0 ? 'SET ' + p.setNumber : '후보') + '</span>' +
                    '</div>';
                body.appendChild(row);
            });
            document.getElementById('playerList').style.display = 'block';
        })
        .catch(() => {
            document.getElementById('previewLoading').style.display = 'none';
            document.getElementById('previewEmpty').style.display   = 'block';
        });
    }
</script>

</body>
</html>
