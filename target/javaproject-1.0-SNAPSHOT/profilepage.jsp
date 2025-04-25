<%@ page import="javawork.personalexp.tools.database.Database" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userEmail = (String) session.getAttribute("email");
    if (userEmail == null) {
        response.sendRedirect("PEM-signin-page.jsp");
        return;
    }
    String userName = Database.getUserNameByEmail(userEmail);
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Personal Expenses Manager - Profile</title>
  <link rel="stylesheet" href="style/profile.css" />
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet" />
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet" />
</head>
<body>

  <div id="top">
    <div class="profile-picture"></div>
    <div id="user-data">
      <h1>asda</h1>
      <h2 id="name"><%= userName %></h2>
      <p id="email"><%= userEmail %></p>
    </div>
    <h1 id="app-name">Personal Expenses Manager</h1>
  </div>

  <div id="width-separator"></div>

  <div class="main-content">
    <div id="navs">
      <ul>
        <li class="lii"><a href="profilepage.jsp"><i class="fas fa-user icons"></i> Profile </a></li>
        <li class="lii"><a href="Settingspage.html"><i class="fas fa-cog icons"></i> Settings </a></li>
        <li class="lii"><a href="#"><i class="fas fa-bell icons"></i> Notifications </a></li>
        <li class="lii"><a href="Categoriespage.html"><i class="fas fa-list icons"></i> Categories </a></li>
        <li class="lii"><a href="#"><i class="fas fa-chart-line icons"></i> Financials </a></li>
        <li class="lii"><a href="REPORTSandANALYTICS.html"><i class="fas fa-file-alt icons"></i> Reports</a></li>
        <li class="lii"><a href="Budgets.html"><i class="fas fa-wallet icons"></i> Budget </a></li>
        <li class="lii"><a href="INCOME TRACKINGpage.html"><i class="fas fa-money-bill-wave icons"></i> Income </a></li>
        <li class="lii"><a href="PEM-DashBoard.jsp"><i class="fas fa-chart-bar icons"></i> Charts </a></li>
      </ul>
      <div id="hight-separator"></div>
    </div>

    <div class="main-area">
      <div class="profile-card">
        <div class="avatar"></div>
        <form action="update-profile" method="post">
          <input type="text" name="name" placeholder="Name" value="<%= userName %>" required />
          <input type="email" name="email" placeholder="Email" value="<%= userEmail %>" required />
          <button type="submit">Save Changes</button>
        </form>
      </div>
    </div>
  </div>

</body>
</html>
