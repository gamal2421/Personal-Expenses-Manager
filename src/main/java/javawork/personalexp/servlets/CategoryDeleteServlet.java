package javawork.personalexp.servlets;


import java.io.IOException;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import javawork.personalexp.tools.Database;

@WebServlet("/deleteCategory")
public class CategoryDeleteServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String categoryIdStr = request.getParameter("categoryId");
        
        if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
            int categoryId = Integer.parseInt(categoryIdStr);

            try {
                boolean success = Database.deleteCategory(categoryId);

                if (success) {
                    response.getWriter().write("Success");
                } else {
                    response.getWriter().write("Failed to delete category.");
                }
            } catch (SQLException e) {
                // Send the specific error message from the Database class
                response.getWriter().write(e.getMessage());
            }
        } else {
            response.getWriter().write("Invalid category ID.");
        }
    }
}
