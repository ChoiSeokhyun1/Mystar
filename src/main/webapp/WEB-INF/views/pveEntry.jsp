<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>엔트리 설정 - My Star League</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/pveEntry.css' />">
</head>
<body>

<header class="msl-topbar">
    <div class="msl-topbar-logo">MY STAR <span>LEAGUE</span></div>
    <div class="msl-topbar-center">
        <nav class="msl-breadcrumb">
            <a href="<c:url value='/mode-select' />">홈</a>
            <span class="sep">/</span>
            <span class="current">엔트리 설정</span>
        </nav>
    </div>
    <div class="msl-topbar-right">
        <div class="msl-crystal">💎 ${sessionScope.loginUser.crystal}</div>
        <div class="msl-user-label"><strong>${sessionScope.loginUser.userNick}</strong></div>
        <a href="<c:url value='/logout' />" class="msl-btn-nav">LOGOUT</a>
    </div>
</header>

<c:set var="activeMenu" value="entry" />
<%@ include file="/WEB-INF/views/layout/sideBar.jsp" %>

<main class="msl-main">

    <header class="msl-page-header msl-animate">
        <div class="msl-page-header-left">
            <div class="msl-page-eyebrow">ENTRY SETUP</div>
            <div class="msl-page-title">엔트리 설정</div>
            <%-- 7명에서 9명으로 안내 문구 수정 --%>
            <div class="msl-page-sub">PVE 스테이지에 출전할 9명의 선수를 선택하세요.</div>
        </div>
    </header>

    <div class="entry-grid msl-animate msl-animate-d1">
        
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
                <span class="toolbar-sep"></span>
                <span class="player-count" id="countLabel"></span>
                <div class="toolbar-entry-actions">
                    <button class="msl-btn msl-btn-secondary entry-toolbar-btn" onclick="resetEntry()">🔄 초기화</button>
                    <button class="msl-btn msl-btn-primary entry-toolbar-btn" id="saveBtn" onclick="saveEntry()">💾 엔트리 저장</button>
                </div>
            </div>

            <div class="msl-panel-body" style="padding:0;overflow-y:auto;">
                <table class="player-table myteam-table">
                    <thead>
                        <tr>
                            <th class="th-chk">선발</th>
                            <th>종족</th>
                            <th>등급</th>
                            <th class="col-enhance-th">강화</th>
                            <th class="name-header">이름</th>
                            <th class="col-atk">ATK</th>
                            <th class="col-def">DEF</th>
                            <th class="col-mac">HP</th>
                            <th class="col-mic">HARASS</th>
                            <th class="col-luk">SPEED</th>
                            <th>합계</th>
                            <th>상태</th>
                            <th>경기력</th>
                        </tr>
                    </thead>
                    <tbody id="playerTableBody">
                        <c:choose>
                            <c:when test="${empty allOwnedPlayers}">
                                <tr><td colspan="13" style="text-align:center;padding:30px;color:#4a5568">보유한 선수가 없습니다.</td></tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="player" items="${allOwnedPlayers}">
                                    <tr class="myteam-row"
                                        data-seq="${player.ownedPlayerSeq}"
                                        data-name="${fn:toLowerCase(player.playerName)}"
                                        data-name-original="${player.playerName}"
                                        data-race="${player.race}"
                                        data-rarity="${fn:toLowerCase(player.currentRarity)}"
                                        data-condition="${player.condition}"
                                        data-atk="${player.currentAttack  + player.enhanceAttack}"
                                        data-def="${player.currentDefense + player.enhanceDefense}"
                                        data-mac="${player.currentHp      + player.enhanceHp}"
                                        data-mic="${player.currentHarass  + player.enhanceHarass}"
                                        data-lck="${player.currentSpeed   + player.enhanceSpeed}">
                                        <td class="td-chk">
                                            <input type="checkbox" class="entry-chk" data-seq="${player.ownedPlayerSeq}" onchange="onCheckChange(this)">
                                        </td>
                                        <td class="col-race col-race-${player.race}">${player.race == 'T' ? '테란' : player.race == 'P' ? '토스' : '저그'}</td>
                                        <td class="col-rarity col-rarity-${fn:toLowerCase(player.currentRarity)}">${player.currentRarity}</td>
                                        <td class="col-enhance-lv"><c:choose><c:when test="${player.enhanceLevel > 0}">${player.enhanceLevel}강</c:when><c:otherwise>-</c:otherwise></c:choose></td>
                                        <td class="col-name">${fn:escapeXml(player.playerName)}</td>
                                        <td class="col-atk">${player.currentAttack  + player.enhanceAttack}</td>
                                        <td class="col-def">${player.currentDefense + player.enhanceDefense}</td>
                                        <td class="col-mac">${player.currentHp      + player.enhanceHp}</td>
                                        <td class="col-mic">${player.currentHarass  + player.enhanceHarass}</td>
                                        <td class="col-luk">${player.currentSpeed   + player.enhanceSpeed}</td>
                                        <td class="col-tot">${player.currentAttack+player.enhanceAttack+player.currentDefense+player.enhanceDefense+player.currentHp+player.enhanceHp+player.currentHarass+player.enhanceHarass+player.currentSpeed+player.enhanceSpeed}</td>
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

        <div class="msl-panel analysis-panel">
            <div class="msl-panel-head">
                <div class="msl-panel-title">팀 분석</div>
            </div>
            <div class="msl-panel-body analysis-body">

                <div class="ana-section ana-slots-section">
                    <%-- 9명으로 라벨 수정 --%>
                    <div class="ana-title">선발 진행 <span id="slotLabel" style="float:right;font-size:0.78rem;letter-spacing:0;color:var(--text-dim);font-family:inherit;">0 / 9</span></div>
                    <div class="entry-slots" id="entrySlots">
                        <%-- 슬롯 9개로 확장 (slot0 ~ slot8) --%>
                        <div class="entry-slot" id="slot0"><span class="slot-name"></span></div>
                        <div class="entry-slot" id="slot1"><span class="slot-name"></span></div>
                        <div class="entry-slot" id="slot2"><span class="slot-name"></span></div>
                        <div class="entry-slot" id="slot3"><span class="slot-name"></span></div>
                        <div class="entry-slot" id="slot4"><span class="slot-name"></span></div>
                        <div class="entry-slot" id="slot5"><span class="slot-name"></span></div>
                        <div class="entry-slot" id="slot6"><span class="slot-name"></span></div>
                        <div class="entry-slot" id="slot7"><span class="slot-name"></span></div>
                        <div class="entry-slot" id="slot8"><span class="slot-name"></span></div>
                    </div>
                </div>

                <div class="ana-section ana-two-col">
                    <div class="ana-two-col-left">
                        <div class="ana-title">종족 구성</div>
                        <div class="race-counter-wrap">
                            <div class="race-counter-item">
                                <div class="race-counter-num race-t" id="cntT">0</div>
                                <div class="race-counter-label race-t">테란</div>
                            </div>
                            <div class="race-counter-item">
                                <div class="race-counter-num race-p" id="cntP">0</div>
                                <div class="race-counter-label race-p">프로토스</div>
                            </div>
                            <div class="race-counter-item">
                                <div class="race-counter-num race-z" id="cntZ">0</div>
                                <div class="race-counter-label race-z">저그</div>
                            </div>
                        </div>
                    </div>
                    <div class="ana-two-col-divider"></div>
                    <div class="ana-two-col-right">
                        <div class="ana-title">평균 능력치</div>
                        <div class="radar-wrap">
                            <svg id="radarSvg" viewBox="0 0 220 224" xmlns="http://www.w3.org/2000/svg"></svg>
                        </div>
                    </div>
                </div>

                <div class="ana-section">
                    <div class="ana-title">팀 진단</div>
                    <div class="team-diagnosis" id="teamDiagnosis">
                        <div class="diag-empty">선수를 선택하면 팀 분석이 표시됩니다.</div>
                    </div>
                </div>

            </div>
        </div>

    </div>
</main>

<script>
    var CTX = '${pageContext.request.contextPath}';
    var COND_LABEL = {PEAK:'🔥 최상', GOOD:'😊 양호', NORMAL:'😐 보통', TIRED:'😓 피로', WORST:'😰 최악'};
    var COND_COLOR = {PEAK:'#ffd600', GOOD:'#4caf7d', NORMAL:'#aaa', TIRED:'#ff9800', WORST:'#ef5350'};
    
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
            bars += '<span style="display:inline-block;width:5px;height:14px;border-radius:2px;margin:0 1px;background:' + bg + ';vertical-align:middle;"></span>';
        }
        td.innerHTML = bars;
    });

    var initialEntry = [
        <c:forEach var="p" items="${pveEntryPlayers}" varStatus="st">
            ${p.ownedPlayerSeq}<c:if test="${!st.last}">,</c:if>
        </c:forEach>
    ];

    document.addEventListener('DOMContentLoaded', function() {
        initialEntry.forEach(function(seq) {
            var chk = document.querySelector('.entry-chk[data-seq="' + seq + '"]');
            if (chk) chk.checked = true;
        });
        refreshAnalysis();
        filterList();
    });

    function filterList() {
        var q = document.getElementById('searchInput').value.toLowerCase();
        var race = document.getElementById('filterRace').value;
        var rar = document.getElementById('filterRarity').value;
        var cnt = 0;
        document.querySelectorAll('.myteam-row').forEach(function(row) {
            var ok = (!q || row.dataset.name.includes(q))
                  && (!race || row.dataset.race === race)
                  && (!rar || row.dataset.rarity === rar);
            row.style.display = ok ? '' : 'none';
            if (ok) cnt++;
        });
        document.getElementById('countLabel').textContent = cnt + '명';
    }

    function onCheckChange(chk) {
        var checked = document.querySelectorAll('.entry-chk:checked');
        <%-- 체크박스 선택 제한을 9명으로 수정 --%>
        if (checked.length > 9) {
            chk.checked = false;
            alert('최대 9명까지만 선택할 수 있습니다.');
            return;
        }
        refreshAnalysis();
    }

    function refreshAnalysis() {
        var checked = document.querySelectorAll('.entry-chk:checked');
        var n = checked.length;

        document.querySelectorAll('.myteam-row').forEach(function(r){ r.classList.remove('checked'); });
        checked.forEach(function(c){ c.closest('.myteam-row').classList.add('checked'); });
        
        var slotsEl = document.getElementById('entrySlots');
        <%-- 9명 체크 로직 --%>
        var isFull  = (n === 9);
        slotsEl.className = 'entry-slots' + (isFull ? ' full' : '');
        
        var selectedNames = [];
        checked.forEach(function(c) {
            var row = c.closest('.myteam-row');
            selectedNames.push(row.dataset.nameOriginal || row.dataset.name || '');
        });
        
        <%-- 슬롯 9개 루프 돌리도록 수정 --%>
        for (var si = 0; si < 9; si++) {
            var slot     = document.getElementById('slot' + si);
            var nameSpan = slot.querySelector('.slot-name');
            if (si < n) {
                slot.className   = 'entry-slot active';
                nameSpan.textContent = selectedNames[si];
            } else {
                slot.className   = 'entry-slot';
                nameSpan.textContent = '';
            }
        }
        <%-- 분모 9로 수정 --%>
        document.getElementById('slotLabel').textContent = n + ' / 9';
        
        var rT=0, rP=0, rZ=0;
        var sAtk=0, sDef=0, sMac=0, sMic=0, sLck=0;
        var condCounts = {PEAK:0, GOOD:0, NORMAL:0, TIRED:0, WORST:0};

        checked.forEach(function(c) {
            var row = c.closest('.myteam-row');
            var race = row.dataset.race;
            if (race==='T') rT++; else if (race==='P') rP++; else if (race==='Z') rZ++;
            sAtk += parseInt(row.dataset.atk)||0;
            sDef += parseInt(row.dataset.def)||0;
            sMac += parseInt(row.dataset.mac)||0;
            sMic += parseInt(row.dataset.mic)||0;
            sLck += parseInt(row.dataset.lck)||0;
            var cond = row.dataset.condition || 'NORMAL';
            if (condCounts[cond] !== undefined) condCounts[cond]++;
        });
        
        document.getElementById('cntT').textContent = rT;
        document.getElementById('cntP').textContent = rP;
        document.getElementById('cntZ').textContent = rZ;

        var aAtk = n > 0 ? Math.round(sAtk/n) : 0;
        var aDef = n > 0 ? Math.round(sDef/n) : 0;
        var aMac = n > 0 ? Math.round(sMac/n) : 0;
        var aMic = n > 0 ? Math.round(sMic/n) : 0;
        var aLck = n > 0 ? Math.round(sLck/n) : 0;

        drawRadar(aAtk, aDef, aMac, aMic, aLck);
        
        var diagEl = document.getElementById('teamDiagnosis');
        if (n === 0) {
            diagEl.innerHTML = '<div class="diag-empty">선수를 선택하면 팀 분석이 표시됩니다.</div>';
            return;
        }

        var msgs = [];
        var statMap = [
            {n:'공격', v:aAtk, c:'#f87171'},
            {n:'수비', v:aDef, c:'#60a5fa'},
            {n:'체력',   v:aMac, c:'#34d399'},
            {n:'견제력', v:aMic, c:'#fbbf24'},
            {n:'속도',   v:aLck, c:'#a78bfa'}
        ];
        
        statMap.sort(function(a,b){ return b.v - a.v; });
        var best  = statMap[0];
        var worst = statMap[statMap.length-1];
        msgs.push({type:'good', icon:'▲', text:'최고 스탯: <strong style="color:'+best.c+'">' + best.n + ' (' + best.v + ')</strong>'});
        msgs.push({type:'warn', icon:'▼', text:'최저 스탯: <strong style="color:'+worst.c+'">' + worst.n + ' (' + worst.v + ')</strong>'});
        
        if (best.v - worst.v > 15) {
            msgs.push({type:'warn', icon:'📊', text:'스탯 편차가 <strong style="color:#ff9800">크게</strong> 벌어져 있습니다.'});
        } else if (best.v - worst.v < 5) {
            msgs.push({type:'good', icon:'⚖️', text:'스탯이 <strong style="color:#4caf7d">고르게</strong> 분포되어 있습니다.'});
        }

        var onlyOneRace = (rT===n || rP===n || rZ===n) && n >= 3;
        var hasAllRaces  = rT > 0 && rP > 0 && rZ > 0;
        if (onlyOneRace)  msgs.push({type:'info', icon:'🎯', text:'단일 종족 구성 — <strong>시너지</strong>가 강할 수 있습니다.'});
        else if (hasAllRaces) msgs.push({type:'info', icon:'🌈', text:'<strong>3종족 혼합</strong> 구성 — 다양한 전략 가능합니다.'});

        var badCond  = condCounts.TIRED + condCounts.WORST;
        var goodCond = condCounts.PEAK  + condCounts.GOOD;
        if (badCond >= 3)       msgs.push({type:'bad',  icon:'😓', text:'컨디션 나쁜 선수 <strong style="color:#ef5350">' + badCond + '명</strong> — 교체를 고려하세요.'});
        else if (goodCond >= 5) msgs.push({type:'good', icon:'🔥', text:'팀 컨디션이 <strong style="color:#4caf7d">매우 좋습니다!</strong>'});
        
        <%-- 진단 메시지 인원 수정 --%>
        if (n < 9) {
            msgs.push({type:'action', icon:'📋', text:'<strong>' + (9-n) + '명</strong>을 더 선택해야 합니다.'});
        } else {
            msgs.push({type:'complete', icon:'✅', text:'9명 선발 완료! <strong style="color:#00e676">저장</strong>할 수 있습니다.'});
        }

        diagEl.innerHTML = msgs.map(function(m) {
            return '<div class="diag-item diag-' + m.type + '">'
                 + '<span class="diag-icon">' + m.icon + '</span>'
                 + '<span class="diag-text">' + m.text + '</span>'
                 + '</div>';
        }).join('');
    }

    function drawRadar(aAtk, aDef, aMac, aMic, aLck) {
        var svg = document.getElementById('radarSvg');
        var cx = 110, cy = 112, r = 82, n = 5;
        var MAX    = 100;
        var vals   = [aAtk, aDef, aMac, aMic, aLck];
        var colors = ['#f87171','#60a5fa','#34d399','#fbbf24','#a78bfa'];
        var labels = ['ATK','DEF','HP','HAR','SPD'];
        
        function pt(i, val) {
            var angle = (Math.PI * 2 / n) * i - Math.PI / 2;
            var ratio = Math.min(Math.max(val / MAX, 0.04), 1);
            return { x: cx + r * ratio * Math.cos(angle), y: cy + r * ratio * Math.sin(angle) };
        }
        function axis(i, scale) {
            var angle = (Math.PI * 2 / n) * i - Math.PI / 2;
            return { x: cx + r * scale * Math.cos(angle), y: cy + r * scale * Math.sin(angle) };
        }

        var html = '';
        [0.25, 0.5, 0.75, 1.0].forEach(function(s) {
            var pts = Array.from({length: n}, function(_, i){ var p = axis(i, s); return p.x+','+p.y; }).join(' ');
            html += '<polygon points="'+pts+'" fill="none" stroke="rgba(255,255,255,'+(s===1.0?'0.14':'0.06')+')" stroke-width="1"/>';
        });
        for (var i = 0; i < n; i++) {
            var p = axis(i, 1);
            html += '<line x1="'+cx+'" y1="'+cy+'" x2="'+p.x+'" y2="'+p.y+'" stroke="rgba(255,255,255,0.07)" stroke-width="1"/>';
        }

        var dataPts = vals.map(function(v, i){ var p = pt(i, v); return p.x+','+p.y; }).join(' ');
        html += '<polygon points="'+dataPts+'" fill="rgba(0,230,118,0.10)" stroke="rgba(0,230,118,0.55)" stroke-width="1.5"/>';

        labels.forEach(function(lbl, i) {
            var lp = axis(i, 1.22);
            html += '<text x="'+lp.x+'" y="'+lp.y+'" text-anchor="middle" dominant-baseline="middle"'
                 +  ' font-size="11" font-family="Barlow Condensed,sans-serif" font-weight="800" fill="'+colors[i]+'">'+lbl+'</text>';
        });
        
        vals.forEach(function(v, i) {
            var dp  = pt(i, v);
            var angle = (Math.PI * 2 / n) * i - Math.PI / 2;
            var vr    = Math.min(Math.max(v / MAX, 0.04), 1);
            var offR  = vr * r + 13;
            var vx    = cx + offR * Math.cos(angle);
            var vy    = cy + offR * Math.sin(angle);

            html += '<circle cx="'+dp.x+'" cy="'+dp.y+'" r="4" fill="'+colors[i]+'" stroke="#0d121e" stroke-width="1.5"/>';
            html += '<rect x="'+(vx-12)+'" y="'+(vy-8)+'" width="24" height="16" rx="4"'
                 +  ' fill="rgba(13,18,30,0.85)" stroke="'+colors[i]+'" stroke-width="1" opacity="0.95"/>';
            html += '<text x="'+vx+'" y="'+vy+'" text-anchor="middle" dominant-baseline="middle"'
                 +  ' font-size="10" font-family="Barlow Condensed,sans-serif" font-weight="900" fill="'+colors[i]+'">'+v+'</text>';
        });

        svg.innerHTML = html;
    }

    function resetEntry() {
        document.querySelectorAll('.entry-chk').forEach(function(c){ c.checked = false; });
        refreshAnalysis();
    }

    function saveEntry() {
        var checked = document.querySelectorAll('.entry-chk:checked');
        <%-- 저장 인원 체크 9명으로 수정 --%>
        if (checked.length !== 9) {
            alert('9명을 모두 선택해주세요. (현재 ' + checked.length + '명)');
            return;
        }
        var seqList = [];
        checked.forEach(function(c){ seqList.push(parseInt(c.dataset.seq)); });
        fetch(CTX + '/my-team/entry/save', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(seqList)
        })
        .then(function(res){ return res.json(); })
        .then(function(data) {
            if(data.success) { alert('엔트리가 성공적으로 저장되었습니다.'); location.href = CTX + '/pve/lobby'; }
            else { alert('저장 실패: ' + data.message); }
        })
        .catch(function(err) { console.error(err); alert('서버와 통신하는 중 오류가 발생했습니다.'); });
    }
</script>
</body>
</html>