package javawork.personalexp.models;

public class Income {
    private int id;
    private int userId;
    private String sourceName;
    private double amount;
    
    // Constructors
    public Income() {}
    
    public Income(int id, int userId, String sourceName, double amount) {
        this.id = id;
        this.userId = userId;
        this.sourceName = sourceName;
        this.amount = amount;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    
    public String getSourceName() { return sourceName; }
    public void setSourceName(String sourceName) { this.sourceName = sourceName; }
    
    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }
}