package mode;

import java.util.Date;

/**
 * Represents a book in the e-library system
 */
public class Book {
    
    public enum Status {
        PENDING, APPROVED, REJECTED
    }
    
    private int bookId;
    private String title;
    private String description;
    private int authorId;
    private int categoryId;
    private String filePath;
    private String coverImagePath;
    private String language;
    private int pages;
    private Date publicationDate;
    private Date uploadDate;
    private int views;
    private int downloads;
    private Status status;
    private String tags;
    private String format;
    private String fileSize;
    private double rating;
    
    // Additional fields from joins
    private String authorName;
    private String categoryName;
    
    // User-specific reading fields
    private int readingProgress;
    private String readingStatus;
    private int readingPriority;
    private Date completedDate;
    private Date lastReadTime;
    private boolean bookmarked;
    
    // Constructors
    public Book() {
    }
    
    public Book(String title, String description, int authorId, int categoryId, 
                String filePath, String coverImagePath, String language, int pages, 
                Date publicationDate, Status status, String tags) {
        this.title = title;
        this.description = description;
        this.authorId = authorId;
        this.categoryId = categoryId;
        this.filePath = filePath;
        this.coverImagePath = coverImagePath;
        this.language = language;
        this.pages = pages;
        this.publicationDate = publicationDate;
        this.status = status;
        this.tags = tags;
        this.views = 0;
        this.downloads = 0;
        this.uploadDate = new Date();
        this.rating = 0.0;
    }
    
    // Getters and Setters
    public int getBookId() {
        return bookId;
    }
    
    public void setBookId(int bookId) {
        this.bookId = bookId;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public int getAuthorId() {
        return authorId;
    }
    
    public void setAuthorId(int authorId) {
        this.authorId = authorId;
    }
    
    public int getCategoryId() {
        return categoryId;
    }
    
    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }
    
    public String getFilePath() {
        return filePath;
    }
    
    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }
    
    public String getCoverImagePath() {
        return coverImagePath;
    }
    
    public void setCoverImagePath(String coverImagePath) {
        this.coverImagePath = coverImagePath;
    }
    
    public String getLanguage() {
        return language;
    }
    
    public void setLanguage(String language) {
        this.language = language;
    }
    
    public int getPages() {
        return pages;
    }
    
    public void setPages(int pages) {
        this.pages = pages;
    }
    
    public Date getPublicationDate() {
        return publicationDate;
    }
    
    public void setPublicationDate(Date publicationDate) {
        this.publicationDate = publicationDate;
    }
    
    public Date getUploadDate() {
        return uploadDate;
    }
    
    public void setUploadDate(Date uploadDate) {
        this.uploadDate = uploadDate;
    }
    
    public int getViews() {
        return views;
    }
    
    public void setViews(int views) {
        this.views = views;
    }
    
    public int getDownloads() {
        return downloads;
    }
    
    public void setDownloads(int downloads) {
        this.downloads = downloads;
    }
    
    public Status getStatus() {
        return status;
    }
    
    public void setStatus(Status status) {
        this.status = status;
    }
    
    public String getTags() {
        return tags;
    }
    
    public void setTags(String tags) {
        this.tags = tags;
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
    
    public String getFormat() {
        return format;
    }
    
    public void setFormat(String format) {
        this.format = format;
    }
    
    public String getFileSize() {
        return fileSize;
    }
    
    public void setFileSize(String fileSize) {
        this.fileSize = fileSize;
    }
    
    public double getRating() {
        return rating;
    }
    
    public void setRating(double rating) {
        this.rating = rating;
    }
    
    /**
     * Increment the view count of this book
     */
    public void incrementViews() {
        this.views++;
    }
    
    /**
     * Increment the download count of this book
     */
    public void incrementDownloads() {
        this.downloads++;
    }
    
    // New getters and setters for user-specific reading fields
    
    /**
     * Get the reading progress (0-100)
     * @return The reading progress percentage
     */
    public int getReadingProgress() {
        return readingProgress;
    }
    
    /**
     * Set the reading progress (0-100)
     * @param readingProgress The reading progress percentage
     */
    public void setReadingProgress(int readingProgress) {
        this.readingProgress = readingProgress;
    }
    
    /**
     * Get the reading status (READING, TO_READ, FINISHED)
     * @return The reading status
     */
    public String getReadingStatus() {
        return readingStatus;
    }
    
    /**
     * Set the reading status (READING, TO_READ, FINISHED)
     * @param readingStatus The reading status
     */
    public void setReadingStatus(String readingStatus) {
        this.readingStatus = readingStatus;
    }
    
    /**
     * Get the reading priority (for TO_READ books)
     * @return The reading priority (lower number = higher priority)
     */
    public int getReadingPriority() {
        return readingPriority;
    }
    
    /**
     * Set the reading priority (for TO_READ books)
     * @param readingPriority The reading priority (lower number = higher priority)
     */
    public void setReadingPriority(int readingPriority) {
        this.readingPriority = readingPriority;
    }
    
    /**
     * Get the date when the book was completed
     * @return The completion date
     */
    public Date getCompletedDate() {
        return completedDate;
    }
    
    /**
     * Set the date when the book was completed
     * @param completedDate The completion date
     */
    public void setCompletedDate(Date completedDate) {
        this.completedDate = completedDate;
    }
    
    /**
     * Get the time when the book was last read
     * @return The last read time
     */
    public Date getLastReadTime() {
        return lastReadTime;
    }
    
    /**
     * Set the time when the book was last read
     * @param lastReadTime The last read time
     */
    public void setLastReadTime(Date lastReadTime) {
        this.lastReadTime = lastReadTime;
    }
    
    /**
     * Check if the book is bookmarked
     * @return true if bookmarked, false otherwise
     */
    public boolean isBookmarked() {
        return bookmarked;
    }
    
    /**
     * Set whether the book is bookmarked
     * @param bookmarked true if bookmarked, false otherwise
     */
    public void setBookmarked(boolean bookmarked) {
        this.bookmarked = bookmarked;
    }
    
    /**
     * Get the formatted reading progress as a string (e.g., "45%")
     * @return The formatted reading progress
     */
    public String getFormattedProgress() {
        return readingProgress + "%";
    }
    
    /**
     * Get the formatted reading status as a user-friendly string
     * @return The formatted reading status
     */
    public String getFormattedReadingStatus() {
        if (readingStatus == null) {
            return "Not Started";
        }
        
        switch (readingStatus) {
            case "READING":
                return "Currently Reading";
            case "TO_READ":
                return "To Read";
            case "FINISHED":
                return "Finished";
            default:
                return readingStatus;
        }
    }
    
    /**
     * Get the CSS class for the reading status
     * @return The CSS class name
     */
    public String getReadingStatusClass() {
        if (readingStatus == null) {
            return "status-not-started";
        }
        
        switch (readingStatus) {
            case "READING":
                return "status-reading";
            case "TO_READ":
                return "status-to-read";
            case "FINISHED":
                return "status-finished";
            default:
                return "status-not-started";
        }
    }
    
    /**
     * Get the estimated time to finish the book based on reading progress
     * @return The estimated time to finish in minutes
     */
    public int getEstimatedTimeToFinish() {
        if (readingProgress >= 100) {
            return 0;
        }
        
        // Assuming average reading speed of 2 minutes per page
        int pagesLeft = (int) Math.ceil(pages * (100 - readingProgress) / 100.0);
        return pagesLeft * 2;
    }
    
    /**
     * Get the formatted estimated time to finish the book
     * @return The formatted estimated time (e.g., "2h 30m")
     */
    public String getFormattedEstimatedTime() {
        int minutes = getEstimatedTimeToFinish();
        
        if (minutes == 0) {
            return "Completed";
        }
        
        int hours = minutes / 60;
        minutes = minutes % 60;
        
        if (hours > 0) {
            return hours + "h " + (minutes > 0 ? minutes + "m" : "");
        } else {
            return minutes + "m";
        }
    }
    
    @Override
    public String toString() {
        return "Book [bookId=" + bookId + ", title=" + title + ", authorId=" + authorId + 
               ", categoryId=" + categoryId + ", status=" + status + "]";
    }
}
