package dao;

import mode.Review;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for Review-related database operations
 */
public class ReviewDAO {
    
    /**
     * Add a new review to the database
     * 
     * @param review The Review object to add
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean addReview(Review review) throws SQLException {
        String sql = "INSERT INTO reviews (book_id, user_id, rating, comment, review_date) " +
                     "VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setInt(1, review.getBookId());
            pstmt.setInt(2, review.getUserId());
            pstmt.setDouble(3, review.getRating());
            pstmt.setString(4, review.getComment());
            pstmt.setTimestamp(5, new java.sql.Timestamp(review.getReviewDate().getTime()));
            
            int rowsAffected = pstmt.executeUpdate();
            
            if (rowsAffected > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        review.setReviewId(generatedKeys.getInt(1));
                        return true;
                    }
                }
            }
            return false;
        }
    }
    
    /**
     * Get a review by its ID
     * 
     * @param reviewId The ID of the review to retrieve
     * @return The Review object if found, null otherwise
     * @throws SQLException If a database error occurs
     */
    public Review getReviewById(int reviewId) throws SQLException {
        String sql = "SELECT r.*, u.first_name, u.last_name, b.title " +
                     "FROM reviews r " +
                     "JOIN users u ON r.user_id = u.user_id " +
                     "JOIN books b ON r.book_id = b.book_id " +
                     "WHERE r.review_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, reviewId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractReviewFromResultSet(rs);
                }
            }
        }
        
        return null;
    }
    
    /**
     * Get reviews for a specific book
     * 
     * @param bookId The ID of the book
     * @return List of Review objects
     * @throws SQLException If a database error occurs
     */
    public List<Review> getReviewsByBook(int bookId) throws SQLException {
        List<Review> reviews = new ArrayList<>();
        
        String sql = "SELECT r.*, u.first_name, u.last_name, b.title, b.cover_image_path " +
                     "FROM reviews r " +
                     "JOIN users u ON r.user_id = u.user_id " +
                     "JOIN books b ON r.book_id = b.book_id " +
                     "WHERE r.book_id = ? " +
                     "ORDER BY r.review_date DESC";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    reviews.add(extractReviewFromResultSet(rs));
                }
            }
        }
        
        return reviews;
    }
    
    /**
     * Get recent reviews for books by a specific author
     * 
     * @param authorId The ID of the author
     * @param limit The maximum number of reviews to return
     * @return List of Review objects
     * @throws SQLException If a database error occurs
     */
    public List<Review> getRecentReviewsByAuthor(int authorId, int limit) throws SQLException {
        List<Review> reviews = new ArrayList<>();
        
        String sql = "SELECT r.*, u.first_name, u.last_name, b.title, b.cover_image_path " +
                     "FROM reviews r " +
                     "JOIN users u ON r.user_id = u.user_id " +
                     "JOIN books b ON r.book_id = b.book_id " +
                     "WHERE b.author_id = ? " +
                     "ORDER BY r.review_date DESC " +
                     "LIMIT ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, authorId);
            pstmt.setInt(2, limit);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    reviews.add(extractReviewFromResultSet(rs));
                }
            }
        }
        
        return reviews;
    }
    
    /**
     * Get reviews by a specific user
     * 
     * @param userId The ID of the user
     * @return List of Review objects
     * @throws SQLException If a database error occurs
     */
    public List<Review> getReviewsByUser(int userId) throws SQLException {
        List<Review> reviews = new ArrayList<>();
        
        String sql = "SELECT r.*, u.first_name, u.last_name, b.title, b.cover_image_path " +
                     "FROM reviews r " +
                     "JOIN users u ON r.user_id = u.user_id " +
                     "JOIN books b ON r.book_id = b.book_id " +
                     "WHERE r.user_id = ? " +
                     "ORDER BY r.review_date DESC";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    reviews.add(extractReviewFromResultSet(rs));
                }
            }
        }
        
        return reviews;
    }
    
    /**
     * Calculate the average rating for a book
     * 
     * @param bookId The ID of the book
     * @return The average rating, or 0 if no reviews
     * @throws SQLException If a database error occurs
     */
    public double getAverageRatingForBook(int bookId) throws SQLException {
        String sql = "SELECT AVG(rating) as avg_rating FROM reviews WHERE book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("avg_rating");
                }
            }
        }
        
        return 0;
    }
    
    /**
     * Update an existing review
     * 
     * @param review The Review object to update
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean updateReview(Review review) throws SQLException {
        String sql = "UPDATE reviews SET rating = ?, comment = ? WHERE review_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setDouble(1, review.getRating());
            pstmt.setString(2, review.getComment());
            pstmt.setInt(3, review.getReviewId());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        }
    }
    
    /**
     * Delete a review from the database
     * 
     * @param reviewId The ID of the review to delete
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean deleteReview(int reviewId) throws SQLException {
        String sql = "DELETE FROM reviews WHERE review_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, reviewId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        }
    }
    
    /**
     * Check if a user has already reviewed a book
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @return true if the user has already reviewed the book, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean hasUserReviewedBook(int userId, int bookId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM reviews WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, bookId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count") > 0;
                }
            }
        }
        
        return false;
    }
    
    /**
     * Get the total number of reviews for a book
     * 
     * @param bookId The ID of the book
     * @return The total number of reviews
     * @throws SQLException If a database error occurs
     */
    public int getReviewCountForBook(int bookId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM reviews WHERE book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
            }
        }
        
        return 0;
    }
    
    /**
     * Helper method to extract a Review object from a ResultSet
     * 
     * @param rs The ResultSet containing review data
     * @return A Review object
     * @throws SQLException If a database error occurs
     */
    private Review extractReviewFromResultSet(ResultSet rs) throws SQLException {
        Review review = new Review();
        review.setReviewId(rs.getInt("review_id"));
        review.setBookId(rs.getInt("book_id"));
        review.setUserId(rs.getInt("user_id"));
        review.setRating(rs.getDouble("rating"));
        review.setComment(rs.getString("comment"));
        review.setReviewDate(rs.getTimestamp("review_date"));
        
        // Additional fields from joins
        review.setUserName(rs.getString("first_name") + " " + rs.getString("last_name"));
        review.setBookTitle(rs.getString("title"));
        
        // Check if the cover_image_path column exists in the result set
        try {
            review.setBookCoverPath(rs.getString("cover_image_path"));
        } catch (SQLException e) {
            // Column doesn't exist, ignore
        }
        
        return review;
    }
}
