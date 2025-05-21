package dao;

import util.DBUtil;
import mode.Book;
import mode.UserBook;
import mode.UserBook.ReadingStatus;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Data Access Object for user-book relationship operations
 * Uses Jakarta EE compatible code
 */
public class UserBookDAO {
    
    /**
     * Check if a book is bookmarked by a user
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @return true if bookmarked, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean isBookmarked(int userId, int bookId) throws SQLException {
        String sql = "SELECT bookmarked FROM user_books WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, bookId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getBoolean("bookmarked");
                }
            }
        }
        
        return false;
    }
    
    /**
     * Add a book to user's collection with specified reading status
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @param status The reading status (TO_READ, READING, FINISHED)
     * @return The created UserBook object if successful, null otherwise
     * @throws SQLException If a database error occurs
     */
    public UserBook addUserBook(int userId, int bookId, ReadingStatus status) throws SQLException {
        String sql = "INSERT INTO user_books (user_id, book_id, reading_status, bookmarked, " +
                     "current_page, start_date, last_read_date, reading_list_priority, user_rating) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            Timestamp now = new Timestamp(new Date().getTime());
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, bookId);
            pstmt.setString(3, status.toString());
            pstmt.setBoolean(4, false); // Not bookmarked by default
            pstmt.setInt(5, 0); // Starting at page 0
            pstmt.setTimestamp(6, now); // Start date
            pstmt.setTimestamp(7, now); // Last read date
            pstmt.setInt(8, 0); // Not in reading list by default
            pstmt.setInt(9, 0); // No rating by default
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows == 0) {
                return null;
            }
            
            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    UserBook userBook = new UserBook(userId, bookId, status);
                    userBook.setUserBookId(generatedKeys.getInt(1));
                    userBook.setStartDate(now);
                    userBook.setLastReadDate(now);
                    
                    // Get book details
                    BookDAO bookDAO = new BookDAO();
                    Book book = bookDAO.getBookById(bookId);
                    if (book != null) {
                        userBook.setBookTitle(book.getTitle());
                        userBook.setBookCover(book.getCoverImagePath());
                        userBook.setAuthorName(book.getAuthorName());
                        userBook.setCategoryName(book.getCategoryName());
                        userBook.setTotalPages(book.getPages());
                    }
                    
                    return userBook;
                }
            }
        }
        
        return null;
    }
    
    /**
     * Get a user-book relationship by user ID and book ID
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @return The UserBook object if found, null otherwise
     * @throws SQLException If a database error occurs
     */
    public UserBook getUserBook(int userId, int bookId) throws SQLException {
        String sql = "SELECT ub.*, b.title, b.cover_image_path, b.pages, " +
                     "CONCAT(u.first_name, ' ', u.last_name) as author_name, c.name as category_name " +
                     "FROM user_books ub " +
                     "JOIN books b ON ub.book_id = b.book_id " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE ub.user_id = ? AND ub.book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, bookId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUserBook(rs);
                }
            }
        }
        
        return null;
    }
    
    /**
     * Get all books for a user with a specific reading status
     * 
     * @param userId The ID of the user
     * @param status The reading status (TO_READ, READING, FINISHED)
     * @return List of UserBook objects
     * @throws SQLException If a database error occurs
     */
    public List<UserBook> getUserBooksByStatus(int userId, ReadingStatus status) throws SQLException {
        List<UserBook> userBooks = new ArrayList<>();
        
        String sql = "SELECT ub.*, b.title, b.cover_image_path, b.pages, " +
                     "CONCAT(u.first_name, ' ', u.last_name) as author_name, c.name as category_name " +
                     "FROM user_books ub " +
                     "JOIN books b ON ub.book_id = b.book_id " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE ub.user_id = ? AND ub.reading_status = ? " +
                     "ORDER BY ub.last_read_date DESC";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setString(2, status.toString());
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    userBooks.add(mapResultSetToUserBook(rs));
                }
            }
        }
        
        return userBooks;
    }
    
    /**
     * Get all bookmarked books for a user
     * 
     * @param userId The ID of the user
     * @return List of Book objects
     * @throws SQLException If a database error occurs
     */
    public List<Book> getBookmarkedBooks(int userId) throws SQLException {
        List<Book> bookmarkedBooks = new ArrayList<>();
        
        String sql = "SELECT b.*, CONCAT(u.first_name, ' ', u.last_name) as author_name, c.name as category_name " +
                     "FROM books b " +
                     "JOIN user_books ub ON b.book_id = ub.book_id " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE ub.user_id = ? AND ub.bookmarked = true " +
                     "ORDER BY ub.last_read_date DESC";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Book book = new Book();
                    book.setBookId(rs.getInt("book_id"));
                    book.setTitle(rs.getString("title"));
                    book.setDescription(rs.getString("description"));
                    book.setAuthorId(rs.getInt("author_id"));
                    book.setCategoryId(rs.getInt("category_id"));
                    book.setFilePath(rs.getString("file_path"));
                    book.setCoverImagePath(rs.getString("cover_image_path"));
                    book.setLanguage(rs.getString("language"));
                    book.setPages(rs.getInt("pages"));
                    book.setPublicationDate(rs.getDate("publication_date"));
                    book.setUploadDate(rs.getTimestamp("upload_date"));
                    book.setViews(rs.getInt("views"));
                    book.setDownloads(rs.getInt("downloads"));
                    book.setStatus(Book.Status.valueOf(rs.getString("status")));
                    book.setTags(rs.getString("tags"));
                    book.setAuthorName(rs.getString("author_name"));
                    book.setCategoryName(rs.getString("category_name"));
                    book.setRating(rs.getDouble("rating"));
                    bookmarkedBooks.add(book);
                }
            }
        }
        
        return bookmarkedBooks;
    }
    
    /**
     * Get user's reading list (books with reading_list_priority > 0)
     * 
     * @param userId The ID of the user
     * @return List of UserBook objects sorted by priority
     * @throws SQLException If a database error occurs
     */
    public List<UserBook> getReadingList(int userId) throws SQLException {
        List<UserBook> userBooks = new ArrayList<>();
        
        String sql = "SELECT ub.*, b.title, b.cover_image_path, b.pages, " +
                     "CONCAT(u.first_name, ' ', u.last_name) as author_name, c.name as category_name " +
                     "FROM user_books ub " +
                     "JOIN books b ON ub.book_id = b.book_id " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE ub.user_id = ? AND ub.reading_list_priority > 0 " +
                     "ORDER BY ub.reading_list_priority ASC";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    userBooks.add(mapResultSetToUserBook(rs));
                }
            }
        }
        
        return userBooks;
    }
    
    /**
     * Update reading status of a book for a user
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @param status The new reading status
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean updateReadingStatus(int userId, int bookId, ReadingStatus status) throws SQLException {
        String sql = "UPDATE user_books SET reading_status = ?, last_read_date = ? ";
        
        // If status is FINISHED, set finish_date
        if (status == ReadingStatus.FINISHED) {
            sql += ", finish_date = ? ";
        }
        
        // If status is READING and current status is TO_READ, set start_date
        if (status == ReadingStatus.READING) {
            UserBook currentUserBook = getUserBook(userId, bookId);
            if (currentUserBook != null && currentUserBook.getReadingStatus() == ReadingStatus.TO_READ) {
                sql += ", start_date = ? ";
            }
        }
        
        sql += "WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            Timestamp now = new Timestamp(new Date().getTime());
            int paramIndex = 1;
            
            pstmt.setString(paramIndex++, status.toString());
            pstmt.setTimestamp(paramIndex++, now);
            
            if (status == ReadingStatus.FINISHED) {
                pstmt.setTimestamp(paramIndex++, now);
            }
            
            if (status == ReadingStatus.READING) {
                UserBook currentUserBook = getUserBook(userId, bookId);
                if (currentUserBook != null && currentUserBook.getReadingStatus() == ReadingStatus.TO_READ) {
                    pstmt.setTimestamp(paramIndex++, now);
                }
            }
            
            pstmt.setInt(paramIndex++, userId);
            pstmt.setInt(paramIndex++, bookId);
            
            int rowsAffected = pstmt.executeUpdate();
            
            // Add to user history
            if (rowsAffected > 0) {
                addToUserHistory(userId, bookId, "STATUS_CHANGE_" + status.toString());
            }
            
            return rowsAffected > 0;
        }
    }
    
    /**
     * Toggle bookmark status for a book
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean toggleBookmark(int userId, int bookId) throws SQLException {
        // First, check if user_book record exists
        boolean exists = false;
        boolean currentBookmarkStatus = false;
        
        String checkSql = "SELECT bookmarked FROM user_books WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(checkSql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, bookId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    exists = true;
                    currentBookmarkStatus = rs.getBoolean("bookmarked");
                }
            }
        }
        
        boolean newBookmarkStatus = !currentBookmarkStatus;
        
        if (exists) {
            // Update existing record
            String sql = "UPDATE user_books SET bookmarked = ?, last_read_date = ? WHERE user_id = ? AND book_id = ?";
            
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {
                
                pstmt.setBoolean(1, newBookmarkStatus);
                pstmt.setTimestamp(2, new Timestamp(new Date().getTime()));
                pstmt.setInt(3, userId);
                pstmt.setInt(4, bookId);
                
                int rowsAffected = pstmt.executeUpdate();
                
                // Add to user history
                if (rowsAffected > 0) {
                    addToUserHistory(userId, bookId, newBookmarkStatus ? "BOOKMARK_ADDED" : "BOOKMARK_REMOVED");
                }
                
                return rowsAffected > 0;
            }
        } else {
            // Insert new record
            String sql = "INSERT INTO user_books (user_id, book_id, bookmarked, last_read_date) VALUES (?, ?, ?, ?)";
            
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {
                
                pstmt.setInt(1, userId);
                pstmt.setInt(2, bookId);
                pstmt.setBoolean(3, true); // New bookmark is always true
                pstmt.setTimestamp(4, new Timestamp(new Date().getTime()));
                
                int rowsAffected = pstmt.executeUpdate();
                
                // Add to user history
                if (rowsAffected > 0) {
                    addToUserHistory(userId, bookId, "BOOKMARK_ADDED");
                }
                
                return rowsAffected > 0;
            }
        }
    }
    
    /**
     * Update reading progress for a book
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @param currentPage The current page number
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean updateReadingProgress(int userId, int bookId, int currentPage) throws SQLException {
        String sql = "UPDATE user_books SET current_page = ?, last_read_date = ? WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, currentPage);
            pstmt.setTimestamp(2, new Timestamp(new Date().getTime()));
            pstmt.setInt(3, userId);
            pstmt.setInt(4, bookId);
            
            int rowsAffected = pstmt.executeUpdate();
            
            // If the book is finished (current_page >= total_pages), update reading status
            if (rowsAffected > 0) {
                UserBook userBook = getUserBook(userId, bookId);
                if (userBook != null && currentPage >= userBook.getTotalPages() && 
                    userBook.getReadingStatus() != ReadingStatus.FINISHED) {
                    updateReadingStatus(userId, bookId, ReadingStatus.FINISHED);
                }
                
                // Add to user history
                addToUserHistory(userId, bookId, "PROGRESS_UPDATE");
            }
            
            return rowsAffected > 0;
        }
    }
    
    /**
     * Add or update a book in the user's reading list
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @param priority The priority in the reading list (1 is highest)
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean updateReadingListPriority(int userId, int bookId, int priority) throws SQLException {
        String sql = "UPDATE user_books SET reading_list_priority = ? WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, priority);
            pstmt.setInt(2, userId);
            pstmt.setInt(3, bookId);
            
            int rowsAffected = pstmt.executeUpdate();
            
            // Add to user history
            if (rowsAffected > 0) {
                addToUserHistory(userId, bookId, priority > 0 ? "ADDED_TO_READING_LIST" : "REMOVED_FROM_READING_LIST");
            }
            
            return rowsAffected > 0;
        }
    }
    
    /**
     * Update user rating for a book
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @param rating The rating (0-5)
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean updateUserRating(int userId, int bookId, int rating) throws SQLException {
        if (rating < 0 || rating > 5) {
            throw new IllegalArgumentException("Rating must be between 0 and 5");
        }
        
        String sql = "UPDATE user_books SET user_rating = ? WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, rating);
            pstmt.setInt(2, userId);
            pstmt.setInt(3, bookId);
            
            int rowsAffected = pstmt.executeUpdate();
            
            // Update the book's average rating
            if (rowsAffected > 0) {
                updateBookAverageRating(bookId);
                
                // Add to user history
                addToUserHistory(userId, bookId, "RATED_BOOK");
            }
            
            return rowsAffected > 0;
        }
    }
    
    /**
     * Remove a book from user's collection
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean removeUserBook(int userId, int bookId) throws SQLException {
        String sql = "DELETE FROM user_books WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, bookId);
            
            int rowsAffected = pstmt.executeUpdate();
            
            // Add to user history
            if (rowsAffected > 0) {
                addToUserHistory(userId, bookId, "REMOVED_BOOK");
            }
            
            return rowsAffected > 0;
        }
    }
    
    /**
     * Get recommended books for a user based on their reading history and preferences
     * 
     * @param userId The ID of the user
     * @param limit The maximum number of recommendations to return
     * @return List of Book objects
     * @throws SQLException If a database error occurs
     */
    public List<Book> getRecommendedBooks(int userId, int limit) throws SQLException {
        List<Book> recommendedBooks = new ArrayList<>();
        
        // This is a simplified recommendation algorithm
        // In a real system, you might use more sophisticated approaches
        String sql = "SELECT b.*, CONCAT(u.first_name, ' ', u.last_name) as author_name, c.name as category_name " +
                     "FROM books b " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE b.book_id NOT IN (SELECT book_id FROM user_books WHERE user_id = ?) " +
                     "AND b.status = 'APPROVED' " +
                     "AND (b.category_id IN (SELECT DISTINCT b2.category_id FROM user_books ub " +
                     "                      JOIN books b2 ON ub.book_id = b2.book_id " +
                     "                      WHERE ub.user_id = ? AND ub.reading_status = 'FINISHED') " +
                     "     OR b.author_id IN (SELECT DISTINCT b3.author_id FROM user_books ub " +
                     "                       JOIN books b3 ON ub.book_id = b3.book_id " +
                     "                       WHERE ub.user_id = ? AND ub.reading_status = 'FINISHED')) " +
                     "ORDER BY b.rating DESC, b.views DESC " +
                     "LIMIT ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, userId);
            pstmt.setInt(3, userId);
            pstmt.setInt(4, limit);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                BookDAO bookDAO = new BookDAO();
                
                while (rs.next()) {
                    Book book = new Book();
                    book.setBookId(rs.getInt("book_id"));
                    book.setTitle(rs.getString("title"));
                    book.setDescription(rs.getString("description"));
                    book.setAuthorId(rs.getInt("author_id"));
                    book.setCategoryId(rs.getInt("category_id"));
                    book.setFilePath(rs.getString("file_path"));
                    book.setCoverImagePath(rs.getString("cover_image_path"));
                    book.setLanguage(rs.getString("language"));
                    book.setPages(rs.getInt("pages"));
                    book.setPublicationDate(rs.getDate("publication_date"));
                    book.setUploadDate(rs.getTimestamp("upload_date"));
                    book.setViews(rs.getInt("views"));
                    book.setDownloads(rs.getInt("downloads"));
                    book.setStatus(Book.Status.valueOf(rs.getString("status")));
                    book.setTags(rs.getString("tags"));
                    book.setAuthorName(rs.getString("author_name"));
                    book.setCategoryName(rs.getString("category_name"));
                    recommendedBooks.add(book);
                }
            }
        }
        
        return recommendedBooks;
    }
    
    /**
     * Get dashboard statistics for a user
     * 
     * @param userId The ID of the user
     * @return Map containing statistics
     * @throws SQLException If a database error occurs
     */
    public Map<String, Integer> getUserDashboardStats(int userId) throws SQLException {
        Map<String, Integer> stats = new HashMap<>();
        
        String sql = "SELECT " +
                     "SUM(CASE WHEN reading_status = 'READING' THEN 1 ELSE 0 END) as currently_reading, " +
                     "SUM(CASE WHEN reading_status = 'TO_READ' THEN 1 ELSE 0 END) as to_read, " +
                     "SUM(CASE WHEN reading_status = 'FINISHED' THEN 1 ELSE 0 END) as finished, " +
                     "SUM(CASE WHEN bookmarked = true THEN 1 ELSE 0 END) as bookmarked, " +
                     "COUNT(*) as total_books " +
                     "FROM user_books WHERE user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("currentlyReading", rs.getInt("currently_reading"));
                    stats.put("toRead", rs.getInt("to_read"));
                    stats.put("finished", rs.getInt("finished"));
                    stats.put("bookmarked", rs.getInt("bookmarked"));
                    stats.put("totalBooks", rs.getInt("total_books"));
                }
            }
        }
        
        // Get reading time statistics
        String timeSQL = "SELECT " +
                         "SUM(TIMESTAMPDIFF(MINUTE, start_date, IFNULL(finish_date, CURRENT_TIMESTAMP))) as total_reading_minutes " +
                         "FROM user_books WHERE user_id = ? AND reading_status IN ('READING', 'FINISHED')";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(timeSQL)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    int totalMinutes = rs.getInt("total_reading_minutes");
                    stats.put("totalReadingMinutes", totalMinutes);
                    stats.put("totalReadingHours", totalMinutes / 60);
                }
            }
        }
        
        return stats;
    }
    
    /**
     * Get recent user activity
     * 
     * @param userId The ID of the user
     * @param limit The maximum number of activities to return
     * @return List of activity maps
     * @throws SQLException If a database error occurs
     */
    public List<Map<String, Object>> getUserRecentActivity(int userId, int limit) throws SQLException {
        List<Map<String, Object>> activities = new ArrayList<>();
        
        String sql = "SELECT uh.*, b.title, b.cover_image_path, " +
                     "CONCAT(u.first_name, ' ', u.last_name) as author_name " +
                     "FROM user_history uh " +
                     "JOIN books b ON uh.book_id = b.book_id " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "WHERE uh.user_id = ? " +
                     "ORDER BY uh.action_date DESC " +
                     "LIMIT ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, limit);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> activity = new HashMap<>();
                    activity.put("historyId", rs.getInt("history_id"));
                    activity.put("userId", rs.getInt("user_id"));
                    activity.put("bookId", rs.getInt("book_id"));
                    activity.put("actionType", rs.getString("action_type"));
                    activity.put("actionDate", rs.getTimestamp("action_date"));
                    activity.put("bookTitle", rs.getString("title"));
                    activity.put("bookCover", rs.getString("cover_image_path"));
                    activity.put("authorName", rs.getString("author_name"));
                    
                    activities.add(activity);
                }
            }
        }
        
        return activities;
    }
    
    /**
     * Add an entry to user history
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @param actionType The type of action (VIEW, DOWNLOAD, etc.)
     * @throws SQLException If a database error occurs
     */
    public void addToUserHistory(int userId, int bookId, String actionType) throws SQLException {
        String sql = "INSERT INTO user_history (user_id, book_id, action_type) VALUES (?, ?, ?)";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, bookId);
            pstmt.setString(3, actionType);
            
            pstmt.executeUpdate();
        }
    }
    
    /**
     * Get reading progress percentage for a book
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @return Progress percentage (0-100)
     * @throws SQLException If a database error occurs
     */
    public int getReadingProgress(int userId, int bookId) throws SQLException {
        String sql = "SELECT ub.current_page, b.pages " +
                     "FROM user_books ub " +
                     "JOIN books b ON ub.book_id = b.book_id " +
                     "WHERE ub.user_id = ? AND ub.book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, bookId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    int currentPage = rs.getInt("current_page");
                    int totalPages = rs.getInt("pages");
                    
                    if (totalPages > 0) {
                        return (int) Math.round((double) currentPage / totalPages * 100);
                    }
                }
            }
        }
        
        return 0;
    }
    
    /**
     * Helper method to map ResultSet to UserBook object
     * 
     * @param rs The ResultSet
     * @return UserBook object
     * @throws SQLException If a database error occurs
     */
    private UserBook mapResultSetToUserBook(ResultSet rs) throws SQLException {
        UserBook userBook = new UserBook();
        
        userBook.setUserBookId(rs.getInt("user_book_id"));
        userBook.setUserId(rs.getInt("user_id"));
        userBook.setBookId(rs.getInt("book_id"));
        userBook.setReadingStatus(ReadingStatus.valueOf(rs.getString("reading_status")));
        userBook.setBookmarked(rs.getBoolean("bookmarked"));
        userBook.setCurrentPage(rs.getInt("current_page"));
        userBook.setTotalPages(rs.getInt("pages"));
        userBook.setStartDate(rs.getTimestamp("start_date"));
        userBook.setLastReadDate(rs.getTimestamp("last_read_date"));
        userBook.setFinishDate(rs.getTimestamp("finish_date"));
        userBook.setReadingListPriority(rs.getInt("reading_list_priority"));
        userBook.setUserRating(rs.getInt("user_rating"));
        
        // Book details
        userBook.setBookTitle(rs.getString("title"));
        userBook.setBookCover(rs.getString("cover_image_path"));
        userBook.setAuthorName(rs.getString("author_name"));
        userBook.setCategoryName(rs.getString("category_name"));
        
        return userBook;
    }
    
    /**
     * Update the average rating of a book based on all user ratings
     * 
     * @param bookId The ID of the book
     * @throws SQLException If a database error occurs
     */
    private void updateBookAverageRating(int bookId) throws SQLException {
        String sql = "UPDATE books SET rating = " +
                     "(SELECT AVG(user_rating) FROM user_books WHERE book_id = ? AND user_rating > 0) " +
                     "WHERE book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            pstmt.setInt(2, bookId);
            
            pstmt.executeUpdate();
        }
    }
    
    /**
     * Get all user books
     * 
     * @param userId The ID of the user
     * @return List of UserBook objects
     * @throws SQLException If a database error occurs
     */
    public List<UserBook> getAllUserBooks(int userId) throws SQLException {
        List<UserBook> userBooks = new ArrayList<>();
        
        String sql = "SELECT ub.*, b.title, b.cover_image_path, b.pages, " +
                     "CONCAT(u.first_name, ' ', u.last_name) as author_name, c.name as category_name " +
                     "FROM user_books ub " +
                     "JOIN books b ON ub.book_id = b.book_id " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE ub.user_id = ? " +
                     "ORDER BY ub.last_read_date DESC";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    userBooks.add(mapResultSetToUserBook(rs));
                }
            }
        }
        
        return userBooks;
    }
    
    /**
     * Get books by category for a user
     * 
     * @param userId The ID of the user
     * @param categoryId The ID of the category
     * @return List of UserBook objects
     * @throws SQLException If a database error occurs
     */
    public List<UserBook> getUserBooksByCategory(int userId, int categoryId) throws SQLException {
        List<UserBook> userBooks = new ArrayList<>();
        
        String sql = "SELECT ub.*, b.title, b.cover_image_path, b.pages, " +
                     "CONCAT(u.first_name, ' ', u.last_name) as author_name, c.name as category_name " +
                     "FROM user_books ub " +
                     "JOIN books b ON ub.book_id = b.book_id " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE ub.user_id = ? AND b.category_id = ? " +
                     "ORDER BY ub.last_read_date DESC";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, categoryId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    userBooks.add(mapResultSetToUserBook(rs));
                }
            }
        }
        
        return userBooks;
    }
    
    /**
     * Get user's reading statistics by category
     * 
     * @param userId The ID of the user
     * @return Map of category names to book counts
     * @throws SQLException If a database error occurs
     */
    public Map<String, Integer> getUserReadingStatsByCategory(int userId) throws SQLException {
        Map<String, Integer> stats = new HashMap<>();
        
        String sql = "SELECT c.name, COUNT(*) as book_count " +
                     "FROM user_books ub " +
                     "JOIN books b ON ub.book_id = b.book_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE ub.user_id = ? " +
                     "GROUP BY c.name " +
                     "ORDER BY book_count DESC";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    stats.put(rs.getString("name"), rs.getInt("book_count"));
                }
            }
        }
        
        return stats;
    }
    
    /**
     * Get user's reading time statistics by month
     * 
     * @param userId The ID of the user
     * @param months Number of months to include
     * @return Map of month names to reading minutes
     * @throws SQLException If a database error occurs
     */
    public Map<String, Integer> getUserReadingTimeByMonth(int userId, int months) throws SQLException {
        Map<String, Integer> stats = new HashMap<>();
        
        String sql = "SELECT DATE_FORMAT(action_date, '%Y-%m') as month, " +
                     "COUNT(*) as activity_count " +
                     "FROM user_history " +
                     "WHERE user_id = ? AND action_type = 'PROGRESS_UPDATE' " +
                     "AND action_date >= DATE_SUB(CURRENT_DATE, INTERVAL ? MONTH) " +
                     "GROUP BY month " +
                     "ORDER BY month";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, months);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    stats.put(rs.getString("month"), rs.getInt("activity_count"));
                }
            }
        }
        
        return stats;
    }
}
