package javawork.personalexp.models;

public class Category {
    private int id;
    private String name;
    private int userId; // Add the userId field as per your requirement

    // Constructor
    public Category(int id, String name, int userId) {
        this.id = id;
        this.name = name;
        this.userId = userId;  // Initialize the userId field
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }
}
