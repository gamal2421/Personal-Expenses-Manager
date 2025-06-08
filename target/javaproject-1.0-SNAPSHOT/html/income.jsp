<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="javawork.personalexp.models.User" %>
<%@ page import="javawork.personalexp.models.Income" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="java.util.ArrayList" %>
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
                String source = request.getParameter("source");
                double amount = Double.parseDouble(request.getParameter("amount"));
                Database.addIncome(userId, amount, source);
            } 
            else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Database.deleteIncome(id);
            }
            else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String source = request.getParameter("source");
                double amount = Double.parseDouble(request.getParameter("amount"));
                Database.updateIncome(id, amount, source);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        }
        
        response.sendRedirect("income.jsp");
        return;
    }

    // Load data
    int userId = Database.getUserIdByEmail(userEmail);
    User user = Database.getUserInfo(userId);
    List<Income> incomes = Database.getIncomes(userId);
    
    // Prepare data for pie chart
    Map<String, Double> incomeBySource = new HashMap<>();
    for (Income income : incomes) {
        String source = income.getSource();
        double amount = income.getAmount();
        incomeBySource.merge(source, amount, Double::sum);
    }

    double totalIncome = incomes.stream().mapToDouble(Income::getAmount).sum();

    // Convert incomeBySource map to JSON arrays for Chart.js
    JSONArray labelsJson = new JSONArray(new ArrayList<>(incomeBySource.keySet()));
    JSONArray dataJson = new JSONArray(new ArrayList<>(incomeBySource.values()));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Personal Expenses Manager - Income</title>
    
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
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link rel="stylesheet" href="../css/income.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
    <li class="nav-item"><a href="ai_suggests.jsp"><i class="icons fas fa-lightbulb"></i> AI Suggests</a></li>
    <li class="nav-item"><a href="logout.jsp"><i class="icons fas fa-sign-out-alt"></i> Logout</a></li>
</ul>
    </div>

    <div class="content-area">
        <div class="top-bar">
            <div class="page-title">
                <h1>Income</h1>
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

        <div class="income-content">
            <div class="filter-add-section">
                <input type="text" class="filter-input" placeholder="Filter income..." id="filterInput">
                <button class="add-btn" id="addIncomeBtn">+</button>
            </div>

            <div class="data-section">
                <div class="chart-container">
                    <h3 class="chart-title">Income Distribution by Source</h3>
                    <canvas id="incomeChart"></canvas>
                </div>
                
                <div class="total-income-summary">
                    <h3>Total Income: $<%= String.format("%.2f", totalIncome) %></h3>
                </div>

                <div class="data-grid">
                    <% if (incomes.isEmpty()) { %>
                        <div class="no-income">No income records found</div>
                    <% } else { %>
                        <% for (Income income : incomes) { %>
                        <div class="income-card">
                            <div class="income-header">
                                <span class="income-source"><%= income.getSource() %></span>
                                <span class="income-amount">$<%= String.format("%.2f", income.getAmount()) %></span>
                                <div class="income-actions">
                                    <button class="action-btn edit-income-btn"
                                        data-id="<%= income.getId() %>"
                                        data-source="<%= income.getSource() %>"
                                        data-amount="<%= income.getAmount() %>"
                                        >
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="action-btn delete-income-btn"
                                        data-id="<%= income.getId() %>"
                                        >
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<div id="income-chart-data"
     data-labels='<%= labelsJson.toString().replace("'", "\\'") %>'
     data-values='<%= dataJson.toString().replace("'", "\\'") %>'>
</div>

<!-- Hidden Form for Add/Edit Income Modal -->
<div id="incomeFormContainer" class="modal-overlay">
    <div class="modal">
        <div class="modal-header">
            <h3 id="incomeModalTitle">Add Income</h3>
            <span class="modal-close" id="closeIncomeForm">&times;</span>
        </div>
        <div class="modal-body">
            <form id="incomeForm" method="POST" action="income.jsp">
                <input type="hidden" name="action" id="incomeFormAction">
                <input type="hidden" name="id" id="incomeId">

                <div class="form-group">
                    <label for="incomeSource" class="form-label">Source:</label>
                    <input type="text" name="source" id="incomeSource" class="form-input" required>
                </div>
                <div class="form-group">
                    <label for="incomeAmount" class="form-label">Amount:</label>
                    <input type="number" name="amount" id="incomeAmount" class="form-input" step="0.01" required min="0">
                </div>
                 <%-- Note: income model in JSP doesn't currently have a date field in the form handling --%>
                 <%-- If a date is needed, this form and the backend handling will need to be updated --%>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Save Income</button>
                    <button type="button" id="cancelIncomeForm" class="btn btn-secondary">Cancel</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Hidden Confirmation Modal for Delete Income -->
<div id="deleteIncomeConfirmModal" class="modal-overlay">
    <div class="modal confirmation-dialog">
        <div class="modal-header">
            <h3 id="confirmIncomeModalTitle">Confirm Deletion</h3>
            <span class="modal-close" id="closeIncomeConfirmModal">&times;</span>
        </div>
        <div class="modal-body">
            <div class="icon-wrapper">
                <i class="fas fa-trash-alt"></i>
            </div>
            <p>Are you sure you want to delete this income record?</p>
        </div>
        <div class="form-actions">
            <button type="button" id="confirmDeleteIncomeBtn" class="btn btn-danger">Yes, Delete</button>
            <button type="button" id="cancelDeleteIncomeBtn" class="btn btn-secondary">Cancel</button>
        </div>
    </div>
</div>

<script src="<%= request.getContextPath() %>/js/income.js"></script>

</body>
</html>