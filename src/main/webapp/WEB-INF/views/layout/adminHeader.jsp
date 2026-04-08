<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
    어드민 공통 헤더 — 모든 관리자 페이지에서 include 해서 사용
    새 메뉴 추가 시 이 파일만 수정하면 전체 반영됨

    사용법:
    <%@ include file="/WEB-INF/views/layout/adminHeader.jspf" %>

    현재 페이지 강조(current 클래스)를 원하면 include 전에 pageTitle 변수를 설정:
    <c:set var="adminCurrentPage" value="stage" />   ← stage / player / pack / entity / build / script
--%>
<header class="msl-topbar">
    <div class="msl-topbar-logo">MY STAR <span>LEAGUE</span>
        <span style="color:#ef4444;font-size:10px;margin-left:8px;background:#2d0000;padding:2px 8px;border-radius:4px;vertical-align:middle;">ADMIN</span>
    </div>
    <div class="msl-topbar-center">
        <nav class="msl-breadcrumb">
            <a href="<c:url value='/pve/lobby' />">PVE 로비</a>
            <span class="sep">/</span>
            <c:choose>
                <c:when test="${adminCurrentPage == 'stage'}"><span class="current">스테이지 관리</span></c:when>
                <c:otherwise><a href="<c:url value='/admin/stage' />">스테이지 관리</a></c:otherwise>
            </c:choose>
            <span class="sep">/</span>
            <c:choose>
                <c:when test="${adminCurrentPage == 'player'}"><span class="current">선수 관리</span></c:when>
                <c:otherwise><a href="<c:url value='/admin/player' />">선수 관리</a></c:otherwise>
            </c:choose>
            <span class="sep">/</span>
            <c:choose>
                <c:when test="${adminCurrentPage == 'pack'}"><span class="current">팩 관리</span></c:when>
                <c:otherwise><a href="<c:url value='/admin/pack' />">팩 관리</a></c:otherwise>
            </c:choose>
            <span class="sep">/</span>
            <c:choose>
                <c:when test="${adminCurrentPage == 'build'}"><span class="current">빌드 관리</span></c:when>
                <c:otherwise><a href="<c:url value='/admin/build/manage' />">빌드 관리</a></c:otherwise>
            </c:choose>
            <span class="sep">/</span>
            <c:choose>
                <c:when test="${adminCurrentPage == 'script'}"><span class="current">대본 관리</span></c:when>
                <c:otherwise><a href="<c:url value='/admin/script/manage' />">대본 관리</a></c:otherwise>
            </c:choose>
            <span class="sep">/</span>
            <c:choose>
                <c:when test="${adminCurrentPage == 'entity'}"><span class="current">유닛/건물 이미지</span></c:when>
                <c:otherwise><a href="<c:url value='/admin/entity' />">유닛/건물 이미지</a></c:otherwise>
            </c:choose>
        </nav>
    </div>
    <div class="msl-topbar-right">
        <div class="msl-user-label">
            <strong>${sessionScope.loginUser.userNick}</strong>
            <span style="color:#ef4444;font-size:10px;margin-left:4px;">[ADMIN]</span>
        </div>
        <a href="<c:url value='/logout' />" class="msl-btn-nav">LOGOUT</a>
    </div>
</header>
