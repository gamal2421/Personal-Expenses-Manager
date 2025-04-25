package javawork.personalexp.servlets;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.Date;

import javawork.personalexp.tools.database.Database;

@WebServlet("/add-budget")
public class AddBudgetServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String email = (String) request.getSession().getAttribute("email");
        if (email == null) {
            response.sendRedirect("PEM-signin-page.jsp");
            return;
        }

        String categoryName = request.getParameter("categoryName");
        double amount = Double.parseDouble(request.getParameter("amount"));
        Date startDate = Date.valueOf(request.getParameter("startDate"));
        Date endDate = Date.valueOf(request.getParameter("endDate"));

        int userId = Database.getUserIdByEmail(email);
        int categoryId = Database.getOrCreateCategoryId(categoryName, userId);
        Database.insertBudget(userId, categoryId, amount, startDate, endDate);

        response.sendRedirect("Budgets.jsp");
    }
}
