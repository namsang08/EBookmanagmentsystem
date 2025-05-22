package dao;

import mode.User;
import util.DBUtil;
import util.SecurityUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserDAO {
    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());
    
    // Create a new user
    public boolean createUser(User user) {
        String sql = "INSERT INTO users (first_name, last_name, email, password, role) VALUES (?, ?, ?, ?, ?)";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, user.getFirstName());
            stmt.setString(2, user.getLastName());
            stmt.setString(3, user.getEmail());
            stmt.setString(4, SecurityUtil.hashPassword(user.getPassword()));
            stmt.setString(5, user.getRole().toString());
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows == 0) {
                return false;
            }
            
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    user.setUserId(generatedKeys.getInt(1));
                    return true;
                } else {
                    return false;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating user", e);
            return false;
        }
    }
    
    // Find user by email
    public User findByEmail(String email) {
        String sql = "SELECT * FROM users WHERE email = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                } else {
                    return null;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding user by email", e);
            return null;
        }
    }
    
    // Find user by ID
    public User findById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                } else {
                    return null;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding user by ID", e);
            return null;
        }
    }
    
    // Update user
    public boolean updateUser(User user) {
        String sql = "UPDATE users SET first_name = ?, last_name = ?, email = ?, " +
                     "role = ?, profile_image = ?, bio = ?, is_active = ? WHERE user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, user.getFirstName());
            stmt.setString(2, user.getLastName());
            stmt.setString(3, user.getEmail());
            stmt.setString(4, user.getRole().toString());
            stmt.setString(5, user.getProfileImage());
            stmt.setString(6, user.getBio());
            stmt.setBoolean(7, user.isActive());
            stmt.setInt(8, user.getUserId());
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating user", e);
            return false;
        }
    }
    
    // Update user password
    public boolean updatePassword(int userId, String newPassword) {
        String sql = "UPDATE users SET password = ? WHERE user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, SecurityUtil.hashPassword(newPassword));
            stmt.setInt(2, userId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating password", e);
            return false;
        }
    }
    
    // Update last login time
    public boolean updateLastLogin(int userId) {
        String sql = "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating last login", e);
            return false;
        }
    }
    
    // Delete user
    public boolean deleteUser(int userId) {
        String sql = "DELETE FROM users WHERE user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting user", e);
            return false;
        }
    }
    
    // Get all users
    public List<User> getAllUsers() {
        String sql = "SELECT * FROM users ORDER BY registration_date DESC";
        List<User> users = new ArrayList<>();
        
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting all users", e);
        }
        
        return users;
    }
    
    // Get users by role
    public List<User> getUsersByRole(User.Role role) {
        String sql = "SELECT * FROM users WHERE role = ? ORDER BY registration_date DESC";
        List<User> users = new ArrayList<>();
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, role.toString());
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    users.add(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting users by role", e);
        }
        
        return users;
    }
    
    // Check if email exists
    public boolean emailExists(String email) {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, email);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking if email exists", e);
        }
        
        return false;
    }
    
    // Set password reset token
    public boolean setResetToken(String email, String token, Timestamp expiry) {
        String sql = "UPDATE users SET reset_token = ?, reset_token_expiry = ? WHERE email = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, token);
            stmt.setTimestamp(2, expiry);
            stmt.setString(3, email);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error setting reset token", e);
            return false;
        }
    }
    
    // Find user by reset token
    public User findByResetToken(String token) {
        String sql = "SELECT * FROM users WHERE reset_token = ? AND reset_token_expiry > CURRENT_TIMESTAMP";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, token);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error finding user by reset token", e);
        }
        
        return null;
    }
    
    // Clear reset token
    public boolean clearResetToken(int userId) {
        String sql = "UPDATE users SET reset_token = NULL, reset_token_expiry = NULL WHERE user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error clearing reset token", e);
            return false;
        }
    }
    
    // Get user activity (for admin user-details.jsp)
    public List<Map<String, Object>> getUserActivity(int userId, int limit) {
        String sql = "SELECT 'book_view' as activity_type, b.title as item_name, uh.view_date as activity_date " +
                     "FROM user_history uh JOIN books b ON uh.book_id = b.book_id " +
                     "WHERE uh.user_id = ? " +
                     "UNION ALL " +
                     "SELECT 'book_download' as activity_type, b.title as item_name, d.download_date as activity_date " +
                     "FROM downloads d JOIN books b ON d.book_id = b.book_id " +
                     "WHERE d.user_id = ? " +
                     "UNION ALL " +
                     "SELECT 'review' as activity_type, b.title as item_name, r.review_date as activity_date " +
                     "FROM reviews r JOIN books b ON r.book_id = b.book_id " +
                     "WHERE r.user_id = ? " +
                     "ORDER BY activity_date DESC " +
                     "LIMIT ?";
        
        List<Map<String, Object>> activities = new ArrayList<>();
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setInt(2, userId);
            stmt.setInt(3, userId);
            stmt.setInt(4, limit);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> activity = new HashMap<>();
                    activity.put("type", rs.getString("activity_type"));
                    activity.put("itemName", rs.getString("item_name"));
                    activity.put("date", rs.getTimestamp("activity_date"));
                    activities.add(activity);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting user activity", e);
        }
        
        return activities;
    }
    
    // Get user downloads count
    public int getUserDownloadsCount(int userId) {
        String sql = "SELECT COUNT(*) FROM downloads WHERE user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting user downloads count", e);
        }
        
        return 0;
    }
    
    // Get user reviews count
    public int getUserReviewsCount(int userId) {
        String sql = "SELECT COUNT(*) FROM reviews WHERE user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting user reviews count", e);
        }
        
        return 0;
    }
    
    // Get user bookmarks count
    public int getUserBookmarksCount(int userId) {
        String sql = "SELECT COUNT(*) FROM user_books WHERE user_id = ? AND is_bookmarked = true";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting user bookmarks count", e);
        }
        
        return 0;
    }
    
    // Get author average rating
    public double getAuthorAverageRating(int userId) {
        String sql = "SELECT AVG(r.rating) FROM reviews r " +
                     "JOIN books b ON r.book_id = b.book_id " +
                     "WHERE b.author_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting author average rating", e);
        }
        
        return 0.0;
    }
    
    // Get user's recent reviews
    public List<Map<String, Object>> getUserReviews(int userId, int limit) {
        String sql = "SELECT r.review_id, r.book_id, b.title as book_title, r.rating, r.review_text, r.review_date " +
                     "FROM reviews r JOIN books b ON r.book_id = b.book_id " +
                     "WHERE r.user_id = ? " +
                     "ORDER BY r.review_date DESC " +
                     "LIMIT ?";
        
        List<Map<String, Object>> reviews = new ArrayList<>();
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setInt(2, limit);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> review = new HashMap<>();
                    review.put("reviewId", rs.getInt("review_id"));
                    review.put("bookId", rs.getInt("book_id"));
                    review.put("bookTitle", rs.getString("book_title"));
                    review.put("rating", rs.getInt("rating"));
                    review.put("reviewText", rs.getString("review_text"));
                    review.put("reviewDate", rs.getTimestamp("review_date"));
                    reviews.add(review);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting user reviews", e);
        }
        
        return reviews;
    }
    
    // Toggle user active status
    public boolean toggleUserStatus(int userId, boolean isActive) {
        String sql = "UPDATE users SET is_active = ? WHERE user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setBoolean(1, isActive);
            stmt.setInt(2, userId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error toggling user status", e);
            return false;
        }
    }
    
    // Get user statistics
    public Map<String, Object> getUserStatistics(int userId) {
        Map<String, Object> stats = new HashMap<>();
        
        stats.put("downloadsCount", getUserDownloadsCount(userId));
        stats.put("reviewsCount", getUserReviewsCount(userId));
        stats.put("bookmarksCount", getUserBookmarksCount(userId));
        
        // Check if user is an author
        User user = findById(userId);
        if (user != null && user.getRole() == User.Role.AUTHOR) {
            stats.put("averageRating", getAuthorAverageRating(userId));
            
            // Get books published count
            String sql = "SELECT COUNT(*) FROM books WHERE author_id = ?";
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                
                stmt.setInt(1, userId);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        stats.put("booksPublished", rs.getInt(1));
                    }
                }
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error getting books published count", e);
                stats.put("booksPublished", 0);
            }
        }
        
        return stats;
    }
    
    // Helper method to map ResultSet to User object
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setFirstName(rs.getString("first_name"));
        user.setLastName(rs.getString("last_name"));
        user.setEmail(rs.getString("email"));
        user.setPassword(rs.getString("password"));
        user.setRole(User.Role.valueOf(rs.getString("role")));
        user.setProfileImage(rs.getString("profile_image"));
        user.setBio(rs.getString("bio"));
        user.setRegistrationDate(rs.getTimestamp("registration_date"));
        user.setLastLogin(rs.getTimestamp("last_login"));
        user.setActive(rs.getBoolean("is_active"));
        user.setResetToken(rs.getString("reset_token"));
        user.setResetTokenExpiry(rs.getTimestamp("reset_token_expiry"));
        return user;
    }
    
    // Verify if the provided password matches the user's password
    public boolean verifyPassword(int userId, String password) {
        String sql = "SELECT password FROM users WHERE user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String storedPassword = rs.getString("password");
                    return SecurityUtil.verifyPassword(password, storedPassword);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error verifying password", e);
        }
        
        return false;
    }
    
    // Update user profile information
    public boolean updateUserProfile(User user) {
        String sql = "UPDATE users SET first_name = ?, last_name = ?, email = ?, bio = ? WHERE user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, user.getFirstName());
            stmt.setString(2, user.getLastName());
            stmt.setString(3, user.getEmail());
            stmt.setString(4, user.getBio());
            stmt.setInt(5, user.getUserId());
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating user profile", e);
            return false;
        }
    }
    
    // Deactivate a user account
    public boolean deactivateUser(int userId) {
        String sql = "UPDATE users SET is_active = false WHERE user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deactivating user", e);
            return false;
        }
    }
}
