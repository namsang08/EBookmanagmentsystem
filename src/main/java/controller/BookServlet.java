package controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import dao.BookDAO;
import mode.Book;
import mode.User;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/BookServlet")
public class BookServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private BookDAO bookDAO;
    
    public void init() {
        bookDAO = new BookDAO();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "new":
                    showNewForm(request, response);
                    break;
                case "insert":
                    insertBook(request, response);
                    break;
                case "delete":
                    deleteBook(request, response);
                    break;
                case "edit":
                    showEditForm(request, response);
                    break;
                case "update":
                    updateBook(request, response);
                    break;
                case "view":
                    viewBook(request, response);
                    break;
                case "search":
                    searchBooks(request, response);
                    break;
                case "list":
                default:
                    listBooks(request, response);
                    break;
            }
        } catch (SQLException ex) {
            throw new ServletException(ex);
        }
    }

    private void listBooks(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        List<Book> books;
        
        // If user is an author, show only their books
        if (user != null && user.getRole() == User.Role.AUTHOR) {
            books = bookDAO.getBooksByAuthor(user.getUserId());
            request.setAttribute("books", books);
            RequestDispatcher dispatcher = request.getRequestDispatcher("author/my-books.jsp");
            dispatcher.forward(request, response);
        } 
        // If user is admin, show all books
        else if (user != null && user.getRole() == User.Role.ADMIN) {
            books = bookDAO.getAllBooks();
            request.setAttribute("books", books);
            RequestDispatcher dispatcher = request.getRequestDispatcher("admin/books.jsp");
            dispatcher.forward(request, response);
        } 
        // Otherwise, show public books
        else {
            books = bookDAO.getPublicBooks();
            request.setAttribute("books", books);
            RequestDispatcher dispatcher = request.getRequestDispatcher("browsebook.jsp");
            dispatcher.forward(request, response);
        }
    }

    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher("author/upload-book.jsp");
        dispatcher.forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Book existingBook = bookDAO.getBook(id);
        
        // Check if user has permission to edit this book
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || (user.getRole() != User.Role.ADMIN && 
                (user.getRole() != User.Role.AUTHOR || existingBook.getAuthorId() != user.getUserId()))) {
            response.sendRedirect("access-denied.jsp");
            return;
        }
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("author/edit-book.jsp");
        request.setAttribute("book", existingBook);
        dispatcher.forward(request, response);
    }

    private void insertBook(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || user.getRole() != User.Role.AUTHOR) {
            response.sendRedirect("access-denied.jsp");
            return;
        }
        
        // Book details will be handled by the file upload servlet
        // This is just a placeholder for the basic flow
        response.sendRedirect("author/dashboard.jsp");
    }

    private void updateBook(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        int id = Integer.parseInt(request.getParameter("id"));
        
        // Check if user has permission to update this book
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Book existingBook = bookDAO.getBook(id);
        
        if (user == null || (user.getRole() != User.Role.ADMIN && 
                (user.getRole() != User.Role.AUTHOR || existingBook.getAuthorId() != user.getUserId()))) {
            response.sendRedirect("access-denied.jsp");
            return;
        }
        
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        int categoryId = Integer.parseInt(request.getParameter("category"));
        
        Book book = new Book();
        book.setBookId(id);
        book.setTitle(title);
        book.setDescription(description);
        book.setCategoryId(categoryId);
        // Other fields would be set here
        
        bookDAO.updateBook(book);
        
        if (user.getRole() == User.Role.ADMIN) {
            response.sendRedirect("BookServlet?action=list");
        } else {
            response.sendRedirect("author/my-books.jsp");
        }
    }

    private void deleteBook(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        int id = Integer.parseInt(request.getParameter("id"));
        
        // Check if user has permission to delete this book
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        Book existingBook = bookDAO.getBook(id);
        
        if (user == null || (user.getRole() != User.Role.ADMIN && 
                (user.getRole() != User.Role.AUTHOR || existingBook.getAuthorId() != user.getUserId()))) {
            response.sendRedirect("access-denied.jsp");
            return;
        }
        
        bookDAO.deleteBook(id);
        
        if (user.getRole() == User.Role.ADMIN) {
            response.sendRedirect("BookServlet?action=list");
        } else {
            response.sendRedirect("author/my-books.jsp");
        }
    }

    private void viewBook(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        Book book = bookDAO.getBook(id);
        
        // Increment view count
        bookDAO.incrementViewCount(id);
        
        request.setAttribute("book", book);
        RequestDispatcher dispatcher = request.getRequestDispatcher("bookdetails.jsp");
        dispatcher.forward(request, response);
    }
    
    private void searchBooks(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        String query = request.getParameter("query");
        List<Book> searchResults = bookDAO.searchBooks(query);
        
        request.setAttribute("books", searchResults);
        request.setAttribute("searchQuery", query);
        RequestDispatcher dispatcher = request.getRequestDispatcher("browsebook.jsp");
        dispatcher.forward(request, response);
    }
}