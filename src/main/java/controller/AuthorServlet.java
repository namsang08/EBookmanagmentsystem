package controller;

import dao.BookDAO;
import dao.CategoryDAO;
import mode.Book;
import mode.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.UUID;

/**
 * Servlet for handling author-related actions
 */
@WebServlet("/AuthorServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1 MB
    maxFileSize = 1024 * 1024 * 10,  // 10 MB
    maxRequestSize = 1024 * 1024 * 15 // 15 MB
)
public class AuthorServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private BookDAO bookDAO;
    private CategoryDAO categoryDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        bookDAO = new BookDAO();
        categoryDAO = new CategoryDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        try {
            if (action == null) {
                response.sendRedirect(request.getContextPath() + "/author/dashboard.jsp");
            } else if (action.equals("getBookDetails")) {
                getBookDetails(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/author/dashboard.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred: " + e.getMessage());
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        try {
            if (action == null) {
                response.sendRedirect(request.getContextPath() + "/author/dashboard.jsp");
            } else if (action.equals("uploadBook")) {
                uploadBook(request, response);
            } else if (action.equals("updateBook")) {
                updateBook(request, response);
            } else if (action.equals("deleteBook")) {
                deleteBook(request, response);
            } else if (action.equals("updateProfile")) {
                updateProfile(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/author/dashboard.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred: " + e.getMessage());
        }
    }
    
    /**
     * Get book details in JSON format
     */
    private void getBookDetails(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        int bookId = Integer.parseInt(request.getParameter("bookId"));
        Book book = bookDAO.getBookById(bookId);
        
        if (book != null) {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            // Create JSON manually using StringBuilder
            StringBuilder json = new StringBuilder();
            json.append("{");
            appendJsonField(json, "bookId", book.getBookId(), true);
            appendJsonField(json, "title", escapeJsonString(book.getTitle()), true);
            appendJsonField(json, "description", escapeJsonString(book.getDescription()), true);
            appendJsonField(json, "authorId", book.getAuthorId(), true);
            appendJsonField(json, "categoryId", book.getCategoryId(), true);
            appendJsonField(json, "filePath", escapeJsonString(book.getFilePath()), true);
            appendJsonField(json, "coverImagePath", escapeJsonString(book.getCoverImagePath()), true);
            appendJsonField(json, "language", escapeJsonString(book.getLanguage()), true);
            appendJsonField(json, "pages", book.getPages(), true);
            appendJsonField(json, "publicationDate", book.getPublicationDate().getTime(), true);
            appendJsonField(json, "uploadDate", book.getUploadDate().getTime(), true);
            appendJsonField(json, "views", book.getViews(), true);
            appendJsonField(json, "downloads", book.getDownloads(), true);
            appendJsonField(json, "status", escapeJsonString(book.getStatus().toString()), true);
            appendJsonField(json, "tags", escapeJsonString(book.getTags() != null ? book.getTags() : ""), true);
            appendJsonField(json, "authorName", escapeJsonString(book.getAuthorName()), true);
            appendJsonField(json, "categoryName", escapeJsonString(book.getCategoryName()), true);
            appendJsonField(json, "rating", book.getRating(), true);
            appendJsonField(json, "format", escapeJsonString(book.getFormat() != null ? book.getFormat() : "PDF"), true);
            appendJsonField(json, "fileSize", escapeJsonString(book.getFileSize() != null ? book.getFileSize() : "Unknown"), false);
            json.append("}");
            
            PrintWriter out = response.getWriter();
            out.print(json.toString());
            out.flush();
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Book not found");
        }
    }
    
    /**
     * Helper method to append a field to the JSON string
     */
    private void appendJsonField(StringBuilder json, String key, Object value, boolean addComma) {
        json.append("\"").append(key).append("\":");
        
        if (value instanceof String) {
            json.append("\"").append(value).append("\"");
        } else {
            json.append(value);
        }
        
        if (addComma) {
            json.append(",");
        }
    }
    
    /**
     * Helper method to escape special characters in JSON strings
     */
    private String escapeJsonString(String input) {
        if (input == null) {
            return "";
        }
        
        StringBuilder result = new StringBuilder();
        for (int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);
            switch (c) {
                case '\\':
                    result.append("\\\\");
                    break;
                case '\"':
                    result.append("\\\"");
                    break;
                case '\b':
                    result.append("\\b");
                    break;
                case '\f':
                    result.append("\\f");
                    break;
                case '\n':
                    result.append("\\n");
                    break;
                case '\r':
                    result.append("\\r");
                    break;
                case '\t':
                    result.append("\\t");
                    break;
                default:
                    // Unicode escape for control characters
                    if (c < ' ') {
                        String hex = Integer.toHexString(c);
                        result.append("\\u");
                        for (int j = 0; j < 4 - hex.length(); j++) {
                            result.append('0');
                        }
                        result.append(hex);
                    } else {
                        result.append(c);
                    }
            }
        }
        return result.toString();
    }
    
    /**
     * Upload a new book
     */
    private void uploadBook(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException, SQLException, ParseException {
        // Check if user is logged in and is an author
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRole() != User.Role.AUTHOR) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Get form data
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));
        String language = request.getParameter("language");
        int pages = Integer.parseInt(request.getParameter("pages"));
        String publicationDateStr = request.getParameter("publicationDate");
        String tags = request.getParameter("tags");
        
        // Parse publication date
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        Date publicationDate = dateFormat.parse(publicationDateStr);
        
        // Get uploaded files
        Part bookFilePart = request.getPart("bookFile");
        Part coverImagePart = request.getPart("coverImage");
        
        // Create directories if they don't exist
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }
        
        String booksPath = uploadPath + File.separator + "books";
        File booksDir = new File(booksPath);
        if (!booksDir.exists()) {
            booksDir.mkdir();
        }
        
        String imagesPath = uploadPath + File.separator + "covers";
        File imagesDir = new File(imagesPath);
        if (!imagesDir.exists()) {
            imagesDir.mkdir();
        }
        
        // Generate unique filenames
        String bookFileName = UUID.randomUUID().toString() + "_" + getFileName(bookFilePart);
        String coverFileName = UUID.randomUUID().toString() + "_" + getFileName(coverImagePart);
        
        // Save files
        bookFilePart.write(booksPath + File.separator + bookFileName);
        coverImagePart.write(imagesPath + File.separator + coverFileName);
        
        // Create book object
        Book book = new Book();
        book.setTitle(title);
        book.setDescription(description);
        book.setAuthorId(user.getUserId());
        book.setCategoryId(categoryId);
        book.setLanguage(language);
        book.setPages(pages);
        book.setPublicationDate(publicationDate);
        book.setUploadDate(new Date());
        book.setFilePath("uploads/books/" + bookFileName);
        book.setCoverImagePath("uploads/covers/" + coverFileName);
        book.setViews(0);
        book.setDownloads(0);
        book.setStatus(Book.Status.PENDING);
        book.setTags(tags);
        
        // Calculate file size
        File bookFile = new File(booksPath + File.separator + bookFileName);
        long fileSizeInBytes = bookFile.length();
        String fileSize;
        
        if (fileSizeInBytes < 1024) {
            fileSize = fileSizeInBytes + " B";
        } else if (fileSizeInBytes < 1024 * 1024) {
            fileSize = String.format("%.2f KB", fileSizeInBytes / 1024.0);
        } else {
            fileSize = String.format("%.2f MB", fileSizeInBytes / (1024.0 * 1024));
        }
        
        book.setFileSize(fileSize);
        
        // Save book to database
        try {
            bookDAO.insertBook(book);
            request.getSession().setAttribute("message", "Book uploaded successfully! It will be reviewed by an administrator.");
            response.sendRedirect(request.getContextPath() + "/author/my-books.jsp");
        } catch (SQLException e) {
            request.getSession().setAttribute("error", "Failed to upload book. Please try again.");
            response.sendRedirect(request.getContextPath() + "/author/upload-book.jsp");
            throw e;
        }
    }
    
    /**
     * Update an existing book
     */
    private void updateBook(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException, SQLException, ParseException {
        // Check if user is logged in and is an author
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRole() != User.Role.AUTHOR) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Get book ID and check if book exists and belongs to the author
        int bookId = Integer.parseInt(request.getParameter("bookId"));
        Book existingBook = bookDAO.getBookById(bookId);
        
        if (existingBook == null || existingBook.getAuthorId() != user.getUserId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You don't have permission to edit this book");
            return;
        }
        
        // Get form data
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));
        String language = request.getParameter("language");
        int pages = Integer.parseInt(request.getParameter("pages"));
        String publicationDateStr = request.getParameter("publicationDate");
        String tags = request.getParameter("tags");
        
        // Parse publication date
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        Date publicationDate = dateFormat.parse(publicationDateStr);
        
        // Update book object
        existingBook.setTitle(title);
        existingBook.setDescription(description);
        existingBook.setCategoryId(categoryId);
        existingBook.setLanguage(language);
        existingBook.setPages(pages);
        existingBook.setPublicationDate(publicationDate);
        existingBook.setTags(tags);
        
        // Check if new files are uploaded
        Part bookFilePart = request.getPart("bookFile");
        Part coverImagePart = request.getPart("coverImage");
        
        if (bookFilePart != null && bookFilePart.getSize() > 0) {
            // Create directory if it doesn't exist
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            String booksPath = uploadPath + File.separator + "books";
            File booksDir = new File(booksPath);
            if (!booksDir.exists()) {
                booksDir.mkdir();
            }
            
            // Delete old file if it exists
            String oldFilePath = getServletContext().getRealPath("") + File.separator + existingBook.getFilePath();
            File oldFile = new File(oldFilePath);
            if (oldFile.exists()) {
                oldFile.delete();
            }
            
            // Generate unique filename
            String bookFileName = UUID.randomUUID().toString() + "_" + getFileName(bookFilePart);
            
            // Save new file
            bookFilePart.write(booksPath + File.separator + bookFileName);
            
            // Update file path
            existingBook.setFilePath("uploads/books/" + bookFileName);
            
            // Calculate file size
            File bookFile = new File(booksPath + File.separator + bookFileName);
            long fileSizeInBytes = bookFile.length();
            String fileSize;
            
            if (fileSizeInBytes < 1024) {
                fileSize = fileSizeInBytes + " B";
            } else if (fileSizeInBytes < 1024 * 1024) {
                fileSize = String.format("%.2f KB", fileSizeInBytes / 1024.0);
            } else {
                fileSize = String.format("%.2f MB", fileSizeInBytes / (1024.0 * 1024));
            }
            
            existingBook.setFileSize(fileSize);
        }
        
        if (coverImagePart != null && coverImagePart.getSize() > 0) {
            // Create directory if it doesn't exist
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            String imagesPath = uploadPath + File.separator + "covers";
            File imagesDir = new File(imagesPath);
            if (!imagesDir.exists()) {
                imagesDir.mkdir();
            }
            
            // Delete old file if it exists
            String oldFilePath = getServletContext().getRealPath("") + File.separator + existingBook.getCoverImagePath();
            File oldFile = new File(oldFilePath);
            if (oldFile.exists()) {
                oldFile.delete();
            }
            
            // Generate unique filename
            String coverFileName = UUID.randomUUID().toString() + "_" + getFileName(coverImagePart);
            
            // Save new file
            coverImagePart.write(imagesPath + File.separator + coverFileName);
            
            // Update cover image path
            existingBook.setCoverImagePath("uploads/covers/" + coverFileName);
        }
        
        // Set status back to pending if it was rejected
        if (existingBook.getStatus() == Book.Status.REJECTED) {
            existingBook.setStatus(Book.Status.PENDING);
        }
        
        // Update book in database
        try {
            bookDAO.updateBook(existingBook);
            request.getSession().setAttribute("message", "Book updated successfully!");
            response.sendRedirect(request.getContextPath() + "/author/my-books.jsp");
        } catch (SQLException e) {
            request.getSession().setAttribute("error", "Failed to update book. Please try again.");
            response.sendRedirect(request.getContextPath() + "/author/edit-book.jsp?id=" + bookId);
            throw e;
        }
    }
    
    /**
     * Delete a book
     */
    private void deleteBook(HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException {
        // Check if user is logged in and is an author
        User user = (User) request.getSession().getAttribute("user");
        if (user == null || user.getRole() != User.Role.AUTHOR) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Get book ID and check if book exists and belongs to the author
        int bookId = Integer.parseInt(request.getParameter("bookId"));
        Book existingBook = bookDAO.getBookById(bookId);
        
        if (existingBook == null || existingBook.getAuthorId() != user.getUserId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You don't have permission to delete this book");
            return;
        }
        
        // Delete files
        String bookFilePath = getServletContext().getRealPath("") + File.separator + existingBook.getFilePath();
        String coverImagePath = getServletContext().getRealPath("") + File.separator + existingBook.getCoverImagePath();
        
        File bookFile = new File(bookFilePath);
        if (bookFile.exists()) {
            bookFile.delete();
        }
        
        File coverImage = new File(coverImagePath);
        if (coverImage.exists()) {
            coverImage.delete();
        }
        
        // Delete book from database
        try {
            bookDAO.deleteBook(bookId);
            request.getSession().setAttribute("message", "Book deleted successfully!");
        } catch (SQLException e) {
            request.getSession().setAttribute("error", "Failed to delete book. Please try again.");
            throw e;
        }
        
        response.sendRedirect(request.getContextPath() + "/author/my-books.jsp");
    }
    
    /**
     * Update author profile
     */
    private void updateProfile(HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException {
        // Implementation for updating author profile
        // This will be implemented in a separate method
        response.sendRedirect(request.getContextPath() + "/author/profile.jsp");
    }
    
    /**
     * Get filename from Part
     */
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        
        return "";
    }
}
