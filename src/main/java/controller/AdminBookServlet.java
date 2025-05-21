package controller;

import dao.BookDAO;
import dao.CategoryDAO;
import mode.Book;
import mode.Category;
import mode.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet for handling admin book operations
 */
@WebServlet("/admin/books/*")
@MultipartConfig
public class AdminBookServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AdminBookServlet.class.getName());
    private BookDAO bookDAO;
    private CategoryDAO categoryDAO;
    
    @Override
    public void init() {
        bookDAO = new BookDAO();
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
                // List all books
                listBooks(request, response);
            } else if (pathInfo.equals("/view")) {
                // View book details
                viewBook(request, response);
            } else if (pathInfo.equals("/edit")) {
                // Show edit book form
                showEditForm(request, response);
            } else if (pathInfo.equals("/add")) {
                // Show add book form
                showAddForm(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error processing book request", e);
            throw new ServletException("Error processing book request", e);
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
                // Add new book
                addBook(request, response);
            } else if ("update".equals(action)) {
                // Update existing book
                updateBook(request, response);
            } else if ("delete".equals(action)) {
                // Delete book
                deleteBook(request, response);
            } else if ("approve".equals(action)) {
                // Approve book
                approveBook(request, response);
            } else if ("reject".equals(action)) {
                // Reject book
                rejectBook(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (SQLException | ParseException e) {
            LOGGER.log(Level.SEVERE, "Error processing book action", e);
            throw new ServletException("Error processing book action", e);
        }
    }
    
    /**
     * List all books
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void listBooks(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        List<Book> books = bookDAO.getAllBooks();
        request.setAttribute("books", books);
        request.getRequestDispatcher("/admin/books.jsp").forward(request, response);
    }
    
    /**
     * View book details
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void viewBook(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        int bookId = Integer.parseInt(request.getParameter("id"));
        Book book = bookDAO.getBook(bookId);
        
        if (book != null) {
            request.setAttribute("book", book);
            request.getRequestDispatcher("/admin/book-details.jsp").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    
    /**
     * Show edit book form
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        int bookId = Integer.parseInt(request.getParameter("id"));
        Book book = bookDAO.getBook(bookId);
        
        if (book != null) {
            List<Category> categories = categoryDAO.getAllCategories();
            
            request.setAttribute("book", book);
            request.setAttribute("categories", categories);
            request.getRequestDispatcher("/admin/edit-book.jsp").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    
    /**
     * Show add book form
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void showAddForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        List<Category> categories = categoryDAO.getAllCategories();
        request.setAttribute("categories", categories);
        request.getRequestDispatcher("/admin/add-book.jsp").forward(request, response);
    }
    
    /**
     * Add new book
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     * @throws ParseException If a date parsing error occurs
     */
    private void addBook(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException, ParseException {
        // Extract book data from form
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        int authorId = Integer.parseInt(request.getParameter("authorId"));
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));
        String language = request.getParameter("language");
        int pages = Integer.parseInt(request.getParameter("pages"));
        String tags = request.getParameter("tags");
        
        // Parse publication date
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        Date publicationDate = dateFormat.parse(request.getParameter("publicationDate"));
        
        // Handle file uploads
        Part filePart = request.getPart("bookFile");
        Part coverPart = request.getPart("coverImage");
        
        String uploadPath = getServletContext().getRealPath("/uploads");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }
        
        // Save book file
        String bookFileName = UUID.randomUUID().toString() + getFileName(filePart);
        String bookFilePath = "/uploads/" + bookFileName;
        try (InputStream fileContent = filePart.getInputStream()) {
            Files.copy(fileContent, Paths.get(uploadPath + File.separator + bookFileName), 
                    StandardCopyOption.REPLACE_EXISTING);
        }
        
        // Save cover image
        String coverFileName = UUID.randomUUID().toString() + getFileName(coverPart);
        String coverFilePath = "/uploads/" + coverFileName;
        try (InputStream coverContent = coverPart.getInputStream()) {
            Files.copy(coverContent, Paths.get(uploadPath + File.separator + coverFileName), 
                    StandardCopyOption.REPLACE_EXISTING);
        }
        
        // Create and save book
        Book book = new Book();
        book.setTitle(title);
        book.setDescription(description);
        book.setAuthorId(authorId);
        book.setCategoryId(categoryId);
        book.setFilePath(bookFilePath);
        book.setCoverImagePath(coverFilePath);
        book.setLanguage(language);
        book.setPages(pages);
        book.setPublicationDate(publicationDate);
        book.setStatus(Book.Status.APPROVED); // Admin-added books are approved by default
        book.setTags(tags);
        
        bookDAO.insertBook(book);
        
        // Redirect to book list
        response.sendRedirect(request.getContextPath() + "/admin/books");
    }
    
    /**
     * Update existing book
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     * @throws ParseException If a date parsing error occurs
     */
    private void updateBook(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException, ParseException {
        int bookId = Integer.parseInt(request.getParameter("bookId"));
        Book book = bookDAO.getBook(bookId);
        
        if (book != null) {
            // Update book data
            book.setTitle(request.getParameter("title"));
            book.setDescription(request.getParameter("description"));
            book.setCategoryId(Integer.parseInt(request.getParameter("categoryId")));
            book.setLanguage(request.getParameter("language"));
            book.setPages(Integer.parseInt(request.getParameter("pages")));
            book.setTags(request.getParameter("tags"));
            
            // Handle file uploads if provided
            Part filePart = request.getPart("bookFile");
            Part coverPart = request.getPart("coverImage");
            
            String uploadPath = getServletContext().getRealPath("/uploads");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdir();
            }
            
            // Update book file if provided
            if (filePart != null && filePart.getSize() > 0) {
                String bookFileName = UUID.randomUUID().toString() + getFileName(filePart);
                String bookFilePath = "/uploads/" + bookFileName;
                try (InputStream fileContent = filePart.getInputStream()) {
                    Files.copy(fileContent, Paths.get(uploadPath + File.separator + bookFileName), 
                            StandardCopyOption.REPLACE_EXISTING);
                }
                book.setFilePath(bookFilePath);
            }
            
            // Update cover image if provided
            if (coverPart != null && coverPart.getSize() > 0) {
                String coverFileName = UUID.randomUUID().toString() + getFileName(coverPart);
                String coverFilePath = "/uploads/" + coverFileName;
                try (InputStream coverContent = coverPart.getInputStream()) {
                    Files.copy(coverContent, Paths.get(uploadPath + File.separator + coverFileName), 
                            StandardCopyOption.REPLACE_EXISTING);
                }
                book.setCoverImagePath(coverFilePath);
            }
            
            // Update book in database
            bookDAO.updateBook(book);
            
            // Redirect to book details
            response.sendRedirect(request.getContextPath() + "/admin/books/view?id=" + bookId);
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    
    /**
     * Delete book
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void deleteBook(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        int bookId = Integer.parseInt(request.getParameter("id"));
        
        // Delete book from database
        bookDAO.deleteBook(bookId);
        
        // Return success response for AJAX
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.print("{\"success\": true}");
        out.flush();
    }
    
    /**
     * Approve book
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void approveBook(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        int bookId = Integer.parseInt(request.getParameter("id"));
        
        // Update book status to APPROVED
        bookDAO.updateBookStatus(bookId, Book.Status.APPROVED);
        
        // Return success response for AJAX
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.print("{\"success\": true, \"status\": \"APPROVED\"}");
        out.flush();
    }
    
    /**
     * Reject book
     * 
     * @param request The HTTP request
     * @param response The HTTP response
     * @throws ServletException If a servlet error occurs
     * @throws IOException If an I/O error occurs
     * @throws SQLException If a database error occurs
     */
    private void rejectBook(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException, SQLException {
        int bookId = Integer.parseInt(request.getParameter("id"));
        
        // Update book status to REJECTED
        bookDAO.updateBookStatus(bookId, Book.Status.REJECTED);
        
        // Return success response for AJAX
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        out.print("{\"success\": true, \"status\": \"REJECTED\"}");
        out.flush();
    }
    
    /**
     * Get file name from Part
     * 
     * @param part The Part containing the file
     * @return The file name
     */
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        
        for (String item : items) {
            if (item.trim().startsWith("filename")) {
                return item.substring(item.indexOf("=") + 2, item.length() - 1);
            }
        }
        
        return "";
    }
}

