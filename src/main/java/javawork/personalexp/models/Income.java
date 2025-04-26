package javawork.personalexp.models;

public class Income {
    private int id;
    private String sourceName;
    private double amount;
    private int userId;

    public Income(int id, String sourceName, double amount, int userId) {
        this.id = id;
        this.sourceName = sourceName;
        this.amount = amount;
        this.userId = userId;
    }

    public Income(int userId, String sourceName, double amount) {
        this.userId = userId;
        this.sourceName = sourceName;
        this.amount = amount;
    }
    // Getters
    public int getId() { return id; }
    public String getSourceName() { return sourceName; }
    public double getAmount() { return amount; }
    public int getUserId() { return userId; }

    // Setters (if needed)
    public void setId(int id) { this.id = id; }
}