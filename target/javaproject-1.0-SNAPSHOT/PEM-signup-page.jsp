<%@ page import="javawork.personalexp.tools.database.Database" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String errorMsg = null;
    String username = request.getParameter("username");
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    if (username != null && email != null && password != null) {
        boolean userExists = Database.isValidUserByEmail(email);  // Check if email exists
        if (!userExists) {
            Database.create_user(username, password, email);  // Create new user
            response.sendRedirect("PEM-signin-page.jsp");  // Redirect to login page
        } else {
            errorMsg = "Email already exists. Please try a different one.";  // Show error message
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="style/PEM-login-page.css">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/octicons/8.5.0/font/css/octicons.min.css">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <title>Sign-Up Page</title>
</head>
<body>
    <div class="container">
        <div class="left-section">
            <h1>Welcome Back!</h1>
            <p>To keep connected with us, please login with your personal info</p>
            <button class="signin-btn" onclick="window.location.href='PEM-signin-page.jsp'">SIGN IN</button>
        </div>
        <div class="right-section">
            <h2>Create Account</h2>
            <div class="social-buttons">
                <button class="social-btn">F</button>
                <button class="social-btn">G+</button>
                <button class="social-btn">in</button>
            </div>
            <p>or use your email for registration:</p>
            <form method="post" action="PEM-signup-page.jsp">
                <input type="text" name="username" placeholder="Username" required>
                <input type="email" name="email" placeholder="Email" required>
                <input type="password" name="password" placeholder="Password" required>
                <button type="submit" class="signup-btn">SIGN UP</button>
            </form>

            <% if (errorMsg != null) { %>
                <p style="color: red;"><%= errorMsg %></p>
            <% } %>
        </div>
    </div>

    <script src="js/PEM-login-page.js"></script>
</body>
</html>
