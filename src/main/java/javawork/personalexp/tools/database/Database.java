package javawork.personalexp.tools.database;
import java.sql.*;

public class Database {
    private static final String URL = "jdbc:postgresql://pg-7df2fd3-waleedgamal2821-a9bd.l.aivencloud.com:14381/defaultdb?sslmode=require";
    private static final String USER = "avnadmin";
    private static final String PASSWORD = "AVNS_v6Of1LG2FuojSos4Hvk";

    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    public static boolean isValidUser(String email, String password) {
        String sql = "SELECT * FROM users WHERE email =? AND password=?";
        try (
            Connection conn = getConnection();
            PreparedStatement stmt = conn.prepareStatement(sql)
        ) {
            stmt.setString(1, email);
            stmt.setString(2, password);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
