<%@ page import="javawork.personalexp.tools.Database" %>
<%@ page import="javawork.personalexp.models.User" %>
<%@ page import="javawork.personalexp.models.Income" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.ParseException"%>
<%! // Declare monthNames as a declaration block
    String[] monthNames = {"", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
%>
<%
    // Check if user is logged in
    String userEmail = (String) session.getAttribute("userEmail");
    if (userEmail == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get user data
    int userId = Database.getUserIdByEmail(userEmail);
    User user = Database.getUserInfo(userId);
    String userIncomeLevel = user.getIncomeLevel(); // Get user's income level
    
    // Get selected month and year from request, default to current month/year if not present
    int selectedMonth = 0; // 0 for all months
    int selectedYear = 0; // 0 for all years

    java.util.Calendar cal = java.util.Calendar.getInstance();
    int currentYear = cal.get(java.util.Calendar.YEAR);
    int currentMonth = cal.get(java.util.Calendar.MONTH) + 1; // Calendar.MONTH is 0-indexed

    String reportDateParam = request.getParameter("reportDate");
    if (reportDateParam != null && !reportDateParam.isEmpty()) {
        SimpleDateFormat inputDateFormat = new SimpleDateFormat("yyyy-MM");
        try {
            java.util.Date date = inputDateFormat.parse(reportDateParam);
            cal.setTime(date);
            selectedYear = cal.get(java.util.Calendar.YEAR);
            selectedMonth = cal.get(java.util.Calendar.MONTH) + 1; // Calendar.MONTH is 0-indexed
        } catch (ParseException e) {
            // Handle parse exception if needed, maybe default to current month/year
            selectedYear = currentYear;
            selectedMonth = currentMonth;
        }
    } else {
        // Default to current month and year if no date is selected
        selectedYear = currentYear;
        selectedMonth = currentMonth;
    }
    
    // Get all data based on selected month and year
    List<Map<String, Object>> categories = Database.getAllCategories();
    List<Income> incomes = Database.getIncomesByMonth(userId, selectedYear, selectedMonth);
    List<Map<String, Object>> budgets = Database.getAllBudgets(userId, selectedYear, selectedMonth);
    List<Map<String, Object>> savingsGoals = Database.getAllSavingsGoals(userId, selectedYear, selectedMonth);
    
    // Get average budgets across all users (this might not need month/year filtering depending on requirement)
    // Map<String, Double> averageBudgets = Database.getAverageBudgetsByCategory(); // Assuming this is for overall comparison
    
    // Get average budget and income for the user's income level
    double averageBudgetForIncomeLevel = 0;
    double averageIncomeForIncomeLevel = 0;
    if (userIncomeLevel != null && !userIncomeLevel.isEmpty()) {
        averageBudgetForIncomeLevel = Database.getAverageBudgetByIncomeLevel(userIncomeLevel, selectedYear, selectedMonth);
        averageIncomeForIncomeLevel = Database.getAverageIncomeByIncomeLevel(userIncomeLevel, selectedYear, selectedMonth);
    }

    // Calculate totals based on filtered data
    double totalIncome = incomes != null ? incomes.stream().mapToDouble(Income::getAmount).sum() : 0;
    double totalBudget = budgets != null ? budgets.stream().mapToDouble(b -> (Double)b.get("budget_amount")).sum() : 0;
    double totalSpending = budgets != null ? budgets.stream().mapToDouble(b -> (Double)b.get("current_spending")).sum() : 0;
    double totalSavingsTarget = savingsGoals != null ? savingsGoals.stream().mapToDouble(g -> (Double)g.get("target_amount")).sum() : 0;
    double totalSavingsCurrent = savingsGoals != null ? savingsGoals.stream().mapToDouble(g -> (Double)g.get("current_amount")).sum() : 0;
    
    // Calculate budget ranking counts (based on filtered budgets and income level average)
    int highCount = 0, avgCount = 0, lowCount = 0;
    if (budgets != null && userIncomeLevel != null && !userIncomeLevel.isEmpty() && averageBudgetForIncomeLevel > 0) {
        for (Map<String, Object> budget : budgets) {
            double budgetAmount = (Double) budget.get("budget_amount");
            double percentageDiff = ((budgetAmount - averageBudgetForIncomeLevel) / averageBudgetForIncomeLevel) * 100;
            
            if (percentageDiff > 20) highCount++;
            else if (percentageDiff < -20) lowCount++;
            else avgCount++;
        }
    }
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  
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
  <title>Personal Expenses Manager - Report</title>
  <link href="/Personal-Expenses-Manager/css/all.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="../css/reports.css">
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

    <div class="content-area">
        <div class="top-bar">
            <div class="page-title">
                <h1> Financial Report</h1>
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

        <div class="filter-section">
            <form action="reports.jsp" method="get">
                <label for="reportDate">Select Month and Year:</label>
                <input type="month" id="reportDate" name="reportDate" value="<%= (selectedYear != 0 && selectedMonth != 0) ? String.format("%d-%02d", selectedYear, selectedMonth) : "" %>">

                <button type="submit">Filter</button>
            </form>
        </div>

        <div class="report-content">
            <div class="summary-cards">
                <div class="summary-card income">
                    <h3>Total Income</h3>
                    <p class="value">$<%= String.format("%.2f", totalIncome) %></p>
                </div>
                
                <div class="summary-card budget">
                    <h3>Total Budget</h3>
                    <p class="value">$<%= String.format("%.2f", totalBudget) %></p>
                </div>
                
                <div class="summary-card income-vs-budget">
                    <h3>Income vs Budget (Your Level)</h3>
                    <p class="value"><%= String.format("%.1f%%", (totalBudget > 0 ? (totalIncome / totalBudget) * 100 : 0)) %></p>
                </div>
                
                <div class="summary-card income-level-avg-income">
                    <h3>Avg Income (<%= userIncomeLevel != null ? userIncomeLevel : "N/A" %>)</h3>
                    <p class="value">$<%= String.format("%.2f", averageIncomeForIncomeLevel) %></p>
                </div>
                
                <div class="summary-card income-level-avg-budget">
                    <h3>Avg Budget (<%= userIncomeLevel != null ? userIncomeLevel : "N/A" %>)</h3>
                    <p class="value">$<%= String.format("%.2f", averageBudgetForIncomeLevel) %></p>
                </div>
                
                <div class="summary-card spending">
                    <h3>Total Spending</h3>
                    <p class="value">$<%= String.format("%.2f", totalSpending) %></p>
                </div>
                
                <div class="summary-card comparison">
                    <h3>Budget Comparison</h3>
                    <div class="rank-summary">
                        <div class="rank-item">
                            <span class="badge high-rank"><%= highCount %></span>
                            <span>High</span>
                        </div>
                        <div class="rank-item">
                            <span class="badge avg-rank"><%= avgCount %></span>
                            <span>Average</span>
                        </div>
                        <div class="rank-item">
                            <span class="badge low-rank"><%= lowCount %></span>
                            <span>Low</span>
                        </div>
                    </div>
                </div>
            </div>
            <h3 class="section-header"><i class="fas fa-hand-holding-usd"></i> Income Sources</h3>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Source</th>
                        <th>Amount</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (incomes != null && !incomes.isEmpty()) { 
                        for (Income income : incomes) { %>
                    <tr>
                        <td><%= income.getId() %></td>
                        <td><%= income.getSource() %></td>
                        <td>$<%= String.format("%.2f", income.getAmount()) %></td>
                    </tr>
                    <% } 
                    } else { %>
                    <tr>
                        <td colspan="3" class="empty-state">No income sources found</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>

            <h3 class="section-header"><i class="fas fa-money-bill-wave"></i> Budgets</h3>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Category</th>
                        <th>Your Budget</th>
                        <th>Avg Budget (<%= userIncomeLevel != null ? userIncomeLevel : "N/A" %>)</th>
                        <th>Comparison</th>
                        <th>Rank</th>
                        <th>Current Spending</th>
                        <th>Remaining</th>
                        <th>Created</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (budgets != null && !budgets.isEmpty()) { 
                        for (Map<String, Object> budget : budgets) { 
                            double budgetAmount = (Double) budget.get("budget_amount");
                            double currentSpending = (Double) budget.get("current_spending");
                            double remaining = budgetAmount - currentSpending;
                            String categoryName = (String) budget.get("category");
                            
                            // Calculate comparison and rank using average budget for income level
                            String comparison = "N/A";
                            String rank = "N/A";
                            String rankClass = "";
                            
                            if (userIncomeLevel != null && !userIncomeLevel.isEmpty() && averageBudgetForIncomeLevel > 0) {
                                double difference = budgetAmount - averageBudgetForIncomeLevel;
                                double percentageDiff = (difference / averageBudgetForIncomeLevel) * 100;
                                
                                if (percentageDiff > 20) {
                                    comparison = String.format("+%.1f%%", percentageDiff);
                                    rank = "High";
                                    rankClass = "high-rank";
                                } else if (percentageDiff < -20) {
                                    comparison = String.format("%.1f%%", percentageDiff);
                                    rank = "Low";
                                    rankClass = "low-rank";
                                } else {
                                    comparison = String.format("%.1f%%", percentageDiff);
                                    rank = "Average";
                                    rankClass = "avg-rank";
                                }
                            }
                    %>
                    <tr>
                        <td><%= budget.get("id") %></td>
                        <td><%= categoryName %></td>
                        <td>$<%= String.format("%.2f", budgetAmount) %></td>
                        <td><%= String.format("%.2f", averageBudgetForIncomeLevel) %></td>
                        <td><%= comparison %></td>
                        <td><span class="badge <%= rankClass %>"><%= rank %></span></td>
                        <td>$<%= String.format("%.2f", currentSpending) %></td>
                        <td class="amount <%= remaining >= 0 ? "positive" : "negative" %>">
                            $<%= String.format("%.2f", remaining) %>
                        </td>
                        <td><%= budget.get("created_at") != null ? dateFormat.format(budget.get("created_at")) : "N/A" %></td>
                    </tr>
                    <% } 
                    } else { %>
                    <tr>
                        <td colspan="9" class="empty-state">No budgets found</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>

            <h3 class="section-header"><i class="fas fa-piggy-bank"></i> Savings Goals</h3>
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Title</th>
                        <th>Target Amount</th>
                        <th>Current Amount</th>
                        <th>Progress</th>
                        <th>Target Date</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (savingsGoals != null && !savingsGoals.isEmpty()) { 
                        for (Map<String, Object> goal : savingsGoals) { 
                            double target = (Double) goal.get("target_amount");
                            double current = (Double) goal.get("current_amount");
                            double progress = target > 0 ? (current / target) * 100 : 0;
                            boolean achieved = goal.get("achieved") != null && (Boolean) goal.get("achieved");
                    %>
                    <tr>
                        <td><%= goal.get("id") %></td>
                        <td><%= goal.get("title") %></td>
                        <td>$<%= String.format("%.2f", target) %></td>
                        <td>$<%= String.format("%.2f", current) %></td>
                        <td>
                            <div class="progress-container">
                                <div class="progress-bar" style="width: <%= String.format("%.1f", progress) %>%;"></div>
                            </div>
                            <%= String.format("%.1f", progress) %>%
                        </td>
                        <td><%= goal.get("target_date") != null ? dateFormat.format(goal.get("target_date")) : "N/A" %></td>
                        <td>
                            <span class="badge <%= achieved ? "achieved" : "in-progress" %>">
                                <%= achieved ? "Achieved" : "In Progress" %>
                            </span>
                        </td>
                    </tr>
                    <% } 
                    } else { %>
                    <tr>
                        <td colspan="7" class="empty-state">No savings goals found</td>
                    </tr>
                    <% } %>
                </tbody>
            </table>

            <h3 class="section-header"><i class="fas fa-brain"></i> AI Analysis</h3>
            <div id="ai-analysis-content">
                <p>Loading AI analysis...</p>
                </div>

        </div>
    </div>
</div>

<script>
    // Profile click event
    document.getElementById('profile-section').addEventListener('click', function() {
        console.log("Profile clicked - can implement popup here");
    });

    // Notification button click
    const notificationBtn = document.querySelector('.notification-btn');
    if (notificationBtn) {
        notificationBtn.addEventListener('click', function() {
            console.log("Notifications clicked - can implement notifications here");
        });
    }

    // Settings button click
    const settingsBtn = document.querySelector('.settings-btn');
    if (settingsBtn) {
        settingsBtn.addEventListener('click', function() {
            console.log("Settings clicked - can implement settings here");
        });
    }
</script>

<script>
    function fetchAiAnalysis() {
        const reportDateInput = document.getElementById('reportDate');
        const selectedDate = reportDateInput.value;
        let year = 0;
        let month = 0;

        if (selectedDate) {
            const [selectedYear, selectedMonth] = selectedDate.split('-');
            year = parseInt(selectedYear);
            month = parseInt(selectedMonth);
        }

        const aiAnalysisDiv = document.getElementById('ai-analysis-content');
        aiAnalysisDiv.innerHTML = '<p>Loading AI analysis...</p>'; // Show loading message

        // Construct the correct URL for the AiAnalysisServlet (Hardcoded context path for testing)
        // TODO: Revert to using <%= request.getContextPath() %> for production
        const contextPath = '/Personal-Expenses-Manager'; // Hardcoded for testing
        const servletPath = '/AiAnalysisServlet';
        const servletUrl = contextPath + servletPath + '?year=' + year + '&month=' + month;

        console.log('Fetching AI analysis from: ' + servletUrl);

        fetch(servletUrl)
            .then(response => {
                if (!response.ok) {
                    // If response is not OK (e.g., 404, 500), read as text to see if it's an HTML error page
                    return response.text().then(text => { throw new Error('HTTP error! status: ' + response.status + ', body: ' + text); });
                }
                return response.json(); // Otherwise, parse as JSON
            })
            .then(data => {
                const aiAnalysisDiv = document.getElementById('ai-analysis-content');
                aiAnalysisDiv.innerHTML = ''; // Clear loading message

                if (data.analysis) {
                    // Split the analysis into sections (e.g., by double newline)
                    const sections = data.analysis.split(/\n\s*\n/);

                    // Create a container for the cards
                    const cardsContainer = document.createElement('div');
                    cardsContainer.classList.add('ai-analysis-cards');

                    sections.forEach(section => {
                        if (section.trim() !== '') {
                            // Create a card for each section
                            const card = document.createElement('div');
                            card.classList.add('ai-analysis-card');

                            // Add the section content to the card (replace single newlines with <br>)
                            card.innerHTML = '<p>' + section.trim().replace(/\n/g, '<br>') + '</p>';

                            cardsContainer.appendChild(card);
                        }
                    });

                    aiAnalysisDiv.appendChild(cardsContainer);

                } else if (data.error) {
                    aiAnalysisDiv.innerHTML = '<p>Error: ' + data.error + '</p>';
                } else {
                    aiAnalysisDiv.innerHTML = '<p>Could not retrieve AI analysis.</p>';
                }
            })
            .catch(error => {
                console.error('Error fetching AI analysis:', error);
                aiAnalysisDiv.innerHTML = '<p>Error loading AI analysis: ' + error.message + '</p>';
            });
    }

    // Fetch analysis when the page loads
    fetchAiAnalysis();

    // You might want to add an event listener to the filter form if you want
    // the AI analysis to update without a full page reload when the filter changes.
    // For now, it updates on page load which happens after filter submission.
</script>
</body>
</html>