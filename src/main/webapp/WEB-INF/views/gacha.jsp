<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>선수 영입 - My Star League</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/gacha.css' />">
</head>
<body class="gacha-page">

<!-- TOPBAR -->
<header class="msl-topbar">
    <div class="msl-topbar-logo">MY STAR <span>LEAGUE</span></div>
    <div class="msl-topbar-center">
        <nav class="msl-breadcrumb">
            <a href="<c:url value='/mode-select' />">홈</a>
            <span class="sep">/</span>
            <span class="current">선수 영입</span>
        </nav>
    </div>
    <div class="msl-topbar-right">
        <div class="msl-crystal" id="userCrystal">&#128142; ${sessionScope.loginUser.crystal}</div>
        <div class="msl-user-label"><strong>${sessionScope.loginUser.userNick}</strong></div>
        <c:if test="${sessionScope.loginUser.userId == 'testuser3'}">
            <a href="<c:url value='/admin/stage' />" class="msl-btn-nav"
               style="background:rgba(239,68,68,0.15);border-color:#7f1d1d;color:#f87171;">&#9881; 관리자</a>
        </c:if>
        <a href="<c:url value='/logout' />" class="msl-btn-nav">LOGOUT</a>
    </div>
</header>

<!-- SIDEBAR -->
<c:set var="activeMenu" value="gacha" />
<%@ include file="/WEB-INF/views/layout/sideBar.jsp" %>

<!-- MAIN -->
<main class="msl-main">

    <div class="msl-page-header msl-animate">
        <div class="msl-page-header-left">
            <div class="msl-page-eyebrow">SCOUT &amp; RECRUIT</div>
            <div class="msl-page-title">선수 영입</div>
        </div>
    </div>

    <div class="gacha-grid msl-animate msl-animate-d1">

        <!-- 팩 선택 탭 바 -->
        <div class="pack-select-bar">
            <span class="pack-select-label">&#128230; 시즌 팩</span>
            <div class="pack-tabs" id="packTabs">
                <c:forEach items="${packList}" var="pack" varStatus="st">
                    <button class="pack-tab ${st.first ? 'active' : ''}" data-pack-seq="${pack.packSeq}">
                        ${pack.packName}
                    </button>
                </c:forEach>
                <c:if test="${empty packList}">
                    <span class="pack-empty-msg">현재 판매 중인 팩이 없습니다.</span>
                </c:if>
            </div>
        </div>

        <!-- 좌측: 뽑기 패널 -->
        <div class="gacha-main-panel msl-panel">
            <div class="pack-banner-wrap">
                <img id="packBannerImg" src="" alt="팩 배너" style="display:none;">
                <div class="pack-banner-fallback" id="packBannerFallback">
                    <span id="packBannerText">SELECT A PACK</span>
                </div>
            </div>
            <div class="pack-info-area">
                <div class="pack-info-name" id="packInfoName">팩을 선택하세요</div>
                <div class="pack-info-desc" id="packInfoDesc">위에서 원하는 팩을 선택하면 정보가 표시됩니다.</div>
                <div class="draw-btn-row">
                    <button class="draw-btn single" id="singleDrawBtn" disabled>
                        1회 뽑기
                        <span class="draw-btn-cost" id="singleCost">&#8212;</span>
                    </button>
                    <button class="draw-btn multi" id="multiDrawBtn" disabled>
                        10회 뽑기
                        <span class="draw-btn-cost" id="multiCost">&#8212;</span>
                    </button>
                </div>
            </div>
        </div>

        <!-- 우측: 주요 등장 선수 -->
        <div class="featured-panel msl-panel">
            <div class="msl-panel-head">
                <div class="msl-panel-title">&#11088; 주요 등장 선수</div>
            </div>
            <div class="featured-scroll" id="featuredScroll">
                <div class="featured-empty">팩을 선택하면 등장 선수 목록이 표시됩니다.</div>
            </div>
        </div>

    </div>
</main>

<!-- 뽑기 결과 모달 -->
<div class="draw-modal-overlay" id="drawModal">
    <div class="draw-modal" id="drawModalInner"></div>
</div>

<!-- 선수 상세 모달 -->
<div class="player-modal-overlay" id="playerModal">
    <div class="player-modal">
        <div class="player-modal-header">
            <span id="playerModalTitle" style="font-family:'Barlow Condensed',sans-serif;font-size:0.75rem;font-weight:700;letter-spacing:0.2em;text-transform:uppercase;color:var(--text-dim);">PLAYER INFO</span>
            <button class="player-modal-close" id="playerModalClose">✕</button>
        </div>
        <div class="player-modal-body">
            <div class="player-modal-top">
                <div id="playerModalImgWrap">
                    <div class="player-modal-img-placeholder">👤</div>
                </div>
                <div class="player-modal-info">
                    <div class="player-modal-name" id="playerModalName">—</div>
                    <div class="player-modal-badges" id="playerModalBadges"></div>
                    <div class="player-modal-cost" id="playerModalCost"></div>
                </div>
            </div>
            <div class="player-modal-stats" id="playerModalStats"></div>
        </div>
    </div>
</div>

<!-- 서버 데이터 -->
<script id="allPackDetailsScript" type="application/json">
<c:choose><c:when test="${not empty allPackDetailsJson}">${allPackDetailsJson}</c:when><c:otherwise>{}</c:otherwise></c:choose>
</script>
<script id="allFeaturedPlayersScript" type="application/json">
<c:choose><c:when test="${not empty allFeaturedPlayersJson}">${allFeaturedPlayersJson}</c:when><c:otherwise>{}</c:otherwise></c:choose>
</script>

<script>
(function() {
    var allPackDetails     = {};
    var allFeaturedPlayers = {};
    try {
        allPackDetails     = JSON.parse(document.getElementById('allPackDetailsScript').textContent);
        allFeaturedPlayers = JSON.parse(document.getElementById('allFeaturedPlayersScript').textContent);
    } catch(e) { console.error(e); }

    var contextPath = '<c:url value="/" />'.replace(/\/$/, '');
    var currentPackSeq = null;

    var packBannerImg  = document.getElementById('packBannerImg');
    var packBannerFb   = document.getElementById('packBannerFallback');
    var packBannerText = document.getElementById('packBannerText');
    var packInfoName   = document.getElementById('packInfoName');
    var packInfoDesc   = document.getElementById('packInfoDesc');
    var singleCostEl   = document.getElementById('singleCost');
    var multiCostEl    = document.getElementById('multiCost');
    var singleDrawBtn  = document.getElementById('singleDrawBtn');
    var multiDrawBtn   = document.getElementById('multiDrawBtn');
    var featuredScroll = document.getElementById('featuredScroll');
    var drawModal      = document.getElementById('drawModal');
    var playerModal    = document.getElementById('playerModal');

    /* 팩 탭 클릭 */
    document.getElementById('packTabs').addEventListener('click', function(e) {
        var btn = e.target.closest('.pack-tab');
        if (!btn) return;
        document.querySelectorAll('.pack-tab').forEach(function(t) { t.classList.remove('active'); });
        btn.classList.add('active');
        showPack(btn.dataset.packSeq);
    });

    /* 팩 표시 */
    function showPack(seqStr) {
        currentPackSeq = seqStr;
        var pack    = allPackDetails[seqStr];
        var players = allFeaturedPlayers[seqStr] || [];

        if (!pack) {
            packInfoName.textContent = '팩 정보 없음';
            packInfoDesc.textContent = '데이터를 불러올 수 없습니다.';
            singleCostEl.textContent = '\u2014';
            multiCostEl.textContent  = '\u2014';
            singleDrawBtn.disabled = true;
            multiDrawBtn.disabled  = true;
            packBannerImg.style.display = 'none';
            packBannerFb.style.display  = 'flex';
            packBannerText.textContent  = 'NO DATA';
            renderFeatured([]);
            return;
        }

        if (pack.bannerImgUrl && pack.bannerImgUrl.trim()) {
            packBannerImg.src = pack.bannerImgUrl;
            packBannerImg.alt = pack.packName + ' 배너';
            packBannerImg.style.display = 'block';
            packBannerFb.style.display  = 'none';
        } else {
            packBannerImg.style.display = 'none';
            packBannerFb.style.display  = 'flex';
            packBannerText.textContent  = (pack.packName || '').toUpperCase();
        }

        packInfoName.textContent = pack.packName || '\u2014';
        packInfoDesc.textContent = pack.description || '설명 없음';

        var cost = pack.costCrystal;
        if (cost && cost > 0) {
            singleCostEl.textContent = '\uD83D\uDC8E ' + cost;
            multiCostEl.textContent  = '\uD83D\uDC8E ' + (cost * 10);
        } else {
            singleCostEl.textContent = '무료';
            multiCostEl.textContent  = '무료';
        }
        singleDrawBtn.disabled = false;
        multiDrawBtn.disabled  = false;

        renderFeatured(players);
    }

    /* 주요 선수 렌더 */
    /* 현재 팩 선수 데이터 캐시 */
    var currentPlayers = [];

    function renderFeatured(players) {
        currentPlayers = players || [];
        if (currentPlayers.length === 0) {
            featuredScroll.innerHTML = '<div class="featured-empty">등장 선수 정보가 없습니다.</div>';
            return;
        }
        var order = {UR:1, SSR:2, SR:3, R:4, N:5};
        var sorted = currentPlayers.slice().sort(function(a,b) {
            return (order[a.rarity]||9) - (order[b.rarity]||9);
        });
        featuredScroll.innerHTML = sorted.map(function(p, idx) {
            var r    = (p.rarity || 'N').toLowerCase();
            var race = p.race || '?';
            // data-idx는 정렬 후 인덱스 — playerSeq로 찾을 것이므로 seq 저장
            return '<div class="featured-item" data-seq="' + p.playerSeq + '">'
                + '<span class="featured-rarity ' + r + '">' + esc(p.rarity || 'N') + '</span>'
                + '<span class="featured-name">' + esc(p.playerName || '이름없음') + '</span>'
                + '<span class="featured-race ' + race + '">' + race + '</span>'
                + '</div>';
        }).join('');
    }

    /* 선수 클릭 → 상세 모달 */
    featuredScroll.addEventListener('click', function(e) {
        var item = e.target.closest('.featured-item');
        if (!item) return;
        var seq = parseInt(item.dataset.seq);
        var player = currentPlayers.filter(function(p) { return p.playerSeq === seq; })[0];
        if (player) showPlayerModal(player);
    });

    /* 뽑기 */
    singleDrawBtn.addEventListener('click', function() { requestDraw(1); });
    multiDrawBtn.addEventListener('click',  function() { requestDraw(10); });

    async function requestDraw(count) {
        if (!currentPackSeq) { alert('팩을 선택하세요.'); return; }
        if (count > 1) { alert('10회 뽑기는 준비 중입니다.'); return; }
        var btns = [singleDrawBtn, multiDrawBtn];
        btns.forEach(function(b) { b.disabled = true; });
        try {
            var formData = new URLSearchParams();
            formData.append('packSeq', currentPackSeq);
            var res = await fetch(contextPath + '/gacha/draw', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: formData
            });
            if (!res.ok) throw new Error('HTTP ' + res.status);
            var result = await res.json();
            if (result.error === 'not_logged_in') {
                alert('로그인이 필요합니다.');
                location.href = contextPath + '/login';
                return;
            }
            if (result.success) {
                showDrawResult(result.player);
                if (result.updatedCurrency) {
                    var el = document.getElementById('userCrystal');
                    if (el) el.textContent = '\uD83D\uDC8E ' + (result.updatedCurrency.crystal || 0);
                }
            } else {
                alert('뽑기 실패: ' + (result.message || '알 수 없는 오류'));
            }
        } catch(e) {
            console.error(e);
            alert('요청 중 오류가 발생했습니다.');
        } finally {
            btns.forEach(function(b) { b.disabled = false; });
        }
    }

    /* 결과 모달 */
    var RARITY_EMOJI = {ur:'\uD83C\uDF08', ssr:'\u2B50', sr:'\uD83D\uDD35', r:'\uD83D\uDFE2', n:'\u26AA'};

    function showDrawResult(player) {
        if (!player) return;
        var r = (player.rarity || 'N').toLowerCase();
        var emoji = RARITY_EMOJI[r] || '\u26AA';
        document.getElementById('drawModalInner').innerHTML =
            '<div class="draw-modal-emoji">' + emoji + '</div>'
            + '<div class="draw-modal-rarity ' + r + '">['+ esc((player.rarity||'N').toUpperCase()) +']</div>'
            + '<div class="draw-modal-name">' + esc(player.playerName || '이름없음') + '</div>'
            + '<div class="draw-modal-sub">' + esc(player.race || '?') + '</div>'
            + '<button class="msl-btn msl-btn-primary" id="modalCloseBtn" style="width:100%;margin-top:1rem;">확인</button>';
        drawModal.classList.add('visible');
        document.getElementById('modalCloseBtn').addEventListener('click', closeModal);
    }

    function closeModal() { drawModal.classList.remove('visible'); }

    drawModal.addEventListener('click', function(e) { if (e.target === drawModal) closeModal(); });

    /* 선수 상세 모달 */
    function showPlayerModal(p) {
        var r = (p.rarity || 'N').toLowerCase();
        var RACE_ICON = {T:'🔵', P:'💜', Z:'🟢'};

        document.getElementById('playerModalName').textContent = p.playerName || '—';

        // 뱃지
        var badgeHtml = '<span class="msl-rarity ' + r + '">' + esc((p.rarity||'N').toUpperCase()) + '</span>'
            + ' <span class="msl-race ' + (p.race||'') + '">' + esc(p.race||'?') + '</span>';
        document.getElementById('playerModalBadges').innerHTML = badgeHtml;

        // 비용
        document.getElementById('playerModalCost').textContent = p.playerCost ? '💎 ' + p.playerCost + ' 크리스탈' : '';

        // 이미지
        var imgWrap = document.getElementById('playerModalImgWrap');
        if (p.playerImgUrl && p.playerImgUrl.trim()) {
            imgWrap.innerHTML = '<img class="player-modal-img" src="' + esc(p.playerImgUrl)
                + '" onerror="this.outerHTML=\'<div class=player-modal-img-placeholder>' + (RACE_ICON[p.race]||'👤') + '</div>\'">';
        } else {
            imgWrap.innerHTML = '<div class="player-modal-img-placeholder">' + (RACE_ICON[p.race]||'👤') + '</div>';
        }

        // 스탯
        var stats = [
            {key:'statAttack',  label:'ATK', cls:'atk'},
            {key:'statDefense', label:'DEF', cls:'def'},
            {key:'statMacro',   label:'MAC', cls:'mac'},
            {key:'statMicro',   label:'MIC', cls:'mic'},
            {key:'statLuck',    label:'LCK', cls:'lck'}
        ];
        document.getElementById('playerModalStats').innerHTML = stats.map(function(s) {
            return '<div class="stat-cell">'
                + '<div class="stat-cell-label">' + s.label + '</div>'
                + '<div class="stat-cell-value ' + s.cls + '">' + (p[s.key] || 0) + '</div>'
                + '</div>';
        }).join('');

        playerModal.classList.add('visible');
    }

    function closePlayerModal() { playerModal.classList.remove('visible'); }

    document.getElementById('playerModalClose').addEventListener('click', closePlayerModal);
    playerModal.addEventListener('click', function(e) { if (e.target === playerModal) closePlayerModal(); });

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') { closeModal(); closePlayerModal(); }
    });

    function esc(s) {
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    }

    /* 초기화 */
    var firstTab = document.querySelector('.pack-tab.active');
    if (firstTab) showPack(firstTab.dataset.packSeq);

})();
</script>
</body>
</html>