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
import javawork.personalexp.models.Income;
import javawork.personalexp.models.SavingGoal;
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
    public static Budget getBudgetById(int id) throws SQLException {
        Budget budget = null;
        try (Connection conn = getConnection()) {
            String sql = "SELECT id, user_id, category, budget_amount, current_spending FROM budgets WHERE id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, id);
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    budget = new Budget(
                        rs.getInt("id"),
                        rs.getString("category"),
                        rs.getDouble("budget_amount"),
                        rs.getDouble("current_spending")
                    );
                    // Assuming you add userId to your Budget model
                    budget.setUserId(rs.getInt("user_id"));
                }
            }
        }
        return budget;
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
        logger.log(Level.SEVERE, "Error adding budget for user: " + userId, e);
        return false;
    }
}

public static boolean updateBudget(int id, String category, double budgetAmount, double currentSpending) {
    try (Connection conn = getConnection();
         PreparedStatement stmt = conn.prepareStatement(
             "UPDATE budgets SET category = ?, budget_amount = ?, current_spending = ? WHERE id = ?")) {
        
        stmt.setString(1, category);
        stmt.setDouble(2, budgetAmount);
        stmt.setDouble(3, currentSpending);
        stmt.setInt(4, id);
        
        return stmt.executeUpdate() > 0;
    } catch (SQLException e) {
        logger.log(Level.SEVERE, "Error updating budget ID: " + id, e);
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
        logger.log(Level.SEVERE, "Error deleting budget ID: " + id, e);
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
                rs.getDouble("budget_amount"),  // Fixed typo from "budget_amount" to match your table
                rs.getDouble("current_spending")
            ));
        }
    } catch (SQLException e) {
        logger.log(Level.SEVERE, "Error fetching budgets for user: " + userId, e);
    }
    return budgets;
}

// Add this to your Database class
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
        logger.log(Level.SEVERE, "Error adding saving goal", e);
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
        String sql = "SELECT id, username, email FROM users";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                users.add(new User(
                    rs.getInt("id"),
                    rs.getString("username"),
                    rs.getString("email")
                ));
            }
        }
    } catch (SQLException e) {
        logger.log(Level.SEVERE, "Error fetching users", e);
    }
    return users;
}


// Add these methods to your Database class

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



// Add these methods to your Database class

public static List<Map<String, Object>> getAllCategories(int userId) {
    List<Map<String, Object>> categories = new ArrayList<>();
    try (Connection conn = getConnection()) {
        String sql = "SELECT id, name FROM categories WHERE user_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
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



// Get categories - now returns all categories since they're global
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

// Add category - no user_id needed
public static boolean addCategory(String categoryName) {
    try (Connection conn = getConnection()) {
        String sql = "INSERT INTO categories (name) VALUES (?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, categoryName);
            return stmt.executeUpdate() > 0;
        }
    } catch (SQLException e) {
        logger.log(Level.SEVERE, "Error adding category", e);
        return false;
    }
}

public static List<Map<String, Object>> getAllBudgets(int userId) {
    List<Map<String, Object>> budgets = new ArrayList<>();
    try (Connection conn = getConnection()) {
        String sql = "SELECT id, category, budget_amount, current_spending, " +
                    "created_at, updated_at FROM budgets WHERE user_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Map<String, Object> budget = new HashMap<>();
                budget.put("id", rs.getInt("id"));
                budget.put("category", rs.getString("category")); // Direct string category
                budget.put("budget_amount", rs.getDouble("budget_amount"));
                budget.put("current_spending", rs.getDouble("current_spending"));
                budget.put("created_at", rs.getDate("created_at"));
                budget.put("updated_at", rs.getDate("updated_at"));
                budgets.add(budget);
            }
        }
    } catch (SQLException e) {
        logger.log(Level.SEVERE, "Error fetching budgets", e);
    }
    return budgets;
}


public static List<Map<String, Object>> getAllSavingsGoals(int userId) {
    List<Map<String, Object>> goals = new ArrayList<>();
    try (Connection conn = getConnection()) {
        String sql = "SELECT id, title, target_amount, current_amount, target_date, " +
                    "achieved, description, created_at FROM savings_goals WHERE user_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
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
        logger.log(Level.SEVERE, "Error fetching savings goals", e);
    }
    return goals;
}
// Add these methods to your Database class

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
// Add these methods to your Database class

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

public static Map<String, Double> getMonthlyIncome(int userId) {
    Map<String, Double> monthlyIncome = new LinkedHashMap<>();
    try (Connection conn = getConnection()) {
        String sql = "SELECT TO_CHAR(created_at, 'Mon') AS month, " +
                    "COALESCE(SUM(amount), 0) AS total " +
                    "FROM income_sources " +
                    "WHERE user_id = ? " +
                    "AND created_at >= DATE_TRUNC('year', CURRENT_DATE) " +
                    "GROUP BY month " +
                    "ORDER BY MIN(created_at)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                monthlyIncome.put(rs.getString("month"), rs.getDouble("total"));
            }
        }
    } catch (SQLException e) {
        logger.log(Level.SEVERE, "Error fetching monthly income", e);
    }
    return monthlyIncome;
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

// Add this method to your Database class
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
}