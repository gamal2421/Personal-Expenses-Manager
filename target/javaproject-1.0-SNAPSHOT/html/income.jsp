<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, com.google.gson.Gson" %>
<%@ page session="true" %>
<%
    // Step 1: Get logged-in user id
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        // Handle case where user is not logged in (redirect to login)
        response.sendRedirect("login.jsp");
        return;
    }

    // Step 2: Fetch user profile data from the database
    String userName = "";
    String userEmail = "";
    try {
        Class.forName("org.postgresql.Driver");
        Connection con = DriverManager.getConnection("jdbc:postgresql://localhost:5432/yourdb", "yourusername", "yourpassword");

        PreparedStatement ps = con.prepareStatement("SELECT name, email FROM users WHERE user_id = ?");
        ps.setString(1, userId);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            userName = rs.getString("name");
            userEmail = rs.getString("email");
        }

        rs.close();
        ps.close();
        con.close();
    } catch(Exception e) {
        e.printStackTrace();
    }

    // Step 3: Fetch income data (existing logic)
    List<Map<String, Object>> incomeData = new ArrayList<>();
    try {
        Connection con = DriverManager.getConnection("jdbc:postgresql://localhost:5432/yourdb", "yourusername", "yourpassword");

        PreparedStatement ps = con.prepareStatement("SELECT source_name AS label, amount FROM income_sources WHERE user_id = ?");
        ps.setString(1, userId);
        ResultSet rs = ps.executeQuery();

        while(rs.next()) {
            Map<String, Object> entry = new HashMap<>();
            entry.put("label", rs.getString("label"));
            entry.put("amount", rs.getDouble("amount"));
            incomeData.add(entry);
        }

        rs.close();
        ps.close();
        con.close();
    } catch(Exception e) {
        e.printStackTrace();
    }

    // Convert income data to JSON
    Gson gson = new Gson();
    String incomeDataJson = gson.toJson(incomeData);
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Personal Expenses Manager - Income</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <link rel="stylesheet" href="../css/income.css">
</head>
<body>

<div class="main-page">
    <!-- Sidebar -->
    <div id="sidebar">
        <div id="profile-section">
            <div class="profile-image">
                <img src="https://via.placeholder.com/100" alt="Profile">
            </div>
            <h3><%= userName %></h3>  <!-- Display fetched name -->
            <p>Financial Analyst</p>
        </div>
        
        <ul class="nav-menu">
            <li class="nav-item"><a href="dashboard.jsp"><i class="icons fas fa-chart-pie"></i> Charts</a></li>
            <li class="nav-item"><a href="Financials goals.jsp"><i class="icons fas fa-wallet"></i> Financials</a></li>
            <li class="nav-item"><a href="REPORTSandANALYTICS.jsp"><i class="icons fas fa-file-alt"></i> Reports</a></li>
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
                <h1>Income</h1>
            </div>
            <div class="top-actions">
                <div class="notification-btn">
                    <i class="fas fa-bell"></i>
                </div>
                <div class="settings-btn">
                    <i class="fas fa-cog"></i>
                </div>
            </div>
        </div>

        <!-- Content Box -->
        <div class="content-box">
            <div class="chart-container">
                <canvas id="incomeChart"></canvas>
            </div>

            <div class="income-entries" id="incomeEntries">
                <!-- Income entries will be added here dynamically -->
            </div>

            <button class="add-button" id="addIncomeBtn">+</button>
        </div>
    </div>

    <!-- Profile Overlay -->
    <div class="overlay" id="profileOverlay"></div>

    <!-- Profile Popup Card -->
    <div class="card profile-popup" id="profileCard">
        <div class="avatar">M</div>  <!-- You can dynamically replace this with the first letter of the user's name -->
        <div class="profile-info">
            <p><strong><%= userName %></strong></p>
            <p><%= userEmail %></p>
        </div>
        <div class="info-field">
            <label>Name</label>
            <p class="info-value"><%= userName %></p>
        </div>
        <div class="info-field">
            <label>Email Account</label>
            <p class="info-value"><%= userEmail %></p>
        </div>
    </div>
</div>

<!-- INCOME PAGE SCRIPTS -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const incomeData = <%= incomeDataJson %>;  // The income data passed from the server
        console.log(incomeData);  // Check if data is received correctly

        let chart;
        const colors = ['#00a97f', '#33c49f', '#66d9b3', '#99e5cc', '#ccefe5', '#ffc107', '#ff5722'];

        function renderChart() {
            const ctx = document.getElementById('incomeChart').getContext('2d');
            if (chart) chart.destroy();
            chart = new Chart(ctx, {
                type: 'pie',
                data: {
                    labels: incomeData.map(item => item.label),
                    datasets: [{
                        label: 'Income',
                        data: incomeData.map(item => item.amount),
                        backgroundColor: colors,
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'right' }
                    }
                }
            });
        }

        renderChart();
    });
</script>

</body>
</html>
