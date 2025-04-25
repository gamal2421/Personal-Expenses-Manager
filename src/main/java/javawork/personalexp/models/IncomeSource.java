package javawork.personalexp.models;

import java.util.Date;

public class IncomeSource {
    private int id;
    private String sourceName;
    private double amount;
    private Date date;
    private int userId;

    // Constructor
    public IncomeSource(int id, String sourceName, double amount, Date date, int userId) {
        this.id = id;
        this.sourceName = sourceName;
        this.amount = amount;
        this.date = date;
        this.userId = userId;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getSourceName() {
        return sourceName;
    }

    public void setSourceName(String sourceName) {
        this.sourceName = sourceName;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }
}
