package controller;

import java.io.IOException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.UserDAO;
import mode.User;

@WebServlet("/UserDeactivationServlet")
public class UserDeactivationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String password = request.getParameter("password");
        String confirmDeactivate = request.getParameter("confirmDeactivate");
        
        // Validate input
        if (password == null || password.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Password is required to deactivate your account");
            response.sendRedirect(request.getContextPath() + "/user/profile.jsp");
            return;
        }
        
        if (confirmDeactivate == null || !confirmDeactivate.equals("true")) {
            session.setAttribute("errorMessage", "You must confirm that you understand the consequences of deactivating your account");
            response.sendRedirect(request.getContextPath() + "/user/profile.jsp");
            return;
        }
        
        // Verify password
        UserDAO userDAO = new UserDAO();
        try {
            boolean passwordVerified = userDAO.verifyPassword(user.getUserId(), password);
            if (!passwordVerified) {
                session.setAttribute("errorMessage", "Incorrect password. Account deactivation failed");
                response.sendRedirect(request.getContextPath() + "/user/profile.jsp");
                return;
            }
            
            // Deactivate account
            user.setActive(false);
            boolean deactivated = userDAO.updateUser(user);
            
            if (deactivated) {
                // Invalidate session and redirect to login
                session.invalidate();
                
                // Create a new session for the message
                session = request.getSession();
                session.setAttribute("successMessage", "Your account has been deactivated. Contact an administrator if you wish to reactivate it.");
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            } else {
                session.setAttribute("errorMessage", "Failed to deactivate account. Please try again or contact support.");
                response.sendRedirect(request.getContextPath() + "/user/profile.jsp");
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/user/profile.jsp");
        }
    }
}
