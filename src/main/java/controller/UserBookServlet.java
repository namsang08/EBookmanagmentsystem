package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.BookDAO;
import dao.UserBookDAO;
import mode.Book;
import mode.User;
import mode.UserBook;
import mode.UserBook.ReadingStatus;

/**
 * Servlet implementation class UserBookServlet
 * Handles user-book interactions like bookmarking, updating reading status, etc.
 */
@WebServlet("/UserBookServlet")
public class UserBookServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private UserBookDAO userBookDAO;
    private BookDAO bookDAO;
    
    /**
     * Initialize DAOs
     */
    @Override
    public void init() throws ServletException {
        super.init();
        userBookDAO = new UserBookDAO();
        bookDAO = new BookDAO();
    }
    
    /**
     * Default constructor
     */
    public UserBookServlet() {
        super();
    }

    /**
     * Handle GET requests - mainly for page redirects after actions
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        int bookId = 0;
        
        try {
            if (request.getParameter("bookId") != null) {
                bookId = Integer.parseInt(request.getParameter("bookId"));
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid book ID");
            return;
        }
        
        try {
            if ("view".equals(action)) {
                // Add view to user history
                userBookDAO.addToUserHistory(currentUser.getUserId(), bookId, "VIEW");
                response.sendRedirect(request.getContextPath() + "/bookdetails.jsp?id=" + bookId);
            } else if ("read".equals(action)) {
                // Add read action to user history
                userBookDAO.addToUserHistory(currentUser.getUserId(), bookId, "READ");
                response.sendRedirect(request.getContextPath() + "/reader.jsp?id=" + bookId);
            } else {
                // Default redirect to book details
                response.sendRedirect(request.getContextPath() + "/bookdetails.jsp?id=" + bookId);
            }
        } catch (SQLException e) {
            getServletContext().log("Database error in UserBookServlet", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error occurred");
        }
    }

    /**
     * Handle POST requests - for AJAX and form submissions
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Check if user is logged in
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            sendJsonResponse(response, false, "User not logged in", HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        String action = request.getParameter("action");
        int userId = currentUser.getUserId();
        int bookId = 0;
        
        try {
            if (request.getParameter("bookId") != null) {
                bookId = Integer.parseInt(request.getParameter("bookId"));
            }
            
            // Override userId if provided and user is admin
            if (request.getParameter("userId") != null && currentUser.getRole().equals("ADMIN")) {
                userId = Integer.parseInt(request.getParameter("userId"));
            }
        } catch (NumberFormatException e) {
            sendJsonResponse(response, false, "Invalid ID format", HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        try {
            boolean success = false;
            String message = "";
            Map<String, Object> additionalData = new HashMap<>();
            
            switch (action) {
                case "toggleBookmark":
                    success = userBookDAO.toggleBookmark(userId, bookId);
                    boolean isBookmarked = userBookDAO.isBookmarked(userId, bookId);
                    message = isBookmarked ? "Book added to bookmarks" : "Book removed from bookmarks";
                    additionalData.put("bookmarked", isBookmarked);
                    break;
                    
                case "updateStatus":
                    String statusStr = request.getParameter("status");
                    if (statusStr != null && !statusStr.isEmpty()) {
                        ReadingStatus status = ReadingStatus.valueOf(statusStr);
                        success = userBookDAO.updateReadingStatus(userId, bookId, status);
                        message = "Reading status updated to " + status;
                    } else {
                        message = "Invalid reading status";
                    }
                    break;
                    
                case "updateProgress":
                    try {
                        int currentPage = Integer.parseInt(request.getParameter("currentPage"));
                        success = userBookDAO.updateReadingProgress(userId, bookId, currentPage);
                        int progressPercent = userBookDAO.getReadingProgress(userId, bookId);
                        message = "Reading progress updated";
                        additionalData.put("progress", progressPercent);
                    } catch (NumberFormatException e) {
                        message = "Invalid page number";
                    }
                    break;
                    
                case "updateRating":
                    try {
                        int rating = Integer.parseInt(request.getParameter("rating"));
                        success = userBookDAO.updateUserRating(userId, bookId, rating);
                        message = "Rating updated";
                    } catch (NumberFormatException e) {
                        message = "Invalid rating value";
                    }
                    break;
                    
                case "removeBook":
                    success = userBookDAO.removeUserBook(userId, bookId);
                    message = success ? "Book removed from your collection" : "Failed to remove book";
                    break;
                    
                case "addToReadingList":
                    try {
                        int priority = Integer.parseInt(request.getParameter("priority"));
                        success = userBookDAO.updateReadingListPriority(userId, bookId, priority);
                        message = priority > 0 ? "Book added to reading list" : "Book removed from reading list";
                    } catch (NumberFormatException e) {
                        message = "Invalid priority value";
                    }
                    break;
                    
                default:
                    message = "Unknown action";
                    break;
            }
            
            // Send JSON response for AJAX requests
            sendJsonResponse(response, success, message, HttpServletResponse.SC_OK, additionalData);
            
        } catch (IllegalArgumentException e) {
            sendJsonResponse(response, false, "Invalid parameter: " + e.getMessage(), HttpServletResponse.SC_BAD_REQUEST);
        } catch (SQLException e) {
            getServletContext().log("Database error in UserBookServlet", e);
            sendJsonResponse(response, false, "Database error occurred", HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        } catch (Exception e) {
            getServletContext().log("Unexpected error in UserBookServlet", e);
            sendJsonResponse(response, false, "An unexpected error occurred", HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
    
    /**
     * Helper method to send JSON response
     */
    private void sendJsonResponse(HttpServletResponse response, boolean success, String message, int statusCode) 
            throws IOException {
        sendJsonResponse(response, success, message, statusCode, null);
    }
    
    /**
     * Helper method to send JSON response with additional data
     */
    private void sendJsonResponse(HttpServletResponse response, boolean success, String message, 
            int statusCode, Map<String, Object> additionalData) throws IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(statusCode);
        
        StringBuilder jsonBuilder = new StringBuilder();
        jsonBuilder.append("{");
        jsonBuilder.append("\"success\":").append(success).append(",");
        jsonBuilder.append("\"message\":\"").append(escapeJsonString(message)).append("\"");
        
        // Add additional data if provided
        if (additionalData != null && !additionalData.isEmpty()) {
            for (Map.Entry<String, Object> entry : additionalData.entrySet()) {
                jsonBuilder.append(",\"").append(escapeJsonString(entry.getKey())).append("\":");
                
                Object value = entry.getValue();
                if (value instanceof String) {
                    jsonBuilder.append("\"").append(escapeJsonString((String) value)).append("\"");
                } else if (value instanceof Boolean) {
                    jsonBuilder.append(value);
                } else if (value instanceof Number) {
                    jsonBuilder.append(value);
                } else {
                    jsonBuilder.append("\"").append(escapeJsonString(String.valueOf(value))).append("\"");
                }
            }
        }
        
        jsonBuilder.append("}");
        
        PrintWriter out = response.getWriter();
        out.print(jsonBuilder.toString());
        out.flush();
    }
    
    /**
     * Helper method to escape special characters in JSON strings
     */
    private String escapeJsonString(String input) {
        if (input == null) {
            return "";
        }
        
        StringBuilder escaped = new StringBuilder();
        for (int i = 0; i < input.length(); i++) {
            char ch = input.charAt(i);
            switch (ch) {
                case '"':
                    escaped.append("\\\"");
                    break;
                case '\\':
                    escaped.append("\\\\");
                    break;
                case '\b':
                    escaped.append("\\b");
                    break;
                case '\f':
                    escaped.append("\\f");
                    break;
                case '\n':
                    escaped.append("\\n");
                    break;
                case '\r':
                    escaped.append("\\r");
                    break;
                case '\t':
                    escaped.append("\\t");
                    break;
                default:
                    escaped.append(ch);
            }
        }
        
        return escaped.toString();
    }
}
