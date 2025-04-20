<%@ page import="javawork.personalexp.tools.database.Database" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String errorMsg = null;
    String user = request.getParameter("email");
    String pass = request.getParameter("password");

    if (user != null && pass != null) {
        if (Database.isValidUser(email, pass)) {
            session.setAttribute("email", email);
            response.sendRedirect("PEM-DashBoard.html");
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
  <link rel="stylesheet" href="style/PEM-signin-page.css" />
  <title>Login Page</title>
</head>
<body>
  <div class="container">
    <!-- Sign In Section -->
    <div class="left-section">
      <h2>Sign in to PEM</h2>
      <div class="social-buttons">
        <button class="social-btn">f</button>
        <button class="social-btn">G+</button>
        <button class="social-btn">in</button>
      </div>
      <p class="muted">or use your email account:</p>
      
      <form method="post">
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
      <button class="signup-outline-btn">SIGN UP</button>
    </div>
  </div>

  <script src="js/PEM-signin-page.js"></script>
</body>
</html>
