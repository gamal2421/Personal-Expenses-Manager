
<%@ page import="java.sql.*" %>
<!--# 
#//set dbUser=avnadmin
//set dbPassword=AVNS_v6Of1LG2FuojSos4Hvk -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>

    <title>Login Page</title>
    <link rel="stylesheet" href="styles/loginpage.css">
</head>
<body>
    <h2>Login</h2>
    <form Class="loginform"  method="post">
        <center>
        Username: <input type="text" name="username"><br>
        Password: <input type="password" name="password"><br>
        <input type="submit" value="Login">
    </center>


    
    <%
    String user = request.getParameter("username");
    String pass = request.getParameter("password");
    if (user != null && pass != null) {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            Class.forName("org.postgresql.Driver");
            String url = "jdbc:postgresql://pg-7df2fd3-waleedgamal2821-a9bd.l.aivencloud.com:14381/defaultdb?sslmode=require";
          String dbUser = "avnadmin";
            String dbPassword = "AVNS_v6Of1LG2FuojSos4Hvk";
            conn = DriverManager.getConnection(url, dbUser, dbPassword);
            String sql = "SELECT * FROM users WHERE username= ? AND password= ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, user);
            stmt.setString(2, pass);
            rs = stmt.executeQuery();
            if (rs.next()) {
                session.setAttribute("user", user);                    
                response.sendRedirect("page2.jsp");
            } else {
                out.println("<p>Invalid username or password.</p>");
            }
        } catch (Exception e) {
            out.println("<p>Error: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

%>

    </form>
  
</body>
</html>
