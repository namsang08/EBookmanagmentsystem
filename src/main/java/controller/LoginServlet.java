package controller;

import dao.UserDAO;
import mode.User;
import util.SecurityUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(LoginServlet.class.getName());
    private UserDAO userDAO;
    
    @Override
    public void init() {
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String remember = request.getParameter("remember");
        
        try {
            // Validate input
            if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Email and password are required");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }
            
            // Find user by email
            User user = userDAO.findByEmail(email);
            
            // Check if user exists and password is correct
            if (user == null || !SecurityUtil.verifyPassword(password, user.getPassword())) {
                request.setAttribute("errorMessage", "Invalid email or password");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }
            
            // Check if user is active
            if (!user.isActive()) {
                request.setAttribute("errorMessage", "Your account is inactive. Please contact support.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }
            
            // Update last login time
            userDAO.updateLastLogin(user.getUserId());
            
            // Create session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            
            // Set session timeout (30 minutes by default, 7 days if remember me is checked)
            if (remember != null && remember.equals("on")) {
                session.setMaxInactiveInterval(7 * 24 * 60 * 60); // 7 days in seconds
            }
            
            // Log the login
            LOGGER.log(Level.INFO, "User logged in: {0}", user.getEmail());
            
            // Redirect based on role
            switch (user.getRole()) {
                case ADMIN:
                    response.sendRedirect("admin/dashboard.jsp");
                    break;
                case AUTHOR:
                    response.sendRedirect("author/dashboard.jsp");
                    break;
                case USER:
                    response.sendRedirect("user/dashboard.jsp");
                    break;
                default:
                    response.sendRedirect("index.jsp");
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error during login", e);
            request.setAttribute("errorMessage", "An error occurred during login. Please try again.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // If user is already logged in, redirect to appropriate dashboard
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            
            switch (user.getRole()) {
                case ADMIN:
                    response.sendRedirect("admin/dashboard.jsp");
                    break;
                case AUTHOR:
                    response.sendRedirect("author/dashboard.jsp");
                    break;
                case USER:
                    response.sendRedirect("user/dashboard.jsp");
                    break;
                default:
                    response.sendRedirect("index.jsp");
            }
        } else {
            // Otherwise, forward to login page
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}