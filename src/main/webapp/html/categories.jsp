<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="javawork.personalexp.models.User" %>
<%@ page import="javawork.personalexp.models.Category" %>
<%@ page import="java.util.List" %>
<%
    // Check if the user is logged in
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");  // Redirect to login if not logged in
        return;  // Ensure no further processing happens
    }

    int userId = Database.getUserIdByEmail(userEmail);
    User user = Database.getUserInfo(userId);
    List<Category> categories = Database.getCategories(userId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Personal Expenses Manager - Categories</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link rel="stylesheet" href="../css/categories.css">
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
            <li class="nav-item"><a href="dashboard.jsp"><i class="icons fas fa-chart-pie"></i> Charts</a></li>
            <li class="nav-item"><a href="#"><i class="icons fas fa-wallet"></i> Financials</a></li>
            <li class="nav-item"><a href="REPORTSandANALYTICS.jsp"><i class="icons fas fa-file-alt"></i> Reports</a></li>
            <li class="nav-item"><a href="#"><i class="icons fas fa-money-bill-wave"></i> Budget</a></li>
            <li class="nav-item"><a href="income.jsp"><i class="icons fas fa-hand-holding-usd"></i> Income</a></li>
            <li class="nav-item"><a href="#"><i class="icons fas fa-tags"></i> Categories</a></li>
        </ul>
    </div>

    <!-- Main Content -->
    <div class="content-area">
        <!-- Top Bar -->
        <div class="top-bar">
            <div class="page-title">
                <h1>Categories</h1>
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

        <!-- Categories Content -->
        <div class="categories-content">
            <div class="filter-add-section">
                <input type="text" class="filter-input" placeholder="Filter categories...">
                <button class="add-btn" id="addCategoryBtn">+</button>
            </div>

            <div class="categories-grid">
                <% for (Category category : categories) { %>
                    <div class="category-card">
                        <div class="category-header">
                            <span class="category-name"><%= category.getName() %></span>
                            <div class="category-actions">
                                <button class="action-btn edit-btn" onclick="editCategory('<%= category.getId() %>', '<%= category.getName() %>')">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="action-btn delete-btn" onclick="deleteCategory('<%= category.getId() %>')">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {


        // Profile click event
        document.getElementById('profile-section').addEventListener('click', function() {
            document.getElementById('profileOverlay').style.display = 'block';
            document.getElementById('profileCard').style.display = 'block';
        });

        // Close popups when clicking overlay
        document.getElementById('profileOverlay').addEventListener('click', function() {
            this.style.display = 'none';
            document.getElementById('profileCard').style.display = 'none';
        });

        // Settings button click
        document.querySelector('.settings-btn').addEventListener('click', function() {
            document.getElementById('settingsOverlay').style.display = 'block';
            document.getElementById('settingsCard').style.display = 'block';
        });



        // Filter categories
        document.querySelector('.filter-input').addEventListener('input', function() {
            const filterValue = this.value.toLowerCase();
            document.querySelectorAll('.category-card').forEach(card => {
                const name = card.querySelector('.category-name').textContent.toLowerCase();
                card.style.display = name.includes(filterValue) ? 'flex' : 'none';
            });
        });
    });

   function deleteCategory(categoryId) {
    // Confirm before deleting
    if (confirm('Are you sure you want to delete this category?')) {
        // Send DELETE request to the CategoryDeleteServlet
        fetch('../deleteCategory', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: 'categoryId=' + categoryId
        })
        .then(response => response.text())
        .then(data => {
            if (data === "Success") {
                alert("Category deleted successfully!");
                location.reload(); // Reload the page to reflect the changes
            } else {
                alert("Failed to delete category.");
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert("Error deleting category.");
        });
    }
}

function addnewcategory() {
    const newCategoryName = prompt('Enter new category name:');
    if (newCategoryName && newCategoryName.trim()) {
        fetch('../addCategory', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: 'categoryName=' + encodeURIComponent(newCategoryName)
        })
        .then(response => response.text())
        .then(data => {
            if (data === "Success") {
                alert("Category added successfully!");
                location.reload(); // Reload the page to reflect the changes
            } else {
                alert("Failed to add category.");
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert("Error adding category.");
        });
    }
}
console.log("ss");
document.getElementById('addCategoryBtn').addEventListener('click', addnewcategory);



function editCategory(categoryId, oldName) {
    const newName = prompt('Edit category name:', oldName);
    if (newName && newName.trim()) {
        fetch('../editCategory', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: 'categoryId=' + categoryId + '&newName=' + encodeURIComponent(newName)
        })
        .then(response => response.text())
        .then(data => {
            if (data === "Success") {
                alert("Category updated successfully!");
                location.reload(); // Reload the page to reflect the changes
            } else {
                alert("Failed to update category.");
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert("Error updating category.");
        });
    }
}

</script>
</body>
</html>
