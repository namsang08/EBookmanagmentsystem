package dao;

import mode.Author;
import mode.User;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for author-related database operations
 */
public class AuthorDAO {
    
    /**
     * Get all authors
     * 
     * @return List of all authors
     * @throws SQLException If a database error occurs
     */
    public List<Author> getAllAuthors() throws SQLException {
        List<Author> authors = new ArrayList<>();
        String sql = "SELECT u.* FROM users u WHERE u.role = 'AUTHOR'";
        
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                authors.add(extractAuthorFromResultSet(rs));
            }
        }
        
        return authors;
    }
    
    /**
     * Get an author by ID
     * 
     * @param authorId The ID of the author
     * @return The Author object if found, null otherwise
     * @throws SQLException If a database error occurs
     */
    public Author getAuthorById(int authorId) throws SQLException {
        String sql = "SELECT u.* FROM users u WHERE u.user_id = ? AND u.role = 'AUTHOR'";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, authorId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return extractAuthorFromResultSet(rs);
                }
            }
        }
        
        return null;
    }
    
    /**
     * Get total number of authors
     * 
     * @return The total number of authors
     * @throws SQLException If a database error occurs
     */
    public int getTotalAuthorsCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE role = 'AUTHOR'";
        
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        
        return 0;
    }
    
    /**
     * Get number of authors registered in the last month
     * 
     * @return The number of authors registered in the last month
     * @throws SQLException If a database error occurs
     */
    public int getLastMonthAuthorsCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM users " +
                     "WHERE role = 'AUTHOR' AND registration_date >= DATE_SUB(NOW(), INTERVAL 1 MONTH)";
        
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        
        return 0;
    }
    
    /**
     * Update author active status
     * 
     * @param authorId The ID of the author
     * @param isActive The new active status
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean updateAuthorStatus(int authorId, boolean isActive) throws SQLException {
        String sql = "UPDATE users SET is_active = ? WHERE user_id = ? AND role = 'AUTHOR'";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setBoolean(1, isActive);
            pstmt.setInt(2, authorId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        }
    }
    
    /**
     * Helper method to extract an Author from a ResultSet
     * 
     * @param rs The ResultSet containing author data
     * @return The Author object
     * @throws SQLException If a database error occurs
     */
    private Author extractAuthorFromResultSet(ResultSet rs) throws SQLException {
        Author author = new Author();
        author.setUserId(rs.getInt("user_id"));
        author.setFirstName(rs.getString("first_name"));
        author.setLastName(rs.getString("last_name"));
        author.setEmail(rs.getString("email"));
        author.setBio(rs.getString("bio"));
        author.setProfileImage(rs.getString("profile_image"));
        author.setRegistrationDate(rs.getTimestamp("registration_date"));
        author.setActive(rs.getBoolean("is_active"));
        
        return author;
    }
}
