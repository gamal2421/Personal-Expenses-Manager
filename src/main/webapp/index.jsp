    <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">

        <!-- Apple Touch Icon (iOS) -->
        <link rel="apple-touch-icon" sizes="180x180" href="../icons/apple-touch-icon.png">
        <!-- Android Chrome -->
        <link rel="icon" type="image/png" sizes="192x192" href="../icons/android-chrome-192x192.png">
        <link rel="icon" type="image/png" sizes="512x512" href="../icons/android-chrome-512x512.png">
        <!-- Favicon -->
        <link rel="icon" type="image/png" sizes="32x32" href="../icons/favicon-32x32.png">
        <link rel="icon" type="image/png" sizes="16x16" href="../icons/favicon-16x16.png">
        <!-- Optional: Web Manifest for PWA -->
        <link rel="manifest" href="../icons/site.webmanifest">

        <link rel="stylesheet" href="css/homepage.css">

        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Personal Expenses Manager - Manage Your Finances</title>
        <meta name="description" content="Easily track and manage your personal expenses, income, and budgets with Personal Expenses Manager. Set financial goals and gain insights into your spending habits.">
        <meta name="keywords" content="personal expenses, money management, budget, income tracker, financial goals, expense tracker, finance app">
        <meta name="author" content="PEM Team | ntg school">
        <!-- Open Graph / Facebook -->
        <meta property="og:type" content="website">
        <meta property="og:url" content="<%= request.getRequestURL() %>">
        <meta property="og:title" content="Personal Expenses Manager - Manage Your Finances">
        <meta property="og:description" content="Easily track and manage your personal expenses, income, and budgets with Personal Expenses Manager. Set financial goals and gain insights into your spending habits.">
        <meta property="og:image" content="<%= request.getContextPath() %>/icons/android-chrome-512x512.png">

        <!-- Twitter -->
        <meta property="twitter:card" content="summary_large_image">
        <meta property="twitter:url" content="<%= request.getRequestURL() %>">
        <meta property="twitter:title" content="Personal Expenses Manager - Manage Your Finances">
        <meta property="twitter:description" content="Easily track and manage your personal expenses, income, and budgets with Personal Expenses Manager. Set financial goals and gain insights into your spending habits.">
        <meta property="twitter:image" content="<%= request.getContextPath() %>/icons/android-chrome-512x512.png">
    </head>
    <body>
        <header>
            <nav>
                <div class="container">
                    <a href="#" class="logo">Personal Expenses Manager</a>
                    <ul>
                        <li><a href="#">Home</a></li>
                        <li><a href="html/login.jsp">Login</a></li>
                        <li><a href="html/signup.jsp">Sign Up</a></li>
                    </ul>
                </div>
            </nav>
        </header>

        <main>
        
            <section class="hero">
                <div class="container">
                    <h1>Take Control of Your Finances</h1>
                    <p>Track expenses, set budgets, and achieve your financial goals with ease.</p>
                    <a href="html/signup.jsp" class="btn btn-primary">Get Started Today</a>
                </div>
            </section>

            <section class="features">
                <div class="container">
                    <h2>Key Features</h2>
                    <div class="slider-container">
                        <div class="feature-grid slider-track">
                            <div class="feature-item">
                                <h3>Expense Tracking</h3>
                                <p>Easily log and categorize your daily spending.</p>
                            </div>
                            <div class="feature-item">
                                <h3>Budgeting Tools</h3>
                                <p>Create and manage budgets to stay on track.</p>
                            </div>
                            <div class="feature-item">
                                <h3>Financial Goals</h3>
                                <p>Set and monitor goals for savings and debt.</p>
                            </div>
                            <div class="feature-item">
                                <h3>Comprehensive Reporting</h3>
                                <p>Generate detailed reports to visualize your spending and income trends.</p>
                            </div>
                            <div class="feature-item">
                                <h3>Income Tracking</h3>
                                <p>Easily record and manage all your sources of income.</p>
                            </div>
                            <div class="feature-item">
                                <h3>Custom Categories</h3>
                                <p>Organize your transactions with personalized categories.</p>
                            </div>
                        </div>
                        <button class="slider-prev">&#10094;</button>
                        <button class="slider-next">&#10095;</button>
                    </div>
                </div>
            </section>

            <section class="services">
                <div class="container">
                    <h2>Our Services</h2>
                    <div class="service-grid">
                        <div class="service-item card">
                            <h3>Expense Management</h3>
                            <p>Track all your spending in one place with easy categorization.</p>
                        </div>
                        <div class="service-item card">
                            <h3>Budget Planning</h3>
                            <p>Create detailed budgets to control your financial outflows.</p>
                        </div>
                        <div class="service-item card">
                            <h3>Goal Setting</h3>
                            <p>Set and monitor financial goals like saving for a down payment or vacation.</p>
                        </div>
                        <div class="service-item card">
                            <h3>Insightful Reports</h3>
                            <p>Generate comprehensive reports to understand your financial health.</p>
                        </div>
                    </div>
                </div>
            </section>

            <section class="methods">
                <div class="container">
                    <h2>Our Methods</h2>
                    <div class="method-grid">
                        <div class="method-item card">
                            <h3>Secure Data Handling</h3>
                            <p>Your financial data is encrypted and stored securely.</p>
                        </div>
                        <div class="method-item card">
                            <h3>User-Friendly Interface</h3>
                            <p>Designed for simplicity and ease of use, even for beginners.</p>
                        </div>
                        <div class="method-item card">
                            <h3>Continuous Improvement</h3>
                            <p>Regular updates and new features based on user feedback.</p>
                        </div>
                        <div class="method-item card">
                            <h3>24/7 Support</h3>
                            <p>Our support team is always ready to assist you with any queries.</p>
                        </div>
                    </div>
                </div>
            </section>

            <section class="testimonials">
                <div class="container">
                    <h2>What Our Users Say</h2>
                    <div class="testimonial-grid">
                        <div class="testimonial-item card">
                            <p>"Personal Expenses Manager has revolutionized how I handle my money. It's intuitive and highly effective!"</p>
                            <h4>- Jane Doe</h4>
                        </div>
                        <div class="testimonial-item card">
                            <p>"The budgeting tools are fantastic! I've never been so good at saving before."</p>
                            <h4>- John Smith</h4>
                        </div>
                        <div class="testimonial-item card">
                            <p>"I love the insightful reports. They help me understand where my money goes."</p>
                            <h4>- Emily White</h4>
                        </div>
                    </div>
                </div>
            </section>

            <section class="call-to-action">
                <div class="container">
                    <h2>Ready to Take Control?</h2>
                    <p>Join thousands of satisfied users and start your financial journey today.</p>
                    <a href="html/signup.jsp" class="btn btn-primary">Sign Up for Free</a>
                </div>
            </section>
        </main>

        <footer>
            <div class="container">
                <p>&copy; 2023 Personal Expenses Manager. All rights reserved.</p>
            </div>
        </footer>



    <script src="js/homepage_slider.js"></script>

    <script src="https://fpyf8.com/88/tag.min.js" data-zone="151626" async data-cfasync="false"></script>

    </body>
    </html>
