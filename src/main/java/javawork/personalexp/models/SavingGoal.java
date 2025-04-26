package javawork.personalexp.models;

import java.sql.Date;

public class SavingGoal {
    private int id;
    private String title;
    private String description;
    private double targetAmount;
    private double currentAmount;
    private Date targetDate;
    private boolean achieved;
    
    public SavingGoal(int id, String title, String description, double targetAmount,
                    double currentAmount, Date targetDate, boolean achieved) {
        this.id = id;
        this.title = title;
        this.description = description;
        this.targetAmount = targetAmount;
        this.currentAmount = currentAmount;
        this.targetDate = targetDate;
        this.achieved = achieved;
    }
    
    // Getters
    public int getId() { return id; }
    public String getTitle() { return title; }
    public String getDescription() { return description; }
    public double getTargetAmount() { return targetAmount; }
    public double getCurrentAmount() { return currentAmount; }
    public Date getTargetDate() { return targetDate; }
    public boolean isAchieved() { return achieved; }
    
    // Formatted getters for JSP
    public String getFormattedTargetAmount() {
        return String.format("$%.2f", targetAmount);
    }
    
    public String getFormattedCurrentAmount() {
        return String.format("$%.2f", currentAmount);
    }
    
    public String getFormattedTargetDate() {
        return targetDate.toString(); // or format as needed
    }
}