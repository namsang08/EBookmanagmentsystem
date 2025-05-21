package mode;

import java.util.Date;

/**
 * Represents a review for a book in the e-library system
 */
public class Review {
    private int reviewId;
    private int bookId;
    private int userId;
    private double rating;
    private String comment;
    private Date reviewDate;
    
    // Additional fields from joins
    private String userName;
    private String bookTitle;
    private String bookCoverPath;
    
    /**
     * Default constructor
     */
    public Review() {
    }
    
    /**
     * Constructor with essential fields
     * 
     * @param bookId The ID of the book being reviewed
     * @param userId The ID of the user writing the review
     * @param rating The rating given (typically 1-5)
     * @param comment The text comment for the review
     */
    public Review(int bookId, int userId, double rating, String comment) {
        this.bookId = bookId;
        this.userId = userId;
        this.rating = rating;
        this.comment = comment;
        this.reviewDate = new Date(); // Current date
    }
    
    // Getters and Setters
    
    public int getReviewId() {
        return reviewId;
    }
    
    public void setReviewId(int reviewId) {
        this.reviewId = reviewId;
    }
    
    public int getBookId() {
        return bookId;
    }
    
    public void setBookId(int bookId) {
        this.bookId = bookId;
    }
    
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public double getRating() {
        return rating;
    }
    
    public void setRating(double rating) {
        this.rating = rating;
    }
    
    public String getComment() {
        return comment;
    }
    
    public void setComment(String comment) {
        this.comment = comment;
    }
    
    public Date getReviewDate() {
        return reviewDate;
    }
    
    public void setReviewDate(Date reviewDate) {
        this.reviewDate = reviewDate;
    }
    
    public String getUserName() {
        return userName;
    }
    
    public void setUserName(String userName) {
        this.userName = userName;
    }
    
    public String getBookTitle() {
        return bookTitle;
    }
    
    public void setBookTitle(String bookTitle) {
        this.bookTitle = bookTitle;
    }
    
    public String getBookCoverPath() {
        return bookCoverPath;
    }
    
    public void setBookCoverPath(String bookCoverPath) {
        this.bookCoverPath = bookCoverPath;
    }
    
    /**
     * Format the review date as a string
     * 
     * @param format The date format pattern
     * @return Formatted date string
     */
    public String getFormattedDate(String format) {
        if (reviewDate == null) {
            return "";
        }
        java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat(format);
        return dateFormat.format(reviewDate);
    }
    
    /**
     * Get HTML for displaying stars based on rating
     * 
     * @return HTML string with star icons
     */
    public String getStarsHtml() {
        StringBuilder stars = new StringBuilder();
        int fullStars = (int) Math.floor(rating);
        boolean hasHalfStar = (rating - fullStars) >= 0.5;
        
        // Add full stars
        for (int i = 0; i < fullStars; i++) {
            stars.append("<i class=\"fas fa-star\" style=\"color: gold;\"></i>");
        }
        
        // Add half star if needed
        if (hasHalfStar) {
            stars.append("<i class=\"fas fa-star-half-alt\" style=\"color: gold;\"></i>");
            fullStars++;
        }
        
        // Add empty stars to make 5 total
        for (int i = fullStars + (hasHalfStar ? 1 : 0); i < 5; i++) {
            stars.append("<i class=\"far fa-star\" style=\"color: gold;\"></i>");
        }
        
        return stars.toString();
    }
    
    @Override
    public String toString() {
        return "Review{" +
                "reviewId=" + reviewId +
                ", bookId=" + bookId +
                ", userId=" + userId +
                ", rating=" + rating +
                ", reviewDate=" + reviewDate +
                ", userName=" + userName +
                ", bookTitle=" + bookTitle +
                ", bookCoverPath=" + bookCoverPath +
                '}';
    }
}
