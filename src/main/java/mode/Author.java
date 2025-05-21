package mode;

import java.sql.Timestamp;
import java.util.List;

/**
 * Author class extending User with author-specific properties
 */
public class Author extends User {
    private int totalBooks;
    private int totalDownloads;
    private double averageRating;
    private List<Book> books;
    
    // Default constructor
    public Author() {
        super();
        setRole(Role.AUTHOR);
    }
    
    // Constructor with essential fields
    public Author(String firstName, String lastName, String email, String password) {
        super(firstName, lastName, email, password, Role.AUTHOR);
        this.totalBooks = 0;
        this.totalDownloads = 0;
        this.averageRating = 0.0;
    }
    
    // Getters and Setters
    public int getTotalBooks() {
        return totalBooks;
    }
    
    public void setTotalBooks(int totalBooks) {
        this.totalBooks = totalBooks;
    }
    
    public int getTotalDownloads() {
        return totalDownloads;
    }
    
    public void setTotalDownloads(int totalDownloads) {
        this.totalDownloads = totalDownloads;
    }
    
    public double getAverageRating() {
        return averageRating;
    }
    
    public void setAverageRating(double averageRating) {
        this.averageRating = averageRating;
    }
    
    public List<Book> getBooks() {
        return books;
    }
    
    public void setBooks(List<Book> books) {
        this.books = books;
        if (books != null) {
            this.totalBooks = books.size();
            
            // Calculate total downloads and average rating
            int downloads = 0;
            double totalRating = 0.0;
            int ratedBooks = 0;
            
            for (Book book : books) {
                downloads += book.getDownloads();
                
                if (book.getRating() > 0) {
                    totalRating += book.getRating();
                    ratedBooks++;
                }
            }
            
            this.totalDownloads = downloads;
            this.averageRating = ratedBooks > 0 ? totalRating / ratedBooks : 0.0;
        }
    }
    
    @Override
    public String toString() {
        return "Author{" +
                "userId=" + getUserId() +
                ", name='" + getFullName() + '\'' +
                ", email='" + getEmail() + '\'' +
                ", totalBooks=" + totalBooks +
                ", totalDownloads=" + totalDownloads +
                ", averageRating=" + averageRating +
                '}';
    }
}
