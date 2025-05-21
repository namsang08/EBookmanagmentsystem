package controller;

import dao.AuthorDAO;
import dao.BookDAO;
import dao.UserDAO;
import mode.Book;
import mode.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet for handling admin dashboard
 */
@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AdminDashboardServlet.class.getName());
    private BookDAO bookDAO;
    private UserDAO userDAO;
    private AuthorDAO authorDAO;
    
    @Override
    public void init() {
        bookDAO = new BookDAO();
        userDAO = new UserDAO();
        authorDAO = new AuthorDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        // Check if user is logged in and is an admin
        if (user == null || user.getRole() != User.Role.ADMIN) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=unauthorized");
            return;
        }
        
        try {
            // Get statistics
            Map<String, Object> stats = new HashMap<>();
            
            // Get all books and users
            List<Book> allBooks = bookDAO.getAllBooks();
            List<User> allUsers = userDAO.getAllUsers();
            
            // Calculate statistics
            int totalBooks = allBooks.size();
            int totalUsers = allUsers.size();
            int totalAuthors = authorDAO.getTotalAuthorsCount();
            int totalDownloads = calculateTotalDownloads(allBooks);
            
            // Calculate growth percentages
            int bookGrowth = calculateBookGrowth(allBooks);
            int userGrowth = calculateUserGrowth(allUsers);
            int authorGrowth = calculateAuthorGrowth(allUsers);
            int downloadGrowth = 5; // Placeholder
            
            // Add statistics to the map
            stats.put("totalBooks", totalBooks);
            stats.put("totalUsers", totalUsers);
            stats.put("totalAuthors", totalAuthors);
            stats.put("totalDownloads", totalDownloads);
            stats.put("bookGrowth", bookGrowth);
            stats.put("userGrowth", userGrowth);
            stats.put("authorGrowth", authorGrowth);
            stats.put("downloadGrowth", downloadGrowth);
            
            // Get recent books (5 most recent)
            List<Book> recentBooks = getRecentBooks(allBooks, 5);
            
            // Get recent users (5 most recent)
            List<User> recentUsers = getRecentUsers(allUsers, 5);
            
            // Set attributes for the JSP
            request.setAttribute("stats", stats);
            request.setAttribute("recentBooks", recentBooks);
            request.setAttribute("recentUsers", recentUsers);
            
            // Forward to the dashboard JSP
            request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving data for admin dashboard", e);
            response.sendRedirect(request.getContextPath() + "/error.jsp?message=Database error");
        }
    }
    
    private int calculateTotalDownloads(List<Book> books) {
        int total = 0;
        for (Book book : books) {
            total += book.getDownloads();
        }
        return total;
    }
    
    private int calculateBookGrowth(List<Book> books) {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MONTH, -1);
        Date oneMonthAgo = cal.getTime();
        
        cal.add(Calendar.MONTH, -1);
        Date twoMonthsAgo = cal.getTime();
        
        int lastMonthBooks = 0;
        int prevMonthBooks = 0;
        
        for (Book book : books) {
            Date uploadDate = new Date(book.getUploadDate().getTime());
            if (uploadDate.after(oneMonthAgo)) {
                lastMonthBooks++;
            } else if (uploadDate.after(twoMonthsAgo)) {
                prevMonthBooks++;
            }
        }
        
        return prevMonthBooks > 0 ? ((lastMonthBooks - prevMonthBooks) * 100 / prevMonthBooks) : 0;
    }
    
    private int calculateUserGrowth(List<User> users) {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MONTH, -1);
        Date oneMonthAgo = cal.getTime();
        
        cal.add(Calendar.MONTH, -1);
        Date twoMonthsAgo = cal.getTime();
        
        int lastMonthUsers = 0;
        int prevMonthUsers = 0;
        
        for (User user : users) {
            Date regDate = new Date(user.getRegistrationDate().getTime());
            if (regDate.after(oneMonthAgo)) {
                lastMonthUsers++;
            } else if (regDate.after(twoMonthsAgo)) {
                prevMonthUsers++;
            }
        }
        
        return prevMonthUsers > 0 ? ((lastMonthUsers - prevMonthUsers) * 100 / prevMonthUsers) : 0;
    }
    
    private int calculateAuthorGrowth(List<User> users) {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MONTH, -1);
        Date oneMonthAgo = cal.getTime();
        
        cal.add(Calendar.MONTH, -1);
        Date twoMonthsAgo = cal.getTime();
        
        int lastMonthAuthors = 0;
        int prevMonthAuthors = 0;
        
        for (User user : users) {
            if (user.getRole() == User.Role.AUTHOR) {
                Date regDate = new Date(user.getRegistrationDate().getTime());
                if (regDate.after(oneMonthAgo)) {
                    lastMonthAuthors++;
                } else if (regDate.after(twoMonthsAgo)) {
                    prevMonthAuthors++;
                }
            }
        }
        
        return prevMonthAuthors > 0 ? ((lastMonthAuthors - prevMonthAuthors) * 100 / prevMonthAuthors) : 0;
    }
    
    private List<Book> getRecentBooks(List<Book> allBooks, int limit) {
        // Sort books by upload date (descending)
        allBooks.sort((b1, b2) -> b2.getUploadDate().compareTo(b1.getUploadDate()));
        
        // Return the first 'limit' books or all if fewer
        return allBooks.size() > limit ? allBooks.subList(0, limit) : allBooks;
    }
    
    private List<User> getRecentUsers(List<User> allUsers, int limit) {
        // Sort users by registration date (descending)
        allUsers.sort((u1, u2) -> u2.getRegistrationDate().compareTo(u1.getRegistrationDate()));
        
        // Return the first 'limit' users or all if fewer
        return allUsers.size() > limit ? allUsers.subList(0, limit) : allUsers;
    }
}
