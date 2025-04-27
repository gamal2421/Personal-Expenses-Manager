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
    
    // Calculate totals
    double totalIncome = incomes != null ? incomes.stream().mapToDouble(Income::getAmount).sum() : 0;
    double totalBudget = budgets != null ? budgets.stream().mapToDouble(b -> (Double)b.get("budget_amount")).sum() : 0;
    double totalSpending = budgets != null ? budgets.stream().mapToDouble(b -> (Double)b.get("current_spending")).sum() : 0;
    double totalSavingsTarget = savingsGoals != null ? savingsGoals.stream().mapToDouble(g -> (Double)g.get("target_amount")).sum() : 0;
    double totalSavingsCurrent = savingsGoals != null ? savingsGoals.stream().mapToDouble(g -> (Double)g.get("current_amount")).sum() : 0;
    
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
  <link rel="stylesheet" href="../css/reports.css">
</head>
<body>
<div class="main-page">
    <!-- Sidebar remains the same -->
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
                
                <div class="summary-card savings">
                    <h3>Savings Progress</h3>
                    <p class="value">$<%= String.format("%.2f", totalSavingsCurrent) %> / $<%= String.format("%.2f", totalSavingsTarget) %></p>
                    <div class="progress-container">
                        <div class="progress-bar" style="width: <%= totalSavingsTarget > 0 ? (totalSavingsCurrent / totalSavingsTarget * 100) : 0 %>%"></div>
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
                        <td>N/A</td> <!-- Removed date formatting since getDate() doesn't exist -->
                    </tr>
                    <% } 
                    } else { %>
                    <tr>
                        <td colspan="4" class="empty-state">No income sources found</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>

            <!-- Rest of your tables (budgets and savings goals) remain the same -->
            <h3 class="section-header"><i class="fas fa-money-bill-wave"></i> Budgets</h3>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Category</th>
                        <th>Budget Amount</th>
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
                    %>
                    <tr>
                        <td><%= budget.get("id") %></td>
                        <td><%= budget.get("category") %></td>
                        <td>$<%= String.format("%.2f", budgetAmount) %></td>
                        <td>$<%= String.format("%.2f", currentSpending) %></td>
                        <td style="color: <%= remaining >= 0 ? "#2ecc71" : "#e74c3c" %>">
                            $<%= String.format("%.2f", remaining) %>
                        </td>
                        <td><%= budget.get("created_at") != null ? dateFormat.format(budget.get("created_at")) : "N/A" %></td>
                    </tr>
                    <% } 
                    } else { %>
                    <tr>
                        <td colspan="6" class="empty-state">No budgets found</td>
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