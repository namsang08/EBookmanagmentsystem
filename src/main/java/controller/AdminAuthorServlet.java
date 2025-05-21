package controller;

import dao.AuthorDAO;
import dao.BookDAO;
import mode.Author;
import mode.Book;
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
 * Servlet for handling admin author operations
 */
@WebServlet("/admin/authors/*")
public class AdminAuthorServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AdminAuthorServlet.class.getName());
    private AuthorDAO authorDAO;
    private BookDAO bookDAO;
    
    @Override
    public void init() {
        authorDAO = new AuthorDAO();
        bookDAO = new BookDAO();
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
                // List all authors
                listAuthors(request, response);
            } else if (pathInfo.equals("/view")) {
                // View author details
                viewAuthor(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error processing author request", e);
            throw new ServletException("Error processing author request", e);
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
            if ("toggleStatus".equals(action)) {
                // Toggle author active status
                toggleAuthorStatus(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error processing author action", e);
            throw new ServletException("Error processing author action", e);
        }
    }
    
    /**
     * List all authors
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void listAuthors(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        List<Author> authors = authorDAO.getAllAuthors();
        request.setAttribute("authors", authors);
        request.getRequestDispatcher("/admin/authors.jsp").forward(request, response);
    }
    
    /**
     * View author details
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void viewAuthor(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        int authorId = Integer.parseInt(request.getParameter("id"));
        Author author = authorDAO.getAuthorById(authorId);
        
        if (author != null) {
            // Get author's books
            List<Book> authorBooks = bookDAO.getBooksByAuthor(authorId);
            
            request.setAttribute("author", author);
            request.setAttribute("authorBooks", authorBooks);
            request.getRequestDispatcher("/admin/author-details.jsp").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    
    /**
     * Toggle author active status
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void toggleAuthorStatus(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        int authorId = Integer.parseInt(request.getParameter("id"));
        Author author = authorDAO.getAuthorById(authorId);
        
        if (author != null) {
            // Toggle active status
            boolean newStatus = !author.isActive();
            
            // Update author status in database (using UserDAO since Author extends User)
            authorDAO.updateAuthorStatus(authorId, newStatus);
            
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
