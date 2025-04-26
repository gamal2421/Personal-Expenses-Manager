<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Personal Expenses Manager</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
<link rel="stylesheet" href="../css/reports.css">
</head>
<body>
<div class="main-page">
    <!-- Sidebar -->
    <div id="sidebar">
        <div id="profile-section">
            <div class="profile-image">
                <img src="https://via.placeholder.com/100" alt="Profile">
            </div>
            <h3>Name</h3>
        </div>
                
        <ul class="nav-menu">
            <li class="nav-item"><a href="dashboard.html"><i class="icons fas fa-chart-pie"></i> Charts</a></li>
            <li class="nav-item"><a href="Financials goals.html"><i class="icons fas fa-wallet"></i> Financials</a></li>
            <li class="nav-item"><a href="reports.html"><i class="icons fas fa-file-alt"></i> Reports</a></li>
            <li class="nav-item"><a href="budget.html"><i class="icons fas fa-money-bill-wave"></i> Budget</a></li>
            <li class="nav-item"><a href="income.html"><i class="icons fas fa-hand-holding-usd"></i> Income</a></li>
            <li class="nav-item"><a href="categories.html"><i class="icons fas fa-tags"></i> Categories</a></li>
        </ul>
    </div>

    <!-- Main Content -->
    <div class="content-area">
        <!-- Top Bar -->
        <div class="top-bar">
            <div class="page-title">
                <h1>Reports</h1>
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

        <!-- Report Content -->
        <div class="report-content">
            <h3 class="section-header">Monthly Expenses Report</h3>
            <p class="subtext">May, 2024</p>

            <h4 class="section-header">Category Breakdown</h4>
            <table>
                <thead>
                    <tr>
                        <th>Category</th>
                        <th>Amount Spent</th>
                        <th>Percentage Of Total</th>
                    </tr>
                </thead>
                <tbody>
                    <tr><td>Food</td><td>$700</td><td>14%</td></tr>
                    <tr><td>Transactions</td><td>$700</td><td>14%</td></tr>
                    <tr><td>Entertainment</td><td>$700</td><td>14%</td></tr>
                    <tr><td>Utilities</td><td>$700</td><td>14%</td></tr>
                </tbody>
            </table>

            <h4 class="section-header">Detailed Transactions</h4>
            <table>
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Category</th>
                        <th>Description</th>
                        <th>Amount</th>
                        <th>Payment Method</th>
                    </tr>
                </thead>
                <tbody id="transactions-body">
                    <!-- JS can add rows here -->
                </tbody>
            </table>

            <div class="summary">
                <strong>Summary</strong><br>
                Total Income: $4000<br>
                Total Expenses: $2350<br>
                Net Savings: $1200<br>
                Number of Transactions: 20<br>
                Average Daily Spending: $75
            </div>
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

    <!-- Profile Overlay -->
    <div class="overlay" id="profileOverlay"></div>

    <!-- Profile Popup Card -->
    <div class="card profile-popup" id="profileCard">
        <div class="avatar">N</div>
        <div class="profile-info">
            <p><strong>Your Name</strong></p>
            <p>ethar.waleed21nmm</p>
        </div>
        <div class="info-field">
            <label>Name</label>
            <p class="info-value">Waleed</p>
        </div>
        <div class="info-field">
            <label>Email Account</label>
            <p class="info-value">ethar.waleed@example.com</p>
        </div>
        <div class="info-field">
            <label>Phone Number</label>
            <p class="info-value">+1234567890</p>
        </div>
    </div>
</div>

<script>
    // Add sample rows to transactions
    const tbody = document.getElementById("transactions-body");
    for (let i = 0; i < 5; i++) {
        let row = document.createElement("tr");
        row.innerHTML = `
            <td>2024-05-0${i + 1}</td>
            <td>Food</td>
            <td>Grocery</td>
            <td>$100</td>
            <td>Credit Card</td>
        `;
        tbody.appendChild(row);
    }

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

    document.getElementById('settingsOverlay').addEventListener('click', function() {
        this.style.display = 'none';
        document.getElementById('settingsCard').style.display = 'none';
    });

    // Settings button click
    document.querySelector('.settings-btn').addEventListener('click', function() {
        document.getElementById('settingsOverlay').style.display = 'block';
        document.getElementById('settingsCard').style.display = 'block';
    });
</script>
</body>
</html>