package javawork.personalexp.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import javawork.personalexp.tools.database.Database;

@WebServlet("/update-profile")
public class UpdateProfileServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("email") == null) {
            response.sendRedirect("PEM-signin-page.jsp");
            return;
        }

        String oldEmail = (String) session.getAttribute("email");
        String newName = request.getParameter("name");
        String newEmail = request.getParameter("email");

        boolean updated = Database.updateUserProfile(oldEmail, newName, newEmail);

        if (updated) {
            session.setAttribute("email", newEmail);
            response.sendRedirect("profilepage.jsp");
        } else {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to update profile");
        }
    }
}
