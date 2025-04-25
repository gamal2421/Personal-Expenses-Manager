package javawork.personalexp.models;

import java.sql.Date;

public class Report {
    private int id;
    private Date month;
    private double totalExpenses;
    private double totalIncome;

    // Getters and setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Date getMonth() { return month; }
    public void setMonth(Date month) { this.month = month; }

    public double getTotalExpenses() { return totalExpenses; }
    public void setTotalExpenses(double totalExpenses) { this.totalExpenses = totalExpenses; }

    public double getTotalIncome() { return totalIncome; }
    public void setTotalIncome(double totalIncome) { this.totalIncome = totalIncome; }
}
