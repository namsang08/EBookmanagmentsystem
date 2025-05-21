package controller;

import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import dao.BookDAO;
import mode.Book;
import mode.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@WebServlet("/UploadBookServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1 MB
    maxFileSize = 1024 * 1024 * 10,  // 10 MB
    maxRequestSize = 1024 * 1024 * 50 // 50 MB
)
public class FileUploadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private BookDAO bookDAO;
    
    public void init() {
        bookDAO = new BookDAO();
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || user.getRole() != User.Role.AUTHOR) {
            response.sendRedirect("access-denied.jsp");
            return;
        }
        
        // Create upload directory if it doesn't exist
        String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }
        
        // Create separate directories for books and covers
        String bookUploadPath = uploadPath + File.separator + "books";
        String coverUploadPath = uploadPath + File.separator + "covers";
        
        File bookUploadDir = new File(bookUploadPath);
        File coverUploadDir = new File(coverUploadPath);
        
        if (!bookUploadDir.exists()) {
            bookUploadDir.mkdir();
        }
        
        if (!coverUploadDir.exists()) {
            coverUploadDir.mkdir();
        }
        
        try {
            // Get form fields
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            int categoryId = Integer.parseInt(request.getParameter("category"));
            String language = request.getParameter("language");
            int pages = 0;
            if (request.getParameter("pages") != null && !request.getParameter("pages").isEmpty()) {
                pages = Integer.parseInt(request.getParameter("pages"));
            }
            
            Date publicationDate = null;
            if (request.getParameter("publicationDate") != null && !request.getParameter("publicationDate").isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                publicationDate = sdf.parse(request.getParameter("publicationDate"));
            } else {
                publicationDate = new Date(); // Default to current date
            }
            
            String tags = request.getParameter("tags");
            
            // Process file uploads
            Part bookFilePart = request.getPart("bookFile");
            Part coverImagePart = request.getPart("coverImage");
            
            // Generate unique filenames
            String bookFileName = getUniqueFileName(getSubmittedFileName(bookFilePart));
            String coverFileName = getUniqueFileName(getSubmittedFileName(coverImagePart));
            
            // Save files
            String bookFilePath = "uploads/books/" + bookFileName;
            String coverImagePath = "uploads/covers/" + coverFileName;
            
            bookFilePart.write(bookUploadPath + File.separator + bookFileName);
            coverImagePart.write(coverUploadPath + File.separator + coverFileName);
            
            // Create book object
            Book book = new Book();
            book.setTitle(title);
            book.setDescription(description);
            book.setAuthorId(user.getUserId());
            book.setCategoryId(categoryId);
            book.setFilePath(bookFilePath);
            book.setCoverImagePath(coverImagePath);
            book.setLanguage(language);
            book.setPages(pages);
            book.setPublicationDate(publicationDate);
            book.setStatus(Book.Status.PENDING); // New books are pending approval
            book.setTags(tags);
            
            // Save to database
            bookDAO.insertBook(book);
            
            // Redirect to success page
            response.sendRedirect("author/dashboard.jsp?upload=success");
            
        } catch (SQLException | ParseException e) {
            e.printStackTrace();
            response.sendRedirect("author/upload-book.jsp?error=true");
        }
    }
    
    // Helper method to get the submitted filename
    private String getSubmittedFileName(Part part) {
        for (String cd : part.getHeader("content-disposition").split(";")) {
            if (cd.trim().startsWith("filename")) {
                String fileName = cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
                return fileName.substring(fileName.lastIndexOf('/') + 1).substring(fileName.lastIndexOf('\\') + 1);
            }
        }
        return null;
    }
    
    // Helper method to generate a unique filename
    private String getUniqueFileName(String originalFileName) {
        return System.currentTimeMillis() + "_" + originalFileName;
    }
}
