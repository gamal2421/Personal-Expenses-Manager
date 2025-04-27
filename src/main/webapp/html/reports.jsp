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
  <title>Personal Expenses Manager - Complete Report</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <style>
    /* Background Gradient */
    body, html {
        height: 100%;
        margin: 0;
        font-family: 'Poppins', sans-serif;
        background: linear-gradient(to right, #f4f9f4, #e0f7fa);
    }

    /* Main Container */
    .main-page {
        display: flex;
        min-height: 100vh;
        width: 100%;
        padding: 20px;
        box-sizing: border-box;
    }

    /* Sidebar Styling */
    #sidebar {
        background-color: rgb(246, 247, 244);
        border-radius: 16px;
        width: 250px;
        text-align: center;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        padding: 20px;
        display: flex;
        flex-direction: column;
    }

    /* Profile Section */
    #profile-section {
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
        background: white;
        border-radius: 16px;
        padding: 20px;
        box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
        cursor: pointer;
        margin-bottom: 30px;
    }

    /* Profile Image */
    .profile-image {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        border: 3px solid #1abc9c;
        overflow: hidden;
        margin-bottom: 10px;
    }

    .profile-image img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }

    /* Navigation */
    .nav-menu {
        list-style: none;
        padding: 0;
        margin: 0;
        flex-grow: 1;
    }

    .nav-item {
        margin-bottom: 15px;
    }

    .nav-item a {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 12px 15px;
        border-radius: 12px;
        background-color: #f9f9f9;
        color: #333;
        text-decoration: none;
        transition: all 0.3s ease;
        font-size: 14px;
    }

    .nav-item a:hover {
        background-color: #3ab19b;
        color: white;
        transform: translateX(5px);
    }

    .nav-item a:hover .icons {
        color: white;
    }

    .icons {
        color: #3ab19b;
        font-size: 1.1em;
        width: 20px;
        text-align: center;
    }

    /* Main Content Area */
    .content-area {
        flex-grow: 1;
        margin-left: 20px;
        display: flex;
        flex-direction: column;
    }

    /* Top Bar */
    .top-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        background: white;
        border-radius: 16px;
        padding: 15px 25px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
        margin-bottom: 20px;
    }

    .page-title h1 {
        margin: 0;
        font-size: 24px;
        color: #333;
    }

    .top-actions {
        display: flex;
        gap: 15px;
    }

    .notification-btn, .settings-btn {
        background: white;
        color: #3ab19b;
        width: 40px;
        height: 40px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 0 10px rgba(58, 177, 155, 0.2);
        cursor: pointer;
        transition: all 0.3s ease;
    }

    .notification-btn:hover, .settings-btn:hover {
        transform: scale(1.1);
        color: #1abc9c;
    }

    /* Report Content */
    .report-content {
        background: white;
        border-radius: 16px;
        padding: 25px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    }

    /* Summary Cards */
    .summary-cards {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 20px;
        margin-bottom: 30px;
    }

    .summary-card {
        background: #f9f9f9;
        border-radius: 12px;
        padding: 20px;
        text-align: center;
        transition: all 0.3s ease;
    }

    .summary-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 6px 16px rgba(58, 177, 155, 0.15);
    }

    .summary-card h3 {
        margin: 0 0 10px 0;
        font-size: 16px;
        color: #666;
    }

    .summary-card .value {
        font-size: 24px;
        font-weight: bold;
        color: #3ab19b;
    }

    .summary-card.income .value {
        color: #2ecc71;
    }

    .summary-card.budget .value {
        color: #3498db;
    }

    .summary-card.spending .value {
        color: #e74c3c;
    }

    .summary-card.comparison {
        background: #f8f9fa;
    }

    /* Progress Bar */
    .progress-container {
        width: 100%;
        height: 8px;
        background: #ecf0f1;
        border-radius: 4px;
        margin-top: 10px;
        overflow: hidden;
    }

    .progress-bar {
        height: 100%;
        background: #3ab19b;
        border-radius: 4px;
        transition: width 0.5s ease;
    }

    /* Rank Summary */
    .rank-summary {
        display: flex;
        justify-content: space-around;
        margin-top: 15px;
    }

    .rank-item {
        display: flex;
        flex-direction: column;
        align-items: center;
    }

    /* Badges */
    .badge {
        padding: 4px 8px;
        border-radius: 12px;
        font-size: 12px;
        font-weight: 500;
    }

    .high-rank {
        background-color: #e74c3c;
        color: white;
    }

    .avg-rank {
        background-color: #f39c12;
        color: white;
    }

    .low-rank {
        background-color: #2ecc71;
        color: white;
    }

    .achieved {
        background-color: #2ecc71;
        color: white;
    }

    .in-progress {
        background-color: #f39c12;
        color: white;
    }

    /* Tables */
    table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 30px;
    }

    th {
        text-align: left;
        padding: 12px 15px;
        background: #f9f9f9;
        color: #333;
        font-weight: 500;
    }

    td {
        padding: 12px 15px;
        border-bottom: 1px solid #eee;
        vertical-align: middle;
    }

    tr:last-child td {
        border-bottom: none;
    }

    tr:hover td {
        background-color: #f5f5f5;
    }

    /* Section Headers */
    .section-header {
        margin: 30px 0 15px 0;
        color: #3ab19b;
        font-size: 18px;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    /* Empty State */
    .empty-state {
        text-align: center;
        color: #7f8c8d;
        padding: 20px;
    }

    /* Action Buttons */
    .action-buttons {
        display: flex;
        gap: 10px;
    }
  </style>
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
            <li class="nav-item"><a href="dashboard.jsp"><i class="icons fas fa-chart-pie"></i> <span>Dashboard</span></a></li>
            <li class="nav-item"><a href="Financials goals.jsp"><i class="icons fas fa-wallet"></i> <span>Financials</span></a></li>
            <li class="nav-item"><a href="reports.jsp" style="background-color: #3ab19b; color: white;"><i class="icons fas fa-file-alt"></i> <span>Reports</span></a></li>
            <li class="nav-item"><a href="budget.jsp"><i class="icons fas fa-money-bill-wave"></i> <span>Budget</span></a></li>
            <li class="nav-item"><a href="income.jsp"><i class="icons fas fa-hand-holding-usd"></i> <span>Income</span></a></li>
            <li class="nav-item"><a href="categories.jsp"><i class="icons fas fa-tags"></i> <span>Categories</span></a></li>
        </ul>
    </div>

    <div class="content-area">
        <div class="top-bar">
            <div class="page-title">
                <h1>Complete Financial Report</h1>
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

            <h3 class="section-header"><i class="fas fa-tags"></i> Categories</h3>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Category Name</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (categories != null && !categories.isEmpty()) { 
                        for (Map<String, Object> category : categories) { %>
                    <tr>
                        <td><%= category.get("id") %></td>
                        <td><%= category.get("name") %></td>
                    </tr>
                    <% } 
                    } else { %>
                    <tr>
                        <td colspan="2" class="empty-state">No categories found</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>

            <h3 class="section-header"><i class="fas fa-hand-holding-usd"></i> Income Sources</h3>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Source</th>
                        <th>Amount</th>
                        <th>Date</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (incomes != null && !incomes.isEmpty()) { 
                        for (Income income : incomes) { %>
                    <tr>
                        <td><%= income.getId() %></td>
                        <td><%= income.getSource() %></td>
                        <td>$<%= String.format("%.2f", income.getAmount()) %></td>
                        <td>N/A</td>
                    </tr>
                    <% } 
                    } else { %>
                    <tr>
                        <td colspan="4" class="empty-state">No income sources found</td>
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