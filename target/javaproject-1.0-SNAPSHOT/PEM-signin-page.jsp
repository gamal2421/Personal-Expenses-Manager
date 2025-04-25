

<%@ page import="javawork.personalexp.tools.database.Database" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String email = request.getParameter("email");
String pass = request.getParameter("password");
String errorMsg = null; 

if (email != null && pass != null) {
    if (Database.isValidUser(email, pass)) {
        session.setAttribute("email", email);  // Store email in session
        response.sendRedirect("PEM-DashBoard.jsp");  // Redirect to dashboard
        return;
    } else {
        errorMsg = "Invalid email or password.";  // Set error message
    }
}
%>
<!DOCTYPE html>
<html lang="en">
<head>

  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/octicons/8.5.0/font/css/octicons.min.css">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
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

      <form method="post" action="PEM-signin-page.jsp">
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
      <p>Enter your personal details<br>and start your journey with us</p>
      <button class="signup-outline-btn">
        <a href="PEM-signup-page.jsp">SIGN UP</a>
      </button>
    </div>
  </div>

  <script src="js/PEM-signin-page.js"></script>
</body>
</html>

