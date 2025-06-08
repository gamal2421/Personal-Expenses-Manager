package javawork.personalexp.tools;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import javawork.personalexp.models.Budget;
import javawork.personalexp.models.Category;
import javawork.personalexp.models.DashboardData;
import javawork.personalexp.models.Expense;
import javawork.personalexp.models.Income;
import javawork.personalexp.models.SavingGoal;
import javawork.personalexp.models.User;
import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.mindrot.jbcrypt.BCrypt;

public class Database {
    // Database connection details
    private static final String URL = "jdbc:postgresql://pg-7df2fd3-waleedgamal2821-a9bd.l.aivencloud.com:14381/defaultdb?sslmode=require";
    private static final String USER = "avnadmin";
    private static final String PASSWORD = "AVNS_v6Of1LG2FuojSos4Hvk";
    private static final Logger logger = Logger.getLogger(Database.class.getName());
    private static HikariDataSource dataSource;

    static {
        try {
            Class.forName("org.postgresql.Driver");
            HikariConfig config = new HikariConfig();
            config.setJdbcUrl(URL);
            config.setUsername(USER);
            config.setPassword(PASSWORD);
            config.setMaximumPoolSize(10); // Tune as needed
            config.setMinimumIdle(2);
            config.setIdleTimeout(30000);
            config.setConnectionTimeout(30000);
            config.setMaxLifetime(1800000);
            dataSource = new HikariDataSource(config);
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Failed to initialize HikariCP DataSource", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return dataSource.getConnection();
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
                String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
                stmt.setString(1, username);
                stmt.setString(2, hashedPassword);
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
            String sql = "SELECT password FROM users WHERE email = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, email);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    String hashedPassword = rs.getString("password");
                    isValid = BCrypt.checkpw(password, hashedPassword);
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
            String sql = "SELECT id, username, email, income_level FROM users WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    user = new User(rs.getInt("id"), rs.getString("username"), rs.getString("email"), rs.getString("income_level"));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching user info for ID: " + userId, e);
        }
        return user;
    }

    // Helper to extract user-friendly error messages from SQLExceptions
    private static String getFriendlySqlError(SQLException e) {
        String msg = e.getMessage();
        if (msg == null) return null;
        if (msg.contains("Current spending cannot exceed budget amount")) {
            return "You have exceeded your budget for this category.";
        }
        if (msg.contains("duplicate key value") || msg.contains("unique constraint")) {
            return "This entry already exists.";
        }
        if (msg.contains("violates foreign key constraint")) {
            return "Invalid reference to another record.";
        }
        if (msg.contains("null value in column")) {
            return "A required field is missing.";
        }
        // Add more as needed
        return null;
    }

    // Helper to determine income level based on total income
    private static String determineIncomeLevel(double totalIncome) {
        // Define your income tiers here.
        if (totalIncome < 20000) {
            return "Low";
        } else if (totalIncome >= 20000 && totalIncome < 50000) {
            return "Medium";
        } else {
            return "High";
        }
    }

    public static boolean addExpense(int userId, int categoryId, double amount, String description) throws SQLException {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // 1. Check if category exists
            String checkCategorySql = "SELECT id FROM categories WHERE id = ?";
            try (PreparedStatement checkCatStmt = conn.prepareStatement(checkCategorySql)) {
                checkCatStmt.setInt(1, categoryId);
                ResultSet rs = checkCatStmt.executeQuery();
                if (!rs.next()) {
                    throw new SQLException("Invalid category selected");
                }
            }
    
            // 2. Try to update budget first (will fail if doesn't exist)
            String updateBudgetSql = "UPDATE budgets SET current_spending = current_spending + ? " +
                                   "WHERE user_id = ? AND category_id = ?";
            try (PreparedStatement updateStmt = conn.prepareStatement(updateBudgetSql)) {
                updateStmt.setDouble(1, amount);
                updateStmt.setInt(2, userId);
                updateStmt.setInt(3, categoryId);
                int updated = updateStmt.executeUpdate();
                
                if (updated == 0) {
                    // Budget doesn't exist, create one with default values
                    String categoryName = "";
                    String getNameSql = "SELECT name FROM categories WHERE id = ?";
                    try (PreparedStatement getNameStmt = conn.prepareStatement(getNameSql)) {
                        getNameStmt.setInt(1, categoryId);
                        ResultSet rs = getNameStmt.executeQuery();
                        if (rs.next()) {
                            categoryName = rs.getString("name");
                        }
                    }
                    
                    String insertBudgetSql = "INSERT INTO budgets (user_id, category_id, category, budget_amount, current_spending) " +
                                           "VALUES (?, ?, ?, ?, ?)";
                    try (PreparedStatement insertStmt = conn.prepareStatement(insertBudgetSql)) {
                        insertStmt.setInt(1, userId);
                        insertStmt.setInt(2, categoryId);
                        insertStmt.setString(3, categoryName);
                        insertStmt.setDouble(4, amount * 2); // Default budget is 2x the expense
                        insertStmt.setDouble(5, amount);
                        
                        if (insertStmt.executeUpdate() == 0) {
                            throw new SQLException("Failed to create budget for this category");
                        }
                    }
                }
            }
            
            // 3. Insert the expense record
            String insertExpenseSql = "INSERT INTO expenses (user_id, category_id, amount, description) " +
                                    "VALUES (?, ?, ?, ?)";
            try (PreparedStatement insertStmt = conn.prepareStatement(insertExpenseSql)) {
                insertStmt.setInt(1, userId);
                insertStmt.setInt(2, categoryId);
                insertStmt.setDouble(3, amount);
                insertStmt.setString(4, description);
                
                if (insertStmt.executeUpdate() == 0) {
                    throw new SQLException("Failed to insert expense record.");
                }
            }
            
            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    logger.log(Level.SEVERE, "Error during rollback", ex);
                }
            }
            String friendly = getFriendlySqlError(e);
            if (friendly != null) throw new SQLException(friendly, e);
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    logger.log(Level.SEVERE, "Error closing connection", e);
                }
            }
        }
    }

    // Income-related methods
    public static boolean addIncome(int userId, double amount, String source) {
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "INSERT INTO income_sources (user_id, amount, source_name) VALUES (?, ?, ?)")) {
            
            stmt.setInt(1, userId);
            stmt.setDouble(2, amount);
            stmt.setString(3, source);
            
            boolean success = stmt.executeUpdate() > 0;
            
            if (success) {
                // Recalculate and update income level after adding income
                double totalIncome = getTotalIncome(userId);
                String newIncomeLevel = determineIncomeLevel(totalIncome);
                updateUserIncomeLevel(userId, newIncomeLevel);
            }
            
            return success;
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
            
            boolean success = stmt.executeUpdate() > 0;

            if (success) {
                // Get the user ID for the updated income
                int userId = -1;
                String getUserIdSql = "SELECT user_id FROM income_sources WHERE id = ?";
                try (PreparedStatement getUserIdStmt = conn.prepareStatement(getUserIdSql)) {
                    getUserIdStmt.setInt(1, id);
                    ResultSet rs = getUserIdStmt.executeQuery();
                    if (rs.next()) {
                        userId = rs.getInt("user_id");
                    }
                }

                if (userId != -1) {
                    // Recalculate and update income level after updating income
                    double totalIncome = getTotalIncome(userId);
                    String newIncomeLevel = determineIncomeLevel(totalIncome);
                    updateUserIncomeLevel(userId, newIncomeLevel);
                }
            }

            return success;
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

    public static List<Income> getIncomesByMonth(int userId, int year, int month) {
        List<Income> incomes = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "SELECT id, amount, source_name FROM income_sources " +
                 "WHERE user_id = ? AND created_at <= (MAKE_DATE(?, ?, 1) + interval '1 month' - interval '1 day') " +
                 "ORDER BY created_at DESC")) {

            stmt.setInt(1, userId);
            stmt.setInt(2, year);
            stmt.setInt(3, month);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                incomes.add(new Income(
                    rs.getInt("id"),
                    rs.getDouble("amount"),
                    rs.getString("source_name")
                ));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching incomes for user up to selected month using PostgreSQL date functions: " + userId, e);
        }
        return incomes;
    }

    public static List<Income> getIncomesOnOrAfterDate(int userId, java.util.Date date) {
        List<Income> incomes = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "SELECT id, amount, source_name FROM income_sources " +
                 "WHERE user_id = ? AND created_at >= ? ORDER BY created_at DESC")) {

            stmt.setInt(1, userId);
            stmt.setDate(2, new java.sql.Date(date.getTime()));
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                incomes.add(new Income(
                    rs.getInt("id"),
                    rs.getDouble("amount"),
                    rs.getString("source_name")
                ));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching incomes for user on or after date: " + userId, e);
        }
        return incomes;
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

    public static boolean addCategory(int userId, String categoryName) throws SQLException {
        try (Connection conn = getConnection()) {
            String sql = "INSERT INTO categories (user_id, name) VALUES (?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                stmt.setString(2, categoryName);
                return stmt.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            if (e.getSQLState().equals("23505")) { // Unique violation
                throw new SQLException("A category with this name already exists.", e);
            } else {
                logger.log(Level.SEVERE, "Error adding category for user: " + userId, e);
                throw e;
            }
        }
    }

    public static boolean updateCategoryName(int categoryId, String newName) throws SQLException {
        try (Connection conn = getConnection()) {
            String sql = "UPDATE categories SET name = ? WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, newName);
                stmt.setInt(2, categoryId);
                return stmt.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            if (e.getSQLState().equals("23505")) { // Unique violation
                throw new SQLException("A category with this name already exists.", e);
            } else {
                logger.log(Level.SEVERE, "Error updating category ID: " + categoryId, e);
                throw e;
            }
        }
    }

    public static boolean deleteCategory(int categoryId) throws SQLException {
        try (Connection conn = getConnection()) {
            String sql = "DELETE FROM categories WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, categoryId);
                return stmt.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            if (e.getSQLState().equals("23503")) { // Foreign key violation
                throw new SQLException("This category is in use and cannot be deleted.", e);
            } else {
                logger.log(Level.SEVERE, "Error deleting category ID: " + categoryId, e);
                throw e;
            }
        }
    }

    public static Map<String, Double> getMonthlyIncome(int userId) {
        Map<String, Double> monthlyIncome = new LinkedHashMap<>();
        
        // Initialize with all months at 0.0
        String[] allMonths = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
        for (String month : allMonths) {
            monthlyIncome.put(month, 0.0);
        }
        
        try (Connection conn = getConnection()) {
            String sql = "SELECT TO_CHAR(created_at, 'Mon') AS month, " +
                        "COALESCE(SUM(amount), 0) AS total " +
                        "FROM income_sources " +
                        "WHERE user_id = ? " +
                        "AND created_at >= DATE_TRUNC('year', CURRENT_DATE) " +
                        "GROUP BY TO_CHAR(created_at, 'Mon'), EXTRACT(MONTH FROM created_at) " +
                        "ORDER BY EXTRACT(MONTH FROM created_at)";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                ResultSet rs = stmt.executeQuery();
                
                while (rs.next()) {
                    String month = rs.getString("month");
                    double total = rs.getDouble("total");
                    monthlyIncome.put(month, total);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching monthly income", e);
        }
        
        return monthlyIncome;
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

    public static List<Budget> getBudgets(int userId) {
        List<Budget> budgets = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "SELECT id, category_id, category, budget_amount, current_spending, " +
                 "created_at, updated_at, budget_type, period_start FROM budgets WHERE user_id = ? ORDER BY created_at DESC")) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                Budget budget = new Budget();
                budget.setId(rs.getInt("id"));
                budget.setUserId(userId);
                budget.setCategoryId(rs.getInt("category_id"));
                budget.setCategory(rs.getString("category"));
                budget.setBudgetAmount(rs.getDouble("budget_amount"));
                budget.setCurrentSpending(rs.getDouble("current_spending"));
                budget.setCreatedAt(rs.getString("created_at"));
                budget.setUpdatedAt(rs.getString("updated_at"));
                budget.setBudgetType(rs.getString("budget_type"));
                budget.setPeriodStart(rs.getString("period_start"));
                budgets.add(budget);
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching budgets", e);
        }
        return budgets;
    }

    public static boolean updateBudget(int id, int categoryId, double budgetAmount, double currentSpending, String budgetType, String periodStart) {
        try (Connection conn = getConnection()) {
            // Get category name
            String categoryName = "";
            String getNameSql = "SELECT name FROM categories WHERE id = ?";
            try (PreparedStatement getNameStmt = conn.prepareStatement(getNameSql)) {
                getNameStmt.setInt(1, categoryId);
                ResultSet rs = getNameStmt.executeQuery();
                if (rs.next()) {
                    categoryName = rs.getString("name");
                } else {
                    return false; // Category not found
                }
            }

            // Update budget
            String updateSql = "UPDATE budgets SET category_id = ?, category = ?, " +
                             "budget_amount = ?, current_spending = ?, updated_at = CURRENT_TIMESTAMP, budget_type = ?, period_start = ? " +
                             "WHERE id = ?";
            try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                updateStmt.setInt(1, categoryId);
                updateStmt.setString(2, categoryName);
                updateStmt.setDouble(3, budgetAmount);
                updateStmt.setDouble(4, currentSpending);
                updateStmt.setString(5, budgetType);
                updateStmt.setDate(6, java.sql.Date.valueOf(periodStart));
                updateStmt.setInt(7, id);
                
                return updateStmt.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            String friendly = getFriendlySqlError(e);
            if (friendly != null) {
                logger.log(Level.WARNING, friendly);
            } else {
                logger.log(Level.SEVERE, "Error updating budget", e);
            }
            return false;
        }
    }

    public static boolean addBudget(int userId, int categoryId, double budgetAmount, double currentSpending, String budgetType, String periodStart) {
        try (Connection conn = getConnection()) {
            // First get the category name
            String categoryName = "";
            String getNameSql = "SELECT name FROM categories WHERE id = ?";
            try (PreparedStatement getNameStmt = conn.prepareStatement(getNameSql)) {
                getNameStmt.setInt(1, categoryId);
                ResultSet rs = getNameStmt.executeQuery();
                if (rs.next()) {
                    categoryName = rs.getString("name");
                } else {
                    return false; // Category not found
                }
            }

            // Then insert the budget
            String insertSql = "INSERT INTO budgets (user_id, category_id, category, budget_amount, current_spending, budget_type, period_start) " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                insertStmt.setInt(1, userId);
                insertStmt.setInt(2, categoryId);
                insertStmt.setString(3, categoryName);
                insertStmt.setDouble(4, budgetAmount);
                insertStmt.setDouble(5, currentSpending);
                insertStmt.setString(6, budgetType);
                insertStmt.setDate(7, java.sql.Date.valueOf(periodStart));
                
                return insertStmt.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            String friendly = getFriendlySqlError(e);
            if (friendly != null) {
                logger.log(Level.WARNING, friendly);
            } else {
                logger.log(Level.SEVERE, "Error adding budget", e);
            }
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
            logger.log(Level.SEVERE, "Error deleting budget", e);
            return false;
        }
    }

    public static boolean addSavingGoal(int userId, String title, String description, 
                                      double targetAmount, Date targetDate, double currentAmount) {
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "INSERT INTO savings_goals (user_id, title, description, target_amount, " +
                 "target_date, current_amount) VALUES (?, ?, ?, ?, ?, ?)")) {
            
            stmt.setInt(1, userId);
            stmt.setString(2, title);
            stmt.setString(3, description);
            stmt.setDouble(4, targetAmount);
            stmt.setDate(5, targetDate);
            stmt.setDouble(6, currentAmount);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            String friendly = getFriendlySqlError(e);
            if (friendly != null) {
                logger.log(Level.WARNING, friendly);
            } else {
                logger.log(Level.SEVERE, "Error adding saving goal", e);
            }
            return false;
        }
    }

    public static boolean updateSavingGoal(int id, String title, String description, 
                                         double targetAmount, Date targetDate, double currentAmount) {
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "UPDATE savings_goals SET title = ?, description = ?, target_amount = ?, " +
                 "target_date = ?, current_amount = ? WHERE id = ?")) {
            
            stmt.setString(1, title);
            stmt.setString(2, description);
            stmt.setDouble(3, targetAmount);
            stmt.setDate(4, targetDate);
            stmt.setDouble(5, currentAmount);
            stmt.setInt(6, id);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating saving goal", e);
            return false;
        }
    }

    public static List<SavingGoal> getSavingGoals(int userId) {
        List<SavingGoal> goals = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "SELECT id, title, description, target_amount, target_date, " +
                 "current_amount, achieved FROM savings_goals WHERE user_id = ?")) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                goals.add(new SavingGoal(
                    rs.getInt("id"),
                    rs.getString("title"),
                    rs.getString("description"),
                    rs.getDouble("target_amount"),
                    rs.getDouble("current_amount"),
                    rs.getDate("target_date"),
                    rs.getBoolean("achieved")
                ));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching saving goals", e);
        }
        return goals;
    }

    public static Map<String, Double> getAverageBudgetsByCategory() {
        Map<String, Double> averages = new HashMap<>();
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT category, AVG(budget_amount) as avg_amount " +
                                             "FROM budgets " +
                                             "GROUP BY category")) {
            while (rs.next()) {
                averages.put(rs.getString("category"), rs.getDouble("avg_amount"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return averages;
    }

    public static boolean isAdmin(int userId) {
        try (Connection conn = getConnection()) {
            String sql = "SELECT isadmin FROM users WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    return rs.getBoolean(1);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking admin status", e);
        }
        return false;
    }

    public static List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        try (Connection conn = getConnection()) {
            String sql = "SELECT id, username, email, income_level FROM users";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    users.add(new User(
                        rs.getInt("id"),
                        rs.getString("username"),
                        rs.getString("email"),
                        rs.getString("income_level")
                    ));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching users", e);
        }
        return users;
    }

    public static double getCurrentMonthIncome(int userId) {
        double totalIncome = 0;
        try (Connection conn = getConnection()) {
            String sql = "SELECT COALESCE(SUM(amount), 0) FROM income_sources " +
                        "WHERE user_id = ? AND EXTRACT(MONTH FROM created_at) = EXTRACT(MONTH FROM CURRENT_DATE)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    totalIncome = rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error calculating current month income", e);
        }
        return totalIncome;
    }

    public static List<Map<String, Object>> getAllCategories() {
        List<Map<String, Object>> categories = new ArrayList<>();
        try (Connection conn = getConnection()) {
            String sql = "SELECT id, name FROM categories";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    Map<String, Object> category = new HashMap<>();
                    category.put("id", rs.getInt("id"));
                    category.put("name", rs.getString("name"));
                    categories.add(category);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching categories", e);
        }
        return categories;
    }

    public static List<Map<String, Object>> getAllIncomeSources(int userId) {
        List<Map<String, Object>> incomeSources = new ArrayList<>();
        try (Connection conn = getConnection()) {
            String sql = "SELECT id, source_name, amount, created_at FROM income_sources WHERE user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    Map<String, Object> income = new HashMap<>();
                    income.put("id", rs.getInt("id"));
                    income.put("source", rs.getString("source_name"));
                    income.put("amount", rs.getDouble("amount"));
                    income.put("date", rs.getDate("created_at"));
                    incomeSources.add(income);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching income sources", e);
        }
        return incomeSources;
    }

    public static List<Category> getCategories() {
        List<Category> categories = new ArrayList<>();
        try (Connection conn = getConnection()) {
            String sql = "SELECT id, name FROM categories";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    categories.add(new Category(
                        rs.getInt("id"),
                        rs.getString("name"),
                        0 // No user_id needed
                    ));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching categories", e);
        }
        return categories;
    }

    public static boolean addCategory(String categoryName) {
        try (Connection conn = getConnection()) {
            String sql = "INSERT INTO categories (name) VALUES (?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, categoryName);
                return stmt.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            String friendly = getFriendlySqlError(e);
            if (friendly != null) {
                logger.log(Level.WARNING, friendly);
            } else {
                logger.log(Level.SEVERE, "Error adding category", e);
            }
            return false;
        }
    }

    public static List<Map<String, Object>> getAllBudgets(int userId, int year, int month) {
        List<Map<String, Object>> budgets = new ArrayList<>();
        try (Connection conn = getConnection()) {
            String sql = "SELECT id, category, budget_amount, current_spending, created_at, updated_at, budget_type, period_start FROM budgets WHERE user_id = ? AND created_at <= (MAKE_DATE(?, ?, 1) + interval '1 month' - interval '1 day')";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                stmt.setInt(2, year);
                stmt.setInt(3, month);
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    Map<String, Object> budget = new HashMap<>();
                    budget.put("id", rs.getInt("id"));
                    budget.put("category", rs.getString("category"));
                    budget.put("budget_amount", rs.getDouble("budget_amount"));
                    budget.put("current_spending", rs.getDouble("current_spending"));
                    budget.put("created_at", rs.getDate("created_at"));
                    budget.put("updated_at", rs.getDate("updated_at"));
                    budget.put("budget_type", rs.getString("budget_type"));
                    budget.put("period_start", rs.getDate("period_start"));
                    budgets.add(budget);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching budgets up to selected month: " + e.getMessage(), e);
        }
        return budgets;
    }

    public static List<Map<String, Object>> getAllSavingsGoals(int userId, int year, int month) {
        List<Map<String, Object>> goals = new ArrayList<>();
        try (Connection conn = getConnection()) {
            String sql = "SELECT id, title, target_amount, current_amount, target_date, " +
                        "achieved, description, created_at FROM savings_goals WHERE user_id = ? AND created_at <= (MAKE_DATE(?, ?, 1) + interval '1 month' - interval '1 day') ";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                stmt.setInt(2, year);
                stmt.setInt(3, month);
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    Map<String, Object> goal = new HashMap<>();
                    goal.put("id", rs.getInt("id"));
                    goal.put("title", rs.getString("title"));
                    goal.put("target_amount", rs.getDouble("target_amount"));
                    goal.put("current_amount", rs.getDouble("current_amount"));
                    goal.put("target_date", rs.getDate("target_date"));
                    goal.put("achieved", rs.getBoolean("achieved"));
                    goal.put("description", rs.getString("description"));
                    goal.put("created_at", rs.getDate("created_at"));
                    goals.add(goal);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching savings goals up to selected month: " + e.getMessage(), e);
        }
        return goals;
    }

    public static Map<String, Object> getMonthlyReport(int userId, int year, int month) {
        Map<String, Object> report = new HashMap<>();
        List<Map<String, Object>> categories = new ArrayList<>(); // Initialize empty list
        report.put("categories", categories);
        report.put("total_income", 0.0);
        report.put("total_expenses", 0.0);
        report.put("total_savings", 0.0);
        report.put("transaction_count", 0);
        
        try (Connection conn = getConnection()) {
            // Get income data
            String incomeSql = "SELECT COALESCE(SUM(amount), 0) AS total_income " +
                             "FROM income_sources " +
                             "WHERE user_id = ? AND EXTRACT(YEAR FROM created_at) = ? " +
                             "AND EXTRACT(MONTH FROM created_at) = ?";
            try (PreparedStatement stmt = conn.prepareStatement(incomeSql)) {
                stmt.setInt(1, userId);
                stmt.setInt(2, year);
                stmt.setInt(3, month);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    report.put("total_income", rs.getDouble("total_income"));
                }
            }

            // Get expense data by category
            String expenseSql = "SELECT c.name AS category, SUM(b.current_spending) AS amount " +
                              "FROM budgets b " +
                              "JOIN categories c ON b.category_id = c.id " +
                              "WHERE b.user_id = ? AND EXTRACT(YEAR FROM b.created_at) = ? " +
                              "AND EXTRACT(MONTH FROM b.created_at) = ? " +
                              "GROUP BY c.name " +
                              "ORDER BY amount DESC";
            try (PreparedStatement stmt = conn.prepareStatement(expenseSql)) {
                stmt.setInt(1, userId);
                stmt.setInt(2, year);
                stmt.setInt(3, month);
                ResultSet rs = stmt.executeQuery();
                double totalExpenses = 0;
                while (rs.next()) {
                    Map<String, Object> category = new HashMap<>();
                    category.put("name", rs.getString("category"));
                    double amount = rs.getDouble("amount");
                    category.put("amount", amount);
                    categories.add(category);
                    totalExpenses += amount;
                }
                report.put("total_expenses", totalExpenses);
                
                // Calculate percentages
                for (Map<String, Object> category : categories) {
                    double amount = (Double) category.get("amount");
                    double percentage = totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0;
                    category.put("percentage", percentage);
                }
            }

            // Get savings data
            String savingsSql = "SELECT COALESCE(SUM(current_amount), 0) AS total_savings " +
                              "FROM savings_goals " +
                              "WHERE user_id = ? AND EXTRACT(YEAR FROM created_at) = ? " +
                              "AND EXTRACT(MONTH FROM created_at) = ?";
            try (PreparedStatement stmt = conn.prepareStatement(savingsSql)) {
                stmt.setInt(1, userId);
                stmt.setInt(2, year);
                stmt.setInt(3, month);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    report.put("total_savings", rs.getDouble("total_savings"));
                }
            }

            // Get transaction count
            String countSql = "SELECT COUNT(*) AS transaction_count " +
                             "FROM budgets " +
                             "WHERE user_id = ? AND EXTRACT(YEAR FROM created_at) = ? " +
                             "AND EXTRACT(MONTH FROM created_at) = ?";
            try (PreparedStatement stmt = conn.prepareStatement(countSql)) {
                stmt.setInt(1, userId);
                stmt.setInt(2, year);
                stmt.setInt(3, month);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    report.put("transaction_count", rs.getInt("transaction_count"));
                }
            }

        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error generating monthly report", e);
        }
        return report;
    }

    public static double getCurrentMonthExpenses(int userId) {
        double totalExpenses = 0;
        try (Connection conn = getConnection()) {
            String sql = "SELECT COALESCE(SUM(amount), 0) FROM expenses " +
                        "WHERE user_id = ? AND EXTRACT(MONTH FROM created_at) = EXTRACT(MONTH FROM CURRENT_DATE)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    totalExpenses = rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error calculating current month expenses", e);
        }
        return totalExpenses;
    }

    public static Map<String, Double> getMonthlyExpenses(int userId) {
        Map<String, Double> monthlyExpenses = new LinkedHashMap<>();
        try (Connection conn = getConnection()) {
            String sql = "SELECT TO_CHAR(created_at, 'Mon') AS month, " +
                        "COALESCE(SUM(amount), 0) AS total " +
                        "FROM expenses " +
                        "WHERE user_id = ? " +
                        "AND created_at >= DATE_TRUNC('year', CURRENT_DATE) " +
                        "GROUP BY month " +
                        "ORDER BY MIN(created_at)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                ResultSet rs = stmt.executeQuery();
                while (rs.next()) {
                    monthlyExpenses.put(rs.getString("month"), rs.getDouble("total"));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching monthly expenses", e);
        }
        return monthlyExpenses;
    }

    public static double getTotalSavingsProgress(int userId) {
        double totalProgress = 0;
        try (Connection conn = getConnection()) {
            String sql = "SELECT COALESCE(SUM(current_amount), 0) FROM savings_goals WHERE user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    totalProgress = rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error calculating savings progress", e);
        }
        return totalProgress;
    }

    public static boolean updateExpense(int expenseId, int categoryId, double amount, String description) {
        try (Connection conn = getConnection()) {
            // First get the old expense to adjust the budget
            Expense oldExpense = getExpenseById(expenseId);
            if (oldExpense == null) return false;
            
            // Adjust the old budget
            String adjustBudgetSql = "UPDATE budgets SET current_spending = current_spending - ? " +
                                   "WHERE user_id = ? AND category_id = ?";
            try (PreparedStatement adjustStmt = conn.prepareStatement(adjustBudgetSql)) {
                adjustStmt.setDouble(1, oldExpense.getAmount());
                adjustStmt.setInt(2, oldExpense.getUserId());
                adjustStmt.setInt(3, oldExpense.getCategoryId());
                adjustStmt.executeUpdate();
            }
            
            // Update the new budget
            String updateBudgetSql = "UPDATE budgets SET current_spending = current_spending + ? " +
                                   "WHERE user_id = ? AND category_id = ?";
            try (PreparedStatement updateStmt = conn.prepareStatement(updateBudgetSql)) {
                updateStmt.setDouble(1, amount);
                updateStmt.setInt(2, oldExpense.getUserId());
                updateStmt.setInt(3, categoryId);
                updateStmt.executeUpdate();
            }
            
            // Update the expense
            String updateExpenseSql = "UPDATE expenses SET category_id = ?, amount = ?, description = ? " +
                                    "WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateExpenseSql)) {
                stmt.setInt(1, categoryId);
                stmt.setDouble(2, amount);
                stmt.setString(3, description);
                stmt.setInt(4, expenseId);
                
                return stmt.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating expense", e);
            return false;
        }
    }

    public static boolean deleteExpense(int expenseId) {
        try (Connection conn = getConnection()) {
            // First get the expense to adjust the budget
            Expense expense = getExpenseById(expenseId);
            if (expense == null) return false;
            
            // Adjust the budget
            String adjustBudgetSql = "UPDATE budgets SET current_spending = current_spending - ? " +
                                   "WHERE user_id = ? AND category_id = ?";
            try (PreparedStatement adjustStmt = conn.prepareStatement(adjustBudgetSql)) {
                adjustStmt.setDouble(1, expense.getAmount());
                adjustStmt.setInt(2, expense.getUserId());
                adjustStmt.setInt(3, expense.getCategoryId());
                adjustStmt.executeUpdate();
            }
            
            // Delete the expense
            String deleteExpenseSql = "DELETE FROM expenses WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(deleteExpenseSql)) {
                stmt.setInt(1, expenseId);
                return stmt.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting expense", e);
            return false;
        }
    }

    public static Expense getExpenseById(int expenseId) {
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "SELECT e.id, e.user_id, e.category_id, c.name as category_name, " +
                 "e.amount, e.description, e.created_at, b.budget_amount " +
                 "FROM expenses e " +
                 "JOIN categories c ON e.category_id = c.id " +
                 "LEFT JOIN budgets b ON e.user_id = b.user_id AND e.category_id = b.category_id " +
                 "WHERE e.id = ?")) {
            
            stmt.setInt(1, expenseId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return new Expense(
                    rs.getInt("id"),
                    rs.getInt("user_id"),
                    rs.getInt("category_id"),
                    rs.getString("category_name"),
                    rs.getDouble("amount"),
                    rs.getString("description"),
                    rs.getDate("created_at"),
                    rs.getDouble("budget_amount")
                );
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching expense by ID", e);
        }
        return null;
    }

    public static List<Expense> getExpenses(int userId) {
        List<Expense> expenses = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "SELECT e.id, e.user_id, e.category_id, c.name as category_name, " +
                 "e.amount, e.description, e.created_at, b.budget_amount " +
                 "FROM expenses e " +
                 "JOIN categories c ON e.category_id = c.id " +
                 "LEFT JOIN budgets b ON e.user_id = b.user_id AND e.category_id = b.category_id " +
                 "WHERE e.user_id = ? ORDER BY e.created_at DESC")) {
            
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                expenses.add(new Expense(
                    rs.getInt("id"),
                    rs.getInt("user_id"),
                    rs.getInt("category_id"),
                    rs.getString("category_name"),
                    rs.getDouble("amount"),
                    rs.getString("description"),
                    rs.getDate("created_at"),
                    rs.getDouble("budget_amount")
                ));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error fetching expenses", e);
        }
        return expenses;
    }

    public static boolean hasBudgetForCategory(int userId, int categoryId) {
        try (Connection conn = getConnection()) {
            String sql = "SELECT COUNT(*) FROM budgets WHERE user_id = ? AND category_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, userId);
                stmt.setInt(2, categoryId);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking budget for category", e);
        }
        return false;
    }

    public static boolean deleteSavingGoal(int id) {
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                 "DELETE FROM savings_goals WHERE id = ?")) {
            
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error deleting saving goal ID: " + id, e);
            return false;
        }
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

    // Methods for income level based averages
    public static double getAverageBudgetByIncomeLevel(String incomeLevel, int year, int month) {
        double averageBudget = 0;
        try (Connection conn = getConnection()) {
            String sql = "SELECT COALESCE(AVG(b.budget_amount), 0) FROM budgets b " +
                         "JOIN users u ON b.user_id = u.id " +
                         "WHERE u.income_level = ? AND EXTRACT(YEAR FROM b.created_at) = ? " +
                         "AND EXTRACT(MONTH FROM b.created_at) = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, incomeLevel);
                stmt.setInt(2, year);
                stmt.setInt(3, month);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    averageBudget = rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error calculating average budget for income level: " + incomeLevel, e);
        }
        return averageBudget;
    }

    public static double getAverageIncomeByIncomeLevel(String incomeLevel, int year, int month) {
        double averageIncome = 0;
        try (Connection conn = getConnection()) {
            String sql = "SELECT COALESCE(AVG(i.amount), 0) FROM income_sources i " +
                         "JOIN users u ON i.user_id = u.id " +
                         "WHERE u.income_level = ? AND EXTRACT(YEAR FROM i.created_at) = ? " +
                         "AND EXTRACT(MONTH FROM i.created_at) = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, incomeLevel);
                stmt.setInt(2, year);
                stmt.setInt(3, month);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    averageIncome = rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error calculating average income for income level: " + incomeLevel, e);
        }
        return averageIncome;
    }

    // New method to update user's income level
    public static boolean updateUserIncomeLevel(int userId, String incomeLevel) {
        try (Connection conn = getConnection()) {
            String sql = "UPDATE users SET income_level = ? WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, incomeLevel);
                stmt.setInt(2, userId);
                return stmt.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error updating income level for user: " + userId, e);
            return false;
        }
    }
}