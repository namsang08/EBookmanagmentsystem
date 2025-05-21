package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import mode.Category;
import util.DBUtil;

/**
 * Data Access Object for category-related database operations
 */
public class CategoryDAO {
    
    /**
     * Get all categories
     * 
     * @return List of all categories with book counts
     * @throws SQLException If a database error occurs
     */
    public List<Category> getAllCategories() throws SQLException {
        List<Category> categories = new ArrayList<>();
        String sql = "SELECT c.*, COUNT(b.book_id) as book_count " +
                     "FROM categories c " +
                     "LEFT JOIN books b ON c.category_id = b.category_id " +
                     "GROUP BY c.category_id " +
                     "ORDER BY c.name";
        
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Category category = new Category();
                category.setCategoryId(rs.getInt("category_id"));
                category.setName(rs.getString("name"));
                category.setDescription(rs.getString("description"));
                category.setCreatedAt(rs.getTimestamp("created_at"));
                category.setBookCount(rs.getInt("book_count"));
                
                categories.add(category);
            }
        }
        return categories;
    }
    
    /**
     * Get a single category by ID
     * 
     * @param categoryId The ID of the category to retrieve
     * @return The Category object if found, null otherwise
     * @throws SQLException If a database error occurs
     */
    public Category getCategoryById(int categoryId) throws SQLException {
        Category category = null;
        String sql = "SELECT c.*, COUNT(b.book_id) as book_count " +
                     "FROM categories c " +
                     "LEFT JOIN books b ON c.category_id = b.category_id " +
                     "WHERE c.category_id = ? " +
                     "GROUP BY c.category_id";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, categoryId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    category = new Category();
                    category.setCategoryId(rs.getInt("category_id"));
                    category.setName(rs.getString("name"));
                    category.setDescription(rs.getString("description"));
                    category.setCreatedAt(rs.getTimestamp("created_at"));
                    category.setBookCount(rs.getInt("book_count"));
                }
            }
        }
        return category;
    }
    
    /**
     * Add a new category
     * 
     * @param category The Category object to add
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean addCategory(Category category) throws SQLException {
        String sql = "INSERT INTO categories (name, description) VALUES (?, ?)";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, category.getName());
            pstmt.setString(2, category.getDescription());
            
            int rowsAffected = pstmt.executeUpdate();
            
            if (rowsAffected > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        category.setCategoryId(generatedKeys.getInt(1));
                        return true;
                    }
                }
            }
            return false;
        }
    }
    
    /**
     * Update an existing category
     * 
     * @param category The Category object to update
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean updateCategory(Category category) throws SQLException {
        String sql = "UPDATE categories SET name = ?, description = ? WHERE category_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, category.getName());
            pstmt.setString(2, category.getDescription());
            pstmt.setInt(3, category.getCategoryId());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        }
    }
    
    /**
     * Delete a category
     * 
     * @param categoryId The ID of the category to delete
     * @return true if successful, false otherwise
     * @throws SQLException If a database error occurs
     */
    public boolean deleteCategory(int categoryId) throws SQLException {
        String sql = "DELETE FROM categories WHERE category_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, categoryId);
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
        }
    }
}
