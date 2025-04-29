<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="javawork.personalexp.models.User" %>
<%@ page import="javawork.personalexp.models.Income" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Personal Expenses Manager - Income</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
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
</ul>
    </div>

    <div class="content-area">
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
                                    <button class="action-btn edit-btn" 
                                        onclick="editIncome(<%= income.getId() %>, '<%= income.getSource() %>', <%= income.getAmount() %>)">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="action-btn delete-btn" 
                                        onclick="deleteIncome(<%= income.getId() %>)">
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

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Filter functionality
        document.getElementById('filterInput').addEventListener('input', function() {
            const filterValue = this.value.toLowerCase();
            document.querySelectorAll('.income-card').forEach(card => {
                const source = card.querySelector('.income-source').textContent.toLowerCase();
                card.style.display = source.includes(filterValue) ? 'block' : 'none';
            });
        });

        // Initialize pie chart
        const ctx = document.getElementById('incomeChart').getContext('2d');
        
        const incomeData = {
            labels: [<%= incomeBySource.keySet().stream()
                .map(source -> "'" + source + "'")
                .collect(java.util.stream.Collectors.joining(", ")) %>],
            datasets: [{
                data: [<%= incomeBySource.values().stream()
                .map(String::valueOf)
                .collect(java.util.stream.Collectors.joining(", ")) %>],
                backgroundColor: [
                    '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', 
                    '#9966FF', '#FF9F40', '#8AC24A', '#607D8B',
                    '#E91E63', '#3F51B5'
                ],
                borderWidth: 1
            }]
        };
        
        const incomeChart = new Chart(ctx, {
            type: 'pie',
            data: incomeData,
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'right',
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const label = context.label || '';
                                const value = context.raw || 0;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = Math.round((value / total) * 100);
                                return `${label}: $${value.toFixed(2)} (${percentage}%)`;
                            }
                        }
                    }
                }
            }
        });

        // Add new income
        document.getElementById('addIncomeBtn').addEventListener('click', function() {
            const source = prompt('Enter income source:');
            if (source && source.trim()) {
                const amount = parseFloat(prompt('Enter income amount:'));
                if (!isNaN(amount)) {
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = 'income.jsp';
                    
                    const actionInput = document.createElement('input');
                    actionInput.type = 'hidden';
                    actionInput.name = 'action';
                    actionInput.value = 'add';
                    form.appendChild(actionInput);
                    
                    const sourceInput = document.createElement('input');
                    sourceInput.type = 'hidden';
                    sourceInput.name = 'source';
                    sourceInput.value = source;
                    form.appendChild(sourceInput);
                    
                    const amountInput = document.createElement('input');
                    amountInput.type = 'hidden';
                    amountInput.name = 'amount';
                    amountInput.value = amount;
                    form.appendChild(amountInput);
                    
                    document.body.appendChild(form);
                    form.submit();
                } else {
                    alert('Please enter a valid amount');
                }
            }
        });
    });

    function editIncome(id, currentSource, currentAmount) {
        const newSource = prompt('Edit income source:', currentSource);
        if (newSource && newSource.trim()) {
            const newAmount = parseFloat(prompt('Edit income amount:', currentAmount));
            if (!isNaN(newAmount)) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'income.jsp';
                
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
                
                const sourceInput = document.createElement('input');
                sourceInput.type = 'hidden';
                sourceInput.name = 'source';
                sourceInput.value = newSource;
                form.appendChild(sourceInput);
                
                const amountInput = document.createElement('input');
                amountInput.type = 'hidden';
                amountInput.name = 'amount';
                amountInput.value = newAmount;
                form.appendChild(amountInput);
                
                document.body.appendChild(form);
                form.submit();
            } else {
                alert('Please enter a valid amount');
            }
        }
    }

    function deleteIncome(id) {
        if (confirm('Are you sure you want to delete this income record?')) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = 'income.jsp';
            
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