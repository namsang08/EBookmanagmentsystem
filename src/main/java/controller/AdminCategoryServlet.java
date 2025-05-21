package controller;

import dao.CategoryDAO;
import mode.Category;
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
 * Servlet for handling admin category operations
 */
@WebServlet("/admin/categories/*")
public class AdminCategoryServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AdminCategoryServlet.class.getName());
    private CategoryDAO categoryDAO;
    
    @Override
    public void init() {
        categoryDAO = new CategoryDAO();
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
                // List all categories
                listCategories(request, response);
            } else if (pathInfo.equals("/view")) {
                // View category details
                viewCategory(request, response);
            } else if (pathInfo.equals("/edit")) {
                // Show edit category form
                showEditForm(request, response);
            } else if (pathInfo.equals("/add")) {
                // Show add category form
                showAddForm(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error processing category request", e);
            throw new ServletException("Error processing category request", e);
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
                // Add new category
                addCategory(request, response);
            } else if ("update".equals(action)) {
                // Update existing category
                updateCategory(request, response);
            } else if ("delete".equals(action)) {
                // Delete category
                deleteCategory(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error processing category action", e);
            throw new ServletException("Error processing category action", e);
        }
    }
    
    /**
     * List all categories
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void listCategories(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        List<Category> categories = categoryDAO.getAllCategories();
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/admin/categories.jsp").forward(request, response);
    }
    
    /**
     * View category details
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void viewCategory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        int categoryId = Integer.parseInt(request.getParameter("id"));
        Category category = categoryDAO.getCategoryById(categoryId);
        
        if (category != null) {
            request.setAttribute("category", category);
            request.getRequestDispatcher("/admin/category-details.jsp").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    
    /**
     * Show edit category form
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        int categoryId = Integer.parseInt(request.getParameter("id"));
        Category category = categoryDAO.getCategoryById(categoryId);
        
        if (category != null) {
            request.setAttribute("category", category);
            request.getRequestDispatcher("/admin/edit-category.jsp").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    
    /**
     * Show add category form
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     */
    private void showAddForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/admin/add-category.jsp").forward(request, response);
    }
    
    /**
     * Add new category
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void addCategory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        // Extract category data from form
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        
        // Create and save category
        Category category = new Category();
        category.setName(name);
        category.setDescription(description);
        
        categoryDAO.addCategory(category);
        
        // Redirect to category list
        response.sendRedirect(request.getContextPath() + "/admin/categories");
    }
    
    /**
     * Update existing category
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void updateCategory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));
        Category category = categoryDAO.getCategoryById(categoryId);
        
        if (category != null) {
            // Update category data
            category.setName(request.getParameter("name"));
            category.setDescription(request.getParameter("description"));
            
            // Update category in database
            categoryDAO.updateCategory(category);
            
            // Redirect to category details
            response.sendRedirect(request.getContextPath() + "/admin/categories/view?id=" + categoryId);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    
    /**
     * Delete category
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void deleteCategory(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        int categoryId = Integer.parseInt(request.getParameter("id"));
        
        // Delete category from database
        categoryDAO.deleteCategory(categoryId);
        
        // Return success response for AJAX
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.print("{\"success\": true}");
        out.flush();
    }
}

