package javawork.personalexp.models;

public class DashboardData {
    private double totalIncome;
    private double totalExpenses;
    private double totalSavings;

    // Constructor
    public DashboardData(double totalIncome, double totalExpenses, double totalSavings) {
        this.totalIncome = totalIncome;
        this.totalExpenses = totalExpenses;
        this.totalSavings = totalSavings;
    }

    // Getters and Setters
    public double getTotalIncome() {
        return totalIncome;
    }

    public void setTotalIncome(double totalIncome) {
        this.totalIncome = totalIncome;
    }

    public double getTotalExpenses() {
        return totalExpenses;
    }

    public void setTotalExpenses(double totalExpenses) {
        this.totalExpenses = totalExpenses;
    }

    public double getTotalSavings() {
        return totalSavings;
    }

    public void setTotalSavings(double totalSavings) {
        this.totalSavings = totalSavings;
    }
}
