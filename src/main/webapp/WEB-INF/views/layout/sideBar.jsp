<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
  공통 사이드바 컴포넌트
  사용법: <c:set var="activeMenu" value="메뉴키" /> 후 <%@ include file="/WEB-INF/views/layout/sideBar.jsp" %>

  메뉴키 목록:
    my-team         선수 명단
    entry           엔트리 설정
    build           전략 수립
    enhance         선수 강화
    pve-lobby       스테이지 목록
    train           훈련
    daily-missions  일일 미션 (NEW)
    gacha           선수 영입
--%>
<aside class="msl-sidebar">
    <div class="msl-nav-section">
        <div class="msl-nav-label">구단 관리</div>
        <a href="<c:url value='/my-team' />" class="msl-nav-item ${activeMenu == 'my-team' ? 'active' : ''}">
            <span class="msl-nav-icon">👥</span> 선수 명단
        </a>
        <a href="<c:url value='/my-team/entry' />" class="msl-nav-item ${activeMenu == 'entry' ? 'active' : ''}">
            <span class="msl-nav-icon">📋</span> 엔트리 설정
        </a>
        <a href="<c:url value='/build/manage' />" class="msl-nav-item ${activeMenu == 'build' ? 'active' : ''}">
            <span class="msl-nav-icon">🧪</span> 전략 수립
        </a>
        <a href="<c:url value='/enhance' />" class="msl-nav-item ${activeMenu == 'enhance' ? 'active' : ''}">
            <span class="msl-nav-icon">⚡</span> 선수 강화
        </a>
    </div>
    <div class="msl-nav-section">
        <div class="msl-nav-label">PVE 모드</div>
        <a href="<c:url value='/pve/lobby' />" class="msl-nav-item ${activeMenu == 'pve-lobby' ? 'active' : ''}">
            <span class="msl-nav-icon">🗺️</span> 스테이지 목록
        </a>
        <a href="<c:url value='/pve/train' />" class="msl-nav-item ${activeMenu == 'train' ? 'active' : ''}">
            <span class="msl-nav-icon">💪</span> 훈련
        </a>
        <a href="<c:url value='/daily-missions' />" class="msl-nav-item ${activeMenu == 'daily-missions' ? 'active' : ''}">
            <span class="msl-nav-icon">📅</span> 일일 미션
            <span class="msl-nav-badge mission-badge" id="missionBadge" style="display:none;"></span>
        </a>
    </div>
    <div class="msl-nav-section">
        <div class="msl-nav-label">스카웃</div>
        <a href="<c:url value='/gacha' />" class="msl-nav-item ${activeMenu == 'gacha' ? 'active' : ''}">
            <span class="msl-nav-icon">🌟</span> 선수 영입
        </a>
    </div>
    <div class="msl-sidebar-spacer"></div>
    <div class="msl-sidebar-back">
        <a href="<c:url value='/mode-select' />">← 모드 선택으로</a>
    </div>
</aside>

<script>
// 일일 미션 수령 가능 보상 개수 조회 및 뱃지 업데이트
function updateMissionBadge() {
    fetch('<c:url value="/daily-missions/claimable-count" />')
        .then(response => response.json())
        .then(data => {
            const badge = document.getElementById('missionBadge');
            if (badge && data.count > 0) {
                badge.textContent = data.count;
                badge.style.display = 'inline-block';
            } else if (badge) {
                badge.style.display = 'none';
            }
        })
        .catch(error => {
            console.error('미션 뱃지 업데이트 실패:', error);
        });
}

// 페이지 로드 시 및 주기적으로 뱃지 업데이트
document.addEventListener('DOMContentLoaded', function() {
    updateMissionBadge();
    
    // 30초마다 업데이트 (옵션)
    setInterval(updateMissionBadge, 30000);
});
</script>

<style>
/* 미션 뱃지 스타일 (기존 NEW 뱃지와 구분) */
.msl-nav-badge.mission-badge {
    background: linear-gradient(135deg, #00e676, #00c853);
    color: #000;
    font-weight: 700;
    width: 20px;
    height: 20px;
    padding: 0;
    border-radius: 50%;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    font-size: 11px;
    line-height: 20px;
    margin-left: auto;
    box-shadow: 0 2px 4px rgba(0, 230, 118, 0.3);
    animation: pulse 2s infinite;
    position: relative;
}

.msl-nav-badge.mission-badge::before {
    content: '';
    display: inline-block;
    vertical-align: middle;
    height: 100%;
}

@keyframes pulse {
    0%, 100% {
        transform: scale(1);
        opacity: 1;
    }
    50% {
        transform: scale(1.1);
        opacity: 0.9;
    }
}
</style>
