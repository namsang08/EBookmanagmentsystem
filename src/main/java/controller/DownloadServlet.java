package controller;

import dao.BookDAO;
import dao.UserHistoryDAO;
import mode.Book;
import mode.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet for handling book downloads
 */
@WebServlet("/DownloadServlet")
public class DownloadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger LOGGER = Logger.getLogger(DownloadServlet.class.getName());
    
    private BookDAO bookDAO;
    private UserHistoryDAO userHistoryDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        bookDAO = new BookDAO();
        userHistoryDAO = new UserHistoryDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Check if user is logged in
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Get book ID
        int bookId = 0;
        try {
            bookId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid book ID parameter", e);
            response.sendRedirect(request.getContextPath() + "/browsebook.jsp");
            return;
        }
        
        try {
            // Get book details
            Book book = bookDAO.getBookById(bookId);
            
            if (book == null) {
                LOGGER.log(Level.WARNING, "Book not found: {0}", bookId);
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Book not found");
                return;
            }
            
            // Check if book is approved
            if (book.getStatus() != Book.Status.APPROVED) {
                // Allow authors to download their own books even if not approved
                if (user.getRole() != User.Role.ADMIN && book.getAuthorId() != user.getUserId()) {
                    LOGGER.log(Level.WARNING, "Unauthorized download attempt for unapproved book: {0}", bookId);
                    response.sendError(HttpServletResponse.SC_FORBIDDEN, "This book is not available for download");
                    return;
                }
            }
            
            // Get file path
            String filePath = getServletContext().getRealPath("") + File.separator + book.getFilePath();
            File downloadFile = new File(filePath);
            
            // Check if file exists
            if (!downloadFile.exists()) {
                LOGGER.log(Level.WARNING, "Book file not found: {0}", filePath);
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found");
                return;
            }
            
            // Increment download count (only if not the author downloading their own book)
            if (book.getAuthorId() != user.getUserId()) {
                try {
                    bookDAO.incrementDownloads(bookId);
                    
                    // Add to user history
                    userHistoryDAO.addToUserHistory(user.getUserId(), bookId, "download");
                } catch (SQLException e) {
                    // Log error but continue with download
                    LOGGER.log(Level.WARNING, "Error updating download statistics", e);
                }
            }
            
            // Set response headers
            String mimeType = getServletContext().getMimeType(filePath);
            if (mimeType == null) {
                mimeType = "application/octet-stream";
            }
            
            response.setContentType(mimeType);
            response.setContentLength((int) downloadFile.length());
            
            String headerKey = "Content-Disposition";
            String headerValue = String.format("attachment; filename=\"%s\"", downloadFile.getName());
            response.setHeader(headerKey, headerValue);
            
            // Stream file to response
            try (FileInputStream inStream = new FileInputStream(downloadFile);
                 OutputStream outStream = response.getOutputStream()) {
                
                byte[] buffer = new byte[4096];
                int bytesRead;
                
                while ((bytesRead = inStream.read(buffer)) != -1) {
                    outStream.write(buffer, 0, bytesRead);
                }
                
                LOGGER.log(Level.INFO, "Book downloaded successfully: {0} by user: {1}", 
                        new Object[]{book.getTitle(), user.getUserId()});
            } catch (IOException e) {
                LOGGER.log(Level.SEVERE, "Error streaming file to client", e);
                throw e;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Database error occurred", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error occurred");
        }
    }
}
