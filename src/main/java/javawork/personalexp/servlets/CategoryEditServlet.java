package javawork.personalexp.servlets;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import javawork.personalexp.tools.Database;


@WebServlet("/editCategory")
public class CategoryEditServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String categoryIdStr = request.getParameter("categoryId");
        String newName = request.getParameter("newName");

        if (categoryIdStr != null && newName != null && !newName.trim().isEmpty()) {
            int categoryId = Integer.parseInt(categoryIdStr);

            boolean success = Database.updateCategoryName(categoryId, newName);

            if (success) {
                response.getWriter().write("Success");
            } else {
                response.getWriter().write("Fail");
            }
        } else {
            response.getWriter().write("Fail");
        }
    }
}
