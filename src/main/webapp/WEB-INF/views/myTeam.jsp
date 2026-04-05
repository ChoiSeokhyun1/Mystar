<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>선수 명단 - My Star League</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/myTeam.css' />">
</head>
<body>

<header class="msl-topbar">
    <div class="msl-topbar-logo">MY STAR <span>LEAGUE</span></div>
    <div class="msl-topbar-center">
        <nav class="msl-breadcrumb">
            <a href="<c:url value='/mode-select' />">홈</a>
            <span class="sep">/</span>
            <span class="current">선수 명단</span>
        </nav>
    </div>
    <div class="msl-topbar-right">
        <div class="msl-crystal">💎 ${sessionScope.loginUser.crystal}</div>
        <div class="msl-user-label"><strong>${sessionScope.loginUser.userNick}</strong></div>
        <a href="<c:url value='/logout' />" class="msl-btn-nav">LOGOUT</a>
    </div>
</header>

<c:set var="activeMenu" value="my-team" />
<%@ include file="/WEB-INF/views/layout/sideBar.jsp" %>

<main class="msl-main">

    <header class="msl-page-header msl-animate">
        <div class="msl-page-header-left">
            <div class="msl-page-eyebrow">SQUAD MANAGEMENT</div>
            <div class="msl-page-title">선수 명단</div>
            <div class="msl-page-sub">보유한 선수들의 능력치를 확인하고 전적을 관리하세요.</div>
        </div>
    </header>

    <div class="squad-grid msl-animate msl-animate-d1">
        
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
                    <option value="ur">UR</option><option value="ssr">SSR</option>
                    <option value="sr">SR</option><option value="r">R</option><option value="n">N</option>
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
                            <c:when test="${empty myPlayerList}">
                                <tr><td colspan="11" style="text-align:center;padding:30px;color:#4a5568">보유한 선수가 없습니다.</td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="player" items="${myPlayerList}">
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
        
        <div class="squad-right-col">
            <div class="msl-panel squad-detail-panel">
                <div class="msl-panel-body squad-detail-body" id="cardPlaceholder">
                    <div class="placeholder-icon">👈</div>
                    <p>좌측 목록에서 선수를 선택해주세요.</p>
                </div>
                
                <div class="msl-panel-body squad-detail-body" id="cardContent" style="display:none;">
                    
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
                            </div>
                            
                            <h2 class="pro-name" id="cardName"></h2>
                            
                            <div class="pro-bio-strip">
                                <span class="bio-highlight" id="profileTeam"></span>
                                <span class="bio-divider"></span>
                                <span id="profileBirth"></span>
                                <span class="bio-divider"></span>
                                <span id="profileBody"></span>
                            </div>
                        </div>
                    </div>

                    <div class="pro-analytics-section">
                        <div class="pro-data-box stat-box">
                            <h3 class="box-title">능력치 스카우팅</h3>
                            <div class="pro-stat-list" id="statList">
                                </div>
                        </div>

                        <div class="pro-data-box record-box">
                            <h3 class="box-title">시즌 통산 전적</h3>
                            <div class="pro-record-display" id="profileRecord">
                                </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="msl-panel squad-recent-panel">
                <div class="msl-panel-head">
                    <div class="msl-panel-title">최근 경기 로그 (Recent 10)</div>
                </div>
                <div class="msl-panel-body" style="padding:0;" id="recentMatchList">
                    <div class="squad-no-records">선수를 선택하세요.</div>
                </div>
            </div>
        </div>
    </div>
</main>

<script>
    const CTX = '${pageContext.request.contextPath}';

    const COND_LABEL = {PEAK:'🔥 최상', GOOD:'😊 양호', NORMAL:'😐 보통', TIRED:'😓 피로', WORST:'😰 최악'};
    const COND_COLOR = {PEAK:'#ffd600', GOOD:'#4caf7d', NORMAL:'#aaa', TIRED:'#ff9800', WORST:'#ef5350'};
    document.querySelectorAll('.cond-cell').forEach(function(td) {
        var cond = td.dataset.cond || 'NORMAL';
        td.innerHTML = '<span style="font-size:0.72rem;font-weight:700;padding:2px 6px;border-radius:4px;border:1px solid '+(COND_COLOR[cond]||'#aaa')+'22;background:'+(COND_COLOR[cond]||'#aaa')+'22;color:'+(COND_COLOR[cond]||'#aaa')+'">'+(COND_LABEL[cond]||cond)+'</span>';
    });
    document.querySelectorAll('.streak-cell').forEach(function(td) {
        var ws = Math.min(parseInt(td.dataset.streak || 0), 5);
        var bars = '';
        for (var i = 0; i < 5; i++) {
            var lit = i < ws;
            var bg = lit ? '#4caf7d' : 'rgba(255,255,255,0.1)';
            bars += '<span style="display:inline-block;width:5px;height:14px;border-radius:2px;margin:0 1px;background:' + bg + ';vertical-align:middle;transition:background 0.3s;"></span>';
        }
        td.innerHTML = bars;
    });

    (function buildPackDropdown() {
        var packs = {};
        document.querySelectorAll('.myteam-row').forEach(function(row) {
            var p = row.dataset.pack || '';
            if (p) packs[p] = true;
        });
        var sel = document.getElementById('filterPack');
        Object.keys(packs).sort().forEach(function(name) {
            var opt = document.createElement('option');
            opt.value = name;
            opt.textContent = name;
            sel.appendChild(opt);
        });
    })();

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

    function selectPlayerRow(element, seq) {
        document.querySelectorAll('.myteam-row').forEach(function(el){ el.classList.remove('active'); });
        if(element) element.classList.add('active');
        selectPlayer(element, seq);
    }

    async function selectPlayer(element, seq) {
        showCardLoading();
        try {
            const res = await fetch(CTX + '/my-team/details?seq=' + seq);
            if (!res.ok) throw new Error('Network error');
            const data = await res.json();
            if (data.error === 'not_logged_in') { location.href = CTX + '/login'; return; }
            if (data.success) {
                updateDetailView(data.details, data.summary, data.matches);
            } else {
                showCardError();
            }
        } catch (err) {
            console.error(err);
            showCardError();
        }
    }

    function updateDetailView(details, summary, matches) {
        document.getElementById('cardPlaceholder').style.display = 'none';
        document.getElementById('cardContent').style.display = 'flex';

        // 1. 헤더 기본 정보 주입 및 색상 클래스 적용
        var raceMap = {T:'테란', P:'프로토스', Z:'저그'};
        var raceEl = document.getElementById('cardRace');
        raceEl.textContent = raceMap[details.race] || details.race || '-';
        raceEl.className = 'badge-tag col-race-' + (details.race || '');

        var rarEl = document.getElementById('cardRarity');
        var rVal = (details.currentRarity || details.rarity || '');
        rarEl.textContent = rVal.toUpperCase();
        rarEl.className = 'badge-tag col-rarity-' + rVal.toLowerCase();

        var packEl = document.getElementById('cardPack');
        packEl.textContent = details.packName ? details.packName : '기본 지급';
        packEl.className = 'badge-tag pack-yellow';

        document.getElementById('cardName').textContent = details.playerName;

        // 통합 바이오 스트립
        document.getElementById('profileTeam').textContent = details.teamName || '무소속';
        document.getElementById('profileBirth').textContent = details.nationality ? (details.nationality + ' ' + (details.birthDate || '')) : '출생정보 없음';
        document.getElementById('profileBody').textContent = details.height ? (details.height + 'cm ' + (details.weight || '') + 'kg') : '신체정보 없음';

        // 이미지
        const imgEl  = document.getElementById('cardImg');
        const fallEl = document.getElementById('cardImgFallback');
        if (details.playerImgUrl) {
            imgEl.src = details.playerImgUrl;
            imgEl.style.display = 'block';
            fallEl.style.display = 'none';
        } else {
            imgEl.style.display = 'none';
            fallEl.style.display = 'block';
        }

        // 2. 능력치 바 렌더링
        const statDefs = [
            {label:'ATK', name:'공격', val: details.currentAttack,  color:'#f87171'},
            {label:'DEF', name:'수비', val: details.currentDefense, color:'#60a5fa'},
            {label:'MAC', name:'매크로', val: details.currentMacro,   color:'#34d399'},
            {label:'MIC', name:'컨트롤', val: details.currentMicro,   color:'#fbbf24'},
            {label:'LCK', name:'럭',     val: details.currentLuck,    color:'#a78bfa'}
        ];
        document.getElementById('statList').innerHTML = statDefs.map(function(s) {
            var pct = Math.min(s.val / 1.5, 100);
            return '<div class="pro-stat-item">'
                 + '<div class="pro-stat-info"><span class="stat-lbl">' + s.label + '</span><span class="stat-nm">' + s.name + '</span></div>'
                 + '<div class="pro-stat-bar-bg"><div class="pro-stat-bar-fill" style="width:' + pct + '%; background:'+s.color+'; box-shadow: 0 0 8px '+s.color+'80;"></div></div>'
                 + '<div class="pro-stat-val" style="color:'+s.color+'">' + s.val + '</div>'
                 + '</div>';
        }).join('');

        // 3. 타이포그래피 전적 기록
        var s = summary || {};
        var totalW = s.wins || 0;
        var totalL = s.losses || 0;
        var totalG = totalW + totalL;
        var wr = s.winRate || 0;
        
        const recordDiv = document.getElementById('profileRecord');
        if (totalG > 0) {
            recordDiv.innerHTML = 
                '<div class="record-scores">' +
                    '<div class="score-box win"><span class="num">' + totalW + '</span><span class="lbl">WINS</span></div>' +
                    '<div class="score-box lose"><span class="num">' + totalL + '</span><span class="lbl">LOSSES</span></div>' +
                '</div>' +
                '<div class="record-winrate">' +
                    '<span class="wr-lbl">승률</span>' +
                    '<span class="wr-val">' + wr + '%</span>' +
                '</div>';
        } else {
            recordDiv.innerHTML = '<div class="record-empty">전적 기록이 존재하지 않습니다.</div>';
        }

        // 4. 최근 경기 로그 (텍스트 크기 축소됨)
        const listEl = document.getElementById('recentMatchList');
        listEl.innerHTML = '';
        if (matches && matches.length > 0) {
            matches.forEach(m => {
                let isWin = (m.isWin === 'Y');
                let dateStr = new Date(m.matchDate).toLocaleDateString();
                let raceStr = m.opponentRace ? m.opponentRace : '?';
                
                let html = '<div class="squad-match-item">' +
                           '<div class="squad-match-badge ' + (isWin ? 'win' : 'lose') + '">' + (isWin ? '승' : '패') + '</div>' +
                           '<div class="squad-match-info">' +
                           '<div class="squad-match-vs">vs ' + m.opponentName + ' <span style="opacity:0.6;font-size:0.75rem;">(' + raceStr + ')</span></div>' +
                           '<div class="squad-match-meta">' + m.mapName + ' · ' + dateStr + '</div>' +
                           '</div></div>';
                listEl.insertAdjacentHTML('beforeend', html);
            });
        } else {
            listEl.innerHTML = '<div class="squad-no-records">최근 경기 기록 없음</div>';
        }
    }

    function showCardLoading() {
        document.getElementById('cardPlaceholder').style.display = 'flex';
        document.getElementById('cardPlaceholder').innerHTML = '<div class="placeholder-icon">⏳</div><p>데이터 로딩 중...</p>';
        document.getElementById('cardContent').style.display = 'none';
        document.getElementById('recentMatchList').innerHTML = '<div class="squad-no-records">로딩 중...</div>';
    }

    function showCardError() {
        document.getElementById('cardPlaceholder').style.display = 'flex';
        document.getElementById('cardPlaceholder').innerHTML = '<div class="placeholder-icon">⚠️</div><p>데이터를 불러올 수 없습니다</p>';
        document.getElementById('cardContent').style.display = 'none';
    }

    window.addEventListener('DOMContentLoaded', () => {
        var first = document.querySelector('.myteam-row');
        if (first) {
            var seq = first.dataset.seq;
            selectPlayerRow(first, seq);
        }
    });
</script>
</body>
</html>