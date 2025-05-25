<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="javawork.personalexp.models.User" %>
<%@ page import="javawork.personalexp.models.Income" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // Check if user is logged in
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get user data
    int userId = Database.getUserIdByEmail(userEmail);
    User user = Database.getUserInfo(userId);
    
    // Get all data
    List<Map<String, Object>> categories = Database.getAllCategories(userId);
    List<Income> incomes = Database.getIncomes(userId);
    List<Map<String, Object>> budgets = Database.getAllBudgets(userId);
    List<Map<String, Object>> savingsGoals = Database.getAllSavingsGoals(userId);
    
    // Get average budgets across all users
    Map<String, Double> averageBudgets = Database.getAverageBudgetsByCategory();
    
    // Calculate totals
    double totalIncome = incomes != null ? incomes.stream().mapToDouble(Income::getAmount).sum() : 0;
    double totalBudget = budgets != null ? budgets.stream().mapToDouble(b -> (Double)b.get("budget_amount")).sum() : 0;
    double totalSpending = budgets != null ? budgets.stream().mapToDouble(b -> (Double)b.get("current_spending")).sum() : 0;
    double totalSavingsTarget = savingsGoals != null ? savingsGoals.stream().mapToDouble(g -> (Double)g.get("target_amount")).sum() : 0;
    double totalSavingsCurrent = savingsGoals != null ? savingsGoals.stream().mapToDouble(g -> (Double)g.get("current_amount")).sum() : 0;
    
    // Calculate budget ranking counts
    int highCount = 0, avgCount = 0, lowCount = 0;
    if (budgets != null) {
        for (Map<String, Object> budget : budgets) {
            String categoryName = (String) budget.get("category");
            Double avgBudget = averageBudgets.get(categoryName);
            if (avgBudget != null) {
                double budgetAmount = (Double) budget.get("budget_amount");
                double percentageDiff = ((budgetAmount - avgBudget) / avgBudget) * 100;
                
                if (percentageDiff > 20) highCount++;
                else if (percentageDiff < -20) lowCount++;
                else avgCount++;
            }
        }
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  
<!-- Apple Touch Icon (iOS) -->
<link rel="apple-touch-icon" sizes="180x180" href="/icons/apple-touch-icon.png">
<!-- Android Chrome -->
<link rel="icon" type="image/png" sizes="192x192" href="/icons/android-chrome-192x192.png">
<link rel="icon" type="image/png" sizes="512x512" href="/icons/android-chrome-512x512.png">
<!-- Favicon -->
<link rel="icon" type="image/png" sizes="32x32" href="/icons/favicon-32x32.png">
<link rel="icon" type="image/png" sizes="16x16" href="/icons/favicon-16x16.png">
<!-- Optional: Web Manifest for PWA -->
<link rel="manifest" href="/icons/site.webmanifest">
  <title>Personal Expenses Manager - Complete Report</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="../css/reports.css">
</head>
<body>
<div class="main-page">
    <!-- Sidebar -->
    <div id="sidebar">
        <div id="profile-section">
            <div class="profile-image">
                <img src="https://e7.pngegg.com/pngimages/442/16/png-clipart-computer-icons-man-icon-logo-silhouette.png" alt="Profile">
            </div>
            <h3><%= user.getUsername() %></h3>
            <p><%= user.getEmail() %></p>
        </div>
                
<ul class="nav-menu">
    <li class="nav-item"><a href="dashboard.jsp"><i class="icons fas fa-chart-pie"></i> Dashboard</a></li>
    <li class="nav-item"><a href="Financials goals.jsp"><i class="icons fas fa-wallet"></i> Financials</a></li>
    <li class="nav-item"><a href="reports.jsp"><i class="icons fas fa-file-alt"></i> Reports</a></li>
    <li class="nav-item"><a href="budget.jsp"><i class="icons fas fa-money-bill-wave"></i> Budget</a></li>
    <li class="nav-item"><a href="income.jsp"><i class="icons fas fa-hand-holding-usd"></i> Income</a></li>
    <li class="nav-item"><a href="categories.jsp"><i class="icons fas fa-tags"></i> Categories</a></li>
    <li class="nav-item"><a href="expenses.jsp"><i class="icons fas fa-shopping-cart"></i> Expenses</a></li>
    <li class="nav-item"><a href="logout.jsp"><i class="icons fas fa-sign-out-alt"></i> Logout</a></li>
</ul>
    </div>

    <div class="content-area">
        <div class="top-bar">
            <div class="page-title">
                <h1>Complete Financial Report</h1>
            </div>
            <div class="top-actions">
<%--                <div class="notification-btn">--%>
<%--                    <i class="fas fa-bell"></i>--%>
<%--                </div>--%>
<%--                <div class="settings-btn">--%>
<%--                    <i class="fas fa-cog"></i>--%>
<%--                </div>--%>
            </div>
        </div>

        <div class="report-content">
            <div class="summary-cards">
                <div class="summary-card income">
                    <h3>Total Income</h3>
                    <p class="value">$<%= String.format("%.2f", totalIncome) %></p>
                </div>
                
                <div class="summary-card budget">
                    <h3>Total Budget</h3>
                    <p class="value">$<%= String.format("%.2f", totalBudget) %></p>
                </div>
                
                <div class="summary-card spending">
                    <h3>Total Spending</h3>
                    <p class="value">$<%= String.format("%.2f", totalSpending) %></p>
                </div>
                
                <div class="summary-card comparison">
                    <h3>Budget Comparison</h3>
                    <div class="rank-summary">
                        <div class="rank-item">
                            <span class="badge high-rank"><%= highCount %></span>
                            <span>High</span>
                        </div>
                        <div class="rank-item">
                            <span class="badge avg-rank"><%= avgCount %></span>
                            <span>Average</span>
                        </div>
                        <div class="rank-item">
                            <span class="badge low-rank"><%= lowCount %></span>
                            <span>Low</span>
                        </div>
                    </div>
                </div>
            </div>
            <h3 class="section-header"><i class="fas fa-hand-holding-usd"></i> Income Sources</h3>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Source</th>
                        <th>Amount</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (incomes != null && !incomes.isEmpty()) { 
                        for (Income income : incomes) { %>
                    <tr>
                        <td><%= income.getId() %></td>
                        <td><%= income.getSource() %></td>
                        <td>$<%= String.format("%.2f", income.getAmount()) %></td>
                    </tr>
                    <% } 
                    } else { %>
                    <tr>
                        <td colspan="3" class="empty-state">No income sources found</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>

            <h3 class="section-header"><i class="fas fa-money-bill-wave"></i> Budgets</h3>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Category</th>
                        <th>Your Budget</th>
                        <th>Avg Budget</th>
                        <th>Comparison</th>
                        <th>Rank</th>
                        <th>Current Spending</th>
                        <th>Remaining</th>
                        <th>Created</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (budgets != null && !budgets.isEmpty()) { 
                        for (Map<String, Object> budget : budgets) { 
                            double budgetAmount = (Double) budget.get("budget_amount");
                            double currentSpending = (Double) budget.get("current_spending");
                            double remaining = budgetAmount - currentSpending;
                            String categoryName = (String) budget.get("category");
                            Double avgBudget = averageBudgets.get(categoryName);
                            
                            // Calculate comparison and rank
                            String comparison = "N/A";
                            String rank = "N/A";
                            String rankClass = "";
                            
                            if (avgBudget != null) {
                                double difference = budgetAmount - avgBudget;
                                double percentageDiff = (difference / avgBudget) * 100;
                                
                                if (percentageDiff > 20) {
                                    comparison = String.format("+%.1f%%", percentageDiff);
                                    rank = "High";
                                    rankClass = "high-rank";
                                } else if (percentageDiff < -20) {
                                    comparison = String.format("%.1f%%", percentageDiff);
                                    rank = "Low";
                                    rankClass = "low-rank";
                                } else {
                                    comparison = String.format("%.1f%%", percentageDiff);
                                    rank = "Average";
                                    rankClass = "avg-rank";
                                }
                            }
                    %>
                    <tr>
                        <td><%= budget.get("id") %></td>
                        <td><%= categoryName %></td>
                        <td>$<%= String.format("%.2f", budgetAmount) %></td>
                        <td><%= avgBudget != null ? "$" + String.format("%.2f", avgBudget) : "N/A" %></td>
                        <td><%= comparison %></td>
                        <td><span class="badge <%= rankClass %>"><%= rank %></span></td>
                        <td>$<%= String.format("%.2f", currentSpending) %></td>
                        <td style="color: <%= remaining >= 0 ? "#2ecc71" : "#e74c3c" %>">
                            $<%= String.format("%.2f", remaining) %>
                        </td>
                        <td><%= budget.get("created_at") != null ? dateFormat.format(budget.get("created_at")) : "N/A" %></td>
                    </tr>
                    <% } 
                    } else { %>
                    <tr>
                        <td colspan="9" class="empty-state">No budgets found</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>

            <h3 class="section-header"><i class="fas fa-piggy-bank"></i> Savings Goals</h3>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Title</th>
                        <th>Target Amount</th>
                        <th>Current Amount</th>
                        <th>Progress</th>
                        <th>Target Date</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (savingsGoals != null && !savingsGoals.isEmpty()) { 
                        for (Map<String, Object> goal : savingsGoals) { 
                            double target = (Double) goal.get("target_amount");
                            double current = (Double) goal.get("current_amount");
                            double progress = target > 0 ? (current / target) * 100 : 0;
                            boolean achieved = goal.get("achieved") != null && (Boolean) goal.get("achieved");
                    %>
                    <tr>
                        <td><%= goal.get("id") %></td>
                        <td><%= goal.get("title") %></td>
                        <td>$<%= String.format("%.2f", target) %></td>
                        <td>$<%= String.format("%.2f", current) %></td>
                        <td>
                            <div class="progress-container">
                                <div class="progress-bar" style="width: <%= progress %>%"></div>
                            </div>
                            <%= String.format("%.1f", progress) %>%
                        </td>
                        <td><%= goal.get("target_date") != null ? dateFormat.format(goal.get("target_date")) : "N/A" %></td>
                        <td>
                            <span class="badge <%= achieved ? "achieved" : "in-progress" %>">
                                <%= achieved ? "Achieved" : "In Progress" %>
                            </span>
                        </td>
                    </tr>
                    <% } 
                    } else { %>
                    <tr>
                        <td colspan="7" class="empty-state">No savings goals found</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
    // Profile click event
    document.getElementById('profile-section').addEventListener('click', function() {
        console.log("Profile clicked - can implement popup here");
    });

    // Notification button click
    document.querySelector('.notification-btn').addEventListener('click', function() {
        console.log("Notifications clicked - can implement notifications here");
    });

    // Settings button click
    document.querySelector('.settings-btn').addEventListener('click', function() {
        console.log("Settings clicked - can implement settings here");
    });
</script>
</body>
</html>