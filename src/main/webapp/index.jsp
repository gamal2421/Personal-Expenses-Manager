<%@ page import="javawork.personalexp.tools.database.Database" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String errorMsg = null;
    String user = request.getParameter("username");
    String pass = request.getParameter("password");

    if (user != null && pass != null) {
        if (Database.isValidUser(user, pass)) {
            session.setAttribute("user", user);
            response.sendRedirect("page2.jsp");
            return;
        } else {
            errorMsg = "Invalid username or password.";
        }
    }
%>

<html>
<head>
    <title>Login Page</title>       
    <link rel="stylesheet" href="styles/loginpage.css">
</head>
<body>
    <h2>Login</h2>
    <form class="loginform" method="post">
        <center>
            Username: <input type="text" name="username"><br>
            Password: <input type="password" name="password"><br>
            <input type="submit" value="Login"><br><br>

            <% if (errorMsg != null) { %>
                <p style="color:red;"><%= errorMsg %></p>
            <% } %>
        </center>
    </form>
</body>
</html>
