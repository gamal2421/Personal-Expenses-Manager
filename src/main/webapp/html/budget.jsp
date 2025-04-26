<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="javawork.personalexp.models.User" %>
<%@ page import="javawork.personalexp.models.Budget" %>
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
            if ("add".equals(action)) {
                String category = request.getParameter("category");
                double budgetAmount = Double.parseDouble(request.getParameter("budgetAmount"));
                double currentSpending = 0.0;
                
                // Safely get currentSpending parameter
                String spendingParam = request.getParameter("currentSpending");
                if (spendingParam != null && !spendingParam.trim().isEmpty()) {
                    currentSpending = Double.parseDouble(spendingParam);
                }
                
                Database.addBudget(userId, category, budgetAmount, currentSpending);
            } 
            else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Database.deleteBudget(id);
            }
            else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String category = request.getParameter("category");
                double budgetAmount = Double.parseDouble(request.getParameter("budgetAmount"));
                double currentSpending = Double.parseDouble(request.getParameter("currentSpending"));
                Database.updateBudget(id, category, budgetAmount, currentSpending);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        }
        
        response.sendRedirect("budget.jsp");
        return;
    }

    // Load data
    int userId = Database.getUserIdByEmail(userEmail);
    User user = Database.getUserInfo(userId);
    List<Budget> budgets = Database.getBudgets(userId);
    
    // Calculate totals
    double totalBudget = 0;
    double totalSpent = 0;
    for (Budget budget : budgets) {
        totalBudget += budget.getBudgetAmount();
        totalSpent += budget.getCurrentSpending();
    }
    double remaining = totalBudget - totalSpent;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Personal Expenses Manager - Budget</title>
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
            <li class="nav-item"><a href="dashboard.jsp"><i class="icons fas fa-chart-pie"></i> Charts</a></li>
            <li class="nav-item"><a href="#"><i class="icons fas fa-wallet"></i> Financials</a></li>
            <li class="nav-item"><a href="reports.jsp"><i class="icons fas fa-file-alt"></i> Reports</a></li>
            <li class="nav-item"><a href="budget.jsp"><i class="icons fas fa-money-bill-wave"></i> Budget</a></li>
            <li class="nav-item"><a href="income.jsp"><i class="icons fas fa-hand-holding-usd"></i> Income</a></li>
            <li class="nav-item"><a href="categories.jsp"><i class="icons fas fa-tags"></i> Categories</a></li>
        </ul>
    </div>

    <div class="content-area">
        <div class="top-bar">
            <div class="page-title">
                <h1>Budget</h1>
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
                    <div class="summary-value">$<%= String.format("%.2f", totalBudget) %></div>
                    <div class="summary-label">Total Budget</div>
                </div>
                <div class="summary-item">
                    <div class="summary-value">$<%= String.format("%.2f", totalSpent) %></div>
                    <div class="summary-label">Total Spent</div>
                </div>
                <div class="summary-item">
                    <div class="summary-value">$<%= String.format("%.2f", remaining) %></div>
                    <div class="summary-label">Remaining</div>
                </div>
            </div>

            <div class="budget-list" id="budgetList">
                <% if (budgets.isEmpty()) { %>
                    <div class="no-budget">No budget records found</div>
                <% } else { %>
                    <% for (Budget budget : budgets) { 
                        double percentage = (budget.getCurrentSpending() / budget.getBudgetAmount()) * 100;
                        double budgetRemaining = budget.getBudgetAmount() - budget.getCurrentSpending();
                    %>
                    <div class="budget-item">
                        <div class="budget-header">
                            <div class="budget-category"><%= budget.getCategory() %></div>
                            <div class="budget-amount">$<%= String.format("%.2f", budget.getCurrentSpending()) %> / $<%= String.format("%.2f", budget.getBudgetAmount()) %></div>
                            <div class="budget-actions">
                                <button class="budget-action-btn edit-btn" 
                                    onclick="editBudget(<%= budget.getId() %>, '<%= budget.getCategory() %>', <%= budget.getBudgetAmount() %>, <%= budget.getCurrentSpending() %>)">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="budget-action-btn delete-btn" 
                                    onclick="deleteBudget(<%= budget.getId() %>)">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </div>
                        <div class="progress-container">
                            <div class="progress-bar <%= percentage > 90 ? "danger" : percentage > 75 ? "warning" : "" %>" 
                                 style="width: <%= Math.min(percentage, 100) %>%"></div>
                        </div>
                        <div class="budget-details">
                            <span>$<%= String.format("%.2f", budgetRemaining) %> remaining</span>
                            <span><%= Math.round(percentage) %>% spent</span>
                        </div>
                    </div>
                    <% } %>
                <% } %>
            </div>

            <button class="add-budget-btn" id="addBudgetBtn">
                <i class="fas fa-plus"></i>
                Add Budget
            </button>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Add new budget
        document.getElementById('addBudgetBtn').addEventListener('click', function() {
            const category = prompt('Enter budget category:');
            if (category && category.trim()) {
                const budgetAmount = parseFloat(prompt('Enter budget amount:'));
                if (!isNaN(budgetAmount)) {
                    const currentSpending = parseFloat(prompt('Enter current spending:') || 0;
                    
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = 'budget.jsp';
                    
                    const actionInput = document.createElement('input');
                    actionInput.type = 'hidden';
                    actionInput.name = 'action';
                    actionInput.value = 'add';
                    form.appendChild(actionInput);
                    
                    const categoryInput = document.createElement('input');
                    categoryInput.type = 'hidden';
                    categoryInput.name = 'category';
                    categoryInput.value = category;
                    form.appendChild(categoryInput);
                    
                    const amountInput = document.createElement('input');
                    amountInput.type = 'hidden';
                    amountInput.name = 'budgetAmount';
                    amountInput.value = budgetAmount;
                    form.appendChild(amountInput);
                    
                    const spendingInput = document.createElement('input');
                    spendingInput.type = 'hidden';
                    spendingInput.name = 'currentSpending';
                    spendingInput.value = currentSpending;
                    form.appendChild(spendingInput);
                    
                    document.body.appendChild(form);
                    form.submit();
                } else {
                    alert('Please enter a valid amount');
                }
            }
        });
    });

    function editBudget(id, currentCategory, currentBudgetAmount, currentSpending) {
        const newCategory = prompt('Edit budget category:', currentCategory);
        if (newCategory && newCategory.trim()) {
            const newBudgetAmount = parseFloat(prompt('Edit budget amount:', currentBudgetAmount));
            if (!isNaN(newBudgetAmount)) {
                const newCurrentSpending = parseFloat(prompt('Edit current spending:', currentSpending));
                
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'budget.jsp';
                
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
                
                const categoryInput = document.createElement('input');
                categoryInput.type = 'hidden';
                categoryInput.name = 'category';
                categoryInput.value = newCategory;
                form.appendChild(categoryInput);
                
                const amountInput = document.createElement('input');
                amountInput.type = 'hidden';
                amountInput.name = 'budgetAmount';
                amountInput.value = newBudgetAmount;
                form.appendChild(amountInput);
                
                const spendingInput = document.createElement('input');
                spendingInput.type = 'hidden';
                spendingInput.name = 'currentSpending';
                spendingInput.value = newCurrentSpending;
                form.appendChild(spendingInput);
                
                document.body.appendChild(form);
                form.submit();
            } else {
                alert('Please enter a valid amount');
            }
        }
    }

    function deleteBudget(id) {
        if (confirm('Are you sure you want to delete this budget?')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'budget.jsp';
            
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