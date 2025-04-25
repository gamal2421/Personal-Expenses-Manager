package javawork.personalexp.models;

import java.util.Date;

public class RecurringPayment {
    private int id;
    private int userId;
    private double amount;
    private String frequency;
    private Date nextDueDate;

    // Constructor
    public RecurringPayment(int id, int userId, double amount, String frequency, Date nextDueDate) {
        this.id = id;
        this.userId = userId;
        this.amount = amount;
        this.frequency = frequency;
        this.nextDueDate = nextDueDate;
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

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public String getFrequency() {
        return frequency;
    }

    public void setFrequency(String frequency) {
        this.frequency = frequency;
    }

    public Date getNextDueDate() {
        return nextDueDate;
    }

    public void setNextDueDate(Date nextDueDate) {
        this.nextDueDate = nextDueDate;
    }
}
