package controller;

import dao.AuthorDAO;
import dao.BookDAO;
import dao.UserDAO;
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
    private UserDAO userDAO;
    
    @Override
    public void init() {
        authorDAO = new AuthorDAO();
        bookDAO = new BookDAO();
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
        if (user == null || !user.getRole().equals("ADMIN")) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        LOGGER.info("AdminAuthorServlet doPost action: " + action);
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        StringBuilder jsonResponse = new StringBuilder("{");
        
        try {
            if ("toggleStatus".equals(action)) {
                // Toggle author active status
                int authorId = Integer.parseInt(request.getParameter("id"));
                boolean isActive = Boolean.parseBoolean(request.getParameter("active"));
                
                boolean success = userDAO.toggleUserStatus(authorId, isActive);
                
                if (success) {
                    jsonResponse.append("\"success\": true,");
                    jsonResponse.append("\"status\": \"").append(isActive ? "Active" : "Inactive").append("\",");
                    jsonResponse.append("\"message\": \"Author status updated successfully.\"");
                } else {
                    jsonResponse.append("\"success\": false,");
                    jsonResponse.append("\"message\": \"Failed to update author status.\"");
                }
            } else if ("delete".equals(action)) {
                // Delete author
                int authorId = Integer.parseInt(request.getParameter("id"));
                LOGGER.info("Attempting to delete author with ID: " + authorId);
                
                // Don't allow deleting the current admin
                if (authorId == user.getUserId()) {
                    jsonResponse.append("\"success\": false,");
                    jsonResponse.append("\"message\": \"You cannot delete your own account.\"");
                    jsonResponse.append("}");
                    out.print(jsonResponse.toString());
                    return;
                }
                
                // First, check if author has books
                List<Book> authorBooks = bookDAO.getBooksByAuthor(authorId);
                if (authorBooks != null && !authorBooks.isEmpty()) {
                    // Delete all author's books first
                    for (Book book : authorBooks) {
                        bookDAO.deleteBook(book.getBookId());
                    }
                }
                
                // Now delete the author (user)
                boolean success = userDAO.deleteUser(authorId);
                
                if (success) {
                    jsonResponse.append("\"success\": true,");
                    jsonResponse.append("\"message\": \"Author and all associated books have been deleted successfully.\"");
                } else {
                    jsonResponse.append("\"success\": false,");
                    jsonResponse.append("\"message\": \"Failed to delete author. The author may have other associated data.\"");
                }
            } else {
                jsonResponse.append("\"success\": false,");
                jsonResponse.append("\"message\": \"Invalid action: ").append(action).append("\"");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error processing author action: " + action, e);
            jsonResponse.append("\"success\": false,");
            jsonResponse.append("\"message\": \"Error: ").append(e.getMessage().replace("\"", "\\\"")).append("\"");
        }
        
        jsonResponse.append("}");
        out.print(jsonResponse.toString());
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
}
