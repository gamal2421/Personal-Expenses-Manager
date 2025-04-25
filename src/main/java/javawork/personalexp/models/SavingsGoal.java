package javawork.personalexp.models;
import java.util.Date;

public class SavingsGoal {
    private int id;
    private int userId;
    private double targetAmount;
    private Date deadline;
    private boolean achieved;

    // Constructor
    public SavingsGoal(int id, int userId, double targetAmount, Date deadline, boolean achieved) {
        this.id = id;
        this.userId = userId;
        this.targetAmount = targetAmount;
        this.deadline = deadline;
        this.achieved = achieved;
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

    public double getTargetAmount() {
        return targetAmount;
    }

    public void setTargetAmount(double targetAmount) {
        this.targetAmount = targetAmount;
    }

    public Date getDeadline() {
        return deadline;
    }

    public void setDeadline(Date deadline) {
        this.deadline = deadline;
    }

    public boolean isAchieved() {
        return achieved;
    }

    public void setAchieved(boolean achieved) {
        this.achieved = achieved;
    }
}
