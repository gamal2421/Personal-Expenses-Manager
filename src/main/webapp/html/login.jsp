<%@ page import="javawork.personalexp.tools.database.Database" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String errorMsg = null;
    String email = request.getParameter("email");
    String password = request.getParameter("password");

    if (email != null && password != null) {
        if (Database.isValidUser(email, password)) {
            session.setAttribute("userEmail", email);
            session.setAttribute("userName", Database.getUserNameByEmail(email));
            response.sendRedirect("dashboard.jsp");
            return;
        } else {
            errorMsg = "Invalid email or password.";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Login Page</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
  <link rel="stylesheet" href="../css/login.css">
</head>
<body>
  <div class="container">
    <!-- Sign In Section -->
    <div class="left-section">
      <h2>Sign in to PEM</h2>
      <div class="social-buttons">
        <button class="social-btn"><i class="fab fa-facebook-f"></i></button>
        <button class="social-btn"><i class="fab fa-google"></i></button>
        <button class="social-btn"><i class="fab fa-linkedin-in"></i></button>
      </div>
      <p class="muted">or use your email account</p>
      <form method="post" action="login.jsp" id="loginForm">
        <div class="input-wrapper">
          <input type="email" name="email" placeholder="Email" required />
        </div>
        <div class="input-wrapper">
          <input type="password" name="password" placeholder="Password" required />
        </div>
        <a href="#" class="forgot-password">Forgot your password?</a>
        <button type="submit" class="signin-btn">SIGN IN</button>
        <% if (errorMsg != null) { %>
          <p style="color:red;"><%= errorMsg %></p>
        <% } %>
      </form>
    </div>

    <!-- Welcome Section -->
    <div class="right-section">
      <h1>Hello, Friend!</h1>
      <p>Enter your personal details<br>and start journey with us</p>
      <button class="signup-outline-btn" onclick="location.href='signup.jsp'">SIGN UP</button>
    </div>
  </div>
</body>
</html>
