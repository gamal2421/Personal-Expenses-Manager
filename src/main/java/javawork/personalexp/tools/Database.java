package javawork.personalexp.tools;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import javawork.personalexp.models.Category;
import javawork.personalexp.models.DashboardData;
import javawork.personalexp.models.Income;
import javawork.personalexp.models.User;

public class Database {
    // Database connection details (hardcoded)
    private static final String URL = "jdbc:postgresql://pg-7df2fd3-waleedgamal2821-a9bd.l.aivencloud.com:14381/defaultdb?sslmode=require";
    private static final String USER = "avnadmin";
    private static final String PASSWORD = "AVNS_v6Of1LG2FuojSos4Hvk";
    private static final Logger logger = Logger.getLogger(Database.class.getName());

    // Static block to load the PostgreSQL JDBC driver
    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            logger.log(Level.SEVERE, "PostgreSQL JDBC Driver not found", e);
        }
    }

    // Method to get a connection to the database
    public static Connection getConnection() throws SQLException {
        try {
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database connection failed", e);
            throw e;  // Rethrow exception after logging it
        }
    }

    // Method to check if a user already exists by email (for registration)
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
    // Method to create a new user (register a new user)
    public static void create_user(String username, String password, String email) throws SQLException {
        try (Connection conn = getConnection()) {
            String sql = "INSERT INTO users (username, password, email, authentication_enabled) VALUES (?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, username);
                stmt.setString(2, password); // Password is stored as plain text (not secure)
                stmt.setString(3, email);
                stmt.setBoolean(4, true);  // Set authentication_enabled to true by default
                stmt.executeUpdate();
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error creating user: " + username, e);
            throw e;  // Rethrow exception after logging it
        }
    }

    // Helper method to execute queries that return a list of results (for simple SELECT queries)
    public static List<String> executeQuery(String query) {
        List<String> results = new ArrayList<>();
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            while (rs.next()) {
                results.add(rs.getString(1)); // Assuming you're interested in the first column
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error executing query: " + query, e);
        }
        return results;
    }

    // Method to validate user credentials (no hashing, plain text password check)
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

    // Method to get a user's name by email
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

    // Fetch total income for a specific user
    public static double getTotalIncome(int userId) {
        double totalIncome = 0;
        String sql = "SELECT SUM(amount) FROM income_sources  WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                totalIncome = rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return totalIncome;
    }

    // Fetch total expenses for a specific user
    public static double getTotalExpenses(int userId) {
        double totalExpenses = 0;
        String sql = "SELECT SUM(amount) FROM expenses WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                totalExpenses = rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return totalExpenses;
    }
    // Update category name
public static boolean updateCategoryName(int categoryId, String newName) {
    try (Connection conn = getConnection();
         PreparedStatement stmt = conn.prepareStatement("UPDATE categories SET name = ? WHERE id = ?")) {
        stmt.setString(1, newName);
        stmt.setInt(2, categoryId);
        return stmt.executeUpdate() > 0;
    } catch (Exception e) {
        e.printStackTrace();
        return false;
    }
}

// Add a new category
public static boolean addCategory(int userId, String categoryName) {
    try (Connection conn = getConnection();
         PreparedStatement stmt = conn.prepareStatement("INSERT INTO categories (user_id, name) VALUES (?, ?)")) {
        stmt.setInt(1, userId);
        stmt.setString(2, categoryName);
        return stmt.executeUpdate() > 0;
    } catch (Exception e) {
        e.printStackTrace();
        return false;
    }
}

    public static boolean deleteCategory(int categoryId) {
        String query = "DELETE FROM categories WHERE id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, categoryId);
            
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;  // Returns true if category is deleted
        } catch (SQLException e) {
            e.printStackTrace();
            return false;  // Return false if there's an issue deleting the category
        }
    }

    // Fetch total savings goal for a specific user
    public static double getTotalSavings(int userId) {
        double totalSavings = 0;
        String sql = "SELECT SUM(target_amount) FROM savings_goals WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                totalSavings = rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return totalSavings;
    }

    // Fetch user information by user ID
    public static User getUserInfo(int userId) {
        User user = null;
        String sql = "SELECT id, username, email FROM users WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                user = new User(rs.getInt("id"), rs.getString("username"), rs.getString("email"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
    }
    public static List<Category> getCategories(int userId) {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT id, name, user_id FROM categories WHERE user_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                int id = rs.getInt("id");
                String name = rs.getString("name");
                categories.add(new Category(id, name, userId));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return categories;
    }
    
    // Method to get user ID by email
    public static int getUserIdByEmail(String email) {
        int userId = -1; // Default if not found
        String sql = "SELECT id FROM users WHERE email = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                userId = rs.getInt("id");
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching user ID by email: " + email, e);
        }
        return userId;
    }



    // Fetch the complete dashboard data for the user
    public static DashboardData getDashboardData(int userId) {
        double totalIncome = getTotalIncome(userId);
        double totalExpenses = getTotalExpenses(userId);
        double totalSavings = getTotalSavings(userId);

        return new DashboardData(totalIncome, totalExpenses, totalSavings);
    }
    

    public static boolean addIncome(Income income) {
        String sql = "INSERT INTO income_sources (source_name, amount, user_id) VALUES (?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, income.getSourceName());
            stmt.setDouble(2, income.getAmount());
            stmt.setInt(3, income.getUserId());
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        income.setId(rs.getInt(1));
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public static List<Income> getIncomesByUserId(int userId) {
        List<Income> incomes = new ArrayList<>();
        String sql = "SELECT id, source_name, amount FROM income_sources WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Income income = new Income(
                    rs.getInt("id"),
                    rs.getString("source_name"),
                    rs.getDouble("amount"),
                    userId
                );
                incomes.add(income);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return incomes;
    }
    
    public static boolean updateIncome(int id, String sourceName, double amount) {
        String sql = "UPDATE income_sources SET source_name = ?, amount = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, sourceName);
            stmt.setDouble(2, amount);
            stmt.setInt(3, id);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    public static boolean deleteIncome(int id) {
        String sql = "DELETE FROM income_sources WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

}

