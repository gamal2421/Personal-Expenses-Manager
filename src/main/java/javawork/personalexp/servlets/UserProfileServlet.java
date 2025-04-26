package javawork.personalexp.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import javawork.personalexp.tools.database.Database;

@WebServlet("/UserProfileServlet")
public class UserProfileServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not logged in");
            return;
        }
        
        String email = (String) session.getAttribute("userEmail");
        if (email == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Not logged in");
            return;
        }
        
        String username = Database.getUserNameByEmail(email);
        String jsonResponse = String.format(
            "{\"username\": \"%s\", \"email\": \"%s\"}", 
            username, email
        );
        
        response.getWriter().write(jsonResponse);
    }
}