package javawork.personalexp.tools;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import javawork.personalexp.models.Budget;
import javawork.personalexp.models.Category;
import javawork.personalexp.models.DashboardData;
import javawork.personalexp.models.Income;
import javawork.personalexp.models.User;

public class Database {
    // Database connection details
    private static final String URL = "jdbc:postgresql://pg-7df2fd3-waleedgamal2821-a9bd.l.aivencloud.com:14381/defaultdb?sslmode=require";
    private static final String USER = "avnadmin";
    private static final String PASSWORD = "AVNS_v6Of1LG2FuojSos4Hvk";
    private static final Logger logger = Logger.getLogger(Database.class.getName());

    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            logger.log(Level.SEVERE, "PostgreSQL JDBC Driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        try {
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database connection failed", e);
            throw e;
        }
    }

    // User-related methods
    public static boolean isValidUserByEmail(String email) {
        boolean exists = false;
        try (Connection conn = getConnection()) {
            String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, email);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    exists = rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking user existence by email: " + email, e);
        }
        return exists;
    }

    public static void create_user(String username, String password, String email) throws SQLException {
        try (Connection conn = getConnection()) {
            String sql = "INSERT INTO users (username, password, email, authentication_enabled) VALUES (?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, username);
                stmt.setString(2, password);
                stmt.setString(3, email);
                stmt.setBoolean(4, true);
                stmt.executeUpdate();
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error creating user: " + username, e);
            throw e;
        }
    }

    public static boolean isValidUser(String email, String password) {
        boolean isValid = false;
        try (Connection conn = getConnection()) {
            String sql = "SELECT COUNT(*) FROM users WHERE email = ? AND password = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, email);
                stmt.setString(2, password);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    isValid = rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error validating user credentials", e);
        }
        return isValid;
    }

    public static String getUserNameByEmail(String email) {
        String userName = null;
        try (Connection conn = getConnection()) {
            String sql = "SELECT username FROM users WHERE email = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, email);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    userName = rs.getString("username");
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching username for email: " + email, e);
        }
        return userName;
    }

    public static int getUserIdByEmail(String email) {
        int userId = -1;
        try (Connection conn = getConnection()) {
            String sql = "SELECT id FROM users WHERE email = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, email);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    userId = rs.getInt("id");
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching user ID by email: " + email, e);
        }
        return userId;
    }

    public static User getUserInfo(int userId) {
        User user = null;
        try (Connection conn = getConnection()) {
            String sql = "SELECT id, username, email FROM users WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    user = new User(rs.getInt("id"), rs.getString("username"), rs.getString("email"));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching user info for ID: " + userId, e);
        }
        return user;
    }

    // Income-related methods
    public static boolean addIncome(int userId, double amount, String source) {
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "INSERT INTO income_sources (user_id, amount, source_name) VALUES (?, ?, ?)")) {
            
            stmt.setInt(1, userId);
            stmt.setDouble(2, amount);
            stmt.setString(3, source);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error adding income for user: " + userId, e);
            return false;
        }
    }

    public static boolean updateIncome(int id, double amount, String source) {
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "UPDATE income_sources SET amount = ?, source_name = ? WHERE id = ?")) {
            
            stmt.setDouble(1, amount);
            stmt.setString(2, source);
            stmt.setInt(3, id);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating income ID: " + id, e);
            return false;
        }
    }

    public static boolean deleteIncome(int id) {
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "DELETE FROM income_sources WHERE id = ?")) {
            
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting income ID: " + id, e);
            return false;
        }
    }

    public static List<Income> getIncomes(int userId) {
        List<Income> incomes = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "SELECT id, amount, source_name FROM income_sources WHERE user_id = ? ORDER BY id DESC")) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                incomes.add(new Income(
                    rs.getInt("id"),
                    rs.getDouble("amount"),
                    rs.getString("source_name")
                ));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching incomes for user: " + userId, e);
        }
        return incomes;
    }

    public static double getTotalIncome(int userId) {
        double totalIncome = 0;
        try (Connection conn = getConnection()) {
            String sql = "SELECT COALESCE(SUM(amount), 0) FROM income_sources WHERE user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    totalIncome = rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error calculating total income for user: " + userId, e);
        }
        return totalIncome;
    }

    // Category-related methods
    public static List<Category> getCategories(int userId) {
        List<Category> categories = new ArrayList<>();
        try (Connection conn = getConnection()) {
            String sql = "SELECT id, name, user_id FROM categories WHERE user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    categories.add(new Category(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getInt("user_id")
                    ));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching categories for user: " + userId, e);
        }
        return categories;
    }

    public static boolean addCategory(int userId, String categoryName) {
        try (Connection conn = getConnection()) {
            String sql = "INSERT INTO categories (user_id, name) VALUES (?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                stmt.setString(2, categoryName);
                return stmt.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error adding category for user: " + userId, e);
            return false;
        }
    }

    public static boolean updateCategoryName(int categoryId, String newName) {
        try (Connection conn = getConnection()) {
            String sql = "UPDATE categories SET name = ? WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, newName);
                stmt.setInt(2, categoryId);
                return stmt.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating category ID: " + categoryId, e);
            return false;
        }
    }

    public static boolean deleteCategory(int categoryId) {
        try (Connection conn = getConnection()) {
            String sql = "DELETE FROM categories WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, categoryId);
                return stmt.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting category ID: " + categoryId, e);
            return false;
        }
    }

    // Dashboard methods
    public static double getTotalExpenses(int userId) {
        double totalExpenses = 0;
        try (Connection conn = getConnection()) {
            String sql = "SELECT COALESCE(SUM(amount), 0) FROM expenses WHERE user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    totalExpenses = rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error calculating total expenses for user: " + userId, e);
        }
        return totalExpenses;
    }

    public static double getTotalSavings(int userId) {
        double totalSavings = 0;
        try (Connection conn = getConnection()) {
            String sql = "SELECT COALESCE(SUM(target_amount), 0) FROM savings_goals WHERE user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    totalSavings = rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error calculating total savings for user: " + userId, e);
        }
        return totalSavings;
    }

    public static DashboardData getDashboardData(int userId) {
        return new DashboardData(
            getTotalIncome(userId),
            getTotalExpenses(userId),
            getTotalSavings(userId)
        );
    }


    // Budget-related methods in Database class
    public static boolean addBudget(int userId, String category, double budgetAmount, double currentSpending) {
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "INSERT INTO budgets (user_id, category, budget_amount, current_spending) VALUES (?, ?, ?, ?)")) {
            
            stmt.setInt(1, userId);
            stmt.setString(2, category);
            stmt.setDouble(3, budgetAmount);
            stmt.setDouble(4, currentSpending);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
public static boolean updateBudget(int id, String category, double budgetAmount) {
    try (Connection conn = getConnection();
         PreparedStatement stmt = conn.prepareStatement(
             "UPDATE budgets SET category = ?, budget_amount = ? WHERE id = ?")) {
        
        stmt.setString(1, category);
        stmt.setDouble(2, budgetAmount);
        stmt.setInt(3, id);
        
        return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}

public static boolean deleteBudget(int id) {
    try (Connection conn = getConnection();
         PreparedStatement stmt = conn.prepareStatement(
             "DELETE FROM budgets WHERE id = ?")) {
        
        stmt.setInt(1, id);
        return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}

public static List<Budget> getBudgets(int userId) {
    List<Budget> budgets = new ArrayList<>();
    try (Connection conn = getConnection();
         PreparedStatement stmt = conn.prepareStatement(
             "SELECT id, category, budget_amount, current_spending FROM budgets WHERE user_id = ?")) {
        
        stmt.setInt(1, userId);
        ResultSet rs = stmt.executeQuery();
        
        while (rs.next()) {
            budgets.add(new Budget(
                rs.getInt("id"),
                rs.getString("category"),
                rs.getDouble("budget_amount"),
                rs.getDouble("current_spending")
            ));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return budgets;
}

    // Utility methods
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn.isValid(2);
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Connection test failed", e);
            return false;
        }
    }
}