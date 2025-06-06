<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    String errorMessage = null; // Initialize error message
    if ("POST".equals(request.getMethod())) {
        String action = request.getParameter("action");
        int userId = Database.getUserIdByEmail(userEmail);
        
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String targetAmountStr = request.getParameter("targetAmount");
        String currentAmountStr = request.getParameter("currentAmount");
        String targetDateStr = request.getParameter("targetDate");
        String idParam = request.getParameter("id");
        
        try {
            if ("add".equals(action) || "update".equals(action)) {
                // Server-side Validation for Add/Update
                if (title == null || title.trim().isEmpty()) {
                    errorMessage = "Goal title is mandatory.";
                } else if (targetAmountStr == null || targetAmountStr.trim().isEmpty()) {
                    errorMessage = "Target amount is mandatory.";
                } else if (targetDateStr == null || targetDateStr.trim().isEmpty()) {
                    errorMessage = "Target date is mandatory.";
                } else {
                    try {
                        double targetAmount = Double.parseDouble(targetAmountStr);
                        if (targetAmount <= 0) {
                            errorMessage = "Target amount must be positive.";
                        }

                        double currentAmount = 0; // Default to 0 if not provided or empty
                        if (currentAmountStr != null && !currentAmountStr.trim().isEmpty()) {
                            currentAmount = Double.parseDouble(currentAmountStr);
                            if (currentAmount < 0) {
                                errorMessage = "Current saved amount cannot be negative.";
                            }
                        }

                        // Basic date format check (YYYY-MM-DD) and valid date check
                        Date targetDate = null;
                        if (targetDateStr != null && !targetDateStr.trim().isEmpty()) {
                            if (!targetDateStr.matches("\\d{4}-\\d{2}-\\d{2}")) {
                                errorMessage = "Target date must be in YYYY-MM-DD format.";
                            } else {
                                try {
                                    targetDate = Date.valueOf(targetDateStr);
                                } catch (IllegalArgumentException e) {
                                    errorMessage = "Invalid target date value.";
                                }
                            }
                        }

                        // If no validation errors, proceed with database operation
                        if (errorMessage == null) {
                            if ("add".equals(action)) {
                                Database.addSavingGoal(userId, title.trim(), description != null ? description.trim() : null, targetAmount, targetDate, currentAmount);
                            } else { // update
                                if (idParam != null && !idParam.isEmpty()) {
                                    try {
                                        int id = Integer.parseInt(idParam);
                                        Database.updateSavingGoal(id, title.trim(), description != null ? description.trim() : null, targetAmount, targetDate, currentAmount);
                                    } catch (NumberFormatException e) {
                                        errorMessage = "Invalid goal ID for update.";
                                    }
                                } else {
                                    errorMessage = "Goal ID not provided for update.";
                                }
                            }
                        }

                    } catch (NumberFormatException e) {
                        errorMessage = "Invalid number format for amount fields.";
                    }
                }
            } 
            else if ("delete".equals(action)) {
                if (idParam != null && !idParam.isEmpty()) {
                    try {
                        int id = Integer.parseInt(idParam);
                Database.deleteSavingGoal(id);
                    } catch (NumberFormatException e) {
                        errorMessage = "Invalid goal ID for deletion.";
                    }
                } else {
                    errorMessage = "Goal ID not provided for deletion.";
                }
            }
        } catch (Exception e) {
            // Catch any other unexpected errors during database operations
            errorMessage = "An unexpected error occurred: " + e.getMessage();
            e.printStackTrace(); // Log the error for debugging
        }
        
        // If there are no errors, redirect. Otherwise, set error attribute and continue to render.
        if (errorMessage == null) {
        response.sendRedirect("Financials goals.jsp");
        return;
        } else {
            request.setAttribute("error", errorMessage);
            // Re-populate form fields for display if it was an add/update attempt
            if ("add".equals(action) || "update".equals(action)) {
                request.setAttribute("submittedTitle", title);
                request.setAttribute("submittedDescription", description);
                request.setAttribute("submittedTargetAmount", targetAmountStr);
                request.setAttribute("submittedCurrentAmount", currentAmountStr);
                request.setAttribute("submittedTargetDate", targetDateStr);
                request.setAttribute("submittedId", idParam);
                request.setAttribute("submittedAction", action);
            }
        }
    }

    // Load data (This part executes for GET requests or POST requests with errors)
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
    
    <!-- Content Security Policy -->
    <meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://cdnjs.cloudflare.com; style-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com; img-src 'self' data: https://e7.pngegg.com;">
    
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
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link rel="stylesheet" href="../css/Financials goals.css">
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
                <h1>Financial Goals</h1>
            </div>
            <!-- Search Bar -->
            <div class="search-bar">
                <input type="text" id="goalSearchInput" placeholder="Search goals...">
                <i class="fas fa-search search-icon"></i>
            </div>
            <div class="top-actions">
                <%--                <div class="notification-btn">--%>
                    <%--                    <i class="fas fa-bell"></i>--%>
                    <%--                </div>--%>
                    <%--                <div class="settings-btn">--%>
                    <%--                    <i class="fas fa-cog"></i>--%>
                    <%--                </div>--%>
                <!-- Add Goal Button (Moved to top actions) -->
                <button class="add-budget-btn" id="addGoalBtn">
                    <i class="fas fa-plus"></i>
                    Add Goal
                </button>
            </div>
        </div>

        <%-- Error Message Display --%>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i>
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

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
                                    data-id="<%= goal.getId() %>"
                                    data-title="<%= goal.getTitle() %>"
                                    data-description="<%= goal.getDescription() != null ? goal.getDescription() : "" %>"
                                    data-targetamount="<%= goal.getTargetAmount() %>"
                                    data-currentamount="<%= goal.getCurrentAmount() %>"
                                    data-targetdate="<%= goal.getTargetDate() %>"
                                    >
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="budget-action-btn delete-btn" 
                                    data-id="<%= goal.getId() %>">
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

            <%-- Remove the button from its original position --%>
<%--
            <button class="add-budget-btn" id="addGoalBtn">
                <i class="fas fa-plus"></i>
                Add Goal
            </button>
--%>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Get form and form elements
        const goalFormContainer = document.getElementById('goalFormContainer');
        const goalForm = document.getElementById('goalForm');
        const formAction = document.getElementById('formAction');
        const goalIdInput = document.getElementById('goalId');
        const goalTitleInput = document.getElementById('goalTitle');
        const goalDescriptionInput = document.getElementById('goalDescription');
        const goalTargetAmountInput = document.getElementById('goalTargetAmount');
        const goalCurrentAmountInput = document.getElementById('goalCurrentAmount');
        const goalTargetDateInput = document.getElementById('goalTargetDate');
        const modalTitle = document.getElementById('modalTitle');
        const closeGoalFormBtn = document.getElementById('closeGoalForm');
        const cancelGoalFormBtn = document.getElementById('cancelGoalForm');

        // Get delete confirmation modal elements
        const deleteConfirmModal = document.getElementById('deleteConfirmModal');
        const confirmDeleteBtn = document.getElementById('confirmDeleteBtn');
        const cancelDeleteBtn = document.getElementById('cancelDeleteBtn');
        const closeConfirmModalBtn = document.getElementById('closeConfirmModal');
        let goalIdToDelete = null; // Variable to store the ID of the goal to be deleted

        // Get search input element
        const goalSearchInput = document.getElementById('goalSearchInput');

        // Function to show the modal form
        function showGoalForm(action, goal) {
            console.log('Showing goal form for action:', action, 'goal:', goal);
            goalForm.reset(); // Reset form fields
            formAction.value = action;
            goalIdInput.value = goal ? goal.id : '';
            modalTitle.textContent = action === 'add' ? 'Add Financial Goal' : 'Edit Financial Goal';

            if (goal) {
                // Populate form for editing
                goalTitleInput.value = goal.title;
                goalDescriptionInput.value = goal.description;
                goalTargetAmountInput.value = goal.targetAmount;
                goalCurrentAmountInput.value = goal.currentAmount;
                goalTargetDateInput.value = goal.targetDate; // YYYY-MM-DD format expected by input type='date'
            }

            // Use class to show for CSS transitions
            goalFormContainer.classList.add('active');
             console.log('Added active class to goalFormContainer');
        }

        // Function to hide the modal form
        function hideGoalForm() {
             console.log('Hiding goal form');
            // Use class to hide for CSS transitions
            goalFormContainer.classList.remove('active');
             console.log('Removed active class from goalFormContainer');
        }

        // Add new goal - show form
        document.getElementById('addGoalBtn').addEventListener('click', function() {
            console.log('Add Goal button clicked');
            showGoalForm('add');
        });

        // Add event listeners to edit buttons
        document.querySelectorAll('.edit-btn').forEach(button => {
            button.addEventListener('click', function() {
                console.log('Edit button clicked', button.getAttribute('data-id'));
                const goal = {
                    id: button.getAttribute('data-id'),
                    title: button.getAttribute('data-title'),
                    description: button.getAttribute('data-description'),
                    targetAmount: button.getAttribute('data-targetamount'),
                    currentAmount: button.getAttribute('data-currentamount'),
                    targetDate: button.getAttribute('data-targetdate')
                };
                showGoalForm('update', goal);
            });
        });

        // Add event listener for cancel button
        cancelGoalFormBtn.addEventListener('click', hideGoalForm);

        // Add event listener for close button (X)
        closeGoalFormBtn.addEventListener('click', hideGoalForm);

        // Close modal if user clicks outside of it
        window.addEventListener('click', function(event) {
            if (event.target === goalFormContainer) {
                console.log('Clicked outside modal, hiding form');
                hideGoalForm();
            }
        });

        // Add event listeners to delete buttons
        document.querySelectorAll('.delete-btn').forEach(button => {
            // Remove any existing click listeners to prevent multiple confirmations
            const oldClickListener = button._clickHandler; // Store the handler if needed later, or just remove
            if (oldClickListener) {
                button.removeEventListener('click', oldClickListener);
            }

            // Add the new click listener
            const newClickListener = function() {
                console.log('Delete button clicked', this.getAttribute('data-id'));
                goalIdToDelete = this.getAttribute('data-id'); // Store the ID
                
                console.log('Attempting to show delete confirm modal...');
                console.log('deleteConfirmModal element:', deleteConfirmModal);
                console.log('deleteConfirmModal classList before adding active:', deleteConfirmModal.classList);
                
                deleteConfirmModal.classList.add('active'); // Show the confirmation modal
                
                console.log('deleteConfirmModal classList after adding active:', deleteConfirmModal.classList);
            };
            button.addEventListener('click', newClickListener);
            button._clickHandler = newClickListener; // Store the new handler
        });

        // Add event listeners for the delete confirmation modal
        confirmDeleteBtn.addEventListener('click', function() {
            console.log('Confirm delete button clicked for goal ID:', goalIdToDelete);
            if (goalIdToDelete) {
                // Create and submit the delete form
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
                idInput.value = goalIdToDelete;
                form.appendChild(idInput);
                
                document.body.appendChild(form);
                form.submit();
            }
            deleteConfirmModal.classList.remove('active'); // Hide the modal
        });

        cancelDeleteBtn.addEventListener('click', function() {
            console.log('Cancel delete button clicked');
            goalIdToDelete = null; // Clear the stored ID
            deleteConfirmModal.classList.remove('active'); // Hide the modal
        });

        closeConfirmModalBtn.addEventListener('click', function() {
             console.log('Close delete modal button clicked');
             goalIdToDelete = null; // Clear the stored ID
             deleteConfirmModal.classList.remove('active'); // Hide the modal
        });

        // Close delete modal if user clicks outside of it
        window.addEventListener('click', function(event) {
            if (event.target === deleteConfirmModal) {
                console.log('Clicked outside delete modal, hiding');
                goalIdToDelete = null; // Clear the stored ID
                deleteConfirmModal.classList.remove('active'); // Hide the modal
            }
        });

        // Add event listener for search input
        goalSearchInput.addEventListener('input', function() {
            const searchTerm = this.value.toLowerCase();
            const goalItems = document.querySelectorAll('.budget-item'); // Assuming .budget-item is the class for each goal display item

            goalItems.forEach(item => {
                const title = item.querySelector('.budget-category').textContent.toLowerCase(); // Assuming .budget-category is the title class
                const descriptionElement = item.querySelector('.goal-description'); // Assuming .goal-description is the description class
                const description = descriptionElement ? descriptionElement.textContent.toLowerCase() : '';

                if (title.includes(searchTerm) || description.includes(searchTerm)) {
                    item.style.display = ''; // Show the item
                } else {
                    item.style.display = 'none'; // Hide the item
                }
            });
        });

    });

    // deleteGoal function is now redundant, will be removed in a future step

</script>

<!-- Hidden Form for Add/Edit Goal -->
<div id="goalFormContainer" class="modal-overlay">
    <div class="modal">
        <div class="modal-header">
            <h3 id="modalTitle">Add Financial Goal</h3>
            <span class="modal-close" id="closeGoalForm">&times;</span>
        </div>
        <div class="modal-body">
            <form id="goalForm" method="POST" action="Financials goals.jsp">
                <input type="hidden" name="action" id="formAction">
                <input type="hidden" name="id" id="goalId">

                <div class="form-group">
                    <label for="goalTitle" class="form-label">Title:</label>
                    <input type="text" name="title" id="goalTitle" class="form-input" required>
                </div>
                <div class="form-group">
                    <label for="goalDescription" class="form-label">Description:</label>
                    <textarea name="description" id="goalDescription" class="form-input"></textarea>
                </div>
                <div class="form-group">
                    <label for="goalTargetAmount" class="form-label">Target Amount:</label>
                    <input type="number" name="targetAmount" id="goalTargetAmount" class="form-input" step="0.01" required min="0">
                </div>
                <div class="form-group">
                    <label for="goalCurrentAmount" class="form-label">Current Saved Amount:</label>
                    <input type="number" name="currentAmount" id="goalCurrentAmount" class="form-input" step="0.01" required min="0">
                </div>
                <div class="form-group">
                    <label for="goalTargetDate" class="form-label">Target Date:</label>
                    <input type="date" name="targetDate" id="goalTargetDate" class="form-input" required>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary">Save Goal</button>
                    <button type="button" id="cancelGoalForm" class="btn btn-secondary">Cancel</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Hidden Confirmation Modal for Delete -->
<div id="deleteConfirmModal" class="modal-overlay">
    <div class="modal confirmation-dialog">
        <div class="modal-header">
            <h3 id="confirmModalTitle">Confirm Deletion</h3>
            <span class="modal-close" id="closeConfirmModal">&times;</span>
        </div>
        <div class="modal-body">
            <div class="icon-wrapper">
                <i class="fas fa-trash-alt"></i>
            </div>
            <p>Are you sure you want to delete this financial goal?</p>
        </div>
        <div class="form-actions">
            <button type="button" id="confirmDeleteBtn" class="btn btn-danger">Yes, Delete</button>
            <button type="button" id="cancelDeleteBtn" class="btn btn-secondary">Cancel</button>
        </div>
    </div>
</div>

</body>
</html>