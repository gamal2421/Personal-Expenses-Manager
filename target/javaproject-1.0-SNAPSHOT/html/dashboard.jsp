<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="javawork.personalexp.models.User" %>
<%@ page import="javawork.personalexp.models.DashboardData" %>
<%@ page import="java.util.*" %>
<%
    // Check if the user is logged in
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int userId = Database.getUserIdByEmail(userEmail);
    User user = Database.getUserInfo(userId);
    DashboardData dashboardData = Database.getDashboardData(userId);
    
    // Get monthly data
    Map<String, Double> monthlyExpenses = Database.getMonthlyExpenses(userId);
    Map<String, Double> monthlyIncome = Database.getMonthlyIncome(userId);
    
    // Prepare chart data
    String[] months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
    List<String> chartLabels = new ArrayList<>();
    List<Double> expenseData = new ArrayList<>();
    List<Double> incomeData = new ArrayList<>();
    
    for (String month : months) {
        chartLabels.add(month);
        expenseData.add(monthlyExpenses.getOrDefault(month, 0.0));
        incomeData.add(monthlyIncome.getOrDefault(month, 0.0));
    }
    
    // Calculate net balance
    double netBalance = dashboardData.getTotalIncome() - dashboardData.getTotalExpenses();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../css/dashboard.css">
    <style>
        .stat-card {
            position: relative;
            padding: 20px;
            border-radius: 8px;
            color: white;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .stat-card h3 {
            margin-top: 0;
            font-size: 1.2rem;
        }
        .value{
                        color: white;
        }
        .stat-card .value {
            color: white;
            font-size: 1.8rem;
            font-weight: bold;
            margin: 10px 0;
        }
        .stat-card .subtext {
            font-size: 0.9rem;
            opacity: 0.9;
        }
        .income-card {
            background: linear-gradient(135deg, #4CAF50, #81C784);
        }
        .expenses-card {
            background: linear-gradient(135deg, #F44336, #E57373);
        }
        .savings-card {
            background: linear-gradient(135deg, #2196F3, #64B5F6);
        }
        .net-card {
            background: linear-gradient(135deg, #FFC107, #FFD54F);
        }
        .chart-container {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            margin-top: 20px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
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
            <li class="nav-item"><a href="dashboard.jsp"><i class="icons fas fa-chart-pie"></i> Charts</a></li>
            <li class="nav-item"><a href="Financials goals.jsp"><i class="icons fas fa-wallet"></i> Financials</a></li>
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
                <h1>Dashboard</h1>
            </div>
        </div>

        <!-- Dashboard Content -->
        <div class="dashboard-content">
            <!-- Stats Cards -->
            <div class="stats-grid">
                <div class="stat-card income-card">
                    <h3><i class="fas fa-money-bill-wave"></i> Income</h3>
                    <div class="value">$<%= String.format("%.2f", dashboardData.getTotalIncome()) %></div>
                    <div class="subtext">This year's total income</div>
                </div>
                <div class="stat-card expenses-card">
                    <h3><i class="fas fa-shopping-cart"></i> Expenses</h3>
                    <div class="value">$<%= String.format("%.2f", dashboardData.getTotalExpenses()) %></div>
                    <div class="subtext">This year's total expenses</div>
                </div>
                <div class="stat-card savings-card">
                    <h3><i class="fas fa-piggy-bank"></i> Savings</h3>
                    <div class="value">$<%= String.format("%.2f", dashboardData.getTotalSavings()) %></div>
                    <div class="subtext">Total savings goals</div>
                </div>
                <div class="stat-card net-card">
                    <h3><i class="fas fa-balance-scale"></i> Net Balance</h3>
                    <div class="value">$<%= String.format("%.2f", netBalance) %></div>
                    <div class="subtext">Income minus expenses</div>
                </div>
            </div>

            <!-- Chart -->
            <div class="chart-container">
                <canvas id="myChart"></canvas>
            </div>
        </div>
    </div>
</div>

<script>
    // Initialize Chart with actual data
    document.addEventListener('DOMContentLoaded', function() {
        const ctx = document.getElementById('myChart').getContext('2d');
        const myChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: <%= Arrays.toString(months) %>,
                datasets: [
                    {
                        label: 'Income',
                        data: <%= incomeData.toString() %>,
                        backgroundColor: 'rgba(75, 192, 192, 0.6)',
                        borderColor: 'rgba(75, 192, 192, 1)',
                        borderWidth: 1
                    },
                    {
                        label: 'Expenses',
                        data: <%= expenseData.toString() %>,
                        backgroundColor: 'rgba(255, 99, 132, 0.6)',
                        borderColor: 'rgba(255, 99, 132, 1)',
                        borderWidth: 1
                    }
                ]
            },
            options: {
                responsive: true,
                scales: {
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Amount ($)'
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: 'Month'
                        }
                    }
                },
                plugins: {
                    title: {
                        display: true,
                        text: 'Monthly Income vs Expenses'
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return context.dataset.label + ': $' + context.raw.toFixed(2);
                            }
                        }
                    }
                }
            }
        });
    });
</script>
</body>
</html>