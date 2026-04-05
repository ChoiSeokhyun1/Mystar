<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // 서버 캐시 방지
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인 - My Star League</title>
    <link rel="stylesheet" href="<c:url value='css/login.css' />">
</head>
<body>
<div class="animated-bg-text">
        <span>APM BUILD GG MICRO MACRO STRATEGY CONTROL RUSH TIMING ALL-IN</span>
        <span>GOSU PUSH GG ZERG TERRAN PROTOSS LEGEND APM BUILD GG MICRO MACRO</span>
        <span>STRATEGY CONTROL RUSH TIMING ALL-IN GOSU PUSH GG ZERG TERRAN PROTOSS</span>
        <span>LEGEND APM BUILD GG MICRO MACRO STRATEGY CONTROL RUSH TIMING ALL-IN GOSU</span>
        </div>

    <div class="login-card"> 
        <div class="login-logo">
            <%-- 로고 이미지 (선택 사항) --%>
            <%-- <img src="<c:url value='/resources/images/your-logo-white.png' />" alt="My Star League Logo"> --%>
        </div>
        <h2>My Star League 로그인</h2>
        
        <c:url value="/login-process" var="loginUrl" /> 
        <form action="${loginUrl}" method="post">
            <div class="form-group">
                <label for="username">아이디</label>
                <input type="text" id="username" name="username" class="form-input" required placeholder="아이디 입력">
            </div>
            <div class="form-group">
                <label for="password">비밀번호</label>
                <input type="password" id="password" name="password" class="form-input" required placeholder="비밀번호 입력">
            </div>
            <div class="form-group" style="margin-top: 2rem;">
                <button type="submit" class="btn-primary">로그인</button>
            </div>
        </form>

        <c:if test="${not empty loginError}">
            <div class="alert alert-danger">
                ${loginError}
            </div>
        </c:if>

        <div class="extra-links">
            아직 회원이 아니신가요? <a href="#">회원가입</a> | <a href="#">비밀번호 찾기</a>
        </div>

        <p class="test-info">
            (테스트: testuser / 1234)
        </p>
    </div>

    <script>
        // bfcache에서 페이지 복원 시 새로고침
        window.addEventListener("pageshow", function(event) {
            if (event.persisted) {
                window.location.reload();
            }
        });

        // 페이지 로드 시 폼 초기화
        document.addEventListener("DOMContentLoaded", function() {
            const loginForm = document.querySelector("form");
            if (loginForm) {
                loginForm.reset(); // 입력값 초기화
            }
        });
    </script>
</body>
</html>
