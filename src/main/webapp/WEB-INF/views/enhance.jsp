<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>선수 강화 - My Star League</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/myTeam.css' />">
    <link rel="stylesheet" href="<c:url value='/css/enhance.css' />">
</head>
<body class="enhance-page">

<header class="msl-topbar">
    <div class="msl-topbar-logo">MY STAR <span>LEAGUE</span></div>
    <div class="msl-topbar-center">
        <nav class="msl-breadcrumb">
            <a href="<c:url value='/mode-select' />">홈</a>
            <span class="sep">/</span>
            <span class="current">선수 강화</span>
        </nav>
    </div>
    <div class="msl-topbar-right">
        <div class="msl-crystal">💎 ${sessionScope.loginUser.crystal}</div>
        <div class="msl-user-label"><strong>${sessionScope.loginUser.userNick}</strong></div>
        <a href="<c:url value='/logout' />" class="msl-btn-nav">LOGOUT</a>
    </div>
</header>

<c:set var="activeMenu" value="enhance" />
<%@ include file="/WEB-INF/views/layout/sideBar.jsp" %>

<main class="msl-main">

    <header class="msl-page-header msl-animate">
        <div class="msl-page-header-left">
            <div class="msl-page-eyebrow">PLAYER ENHANCEMENT</div>
            <div class="msl-page-title">선수 강화</div>
            <div class="msl-page-sub">동일 선수(같은 팩) 중복 카드를 재료로 강화합니다. 강화 능력치는 경기 패배에도 감소하지 않습니다.</div>
        </div>
    </header>

    <div class="squad-grid msl-animate msl-animate-d1">

        <!-- ── 좌측: 선수 목록 (myTeam 동일) ── -->
        <div class="msl-panel squad-list-panel">
            <div class="myteam-toolbar">
                <input type="text" id="searchInput" placeholder="🔍 이름 검색..." oninput="filterList()">
                <div class="toolbar-sep"></div>
                <select id="filterRace" onchange="filterList()">
                    <option value="">종족 전체</option>
                    <option value="T">T 테란</option>
                    <option value="P">P 프로토스</option>
                    <option value="Z">Z 저그</option>
                </select>
                <select id="filterRarity" onchange="filterList()">
                    <option value="">등급 전체</option>
                    <option value="ur">UR</option>
                    <option value="ssr">SSR</option>
                    <option value="sr">SR</option>
                    <option value="r">R</option>
                    <option value="n">N</option>
                </select>
                <select id="filterPack" onchange="filterList()">
                    <option value="">팩 전체</option>
                </select>
                <span class="player-count" id="countLabel"></span>
            </div>

            <div class="msl-panel-body" style="padding:0;overflow-y:auto;">
                <table class="player-table myteam-table">
                    <thead>
                        <tr>
                            <th>종족</th>
                            <th>등급</th>
                            <th class="col-enhance-th">강화</th>
                            <th class="name-header">이름</th>
                            <th class="col-atk">ATK</th>
                            <th class="col-def">DEF</th>
                            <th class="col-mac">MAC</th>
                            <th class="col-mic">MIC</th>
                            <th class="col-luk">LCK</th>
                            <th>합계</th>
                            <th>상태</th>
                            <th>경기력</th>
                        </tr>
                    </thead>
                    <tbody id="playerTableBody">
                        <c:choose>
                            <c:when test="${empty players}">
                                <tr><td colspan="11" style="text-align:center;padding:30px;color:#4a5568">보유한 선수가 없습니다.</td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="player" items="${players}">
                                    <tr class="myteam-row"
                                        data-seq="${player.ownedPlayerSeq}"
                                        data-name="${fn:toLowerCase(player.playerName)}"
                                        data-race="${player.race}"
                                        data-rarity="${fn:toLowerCase(player.currentRarity)}"
                                        data-condition="${player.condition}"
                                        data-pack="${fn:escapeXml(player.packName)}"
                                        onclick="selectPlayerRow(this, ${player.ownedPlayerSeq})">
                                        <td class="col-race col-race-${player.race}">${player.race == 'T' ? '테란' : player.race == 'P' ? '토스' : '저그'}</td>
                                        <td class="col-rarity col-rarity-${fn:toLowerCase(player.currentRarity)}">${player.currentRarity}</td>
                                        <td class="col-enhance-lv"><c:choose><c:when test="${player.enhanceLevel > 0}">${player.enhanceLevel}강</c:when><c:otherwise>-</c:otherwise></c:choose></td>
                                        <td class="col-name">${fn:escapeXml(player.playerName)}</td>
                                        <td class="col-atk">${player.currentAttack  + player.enhanceAttack}</td>
                                        <td class="col-def">${player.currentDefense + player.enhanceDefense}</td>
                                        <td class="col-mac">${player.currentMacro   + player.enhanceMacro}</td>
                                        <td class="col-mic">${player.currentMicro   + player.enhanceMicro}</td>
                                        <td class="col-luk">${player.currentLuck    + player.enhanceLuck}</td>
                                        <td class="col-tot">${player.currentAttack+player.enhanceAttack+player.currentDefense+player.enhanceDefense+player.currentMacro+player.enhanceMacro+player.currentMicro+player.enhanceMicro+player.currentLuck+player.enhanceLuck}</td>
                                        <td class="cond-cell" data-cond="${player.condition}"></td>
                                        <td class="streak-cell" data-streak="${player.winStreak}"></td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- ── 우측: 선수 상세 + 강화 (myTeam 구조 동일) ── -->
        <div class="squad-right-col enhance-right-col">
            <div class="msl-panel squad-detail-panel enhance-detail-panel">

                <!-- placeholder -->
                <div class="msl-panel-body squad-detail-body" id="cardPlaceholder">
                    <div class="placeholder-icon">👈</div>
                    <p>좌측 목록에서 강화할 선수를 선택해주세요.</p>
                </div>

                <!-- 선수 상세 (myTeam 동일 구조) -->
                <div class="msl-panel-body squad-detail-body enhance-scroll-body" id="cardContent" style="display:none;">

                    <!-- 1. 아이덴티티 (myTeam 동일) -->
                    <div class="pro-identity-section">
                        <div class="pro-avatar">
                            <img id="cardImg" src="" alt="" style="display:none;">
                            <div id="cardImgFallback">👤</div>
                        </div>
                        <div class="pro-headline">
                            <div class="pro-badges">
                                <span id="cardRace"></span>
                                <span id="cardRarity"></span>
                                <span id="cardPack"></span>
                                <span id="cardEnhanceBadge" class="badge-tag enhance-lv-badge"></span>
                            </div>
                            <h2 class="pro-name" id="cardName"></h2>
                            <div class="pro-bio-strip">
                                <span class="bio-highlight" id="profileTeam"></span>
                                <span class="bio-divider"></span>
                                <span id="profileBirth"></span>
                            </div>
                        </div>
                    </div>

                    <!-- 2. 데이터 분석: 능력치 + 강화 현황 -->
                    <div class="pro-analytics-section">
                        <div class="pro-data-box stat-box">
                            <h3 class="box-title">능력치 스카우팅</h3>
                            <div class="pro-stat-list" id="statList"></div>
                        </div>
                        <div class="pro-data-box">
                            <h3 class="box-title">강화 현황</h3>
                            <div class="enhance-stat-detail" id="enhanceStatDetail">
                                <div class="enhance-stat-detail-placeholder">선수를 선택하세요.</div>
                            </div>
                        </div>
                    </div>

                    <!-- 3. 강화 전용 섹션 -->
                    <div class="enhance-section">
                        <div class="enhance-info-card">
                            <div>
                                <div class="enhance-info-item-label">현재 강화</div>
                                <div class="enhance-info-item-val" id="infoLevel">+0</div>
                            </div>
                            <div>
                                <div class="enhance-info-item-label">성공 확률</div>
                                <div class="enhance-info-item-val success-rate" id="infoRate">-</div>
                            </div>
                            <div>
                                <div class="enhance-info-item-label">재료 보유</div>
                                <div class="enhance-info-item-val material-count" id="infoMaterial">-</div>
                            </div>
                        </div>
                        <p class="enhance-material-desc">
                            재료 조건: 동일 선수 + 동일 팩 카드 1장 소모<br>
                            강화 성공 시 5개 스탯 중 랜덤 +1 (패배에도 감소 없음)
                        </p>
                    </div>
                </div>

                <!-- 강화 버튼 (하단 고정) -->
                <div class="enhance-action-area" id="enhanceActionArea" style="display:none;">
                    <button class="msl-btn enhance-do-btn" id="enhanceBtn" onclick="doEnhance()">
                        ⚡ 강화하기
                    </button>
                </div>

            </div>
        </div>
    </div>
</main>

<!-- 강화 모달 -->
<div class="enhance-modal-overlay" id="enhanceModal">
    <div class="enhance-modal">

        <!-- 강화 중 화면 -->
        <div id="modalLoading" style="display:none;">
            <div class="loading-anvil" id="loadingAnvil">⚒️</div>
            <div class="loading-sparks" id="loadingSparks"></div>
            <div class="loading-title">강화 중...</div>
            <div class="loading-bar-wrap"><div class="loading-bar" id="loadingBar"></div></div>
        </div>

        <!-- 결과 화면 -->
        <div id="modalResult" style="display:none;">
            <div class="enhance-result-icon" id="modalIcon"></div>
            <div class="enhance-result-title" id="modalTitle"></div>
            <div class="enhance-result-msg"   id="modalMsg"></div>
            <div id="modalStatChips" style="margin-bottom:0.5rem;"></div>
            <div class="enhance-result-next"  id="modalNext"></div>
            <button class="msl-btn msl-btn-primary" onclick="closeModal()"
                    style="width:100%;justify-content:center;margin-top:1rem;">확인</button>
        </div>

    </div>
</div>

<script>
    const CTX = '${pageContext.request.contextPath}';

    /* ── 컨디션 셀 초기화 (myTeam 동일) ── */
    const COND_LABEL = {PEAK:'🔥 최상', GOOD:'😊 양호', NORMAL:'😐 보통', TIRED:'😓 피로', WORST:'😰 최악'};
    const COND_COLOR = {PEAK:'#ffd600', GOOD:'#4caf7d', NORMAL:'#aaa', TIRED:'#ff9800', WORST:'#ef5350'};
    document.querySelectorAll('.cond-cell').forEach(function(td) {
        var cond = td.dataset.cond || 'NORMAL';
        td.innerHTML = '<span style="font-size:0.72rem;font-weight:700;padding:2px 6px;border-radius:4px;border:1px solid '+(COND_COLOR[cond]||'#aaa')+'22;background:'+(COND_COLOR[cond]||'#aaa')+'22;color:'+(COND_COLOR[cond]||'#aaa')+'">'+(COND_LABEL[cond]||cond)+'</span>';
    });

    /* ── 경기력(연승) 셀 초기화 (myTeam 동일) ── */
    document.querySelectorAll('.streak-cell').forEach(function(td) {
        var ws = Math.min(parseInt(td.dataset.streak || 0), 5);
        var bars = '';
        for (var i = 0; i < 5; i++) {
            var bg = i < ws ? '#4caf7d' : 'rgba(255,255,255,0.1)';
            bars += '<span style="display:inline-block;width:5px;height:14px;border-radius:2px;margin:0 1px;background:'+bg+';vertical-align:middle;"></span>';
        }
        td.innerHTML = bars;
    });

    /* ── 팩 드롭다운 빌드 ── */
    (function buildPackDropdown() {
        var packs = {};
        document.querySelectorAll('.myteam-row').forEach(function(row) {
            var p = row.dataset.pack || '';
            if (p) packs[p] = true;
        });
        var sel = document.getElementById('filterPack');
        Object.keys(packs).sort().forEach(function(name) {
            var opt = document.createElement('option');
            opt.value = name; opt.textContent = name;
            sel.appendChild(opt);
        });
    })();

    /* ── 필터 ── */
    function filterList() {
        var q    = document.getElementById('searchInput').value.toLowerCase();
        var race = document.getElementById('filterRace').value;
        var rar  = document.getElementById('filterRarity').value;
        var pack = document.getElementById('filterPack').value;
        var cnt  = 0;
        document.querySelectorAll('.myteam-row').forEach(function(row) {
            var ok = (!q    || row.dataset.name.includes(q))
                  && (!race || row.dataset.race === race)
                  && (!rar  || row.dataset.rarity === rar)
                  && (!pack || row.dataset.pack === pack);
            row.style.display = ok ? '' : 'none';
            if (ok) cnt++;
        });
        document.getElementById('countLabel').textContent = cnt + '명';
    }
    filterList();

    /* ── 선수 선택 ── */
    var selectedSeq = null;

    function selectPlayerRow(element, seq) {
        document.querySelectorAll('.myteam-row').forEach(function(el){ el.classList.remove('active'); });
        if (element) element.classList.add('active');
        selectedSeq = seq;
        loadPlayerDetail(seq);
    }

    async function loadPlayerDetail(seq) {
        showCardLoading();
        try {
            const [detailRes, enhanceRes] = await Promise.all([
                fetch(CTX + '/my-team/details?seq=' + seq),
                fetch(CTX + '/enhance/info?ownedPlayerSeq=' + seq)
            ]);
            const detailData  = await detailRes.json();
            const enhanceData = await enhanceRes.json();

            if (detailData.error === 'not_logged_in') { location.href = CTX + '/login'; return; }
            if (!detailData.success) { showCardError(); return; }

            updateDetailView(detailData.details, enhanceData);
        } catch(err) {
            console.error(err);
            showCardError();
        }
    }

    function updateDetailView(details, enhanceData) {
        document.getElementById('cardPlaceholder').style.display = 'none';
        document.getElementById('cardContent').style.display     = 'flex';
        document.getElementById('enhanceActionArea').style.display = '';

        /* 종족/등급/팩 뱃지 */
        var raceMap = {T:'테란', P:'프로토스', Z:'저그'};
        var raceEl  = document.getElementById('cardRace');
        raceEl.textContent = raceMap[details.race] || details.race || '-';
        raceEl.className   = 'badge-tag col-race-' + (details.race || '');

        var rarEl  = document.getElementById('cardRarity');
        var rVal   = (details.currentRarity || details.rarity || '');
        rarEl.textContent = rVal.toUpperCase();
        rarEl.className   = 'badge-tag col-rarity-' + rVal.toLowerCase();

        var packEl = document.getElementById('cardPack');
        packEl.textContent = details.packName ? details.packName : '기본 지급';
        packEl.className   = 'badge-tag pack-yellow';

        /* 강화 레벨 뱃지 */
        var elv     = enhanceData.enhanceLevel || 0;
        var lvBadge = document.getElementById('cardEnhanceBadge');
        if (elv > 0) {
            lvBadge.textContent  = '+' + elv + ' 강화';
            lvBadge.className    = 'badge-tag enhance-lv-badge' + (elv >= 99 ? ' max' : '');
            lvBadge.style.display = '';
        } else {
            lvBadge.style.display = 'none';
        }

        /* 이름, 바이오 */
        document.getElementById('cardName').textContent        = details.playerName;
        document.getElementById('profileTeam').textContent     = details.teamName || '무소속';
        document.getElementById('profileBirth').textContent    = details.nationality ? details.nationality : '';

        /* 이미지 */
        var imgEl  = document.getElementById('cardImg');
        var fallEl = document.getElementById('cardImgFallback');
        if (details.playerImgUrl) {
            imgEl.src = details.playerImgUrl;
            imgEl.style.display  = 'block';
            fallEl.style.display = 'none';
        } else {
            imgEl.style.display  = 'none';
            fallEl.style.display = 'block';
        }

        /* 능력치 바 (total = base + enhance) */
        var eAtk = enhanceData.enhanceAttack  || 0;
        var eDef = enhanceData.enhanceDefense || 0;
        var eMac = enhanceData.enhanceMacro   || 0;
        var eMic = enhanceData.enhanceMicro   || 0;
        var eLuk = enhanceData.enhanceLuck    || 0;
        var statDefs = [
            {label:'ATK', name:'공격',   base: details.currentAttack,  enh: eAtk, color:'#f87171'},
            {label:'DEF', name:'수비',   base: details.currentDefense, enh: eDef, color:'#60a5fa'},
            {label:'MAC', name:'매크로', base: details.currentMacro,   enh: eMac, color:'#34d399'},
            {label:'MIC', name:'컨트롤', base: details.currentMicro,   enh: eMic, color:'#fbbf24'},
            {label:'LCK', name:'럭',     base: details.currentLuck,    enh: eLuk, color:'#a78bfa'}
        ];
        document.getElementById('statList').innerHTML = statDefs.map(function(s) {
            var total   = s.base + s.enh;
            var basePct = Math.min(s.base / 1.5, 100);
            var enhTxt  = s.enh > 0
                ? '<span class="stat-enh-val" style="color:' + s.color + '">(+' + s.enh + ')</span>'
                : '<span class="stat-enh-val"></span>';
            return '<div class="pro-stat-item">'
                 + '<div class="pro-stat-info"><span class="stat-lbl">' + s.label + '</span></div>'
                 + '<div class="pro-stat-bar-bg"><div class="pro-stat-bar-fill" style="width:' + basePct + '%;background:' + s.color + ';box-shadow:0 0 8px ' + s.color + '80;"></div></div>'
                 + '<div class="pro-stat-val" style="color:' + s.color + '">' + total + '</div>'
                 + enhTxt
                 + '</div>';
        }).join('');

        /* 강화 현황 박스 — 연속 성공/실패 streak */
        var streak   = enhanceData.enhanceStreak || 0;
        var detailEl = document.getElementById('enhanceStatDetail');

        if (streak === 0) {
            detailEl.innerHTML =
                '<div class="streak-none">'
              + '<div class="streak-icon">🔮</div>'
              + '<div class="streak-none-msg">아직 강화 기록이 없습니다.</div>'
              + '</div>';
        } else if (streak > 0) {
            // 연속 성공
            var flames = '';
            for (var fi = 0; fi < Math.min(streak, 10); fi++) flames += '🔥';
            detailEl.innerHTML =
                '<div class="streak-wrap streak-success">'
              + '<div class="streak-icon-big">' + flames + '</div>'
              + '<div class="streak-count success">x' + streak + ' 연속 성공</div>'
              + '<div class="streak-sub">계속 이 기세를 이어가세요!</div>'
              + getStreakComment(streak, true)
              + '</div>';
        } else {
            // 연속 실패
            var count = Math.abs(streak);
            var ices  = '';
            for (var ii = 0; ii < Math.min(count, 10); ii++) ices += '❄️';
            detailEl.innerHTML =
                '<div class="streak-wrap streak-fail">'
              + '<div class="streak-icon-big">' + ices + '</div>'
              + '<div class="streak-count fail">x' + count + ' 연속 실패</div>'
              + '<div class="streak-sub">다음엔 성공할 거예요...</div>'
              + getStreakComment(count, false)
              + '</div>';
        }

        /* 강화 정보 */
        updateEnhanceInfo(enhanceData);

        /* ── 목록 행 스탯 실시간 업데이트 ── */
        var activeRow = document.querySelector('.myteam-row.active');
        if (activeRow) {
            var totals = [
                details.currentAttack  + eAtk,
                details.currentDefense + eDef,
                details.currentMacro   + eMac,
                details.currentMicro   + eMic,
                details.currentLuck    + eLuk
            ];
            var sum   = totals.reduce(function(a, b) { return a + b; }, 0);
            var cells = activeRow.querySelectorAll('.col-atk, .col-def, .col-mac, .col-mic, .col-luk, .col-tot');
            if (cells.length >= 6) {
                for (var ci = 0; ci < 5; ci++) cells[ci].textContent = totals[ci];
                cells[5].textContent = sum;
            }
        }
    }

    function updateEnhanceInfo(data) {
        if (!data || !data.success) return;

        var level    = data.enhanceLevel    || 0;
        var rate     = data.successRate     || 0;
        var matCount = data.materialCount;

        document.getElementById('infoLevel').textContent = '+' + level;

        var rateEl = document.getElementById('infoRate');
        rateEl.textContent = rate + '%';
        rateEl.className   = 'enhance-info-item-val success-rate';
        if (rate <= 15) rateEl.classList.add('danger');
        else if (rate <= 40) rateEl.classList.add('warn');

        var matEl = document.getElementById('infoMaterial');
        matEl.textContent = matCount + '장';
        matEl.className   = 'enhance-info-item-val material-count';
        if (matCount === 0) matEl.classList.add('empty');

        var btn = document.getElementById('enhanceBtn');
        if (level >= 99) {
            btn.textContent = '✅ 최대 강화 달성 (+99)';
            btn.disabled    = true;
        } else if (matCount < 1) {
            btn.textContent = '⚡ 강화하기 (재료 부족)';
            btn.disabled    = true;
        } else {
            btn.textContent = '⚡ 강화하기  (+' + level + ' → +' + (level + 1) + '  /  성공률 ' + rate + '%)';
            btn.disabled    = false;
        }
    }

    /* ── 강화 실행 ── */
    function doEnhance() {
        if (!selectedSeq) return;
        var btn = document.getElementById('enhanceBtn');
        btn.disabled    = true;
        btn.textContent = '강화 중...';

        // 1. 모달 열고 로딩 화면 표시
        showLoadingModal();

        fetch(CTX + '/enhance/execute', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'ownedPlayerSeq=' + selectedSeq
        })
        .then(function(r){ return r.json(); })
        .then(function(data) {
            if (!data.success) {
                closeModal();
                alert(data.message);
                btn.disabled = false;
                return;
            }
            // 2. 로딩 최소 1.8초 후 결과 표시
            setTimeout(function() {
                showResultModal(data);
                loadPlayerDetail(selectedSeq);
                if (data.enhanced) {
                    var activeRow = document.querySelector('.myteam-row.active');
                    if (activeRow) {
                        var enhCell = activeRow.querySelector('.col-enhance-lv');
                        if (enhCell) enhCell.textContent = data.newEnhanceLevel + '강';
                    }
                }
            }, 1800);
        })
        .catch(function(){
            closeModal();
            alert('오류가 발생했습니다.');
            btn.disabled = false;
        });
    }

    /* ── 로딩 모달 ── */
    var _sparkInterval = null;
    var _loadInterval  = null;

    function showLoadingModal() {
        document.getElementById('modalLoading').style.display = 'block';
        document.getElementById('modalResult').style.display  = 'none';
        document.getElementById('enhanceModal').classList.add('show');

        // 로딩 바 애니메이션
        var bar = document.getElementById('loadingBar');
        bar.style.width = '0%';
        bar.style.transition = 'none';
        setTimeout(function(){ bar.style.transition = 'width 1.6s cubic-bezier(.4,0,.2,1)'; bar.style.width = '90%'; }, 50);

        // 망치 흔들기
        var anvil = document.getElementById('loadingAnvil');
        anvil.style.animation = 'hammerHit 0.35s ease-in-out infinite alternate';

        // 불꽃 파티클
        var sparks = document.getElementById('loadingSparks');
        sparks.innerHTML = '';
        _sparkInterval = setInterval(function() {
            for (var i = 0; i < 2; i++) {
                var s = document.createElement('span');
                s.className = 'spark';
                s.style.left = (30 + Math.random() * 40) + '%';
                s.style.animationDuration = (0.5 + Math.random() * 0.5) + 's';
                s.style.animationDelay    = (Math.random() * 0.2) + 's';
                s.textContent = ['✦','·','★','◆'][Math.floor(Math.random()*4)];
                sparks.appendChild(s);
                setTimeout(function(el){ el.remove(); }, 900);
            }
        }, 180);
    }

    /* ── 결과 모달 ── */
    function showResultModal(data) {
        // 로딩 정리
        clearInterval(_sparkInterval);
        var anvil = document.getElementById('loadingAnvil');
        anvil.style.animation = 'none';

        document.getElementById('modalLoading').style.display = 'none';
        var resultEl = document.getElementById('modalResult');
        resultEl.style.display  = 'block';
        resultEl.style.animation = 'resultReveal 0.4s cubic-bezier(.4,0,.2,1)';

        var enhanced = data.enhanced;
        document.getElementById('modalIcon').textContent  = enhanced ? '✨' : '💨';
        var titleEl = document.getElementById('modalTitle');
        titleEl.textContent = enhanced ? '강화 성공!' : '강화 실패';
        titleEl.className   = 'enhance-result-title ' + (enhanced ? 'success' : 'fail');
        document.getElementById('modalMsg').textContent = data.message;

        var STAT_KR = {attack:'공격(ATK)', defense:'수비(DEF)', macro:'매크로(MAC)', micro:'컨트롤(MIC)', luck:'럭(LUK)'};
        document.getElementById('modalStatChips').innerHTML =
            enhanced && data.enhancedStat
            ? '<span class="enhance-result-stat-chip">' + (STAT_KR[data.enhancedStat] || data.enhancedStat) + ' +1</span>'
            : '';
        document.getElementById('modalNext').textContent =
            '남은 재료: ' + data.remainMaterials + '장  |  다음 성공률: ' + data.nextSuccessRate + '%';
    }

    /* ── streak 코멘트 ── */
    function getStreakComment(count, isSuccess) {
        var comments;
        if (isSuccess) {
            comments = [
                '', '',
                '<div class="streak-comment good">슬슬 운이 따르고 있네요!</div>',
                '<div class="streak-comment good">3연성! 강화의 신이 함께합니다!</div>',
                '<div class="streak-comment great">4연성!! 이 기세라면 +99도 꿈이 아닙니다!</div>',
                '<div class="streak-comment great">5연성!!! 전설의 강화사!</div>',
            ];
        } else {
            comments = [
                '', '',
                '<div class="streak-comment warn">2연패... 한 번 쉬고 싶은 마음 이해합니다.</div>',
                '<div class="streak-comment warn">3연패... 혹시 마우스가 잘못된 건 아닐까요?</div>',
                '<div class="streak-comment bad">4연패!!!! 강화석이 불쌍합니다...</div>',
                '<div class="streak-comment bad">5연패!!!!! 정말 괜찮으신가요...?</div>',
            ];
        }
        var idx = Math.min(count, comments.length - 1);
        return comments[idx] || '';
    }

    /* ── 모달 닫기 ── */
    function closeModal() {
        document.getElementById('enhanceModal').classList.remove('show');
        clearInterval(_sparkInterval);
        setTimeout(function() {
            document.getElementById('modalLoading').style.display = 'none';
            document.getElementById('modalResult').style.display  = 'none';
        }, 250);
        var btn = document.getElementById('enhanceBtn');
        if (btn) btn.disabled = false;
    }

    /* ── 로딩 / 에러 ── */
    function showCardLoading() {
        document.getElementById('cardPlaceholder').style.display    = 'flex';
        document.getElementById('cardPlaceholder').innerHTML        = '<div class="placeholder-icon">⏳</div><p>데이터 로딩 중...</p>';
        document.getElementById('cardContent').style.display        = 'none';
        document.getElementById('enhanceActionArea').style.display  = 'none';
    }
    function showCardError() {
        document.getElementById('cardPlaceholder').style.display    = 'flex';
        document.getElementById('cardPlaceholder').innerHTML        = '<div class="placeholder-icon">⚠️</div><p>데이터를 불러올 수 없습니다</p>';
        document.getElementById('cardContent').style.display        = 'none';
        document.getElementById('enhanceActionArea').style.display  = 'none';
    }

    /* ── 첫 선수 자동 선택 ── */
    window.addEventListener('DOMContentLoaded', function() {
        var first = document.querySelector('.myteam-row');
        if (first) selectPlayerRow(first, first.dataset.seq);
    });
</script>

</body>
</html>
