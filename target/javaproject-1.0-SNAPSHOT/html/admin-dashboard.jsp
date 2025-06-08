<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="javawork.personalexp.models.User" %>
<%@ page import="java.util.List" %>
<%
    // Check if user is logged in and is admin
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<User> users = Database.getAllUsers();
    int totalUsers = users.size();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>
    <meta name="description" content="Admin dashboard for Personal Expenses Manager. Manage users, categories, and application settings.">
    <meta name="keywords" content="admin, dashboard, user management, category management, application settings, personal expenses manager">
    <meta name="author" content="PEM Team | ntg school">
    
    <!-- Apple Touch Icon (iOS) -->
    <link rel="apple-touch-icon" sizes="180x180" href="../icons/apple-touch-icon.png">
    <!-- Android Chrome -->
    <link rel="icon" type="image/png" sizes="192x192" href="../icons/android-chrome-192x192.png">
    <link rel="icon" type="image/png" sizes="512x512" href="../icons/android-chrome-512x512.png">
    <!-- Favicon -->
    <link rel="icon" type="image/png" sizes="32x32" href="../icons/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="../icons/favicon-16x16.png">
    <!-- Optional: Web Manifest for PWA -->
    <link rel="manifest" href="../icons/site.webmanifest">

    
   <link rel="stylesheet" href="../css/all.min.css"> <%-- Link to Font Awesome --%>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
<link rel="stylesheet" href="../css/admindash.css">
</head>
<body>
    <div class="main-page">
        <!-- Sidebar -->
        <div id="sidebar">
            <div id="profile-section">
                <div class="profile-image">
                    <%= session.getAttribute("userName").toString().charAt(0) %>
                </div>
                <h3><%= session.getAttribute("userName") %></h3>
                <p>Administrator</p>
            </div>
            
            <ul class="nav-menu">
                <li class="nav-item">
                    <a href="admin-dashboard.jsp">
                        <i class="fas fa-tachometer-alt icons"></i>
                        Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a href="admin-categories.jsp">
                        <i class="fas fa-tags icons"></i>
                        Manage Categories
                    </a>
                </li>
            </ul>
            
            <div style="margin-top: auto; padding: 15px;">
                <a href="logout.jsp" style="color: #3ab19b; text-decoration: none; display: flex; align-items: center; gap: 8px; justify-content: center;">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </div>
        
        <!-- Main Content -->
        <div class="content-area">
            <!-- Top Bar -->
            <div class="top-bar">
                <div class="page-title">
                    <h1>Admin Dashboard</h1>
                </div>
                <div class="top-actions">
<%--                    <div class="notification-btn">--%>
<%--                        <i class="fas fa-bell"></i>--%>
<%--                    </div>--%>
<%--                    <div class="settings-btn">--%>
<%--                        <i class="fas fa-cog"></i>--%>
<%--                    </div>--%>
                </div>
            </div>
            
            <!-- Dashboard Content -->
            <div class="dashboard-content">
                <!-- Stats Grid -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <h3>Total Users</h3>
                        <div class="value"><%= totalUsers %></div>
                    </div>
                </div>
                

                
            </div>
        </div>
    </div>
</body>
</html>