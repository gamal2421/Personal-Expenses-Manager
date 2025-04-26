<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="javawork.personalexp.tools.database.Database" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/octicons/8.5.0/font/css/octicons.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/dashboard.css">
    <title>Dashboard</title>
    <style>
        .profile-popup {
            display: none;
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: 300px;
            padding: 20px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            z-index: 1001;
        }

        .profile-popup .avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: #3ab19b;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            font-weight: bold;
            margin: 0 auto 15px;
        }

        .profile-info {
            text-align: center;
            margin-bottom: 20px;
        }

        .info-field {
            margin-bottom: 10px;
        }

        .info-field label {
            display: block;
            font-size: 12px;
            color: #666;
            margin-bottom: 3px;
        }

        .info-value {
            font-size: 14px;
            color: #333;
            margin: 0;
            padding: 5px;
            background: #f5f5f5;
            border-radius: 4px;
        }

        .overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
        }
    </style>
</head>
<body>
<div class="main-page">
    <!-- Sidebar -->
    <div id="sidebar">
        <div id="profile-section">
            <div class="profile-image">
                <img src="https://via.placeholder.com/100" alt="Profile">
            </div>
            <h3>
                <% 
                    String email = (String) session.getAttribute("userEmail"); 
                    if (email != null) {
                        String userName = Database.getUserNameByEmail(email); 
                        out.print(userName); 
                    } else {
                        out.print("User not logged in");
                    }
                %>
            </h3>
            <p>Worked</p>
        </div>

        <ul class="nav-menu">
            <li class="nav-item"><a href="dashboard.jsp"><i class="icons fas fa-chart-pie"></i> Charts</a></li>
            <li class="nav-item"><a href="financials.jsp"><i class="icons fas fa-wallet"></i> Financials</a></li>
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
            <!-- Stats Cards -->
            <div class="stats-grid">
                <div class="stat-card">
                    <h3>Income</h3>
                    <div class="value">$100</div>
                </div>
                <div class="stat-card">
                    <h3>Expenses</h3>
                    <div class="value">$70</div>
                </div>
                <div class="stat-card">
                    <h3>Savings</h3>
                    <div class="value">$80</div>
                </div>
                <div class="stat-card">
                    <h3>Investments</h3>
                    <div class="value">$90</div>
                </div>
            </div>

            <!-- Chart -->
            <div class="chart-container">
                <canvas id="myChart"></canvas>
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
        <div class="avatar">
            <% 
                String userEmail = (String) session.getAttribute("userEmail");
                String user = userEmail != null ? Database.getUserNameByEmail(userEmail) : "User";
                out.print(user.substring(0, 1).toUpperCase()); 
            %>
        </div>
        <div class="profile-info">
            <p><strong>Your Profile</strong></p>
            <p id="profile-username"><%= user %></p>
        </div>
        <div class="info-field">
            <label>Name</label>
            <p class="info-value" id="profile-name"><%= user %></p>
        </div>
        <div class="info-field">
            <label>Email Account</label>
            <p class="info-value" id="profile-email"><%= userEmail != null ? userEmail : "Not logged in" %></p>
        </div>
        <div class="profile-actions">
            <button class="logout-btn" onclick="logout()">Logout</button>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const ctx = document.getElementById('myChart').getContext('2d');
        const myChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
                datasets: [{
                    label: 'Expenses',
                    data: [65, 59, 80, 81, 56, 55],
                    backgroundColor: 'rgba(58, 177, 155, 0.2)',
                    borderColor: 'rgba(58, 177, 155, 1)',
                    borderWidth: 2,
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });

        document.getElementById('profile-section').addEventListener('click', function() {
            fetchUserProfile();
            document.getElementById('profileOverlay').style.display = 'block';
            document.getElementById('profileCard').style.display = 'block';
        });

        document.getElementById('profileOverlay').addEventListener('click', function() {
            this.style.display = 'none';
            document.getElementById('profileCard').style.display = 'none';
        });

        document.getElementById('settingsOverlay').addEventListener('click', function() {
            this.style.display = 'none';
            document.getElementById('settingsCard').style.display = 'none';
        });

        document.querySelector('.settings-btn').addEventListener('click', function() {
            document.getElementById('settingsOverlay').style.display = 'block';
            document.getElementById('settingsCard').style.display = 'block';
        });

        function fetchUserProfile() {
            // Using JSP-rendered data for simplicity
            // For AJAX implementation, see the alternative approach below
            console.log("Profile data loaded");
        }

        function logout() {
            fetch('LogoutServlet', {
                method: 'POST'
            }).then(response => {
                if (response.ok) {
                    window.location.href = 'login.jsp';
                }
            });
        }
    });

    // Alternative AJAX implementation:
    /*
    function fetchUserProfile() {
        fetch('UserProfileServlet')
            .then(response => {
                if (!response.ok) {
                    throw new Error('Not logged in');
                }
                return response.json();
            })
            .then(data => {
                document.getElementById('profile-name').textContent = data.username;
                document.getElementById('profile-username').textContent = data.username;
                document.getElementById('profile-email').textContent = data.email;
                document.querySelector('.avatar').textContent = data.username.charAt(0).toUpperCase();
            })
            .catch(error => {
                console.error('Error fetching profile:', error);
                window.location.href = 'login.jsp';
            });
    }
    */
</script>
</body>
</html>