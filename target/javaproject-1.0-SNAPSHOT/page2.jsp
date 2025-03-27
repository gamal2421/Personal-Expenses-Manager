<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>Welcome</title>
</head>
<body>
    <% 
        String user = (String) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }
    %>
    <h2>Welcome, <%= user %>!</h2>
    <p>You have successfully logged in.</p>
    <a href="logout.jsp">Logout</a>
</body>
</html>
