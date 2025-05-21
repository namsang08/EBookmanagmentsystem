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

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(RegisterServlet.class.getName());
    private UserDAO userDAO;
    
    @Override
    public void init() {
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String role = request.getParameter("role");
        String terms = request.getParameter("terms");
        
        try {
            // Validate input
            if (firstName == null || firstName.trim().isEmpty() ||
                lastName == null || lastName.trim().isEmpty() ||
                email == null || email.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                confirmPassword == null || confirmPassword.trim().isEmpty() ||
                role == null || role.trim().isEmpty()) {
                
                request.setAttribute("errorMessage", "All fields are required");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            
            // Validate email format
            if (!email.matches("^[\\w-\\.]+@([\\w-]+\\.)+[\\w-]{2,4}$")) {
                request.setAttribute("errorMessage", "Invalid email format");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            
            // Check if passwords match
            if (!password.equals(confirmPassword)) {
                request.setAttribute("errorMessage", "Passwords do not match");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            
            // Check password strength (at least 8 characters with letters and numbers)
            if (password.length() < 8 || !password.matches(".*[A-Za-z].*") || !password.matches(".*[0-9].*")) {
                request.setAttribute("errorMessage", "Password must be at least 8 characters long and contain both letters and numbers");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            
            // Check if terms are accepted
            if (terms == null || !terms.equals("on")) {
                request.setAttribute("errorMessage", "You must accept the Terms of Service and Privacy Policy");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            
            // Check if email already exists
            if (userDAO.emailExists(email)) {
                request.setAttribute("errorMessage", "Email already exists");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }
            
            // Sanitize input
            firstName = SecurityUtil.sanitizeInput(firstName);
            lastName = SecurityUtil.sanitizeInput(lastName);
            
            // Create user object
            User user = new User();
            user.setFirstName(firstName);
            user.setLastName(lastName);
            user.setEmail(email);
            user.setPassword(password); // Will be hashed in DAO
            
            // Set role based on selection
            if (role.equals("author")) {
                user.setRole(User.Role.AUTHOR);
            } else {
                user.setRole(User.Role.USER);
            }
            
            // Save user to database
            boolean success = userDAO.createUser(user);
            
            if (success) {
                // Log the registration
                LOGGER.log(Level.INFO, "New user registered: {0}", user.getEmail());
                
                // Create session and log in the user
                HttpSession session = request.getSession();
                session.setAttribute("user", user);
                
                // Redirect based on role
                if (user.getRole() == User.Role.AUTHOR) {
                    response.sendRedirect("author/dashboard.jsp");
                } else {
                    response.sendRedirect("user/dashboard.jsp");
                }
            } else {
                request.setAttribute("errorMessage", "Registration failed. Please try again.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error during registration", e);
            request.setAttribute("errorMessage", "An error occurred during registration. Please try again.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
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
            // Otherwise, forward to registration page
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}