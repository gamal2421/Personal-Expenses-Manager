package javawork.personalexp.models;

import java.util.Date;

public class Budget {
    private int id;
    private int categoryId;
    private String categoryName; // New field
    private double amount;
    private Date startDate;
    private Date endDate;
    private int userId;

    // Constructor with categoryName
    public Budget(int id, String categoryName, double amount, Date startDate, Date endDate) {
        this.id = id;
        this.categoryName = categoryName;
        this.amount = amount;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    // Full constructor
    public Budget(int id, int categoryId, double amount, Date startDate, Date endDate, int userId) {
        this.id = id;
        this.categoryId = categoryId;
        this.amount = amount;
        this.startDate = startDate;
        this.endDate = endDate;
        this.userId = userId;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    @Override
    public String toString() {
        return "Budget{" +
                "id=" + id +
                ", categoryName='" + categoryName + '\'' +
                ", amount=" + amount +
                ", startDate=" + startDate +
                ", endDate=" + endDate +
                '}';
    }
}
