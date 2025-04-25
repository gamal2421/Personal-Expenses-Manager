package javawork.personalexp.models;
public class User {
    private int id;
    private String username;
    private String password;
    private String email;
    private boolean authenticationEnabled;

    // Constructor
    public User(int id, String username, String password, String email, boolean authenticationEnabled) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.email = email;
        this.authenticationEnabled = authenticationEnabled;
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

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public boolean isAuthenticationEnabled() {
        return authenticationEnabled;
    }

    public void setAuthenticationEnabled(boolean authenticationEnabled) {
        this.authenticationEnabled = authenticationEnabled;
    }
}
