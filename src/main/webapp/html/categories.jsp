<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="javawork.personalexp.models.User" %>
<%@ page import="javawork.personalexp.models.Category" %>
<%@ page import="java.util.List" %>
<%
    // Check if the user is logged in
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int userId = Database.getUserIdByEmail(userEmail);
    User user = Database.getUserInfo(userId);
    List<Category> categories = Database.getCategories(); // Changed to get all categories
    boolean isAdmin = Database.isAdmin(userId);

    String errorMessage = (String) session.getAttribute("errorMessage");
    if (errorMessage != null) {
        session.removeAttribute("errorMessage"); // Clear the message after displaying
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Personal Expenses Manager - Categories</title>
    <meta name="description" content="Manage your expense categories with Personal Expenses Manager. Add, edit, or delete categories for better financial organization.">
    <meta name="keywords" content="categories, expense categories, income categories, financial organization, personal finance, money management">
    <meta name="author" content="PEM Team | ntg school">

    <!-- Open Graph / Facebook -->
    <meta property="og:type" content="website">
    <meta property="og:url" content="<%= request.getRequestURL() %>">
    <meta property="og:title" content="Personal Expenses Manager - Categories">
    <meta property="og:description" content="Manage your expense categories with Personal Expenses Manager. Add, edit, or delete categories for better financial organization.">
    <meta property="og:image" content="<%= request.getContextPath() %>/icons/android-chrome-512x512.png">

    <!-- Twitter -->
    <meta property="twitter:card" content="summary_large_image">
    <meta property="twitter:url" content="<%= request.getRequestURL() %>">
    <meta property="twitter:title" content="Personal Expenses Manager - Categories">
    <meta property="twitter:description" content="Manage your expense categories with Personal Expenses Manager. Add, edit, or delete categories for better financial organization.">
    <meta property="twitter:image" content="<%= request.getContextPath() %>/icons/android-chrome-512x512.png">
    
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
    <link rel="stylesheet" href="../css/categories.css">
    <style>
        .admin-only {
            display: none;
        }
    </style>
    <% if (isAdmin) { %>
    <style>
        .admin-only {
            display: block !important; /* Use !important to ensure it overrides the 'display: none' */
        }
    </style>
    <% } %>
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
            <% if (isAdmin) { %>
                <small>(Admin)</small>
            <% } %>
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
        <!-- Top Bar -->
        <div class="top-bar">
            <div class="page-title">
                <h1>Categories</h1>
                <% if (isAdmin) { %>
                    <small class="admin-badge">Admin Mode</small>
                <% } %>
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

        <!-- Categories Content -->
        <div class="categories-content">
            <div class="filter-add-section">
                <input type="text" class="filter-input" placeholder="Filter categories..." id="filterInput">
                <% if (isAdmin) { %>
                    <button class="add-btn admin-only" id="addCategoryBtn">+ Add Category</button>
                <% } %>
            </div>

            <% if (errorMessage != null) { %>
                <div class="error-message">
                    <i class="fas fa-exclamation-circle"></i> <%= errorMessage %>
                </div>
            <% } %>

            <div class="categories-grid">
                <% for (Category category : categories) { %>
                    <div class="category-card">
                        <div class="category-header">
                            <span class="category-name"><%= category.getName() %></span>
                            <% if (isAdmin) { %>
                                <div class="category-actions admin-only">
                                    <button class="action-btn edit-btn" data-id="<%= category.getId() %>" data-name="<%= category.getName() %>">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="action-btn delete-btn" data-id="<%= category.getId() %>">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</div>

<%-- Profile and Settings Modals (if they exist) --%>
<div id="profileOverlay" class="overlay" style="display: none;"></div>
<div id="profileCard" class="card profile-popup" style="display: none;">
    <div class="avatar"><%= user.getUsername().substring(0, 1).toUpperCase() %></div>
    <div class="profile-info">
        <p><%= user.getUsername() %></p>
        <p><%= user.getEmail() %></p>
    </div>
</div>

<div id="settingsOverlay" class="modal-overlay" style="display: none;"></div>
<div id="settingsCard" class="modal settings-card" style="display: none;">
    <div class="modal-header">
        <h3 class="modal-title">Settings</h3>
        <span class="modal-close">&times;</span>
    </div>
    <div class="modal-body">
        <div class="card-item">
            <span class="material-icons">lock</span>
            <span>Change Password</span>
        </div>
        <div class="card-item">
            <span class="material-icons">notifications</span>
            <span>Notification Preferences</span>
        </div>
        <div class="card-item">
            <span class="material-icons">privacy_tip</span>
            <span>Privacy Settings</span>
        </div>
    </div>
</div>

<!-- Hidden Form for Add/Edit Category Modal -->
<div id="categoryFormContainer" class="modal-overlay">
    <div class="modal">
        <div class="modal-header">
            <h3 id="categoryModalTitle">Add Category</h3>
            <span class="modal-close" id="closeCategoryForm">&times;</span>
        </div>
        <div class="modal-body">
            <form id="categoryForm" method="POST" action="categories.jsp">
                <input type="hidden" name="action" id="categoryFormAction">
                <input type="hidden" name="id" id="categoryId">

                <div class="form-group">
                    <label for="categoryName" class="form-label">Category Name:</label>
                    <input type="text" name="name" id="categoryName" class="form-input" required>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Save Category</button>
                    <button type="button" id="cancelCategoryForm" class="btn btn-secondary">Cancel</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Hidden Confirmation Modal for Delete Category -->
<div id="deleteCategoryConfirmModal" class="modal-overlay">
    <div class="modal confirmation-dialog">
        <div class="modal-header">
            <h3 id="confirmCategoryModalTitle">Confirm Deletion</h3>
            <span class="modal-close" id="closeDeleteConfirmModal">&times;</span>
        </div>
        <div class="modal-body">
            <div class="icon-wrapper">
                <i class="fas fa-trash-alt"></i>
            </div>
            <p>Are you sure you want to delete this category?</p>
        </div>
        <div class="form-actions">
            <button type="button" id="confirmDeleteCategoryBtn" class="btn btn-danger">Yes, Delete</button>
            <button type="button" id="cancelDeleteCategoryBtn" class="btn btn-secondary">Cancel</button>
        </div>
    </div>
</div>

<script src="../js/categories.js"></script>
</body>
</html>