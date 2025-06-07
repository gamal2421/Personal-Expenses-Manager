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
<%
    response.sendRedirect(request.getContextPath() + "/html/login.jsp");
%>
</body>
</html>
