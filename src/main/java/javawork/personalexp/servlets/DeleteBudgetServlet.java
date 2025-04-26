package javawork.personalexp.servlets;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import javawork.personalexp.tools.database.*;

@WebServlet("/delete-budget")
public class DeleteBudgetServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int budgetId = Integer.parseInt(request.getParameter("id"));
        boolean success = Database.deleteBudgetById(budgetId);
        response.sendRedirect("Budgets.jsp");  // Refresh the page
    }
}
