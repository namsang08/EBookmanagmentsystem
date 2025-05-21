package mode;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Represents the relationship between a user and a book
 */
public class UserBook {
    
    /**
     * Reading status enum
     */
    public enum ReadingStatus {
        TO_READ,
        READING,
        FINISHED
    }
    
    private int userBookId;
    private int userId;
    private int bookId;
    private ReadingStatus readingStatus;
    private boolean bookmarked;
    private int currentPage;
    private int totalPages;
    private Timestamp startDate;
    private Timestamp lastReadDate;
    private Timestamp finishDate;
    private int readingListPriority;
    private int userRating;
    
    // Book details (for convenience)
    private String bookTitle;
    private String bookCover;
    private String authorName;
    private String categoryName;
    
    /**
     * Default constructor
     */
    public UserBook() {
    }
    
    /**
     * Constructor with essential fields
     * 
     * @param userId The user ID
     * @param bookId The book ID
     * @param readingStatus The reading status
     */
    public UserBook(int userId, int bookId, ReadingStatus readingStatus) {
        this.userId = userId;
        this.bookId = bookId;
        this.readingStatus = readingStatus;
        this.bookmarked = false;
        this.currentPage = 0;
        this.readingListPriority = 0;
        this.userRating = 0;
    }
    
    // Getters and setters
    
    public int getUserBookId() {
        return userBookId;
    }
    
    public void setUserBookId(int userBookId) {
        this.userBookId = userBookId;
    }
    
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public int getBookId() {
        return bookId;
    }
    
    public void setBookId(int bookId) {
        this.bookId = bookId;
    }
    
    public ReadingStatus getReadingStatus() {
        return readingStatus;
    }
    
    public void setReadingStatus(ReadingStatus readingStatus) {
        this.readingStatus = readingStatus;
    }
    
    public boolean isBookmarked() {
        return bookmarked;
    }
    
    public void setBookmarked(boolean bookmarked) {
        this.bookmarked = bookmarked;
    }
    
    public int getCurrentPage() {
        return currentPage;
    }
    
    public void setCurrentPage(int currentPage) {
        this.currentPage = currentPage;
    }
    
    public int getTotalPages() {
        return totalPages;
    }
    
    public void setTotalPages(int totalPages) {
        this.totalPages = totalPages;
    }
    
    public Timestamp getStartDate() {
        return startDate;
    }
    
    public void setStartDate(Timestamp startDate) {
        this.startDate = startDate;
    }
    
    public Timestamp getLastReadDate() {
        return lastReadDate;
    }
    
    public void setLastReadDate(Timestamp lastReadDate) {
        this.lastReadDate = lastReadDate;
    }
    
    public Timestamp getFinishDate() {
        return finishDate;
    }
    
    public void setFinishDate(Timestamp finishDate) {
        this.finishDate = finishDate;
    }
    
    public int getReadingListPriority() {
        return readingListPriority;
    }
    
    public void setReadingListPriority(int readingListPriority) {
        this.readingListPriority = readingListPriority;
    }
    
    public int getUserRating() {
        return userRating;
    }
    
    public void setUserRating(int userRating) {
        this.userRating = userRating;
    }
    
    public String getBookTitle() {
        return bookTitle;
    }
    
    public void setBookTitle(String bookTitle) {
        this.bookTitle = bookTitle;
    }
    
    public String getBookCover() {
        return bookCover;
    }
    
    public void setBookCover(String bookCover) {
        this.bookCover = bookCover;
    }
    
    public String getAuthorName() {
        return authorName;
    }
    
    public void setAuthorName(String authorName) {
        this.authorName = authorName;
    }
    
    public String getCategoryName() {
        return categoryName;
    }
    
    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }
    
    /**
     * Get the reading progress percentage
     * 
     * @return Progress percentage (0-100)
     */
    public int getProgressPercentage() {
        if (totalPages > 0) {
            return (int) Math.round((double) currentPage / totalPages * 100);
        }
        return 0;
    }
    
    /**
     * Get formatted start date
     * 
     * @return Formatted date string
     */
    public String getFormattedStartDate() {
        if (startDate == null) {
            return "Not started";
        }
        SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy");
        return sdf.format(new Date(startDate.getTime()));
    }
    
    /**
     * Get formatted last read date
     * 
     * @return Formatted date string
     */
    public String getFormattedLastReadDate() {
        if (lastReadDate == null) {
            return "Never";
        }
        SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy");
        return sdf.format(new Date(lastReadDate.getTime()));
    }
    
    /**
     * Get formatted finish date
     * 
     * @return Formatted date string
     */
    public String getFormattedFinishDate() {
        if (finishDate == null) {
            return "Not finished";
        }
        SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy");
        return sdf.format(new Date(finishDate.getTime()));
    }
    
    /**
     * Get reading status as a user-friendly string
     * 
     * @return Status string
     */
    public String getReadingStatusString() {
        switch (readingStatus) {
            case TO_READ:
                return "To Read";
            case READING:
                return "Currently Reading";
            case FINISHED:
                return "Finished";
            default:
                return "Unknown";
        }
    }
    
    /**
     * Get CSS class for the reading status
     * 
     * @return CSS class name
     */
    public String getStatusClass() {
        switch (readingStatus) {
            case TO_READ:
                return "badge bg-secondary";
            case READING:
                return "badge bg-primary";
            case FINISHED:
                return "badge bg-success";
            default:
                return "badge bg-light";
        }
    }
    
    /**
     * Get estimated time to finish the book
     * 
     * @param pagesPerHour Average pages read per hour
     * @return Estimated hours to finish
     */
    public double getEstimatedTimeToFinish(int pagesPerHour) {
        if (pagesPerHour <= 0) {
            pagesPerHour = 30; // Default value
        }
        
        int pagesLeft = totalPages - currentPage;
        if (pagesLeft <= 0) {
            return 0;
        }
        
        return (double) pagesLeft / pagesPerHour;
    }
    
    /**
     * Get formatted estimated time to finish
     * 
     * @param pagesPerHour Average pages read per hour
     * @return Formatted time string
     */
    public String getFormattedEstimatedTime(int pagesPerHour) {
        double hours = getEstimatedTimeToFinish(pagesPerHour);
        
        if (hours <= 0) {
            return "Finished";
        }
        
        int wholeHours = (int) hours;
        int minutes = (int) Math.round((hours - wholeHours) * 60);
        
        if (wholeHours == 0) {
            return minutes + " min";
        } else if (minutes == 0) {
            return wholeHours + " h";
        } else {
            return wholeHours + " h " + minutes + " min";
        }
    }
    
    /**
     * Get reading list priority as a string
     * 
     * @return Priority string
     */
    public String getPriorityString() {
        if (readingListPriority <= 0) {
            return "Not in reading list";
        } else if (readingListPriority == 1) {
            return "Highest";
        } else if (readingListPriority <= 3) {
            return "High";
        } else if (readingListPriority <= 6) {
            return "Medium";
        } else {
            return "Low";
        }
    }
    
    /**
     * Get CSS class for the priority
     * 
     * @return CSS class name
     */
    public String getPriorityClass() {
        if (readingListPriority <= 0) {
            return "";
        } else if (readingListPriority == 1) {
            return "text-danger fw-bold";
        } else if (readingListPriority <= 3) {
            return "text-danger";
        } else if (readingListPriority <= 6) {
            return "text-warning";
        } else {
            return "text-info";
        }
    }
}
