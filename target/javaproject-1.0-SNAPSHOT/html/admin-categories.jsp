<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="javawork.personalexp.models.Category" %>
<%@ page import="java.util.List" %>
<%
    // Check admin status
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Handle form submissions
    if ("POST".equals(request.getMethod())) {
        String action = request.getParameter("action");
        
        try {
            if ("add".equals(action)) {
                String name = request.getParameter("name");
                Database.addCategory(name);
            } 
            else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Database.deleteCategory(id);
            }
            else if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String newName = request.getParameter("newName");
                Database.updateCategoryName(id, newName);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        }
        
        response.sendRedirect("admin-categories.jsp");
        return;
    }

    List<Category> categories = Database.getCategories();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Categories</title>
    
<link rel="icon" type="image/png" href="/icons/icon.png">
<link rel="apple-touch-icon" sizes="180x180" href="/icons/icon.png">
<link rel="icon" type="image/png" sizes="32x32" href="/icons/icon.png">
<link rel="icon" type="image/png" sizes="16x16" href="/icons/icon.png">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="../css/categoryadmin.css">

</head>
<body>
    <div class="main-page">
        <!-- Sidebar -->
        <div id="sidebar">
            <div id="profile-section">
                <div class="profile-image">
                    <%= session.getAttribute("userName").toString().charAt(0) %>
                </div>
                <h3><%= session.getAttribute("userName") %></h3>
                <p>Administrator</p>
            </div>
            
            <ul class="nav-menu">
                <li class="nav-item">
                    <a href="admin-dashboard.jsp">
                        <i class="fas fa-tachometer-alt icons"></i>
                        Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a href="admin-categories.jsp" style="background-color: #3ab19b; color: white;">
                        <i class="fas fa-tags icons"></i>
                        Manage Categories
                    </a>
                </li>


            </ul>
            
            <div style="margin-top: auto; padding: 15px;">
                <a href="login.jsp" style="color: #3ab19b; text-decoration: none; display: flex; align-items: center; gap: 8px; justify-content: center;">
                    <i class="fas fa-sign-out-alt"></i> Logout
                </a>
            </div>
        </div>
        
        <!-- Main Content -->
        <div class="content-area">
            <!-- Top Bar -->
            <div class="top-bar">
                <div class="page-title">
                    <h1>Manage Categories</h1>
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
            
            <!-- Dashboard Content -->
            <div class="dashboard-content">
                <!-- Error Message -->
                <% if (request.getAttribute("error") != null) { %>
                    <div class="error-message" style="display: block;">
                        <i class="fas fa-exclamation-circle"></i> <%= request.getAttribute("error") %>
                    </div>
                <% } %>
                
                <!-- Add Category Form -->
                <div class="form-card">
                    <h3><i class="fas fa-plus-circle"></i> Add New Category</h3>
                    <form method="post">
                        <input type="hidden" name="action" value="add">
                        <div class="form-group">
                            <input type="text" class="form-control" name="name" placeholder="Enter category name" required>
                        </div>
                        <button type="submit" class="btn"><i class="fas fa-plus"></i> Add Category</button>
                    </form>
                </div>
                
                <!-- Categories Table -->
                <div class="table-card">
                    <h3><i class="fas fa-list"></i> Existing Categories</h3>
                    <table class="category-table">
                        <thead>
                            <tr>
                                <th>Category Name</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Category category : categories) { %>
                            <tr>
                                <td><%= category.getName() %></td>
                                <td class="action-buttons">
                                    <form method="post" style="display:inline;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= category.getId() %>">
                                        <button type="submit" class="btn btn-danger"><i class="fas fa-trash"></i> Delete</button>
                                    </form>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</body>
</html>