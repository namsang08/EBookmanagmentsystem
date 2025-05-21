package dao;

import util.DBUtil;
import mode.Book;
import mode.Category;

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
 * Data Access Object for book-related database operations
 */
public class BookDAO {
    
    // Get all books
    public List<Book> getAllBooks() throws SQLException {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT b.*, u.first_name, u.last_name, c.name as category_name " +
                     "FROM books b " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "ORDER BY b.publication_date DESC";
        
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                books.add(extractBookFromResultSet(rs));
            }
        }
        return books;
    }
    
    // Get books by author
    public List<Book> getBooksByAuthor(int authorId) throws SQLException {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT b.*, u.first_name, u.last_name, c.name as category_name " +
                     "FROM books b " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE b.author_id = ? " +
                     "ORDER BY b.publication_date DESC";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, authorId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    books.add(extractBookFromResultSet(rs));
                }
            }
        }
        return books;
    }
    
    // Get public (approved) books
    public List<Book> getPublicBooks() throws SQLException {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT b.*, u.first_name, u.last_name, c.name as category_name " +
                     "FROM books b " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE b.status = 'APPROVED' " +
                     "ORDER BY b.publication_date DESC";
        
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                books.add(extractBookFromResultSet(rs));
            }
        }
        return books;
    }
    
    // Get a single book by ID
    public Book getBook(int bookId) throws SQLException {
        Book book = null;
        String sql = "SELECT b.*, u.first_name, u.last_name, c.name as category_name " +
                     "FROM books b " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE b.book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    book = extractBookFromResultSet(rs);
                }
            }
        }
        return book;
    }
    
    // Insert a new book
    public void insertBook(Book book) throws SQLException {
        String sql = "INSERT INTO books (title, description, author_id, category_id, file_path, cover_image_path, " +
                     "language, pages, publication_date, status, tags) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, book.getTitle());
            pstmt.setString(2, book.getDescription());
            pstmt.setInt(3, book.getAuthorId());
            pstmt.setInt(4, book.getCategoryId());
            pstmt.setString(5, book.getFilePath());
            pstmt.setString(6, book.getCoverImagePath());
            pstmt.setString(7, book.getLanguage());
            pstmt.setInt(8, book.getPages());
            pstmt.setDate(9, new java.sql.Date(book.getPublicationDate().getTime()));
            pstmt.setString(10, book.getStatus().toString());
            pstmt.setString(11, book.getTags());
            
            pstmt.executeUpdate();
            
            try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    book.setBookId(generatedKeys.getInt(1));
                }
            }
        }
    }
    
    // Update an existing book
    public void updateBook(Book book) throws SQLException {
        String sql = "UPDATE books SET title = ?, description = ?, category_id = ?, " +
                     "language = ?, pages = ?, tags = ? " +
                     "WHERE book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, book.getTitle());
            pstmt.setString(2, book.getDescription());
            pstmt.setInt(3, book.getCategoryId());
            pstmt.setString(4, book.getLanguage());
            pstmt.setInt(5, book.getPages());
            pstmt.setString(6, book.getTags());
            pstmt.setInt(7, book.getBookId());
            
            pstmt.executeUpdate();
        }
    }
    
    // Delete a book
    public void deleteBook(int bookId) throws SQLException {
        String sql = "DELETE FROM books WHERE book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            pstmt.executeUpdate();
        }
    }
    
    // Update book status (for admin approval)
    public void updateBookStatus(int bookId, Book.Status status) throws SQLException {
        String sql = "UPDATE books SET status = ? WHERE book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, status.toString());
            pstmt.setInt(2, bookId);
            
            pstmt.executeUpdate();
        }
    }
    
    // Increment view count
    public void incrementViewCount(int bookId) throws SQLException {
        String sql = "UPDATE books SET views = views + 1 WHERE book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            pstmt.executeUpdate();
        }
    }
    
    // Increment download count
    public void incrementDownloadCount(int bookId) throws SQLException {
        String sql = "UPDATE books SET downloads = downloads + 1 WHERE book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            pstmt.executeUpdate();
        }
    }
    
    // Search books
    public List<Book> searchBooks(String query) throws SQLException {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT b.*, u.first_name, u.last_name, c.name as category_name " +
                     "FROM books b " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE b.status = 'APPROVED' AND " +
                     "(b.title LIKE ? OR b.description LIKE ? OR b.tags LIKE ? OR " +
                     "u.first_name LIKE ? OR u.last_name LIKE ? OR c.name LIKE ?) " +
                     "ORDER BY b.publication_date DESC";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            String searchTerm = "%" + query + "%";
            pstmt.setString(1, searchTerm);
            pstmt.setString(2, searchTerm);
            pstmt.setString(3, searchTerm);
            pstmt.setString(4, searchTerm);
            pstmt.setString(5, searchTerm);
            pstmt.setString(6, searchTerm);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    books.add(extractBookFromResultSet(rs));
                }
            }
        }
        return books;
    }
    
    // Get books by category
    public List<Book> getBooksByCategory(int categoryId) throws SQLException {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT b.*, u.first_name, u.last_name, c.name as category_name " +
                     "FROM books b " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE b.status = 'APPROVED' AND b.category_id = ? " +
                     "ORDER BY b.publication_date DESC";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, categoryId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    books.add(extractBookFromResultSet(rs));
                }
            }
        }
        return books;
    }
    
    // Helper method to extract book from ResultSet
    private Book extractBookFromResultSet(ResultSet rs) throws SQLException {
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
        
        // Additional fields from joins
        book.setAuthorName(rs.getString("first_name") + " " + rs.getString("last_name"));
        book.setCategoryName(rs.getString("category_name"));
        
        return book;
    }

    //Get related books (same category or author)
    public List<Book> getRelatedBooks(int bookId, int categoryId, int authorId, int limit) throws SQLException {
        List<Book> relatedBooks = new ArrayList<>();
        String sql = "SELECT b.*, u.first_name, u.last_name, c.name as category_name " +
                    "FROM books b " +
                    "JOIN users u ON b.author_id = u.user_id " +
                    "JOIN categories c ON b.category_id = c.category_id " +
                    "WHERE b.book_id != ? AND b.status = 'APPROVED' " +
                    "AND (b.category_id = ? OR b.author_id = ?) " +
                    "ORDER BY RAND() " +
                    "LIMIT ?";
        
        try (Connection conn = DBUtil.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            pstmt.setInt(2, categoryId);
            pstmt.setInt(3, authorId);
            pstmt.setInt(4, limit);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Book book = extractBookFromResultSet(rs);
                    
                    // Additional fields from joins
                    book.setAuthorName(rs.getString("first_name") + " " + rs.getString("last_name"));
                    book.setCategoryName(rs.getString("category_name"));
                    
                    relatedBooks.add(book);
                }
            }
        }
        
        return relatedBooks;
    }

    //Increment view count
    public void incrementViews(int bookId) throws SQLException {
        String sql = "UPDATE books SET views = views + 1 WHERE book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            
            pstmt.executeUpdate();
        }
    }

    //Increment download count
    public void incrementDownloads(int bookId) throws SQLException {
        String sql = "UPDATE books SET downloads = downloads + 1 WHERE book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            
            pstmt.executeUpdate();
        }
    }

    //Update book rating
    public void updateBookRating(int bookId, double rating) throws SQLException {
        String sql = "UPDATE books SET rating = ? WHERE book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setDouble(1, rating);
            pstmt.setInt(2, bookId);
            
            pstmt.executeUpdate();
        }
    }

    //Add to user history (view, download, etc.)
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
     * Get a book by its ID
     * 
     * @param bookId The ID of the book to retrieve
     * @return The Book object if found, null otherwise
     * @throws SQLException If a database error occurs
     */
    public Book getBookById(int bookId) throws SQLException {
        String sql = "SELECT b.*, u.first_name, u.last_name, c.name as category_name " +
                    "FROM books b " +
                    "JOIN users u ON b.author_id = u.user_id " +
                    "JOIN categories c ON b.category_id = c.category_id " +
                    "WHERE b.book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
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
                    
                    // Additional fields from joins
                    book.setAuthorName(rs.getString("first_name") + " " + rs.getString("last_name"));
                    book.setCategoryName(rs.getString("category_name"));
                    
                    return book;
                }
            }
        }
        
        return null;
    }
    
    // NEW METHODS FOR USER DASHBOARD FUNCTIONALITY
    
    /**
     * Get books currently being read by a user
     * 
     * @param userId The ID of the user
     * @return List of books currently being read
     * @throws SQLException If a database error occurs
     */
    public List<Book> getCurrentlyReadingBooks(int userId) throws SQLException {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT b.*, u.first_name, u.last_name, c.name as category_name, " +
                     "ur.progress, ur.last_read " +
                     "FROM books b " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "JOIN user_reading ur ON b.book_id = ur.book_id " +
                     "WHERE ur.user_id = ? AND ur.status = 'READING' " +
                     "ORDER BY ur.last_read DESC";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Book book = extractBookFromResultSet(rs);
                    // Add reading progress information
                    book.setReadingProgress(rs.getInt("progress"));
                    book.setLastReadTime(rs.getTimestamp("last_read"));
                    books.add(book);
                }
            }
        }
        
        return books;
    }
    
    /**
     * Get books in a user's reading list (to-read)
     * 
     * @param userId The ID of the user
     * @return List of books in the reading list
     * @throws SQLException If a database error occurs
     */
    public List<Book> getReadingListBooks(int userId) throws SQLException {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT b.*, u.first_name, u.last_name, c.name as category_name, " +
                     "ur.priority " +
                     "FROM books b " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "JOIN user_reading ur ON b.book_id = ur.book_id " +
                     "WHERE ur.user_id = ? AND ur.status = 'TO_READ' " +
                     "ORDER BY ur.priority ASC";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Book book = extractBookFromResultSet(rs);
                    // Add priority information
                    book.setReadingPriority(rs.getInt("priority"));
                    books.add(book);
                }
            }
        }
        
        return books;
    }
    
    /**
     * Get books finished by a user
     * 
     * @param userId The ID of the user
     * @return List of finished books
     * @throws SQLException If a database error occurs
     */
    public List<Book> getFinishedBooks(int userId) throws SQLException {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT b.*, u.first_name, u.last_name, c.name as category_name, " +
                     "ur.completed_date " +
                     "FROM books b " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "JOIN user_reading ur ON b.book_id = ur.book_id " +
                     "WHERE ur.user_id = ? AND ur.status = 'FINISHED' " +
                     "ORDER BY ur.completed_date DESC";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Book book = extractBookFromResultSet(rs);
                    // Add completion date
                    book.setCompletedDate(rs.getTimestamp("completed_date"));
                    books.add(book);
                }
            }
        }
        
        return books;
    }
    
    /**
     * Get bookmarked books for a user
     * 
     * @param userId The ID of the user
     * @return List of bookmarked books
     * @throws SQLException If a database error occurs
     */
    public List<Book> getBookmarkedBooks(int userId) throws SQLException {
        List<Book> books = new ArrayList<>();
        String sql = "SELECT b.*, u.first_name, u.last_name, c.name as category_name " +
                     "FROM books b " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "JOIN user_bookmarks ub ON b.book_id = ub.book_id " +
                     "WHERE ub.user_id = ? " +
                     "ORDER BY ub.created_at DESC";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    books.add(extractBookFromResultSet(rs));
                }
            }
        }
        
        return books;
    }
    
    /**
     * Add or update a book in user's reading list
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @param status The reading status (READING, TO_READ, FINISHED)
     * @param progress The reading progress (0-100)
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean updateReadingStatus(int userId, int bookId, String status, int progress) throws SQLException {
        // Check if record exists
        String checkSql = "SELECT COUNT(*) FROM user_reading WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            
            checkStmt.setInt(1, userId);
            checkStmt.setInt(2, bookId);
            
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    // Update existing record
                    String updateSql = "UPDATE user_reading SET status = ?, progress = ?, last_read = ? " +
                                      "WHERE user_id = ? AND book_id = ?";
                    
                    try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                        updateStmt.setString(1, status);
                        updateStmt.setInt(2, progress);
                        updateStmt.setTimestamp(3, new Timestamp(new Date().getTime()));
                        updateStmt.setInt(4, userId);
                        updateStmt.setInt(5, bookId);
                        
                        // If status is FINISHED, update completed_date
                        if ("FINISHED".equals(status)) {
                            updateSql = "UPDATE user_reading SET status = ?, progress = 100, " +
                                       "last_read = ?, completed_date = ? " +
                                       "WHERE user_id = ? AND book_id = ?";
                            
                            try (PreparedStatement finishedStmt = conn.prepareStatement(updateSql)) {
                                Timestamp now = new Timestamp(new Date().getTime());
                                finishedStmt.setString(1, status);
                                finishedStmt.setTimestamp(2, now);
                                finishedStmt.setTimestamp(3, now);
                                finishedStmt.setInt(4, userId);
                                finishedStmt.setInt(5, bookId);
                                
                                return finishedStmt.executeUpdate() > 0;
                            }
                        }
                        
                        return updateStmt.executeUpdate() > 0;
                    }
                } else {
                    // Insert new record
                    String insertSql = "INSERT INTO user_reading (user_id, book_id, status, progress, last_read) " +
                                      "VALUES (?, ?, ?, ?, ?)";
                    
                    try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                        insertStmt.setInt(1, userId);
                        insertStmt.setInt(2, bookId);
                        insertStmt.setString(3, status);
                        insertStmt.setInt(4, progress);
                        insertStmt.setTimestamp(5, new Timestamp(new Date().getTime()));
                        
                        return insertStmt.executeUpdate() > 0;
                    }
                }
            }
        }
    }
    
    /**
     * Toggle bookmark for a book
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @return true if bookmark was added, false if it was removed
     * @throws SQLException If a database error occurs
     */
    public boolean toggleBookmark(int userId, int bookId) throws SQLException {
        // Check if bookmark exists
        String checkSql = "SELECT COUNT(*) FROM user_bookmarks WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            
            checkStmt.setInt(1, userId);
            checkStmt.setInt(2, bookId);
            
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    // Remove bookmark
                    String deleteSql = "DELETE FROM user_bookmarks WHERE user_id = ? AND book_id = ?";
                    
                    try (PreparedStatement deleteStmt = conn.prepareStatement(deleteSql)) {
                        deleteStmt.setInt(1, userId);
                        deleteStmt.setInt(2, bookId);
                        
                        return deleteStmt.executeUpdate() > 0;
                    }
                } else {
                    // Add bookmark
                    String insertSql = "INSERT INTO user_bookmarks (user_id, book_id, created_at) VALUES (?, ?, ?)";
                    
                    try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                        insertStmt.setInt(1, userId);
                        insertStmt.setInt(2, bookId);
                        insertStmt.setTimestamp(3, new Timestamp(new Date().getTime()));
                        
                        return insertStmt.executeUpdate() > 0;
                    }
                }
            }
        }
    }
    
    /**
     * Check if a book is bookmarked by a user
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @return true if bookmarked, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean isBookmarked(int userId, int bookId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM user_bookmarks WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, bookId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        
        return false;
    }
    
    /**
     * Get reading status for a book
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @return The reading status or null if not in reading list
     * @throws SQLException If a database error occurs
     */
    public String getReadingStatus(int userId, int bookId) throws SQLException {
        String sql = "SELECT status FROM user_reading WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, bookId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("status");
                }
            }
        }
        
        return null;
    }
    
    /**
     * Get reading progress for a book
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @return The reading progress (0-100) or 0 if not in reading list
     * @throws SQLException If a database error occurs
     */
    public int getReadingProgress(int userId, int bookId) throws SQLException {
        String sql = "SELECT progress FROM user_reading WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, bookId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("progress");
                }
            }
        }
        
        return 0;
    }
    
    /**
     * Get recommended books for a user based on reading history
     * 
     * @param userId The ID of the user
     * @param limit The maximum number of books to return
     * @return List of recommended books
     * @throws SQLException If a database error occurs
     */
    public List<Book> getRecommendedBooks(int userId, int limit) throws SQLException {
        // First get categories from user's reading history
        List<Integer> categoryIds = new ArrayList<>();
        String categorySql = "SELECT DISTINCT c.category_id FROM categories c " +
                            "JOIN books b ON c.category_id = b.category_id " +
                            "JOIN user_reading ur ON b.book_id = ur.book_id " +
                            "WHERE ur.user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement categoryStmt = conn.prepareStatement(categorySql)) {
            
            categoryStmt.setInt(1, userId);
            
            try (ResultSet rs = categoryStmt.executeQuery()) {
                while (rs.next()) {
                    categoryIds.add(rs.getInt("category_id"));
                }
            }
        }
        
        // If no reading history, return popular books
        if (categoryIds.isEmpty()) {
            String popularSql = "SELECT b.*, u.first_name, u.last_name, c.name as category_name " +
                               "FROM books b " +
                               "JOIN users u ON b.author_id = u.user_id " +
                               "JOIN categories c ON b.category_id = c.category_id " +
                               "WHERE b.status = 'APPROVED' " +
                               "ORDER BY (b.views + b.downloads * 2) DESC " +
                               "LIMIT ?";
            
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement popularStmt = conn.prepareStatement(popularSql)) {
                
                popularStmt.setInt(1, limit);
                
                List<Book> popularBooks = new ArrayList<>();
                try (ResultSet rs = popularStmt.executeQuery()) {
                    while (rs.next()) {
                        popularBooks.add(extractBookFromResultSet(rs));
                    }
                }
                
                return popularBooks;
            }
        }
        
        // Get books in those categories that the user hasn't read
        StringBuilder bookSql = new StringBuilder();
        bookSql.append("SELECT b.*, u.first_name, u.last_name, c.name as category_name ");
        bookSql.append("FROM books b ");
        bookSql.append("JOIN users u ON b.author_id = u.user_id ");
        bookSql.append("JOIN categories c ON b.category_id = c.category_id ");
        bookSql.append("WHERE b.status = 'APPROVED' AND b.category_id IN (");
        
        for (int i = 0; i < categoryIds.size(); i++) {
            if (i > 0) {
                bookSql.append(",");
            }
            bookSql.append("?");
        }
        
        bookSql.append(") AND b.book_id NOT IN (");
        bookSql.append("SELECT book_id FROM user_reading WHERE user_id = ?");
        bookSql.append(") ORDER BY b.rating DESC, b.views DESC LIMIT ?");
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement bookStmt = conn.prepareStatement(bookSql.toString())) {
            
            int paramIndex = 1;
            for (Integer categoryId : categoryIds) {
                bookStmt.setInt(paramIndex++, categoryId);
            }
            bookStmt.setInt(paramIndex++, userId);
            bookStmt.setInt(paramIndex, limit);
            
            List<Book> recommendedBooks = new ArrayList<>();
            try (ResultSet rs = bookStmt.executeQuery()) {
                while (rs.next()) {
                    recommendedBooks.add(extractBookFromResultSet(rs));
                }
            }
            
            return recommendedBooks;
        }
    }
    
    /**
     * Get user's reading statistics
     * 
     * @param userId The ID of the user
     * @return Map containing reading statistics
     * @throws SQLException If a database error occurs
     */
    public Map<String, Integer> getUserReadingStats(int userId) throws SQLException {
        Map<String, Integer> stats = new HashMap<>();
        
        String sql = "SELECT " +
                    "SUM(CASE WHEN status = 'READING' THEN 1 ELSE 0 END) as currently_reading, " +
                    "SUM(CASE WHEN status = 'TO_READ' THEN 1 ELSE 0 END) as to_read, " +
                    "SUM(CASE WHEN status = 'FINISHED' THEN 1 ELSE 0 END) as finished " +
                    "FROM user_reading WHERE user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("currentlyReading", rs.getInt("currently_reading"));
                    stats.put("toRead", rs.getInt("to_read"));
                    stats.put("finished", rs.getInt("finished"));
                }
            }
        }
        
        // Get bookmarks count
        String bookmarkSql = "SELECT COUNT(*) as bookmarked FROM user_bookmarks WHERE user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(bookmarkSql)) {
            
            pstmt.setInt(1, userId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    stats.put("bookmarked", rs.getInt("bookmarked"));
                }
            }
        }
        
        return stats;
    }
    
    /**
     * Get user's recent activity
     * 
     * @param userId The ID of the user
     * @param limit The maximum number of activities to return
     * @return List of activity maps containing bookId, bookTitle, activityType, and timestamp
     * @throws SQLException If a database error occurs
     */
    public List<Map<String, Object>> getUserRecentActivity(int userId, int limit) throws SQLException {
        List<Map<String, Object>> activities = new ArrayList<>();
        
        // Get recent downloads and views
        String historySql = "SELECT b.book_id, b.title, uh.action_type, uh.timestamp " +
                           "FROM user_history uh " +
                           "JOIN books b ON uh.book_id = b.book_id " +
                           "WHERE uh.user_id = ? " +
                           "ORDER BY uh.timestamp DESC LIMIT ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(historySql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, limit);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> activity = new HashMap<>();
                    activity.put("bookId", rs.getInt("book_id"));
                    activity.put("bookTitle", rs.getString("title"));
                    activity.put("activityType", rs.getString("action_type"));
                    activity.put("timestamp", rs.getTimestamp("timestamp"));
                    activities.add(activity);
                }
            }
        }
        
        // Get recent reading updates
        String readingSql = "SELECT b.book_id, b.title, " +
                           "CASE ur.status " +
                           "  WHEN 'READING' THEN 'STARTED_READING' " +
                           "  WHEN 'FINISHED' THEN 'FINISHED_READING' " +
                           "  ELSE ur.status " +
                           "END as activity_type, " +
                           "ur.last_read as timestamp " +
                           "FROM user_reading ur " +
                           "JOIN books b ON ur.book_id = b.book_id " +
                           "WHERE ur.user_id = ? " +
                           "ORDER BY ur.last_read DESC LIMIT ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(readingSql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, limit);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> activity = new HashMap<>();
                    activity.put("bookId", rs.getInt("book_id"));
                    activity.put("bookTitle", rs.getString("title"));
                    activity.put("activityType", rs.getString("activity_type"));
                    activity.put("timestamp", rs.getTimestamp("timestamp"));
                    activities.add(activity);
                }
            }
        }
        
        // Sort all activities by timestamp (descending)
        activities.sort((a1, a2) -> {
            Timestamp t1 = (Timestamp) a1.get("timestamp");
            Timestamp t2 = (Timestamp) a2.get("timestamp");
            return t2.compareTo(t1);
        });
        
        // Limit to requested number
        if (activities.size() > limit) {
            activities = activities.subList(0, limit);
        }
        
        return activities;
    }
    
    /**
     * Update reading priority for a book in the reading list
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @param priority The priority (lower number = higher priority)
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean updateReadingPriority(int userId, int bookId, int priority) throws SQLException {
        String sql = "UPDATE user_reading SET priority = ? " +
                    "WHERE user_id = ? AND book_id = ? AND status = 'TO_READ'";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, priority);
            pstmt.setInt(2, userId);
            pstmt.setInt(3, bookId);
            
            return pstmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Remove a book from user's reading list
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean removeFromReadingList(int userId, int bookId) throws SQLException {
        String sql = "DELETE FROM user_reading WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, bookId);
            
            return pstmt.executeUpdate() > 0;
        }
    }
}
