<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>일일 미션 - My Star League</title>
    <link rel="stylesheet" href="<c:url value='/css/msl-layout.css' />">
    <link rel="stylesheet" href="<c:url value='/css/dailyMissions.css' />">
</head>
<body class="daily-mission-page">

<!-- TOPBAR -->
<header class="msl-topbar">
    <div class="msl-topbar-logo">MY STAR <span>LEAGUE</span></div>
    <div class="msl-topbar-center">
        <nav class="msl-breadcrumb">
            <a href="<c:url value='/mode-select' />">홈</a>
            <span class="sep">/</span>
            <span class="current">일일 미션</span>
        </nav>
    </div>
    <div class="msl-topbar-right">
        <div class="msl-crystal" id="userCrystal">💎 ${sessionScope.loginUser.crystal}</div>
        <div class="msl-user-label"><strong>${sessionScope.loginUser.userNick}</strong></div>
        <c:if test="${sessionScope.loginUser.userId == 'testuser3'}">
            <a href="<c:url value='/admin/stage' />" class="msl-btn-nav"
               style="background:rgba(239,68,68,0.15);border-color:#7f1d1d;color:#f87171;">⚙ 관리자</a>
        </c:if>
        <a href="<c:url value='/logout' />" class="msl-btn-nav">LOGOUT</a>
    </div>
</header>

<!-- SIDEBAR -->
<c:set var="activeMenu" value="daily-missions" />
<%@ include file="/WEB-INF/views/layout/sideBar.jsp" %>

<!-- MAIN -->
<main class="msl-main">

    <div class="msl-page-header msl-animate">
        <div class="msl-page-header-left">
            <div class="msl-page-eyebrow">DAILY CHALLENGES</div>
            <div class="msl-page-title">일일 미션</div>
        </div>
        
        <!-- 우측 상단: 미니 통계 + 모든 보상 받기 버튼 -->
        <div class="mission-top-right">
            <div class="mission-mini-stats">
                <div class="mission-mini-stat">
                    <div class="mission-mini-stat-label">완료</div>
                    <div class="mission-mini-stat-value">${completedMissions}/${totalMissions}</div>
                </div>
                <div class="mission-mini-stat">
                    <div class="mission-mini-stat-label">수령</div>
                    <div class="mission-mini-stat-value">${claimedMissions}/${totalMissions}</div>
                </div>
                <div class="mission-mini-stat">
                    <div class="mission-mini-stat-label">가능</div>
                    <div class="mission-mini-stat-value secondary" id="totalRewardsDisplay">💎${totalRewards}</div>
                </div>
            </div>
            
            <button class="btn-claim-all" onclick="claimAllRewards()" id="btnClaimAll">
                모든 보상 받기
            </button>
        </div>
    </div>

    <!-- 미션 그리드 (2행 3열) -->
    <div class="mission-grid msl-animate msl-animate-d1">
        <c:forEach items="${missions}" var="mission">
            <div class="mission-card ${mission.isCompleted == 'Y' ? 'completed' : ''} ${mission.isClaimed == 'Y' ? 'claimed' : ''}" 
                 data-mission-id="${mission.missionId}">
                
                <div class="mission-check">✓</div>
                
                <div class="mission-icon">${mission.missionIcon}</div>
                
                <div class="mission-info">
                    <div class="mission-title">${mission.missionTitle}</div>
                    <div class="mission-desc">${mission.missionDesc}</div>
                    
                    <c:if test="${mission.isClaimed != 'Y'}">
                        <div class="mission-progress-bar">
                            <div class="mission-progress-fill" style="width: ${mission.progressPercent}%"></div>
                        </div>
                        <div class="mission-progress-text">
                            ${mission.currentCount} / ${mission.targetCount}
                        </div>
                    </c:if>
                </div>
                
                <div class="mission-reward">
                    <div class="mission-reward-label">보상</div>
                    <div class="mission-reward-value">💎 ${mission.rewardCrystal}</div>
                </div>
                
                <div class="mission-action">
                    <c:choose>
                        <c:when test="${mission.isClaimed == 'Y'}">
                            <button class="mission-btn claimed" disabled>수령 완료</button>
                        </c:when>
                        <c:when test="${mission.isCompleted == 'Y'}">
                            <button class="mission-btn claim" onclick="claimReward(${mission.missionId})">
                                보상 받기
                            </button>
                        </c:when>
                        <c:otherwise>
                            <button class="mission-btn claim" disabled>진행 중</button>
                            <div class="mission-status">
                                ${mission.progressPercent}% 완료
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </c:forEach>
    </div>

</main>

<script>
// 개별 보상 수령
function claimReward(missionId) {
    fetch('<c:url value="/daily-missions/claim" />', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'missionId=' + missionId
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert(data.message + '\n획득: 💎 ' + data.rewardAmount);
            
            // UI 업데이트
            document.getElementById('userCrystal').textContent = '💎 ' + data.newCrystal;
            
            // 페이지 새로고침
            location.reload();
        } else {
            alert('오류: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('보상 수령 중 오류가 발생했습니다.');
    });
}

// 전체 보상 일괄 수령
function claimAllRewards() {
    if (!confirm('수령 가능한 모든 보상을 받으시겠습니까?')) {
        return;
    }
    
    fetch('<c:url value="/daily-missions/claim-all" />', {
        method: 'POST'
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert(data.message + '\n총 획득: 💎 ' + data.totalReward);
            
            // UI 업데이트
            document.getElementById('userCrystal').textContent = '💎 ' + data.newCrystal;
            
            // 페이지 새로고침
            location.reload();
        } else {
            alert('오류: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('보상 수령 중 오류가 발생했습니다.');
    });
}

// 페이지 로드 시 일괄 수령 버튼 활성화/비활성화
window.addEventListener('DOMContentLoaded', function() {
    const totalRewards = ${totalRewards};
    const btnClaimAll = document.getElementById('btnClaimAll');
    
    if (totalRewards <= 0) {
        btnClaimAll.disabled = true;
    }
});
</script>

</body>
</html>
