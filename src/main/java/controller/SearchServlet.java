package controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import dao.BookDAO;
import mode.Book;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/SearchServlet")
public class SearchServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private BookDAO bookDAO;
    
    public void init() {
        bookDAO = new BookDAO();
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String query = request.getParameter("query");
        String categoryId = request.getParameter("category");
        
        try {
            List<Book> searchResults;
            
            // If category filter is applied
            if (categoryId != null && !categoryId.isEmpty()) {
                searchResults = bookDAO.getBooksByCategory(Integer.parseInt(categoryId));
                
                // If search query is also provided, filter the results
                if (query != null && !query.isEmpty()) {
                    searchResults.removeIf(book -> 
                        !book.getTitle().toLowerCase().contains(query.toLowerCase()) &&
                        !book.getDescription().toLowerCase().contains(query.toLowerCase()) &&
                        !book.getAuthorName().toLowerCase().contains(query.toLowerCase()) &&
                        !(book.getTags() != null && book.getTags().toLowerCase().contains(query.toLowerCase()))
                    );
                }
            } 
            // If only search query is provided
            else if (query != null && !query.isEmpty()) {
                searchResults = bookDAO.searchBooks(query);
            } 
            // If no filters, show all public books
            else {
                searchResults = bookDAO.getPublicBooks();
            }
            
            request.setAttribute("books", searchResults);
            request.setAttribute("searchQuery", query);
            request.setAttribute("categoryId", categoryId);
            
            RequestDispatcher dispatcher = request.getRequestDispatcher("browsebook.jsp");
            dispatcher.forward(request, response);
            
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}