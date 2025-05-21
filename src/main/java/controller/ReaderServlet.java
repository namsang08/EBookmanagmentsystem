package controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

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

/**
 * Servlet for handling book reader functionality
 */
@WebServlet("/ReaderServlet")
public class ReaderServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ReaderServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "view";
        }
        
        switch (action) {
            case "getPageContent":
                getPageContent(request, response);
                break;
            default:
                response.sendRedirect("reader.jsp");
                break;
        }
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if (action == null) {
            response.sendRedirect("reader.jsp");
            return;
        }
        
        switch (action) {
            case "updateProgress":
                updateReadingProgress(request, response);
                break;
            case "addBookmark":
                addBookmark(request, response);
                break;
            case "removeBookmark":
                removeBookmark(request, response);
                break;
            default:
                response.sendRedirect("reader.jsp");
                break;
        }
    }
    
    /**
     * Get content for a specific page of a book
     */
    private void getPageContent(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int bookId = 0;
        int page = 1;
        
        try {
            bookId = Integer.parseInt(request.getParameter("bookId"));
            page = Integer.parseInt(request.getParameter("page"));
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        
        // In a real application, you would fetch the actual content for this page
        // For this example, we'll generate sample content
        String content = generateSampleContent(bookId, page);
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        out.print(content);
    }
    
    /**
     * Update user's reading progress
     */
    private void updateReadingProgress(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        int userId = 0;
        int bookId = 0;
        int currentPage = 1;
        
        try {
            userId = Integer.parseInt(request.getParameter("userId"));
            bookId = Integer.parseInt(request.getParameter("bookId"));
            currentPage = Integer.parseInt(request.getParameter("currentPage"));
            
            // Verify the user ID matches the logged-in user
            if (userId != currentUser.getUserId()) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            
            UserBookDAO userBookDAO = new UserBookDAO();
            boolean success = userBookDAO.updateReadingProgress(userId, bookId, currentPage);
            
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": " + success + "}");
            
        } catch (NumberFormatException | SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": false, \"error\": \"" + e.getMessage() + "\"}");
        }
    }
    
    /**
     * Add a bookmark for a user
     */
    private void addBookmark(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        int userId = 0;
        int bookId = 0;
        int page = 1;
        String title = "";
        
        try {
            userId = Integer.parseInt(request.getParameter("userId"));
            bookId = Integer.parseInt(request.getParameter("bookId"));
            page = Integer.parseInt(request.getParameter("page"));
            title = request.getParameter("title");
            
            // Verify the user ID matches the logged-in user
            if (userId != currentUser.getUserId()) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            
            // In a real application, you would save the bookmark to the database
            // For this example, we'll just return success
            
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": true}");
            
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": false, \"error\": \"" + e.getMessage() + "\"}");
        }
    }
    
    /**
     * Remove a bookmark for a user
     */
    private void removeBookmark(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        
        int userId = 0;
        int bookId = 0;
        int page = 1;
        
        try {
            userId = Integer.parseInt(request.getParameter("userId"));
            bookId = Integer.parseInt(request.getParameter("bookId"));
            page = Integer.parseInt(request.getParameter("page"));
            
            // Verify the user ID matches the logged-in user
            if (userId != currentUser.getUserId()) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            
            // In a real application, you would remove the bookmark from the database
            // For this example, we'll just return success
            
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": true}");
            
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print("{\"success\": false, \"error\": \"" + e.getMessage() + "\"}");
        }
    }
    
    /**
     * Generate sample content for a page
     */
    private String generateSampleContent(int bookId, int page) {
        StringBuilder content = new StringBuilder();
        
        // Add chapter heading for first page of chapters
        if (page % 10 == 1) {
            int chapterNum = (page / 10) + 1;
            content.append("<h1>Chapter ").append(chapterNum).append("</h1>");
            
            switch (chapterNum) {
                case 1:
                    content.append("<h2>Introduction</h2>");
                    break;
                case 2:
                    content.append("<h2>Getting Started</h2>");
                    break;
                case 3:
                    content.append("<h2>Advanced Concepts</h2>");
                    break;
                case 4:
                    content.append("<h2>Practical Applications</h2>");
                    break;
                case 5:
                    content.append("<h2>Case Studies</h2>");
                    break;
                default:
                    content.append("<h2>Additional Material</h2>");
            }
        }
        
        // Add paragraphs of content
        int paragraphs = 3 + (int)(Math.random() * 3); // 3-5 paragraphs per page
        for (int i = 0; i < paragraphs; i++) {
            content.append("<p>");
            
            // Generate 3-6 sentences per paragraph
            int sentences = 3 + (int)(Math.random() * 4);
            for (int j = 0; j < sentences; j++) {
                // Sample sentences
                String[] sampleSentences = {
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                    "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                    "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.",
                    "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum.",
                    "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia.",
                    "Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit.",
                    "Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet.",
                    "Consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt.",
                    "Ut labore et dolore magnam aliquam quaerat voluptatem.",
                    "Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse."
                };
                
                int index = (bookId * page * i * j) % sampleSentences.length;
                content.append(sampleSentences[index]).append(" ");
            }
            
            content.append("</p>");
        }
        
        // Add a figure or quote occasionally
        if (page % 5 == 0) {
            content.append("<blockquote>");
            content.append("\"The only way to learn a new programming language is by writing programs in it.\" - Dennis Ritchie");
            content.append("</blockquote>");
        }
        
        return content.toString();
    }
}
