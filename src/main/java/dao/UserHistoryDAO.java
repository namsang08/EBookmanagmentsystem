package dao;

import util.DBUtil;
import mode.Book;
import mode.User;

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
 * Data Access Object for user history-related database operations
 */
public class UserHistoryDAO {
    
    /**
     * Add an action to user history
     * 
     * @param userId The ID of the user
     * @param bookId The ID of the book
     * @param actionType The type of action (view, download, etc.)
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean addToUserHistory(int userId, int bookId, String actionType) throws SQLException {
        String sql = "INSERT INTO user_history (user_id, book_id, action_type, action_date) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            pstmt.setInt(2, bookId);
            pstmt.setString(3, actionType);
            pstmt.setTimestamp(4, new Timestamp(new Date().getTime()));
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        }
    }
    
    /**
     * Get user history for a specific user
     * 
     * @param userId The ID of the user
     * @param limit The maximum number of records to return (0 for all)
     * @return List of user history records with book details
     * @throws SQLException If a database error occurs
     */
    public List<Map<String, Object>> getUserHistory(int userId, int limit) throws SQLException {
        List<Map<String, Object>> history = new ArrayList<>();
        
        String sql = "SELECT h.*, b.title, b.cover_image_path, u.first_name, u.last_name " +
                     "FROM user_history h " +
                     "JOIN books b ON h.book_id = b.book_id " +
                     "JOIN users u ON b.author_id = u.user_id " +
                     "WHERE h.user_id = ? " +
                     "ORDER BY h.action_date DESC";
        
        if (limit > 0) {
            sql += " LIMIT ?";
        }
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            if (limit > 0) {
                pstmt.setInt(2, limit);
            }
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> record = new HashMap<>();
                    record.put("historyId", rs.getInt("history_id"));
                    record.put("userId", rs.getInt("user_id"));
                    record.put("bookId", rs.getInt("book_id"));
                    record.put("actionType", rs.getString("action_type"));
                    record.put("actionDate", rs.getTimestamp("action_date"));
                    record.put("bookTitle", rs.getString("title"));
                    record.put("coverImagePath", rs.getString("cover_image_path"));
                    record.put("authorName", rs.getString("first_name") + " " + rs.getString("last_name"));
                    
                    history.add(record);
                }
            }
        }
        
        return history;
    }
    
    /**
     * Get user history for a specific book
     * 
     * @param bookId The ID of the book
     * @param limit The maximum number of records to return (0 for all)
     * @return List of user history records with user details
     * @throws SQLException If a database error occurs
     */
    public List<Map<String, Object>> getBookHistory(int bookId, int limit) throws SQLException {
        List<Map<String, Object>> history = new ArrayList<>();
        
        String sql = "SELECT h.*, u.first_name, u.last_name, u.email " +
                     "FROM user_history h " +
                     "JOIN users u ON h.user_id = u.user_id " +
                     "WHERE h.book_id = ? " +
                     "ORDER BY h.action_date DESC";
        
        if (limit > 0) {
            sql += " LIMIT ?";
        }
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            
            if (limit > 0) {
                pstmt.setInt(2, limit);
            }
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> record = new HashMap<>();
                    record.put("historyId", rs.getInt("history_id"));
                    record.put("userId", rs.getInt("user_id"));
                    record.put("bookId", rs.getInt("book_id"));
                    record.put("actionType", rs.getString("action_type"));
                    record.put("actionDate", rs.getTimestamp("action_date"));
                    record.put("userName", rs.getString("first_name") + " " + rs.getString("last_name"));
                    record.put("userEmail", rs.getString("email"));
                    
                    history.add(record);
                }
            }
        }
        
        return history;
    }
    
    /**
     * Get download count by date for a specific book
     * 
     * @param bookId The ID of the book
     * @param days Number of days to include (0 for all time)
     * @return Map with dates as keys and download counts as values
     * @throws SQLException If a database error occurs
     */
    public Map<String, Integer> getDownloadCountByDate(int bookId, int days) throws SQLException {
        Map<String, Integer> downloadCounts = new HashMap<>();
        
        String sql = "SELECT DATE(action_date) as download_date, COUNT(*) as count " +
                     "FROM user_history " +
                     "WHERE book_id = ? AND action_type = 'download' ";
        
        if (days > 0) {
            sql += "AND action_date >= DATE_SUB(CURRENT_DATE, INTERVAL ? DAY) ";
        }
        
        sql += "GROUP BY DATE(action_date) ORDER BY download_date";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            
            if (days > 0) {
                pstmt.setInt(2, days);
            }
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    String date = rs.getString("download_date");
                    int count = rs.getInt("count");
                    downloadCounts.put(date, count);
                }
            }
        }
        
        return downloadCounts;
    }
    
    /**
     * Get view count by date for a specific book
     * 
     * @param bookId The ID of the book
     * @param days Number of days to include (0 for all time)
     * @return Map with dates as keys and view counts as values
     * @throws SQLException If a database error occurs
     */
    public Map<String, Integer> getViewCountByDate(int bookId, int days) throws SQLException {
        Map<String, Integer> viewCounts = new HashMap<>();
        
        String sql = "SELECT DATE(action_date) as view_date, COUNT(*) as count " +
                     "FROM user_history " +
                     "WHERE book_id = ? AND action_type = 'view' ";
        
        if (days > 0) {
            sql += "AND action_date >= DATE_SUB(CURRENT_DATE, INTERVAL ? DAY) ";
        }
        
        sql += "GROUP BY DATE(action_date) ORDER BY view_date";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            
            if (days > 0) {
                pstmt.setInt(2, days);
            }
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    String date = rs.getString("view_date");
                    int count = rs.getInt("count");
                    viewCounts.put(date, count);
                }
            }
        }
        
        return viewCounts;
    }
    
    /**
     * Delete user history records for a specific user
     * 
     * @param userId The ID of the user
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean deleteUserHistory(int userId) throws SQLException {
        String sql = "DELETE FROM user_history WHERE user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, userId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        }
    }
    
    /**
     * Delete user history records for a specific book
     * 
     * @param bookId The ID of the book
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean deleteBookHistory(int bookId) throws SQLException {
        String sql = "DELETE FROM user_history WHERE book_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, bookId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        }
    }
}
