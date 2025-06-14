<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="javawork.personalexp.models.User" %>
<%@ page import="javawork.personalexp.models.Budget" %>
<%@ page import="javawork.personalexp.models.Category" %>
<%@ page import="java.util.List" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="java.util.ArrayList" %>
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
                double budgetAmount = Double.parseDouble(request.getParameter("budgetAmount"));
                double currentSpending = 0.0;
                
                String spendingParam = request.getParameter("currentSpending");
                if (spendingParam != null && !spendingParam.trim().isEmpty()) {
                    currentSpending = Double.parseDouble(spendingParam);
                }
                
                String budgetType = request.getParameter("budgetType");
                if (budgetType == null || budgetType.isEmpty()) budgetType = "monthly";
                String periodStart = request.getParameter("periodStart");
                if (periodStart == null || periodStart.isEmpty()) periodStart = java.time.LocalDate.now().toString();
                
                boolean success = Database.addBudget(userId, categoryId, budgetAmount, currentSpending, budgetType, periodStart);
                if (!success) {
                    request.setAttribute("error", "Failed to add budget");
                }
            } 
            else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean success = Database.deleteBudget(id);
                if (!success) {
                    request.setAttribute("error", "Failed to delete budget");
                }
            }
            else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                int categoryId = Integer.parseInt(request.getParameter("categoryId"));
                double budgetAmount = Double.parseDouble(request.getParameter("budgetAmount"));
                double currentSpending = Double.parseDouble(request.getParameter("currentSpending"));
                String budgetType = request.getParameter("budgetType");
                if (budgetType == null || budgetType.isEmpty()) budgetType = "monthly";
                String periodStart = request.getParameter("periodStart");
                if (periodStart == null || periodStart.isEmpty()) periodStart = java.time.LocalDate.now().toString();
                
                boolean success = Database.updateBudget(id, categoryId, budgetAmount, currentSpending, budgetType, periodStart);
                if (!success) {
                    request.setAttribute("error", "Failed to update budget");
                }
            }
        } catch (Exception e) {
            String msg = e.getMessage();
            if (msg != null && msg.contains("monthly budget for this category and period already exists")) {
                request.setAttribute("error", "A <b>monthly</b> budget for this category and month already exists. Please edit the existing budget or choose a different month.");
            } else if (msg != null && msg.contains("yearly budget for this category and period already exists")) {
                request.setAttribute("error", "A <b>yearly</b> budget for this category and year already exists. Please edit the existing budget or choose a different year.");
            } else if (msg != null && msg.contains("midyear budget for this category and period already exists")) {
                request.setAttribute("error", "A <b>mid-year</b> budget for this category and half-year already exists. Please edit the existing budget or choose a different half-year.");
            } else if (msg != null && msg.contains("already exists")) {
                request.setAttribute("error", "A budget for this period already exists! Please choose a different period or edit the existing budget.");
            } else {
                request.setAttribute("error", "Error: " + msg);
            }
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

    // Convert categories to JSON for JavaScript
    JSONArray categoriesJson = new JSONArray();
    for (Category category : categories) {
        categoriesJson.put(category.toJson()); // Assuming Category model has a toJson() method
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Personal Expenses Manager - Budget</title>
    <meta name="description" content="Create and manage your budgets with Personal Expenses Manager. Set spending limits, track progress, and control your finances.">
    <meta name="keywords" content="budget, budgeting, spending limits, financial planning, personal finance, money management, expense control">
    <meta name="author" content="PEM Team | ntg school">

    <!-- Open Graph / Facebook -->
    <meta property="og:type" content="website">
    <meta property="og:url" content="<%= request.getRequestURL() %>">
    <meta property="og:title" content="Personal Expenses Manager - Budget">
    <meta property="og:description" content="Create and manage your budgets with Personal Expenses Manager. Set spending limits, track progress, and control your finances.">
    <meta property="og:image" content="<%= request.getContextPath() %>/icons/android-chrome-512x512.png">

    <!-- Twitter -->
    <meta property="twitter:card" content="summary_large_image">
    <meta property="twitter:url" content="<%= request.getRequestURL() %>">
    <meta property="twitter:title" content="Personal Expenses Manager - Budget">
    <meta property="twitter:description" content="Create and manage your budgets with Personal Expenses Manager. Set spending limits, track progress, and control your finances.">
    <meta property="twitter:image" content="<%= request.getContextPath() %>/icons/android-chrome-512x512.png">

    <!-- Content Security Policy -->
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

        /* Budget Content */
        .budget-content {
          background: white;
          border-radius: 16px;
          padding: 25px;
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
          flex-grow: 1;
        }

        /* Budget Summary */
        .budget-summary {
          display: flex;
          justify-content: space-between;
          margin-bottom: 30px;
          background: #f9f9f9;
          border-radius: 12px;
          padding: 20px;
        }

        .summary-item {
          text-align: center;
          flex: 1;
        }

        .summary-value {
          font-size: 24px;
          font-weight: bold;
          color: #3ab19b;
          margin-bottom: 5px;
        }

        .summary-label {
          color: #666;
          font-size: 14px;
        }

        /* Budget List */
        .budget-list {
          margin-top: 20px;
        }

        .budget-item {
          background: #f9f9f9;
          border-radius: 12px;
          padding: 15px 20px;
          margin-bottom: 15px;
          transition: all 0.3s ease;
        }

        .budget-item:hover {
          transform: translateY(-2px);
          box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        .budget-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 10px;
        }

        .budget-category {
          font-weight: 600;
          font-size: 16px;
        }

        .budget-amount {
          font-weight: 600;
          color: #3ab19b;
        }

        .budget-actions {
          display: flex;
          gap: 10px;
        }

        .budget-action-btn {
          background: none;
          border: none;
          cursor: pointer;
          color: #666;
          transition: all 0.2s ease;
        }

        .budget-action-btn:hover {
          color: #3ab19b;
          transform: scale(1.1);
        }

        .progress-container {
          height: 8px;
          background: #e0e0e0;
          border-radius: 4px;
          margin: 10px 0;
          overflow: hidden;
        }

        .progress-bar {
          height: 100%;
          background: #3ab19b;
          border-radius: 4px;
          transition: width 0.5s ease;
        }

        .danger {
          background: #e74c3c;
        }

        .warning {
          background: #f39c12;
        }

        .budget-details {
          display: flex;
          justify-content: space-between;
          font-size: 14px;
          color: #666;
        }

        /* Add Budget Button */
        .add-budget-btn {
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 8px;
          background: #1abc9c;
          color: white;
          border: none;
          border-radius: 30px;
          padding: 12px 24px;
          margin: 20px auto 0;
          cursor: pointer;
          transition: all 0.3s ease;
        }

        .add-budget-btn:hover {
          background: #16a085;
          transform: translateY(-2px);
          box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
        }

        /* Overlay and Popups */
        .overlay {
          position: fixed;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background: rgba(0,0,0,0.3);
          display: none;
          z-index: 100;
        }

        .card {
          background: white;
          border-radius: 16px;
          box-shadow: 0 6px 20px rgba(0,0,0,0.1);
          padding: 20px;
          width: 320px;
          position: fixed;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          z-index: 101;
          display: none;
        }

        .profile-popup {
          text-align: center;
        }

        .avatar {
          width: 80px;
          height: 80px;
          border-radius: 50%;
          background: #3ab19b;
          margin: 0 auto 15px;
          display: flex;
          align-items: center;
          justify-content: center;
          color: white;
          font-size: 30px;
        }

        .info-field {
          margin-bottom: 15px;
          text-align: left;
        }

        .info-field label {
          display: block;
          font-size: 12px;
          color: #666;
          margin-bottom: 5px;
        }

        .info-value {
          margin: 0;
          padding: 8px 12px;
          background: #f5f5f5;
          border-radius: 8px;
        }

        /* Enhanced Modal Styles */
        .modal-overlay {
          position: fixed;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background: rgba(0, 0, 0, 0.5);
          display: flex;
          align-items: center;
          justify-content: center;
          z-index: 1000;
          visibility: hidden;
          opacity: 0;
          transition: visibility 0.3s, opacity 0.3s ease-in-out;
        }

        .modal-overlay.active {
          visibility: visible;
          opacity: 1;
        }

        .modal {
          background-color: #fff;
          padding: 20px 30px;
          border-radius: 16px;
          box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
          width: 90%;
          max-width: 500px;
          transform: translateY(-50px);
          transition: transform 0.3s ease-in-out;
          box-sizing: border-box;
          position: relative;
        }

        .modal-overlay.active .modal {
          transform: translateY(0);
        }

        .modal-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          border-bottom: 1px solid #eee;
          padding-bottom: 15px;
          margin-bottom: 20px;
        }

        .modal-title {
          margin: 0;
          font-size: 20px;
          color: #333;
        }

        .modal-close {
          background: none;
          border: none;
          font-size: 24px;
          line-height: 1;
          cursor: pointer;
          color: #aaa;
          position: absolute;
          top: 15px;
          right: 15px;
          padding: 5px;
        }

        .modal-close:hover {
          color: #777;
        }

        .form-group {
          margin-bottom: 20px;
        }

        .form-label {
          display: block;
          margin-bottom: 8px;
          font-weight: 500;
          color: #555;
        }

        .form-input {
          width: 100%;
          padding: 12px;
          border: 1px solid #ccc;
          border-radius: 8px;
          font-size: 16px;
          box-sizing: border-box;
          transition: border-color 0.2s ease;
        }

        .form-input:focus {
          outline: none;
          border-color: #3ab19b;
          box-shadow: 0 0 5px rgba(58, 177, 155, 0.3);
        }

        select.form-input {
          padding: 10px;
          height: calc(2.5em + 2px);
          appearance: none;
          background-image: url('data:image/svg+xml;utf8,<svg fill="#333" viewBox="0 0 24 24" width="24" height="24" xmlns="http://www.w3.org/2000/svg"><path d="M7 10l5 5 5-5z"/></svg>');
          background-repeat: no-repeat;
          background-position: right 10px center;
          background-size: 12px;
        }

        .form-actions {
          display: flex;
          justify-content: flex-end;
          gap: 10px;
          padding-top: 15px;
          border-top: 1px solid #eee;
        }

        .btn {
          padding: 10px 20px;
          border: none;
          border-radius: 25px;
          cursor: pointer;
          font-size: 16px;
          transition: background-color 0.2s ease, transform 0.1s ease;
        }

        .btn-secondary {
          background-color: #e0e0e0;
          color: #333;
        }

        .btn-secondary:hover {
          background-color: #d5d5d5;
        }

        .btn-primary {
          background-color: #1abc9c;
          color: white;
        }

        .btn-primary:hover {
          background-color: #16a085;
          transform: translateY(-1px);
        }

        .btn-danger {
          background-color: #e74c3c;
          color: white;
        }

        .btn-danger:hover {
          background-color: #c0392b;
          transform: translateY(-1px);
        }

        /* Confirmation Dialog Specific Styles */
        .confirmation-dialog .modal-header {
          justify-content: center;
          border-bottom: none;
        }

        .confirmation-dialog .modal-body {
          text-align: center;
          margin-bottom: 20px;
        }

        .confirmation-dialog .modal-body p {
          font-size: 16px;
          color: #555;
          margin-bottom: 20px;
        }

        .confirmation-dialog .icon-wrapper {
          color: #e74c3c;
          font-size: 48px;
          margin-bottom: 20px;
        }

        .confirmation-dialog .icon-wrapper i {
          border: 3px solid #e74c3c;
          border-radius: 50%;
          padding: 15px;
        }

        /* Profile Card Styles */
        .profile-popup .avatar {
          width: 100px;
          height: 100px;
          font-size: 40px;
          margin-bottom: 20px;
          background: linear-gradient(135deg, #1abc9c, #16a085);
        }

        .profile-popup .profile-info {
          text-align: center;
          margin-bottom: 25px;
        }

        .profile-popup .profile-info p:first-child {
          font-size: 20px;
          font-weight: 600;
          margin-bottom: 5px;
          color: #2c3e50;
        }

        .profile-popup .profile-info p:last-child {
          color: #7f8c8d;
          font-size: 15px;
        }

        /* Settings Card Styles */
        .settings-card .card-item {
          padding: 15px;
          border-radius: 10px;
          cursor: pointer;
          display: flex;
          align-items: center;
          gap: 15px;
          transition: all 0.2s ease;
          margin-bottom: 10px;
        }

        .settings-card .card-item:last-child {
          margin-bottom: 0;
        }

        .settings-card .card-item:hover {
          background: #f5f5f5;
        }

        .settings-card .card-item .material-icons {
          color: #7f8c8d;
          font-size: 22px;
        }
        .btn {
          padding: 10px 20px;
          border-radius: 8px;
          font-size: 14px;
          cursor: pointer;
          transition: all 0.3s ease;
        }

        .btn-secondary {
          background: #f5f5f5;
          color: #333;
          border: none;
        }

        .btn-secondary:hover {
          background: #e0e0e0;
        }

        .btn-primary {
          background: #1abc9c;
          color: white;
          border: none;
        }

        .btn-primary:hover {
          background: #16a085;
        }

        /* Alert Notification */
        .alert {
          position: fixed;
          top: 20px;
          right: 20px;
          padding: 15px 20px;
          border-radius: 8px;
          background: #2ecc71;
          color: white;
          box-shadow: 0 4px 12px rgba(0,0,0,0.15);
          transform: translateX(150%);
          transition: transform 0.3s ease;
          z-index: 10000;
          display: flex;
          align-items: center;
          gap: 10px;
        }

        .alert.show {
          transform: translateX(0);
        }

        .alert.error {
          background: #e74c3c;
        }

        .alert.warning {
          background: #f39c12;
        }

        .alert i {
          font-size: 18px;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
          .main-page {
            flex-direction: column;
          }

          #sidebar {
            width: 100%;
            margin-bottom: 20px;
          }

          .content-area {
            margin-left: 0;
          }

          .budget-summary {
            flex-direction: column;
            gap: 20px;
          }

          .summary-item {
            text-align: left;
          }
        }

        /* Custom styles for our JSP content */
        .admin-badge {
          background-color: #27ae60;
          color: white;
          padding: 3px 10px;
          border-radius: 12px;
          font-size: 12px;
          margin-left: 10px;
        }

        .error-message {
          background-color: #fdecea;
          color: #e74c3c;
          padding: 10px 15px;
          border-radius: 4px;
          margin-bottom: 20px;
          display: flex;
          align-items: center;
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
    
    <!-- Main Content -->
    <div class="content-area">
        <div class="top-bar">
            <div class="page-title">
                <h1>Budget Management</h1>
            </div>
            <div class="top-actions">
                <button class="add-budget-btn" id="addBudgetBtn">
                    <i class="fas fa-plus"></i> Add Budget
                </button>
            </div>
        </div>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="error-message">
                <i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("error") %>
            </div>
        <% } %>
        
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
            
            <div class="budget-list">
                <% if (budgets.isEmpty()) { %>
                    <div style="text-align: center; padding: 40px; color: #7f8c8d;">
                        <i class="fas fa-money-bill-wave" style="font-size: 40px; margin-bottom: 10px;"></i>
                        <p>No budgets found. Add your first budget to get started.</p>
                    </div>
                <% } else { %>
                    <% for (Budget budget : budgets) { 
                        double percentage = (budget.getCurrentSpending() / budget.getBudgetAmount()) * 100;
                        double budgetRemaining = budget.getBudgetAmount() - budget.getCurrentSpending();
                    %>
                    <div class="budget-item">
                        <div class="budget-header">
                            <div class="budget-category"><%= budget.getCategory() %></div>
                            <div class="budget-amount">
                                $<%= String.format("%.2f", budget.getCurrentSpending()) %> / $<%= String.format("%.2f", budget.getBudgetAmount()) %>
                            </div>
                            <div class="budget-actions">
                                <button class="budget-action-btn edit-budget-btn"
                                    data-id="<%= budget.getId() %>"
                                    data-category-id="<%= budget.getCategoryId() %>"
                                    data-budget-amount="<%= budget.getBudgetAmount() %>"
                                    data-current-spending="<%= budget.getCurrentSpending() %>"
                                    data-budget-type="<%= budget.getBudgetType() %>"
                                    data-period-start="<%= budget.getPeriodStart() %>"
                                    >
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="budget-action-btn delete-budget-btn"
                                    data-id="<%= budget.getId() %>"
                                    >
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </div>
                        <div class="budget-meta" style="font-size: 13px; color: #888; margin-bottom: 6px;">
                            <span>Type: <%= budget.getBudgetType() != null ? budget.getBudgetType().substring(0,1).toUpperCase() + budget.getBudgetType().substring(1) : "N/A" %></span>
                            &nbsp;|&nbsp;
                            <span>Period Start: <%= budget.getPeriodStart() != null ? budget.getPeriodStart() : "N/A" %></span>
                        </div>
                        <div class="progress-container">
                            <div class="progress-bar <%= percentage > 90 ? "danger" : percentage > 75 ? "warning" : "" %>" 
                                 style="width: <%= Math.min(percentage, 100) %>%"></div>
                        </div>
                        <div class="budget-details">
                            <span>$<%= String.format("%.2f", budgetRemaining) %> remaining</span>
                            <span><%= String.format("%.1f", percentage) %>% spent</span>
                        </div>
                    </div>
                    <% } %>
                <% } %>
            </div>
        </div>
    </div>
</div>

<!-- Hidden Form for Add/Edit Budget Modal -->
<div id="budgetFormContainer" class="modal-overlay">
    <div class="modal">
        <div class="modal-header">
            <h3 id="budgetModalTitle">Add Budget</h3>
            <span class="modal-close" id="closeBudgetForm">&times;</span>
        </div>
        <div class="modal-body">
            <form id="budgetForm" method="POST" action="budget.jsp">
                <input type="hidden" name="action" id="budgetFormAction">
                <input type="hidden" name="id" id="budgetBudgetId">

                <div class="form-group">
                    <label for="budgetCategory" class="form-label">Category:</label>
                    <%-- This will be populated dynamically by JavaScript --%>
                    <select name="categoryId" id="budgetCategory" class="form-input" required>
                         <option value="">Select a category</option>
                         <% for (Category category : categories) { %>
                             <option value="<%= category.getId() %>"><%= category.getName() %></option>
                         <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="budgetAmount" class="form-label">Budget Amount:</label>
                    <input type="number" name="budgetAmount" id="budgetAmount" class="form-input" step="0.01" required min="0">
                </div>
                 <div class="form-group">
                    <label for="budgetCurrentSpending" class="form-label">Current Spending:</label>
                    <input type="number" name="currentSpending" id="budgetCurrentSpending" class="form-input" step="0.01" required min="0">
                </div>
                <div class="form-group">
                    <label for="budgetType" class="form-label">Budget Type:</label>
                    <select name="budgetType" id="budgetType" class="form-input" required>
                        <option value="monthly">Monthly</option>
                        <option value="yearly">Yearly</option>
                        <option value="midyear">Mid-Year (6 months)</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="periodStart" class="form-label">Period Start:</label>
                    <input type="date" name="periodStart" id="periodStart" class="form-input" required>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Save Budget</button>
                    <button type="button" id="cancelBudgetForm" class="btn btn-secondary">Cancel</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Hidden Confirmation Modal for Delete Budget -->
<div id="deleteBudgetConfirmModal" class="modal-overlay">
    <div class="modal confirmation-dialog">
        <div class="modal-header">
            <h3 id="confirmBudgetModalTitle">Confirm Deletion</h3>
            <span class="modal-close" id="closeBudgetConfirmModal">&times;</span>
        </div>
        <div class="modal-body">
            <div class="icon-wrapper">
                <i class="fas fa-trash-alt"></i>
            </div>
            <p>Are you sure you want to delete this budget?</p>
        </div>
        <div class="form-actions">
            <button type="button" id="confirmDeleteBudgetBtn" class="btn btn-danger">Yes, Delete</button>
            <button type="button" id="cancelDeleteBudgetBtn" class="btn btn-secondary">Cancel</button>
        </div>
    </div>
</div>

<script src="<%= request.getContextPath() %>/js/budget.js"></script>
</body>
</html>