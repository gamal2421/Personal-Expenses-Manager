package javawork.personalexp.servlets;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import javawork.personalexp.models.Income;
import javawork.personalexp.tools.Database;
@WebServlet("/IncomeServlet")
public class IncomeServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
        throws ServletException, IOException {
    
    response.setContentType("application/json");
    String action = request.getParameter("action");
    String email = (String) request.getSession().getAttribute("userEmail");
    
    if (email == null) {
        response.getWriter().write("{ \"success\": false, \"message\": \"Not logged in\" }");
        return;
    }
    
    try {
        int userId = Database.getUserIdByEmail(email);
        
        switch (action) {
            case "add":
                String sourceName = request.getParameter("sourceName");
                double amount = Double.parseDouble(request.getParameter("amount"));
                Income newIncome = new Income( userId,  sourceName,  amount);
                boolean added = Database.addIncome(newIncome);
                response.getWriter().write(String.format(
                    "{ \"success\": %b, \"id\": %d }", 
                    added, added ? newIncome.getId() : -1
                ));
                break;
                
            case "update":
                int updateId = Integer.parseInt(request.getParameter("id"));
                String updateName = request.getParameter("sourceName");
                double updateAmount = Double.parseDouble(request.getParameter("amount"));
                boolean updated = Database.updateIncome(updateId, updateName, updateAmount);
                response.getWriter().write("{ \"success\": " + updated + " }");
                break;
                
            case "delete":
                int deleteId = Integer.parseInt(request.getParameter("id"));
                boolean deleted = Database.deleteIncome(deleteId);
                response.getWriter().write("{ \"success\": " + deleted + " }");
                break;
                
            default:
                response.getWriter().write("{ \"success\": false, \"message\": \"Invalid action\" }");
        }
    } catch (Exception e) {
        response.getWriter().write("{ \"success\": false, \"message\": \"Error: " + e.getMessage() + "\" }");
        e.printStackTrace();
    }
}
}