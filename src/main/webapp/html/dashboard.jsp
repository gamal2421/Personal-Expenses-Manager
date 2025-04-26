<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="javawork.personalexp.models.User" %>
<%@ page import="javawork.personalexp.models.DashboardData" %>
<%
    // Check if the user is logged in
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");  // Redirect to login if not logged in
        return;  // Ensure no further processing happens
    }
        int userId = Database.getUserIdByEmail(userEmail);
    User user = Database.getUserInfo(userId);
    DashboardData dashboardData = Database.getDashboardData(userId);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../css/dashboard.css">
</head>
<body>
<div class="main-page">
    <!-- Sidebar -->
    <div id="sidebar">
        <div id="profile-section">
            <div class="profile-image">
                <img src="https://via.placeholder.com/100" alt="Profile">
            </div>
            <h3><%= user.getUsername() %></h3>
            <p><%= user.getEmail() %></p>
        </div>
        <ul class="nav-menu">
            <li class="nav-item"><a href="dashboard.jsp"><i class="icons fas fa-chart-pie"></i> Charts</a></li>
            <li class="nav-item"><a href="#"><i class="icons fas fa-wallet"></i> Financials</a></li>
            <li class="nav-item"><a href="#"><i class="icons fas fa-file-alt"></i> Reports</a></li>
            <li class="nav-item"><a href="budget.jsp"><i class="icons fas fa-money-bill-wave"></i> Budget</a></li>
            <li class="nav-item"><a href="income.jsp"><i class="icons fas fa-hand-holding-usd"></i> Income</a></li>
            <li class="nav-item"><a href="categories.jsp"><i class="icons fas fa-tags"></i> Categories</a></li>
        </ul>
    </div>

    <!-- Main Content -->
    <div class="content-area">
        <!-- Top Bar -->
        <div class="top-bar">
            <div class="page-title">
                <h1>Dashboard</h1>
            </div>
        </div>

        <!-- Dashboard Content -->
        <div class="dashboard-content">
            <!-- Stats Cards -->
            <div class="stats-grid">
                <div class="stat-card">
                    <h3>Income</h3>
                    <div class="value">$<%= dashboardData.getTotalIncome() %></div>
                </div>
                <div class="stat-card">
                    <h3>Expenses</h3>
                    <div class="value">$<%= dashboardData.getTotalExpenses() %></div>
                </div>
                <div class="stat-card">
                    <h3>Savings</h3>
                    <div class="value">$<%= dashboardData.getTotalSavings() %></div>
                </div>
            </div>

            <!-- Chart -->
            <div class="chart-container">
                <canvas id="myChart"></canvas>
            </div>
        </div>
    </div>
</div>

<script>
    // Initialize Chart
    document.addEventListener('DOMContentLoaded', function() {
        const ctx = document.getElementById('myChart').getContext('2d');
        const myChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                datasets: [{
                    label: 'Expenses',
                    data: [12, 19, 3, 5, 2, 3],
                    borderColor: 'rgb(255, 99, 132)',
                    fill: false
                }]
            }
        });
    });
</script>
</body>
</html>
