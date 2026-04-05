<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>훈련 - My Star League</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/pveTrain.css' />">
</head>
<body>

<header class="msl-topbar">
    <div class="msl-topbar-logo">MY STAR <span>LEAGUE</span></div>
    <div class="msl-topbar-center">
        <nav class="msl-breadcrumb">
            <a href="<c:url value='/mode-select' />">홈</a>
            <span class="sep">/</span>
            <span class="current">훈련</span>
        </nav>
    </div>
    <div class="msl-topbar-right">
        <div class="msl-crystal">💎 ${sessionScope.loginUser.crystal}</div>
        <div class="msl-user-label"><strong>${sessionScope.loginUser.userNick}</strong></div>
        <a href="<c:url value='/logout' />" class="msl-btn-nav">LOGOUT</a>
    </div>
</header>

<c:set var="activeMenu" value="train" />
<%@ include file="/WEB-INF/views/layout/sideBar.jsp" %>

<main class="msl-main">

    <header class="msl-page-header msl-animate">
        <div class="msl-page-header-left">
            <div class="msl-page-eyebrow">PLAYER TRAINING</div>
            <div class="msl-page-title">선수 훈련</div>
            <div class="msl-page-sub">1포인트 소모 시 랜덤 능력치 +3이 적용됩니다.</div>
        </div>
        <div class="msl-page-header-right">
            <div class="train-point-badge">
                💪 훈련 포인트 <span id="trainPointDisplay">${trainPoint}</span>
            </div>
        </div>
    </header>

    <div class="train-grid msl-animate msl-animate-d1">

        <!-- 좌측: 선수 목록 -->
        <div class="msl-panel train-list-panel">
            <div class="squad-toolbar">
                <div class="squad-filter-group">
                    <button class="filter-btn active" onclick="setFilter('race','ALL',this)">ALL</button>
                    <button class="filter-btn" onclick="setFilter('race','T',this)">T</button>
                    <button class="filter-btn" onclick="setFilter('race','P',this)">P</button>
                    <button class="filter-btn" onclick="setFilter('race','Z',this)">Z</button>
                </div>
                <div class="squad-filter-group">
                    <button class="filter-btn active" onclick="setFilter('rarity','ALL',this)">ALL</button>
                    <button class="filter-btn" onclick="setFilter('rarity','N',this)">N</button>
                    <button class="filter-btn" onclick="setFilter('rarity','R',this)">R</button>
                    <button class="filter-btn" onclick="setFilter('rarity','SR',this)">SR</button>
                    <button class="filter-btn" onclick="setFilter('rarity','SSR',this)">SSR</button>
                    <button class="filter-btn" onclick="setFilter('rarity','UR',this)">UR</button>
                </div>
            </div>

            <div class="squad-list-header">
                    <span style="color:var(--text-dim);font-family:'Barlow Condensed',sans-serif;font-size:0.78rem;font-weight:700;">등급</span>
                    <span style="color:var(--text-dim);font-family:'Barlow Condensed',sans-serif;font-size:0.78rem;font-weight:700;">종족</span>
                    <span style="color:var(--text-dim);font-family:'Barlow Condensed',sans-serif;font-size:0.78rem;font-weight:700;">이름</span>
                    <span class="sc-atk">ATK</span>
                    <span class="sc-def">DEF</span>
                    <span class="sc-mac">MAC</span>
                    <span class="sc-mic">MIC</span>
                    <span class="sc-luk">LUK</span>
                    <span class="sc-tot">TOT</span>
            </div>

            <div class="msl-panel-body" style="padding:0;">
                <ul class="squad-list-ul" id="playerList">
                    <c:choose>
                        <c:when test="${empty players}">
                            <li class="squad-no-records">보유한 선수가 없습니다.</li>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="p" items="${players}">
                                <li class="squad-list-item"
                                    data-seq="${p.ownedPlayerSeq}"
                                    data-race="${p.race}"
                                    data-rarity="${p.currentRarity}"
                                    data-atk="${p.currentAttack}"
                                    data-def="${p.currentDefense}"
                                    data-mac="${p.currentMacro}"
                                    data-mic="${p.currentMicro}"
                                    data-luk="${p.currentLuck}"
                                    data-img="${fn:escapeXml(p.playerImgUrl)}"
                                    data-condition="${p.condition}"
                                    data-winstreak="${p.winStreak}"
                                    onclick="selectPlayer(this)">
                                        <span class="msl-rarity ${fn:toLowerCase(p.currentRarity)}">${p.currentRarity}</span>
                                        <span class="msl-race ${p.race}">${p.race}</span>
                                        <span class="list-player-name">${fn:escapeXml(p.playerName)}</span>
                                        <span class="sc-atk">${p.currentAttack}</span>
                                        <span class="sc-def">${p.currentDefense}</span>
                                        <span class="sc-mac">${p.currentMacro}</span>
                                        <span class="sc-mic">${p.currentMicro}</span>
                                        <span class="sc-luk">${p.currentLuck}</span>
                                        <span class="sc-tot train-total-stat">${p.currentAttack + p.currentDefense + p.currentMacro + p.currentMicro + p.currentLuck}</span>
                                </li>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </ul>
            </div>
        </div>

        <!-- 우측: 선수 상세 + 훈련 -->
        <div class="train-right-col">

            <!-- 우측 단일 패널: 선수 상세 + 훈련 -->
            <div class="msl-panel train-right-panel">
                <!-- 선수 상세 -->
                <div class="train-detail-area">
                    <div id="cardPlaceholder">
                        <div class="placeholder-icon">👈</div>
                        <p>좌측 목록에서 선수를 선택해주세요.</p>
                    </div>
                    <div id="cardContent">
                        <div class="squad-card-header">
                            <div class="squad-card-title">
                                <h2 id="cardName"></h2>
                            </div>
                            <div class="squad-card-meta">
                                <span class="msl-rarity" id="cardRarity"></span>
                                <span class="msl-race" id="cardRace"></span>
                                <span class="condition-badge" id="cardCondition"></span>
                                <span class="streak-badge" id="cardStreak" style="display:none;"></span>
                            </div>
                        </div>
                        <div class="squad-card-body-flex">
                            <div class="squad-card-img" id="cardImgWrap">
                                <img id="cardImg" src="" alt="" style="display:none;">
                                <span id="cardImgFallback" style="font-size:2.5rem;">👤</span>
                            </div>
                            <div class="squad-stat-list" id="statList"></div>
                        </div>

                        <!-- 특수 강화 재료 슬롯 (미구현) -->
                        <div class="special-enhance-area">
                            <div class="special-enhance-title">⚗️ 특수 강화 <span class="locked-badge">미구현</span></div>
                            <div class="special-enhance-desc">재료를 선택한 상태로 훈련하면 특수 강화가 적용됩니다. 능력치 총합이 높을수록 더 많은 재료가 소모됩니다.</div>
                            <div class="special-slots">
                                <div class="special-slot locked" id="specialSlot1" onclick="toggleSlot(1)">
                                    <div class="slot-icon">🔒</div>
                                    <div class="slot-name">강화석 I</div>
                                    <div class="slot-stock">보유 0개</div>
                                </div>
                                <div class="special-slot locked" id="specialSlot2" onclick="toggleSlot(2)">
                                    <div class="slot-icon">🔒</div>
                                    <div class="slot-name">강화석 II</div>
                                    <div class="slot-stock">보유 0개</div>
                                </div>
                                <div class="special-slot locked" id="specialSlot3" onclick="toggleSlot(3)">
                                    <div class="slot-icon">🔒</div>
                                    <div class="slot-name">강화석 III</div>
                                    <div class="slot-stock">보유 0개</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 훈련하기 (하단 고정) -->
                <div class="train-action-area">
                    <div class="train-action-divider"></div>
                    <div class="train-action-body">
                        <div id="trainPlaceholder" class="train-action-placeholder">선수를 선택하면 훈련할 수 있습니다.</div>
                        <div id="trainAction" style="display:none;">
                            <p class="train-action-desc"><span id="trainTargetName"></span> 선수를 훈련합니다. 포인트 1 소모 시 랜덤 능력치 +3이 적용됩니다.</p>
                            <button class="msl-btn msl-btn-primary train-do-btn" id="trainBtn" onclick="doTrain()">
                                💪 훈련하기 (포인트 1 소모)
                            </button>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>
</main>

<!-- 훈련 결과 모달 -->
<div class="train-modal-overlay" id="trainModal">
    <div class="train-modal">
        <div class="train-modal-title" id="modalPlayerName"></div>
        <div class="train-modal-sub">훈련 완료! 능력치가 상승했습니다.</div>
        <div class="radar-wrap">
            <svg id="radarSvg" viewBox="0 0 220 220" xmlns="http://www.w3.org/2000/svg"></svg>
        </div>
        <div class="train-modal-stats" id="modalStats"></div>
        <button class="msl-btn msl-btn-primary" onclick="closeTrainModal()" style="width:100%;justify-content:center;margin-top:0.5rem;">확인</button>
    </div>
</div>

<script>
    const CTX = '${pageContext.request.contextPath}';
    let selectedSeq  = null;
    let selectedItem = null;
    let filterRace   = 'ALL';
    let filterRarity = 'ALL';

    // ── 선수 선택 ──────────────────────────────────────────
    function selectPlayer(el) {
        document.querySelectorAll('.squad-list-item').forEach(c => c.classList.remove('active'));
        el.classList.add('active');
        selectedSeq  = el.dataset.seq;
        selectedItem = el;

        const name = el.querySelector('.list-player-name').textContent;
        const race   = el.dataset.race;
        const rarity = el.dataset.rarity;

        // 우측 상단 패널 업데이트 (seq로 fetch 없이 카드에서 직접 읽기)
        document.getElementById('cardPlaceholder').style.display = 'none';
        document.getElementById('cardContent').classList.add('visible');
        document.getElementById('cardName').textContent = name;

        const rarityEl = document.getElementById('cardRarity');
        rarityEl.textContent  = rarity;
        rarityEl.className    = 'msl-rarity ' + rarity.toLowerCase();
        const raceEl = document.getElementById('cardRace');
        raceEl.textContent = race;
        raceEl.className   = 'msl-race ' + race;

        // 선수 이미지
        var imgUrl = el.dataset.img || '';
        var imgEl  = document.getElementById('cardImg');
        var fallEl = document.getElementById('cardImgFallback');
        if (imgUrl) {
            imgEl.src = imgUrl;
            imgEl.style.display = 'block';
            fallEl.style.display = 'none';
        } else {
            imgEl.style.display = 'none';
            fallEl.style.display = 'block';
        }

        // 스탯 바는 카드에서 읽어옴
        renderStatBars(el);

        // 컨디션 뱃지
        var condition = el.dataset.condition || 'NORMAL';
        var winStreak = parseInt(el.dataset.winstreak || 0);
        var COND_LABEL = {PEAK:'🔥 최상', GOOD:'😊 양호', NORMAL:'😐 보통', TIRED:'😓 피로', WORST:'😰 최악'};
        var COND_COLOR = {PEAK:'#ffd600', GOOD:'#4caf7d', NORMAL:'#aaa', TIRED:'#ff9800', WORST:'#ef5350'};
        var condEl = document.getElementById('cardCondition');
        condEl.textContent = COND_LABEL[condition] || condition;
        condEl.style.background = (COND_COLOR[condition] || '#aaa') + '22';
        condEl.style.borderColor = COND_COLOR[condition] || '#aaa';
        condEl.style.color = COND_COLOR[condition] || '#aaa';
        var streakEl = document.getElementById('cardStreak');
        if (winStreak > 0) {
            streakEl.textContent = '🔥 ' + winStreak + '연승 +' + Math.min(winStreak,10) + '%';
            streakEl.style.display = '';
        } else {
            streakEl.style.display = 'none';
        }

        // 훈련 패널
        document.getElementById('trainPlaceholder').style.display = 'none';
        document.getElementById('trainAction').style.display = 'block';
        document.getElementById('trainTargetName').textContent = name;

        const tp  = parseInt(document.getElementById('trainPointDisplay').textContent);
        const btn = document.getElementById('trainBtn');
        btn.disabled = tp < 1;
        btn.textContent = tp < 1 ? '훈련 포인트 부족' : '💪 훈련하기 (포인트 1 소모)';
    }


    function renderStatBars(listItem) {
        var stats = [
            {label:'공격',   val: parseInt(listItem.dataset.atk||0), cls:'atk', id:'sv-atk'},
            {label:'수비',   val: parseInt(listItem.dataset.def||0), cls:'def', id:'sv-def'},
            {label:'매크로', val: parseInt(listItem.dataset.mac||0), cls:'mac', id:'sv-mac'},
            {label:'컨트롤', val:parseInt(listItem.dataset.mic||0), cls:'mic', id:'sv-mic'},
            {label:'럭',     val: parseInt(listItem.dataset.luk||0), cls:'luk', id:'sv-luk'},
        ];
        document.getElementById('statList').innerHTML = stats.map(function(s) {
            var pct = Math.min(s.val / 1.5, 100);
            return '<div class="squad-stat-item">'
                + '<span class="squad-stat-label">' + s.label + '</span>'
                + '<span class="squad-stat-value" id="' + s.id + '">' + s.val + '</span>'
                + '<div class="squad-stat-bar"><div class="squad-stat-bar-fill train-bar-' + s.cls
                + '" id="bar-' + s.id + '" style="width:' + pct + '%"></div></div>'
                + '</div>';
        }).join('');
    }

    // ── 필터 ──────────────────────────────────────────
    function setFilter(type, val, btn) {
        btn.closest('.squad-filter-group').querySelectorAll('.filter-btn').forEach(function(b){ b.classList.remove('active'); });
        btn.classList.add('active');
        if (type === 'race')   filterRace   = val;
        if (type === 'rarity') filterRarity = val;
        applyFilter();
    }

    function applyFilter() {
        document.querySelectorAll('.squad-list-item').forEach(function(item) {
            var raceOk   = filterRace   === 'ALL' || item.dataset.race   === filterRace;
            var rarityOk = filterRarity === 'ALL' || item.dataset.rarity === filterRarity;
            item.style.display = (raceOk && rarityOk) ? '' : 'none';
        });
    }

    // ── 훈련 실행 ──────────────────────────────────────────
    function doTrain() {
        if (!selectedSeq) return;
        const btn = document.getElementById('trainBtn');
        btn.disabled = true;
        btn.textContent = '훈련 중...';

        fetch(CTX + '/pve/train/use', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'ownedPlayerSeq=' + selectedSeq
        })
        .then(r => r.json())
        .then(function(data) {
            if (!data.success) { alert(data.message); btn.disabled = false; btn.textContent = '💪 훈련하기 (포인트 1 소모)'; return; }

            // 포인트 업데이트
            document.getElementById('trainPointDisplay').textContent = data.remainPoint;

            // 스탯 바 업데이트
            var updates = [
                ['sv-atk', 'bar-sv-atk', data.afterAttack],
                ['sv-def', 'bar-sv-def', data.afterDefense],
                ['sv-mac', 'bar-sv-mac', data.afterMacro],
                ['sv-mic', 'bar-sv-mic', data.afterMicro],
                ['sv-luk', 'bar-sv-luk', data.afterLuck],
            ];
            updates.forEach(function(u) {
                var valEl = document.getElementById(u[0]);
                var barEl = document.getElementById(u[1]);
                if (valEl) valEl.textContent = u[2];
                if (barEl) barEl.style.width = Math.min(u[2] / 1.5, 100) + '%';
            });

            // 목록 총합 + 개별 스탯 업데이트
            if (selectedItem) {
                selectedItem.dataset.atk = data.afterAttack;
                selectedItem.dataset.def = data.afterDefense;
                selectedItem.dataset.mac = data.afterMacro;
                selectedItem.dataset.mic = data.afterMicro;
                selectedItem.dataset.luk = data.afterLuck;
                var total = data.afterAttack + data.afterDefense + data.afterMacro + data.afterMicro + data.afterLuck;
                var totalEl = selectedItem.querySelector('.train-total-stat');
                if (totalEl) totalEl.textContent = total;
                // 목록 개별 스탯 업데이트
                var sc = selectedItem.querySelectorAll('.sc-atk, .sc-def, .sc-mac, .sc-mic, .sc-luk, .sc-tot');
                if (sc.length >= 6) {
                    sc[0].textContent = data.afterAttack;
                    sc[1].textContent = data.afterDefense;
                    sc[2].textContent = data.afterMacro;
                    sc[3].textContent = data.afterMicro;
                    sc[4].textContent = data.afterLuck;
                    sc[5].textContent = total;
                }
                renderStatBars(selectedItem);
            }

            // 모달
            var incs   = [data.attackInc, data.defenseInc, data.macroInc, data.microInc, data.luckInc];
            var afters = [data.afterAttack, data.afterDefense, data.afterMacro, data.afterMicro, data.afterLuck];
            var before = afters.map(function(v, i){ return v - incs[i]; });
            var labels = ['공격','수비','매크로','컨트롤','럭'];

            document.getElementById('modalPlayerName').textContent = selectedItem.querySelector('.list-player-name').textContent + ' 훈련 결과';
            document.getElementById('modalStats').innerHTML = labels.map(function(lbl, i) {
                var cls = incs[i] === 0 ? ' zero' : '';
                var val = incs[i] > 0 ? '+' + incs[i] : incs[i];
                return '<span class="result-stat-chip' + cls + '">' + lbl + ' <b>' + val + '</b></span>';
            }).join('');

            drawRadar(before, afters, labels);
            document.getElementById('trainModal').classList.add('show');

            // 선수 카드 data 속성 갱신 (다시 클릭 시 최신값 반영)
            if (selectedItem) {
                selectedItem.dataset.atk = data.afterAttack;
                selectedItem.dataset.def = data.afterDefense;
                selectedItem.dataset.mac = data.afterMacro;
                selectedItem.dataset.mic = data.afterMicro;
                selectedItem.dataset.luk = data.afterLuck;
            }

            var remaining = data.remainPoint;
            btn.disabled = remaining < 1;
            btn.textContent = remaining < 1 ? '훈련 포인트 부족' : '💪 훈련하기 (포인트 1 소모)';
        })
        .catch(function(){ alert('오류가 발생했습니다.'); btn.disabled = false; });
    }

    // ── 모달 ──────────────────────────────────────────
    function closeTrainModal() {
        document.getElementById('trainModal').classList.remove('show');
    }

    // ── 레이더 차트 ──────────────────────────────────────────
    function drawRadar(before, after, labels) {
        var svg = document.getElementById('radarSvg');
        var cx = 110, cy = 110, r = 80, n = 5;
        var MAX_STAT = 150;

        function toXY(idx, val) {
            var angle = (Math.PI * 2 / n) * idx - Math.PI / 2;
            var ratio = Math.min(val / MAX_STAT, 1);
            return { x: cx + r * ratio * Math.cos(angle), y: cy + r * ratio * Math.sin(angle) };
        }
        function axisXY(idx, scale) {
            var angle = (Math.PI * 2 / n) * idx - Math.PI / 2;
            return { x: cx + r * scale * Math.cos(angle), y: cy + r * scale * Math.sin(angle) };
        }

        var html = '';
        [0.2, 0.4, 0.6, 0.8, 1.0].forEach(function(s) {
            var pts = Array.from({length: n}, function(_, i) { var p = axisXY(i, s); return p.x + ',' + p.y; }).join(' ');
            html += '<polygon points="' + pts + '" fill="none" stroke="rgba(255,255,255,0.07)" stroke-width="1"/>';
        });
        for (var i = 0; i < n; i++) {
            var p = axisXY(i, 1);
            html += '<line x1="' + cx + '" y1="' + cy + '" x2="' + p.x + '" y2="' + p.y + '" stroke="rgba(255,255,255,0.08)" stroke-width="1"/>';
        }
        var bPts = before.map(function(v, i) { var p = toXY(i, v); return p.x + ',' + p.y; }).join(' ');
        html += '<polygon points="' + bPts + '" fill="rgba(68,138,255,0.12)" stroke="rgba(68,138,255,0.45)" stroke-width="1.5"/>';
        html += '<polygon id="radarAfter" points="' + bPts + '" fill="rgba(0,230,118,0.18)" stroke="var(--green)" stroke-width="2"/>';
        labels.forEach(function(lbl, i) {
            var p = axisXY(i, 1.22);
            html += '<text x="' + p.x + '" y="' + p.y + '" text-anchor="middle" dominant-baseline="middle" font-size="11" fill="var(--text-dim)">' + lbl + '</text>';
        });
        svg.innerHTML = html;

        var afterPts  = after.map(function(v, i)  { var p = toXY(i, v); return {x: p.x, y: p.y}; });
        var beforePts = before.map(function(v, i) { var p = toXY(i, v); return {x: p.x, y: p.y}; });
        var duration  = 700, start = performance.now();
        function animate(now) {
            var t    = Math.min((now - start) / duration, 1);
            var ease = 1 - Math.pow(1 - t, 3);
            var pts  = beforePts.map(function(bp, i) {
                var ap = afterPts[i];
                return (bp.x + (ap.x - bp.x) * ease) + ',' + (bp.y + (ap.y - bp.y) * ease);
            }).join(' ');
            var el = document.getElementById('radarAfter');
            if (el) el.setAttribute('points', pts);
            if (t < 1) requestAnimationFrame(animate);
        }
        requestAnimationFrame(animate);
    }
    // ── 특수 강화 슬롯 (미구현 - 토글만) ──
    var selectedSlot = null;
    function toggleSlot(num) {
        // 미구현 알림
        alert('특수 강화 재료 기능은 아직 구현 중입니다.');
    }

    // ── 페이지 로드 시 첫 번째 선수 자동 선택 ──
    window.addEventListener('DOMContentLoaded', function() {
        var first = document.querySelector('.squad-list-item');
        if (first) selectPlayer(first);
    });
</script>

</body>
</html>
