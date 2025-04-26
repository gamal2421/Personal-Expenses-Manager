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
            <h3>Mohab Mohamed</h3>
            <p>Financial Analyst</p>
        </div>
        
        <ul class="nav-menu">
            <li class="nav-item"><a href="dashboard.jsp"><i class="icons fas fa-chart-pie"></i> Charts</a></li>
            <li class="nav-item"><a href="Financials goals.html"><i class="icons fas fa-wallet"></i> Financials</a></li>
            <li class="nav-item"><a href="REPORTSandANALYTICS.html"><i class="icons fas fa-file-alt"></i> Reports</a></li>
            <li class="nav-item"><a href="budget.html"icons fas fa-money-bill-wave"></i> Budget</a></li>
            <li class="nav-item"><a href="income.jsp"><i class="icons fas fa-hand-holding-usd"></i> Income</a></li>
            <li class="nav-item"><a href="categories.html"><i class="icons fas fa-tags"></i> Categories</a></li>
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
                <!-- Income entries will be added here dynamically -->
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

    <!-- Profile Overlay -->
    <div class="overlay" id="profileOverlay"></div>

    <!-- Profile Popup Card -->
    <div class="card profile-popup" id="profileCard">
        <div class="avatar">M</div>
        <div class="profile-info">
            <p><strong>Mohab Mohamed</strong></p>
            <p>mohab123@gmail.com</p>
        </div>
        <div class="info-field">
            <label>Name</label>
            <p class="info-value">Mohab Mohamed</p>
        </div>
        <div class="info-field">
            <label>Email Account</label>
            <p class="info-value">mohab123@gmail.com</p>
        </div>
        <div class="info-field">
            <label>Phone Number</label>
            <p class="info-value">+1234567890</p>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Initialize chart
        let chart;
        let incomeData = [
            { label: 'Freelancing', amount: 415 },
            { label: 'Work', amount: 103 },
            { label: 'Teaching', amount: 12 },
            { label: 'Exchange', amount: 27 },
            { label: 'GSL', amount: 390 }
        ];

        const colors = ['#00a97f', '#33c49f', '#66d9b3', '#99e5cc', '#ccefe5'];

        function renderChart() {
            const ctx = document.getElementById('incomeChart').getContext('2d');
            if (chart) chart.destroy();
            chart = new Chart(ctx, {
                type: 'pie',
                data: {
                    labels: incomeData.map(item => item.label),
                    datasets: [{
                        label: 'Income',
                        data: incomeData.map(item => item.amount),
                        backgroundColor: colors,
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'right' }
                    }
                }
            });
        }

        function renderIncomeEntries() {
            const container = document.getElementById('incomeEntries');
            container.innerHTML = '';
            
            incomeData.forEach((item, index) => {
                const entry = document.createElement('div');
                entry.className = 'income-entry';
                entry.innerHTML = `
                    <span>${item.label}: $${item.amount}</span>
                    <div class="actions">
                        <i class="material-icons delete-icon">delete</i>
                        <i class="material-icons edit-icon">edit</i>
                    </div>
                `;
                
                entry.querySelector('.delete-icon').addEventListener('click', () => {
                    incomeData.splice(index, 1);
                    renderIncomeEntries();
                    renderChart();
                });
                
                entry.querySelector('.edit-icon').addEventListener('click', () => {
                    const newLabel = prompt("Edit label:", item.label);
                    const newAmount = parseFloat(prompt("Edit amount:", item.amount));
                    if (newLabel && !isNaN(newAmount)) {
                        incomeData[index] = { label: newLabel, amount: newAmount };
                        renderIncomeEntries();
                        renderChart();
                    }
                });
                
                container.appendChild(entry);
            });
        }

        // Add new income
        document.getElementById('addIncomeBtn').addEventListener('click', function() {
            const label = prompt("Enter income label:");
            const amount = parseFloat(prompt("Enter income amount:"));
            if (label && !isNaN(amount)) {
                incomeData.push({ label, amount });
                renderIncomeEntries();
                renderChart();
            }
        });

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

        // Initial render
        renderChart();
        renderIncomeEntries();
    });
</script>
</body>
</html>
