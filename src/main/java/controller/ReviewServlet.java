package controller;

import dao.BookDAO;
import dao.ReviewDAO;
import mode.Review;
import mode.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Date;

/**
 * Servlet for handling review-related actions
 */
@WebServlet("/ReviewServlet")
public class ReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private ReviewDAO reviewDAO;
    private BookDAO bookDAO;
    
    @Override
    public void init() throws ServletException {
        super.init();
        reviewDAO = new ReviewDAO();
        bookDAO = new BookDAO();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        
        try {
            if (action == null) {
                response.sendRedirect(request.getContextPath() + "/browsebook.jsp");
            } else if (action.equals("addReview")) {
                addReview(request, response);
            } else if (action.equals("updateReview")) {
                updateReview(request, response);
            } else if (action.equals("deleteReview")) {
                deleteReview(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/browsebook.jsp");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException(e);
        }
    }
    
    /**
     * Add a new review
     */
    private void addReview(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        // Check if user is logged in
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Get form data
        int bookId = Integer.parseInt(request.getParameter("bookId"));
        double rating = Double.parseDouble(request.getParameter("rating"));
        String comment = request.getParameter("comment");
        
        // Check if user has already reviewed this book
        if (reviewDAO.hasUserReviewedBook(user.getUserId(), bookId)) {
            request.getSession().setAttribute("error", "You have already reviewed this book.");
            response.sendRedirect(request.getContextPath() + "/bookdetails.jsp?id=" + bookId);
            return;
        }
        
        // Create review object
        Review review = new Review();
        review.setBookId(bookId);
        review.setUserId(user.getUserId());
        review.setRating(rating);
        review.setComment(comment);
        review.setReviewDate(new Date());
        
        // Save review to database
        boolean success = reviewDAO.addReview(review);
        
        if (success) {
            // Update book rating
            double avgRating = reviewDAO.getAverageRatingForBook(bookId);
            bookDAO.updateBookRating(bookId, avgRating);
            
            request.getSession().setAttribute("message", "Review submitted successfully!");
        } else {
            request.getSession().setAttribute("error", "Failed to submit review. Please try again.");
        }
        
        // Redirect back to book details page
        response.sendRedirect(request.getContextPath() + "/bookdetails.jsp?id=" + bookId);
    }
    
    /**
     * Update an existing review
     */
    private void updateReview(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        // Check if user is logged in
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Get form data
        int reviewId = Integer.parseInt(request.getParameter("reviewId"));
        int bookId = Integer.parseInt(request.getParameter("bookId"));
        double rating = Double.parseDouble(request.getParameter("rating"));
        String comment = request.getParameter("comment");
        
        // Get the review to check ownership
        Review existingReview = reviewDAO.getReviewById(reviewId);
        if (existingReview == null || (existingReview.getUserId() != user.getUserId() && user.getRole() != User.Role.ADMIN)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You don't have permission to update this review");
            return;
        }
        
        // Update review object
        existingReview.setRating(rating);
        existingReview.setComment(comment);
        
        // Save review to database
        boolean success = reviewDAO.updateReview(existingReview);
        
        if (success) {
            // Update book rating
            double avgRating = reviewDAO.getAverageRatingForBook(bookId);
            bookDAO.updateBookRating(bookId, avgRating);
            
            request.getSession().setAttribute("message", "Review updated successfully!");
        } else {
            request.getSession().setAttribute("error", "Failed to update review. Please try again.");
        }
        
        // Redirect back to book details page
        response.sendRedirect(request.getContextPath() + "/bookdetails.jsp?id=" + bookId);
    }
    
    /**
     * Delete a review
     */
    private void deleteReview(HttpServletRequest request, HttpServletResponse response) throws SQLException, IOException {
        // Check if user is logged in
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        // Get review ID and book ID
        int reviewId = Integer.parseInt(request.getParameter("reviewId"));
        int bookId = Integer.parseInt(request.getParameter("bookId"));
        
        // Check if user is admin or the review owner
        Review review = reviewDAO.getReviewById(reviewId);
        if (review == null || (review.getUserId() != user.getUserId() && user.getRole() != User.Role.ADMIN)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "You don't have permission to delete this review");
            return;
        }
        
        // Delete review from database
        boolean success = reviewDAO.deleteReview(reviewId);
        
        if (success) {
            // Update book rating
            double avgRating = reviewDAO.getAverageRatingForBook(bookId);
            bookDAO.updateBookRating(bookId, avgRating);
            
            request.getSession().setAttribute("message", "Review deleted successfully!");
        } else {
            request.getSession().setAttribute("error", "Failed to delete review. Please try again.");
        }
        
        // Redirect back to book details page or reviews page
        String referer = request.getHeader("Referer");
        if (referer != null && !referer.isEmpty()) {
            response.sendRedirect(referer);
        } else {
            response.sendRedirect(request.getContextPath() + "/bookdetails.jsp?id=" + bookId);
        }
    }
}
