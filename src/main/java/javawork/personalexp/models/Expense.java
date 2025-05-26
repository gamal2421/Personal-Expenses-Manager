package javawork.personalexp.models;

import java.sql.Date;

public class Expense {
    private int id;
    private int userId;
    private int categoryId;
    private String categoryName;
    private double amount;
    private String description;
    private Date date;
    private double budgetAmount;
    
    // Constructors, getters, and setters
    public Expense() {}
    
    public Expense(int id, int userId, int categoryId, String categoryName, 
                  double amount, String description, Date date, double budgetAmount) {
        this.id = id;
        this.userId = userId;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.amount = amount;
        this.description = description;
        this.date = date;
        this.budgetAmount = budgetAmount;
    }
    public void setAmount(double amount) {
        this.amount = amount;
    }
    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }public void setDate(Date date) {
        this.date = date;
    }public void setDescription(String description) {
        this.description = description;
    } public void setId(int id) {
        this.id = id;
    }public void setUserId(int userId) {
        this.userId = userId;
    }
    public double getAmount() {
        return amount;
    }public int getCategoryId() {
        return categoryId;
    }public String getCategoryName() {
        return categoryName;
    }public Date getDate() {
        return date;
    }public String getDescription() {
        return description;
    }public int getId() {
        return id;
    }public int getUserId() {
        return userId;
    }
    public double getBudgetAmount() {
        return budgetAmount;
    }
    public void setBudgetAmount(double budgetAmount) {
        this.budgetAmount = budgetAmount;
    }
    // Getters and setters for all fields
    // ...
}