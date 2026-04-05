<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="메인 로비" scope="request" />
<%@ include file="layout/header.jspf" %>

<div class="lobby-container">
    
    <div class="hero-section">
        <div class="user-summary">
            <h1 class="welcome-text">WELCOME BACK, <span class="highlight">${sessionScope.loginUser.userNick}</span></h1>
            <p class="team-name-display">TEAM: ${not empty sessionScope.loginUser.teamName ? sessionScope.loginUser.teamName : '팀을 설정하세요'}</p>
        </div>
        <div class="resource-hub">
            <div class="res-card">
                <span class="res-label">보유 크리스탈</span>
                <span class="res-value">💎 ${sessionScope.loginUser.crystal}</span>
            </div>
        </div>
    </div>

    <div class="game-dashboard">
        
        <div class="menu-card management">
            <div class="card-icon">🛡️</div>
            <h3>구단 관리</h3>
            <p>선수를 육성하고 최적의 엔트리를 구성하여 승리를 쟁취하세요.</p>
            <div class="btn-group">
                <a href="<c:url value='/my-team' />" class="btn-lobby">선수 명단</a>
                <a href="<c:url value='/my-team/entry' />" class="btn-lobby">로스터 설정</a>
                <a href="<c:url value='/build/manage' />" class="btn-lobby">전략 수립</a>
            </div>
        </div>

        <div class="menu-card battle-main">
            <div class="card-tag">MAIN MISSION</div>
            <div class="card-icon">⚔️</div>
            <h3>시나리오 모드</h3>
            <p>강력한 AI 팀들에게 도전하고 보상을 획득하여 팀을 성장시키세요.</p>
            <a href="<c:url value='/pve/lobby' />" class="btn-lobby btn-highlight">전장으로 출격</a>
        </div>

        <div class="menu-card recruit">
            <div class="card-icon">🌟</div>
            <h3>선수 스카웃</h3>
            <p>전설적인 선수를 영입할 기회! 새로운 스타를 팀에 합류시키세요.</p>
            <a href="<c:url value='/gacha' />" class="btn-lobby btn-success">스카웃 시작</a>
        </div>

    </div>

    <div class="lobby-footer-info">
        <p>현재 시즌: <strong>2024 MSL PRE-SEASON</strong> | 서버 상태: <span class="status-online">● ONLINE</span></p>
    </div>
</div>

<%@ include file="layout/footer.jspf" %>