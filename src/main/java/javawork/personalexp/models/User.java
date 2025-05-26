package javawork.personalexp.models;

public class User {
    private int id;
    private String username;
    private String email;
    private String incomeLevel;

    // Constructor
    public User(int id, String username, String email, String incomeLevel) {
        this.id = id;
        this.username = username;
        this.email = email;
        this.incomeLevel = incomeLevel;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getIncomeLevel() {
        return incomeLevel;
    }

    public void setIncomeLevel(String incomeLevel) {
        this.incomeLevel = incomeLevel;
    }
}
