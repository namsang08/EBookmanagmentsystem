package controller;

import dao.CategoryDAO;
import mode.Category;
import mode.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

/**
 * Servlet for handling category-related actions
 */
@WebServlet("/CategoryServlet")
public class CategoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private CategoryDAO categoryDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        categoryDAO = new CategoryDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        try {
            if (action == null) {
                listCategories(request, response);
            } else if (action.equals("edit")) {
                showEditForm(request, response);
            } else if (action.equals("delete")) {
                deleteCategory(request, response);
            } else {
                listCategories(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        try {
            if (action == null) {
                response.sendRedirect(request.getContextPath() + "/admin/categories.jsp");
            } else if (action.equals("add")) {
                addCategory(request, response);
            } else if (action.equals("update")) {
                updateCategory(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/categories.jsp");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }
    
    /**
     * List all categories
     */
    private void listCategories(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        List<Category> categories = categoryDAO.getAllCategories();
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/admin/categories.jsp").forward(request, response);
    }
    
    /**
     * Show edit form for a category
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) throws SQLException, ServletException, IOException {
        // Check if user is logged in and is an admin
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRole() != User.Role.ADMIN) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        int categoryId = Integer.parseInt(request.getParameter("id"));
        Category category = categoryDAO.getCategoryById(categoryId);
        
        if (category != null) {
            request.setAttribute("category", category);
            request.getRequestDispatcher("/admin/edit-category.jsp").forward(request, response);
        } else {
            request.getSession().setAttribute("error", "Category not found.");
            response.sendRedirect(request.getContextPath() + "/admin/categories.jsp");
        }
    }
    
    /**
     * Add a new category
     */
    private void addCategory(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        // Check if user is logged in and is an admin
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRole() != User.Role.ADMIN) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        
        Category category = new Category();
        category.setName(name);
        category.setDescription(description);
        
        boolean success = categoryDAO.addCategory(category);
        
        if (success) {
            request.getSession().setAttribute("message", "Category added successfully!");
        } else {
            request.getSession().setAttribute("error", "Failed to add category. Please try again.");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/categories.jsp");
    }
    
    /**
     * Update an existing category
     */
    private void updateCategory(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        // Check if user is logged in and is an admin
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRole() != User.Role.ADMIN) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        
        Category category = new Category();
        category.setCategoryId(categoryId);
        category.setName(name);
        category.setDescription(description);
        
        boolean success = categoryDAO.updateCategory(category);
        
        if (success) {
            request.getSession().setAttribute("message", "Category updated successfully!");
        } else {
            request.getSession().setAttribute("error", "Failed to update category. Please try again.");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/categories.jsp");
    }
    
    /**
     * Delete a category
     */
    private void deleteCategory(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        // Check if user is logged in and is an admin
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRole() != User.Role.ADMIN) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        int categoryId = Integer.parseInt(request.getParameter("id"));
        
        boolean success = categoryDAO.deleteCategory(categoryId);
        
        if (success) {
            request.getSession().setAttribute("message", "Category deleted successfully!");
        } else {
            request.getSession().setAttribute("error", "Failed to delete category. Please try again.");
        }
        
        response.sendRedirect(request.getContextPath() + "/admin/categories.jsp");
    }
}
