<%@ page import="java.sql.Date" %>
<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="javawork.personalexp.models.User" %>
<%@ page import="javawork.personalexp.models.SavingGoal" %>
<%@ page import="java.util.List" %>
<%
    // Check if user is logged in
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Handle form submissions
    if ("POST".equals(request.getMethod())) {
        String action = request.getParameter("action");
        int userId = Database.getUserIdByEmail(userEmail);
        
        try {
            if ("add".equals(action) || "update".equals(action)) {
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                double targetAmount = Double.parseDouble(request.getParameter("targetAmount"));
                double currentAmount = Double.parseDouble(request.getParameter("currentAmount"));
                Date targetDate = Date.valueOf(request.getParameter("targetDate"));
                
                if ("add".equals(action)) {
                    Database.addSavingGoal(userId, title, description, targetAmount, targetDate, currentAmount);
                } else {
                    int id = Integer.parseInt(request.getParameter("id"));
                    Database.updateSavingGoal(id, title, description, targetAmount, targetDate, currentAmount);
                }
            } 
            else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Database.deleteSavingGoal(id);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        }
        
        response.sendRedirect("Financials goals.jsp");
        return;
    }

    // Load data
    int userId = Database.getUserIdByEmail(userEmail);
    User user = Database.getUserInfo(userId);
    List<SavingGoal> goals = Database.getSavingGoals(userId);
    
    // Calculate totals
    double totalTarget = 0;
    double totalSaved = 0;
    for (SavingGoal goal : goals) {
        totalTarget += goal.getTargetAmount();
        totalSaved += goal.getCurrentAmount();
    }
    double remaining = totalTarget - totalSaved;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Personal Expenses Manager - Financial Goals</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link rel="stylesheet" href="../css/budget.css">
</head>
<body>
<div class="main-page">
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
</ul>
    </div>

    <div class="content-area">
        <div class="top-bar">
            <div class="page-title">
                <h1>Financial Goals</h1>
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

        <div class="budget-content">
            <div class="budget-summary">
                <div class="summary-item">
                    <div class="summary-value">$<%= String.format("%.2f", totalTarget) %></div>
                    <div class="summary-label">Total Target</div>
                </div>
                <div class="summary-item">
                    <div class="summary-value">$<%= String.format("%.2f", totalSaved) %></div>
                    <div class="summary-label">Total Saved</div>
                </div>
                <div class="summary-item">
                    <div class="summary-value">$<%= String.format("%.2f", remaining) %></div>
                    <div class="summary-label">Remaining</div>
                </div>
            </div>

            <div class="budget-list" id="budgetList">
                <% if (goals.isEmpty()) { %>
                    <div class="no-budget">No financial goals found</div>
                <% } else { %>
                    <% for (SavingGoal goal : goals) { 
                        double percentage = (goal.getCurrentAmount() / goal.getTargetAmount()) * 100;
                        double goalRemaining = goal.getTargetAmount() - goal.getCurrentAmount();
                    %>
                    <div class="budget-item">
                        <div class="budget-header">
                            <div class="budget-category"><%= goal.getTitle() %></div>
                            <div class="budget-amount">
                                $<%= String.format("%.2f", goal.getCurrentAmount()) %> / $<%= String.format("%.2f", goal.getTargetAmount()) %>
                            </div>
                            <div class="budget-actions">
                                <button class="budget-action-btn edit-btn" 
                                    onclick="editGoal(<%= goal.getId() %>, '<%= goal.getTitle().replace("'", "\\'") %>', 
                                    '<%= goal.getDescription() != null ? goal.getDescription().replace("'", "\\'") : "" %>', 
                                    <%= goal.getTargetAmount() %>, <%= goal.getCurrentAmount() %>, 
                                    '<%= goal.getTargetDate() %>')">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="budget-action-btn delete-btn" 
                                    onclick="deleteGoal(<%= goal.getId() %>)">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </div>
                        <% if (goal.getDescription() != null && !goal.getDescription().isEmpty()) { %>
                            <p class="goal-description"><%= goal.getDescription() %></p>
                        <% } %>
                        <div class="progress-container">
                            <div class="progress-bar <%= percentage > 90 ? "danger" : percentage > 75 ? "warning" : "" %>" 
                                 style="width: <%= Math.min(percentage, 100) %>%"></div>
                        </div>
                        <div class="budget-details">
                            <span>Target Date: <%= goal.getTargetDate() %></span>
                            <span>$<%= String.format("%.2f", goalRemaining) %> remaining</span>
                            <span><%= Math.round(percentage) %>% saved</span>
                            <span>Status: <%= goal.isAchieved() ? "✓ Achieved" : "In Progress" %></span>
                        </div>
                    </div>
                    <% } %>
                <% } %>
            </div>

            <button class="add-budget-btn" id="addGoalBtn">
                <i class="fas fa-plus"></i>
                Add Goal
            </button>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Add new goal
        document.getElementById('addGoalBtn').addEventListener('click', function() {
            const title = prompt('Enter goal title:');
            if (title && title.trim()) {
                const description = prompt('Enter description (optional):') || '';
                const targetAmount = parseFloat(prompt('Enter target amount:'));
                if (!isNaN(targetAmount)) {
                    const currentAmount = parseFloat(prompt('Enter current saved amount:') || 0);
                    const targetDate = prompt('Enter target date (YYYY-MM-DD):');
                    
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = 'Financials goals.jsp';
                    
                    const actionInput = document.createElement('input');
                    actionInput.type = 'hidden';
                    actionInput.name = 'action';
                    actionInput.value = 'add';
                    form.appendChild(actionInput);
                    
                    const titleInput = document.createElement('input');
                    titleInput.type = 'hidden';
                    titleInput.name = 'title';
                    titleInput.value = title;
                    form.appendChild(titleInput);
                    
                    const descInput = document.createElement('input');
                    descInput.type = 'hidden';
                    descInput.name = 'description';
                    descInput.value = description;
                    form.appendChild(descInput);
                    
                    const targetInput = document.createElement('input');
                    targetInput.type = 'hidden';
                    targetInput.name = 'targetAmount';
                    targetInput.value = targetAmount;
                    form.appendChild(targetInput);
                    
                    const currentInput = document.createElement('input');
                    currentInput.type = 'hidden';
                    currentInput.name = 'currentAmount';
                    currentInput.value = currentAmount;
                    form.appendChild(currentInput);
                    
                    const dateInput = document.createElement('input');
                    dateInput.type = 'hidden';
                    dateInput.name = 'targetDate';
                    dateInput.value = targetDate;
                    form.appendChild(dateInput);
                    
                    document.body.appendChild(form);
                    form.submit();
                } else {
                    alert('Please enter a valid amount');
                }
            }
        });
    });

    function editGoal(id, currentTitle, currentDescription, currentTargetAmount, 
                     currentAmount, currentTargetDate) {
        const newTitle = prompt('Edit goal title:', currentTitle);
        if (newTitle && newTitle.trim()) {
            const newDescription = prompt('Edit description:', currentDescription || '');
            const newTargetAmount = parseFloat(prompt('Edit target amount:', currentTargetAmount));
            if (!isNaN(newTargetAmount)) {
                const newCurrentAmount = parseFloat(prompt('Edit current saved amount:', currentAmount));
                const newTargetDate = prompt('Edit target date (YYYY-MM-DD):', currentTargetDate);
                
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'Financials goals.jsp';
                
                const actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.value = 'update';
                form.appendChild(actionInput);
                
                const idInput = document.createElement('input');
                idInput.type = 'hidden';
                idInput.name = 'id';
                idInput.value = id;
                form.appendChild(idInput);
                
                const titleInput = document.createElement('input');
                titleInput.type = 'hidden';
                titleInput.name = 'title';
                titleInput.value = newTitle;
                form.appendChild(titleInput);
                
                const descInput = document.createElement('input');
                descInput.type = 'hidden';
                descInput.name = 'description';
                descInput.value = newDescription;
                form.appendChild(descInput);
                
                const targetInput = document.createElement('input');
                targetInput.type = 'hidden';
                targetInput.name = 'targetAmount';
                targetInput.value = newTargetAmount;
                form.appendChild(targetInput);
                
                const currentInput = document.createElement('input');
                currentInput.type = 'hidden';
                currentInput.name = 'currentAmount';
                currentInput.value = newCurrentAmount;
                form.appendChild(currentInput);
                
                const dateInput = document.createElement('input');
                dateInput.type = 'hidden';
                dateInput.name = 'targetDate';
                dateInput.value = newTargetDate;
                form.appendChild(dateInput);
                
                document.body.appendChild(form);
                form.submit();
            } else {
                alert('Please enter a valid amount');
            }
        }
    }

    function deleteGoal(id) {
        if (confirm('Are you sure you want to delete this goal?')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'Financials goals.jsp';
            
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'delete';
            form.appendChild(actionInput);
            
            const idInput = document.createElement('input');
            idInput.type = 'hidden';
            idInput.name = 'id';
            idInput.value = id;
            form.appendChild(idInput);
            
            document.body.appendChild(form);
            form.submit();
        }
    }
</script>
</body>
</html>