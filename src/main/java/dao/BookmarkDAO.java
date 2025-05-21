package dao;


import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import mode.Book;
import util.DBUtil;

public class BookmarkDAO {
    
    // Add a bookmark
    public void addBookmark(int userId, int bookId) throws SQLException {
        String sql = "INSERT INTO bookmarks (user_id, book_id) VALUES (?, ?)";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, bookId);
            
            pstmt.executeUpdate();
        }
    }
    
    // Remove a bookmark
    public void removeBookmark(int userId, int bookId) throws SQLException {
        String sql = "DELETE FROM bookmarks WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, bookId);
            
            pstmt.executeUpdate();
        }
    }
    
    // Check if a user has bookmarked a book
    public boolean hasBookmark(int userId, int bookId) throws SQLException {
        String sql = "SELECT 1 FROM bookmarks WHERE user_id = ? AND book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, bookId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        }
    }
    
    // Get all bookmarks for a user
    public List<Book> getUserBookmarks(int userId) throws SQLException {
        List<Book> bookmarks = new ArrayList<>();
        String sql = "SELECT b.*, u.first_name, u.last_name, c.name as category_name " +
                     "FROM bookmarks bm " +
                     "JOIN books b ON bm.book_id = b.book_id " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "JOIN categories c ON b.category_id = c.category_id " +
                     "WHERE bm.user_id = ? " +
                     "ORDER BY bm.created_at DESC";
        
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
                    
                    // Additional fields from joins
                    book.setAuthorName(rs.getString("first_name") + " " + rs.getString("last_name"));
                    book.setCategoryName(rs.getString("category_name"));
                    
                    bookmarks.add(book);
                }
            }
        }
        
        return bookmarks;
    }
}
