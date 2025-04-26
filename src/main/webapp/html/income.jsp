
<%@ page import="javawork.personalexp.models.Income" %>
<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
String email = (String) session.getAttribute("userEmail");
    if (email == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int userId = -1;
    String username = "Guest";
    List<Income> incomes = Collections.emptyList();
    
    try {
        userId = Database.getUserIdByEmail(email);
        username = Database.getUserNameByEmail(email);
        incomes = Database.getIncomesByUserId(userId);
    } catch (Exception e) {
        System.err.println("Database error: " + e.getMessage());
    }
    
    // Generate CSRF token if not exists
    if (session.getAttribute("csrfToken") == null) {
        session.setAttribute("csrfToken", java.util.UUID.randomUUID().toString());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Personal Expenses Manager - Income</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <link rel="stylesheet" href="../css/income.css">
</head>
<body>
<div class="main-page">
    <!-- Sidebar -->
    <div id="sidebar">
        <div id="profile-section">
            <div class="profile-image">
                <img src="https://via.placeholder.com/100" alt="Profile">
            </div>
            <h3><%= username %></h3>
            <p>Financial Analyst</p>
        </div>
        
        <ul class="nav-menu">
            <li class="nav-item"><a href="dashboard.jsp"><i class="icons fas fa-chart-pie"></i> Charts</a></li>
            <li class="nav-item"><a href="financial_goals.jsp"><i class="icons fas fa-wallet"></i> Financials</a></li>
            <li class="nav-item"><a href="reports.jsp"><i class="icons fas fa-file-alt"></i> Reports</a></li>
            <li class="nav-item"><a href="budget.jsp"><i class="icons fas fa-money-bill-wave"></i> Budget</a></li>
            <li class="nav-item"><a href="income.jsp"><i class="icons fas fa-hand-holding-usd"></i> Income</a></li>
            <li class="nav-item"><a href="categories.jsp"><i class="icons fas fa-tags"></i> Categories</a></li>
        </ul>
    </div>

    <!-- Main Content -->
    <div class="content-area">
        <!-- Top Bar -->
        <div class="top-bar">
            <div class="page-title">
                <h1>Income</h1>
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

        <!-- Content Box -->
        <div class="content-box">
            <div class="chart-container">
                <canvas id="incomeChart"></canvas>
            </div>

            <div class="income-entries" id="incomeEntries">
                <% if (incomes != null && !incomes.isEmpty()) { %>
                    <% for (Income income : incomes) { %>
                        <div class="income-entry" data-id="<%= income.getId() %>">
                            <span><%= income.getSourceName() %>: $<%= String.format("%.2f", income.getAmount()) %></span>
                            <div class="actions">
                                <i class="material-icons delete-icon">delete</i>
                                <i class="material-icons edit-icon">edit</i>
                            </div>
                        </div>
                    <% } %>
                <% } else { %>
                    <div class="no-income">No income records found</div>
                <% } %>
            </div>

            <button class="add-button" id="addIncomeBtn">+</button>
        </div>
    </div>

    <!-- Settings Overlay -->
    <div class="overlay" id="settingsOverlay"></div>

    <!-- Settings Card -->
    <div class="card" id="settingsCard">
        <div class="card-item"><span class="material-icons">palette</span> Theme</div>
        <div class="card-item"><span class="material-icons">lock</span> Privacy</div>
        <div class="card-item"><span class="material-icons">notifications_active</span> Enable Notification</div>
    </div>

    <!-- Loading Indicator -->
    <div class="loading-overlay" id="loadingOverlay">
        <div class="loading-spinner"></div>
    </div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        console.log("Page loaded - initializing income management");
        
        // Initialize chart and variables
        let incomeChart = null;
        const colors = ['#00a97f', '#33c49f', '#66d9b3', '#99e5cc', '#ccefe5'];
        const csrfToken = '<%= session.getAttribute("csrfToken") %>';
        const loadingOverlay = document.getElementById('loadingOverlay');
        const userId = <%= userId %>;

        // Loading indicator functions
        function showLoading() {
            loadingOverlay.style.display = 'flex';
        }

        function hideLoading() {
            loadingOverlay.style.display = 'none';
        }

        // Toast notification function
        function showToast(message, type = 'success') {
            const toast = document.createElement('div');
            toast.className = `toast ${type}`;
            toast.textContent = message;
            document.body.appendChild(toast);
            
            setTimeout(() => {
                toast.classList.add('fade-out');
                setTimeout(() => toast.remove(), 500);
            }, 3000);
        }

        // Chart rendering function
        function renderChart() {
            console.log("Rendering chart...");
            const incomeEntries = document.querySelectorAll('.income-entry');
            const labels = [];
            const amounts = [];
            
            incomeEntries.forEach(entry => {
                const text = entry.querySelector('span').textContent;
                const parts = text.split(': $');
                labels.push(parts[0]);
                amounts.push(parseFloat(parts[1]));
            });
            
            const ctx = document.getElementById('incomeChart').getContext('2d');
            
            // Destroy previous chart if exists
            if (incomeChart) {
                incomeChart.destroy();
            }
            
            if (labels.length > 0) {
                incomeChart = new Chart(ctx, {
                    type: 'pie',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Income Amount',
                            data: amounts,
                            backgroundColor: colors,
                            borderWidth: 1
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                position: 'right',
                            },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        return `${context.label}: $${context.raw.toFixed(2)}`;
                                    }
                                }
                            }
                        }
                    }
                });
                console.log("Chart rendered with data");
            } else {
                // Clear and show message if no data
                ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
                ctx.font = '16px Arial';
                ctx.fillStyle = '#666';
                ctx.textAlign = 'center';
                ctx.fillText('No income data available', ctx.canvas.width/2, ctx.canvas.height/2);
                console.log("No data available for chart");
            }
        }

        // Unified AJAX handler for income actions
        function handleIncomeAction(action, data, successCallback) {
            console.log(`Handling ${action} action with data:`, data);
            showLoading();
            
            fetch('IncomeServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-CSRF-Token': csrfToken
                },
                body: `action=${action}&${new URLSearchParams(data).toString()}`
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            })
            .then(result => {
                console.log("Server response:", result);
                if (result.success) {
                    successCallback(result);
                    showToast(`Income ${action} successful`);
                } else {
                    throw new Error(result.message || `Failed to ${action} income`);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showToast(error.message, 'error');
            })
            .finally(() => {
                hideLoading();
            });
        }

        // Add new income
        document.getElementById('addIncomeBtn').addEventListener('click', function() {
            const sourceName = prompt("Enter income source:");
            if (!sourceName) {
                console.log("Add income canceled - no source name");
                return;
            }
            
            const amountStr = prompt("Enter income amount:");
            if (!amountStr) {
                console.log("Add income canceled - no amount");
                return;
            }
            
            const amount = parseFloat(amountStr);
            if (isNaN(amount) || amount <= 0) {
                showToast('Please enter a valid positive number', 'error');
                return;
            }
            
            console.log(`Adding new income: ${sourceName} - $${amount}`);
            
            handleIncomeAction('add', { 
                sourceName: sourceName, 
                amount: amount,
                userId: userId
            }, (result) => {
                const container = document.getElementById('incomeEntries');
                // Remove "no income" message if exists
                const noIncomeMsg = container.querySelector('.no-income');
                if (noIncomeMsg) noIncomeMsg.remove();
                
                // Create new entry element
                const entry = document.createElement('div');
                entry.className = 'income-entry';
                entry.dataset.id = result.id;
                entry.innerHTML = `
                    <span>${sourceName}: $${amount.toFixed(2)}</span>
                    <div class="actions">
                        <i class="material-icons delete-icon">delete</i>
                        <i class="material-icons edit-icon">edit</i>
                    </div>
                `;
                container.appendChild(entry);
                addEntryEventListeners(entry);
                renderChart();
            });
        });

        // Edit income listener
        function setupEditListener(entry) {
            entry.querySelector('.edit-icon').addEventListener('click', function() {
                const currentText = entry.querySelector('span').textContent;
                const [currentSource, currentAmount] = currentText.split(': $');
                const amount = parseFloat(currentAmount);
                
                const newSource = prompt("Edit income source:", currentSource.trim());
                if (newSource === null) {
                    console.log("Edit canceled");
                    return;
                }
                
                const newAmountStr = prompt("Edit income amount:", amount);
                if (newAmountStr === null) {
                    console.log("Edit canceled");
                    return;
                }
                
                const newAmount = parseFloat(newAmountStr);
                if (isNaN(newAmount) || newAmount <= 0) {
                    showToast('Invalid amount', 'error');
                    return;
                }
                
                console.log(`Updating income ID ${entry.dataset.id} to ${newSource} - $${newAmount}`);
                
                handleIncomeAction('update', {
                    id: entry.dataset.id,
                    sourceName: newSource,
                    amount: newAmount
                }, () => {
                    entry.querySelector('span').textContent = `${newSource}: $${newAmount.toFixed(2)}`;
                    renderChart();
                });
            });
        }

        // Delete income listener
        function setupDeleteListener(entry) {
            entry.querySelector('.delete-icon').addEventListener('click', function() {
                if (!confirm('Are you sure you want to delete this income record?')) {
                    console.log("Delete canceled");
                    return;
                }
                
                console.log(`Deleting income ID ${entry.dataset.id}`);
                
                handleIncomeAction('delete', { 
                    id: entry.dataset.id 
                }, () => {
                    entry.remove();
                    renderChart();
                    
                    // Show "no income" message if last entry was deleted
                    if (document.querySelectorAll('.income-entry').length === 0) {
                        document.getElementById('incomeEntries').innerHTML = 
                            '<div class="no-income">No income records found</div>';
                    }
                });
            });
        }

        // Add event listeners to an income entry
        function addEntryEventListeners(entry) {
            setupEditListener(entry);
            setupDeleteListener(entry);
        }

        // Initialize event listeners for existing entries
        document.querySelectorAll('.income-entry').forEach(entry => {
            addEntryEventListeners(entry);
        });

        // Initial chart render
        renderChart();
        console.log("Income page initialization complete");
    });
</script>

<style>
    .toast {
        position: fixed;
        bottom: 20px;
        right: 20px;
        padding: 12px 24px;
        background-color: #00a97f;
        color: white;
        border-radius: 4px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.2);
        z-index: 1000;
        animation: slide-in 0.5s ease-out;
    }
    
    .toast.error {
        background-color: #e74c3c;
    }
    
    .toast.fade-out {
        animation: fade-out 0.5s ease-out;
    }
    
    .no-income {
        text-align: center;
        padding: 20px;
        color: #666;
    }
    
    .loading-overlay {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0,0,0,0.2);
        z-index: 2000;
        justify-content: center;
        align-items: center;
    }
    
    .loading-spinner {
        border: 4px solid #f3f3f3;
        border-top: 4px solid #00a97f;
        border-radius: 50%;
        width: 40px;
        height: 40px;
        animation: spin 1s linear infinite;
    }
    
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
    
    @keyframes slide-in {
        from { transform: translateX(100%); }
        to { transform: translateX(0); }
    }
    
    @keyframes fade-out {
        from { opacity: 1; }
        to { opacity: 0; }
    }
</style>
</body>
</html>