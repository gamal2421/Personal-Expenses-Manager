package javawork.personalexp.models;

public class Budget {
    private int id;
    private String category;
    private double budgetAmount;
    private double currentSpending;

    public Budget(int id, String category, double budgetAmount, double currentSpending) {
        this.id = id;
        this.category = category;
        this.budgetAmount = budgetAmount;
        this.currentSpending = currentSpending;
    }

    // Getters and setters
    public int getId() { return id; }
    public String getCategory() { return category; }
    public double getBudgetAmount() { return budgetAmount; }
    public double getCurrentSpending() { return currentSpending; }
    
    public void setId(int id) { this.id = id; }
    public void setCategory(String category) { this.category = category; }
    public void setBudgetAmount(double budgetAmount) { this.budgetAmount = budgetAmount; }
    public void setCurrentSpending(double currentSpending) { this.currentSpending = currentSpending; }
}