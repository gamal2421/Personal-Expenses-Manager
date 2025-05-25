<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Invalidate the current session
    session.invalidate();

    // Redirect to the login page
    response.sendRedirect("login.jsp");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Logging out...</title>
</head>
<body>
    <p>Logging out. Please wait...</p>
</body>
</html> 