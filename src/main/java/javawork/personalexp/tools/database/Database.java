package javawork.personalexp.tools.database;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javawork.personalexp.models.Budget;
import javawork.personalexp.models.Category;
import javawork.personalexp.models.Report;

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

    public static void create_user(String username, String password, String email) {
        String sql = "INSERT INTO users (username, password, email) VALUES (?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            stmt.setString(2, password);
            stmt.setString(3, email);
            stmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static String getUserNameByEmail(String email) {
        String name = "User";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT username FROM users WHERE email = ?")) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                name = rs.getString("username");
                System.out.println("Fetched username: " + name);
            }
            rs.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return name;
    }

    public static int getUserIdByEmail(String email) {
        int id = -1;
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement("SELECT id FROM users WHERE email = ?")) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                id = rs.getInt("id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return id;
    }

    public static void insertBudget(int userId, int categoryId, double amount, String startDate, String endDate) {
        try (Connection conn = getConnection()) {
            String sql = "INSERT INTO budgets (user_id, category_id, amount, start_date, end_date) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userId);
            stmt.setInt(2, categoryId);
            stmt.setDouble(3, amount);
            stmt.setDate(4, Date.valueOf(startDate));
            stmt.setDate(5, Date.valueOf(endDate));
            stmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static int getOrCreateCategoryId(String categoryName, int userId) {
        String select = "SELECT id FROM categories WHERE name = ? AND user_id = ?";
        String insert = "INSERT INTO categories(name, user_id) VALUES(?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement selectStmt = conn.prepareStatement(select)) {

            selectStmt.setString(1, categoryName);
            selectStmt.setInt(2, userId);
            ResultSet rs = selectStmt.executeQuery();
            if (rs.next()) return rs.getInt("id");

            PreparedStatement insertStmt = conn.prepareStatement(insert, Statement.RETURN_GENERATED_KEYS);
            insertStmt.setString(1, categoryName);
            insertStmt.setInt(2, userId);
            insertStmt.executeUpdate();
            ResultSet keys = insertStmt.getGeneratedKeys();
            if (keys.next()) return keys.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public static List<Budget> getBudgetsByEmail(String email) {
        List<Budget> budgets = new ArrayList<>();
        int userId = getUserIdByEmail(email);

        String sql = "SELECT b.id, c.name AS category_name, b.amount, b.start_date, b.end_date " +
                     "FROM budgets b JOIN categories c ON b.category_id = c.id " +
                     "WHERE b.user_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                budgets.add(new Budget(
                    rs.getInt("id"),
                    rs.getString("category_name"),
                    rs.getDouble("amount"),
                    rs.getDate("start_date"),
                    rs.getDate("end_date")
                ));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return budgets;
    }
    public static List<Report> getReportsByUserId(int userId) {
    List<Report> reports = new ArrayList<>();
    String sql = "SELECT id, month, total_expenses, total_income FROM reports WHERE user_id = ? ORDER BY month DESC";

    try (Connection conn = getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql)) {

        stmt.setInt(1, userId);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            Report report = new Report();
            report.setId(rs.getInt("id"));
            report.setMonth(rs.getDate("month"));
            report.setTotalExpenses(rs.getDouble("total_expenses"));
            report.setTotalIncome(rs.getDouble("total_income"));
            reports.add(report);
        }

    } catch (Exception e) {
        e.printStackTrace();
    }

    return reports;
}

    public static List<Category> getCategoriesByUserId(int userId) {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT id, name, user_id FROM categories WHERE user_id = ?";
    
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
    
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
    
            while (rs.next()) {
                categories.add(new Category(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getInt("user_id")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    
        return categories;
    }
    
    
    public static boolean deleteBudgetById(int id) {
        String sql = "DELETE FROM budgets WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public static void insertBudget(int userId, int categoryId, double amount, Date startDate, Date endDate) {
        String sql = "INSERT INTO budgets(user_id, category_id, amount, start_date, end_date) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, categoryId);
            stmt.setDouble(3, amount);
            stmt.setDate(4, startDate);
            stmt.setDate(5, endDate);
            stmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static boolean updateUserProfile(String oldEmail, String newName, String newEmail) {
        try (Connection conn = getConnection()) {
            String sql = "UPDATE users SET username = ?, email = ? WHERE email = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, newName);
                stmt.setString(2, newEmail);
                stmt.setString(3, oldEmail);
                return stmt.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean isValidUserByEmail(String email) {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean isValidUser(String email, String password) {
        String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            stmt.setString(2, password);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public static int addIncomeWithId(int userId, String sourceName, double amount) {
        String sql = "INSERT INTO incomes (user_id, source_name, amount) VALUES (?, ?, ?) RETURNING id";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setString(2, sourceName);
            stmt.setDouble(3, amount);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }
    
    public static void addIncome(int userId, String sourceName, double amount) {
        addIncomeWithId(userId, sourceName, amount);
    }
    
    public static boolean updateIncome(int incomeId, String sourceName, double amount) {
        String sql = "UPDATE income SET source_name = ?, amount = ? WHERE id = ?";
        
        try (Connection conn = getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setString(1, sourceName);
            stmt.setDouble(2, amount);
            stmt.setInt(3, incomeId);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static boolean deleteIncome(int incomeId) {
        String sql = "DELETE FROM income WHERE id = ?";
        
        try (Connection conn = getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
             
            stmt.setInt(1, incomeId);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

}
