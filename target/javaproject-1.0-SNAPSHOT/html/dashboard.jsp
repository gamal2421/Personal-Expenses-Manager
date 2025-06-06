<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="javawork.personalexp.models.User" %>
<%@ page import="javawork.personalexp.models.DashboardData" %>
<%@ page import="java.util.*" %>
<%@ page import="org.json.JSONArray" %>
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
    List<Double> expenseData = new ArrayList<>();
    List<Double> incomeData = new ArrayList<>();
    
    for (String month : months) {
        expenseData.add(monthlyExpenses.getOrDefault(month, 0.0));
        incomeData.add(monthlyIncome.getOrDefault(month, 0.0));
    }
    
    // Convert data to JSON
    JSONArray monthsJson = new JSONArray(Arrays.asList(months));
    JSONArray expenseJson = new JSONArray(expenseData);
    JSONArray incomeJson = new JSONArray(incomeData);
    
    // Calculate net balance
    double netBalance = dashboardData.getTotalIncome() - dashboardData.getTotalExpenses();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Personal Expenses Manager - Dashboard</title>
    
    <!-- Content Security Policy -->
    <meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; style-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com; img-src 'self' data: https://e7.pngegg.com;">

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
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link rel="stylesheet" href="../css/dashboard.css">
    <style>
        
        .stat-card .value {
            font-size: 1.8rem;
            font-weight: bold;
            margin: 15px 0;
            color: white;

        }
        
        .stat-card .subtext {
            font-size: 0.9rem;
            opacity: 0.9;
        }
        
        .income-card {
            background: linear-gradient(135deg, #4CAF50, #2E7D32);
        }
        
        .expenses-card {
            background: linear-gradient(135deg, #F44336, #C62828);
        }
        
        .savings-card {
            background: linear-gradient(135deg, #2196F3, #1565C0);
        }
        
        .net-card {
            background: linear-gradient(135deg, #FFC107, #FF8F00);
        }
        
        .chart-container {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            margin-top: 20px;
            height: 400px;
            position: relative;
        }
        
        @media (max-width: 768px) {
            .main-page {
                flex-direction: column;
            }
            
            #sidebar {
                width: 100%;
            }
            
            .stats-grid {
                grid-template-columns: 1fr;
            }
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
        <!-- Top Bar -->
        <div class="top-bar">
            <div class="page-title">
                <h1>Dashboard Overview</h1>
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

        <!-- Dashboard Content -->
        <div class="dashboard-content">
            <!-- Stats Cards -->
            <div class="stats-grid">
                <div class="stat-card income-card">
                    <h3><i class="fas fa-money-bill-wave"></i> Income</h3>
                    <div class="value">$<%= String.format("%.2f", dashboardData.getTotalIncome()) %></div>
                    <div class="subtext">Total income this year</div>
                </div>
                
                <div class="stat-card expenses-card">
                    <h3><i class="fas fa-shopping-cart"></i> Expenses</h3>
                    <div class="value">$<%= String.format("%.2f", dashboardData.getTotalExpenses()) %></div>
                    <div class="subtext">Total expenses this year</div>
                </div>
                
                <div class="stat-card savings-card">
                    <h3><i class="fas fa-piggy-bank"></i> Savings</h3>
                    <div class="value">$<%= String.format("%.2f", dashboardData.getTotalSavings()) %></div>
                    <div class="subtext">Towards your savings goals</div>
                </div>
                
                <div class="stat-card net-card">
                    <h3><i class="fas fa-balance-scale"></i> Net Balance</h3>
                    <div class="value">$<%= String.format("%.2f", netBalance) %></div>
                    <div class="subtext">Income minus expenses</div>
                </div>
            </div>

            <!-- Chart -->
            <div class="chart-container">
                <canvas id="financeChart"></canvas>
            </div>
        </div>
    </div>
</div>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Prepare chart data from JSP variables
        const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        const expenseData = <%= new JSONArray(expenseData) %>;
        const incomeData = <%= new JSONArray(incomeData) %>;
        
        console.log("Expense Data:", expenseData);
        console.log("Income Data:", incomeData);
        
        // Create chart
        const ctx = document.getElementById('financeChart').getContext('2d');
        const chart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: months,
                datasets: [
                    {
                        label: 'Income',
                        data: incomeData,
                        backgroundColor: 'rgba(76, 175, 80, 0.7)',
                        borderColor: 'rgba(76, 175, 80, 1)',
                        borderWidth: 1,
                        borderRadius: 4
                    },
                    {
                        label: 'Expenses',
                        data: expenseData,
                        backgroundColor: 'rgba(244, 67, 54, 0.7)',
                        borderColor: 'rgba(244, 67, 54, 1)',
                        borderWidth: 1,
                        borderRadius: 4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'top',
                        labels: {
                            font: {
                                size: 14,
                                weight: 'bold'
                            },
                            padding: 20
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return `${context.dataset.label}: $${context.raw.toFixed(2)}`;
                            }
                        }
                    },
                    title: {
                        display: true,
                        text: 'Monthly Income vs Expenses',
                        font: {
                            size: 16,
                            weight: 'bold'
                        },
                        padding: {
                            top: 10,
                            bottom: 20
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Amount ($)',
                            font: {
                                weight: 'bold'
                            }
                        },
                        ticks: {
                            callback: function(value) {
                                return '$' + value.toLocaleString();
                            }
                        },
                        grid: {
                            drawBorder: false
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: 'Month',
                            font: {
                                weight: 'bold'
                            }
                        },
                        grid: {
                            display: false
                        }
                    }
                },
                animation: {
                    duration: 1000,
                    easing: 'easeOutQuart'
                }
            }
        });
    });
</script>
</body>
</html>