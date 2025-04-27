<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="javawork.personalexp.models.User" %>
<%@ page import="javawork.personalexp.models.Budget" %>
<%@ page import="javawork.personalexp.models.Category" %>
<%@ page import="java.util.List" %>
<%
    // Check if user is logged in
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = Database.getUserIdByEmail(userEmail);
    boolean isAdmin = Database.isAdmin(userId);
    User user = Database.getUserInfo(userId);

    // Handle form submissions
    if ("POST".equals(request.getMethod())) {
        String action = request.getParameter("action");
        
        try {
            if ("add".equals(action)) {
                int categoryId = Integer.parseInt(request.getParameter("categoryId"));
                String categoryName = request.getParameter("categoryName");
                double budgetAmount = Double.parseDouble(request.getParameter("budgetAmount"));
                double currentSpending = 0.0;
                
                String spendingParam = request.getParameter("currentSpending");
                if (spendingParam != null && !spendingParam.trim().isEmpty()) {
                    currentSpending = Double.parseDouble(spendingParam);
                }
                
                Database.addBudget(userId, categoryName, budgetAmount, currentSpending);
            } 
            else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                // For now, allow all users to delete their own budgets
                // You'll need to implement proper ownership checking in your Database class
                Database.deleteBudget(id);
            }
            else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                int categoryId = Integer.parseInt(request.getParameter("categoryId"));
                String categoryName = request.getParameter("categoryName");
                double budgetAmount = Double.parseDouble(request.getParameter("budgetAmount"));
                double currentSpending = Double.parseDouble(request.getParameter("currentSpending"));
                // For now, allow all users to update their own budgets
                Database.updateBudget(id, categoryName, budgetAmount, currentSpending);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        }
        
        response.sendRedirect("budget.jsp");
        return;
    }

    // Load data
    List<Budget> budgets = Database.getBudgets(userId);
    List<Category> categories = Database.getCategories(); // Get all categories
    
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
    <style>
        .modal {
            display: none;
            position: fixed;
            z-index: 1;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0,0,0,0.4);
        }
        .modal-content {
            background-color: #fefefe;
            margin: 15% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80%;
            max-width: 500px;
            border-radius: 5px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        .form-group input, .form-group select {
            width: 100%;
            padding: 8px;
            box-sizing: border-box;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .form-actions {
            text-align: right;
            margin-top: 20px;
        }
        .form-actions button {
            padding: 8px 15px;
            margin-left: 10px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .form-actions .save-btn {
            background-color: #4CAF50;
            color: white;
        }
        .form-actions .cancel-btn {
            background-color: #f44336;
            color: white;
        }
        .admin-badge {
            background-color: #4CAF50;
            color: white;
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 12px;
            margin-left: 10px;
        }
        .user-budget-actions {
            display: flex;
            gap: 5px;
        }
    </style>
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
            <% if (isAdmin) { %>
                <small>(Admin)</small>
            <% } %>
        </div>

        <ul class="nav-menu">
            <li class="nav-item"><a href="dashboard.jsp"><i class="icons fas fa-chart-pie"></i> Charts</a></li>
            <li class="nav-item"><a href="Financials goals.jsp"><i class="icons fas fa-wallet"></i> Financials</a></li>
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
                <% if (isAdmin) { %>
                    <span class="admin-badge">Admin Mode</span>
                <% } %>
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
                            <div class="user-budget-actions">
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

<!-- Add Budget Modal -->
<div id="addBudgetModal" class="modal">
    <div class="modal-content">
        <h2>Add New Budget</h2>
        <form id="addBudgetForm" method="POST" action="budget.jsp">
            <input type="hidden" name="action" value="add">
            
            <div class="form-group">
                <label for="category">Category:</label>
                <select id="category" name="categoryId" required>
                    <option value="">Select a category</option>
                    <% for (Category category : categories) { %>
                        <option value="<%= category.getId() %>"><%= category.getName() %></option>
                    <% } %>
                </select>
                <input type="hidden" id="categoryName" name="categoryName">
            </div>
            
            <div class="form-group">
                <label for="budgetAmount">Budget Amount:</label>
                <input type="number" id="budgetAmount" name="budgetAmount" step="0.01" min="0" required>
            </div>
            
            <div class="form-group">
                <label for="currentSpending">Current Spending (optional):</label>
                <input type="number" id="currentSpending" name="currentSpending" step="0.01" min="0" value="0">
            </div>
            
            <div class="form-actions">
                <button type="button" class="cancel-btn" onclick="closeAddModal()">Cancel</button>
                <button type="submit" class="save-btn">Save</button>
            </div>
        </form>
    </div>
</div>

<!-- Edit Budget Modal -->
<div id="editBudgetModal" class="modal">
    <div class="modal-content">
        <h2>Edit Budget</h2>
        <form id="editBudgetForm" method="POST" action="budget.jsp">
            <input type="hidden" name="action" value="update">
            <input type="hidden" id="editId" name="id">
            
            <div class="form-group">
                <label for="editCategory">Category:</label>
                <select id="editCategory" name="categoryId" required>
                    <option value="">Select a category</option>
                    <% for (Category category : categories) { %>
                        <option value="<%= category.getId() %>"><%= category.getName() %></option>
                    <% } %>
                </select>
                <input type="hidden" id="editCategoryName" name="categoryName">
            </div>
            
            <div class="form-group">
                <label for="editBudgetAmount">Budget Amount:</label>
                <input type="number" id="editBudgetAmount" name="budgetAmount" step="0.01" min="0" required>
            </div>
            
            <div class="form-group">
                <label for="editCurrentSpending">Current Spending:</label>
                <input type="number" id="editCurrentSpending" name="currentSpending" step="0.01" min="0" required>
            </div>
            
            <div class="form-actions">
                <button type="button" class="cancel-btn" onclick="closeEditModal()">Cancel</button>
                <button type="submit" class="save-btn">Save</button>
            </div>
        </form>
    </div>
</div>

<script>
    // Set up category name when selection changes
    document.getElementById('category').addEventListener('change', function() {
        var selectedOption = this.options[this.selectedIndex];
        document.getElementById('categoryName').value = selectedOption.text;
    });
    
    document.getElementById('editCategory').addEventListener('change', function() {
        var selectedOption = this.options[this.selectedIndex];
        document.getElementById('editCategoryName').value = selectedOption.text;
    });

    // Modal functions
    function openAddModal() {
        document.getElementById('addBudgetModal').style.display = 'block';
    }
    
    function closeAddModal() {
        document.getElementById('addBudgetModal').style.display = 'none';
    }
    
    function openEditModal(id, categoryName, budgetAmount, currentSpending) {
        // Find the category option that matches the current category name
        var select = document.getElementById('editCategory');
        for (var i = 0; i < select.options.length; i++) {
            if (select.options[i].text === categoryName) {
                select.selectedIndex = i;
                break;
            }
        }
        
        document.getElementById('editId').value = id;
        document.getElementById('editCategoryName').value = categoryName;
        document.getElementById('editBudgetAmount').value = budgetAmount;
        document.getElementById('editCurrentSpending').value = currentSpending;
        
        document.getElementById('editBudgetModal').style.display = 'block';
    }
    
    function closeEditModal() {
        document.getElementById('editBudgetModal').style.display = 'none';
    }
    
    function editBudget(id, categoryName, budgetAmount, currentSpending) {
        openEditModal(id, categoryName, budgetAmount, currentSpending);
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

    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('addBudgetBtn').addEventListener('click', openAddModal);
        
        window.addEventListener('click', function(event) {
            if (event.target.className === 'modal') {
                closeAddModal();
                closeEditModal();
            }
        });
    });
</script>
</body>
</html>