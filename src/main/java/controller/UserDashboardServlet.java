package controller;

import dao.BookDAO;
import dao.UserBookDAO;
import mode.Book;
import mode.UserBook;
import mode.UserBook.ReadingStatus;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet for handling user dashboard operations
 */
@WebServlet("/user/dashboard")
public class UserDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private UserBookDAO userBookDAO;
    private BookDAO bookDAO;
    
    @Override
    public void init() throws ServletException {
        userBookDAO = new UserBookDAO();
        bookDAO = new BookDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        try {
            // Get dashboard statistics
            Map<String, Integer> stats = userBookDAO.getUserDashboardStats(userId);
            request.setAttribute("stats", stats);
            
            // Get currently reading books
            List<UserBook> currentlyReading = userBookDAO.getUserBooksByStatus(userId, ReadingStatus.READING);
            request.setAttribute("currentlyReading", currentlyReading);
            
            // Get recommended books
            List<Book> recommendedBooks = userBookDAO.getRecommendedBooks(userId, 4);
            request.setAttribute("recommendedBooks", recommendedBooks);
            
            // Get recent activity
            List<Map<String, Object>> recentActivity = userBookDAO.getUserRecentActivity(userId, 5);
            request.setAttribute("recentActivity", recentActivity);
            
            // Forward to dashboard page
            request.getRequestDispatcher("/user/dashboard.jsp").forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error occurred");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        
        String action = request.getParameter("action");
        int bookId = Integer.parseInt(request.getParameter("bookId"));
        
        try {
            boolean success = false;
            
            switch (action) {
                case "startReading":
                    // Check if the book is already in user's collection
                    UserBook existingBook = userBookDAO.getUserBook(userId, bookId);
                    if (existingBook == null) {
                        // Add book to user's collection with READING status
                        userBookDAO.addUserBook(userId, bookId, ReadingStatus.READING);
                    } else {
                        // Update status to READING
                        userBookDAO.updateReadingStatus(userId, bookId, ReadingStatus.READING);
                    }
                    success = true;
                    break;
                    
                case "continueReading":
                    // Redirect to reader page
                    response.sendRedirect(request.getContextPath() + "/reader?bookId=" + bookId);
                    return;
                    
                case "viewDetails":
                    // Redirect to book details page
                    response.sendRedirect(request.getContextPath() + "/book?id=" + bookId);
                    return;
                    
                case "toggleBookmark":
                    success = userBookDAO.toggleBookmark(userId, bookId);
                    // Return JSON response for AJAX call
                    response.setContentType("application/json");
                    response.getWriter().write("{\"success\":" + success + "}");
                    return;
                    
                case "rate":
                    int rating = Integer.parseInt(request.getParameter("rating"));
                    success = userBookDAO.updateUserRating(userId, bookId, rating);
                    // Return JSON response for AJAX call
                    response.setContentType("application/json");
                    response.getWriter().write("{\"success\":" + success + "}");
                    return;
                    
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
                    return;
            }
            
            // Redirect back to dashboard
            response.sendRedirect(request.getContextPath() + "/user/dashboard");
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error occurred");
        }
    }
}
