<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="javawork.personalexp.models.User" %>
<%@ page import="javawork.personalexp.models.Expense" %>
<%@ page import="javawork.personalexp.models.Category" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="javawork.personalexp.models.Budget" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.time.LocalDate" %>
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
    List<Expense> expenses = Database.getExpenses(userId);
    List<Category> categories = Database.getCategories();
    List<Budget> budgets = Database.getBudgets(userId);

    // Build category -> budget amount map
    Map<String, Double> categoryBudgets = new HashMap<>();
    Map<String, String> categoryBudgetTypes = new HashMap<>();
    Map<String, String> categoryBudgetPeriods = new HashMap<>();
    for (Budget budget : budgets) {
        // Only use the current period/monthly for now (can expand logic as needed)
        if ("monthly".equals(budget.getBudgetType())) {
            LocalDate period = LocalDate.parse(budget.getPeriodStart());
            if (period.getYear() == java.time.LocalDate.now().getYear() && period.getMonthValue() == java.time.LocalDate.now().getMonthValue()) {
                categoryBudgets.put(budget.getCategory(), budget.getBudgetAmount());
                categoryBudgetTypes.put(budget.getCategory(), budget.getBudgetType());
                categoryBudgetPeriods.put(budget.getCategory(), budget.getPeriodStart());
            }
        }
        // Optionally add logic for yearly/midyear if you want to support those too
    }
    // Build category -> total spent map
    Map<String, Double> categoryTotals = new HashMap<>();
    for (Expense expense : expenses) {
        String cat = expense.getCategoryName();
        categoryTotals.put(cat, categoryTotals.getOrDefault(cat, 0.0) + expense.getAmount());
    }

    // Handle form submission
    if ("POST".equals(request.getMethod())) {
        String action = request.getParameter("action");
        
        try {
            if ("add".equals(action)) {
                int categoryId = Integer.parseInt(request.getParameter("categoryId"));
                double amount = Double.parseDouble(request.getParameter("amount"));
                String description = request.getParameter("description");
                
                boolean success = Database.addExpense(userId, categoryId, amount, description);
                if (success) {
                    response.sendRedirect("expenses.jsp?success=Expense+added+successfully");
                    return;
                } else {
                    request.setAttribute("error", "Failed to add expense. Please make sure you have a budget set up for this category.");
                }
            } 
            else if ("update".equals(action)) {
                int expenseId = Integer.parseInt(request.getParameter("expenseId"));
                int categoryId = Integer.parseInt(request.getParameter("categoryId"));
                double amount = Double.parseDouble(request.getParameter("amount"));
                String description = request.getParameter("description");
                
                boolean success = Database.updateExpense(expenseId, categoryId, amount, description);
                if (success) {
                    response.sendRedirect("expenses.jsp?success=Expense+updated+successfully");
                    return;
                } else {
                    request.setAttribute("error", "Failed to update expense. Please try again.");
                }
            }
            else if ("delete".equals(action)) {
                int expenseId = Integer.parseInt(request.getParameter("expenseId"));
                boolean success = Database.deleteExpense(expenseId);
                if (success) {
                    response.sendRedirect("expenses.jsp?success=Expense+deleted+successfully");
                    return;
                } else {
                    request.setAttribute("error", "Failed to delete expense. Please try again.");
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Refresh data if we're not redirecting
        expenses = Database.getExpenses(userId);
        categories = Database.getCategories();
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Personal Expenses Manager - Expenses</title>
    
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

    <link href="/Personal-Expenses-Manager/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<link rel="stylesheet" href="../css/expenses.css">
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
            <li class="nav-item"><a href="expenses.jsp" ><i class="icons fas fa-shopping-cart"></i> Expenses</a></li>
            <li class="nav-item"><a href="ai_suggests.jsp"><i class="icons fas fa-lightbulb"></i> AI Suggests</a></li>
            <li class="nav-item"><a href="logout.jsp"><i class="icons fas fa-sign-out-alt"></i> Logout</a></li>
        </ul>
    </div>
    
    <!-- Main Content -->
    <div class="content-area">
        <div class="top-bar">
            <div class="page-title">
                <h1>Expense Tracking</h1>
            </div>
            <div class="top-actions">
                <button class="add-budget-btn" id="addExpenseBtn">
                    <i class="fas fa-plus"></i> Add Expense
                </button>
            </div>
        </div>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert-danger">
                <i class="fas fa-exclamation-circle"></i> 
                <strong>Error:</strong> <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
        <% if (request.getParameter("success") != null) { %>
            <div class="alert-success">
                <i class="fas fa-check-circle"></i> 
                <%= request.getParameter("success") %>
            </div>
        <% } %>
        
        <div class="expense-content">
            <div class="budget-list">
                <% if (expenses.isEmpty()) { %>
                    <div class="empty-state">
                        <i class="fas fa-shopping-cart"></i>
                        <p>No expenses found. Add your first expense to get started.</p>
                    </div>
                <% } else { %>
                    <% for (Expense expense : expenses) { %>
                    <% String escapedDescription = expense.getDescription().replace("\"", "\\\""); %>
                    <% 
                        String catName = expense.getCategoryName();
                        double totalSpent = categoryTotals.get(catName);
                        double budgetAmount = categoryBudgets.getOrDefault(catName, 0.0);
                        boolean isOverBudget = budgetAmount > 0 && totalSpent > budgetAmount;
                        String budgetType = categoryBudgetTypes.get(catName);
                        String budgetPeriod = categoryBudgetPeriods.get(catName);
                    %>
                    <div class="expense-item <%= isOverBudget ? "over-budget" : "" %>" id="expense-<%= expense.getId() %>">
                        <div class="expense-header">
                            <div class="expense-category"><%= expense.getCategoryName() %></div>
                            <div class="expense-amount">-$<%= String.format("%.2f", expense.getAmount()) %></div>
                            <div class="expense-actions">
                                <button class='action-btn edit-btn' onclick='openEditModal("<%= expense.getId() %>", "<%= expense.getCategoryId() %>", "<%= expense.getAmount() %>", "<%= escapedDescription %>")'>
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="action-btn delete-btn" onclick="deleteExpense('<%= expense.getId() %>')">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </div>
                        <% if (budgetType != null && budgetPeriod != null) { %>
                        <div class="budget-meta" style="font-size: 12px; color: #888; margin-bottom: 4px;">
                            <span>Budget Type: <%= budgetType.substring(0,1).toUpperCase() + budgetType.substring(1) %></span>
                            &nbsp;|&nbsp;
                            <span>Period Start: <%= budgetPeriod %></span>
                        </div>
                        <% } %>
                        <% if (isOverBudget) { %>
                        <div class="over-budget-warning" style="color: red; font-weight: bold; margin-bottom: 5px; display: flex; align-items: center;"><i class="fas fa-exclamation-triangle" style="margin-right: 6px;"></i> Over Budget!</div>
                        <% } %>
                        <div class="expense-description"><%= expense.getDescription() %></div>
                        <div class="expense-date"><%= dateFormat.format(expense.getDate()) %></div>
                    </div>
                    <% } %>
                <% } %>
            </div>
        </div>
    </div>
</div>

<!-- Add Expense Modal -->
<div class="modal-overlay" id="addExpenseModal">
    <div style="padding : 40px ;" class="modal">
        <div class="modal-header">
            <h2 class="modal-title">Add New Expense</h2>
            <button class="modal-close" onclick="closeAddModal()">&times;</button>
        </div>
        <form id="addExpenseForm" method="POST" action="expenses.jsp">
            <input type="hidden" name="action" value="add">
            
            <div class="form-group">
                <label for="category" class="form-label">Category</label>
                <select id="category" name="categoryId" class="form-input" required>
                    <option value="">Select a category</option>
                    <%
                        java.util.Set<String> seenCategories = new java.util.HashSet<>();
                        for (Category category : categories) {
                            String catName = category.getName();
                            if (!seenCategories.contains(catName)) {
                                seenCategories.add(catName);
                                String label = catName;
                                String type = categoryBudgetTypes.get(catName);
                                String period = categoryBudgetPeriods.get(catName);
                                if (type != null && period != null) {
                                    label += " (Type: " + type.substring(0,1).toUpperCase() + type.substring(1) + ", Period: " + period + ")";
                                }
                    %>
                        <option value="<%= category.getId() %>"><%= label %></option>
                    <%
                            }
                        }
                    %>
                </select>
            </div>
            
            <div class="form-group">
                <label for="amount" class="form-label">Amount</label>
                <input type="number" id="amount" name="amount" class="form-input"
                       step="0.01" min="0.01" required>
            </div>
            
            <div class="form-group">
                <label for="description" class="form-label">Description</label>
                <input type="text" id="description" name="description" class="form-input"
                       required placeholder="e.g., Groceries at Walmart">
            </div>
            
            <div class="form-actions">
                <button type="button" class="btn btn-secondary" onclick="closeAddModal()">Cancel</button>
                <button type="submit" class="btn btn-primary">Add Expense</button>
            </div>
        </form>
    </div>
</div>

<!-- Edit Expense Modal -->
<div class="modal-overlay" id="editExpenseModal">
    <div class="modal">
        <div class="modal-header">
            <h2 class="modal-title">Edit Expense</h2>
            <button class="modal-close" onclick="closeEditModal()">&times;</button>
        </div>
        <form id="editExpenseForm" method="POST" action="expenses.jsp">
            <input type="hidden" name="action" value="update">
            <input type="hidden" id="editExpenseId" name="expenseId">
            
            <div class="form-group">
                <label for="editCategory" class="form-label">Category</label>
                <select id="editCategory" name="categoryId" class="form-input" required>
                    <option value="">Select a category</option>
                    <%
                        seenCategories = new java.util.HashSet<>();
                        for (Category category : categories) {
                            String catName = category.getName();
                            if (!seenCategories.contains(catName)) {
                                seenCategories.add(catName);
                                String label = catName;
                                String type = categoryBudgetTypes.get(catName);
                                String period = categoryBudgetPeriods.get(catName);
                                if (type != null && period != null) {
                                    label += " (Type: " + type.substring(0,1).toUpperCase() + type.substring(1) + ", Period: " + period + ")";
                                }
                    %>
                        <option value="<%= category.getId() %>"><%= label %></option>
                    <%
                            }
                        }
                    %>
                </select>
            </div>
            
            <div class="form-group">
                <label for="editAmount" class="form-label">Amount</label>
                <input type="number" id="editAmount" name="amount" class="form-input"
                       step="0.01" min="0.01" required>
            </div>
            
            <div class="form-group">
                <label for="editDescription" class="form-label">Description</label>
                <input type="text" id="editDescription" name="description" class="form-input"
                       required>
            </div>
            
            <div class="form-actions">
                <button type="button" class="btn btn-secondary" onclick="closeEditModal()">Cancel</button>
                <button type="submit" class="btn btn-primary">Save Changes</button>
            </div>
        </form>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal-overlay" id="deleteExpenseModal">
    <div class="modal confirmation-dialog">
        <div class="modal-header">
            <h2 class="modal-title">Confirm Deletion</h2>
            <button class="modal-close" onclick="closeDeleteModal()">&times;</button>
        </div>
        <div class="modal-body">
            <div class="icon-wrapper">
                <i class="fas fa-exclamation-triangle"></i>
            </div>
            <p>Are you sure you want to delete this expense?</p>
        </div>
        <div class="form-actions">
            <button type="button" class="btn btn-secondary" onclick="closeDeleteModal()">Cancel</button>
            <button type="button" class="btn btn-danger" onclick="confirmDelete()">Delete</button>
        </div>
    </div>
</div>

<script>
    // Modal functions
    function openAddModal() {
        document.getElementById('addExpenseModal').classList.add('active');
    }
    
    function closeAddModal() {
        document.getElementById('addExpenseModal').classList.remove('active');
    }
    
    function openEditModal(expenseId, categoryId, amount, description) {
        document.getElementById('editExpenseId').value = expenseId;
        document.getElementById('editCategory').value = categoryId;
        document.getElementById('editAmount').value = amount;
        document.getElementById('editDescription').value = description;
        document.getElementById('editExpenseModal').classList.add('active');
    }
    
    function closeEditModal() {
        document.getElementById('editExpenseModal').classList.remove('active');
    }
    
    let expenseToDelete = null;
    
    function deleteExpense(expenseId) {
        expenseToDelete = expenseId;
        document.getElementById('deleteExpenseModal').classList.add('active');
    }
    
    function closeDeleteModal() {
        expenseToDelete = null;
        document.getElementById('deleteExpenseModal').classList.remove('active');
    }
    
    function confirmDelete() {
        if (expenseToDelete) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'expenses.jsp';
            
            const actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'delete';
            form.appendChild(actionInput);
            
            const idInput = document.createElement('input');
            idInput.type = 'hidden';
            idInput.name = 'expenseId';
            idInput.value = expenseToDelete;
            form.appendChild(idInput);
            
            document.body.appendChild(form);
            form.submit();
        }
    }
    
    // Form validation
    document.getElementById('addExpenseForm').addEventListener('submit', function(e) {
        const category = document.getElementById('category');
        const amount = parseFloat(document.getElementById('amount').value);
        const description = document.getElementById('description').value.trim();
        
        if (category.value === '') {
            alert('Please select a category');
            e.preventDefault();
            return;
        }
        
        if (isNaN(amount) || amount <= 0) {
            alert('Please enter a valid amount greater than 0');
            e.preventDefault();
            return;
        }
        
        if (description === '') {
            alert('Please enter a description');
            e.preventDefault();
            return;
        }
    });
    
    document.getElementById('editExpenseForm').addEventListener('submit', function(e) {
        const category = document.getElementById('editCategory');
        const amount = parseFloat(document.getElementById('editAmount').value);
        const description = document.getElementById('editDescription').value.trim();
        
        if (category.value === '') {
            alert('Please select a category');
            e.preventDefault();
            return;
        }
        
        if (isNaN(amount) || amount <= 0) {
            alert('Please enter a valid amount greater than 0');
            e.preventDefault();
            return;
        }
        
        if (description === '') {
            alert('Please enter a description');
            e.preventDefault();
            return;
        }
    });
    
    // Event listeners
    document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('addExpenseBtn').addEventListener('click', openAddModal);
    });
</script>
</body>
</html>