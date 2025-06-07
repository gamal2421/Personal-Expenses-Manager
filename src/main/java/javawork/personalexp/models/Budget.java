package javawork.personalexp.models;

public class Budget {
    private int id;
    private int userId;
    private int categoryId;
    private String category;
    private double budgetAmount;
    private double currentSpending;
    private String createdAt;
    private String updatedAt;
    private String budgetType; // 'monthly', 'yearly', 'midyear'
    private String periodStart; // e.g., '2024-06-01'

    // Constructors
    public Budget() {}

    public Budget(int id, String category, double budgetAmount, double currentSpending) {
        this.id = id;
        this.category = category;
        this.budgetAmount = budgetAmount;
        this.currentSpending = currentSpending;
    }

    public Budget(int id, int userId, int categoryId, String category, double budgetAmount, double currentSpending, String createdAt, String updatedAt, String budgetType, String periodStart) {
        this.id = id;
        this.userId = userId;
        this.categoryId = categoryId;
        this.category = category;
        this.budgetAmount = budgetAmount;
        this.currentSpending = currentSpending;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.budgetType = budgetType;
        this.periodStart = periodStart;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public double getBudgetAmount() {
        return budgetAmount;
    }

    public void setBudgetAmount(double budgetAmount) {
        this.budgetAmount = budgetAmount;
    }

    public double getCurrentSpending() {
        return currentSpending;
    }

    public void setCurrentSpending(double currentSpending) {
        this.currentSpending = currentSpending;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getBudgetType() {
        return budgetType;
    }

    public void setBudgetType(String budgetType) {
        this.budgetType = budgetType;
    }

    public String getPeriodStart() {
        return periodStart;
    }

    public void setPeriodStart(String periodStart) {
        this.periodStart = periodStart;
    }
}