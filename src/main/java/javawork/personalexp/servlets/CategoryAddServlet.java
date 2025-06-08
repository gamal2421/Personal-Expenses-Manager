package javawork.personalexp.servlets;

import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import javawork.personalexp.tools.Database;

@WebServlet("/addCategory")
public class CategoryAddServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String categoryName = request.getParameter("categoryName");
        HttpSession session = request.getSession(false);
        String userEmail = (String) session.getAttribute("userEmail");

        if (userEmail != null && categoryName != null && !categoryName.trim().isEmpty()) {
            int userId = Database.getUserIdByEmail(userEmail);

            try {
                boolean success = Database.addCategory(userId, categoryName);

                if (success) {
                    response.getWriter().write("Success");
                } else {
                    response.getWriter().write("Failed to add category.");
                }
            } catch (SQLException e) {
                response.getWriter().write(e.getMessage());
            }
        } else {
            response.getWriter().write("Fail");
        }
    }
}
