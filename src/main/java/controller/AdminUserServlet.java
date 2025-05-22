package controller;

import dao.UserDAO;
import mode.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet for handling admin user operations
 */
@WebServlet("/admin/users/*")
public class AdminUserServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AdminUserServlet.class.getName());
    private UserDAO userDAO;
    
    @Override
    public void init() {
        userDAO = new UserDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        // Check if user is logged in and is an admin
        if (user == null || !user.getRole().equals("ADMIN")) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String pathInfo = request.getPathInfo();
        
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                // List all users
                listUsers(request, response);
            } else if (pathInfo.equals("/view")) {
                // View user details
                viewUser(request, response);
            } else if (pathInfo.equals("/edit")) {
                // Show edit user form
                showEditForm(request, response);
            } else if (pathInfo.equals("/add")) {
                // Show add user form
                showAddForm(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error processing user request", e);
            throw new ServletException("Error processing user request", e);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        // Check if user is logged in and is an admin
        if (user == null || !user.getRole().equals("ADMIN")) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        LOGGER.info("AdminUserServlet doPost action: " + action);
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            if ("add".equals(action)) {
                // Add new user
                addUser(request, response);
            } else if ("update".equals(action)) {
                // Update existing user
                updateUser(request, response);
            } else if ("delete".equals(action)) {
                // Delete user
                int userId = Integer.parseInt(request.getParameter("id"));
                LOGGER.info("Attempting to delete user with ID: " + userId);
                
                // Don't allow deleting the current admin
                if (userId == user.getUserId()) {
                    out.print("{\"success\": false, \"message\": \"You cannot delete your own account.\"}");
                    return;
                }
                
                boolean success = userDAO.deleteUser(userId);
                
                if (success) {
                    out.print("{\"success\": true, \"message\": \"User has been deleted successfully.\"}");
                } else {
                    out.print("{\"success\": false, \"message\": \"Failed to delete user. The user may have associated data.\"}");
                }
            } else if ("toggleStatus".equals(action)) {
                // Toggle user active status
                int userId = Integer.parseInt(request.getParameter("id"));
                boolean isActive = Boolean.parseBoolean(request.getParameter("active"));
                
                boolean success = userDAO.toggleUserStatus(userId, isActive);
                
                if (success) {
                    out.print("{\"success\": true, \"status\": \"" + (isActive ? "Active" : "Inactive") + 
                              "\", \"message\": \"User status updated successfully.\"}");
                } else {
                    out.print("{\"success\": false, \"message\": \"Failed to update user status.\"}");
                }
            } else {
                out.print("{\"success\": false, \"message\": \"Invalid action: " + action + "\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing user action: " + action, e);
            String errorMessage = e.getMessage();
            if (errorMessage != null) {
                errorMessage = errorMessage.replace("\"", "\\\"");
            } else {
                errorMessage = "Unknown error";
            }
            out.print("{\"success\": false, \"message\": \"Error: " + errorMessage + "\"}");
        }
    }
    
    /**
     * List all users
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void listUsers(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        List<User> users = userDAO.getAllUsers();
        request.setAttribute("users", users);
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }
    
    /**
     * View user details
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void viewUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        int userId = Integer.parseInt(request.getParameter("id"));
        User user = userDAO.findById(userId);
        
        if (user != null) {
            request.setAttribute("userDetails", user);
            request.getRequestDispatcher("/admin/user-details.jsp").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    
    /**
     * Show edit user form
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        int userId = Integer.parseInt(request.getParameter("id"));
        User user = userDAO.findById(userId);
        
        if (user != null) {
            request.setAttribute("userDetails", user);
            request.getRequestDispatcher("/admin/edit-user.jsp").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    
    /**
     * Show add user form
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     */
    private void showAddForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/admin/add-user.jsp").forward(request, response);
    }
    
    /**
     * Add new user
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void addUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        // Extract user data from form
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String roleStr = request.getParameter("role");
        
        // Create and save user
        User newUser = new User();
        newUser.setFirstName(firstName);
        newUser.setLastName(lastName);
        newUser.setEmail(email);
        newUser.setPassword(password); // In a real app, this should be hashed
        
        // Convert String role to User.Role enum
        try {
            User.Role role = User.Role.valueOf(roleStr);
            newUser.setRole(role);
        } catch (IllegalArgumentException e) {
            LOGGER.warning("Invalid role: " + roleStr + ". Setting default role USER.");
            newUser.setRole(User.Role.USER);
        }
        
        newUser.setActive(true);
        
        boolean success = userDAO.createUser(newUser);
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        if (success) {
            out.print("{\"success\": true, \"message\": \"User created successfully.\", \"userId\": " + newUser.getUserId() + "}");
        } else {
            out.print("{\"success\": false, \"message\": \"Failed to create user.\"}");
        }
    }
    
    /**
     * Update existing user
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void updateUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        int userId = Integer.parseInt(request.getParameter("userId"));
        User user = userDAO.findById(userId);
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        if (user != null) {
            // Update user data
            user.setFirstName(request.getParameter("firstName"));
            user.setLastName(request.getParameter("lastName"));
            user.setEmail(request.getParameter("email"));
            
            // Update role if provided
            String roleStr = request.getParameter("role");
            if (roleStr != null && !roleStr.isEmpty()) {
                try {
                    User.Role role = User.Role.valueOf(roleStr);
                    user.setRole(role);
                } catch (IllegalArgumentException e) {
                    LOGGER.warning("Invalid role: " + roleStr + ". Role not updated.");
                }
            }
            
            // Update user in database
            boolean success = userDAO.updateUser(user);
            
            // Update password if provided
            String password = request.getParameter("password");
            if (password != null && !password.trim().isEmpty()) {
                userDAO.updatePassword(userId, password);
            }
            
            if (success) {
                out.print("{\"success\": true, \"message\": \"User updated successfully.\"}");
            } else {
                out.print("{\"success\": false, \"message\": \"Failed to update user.\"}");
            }
        } else {
            out.print("{\"success\": false, \"message\": \"User not found.\"}");
        }
    }
}
