package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import dao.BookDAO;
import dao.CategoryDAO;
import dao.UserDAO;
import dao.AuthorDAO;
import mode.Book;
import mode.Category;
import mode.User;
import mode.Author;

/**
 * Servlet implementation class AdminReportServlet
 * Handles requests for report data for the admin dashboard
 */
@WebServlet("/AdminReportServlet")
public class AdminReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(AdminReportServlet.class.getName());
    
    private BookDAO bookDAO;
    private CategoryDAO categoryDAO;
    private UserDAO userDAO;
    private AuthorDAO authorDAO;
    
    /**
     * Initialize the DAOs
     */
    @Override
    public void init() throws ServletException {
        super.init();
        bookDAO = new BookDAO();
        categoryDAO = new CategoryDAO();
        userDAO = new UserDAO();
        authorDAO = new AuthorDAO();
    }
    
    /**
     * Handle GET requests for report data
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        // Check if user is logged in and is an admin
        if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        
        String action = request.getParameter("action");
        String timeRange = request.getParameter("timeRange");
        
        if (action == null || action.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action parameter is required");
            return;
        }
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        
        try {
            String jsonData = "";
            
            switch (action) {
                case "userRegistrations":
                    jsonData = getUserRegistrationsData(timeRange);
                    break;
                case "bookDownloads":
                    jsonData = getBookDownloadsData(timeRange);
                    break;
                case "booksByCategory":
                    jsonData = getBooksByCategoryData();
                    break;
                case "topAuthors":
                    jsonData = getTopAuthorsData();
                    break;
                case "topBooks":
                    jsonData = getTopBooksData();
                    break;
                case "activeUsers":
                    jsonData = getActiveUsersData();
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action parameter");
                    return;
            }
            
            out.print(jsonData);
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error generating report data", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating report data");
        }
    }
    
    /**
     * Get user registrations data for the specified time range
     * 
     * @param timeRange The time range for the report
     * @return JSON string with user registrations data
     * @throws SQLException If a database error occurs
     */
    private String getUserRegistrationsData(String timeRange) throws SQLException {
        List<User> allUsers = userDAO.getAllUsers();
        Map<String, Integer> registrationsByDate = new HashMap<>();
        
        // Define date format based on time range
        String dateFormat = "yyyy-MM-dd";
        if ("30".equals(timeRange)) {
            dateFormat = "yyyy-MM-dd";
        } else if ("90".equals(timeRange)) {
            dateFormat = "yyyy-MM";
        } else if ("365".equals(timeRange)) {
            dateFormat = "yyyy-MM";
        } else if ("all".equals(timeRange)) {
            dateFormat = "yyyy";
        }
        
        SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
        
        // Calculate start date based on time range
        Calendar cal = Calendar.getInstance();
        Date endDate = cal.getTime();
        
        if ("7".equals(timeRange)) {
            cal.add(Calendar.DAY_OF_MONTH, -7);
        } else if ("30".equals(timeRange)) {
            cal.add(Calendar.DAY_OF_MONTH, -30);
        } else if ("90".equals(timeRange)) {
            cal.add(Calendar.MONTH, -3);
        } else if ("365".equals(timeRange)) {
            cal.add(Calendar.YEAR, -1);
        } else {
            cal.add(Calendar.YEAR, -10); // Assuming the system is not older than 10 years
        }
        
        Date startDate = cal.getTime();
        
        // Initialize the map with all dates in the range
        cal.setTime(startDate);
        while (!cal.getTime().after(endDate)) {
            String dateKey = sdf.format(cal.getTime());
            registrationsByDate.put(dateKey, 0);
            
            if ("7".equals(timeRange) || "30".equals(timeRange)) {
                cal.add(Calendar.DAY_OF_MONTH, 1);
            } else if ("90".equals(timeRange) || "365".equals(timeRange)) {
                cal.add(Calendar.MONTH, 1);
            } else {
                cal.add(Calendar.YEAR, 1);
            }
        }
        
        // Count registrations by date
        for (User user : allUsers) {
            Date registrationDate = user.getRegistrationDate();
            if (registrationDate != null && !registrationDate.before(startDate) && !registrationDate.after(endDate)) {
                String dateKey = sdf.format(registrationDate);
                registrationsByDate.put(dateKey, registrationsByDate.getOrDefault(dateKey, 0) + 1);
            }
        }
        
        // Build JSON response
        StringBuilder json = new StringBuilder();
        json.append("{\"labels\":[");
        
        List<String> sortedDates = new ArrayList<>(registrationsByDate.keySet());
        java.util.Collections.sort(sortedDates);
        
        boolean first = true;
        for (String date : sortedDates) {
            if (!first) {
                json.append(",");
            }
            json.append("\"" + date + "\"");
            first = false;
        }
        
        json.append("],\"values\":[");
        
        first = true;
        for (String date : sortedDates) {
            if (!first) {
                json.append(",");
            }
            json.append(registrationsByDate.get(date));
            first = false;
        }
        
        json.append("]}");
        
        return json.toString();
    }
    
    /**
     * Get book downloads data for the specified time range
     * 
     * @param timeRange The time range for the report
     * @return JSON string with book downloads data
     * @throws SQLException If a database error occurs
     */
    private String getBookDownloadsData(String timeRange) throws SQLException {
        // This is a simplified implementation since we don't have a table that tracks downloads by date
        // In a real implementation, you would query a downloads history table
        
        // For now, we'll generate some sample data based on the time range
        Map<String, Integer> downloadsByDate = new HashMap<>();
        
        // Define date format based on time range
        String dateFormat = "yyyy-MM-dd";
        if ("30".equals(timeRange)) {
            dateFormat = "yyyy-MM-dd";
        } else if ("90".equals(timeRange)) {
            dateFormat = "yyyy-MM";
        } else if ("365".equals(timeRange)) {
            dateFormat = "yyyy-MM";
        } else if ("all".equals(timeRange)) {
            dateFormat = "yyyy";
        }
        
        SimpleDateFormat sdf = new SimpleDateFormat(dateFormat);
        
        // Calculate start date based on time range
        Calendar cal = Calendar.getInstance();
        Date endDate = cal.getTime();
        
        if ("7".equals(timeRange)) {
            cal.add(Calendar.DAY_OF_MONTH, -7);
        } else if ("30".equals(timeRange)) {
            cal.add(Calendar.DAY_OF_MONTH, -30);
        } else if ("90".equals(timeRange)) {
            cal.add(Calendar.MONTH, -3);
        } else if ("365".equals(timeRange)) {
            cal.add(Calendar.YEAR, -1);
        } else {
            cal.add(Calendar.YEAR, -10); // Assuming the system is not older than 10 years
        }
        
        Date startDate = cal.getTime();
        
        // Initialize the map with all dates in the range
        cal.setTime(startDate);
        while (!cal.getTime().after(endDate)) {
            String dateKey = sdf.format(cal.getTime());
            downloadsByDate.put(dateKey, 0);
            
            if ("7".equals(timeRange) || "30".equals(timeRange)) {
                cal.add(Calendar.DAY_OF_MONTH, 1);
            } else if ("90".equals(timeRange) || "365".equals(timeRange)) {
                cal.add(Calendar.MONTH, 1);
            } else {
                cal.add(Calendar.YEAR, 1);
            }
        }
        
        // In a real implementation, you would query the database for actual download data
        // For now, we'll generate random data
        List<Book> allBooks = bookDAO.getAllBooks();
        int totalDownloads = 0;
        for (Book book : allBooks) {
            totalDownloads += book.getDownloads();
        }
        
        // Distribute downloads across the date range
        int remainingDownloads = totalDownloads;
        List<String> dates = new ArrayList<>(downloadsByDate.keySet());
        java.util.Collections.sort(dates);
        
        for (int i = 0; i < dates.size() - 1; i++) {
            int downloadsForDate = (int) (Math.random() * (remainingDownloads / (dates.size() - i)));
            downloadsByDate.put(dates.get(i), downloadsForDate);
            remainingDownloads -= downloadsForDate;
        }
        
        // Assign remaining downloads to the last date
        if (dates.size() > 0) {
            downloadsByDate.put(dates.get(dates.size() - 1), remainingDownloads);
        }
        
        // Build JSON response
        StringBuilder json = new StringBuilder();
        json.append("{\"labels\":[");
        
        boolean first = true;
        for (String date : dates) {
            if (!first) {
                json.append(",");
            }
            json.append("\"" + date + "\"");
            first = false;
        }
        
        json.append("],\"values\":[");
        
        first = true;
        for (String date : dates) {
            if (!first) {
                json.append(",");
            }
            json.append(downloadsByDate.get(date));
            first = false;
        }
        
        json.append("]}");
        
        return json.toString();
    }
    
    /**
     * Get books by category data
     * 
     * @return JSON string with books by category data
     * @throws SQLException If a database error occurs
     */
    private String getBooksByCategoryData() throws SQLException {
        List<Category> categories = categoryDAO.getAllCategories();
        
        StringBuilder json = new StringBuilder();
        json.append("{\"labels\":[");
        
        boolean first = true;
        for (Category category : categories) {
            if (!first) {
                json.append(",");
            }
            json.append("\"" + escapeJson(category.getName()) + "\"");
            first = false;
        }
        
        json.append("],\"values\":[");
        
        first = true;
        for (Category category : categories) {
            if (!first) {
                json.append(",");
            }
            json.append(category.getBookCount());
            first = false;
        }
        
        json.append("]}");
        
        return json.toString();
    }
    
    /**
     * Get top authors data
     * 
     * @return JSON string with top authors data
     * @throws SQLException If a database error occurs
     */
    private String getTopAuthorsData() throws SQLException {
        List<Author> authors = authorDAO.getAllAuthors();
        Map<Integer, Integer> bookCountByAuthor = new HashMap<>();
        Map<Integer, String> authorNames = new HashMap<>();
        
        // Count books by author
        List<Book> allBooks = bookDAO.getAllBooks();
        for (Book book : allBooks) {
            int authorId = book.getAuthorId();
            bookCountByAuthor.put(authorId, bookCountByAuthor.getOrDefault(authorId, 0) + 1);
        }
        
        // Get author names
        for (Author author : authors) {
            authorNames.put(author.getUserId(), author.getFirstName() + " " + author.getLastName());
        }
        
        // Sort authors by book count (descending)
        List<Map.Entry<Integer, Integer>> sortedAuthors = new ArrayList<>(bookCountByAuthor.entrySet());
        sortedAuthors.sort((a, b) -> b.getValue().compareTo(a.getValue()));
        
        // Limit to top 10 authors
        int limit = Math.min(10, sortedAuthors.size());
        if (limit > 0) {
            sortedAuthors = sortedAuthors.subList(0, limit);
        }
        
        // Build JSON response
        StringBuilder json = new StringBuilder();
        json.append("{\"labels\":[");
        
        boolean first = true;
        for (Map.Entry<Integer, Integer> entry : sortedAuthors) {
            if (!first) {
                json.append(",");
            }
            String authorName = authorNames.getOrDefault(entry.getKey(), "Unknown");
            json.append("\"" + escapeJson(authorName) + "\"");
            first = false;
        }
        
        json.append("],\"values\":[");
        
        first = true;
        for (Map.Entry<Integer, Integer> entry : sortedAuthors) {
            if (!first) {
                json.append(",");
            }
            json.append(entry.getValue());
            first = false;
        }
        
        json.append("]}");
        
        return json.toString();
    }
    
    /**
     * Get top books data
     * 
     * @return JSON string with top books data
     * @throws SQLException If a database error occurs
     */
    private String getTopBooksData() throws SQLException {
        List<Book> allBooks = bookDAO.getAllBooks();
        
        // Sort books by downloads (descending)
        allBooks.sort((a, b) -> Integer.compare(b.getDownloads(), a.getDownloads()));
        
        // Limit to top 10 books
        int limit = Math.min(10, allBooks.size());
        List<Book> topBooks = limit > 0 ? allBooks.subList(0, limit) : new ArrayList<>();
        
        // Build JSON response
        StringBuilder json = new StringBuilder();
        json.append("[");
        
        boolean first = true;
        for (Book book : topBooks) {
            if (!first) {
                json.append(",");
            }
            
            json.append("{");
            json.append("\"id\":" + book.getBookId() + ",");
            json.append("\"title\":\"" + escapeJson(book.getTitle()) + "\",");
            json.append("\"author\":\"" + escapeJson(book.getAuthorName()) + "\",");
            json.append("\"category\":\"" + escapeJson(book.getCategoryName()) + "\",");
            json.append("\"downloads\":" + book.getDownloads() + ",");
            json.append("\"views\":" + book.getViews() + ",");
            json.append("\"rating\":" + book.getRating());
            json.append("}");
            
            first = false;
        }
        
        json.append("]");
        
        return json.toString();
    }
    
    /**
     * Get active users data
     * 
     * @return JSON string with active users data
     * @throws SQLException If a database error occurs
     */
    private String getActiveUsersData() throws SQLException {
        List<User> allUsers = userDAO.getAllUsers();
        
        // In a real implementation, you would query a user activity table
        // For now, we'll use registration date as a proxy for activity
        
        // Sort users by registration date (descending)
        allUsers.sort((a, b) -> {
            if (a.getRegistrationDate() == null) return 1;
            if (b.getRegistrationDate() == null) return -1;
            return b.getRegistrationDate().compareTo(a.getRegistrationDate());
        });
        
        // Limit to top 10 users
        int limit = Math.min(10, allUsers.size());
        List<User> activeUsers = limit > 0 ? allUsers.subList(0, limit) : new ArrayList<>();
        
        // Build JSON response
        StringBuilder json = new StringBuilder();
        json.append("[");
        
        boolean first = true;
        for (User user : activeUsers) {
            if (!first) {
                json.append(",");
            }
            
            json.append("{");
            json.append("\"id\":" + user.getUserId() + ",");
            json.append("\"name\":\"" + escapeJson(user.getFirstName() + " " + user.getLastName()) + "\",");
            json.append("\"email\":\"" + escapeJson(user.getEmail()) + "\",");
            json.append("\"role\":\"" + user.getRole() + "\",");
            
            // Format registration date
            String registrationDate = user.getRegistrationDate() != null ? 
                new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(user.getRegistrationDate()) : "";
            json.append("\"registrationDate\":\"" + registrationDate + "\",");
            
            // In a real implementation, you would query for these values
            json.append("\"downloads\":" + (int)(Math.random() * 50) + ",");
            json.append("\"reviews\":" + (int)(Math.random() * 20));
            
            json.append("}");
            
            first = false;
        }
        
        json.append("]");
        
        return json.toString();
    }
    
    /**
     * Escape special characters in JSON strings
     * 
     * @param input The input string
     * @return The escaped string
     */
    private String escapeJson(String input) {
        if (input == null) {
            return "";
        }
        
        return input.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
}
