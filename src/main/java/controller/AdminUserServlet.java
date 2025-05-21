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
        if (user == null || user.getRole() != User.Role.ADMIN) {
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
        if (user == null || user.getRole() != User.Role.ADMIN) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        try {
            if ("add".equals(action)) {
                // Add new user
                addUser(request, response);
            } else if ("update".equals(action)) {
                // Update existing user
                updateUser(request, response);
            } else if ("delete".equals(action)) {
                // Delete user
                deleteUser(request, response);
            } else if ("toggleStatus".equals(action)) {
                // Toggle user active status
                toggleUserStatus(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error processing user action", e);
            throw new ServletException("Error processing user action", e);
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
        User.Role role = User.Role.valueOf(roleStr);
        
        // Create and save user
        User user = new User();
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setEmail(email);
        user.setPassword(password); // In a real app, this should be hashed
        user.setRole(role);
        user.setActive(true);
        
        userDAO.createUser(user);
        
        // Redirect to user list
        response.sendRedirect(request.getContextPath() + "/admin/users");
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
        
        if (user != null) {
            // Update user data
            user.setFirstName(request.getParameter("firstName"));
            user.setLastName(request.getParameter("lastName"));
            user.setEmail(request.getParameter("email"));
            user.setRole(User.Role.valueOf(request.getParameter("role")));
            
            // Update password if provided
            String password = request.getParameter("password");
            if (password != null && !password.trim().isEmpty()) {
                userDAO.updatePassword(userId, password);
            }
            
            // Update user in database
            userDAO.updateUser(user);
            
            // Redirect to user details
            response.sendRedirect(request.getContextPath() + "/admin/users/view?id=" + userId);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    
    /**
     * Delete user
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void deleteUser(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        int userId = Integer.parseInt(request.getParameter("id"));
        
        // Delete user from database
        userDAO.deleteUser(userId);
        
        // Return success response for AJAX
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.print("{\"success\": true}");
        out.flush();
    }
    
    /**
     * Toggle user active status
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void toggleUserStatus(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        int userId = Integer.parseInt(request.getParameter("id"));
        User user = userDAO.findById(userId);
        
        if (user != null) {
            // Toggle active status
            boolean newStatus = !user.isActive();
            user.setActive(newStatus);
            
            // Update user in database
            userDAO.updateUser(user);
            
            // Return success response for AJAX
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": true, \"status\": \"" + (newStatus ? "Active" : "Inactive") + "\"}");
            out.flush();
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
}
