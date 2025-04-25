package javawork.personalexp.models;

import java.util.Date;

public class Notification {
    private int id;
    private int userId;
    private String type;
    private String message;
    private Date date;
    private boolean isDismissed;

    // Constructor
    public Notification(int id, int userId, String type, String message, Date date, boolean isDismissed) {
        this.id = id;
        this.userId = userId;
        this.type = type;
        this.message = message;
        this.date = date;
        this.isDismissed = isDismissed;
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

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public boolean isDismissed() {
        return isDismissed;
    }

    public void setDismissed(boolean dismissed) {
        isDismissed = dismissed;
    }
}
