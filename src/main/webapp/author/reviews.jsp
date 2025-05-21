<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="mode.Book"%>
<%@ page import="mode.User"%>
<%@ page import="mode.Review"%>
<%@ page import="dao.BookDAO"%>
<%@ page import="dao.ReviewDAO"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reviews - E-Library Hub</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .dashboard-container {
            display: grid;
            grid-template-columns: 250px 1fr;
            min-height: calc(100vh - 60px);
        }
        
        .sidebar {
            background-color: #2c3e50;
            color: white;
            padding: 20px 0;
        }
        
        .sidebar-header {
            padding: 0 20px 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            margin-bottom: 20px;
        }
        
        .sidebar-header h2 {
            font-size: 1.2rem;
            margin-bottom: 5px;
        }
        
        .sidebar-header p {
            font-size: 0.9rem;
            opacity: 0.7;
        }
        
        .sidebar-menu {
            list-style: none;
        }
        
        .sidebar-menu li {
            margin-bottom: 5px;
        }
        
        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 10px 20px;
            color: rgba(255, 255, 255, 0.7);
            transition: all 0.3s ease;
        }
        
        .sidebar-menu a:hover, .sidebar-menu a.active {
            background-color: rgba(255, 255, 255, 0.1);
            color: white;
        }
        
        .sidebar-menu i {
            margin-right: 10px;
            width: 20px;
            text-align: center;
        }
        
        .main-content {
            padding: 20px;
            background-color: #f8f9fa;
        }
        
        .dashboard-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .dashboard-title {
            font-size: 1.5rem;
        }
        
        .filter-controls {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        
        .filter-group {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .filter-label {
            font-weight: 500;
            white-space: nowrap;
        }
        
        .reviews-container {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
        }
        
        .reviews-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .reviews-title {
            font-size: 1.2rem;
        }
        
        .reviews-stats {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .review-stat {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 15px;
            background-color: var(--secondary-color);
            border-radius: var(--border-radius);
            min-width: 100px;
        }
        
        .review-stat-value {
            font-size: 1.5rem;
            font-weight: 600;
        }
        
        .review-stat-label {
            font-size: 0.8rem;
            color: var(--text-light);
        }
        
        .review-list {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }
        
        .review-card {
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            padding: 20px;
            transition: all 0.3s ease;
        }
        
        .review-card:hover {
            box-shadow: var(--shadow);
        }
        
        .review-card-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }
        
        .review-book {
            font-weight: 600;
            font-size: 1.1rem;
        }
        
        .review-rating {
            color: gold;
        }
        
        .review-user {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 10px;
        }
        
        .review-user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
        }
        
        .review-user-name {
            font-weight: 500;
        }
        
        .review-date {
            font-size: 0.8rem;
            color: var(--text-light);
        }
        
        .review-content {
            margin-bottom: 15px;
            line-height: 1.5;
        }
        
        .review-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            margin-top: 20px;
        }
        
        .pagination-item {
            width: 35px;
            height: 35px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            margin: 0 5px;
            background-color: var(--secondary-color);
            color: var(--text-color);
            text-decoration: none;
            transition: all 0.3s ease;
        }
        
        .pagination-item:hover, .pagination-item.active {
            background-color: var(--primary-color);
            color: white;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px 20px;
        }
        
        .empty-state-icon {
            font-size: 3rem;
            color: #ddd;
            margin-bottom: 15px;
        }
        
        /* Modal styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0, 0, 0, 0.5);
        }
        
        .modal-content {
            background-color: #fefefe;
            margin: 10% auto;
            padding: 20px;
            border-radius: var(--border-radius);
            width: 80%;
            max-width: 600px;
            box-shadow: var(--shadow);
            position: relative;
        }
        
        .close-modal {
            position: absolute;
            right: 20px;
            top: 15px;
            font-size: 1.5rem;
            cursor: pointer;
        }
        
        .modal-header {
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border-color);
        }
        
        .modal-title {
            font-size: 1.3rem;
            margin: 0;
        }
        
        .modal-body {
            margin-bottom: 20px;
        }
        
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        
        @media (max-width: 992px) {
            .dashboard-container {
                grid-template-columns: 1fr;
            }
            
            .sidebar {
                display: none;
            }
            
            .filter-controls {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .reviews-stats {
                flex-wrap: wrap;
            }
        }
    </style>
</head>
<body>
    <%
    // Check if user is logged in and is an author
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRole() != User.Role.AUTHOR) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get author's books
    BookDAO bookDAO = new BookDAO();
    ReviewDAO reviewDAO = new ReviewDAO();
    List<Book> authorBooks = new ArrayList<>();
    
    try {
        authorBooks = bookDAO.getBooksByAuthor(user.getUserId());
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    // Get filter parameters
    String bookFilter = request.getParameter("bookId");
    String ratingFilter = request.getParameter("rating");
    String sortBy = request.getParameter("sortBy");
    
    int selectedBookId = 0;
    int selectedRating = 0;
    String selectedSort = "newest";
    
    try {
        if (bookFilter != null) {
            selectedBookId = Integer.parseInt(bookFilter);
        }
        if (ratingFilter != null) {
            selectedRating = Integer.parseInt(ratingFilter);
        }
        if (sortBy != null) {
            selectedSort = sortBy;
        }
    } catch (NumberFormatException e) {
        // Use defaults
    }
    
    // Get reviews for author's books
    List<Review> reviews = new ArrayList<>();
    
    try {
        // Get all reviews for all author's books
        for (Book book : authorBooks) {
            List<Review> bookReviews = reviewDAO.getReviewsByBook(book.getBookId());
            reviews.addAll(bookReviews);
        }
        
        // Apply filters
        if (selectedBookId > 0) {
            List<Review> filteredReviews = new ArrayList<>();
            for (Review review : reviews) {
                if (review.getBookId() == selectedBookId) {
                    filteredReviews.add(review);
                }
            }
            reviews = filteredReviews;
        }
        
        if (selectedRating > 0) {
            List<Review> filteredReviews = new ArrayList<>();
            for (Review review : reviews) {
                if ((int)review.getRating() == selectedRating) {
                    filteredReviews.add(review);
                }
            }
            reviews = filteredReviews;
        }
        
        // Apply sorting
        if ("oldest".equals(selectedSort)) {
            reviews.sort((r1, r2) -> r1.getReviewDate().compareTo(r2.getReviewDate()));
        } else if ("highest".equals(selectedSort)) {
            reviews.sort((r1, r2) -> Double.compare(r2.getRating(), r1.getRating()));
        } else if ("lowest".equals(selectedSort)) {
            reviews.sort((r1, r2) -> Double.compare(r1.getRating(), r2.getRating()));
        } else {
            // Default: newest first
            reviews.sort((r1, r2) -> r2.getReviewDate().compareTo(r1.getReviewDate()));
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    // Calculate review statistics
    int totalReviews = reviews.size();
    int fiveStarReviews = 0;
    int fourStarReviews = 0;
    int threeStarReviews = 0;
    int twoStarReviews = 0;
    int oneStarReviews = 0;
    double averageRating = 0;
    
    for (Review review : reviews) {
        double rating = review.getRating();
        averageRating += rating;
        
        if (rating >= 4.5) {
            fiveStarReviews++;
        } else if (rating >= 3.5) {
            fourStarReviews++;
        } else if (rating >= 2.5) {
            threeStarReviews++;
        } else if (rating >= 1.5) {
            twoStarReviews++;
        } else {
            oneStarReviews++;
        }
    }
    
    if (totalReviews > 0) {
        averageRating /= totalReviews;
    }
    
    // Format date
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("h:mm a");
    String currentDate = dateFormat.format(new Date());
    
    // Pagination
    int currentPage = 1;
    int reviewsPerPage = 10;
    int totalPages = (int) Math.ceil((double) reviews.size() / reviewsPerPage);
    
    try {
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            currentPage = Integer.parseInt(pageParam);
            if (currentPage < 1) {
                currentPage = 1;
            } else if (currentPage > totalPages) {
                currentPage = totalPages;
            }
        }
    } catch (NumberFormatException e) {
        // Use default
    }
    
    // Get reviews for current page
    List<Review> currentPageReviews = new ArrayList<>();
    int startIndex = (currentPage - 1) * reviewsPerPage;
    int endIndex = Math.min(startIndex + reviewsPerPage, reviews.size());
    
    if (startIndex < reviews.size()) {
        currentPageReviews = reviews.subList(startIndex, endIndex);
    }
    %>

    <header class="main-header">
        <div class="container">
            <div class="logo">
                <i class="fas fa-book-open"></i>
                <h1>E-Library Hub</h1>
            </div>
            <nav class="main-nav">
                <ul>
                    <li><a href="../index.jsp">Home</a></li>
                    <li><a href="../browsebook.jsp">Browse Books</a></li>
                    <li><a href="../LogoutServlet">Logout</a></li>
                </ul>
            </nav>
            <button class="mobile-menu-toggle">
                <i class="fas fa-bars"></i>
            </button>
        </div>
    </header>

    <div class="dashboard-container">
        <aside class="sidebar">
            <div class="sidebar-header">
                <h2>Author Dashboard</h2>
                <p>Welcome, <%= user.getFirstName() %></p>
            </div>
            <ul class="sidebar-menu">
                <li><a href="dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="my-books.jsp"><i class="fas fa-book"></i> My Books</a></li>
                <li><a href="upload-book.jsp"><i class="fas fa-upload"></i> Upload Book</a></li>
                <li><a href="analytics.jsp"><i class="fas fa-chart-line"></i> Analytics</a></li>
                <li><a href="reviews.jsp" class="active"><i class="fas fa-star"></i> Reviews</a></li>
                <li><a href="profile.jsp"><i class="fas fa-user"></i> Profile</a></li>
                <li><a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>
        
        <main class="main-content">
            <div class="dashboard-header">
                <h1 class="dashboard-title">Reviews</h1>
                <div class="date">
                    <i class="far fa-calendar-alt"></i> <%= currentDate %>
                </div>
            </div>
            
            <div class="filter-controls">
                <div class="filter-group">
                    <span class="filter-label">Book:</span>
                    <select id="bookFilter" class="form-control" onchange="updateFilters()">
                        <option value="0" <%= selectedBookId == 0 ? "selected" : "" %>>All Books</option>
                        <% for (Book book : authorBooks) { %>
                        <option value="<%= book.getBookId() %>" <%= selectedBookId == book.getBookId() ? "selected" : "" %>><%= book.getTitle() %></option>
                        <% } %>
                    </select>
                </div>
                
                <div class="filter-group">
                    <span class="filter-label">Rating:</span>
                    <select id="ratingFilter" class="form-control" onchange="updateFilters()">
                        <option value="0" <%= selectedRating == 0 ? "selected" : "" %>>All Ratings</option>
                        <option value="5" <%= selectedRating == 5 ? "selected" : "" %>>5 Stars</option>
                        <option value="4" <%= selectedRating == 4 ? "selected" : "" %>>4 Stars</option>
                        <option value="3" <%= selectedRating == 3 ? "selected" : "" %>>3 Stars</option>
                        <option value="2" <%= selectedRating == 2 ? "selected" : "" %>>2 Stars</option>
                        <option value="1" <%= selectedRating == 1 ? "selected" : "" %>>1 Star</option>
                    </select>
                </div>
                
                <div class="filter-group">
                    <span class="filter-label">Sort By:</span>
                    <select id="sortBy" class="form-control" onchange="updateFilters()">
                        <option value="newest" <%= "newest".equals(selectedSort) ? "selected" : "" %>>Newest First</option>
                        <option value="oldest" <%= "oldest".equals(selectedSort) ? "selected" : "" %>>Oldest First</option>
                        <option value="highest" <%= "highest".equals(selectedSort) ? "selected" : "" %>>Highest Rating</option>
                        <option value="lowest" <%= "lowest".equals(selectedSort) ? "selected" : "" %>>Lowest Rating</option>
                    </select>
                </div>
            </div>
            
            <div class="reviews-container">
                <div class="reviews-header">
                    <h2 class="reviews-title">All Reviews (<%= totalReviews %>)</h2>
                </div>
                
                <div class="reviews-stats">
                    <div class="review-stat">
                        <div class="review-stat-value"><%= String.format("%.1f", averageRating) %></div>
                        <div class="review-stat-label">Average Rating</div>
                    </div>
                    
                    <div class="review-stat">
                        <div class="review-stat-value"><%= fiveStarReviews %></div>
                        <div class="review-stat-label">5 Stars</div>
                    </div>
                    
                    <div class="review-stat">
                        <div class="review-stat-value"><%= fourStarReviews %></div>
                        <div class="review-stat-label">4 Stars</div>
                    </div>
                    
                    <div class="review-stat">
                        <div class="review-stat-value"><%= threeStarReviews %></div>
                        <div class="review-stat-label">3 Stars</div>
                    </div>
                    
                    <div class="review-stat">
                        <div class="review-stat-value"><%= twoStarReviews %></div>
                        <div class="review-stat-label">2 Stars</div>
                    </div>
                    
                    <div class="review-stat">
                        <div class="review-stat-value"><%= oneStarReviews %></div>
                        <div class="review-stat-label">1 Star</div>
                    </div>
                </div>
                
                <div class="review-list">
                    <% if (currentPageReviews.isEmpty()) { %>
                    <div class="empty-state">
                        <div class="empty-state-icon">
                            <i class="fas fa-star"></i>
                        </div>
                        <h3>No Reviews Yet</h3>
                        <p>Your books haven't received any reviews yet.</p>
                    </div>
                    <% } else { %>
                        <% for (Review review : currentPageReviews) { %>
                        <div class="review-card">
                            <div class="review-card-header">
                                <div class="review-book"><%= review.getBookTitle() %></div>
                                <div class="review-rating">
                                    <% for (int i = 1; i <= 5; i++) { %>
                                        <% if (i <= review.getRating()) { %>
                                            <i class="fas fa-star"></i>
                                        <% } else if (i - 0.5 <= review.getRating()) { %>
                                            <i class="fas fa-star-half-alt"></i>
                                        <% } else { %>
                                            <i class="far fa-star"></i>
                                        <% } %>
                                    <% } %>
                                    <%= String.format("%.1f", review.getRating()) %>
                                </div>
                            </div>
                            
                            <div class="review-user">
                                <img src="../images/default-avatar.png" alt="User Avatar" class="review-user-avatar">
                                <div>
                                    <div class="review-user-name"><%= review.getUserName() %></div>
                                    <div class="review-date">
                                        <%= dateFormat.format(review.getReviewDate()) %> at <%= timeFormat.format(review.getReviewDate()) %>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="review-content">
                                <%= review.getComment() %>
                            </div>
                            
                            <div class="review-actions">
                                <button class="btn-secondary" onclick="viewReview(<%= review.getReviewId() %>)">
                                    <i class="fas fa-eye"></i> View
                                </button>
                                <button class="btn-primary" onclick="replyToReview(<%= review.getReviewId() %>)">
                                    <i class="fas fa-reply"></i> Reply
                                </button>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
                
                <% if (totalPages > 1) { %>
                <div class="pagination">
                    <% if (currentPage > 1) { %>
                    <a href="?page=<%= currentPage - 1 %>&bookId=<%= selectedBookId %>&rating=<%= selectedRating %>&sortBy=<%= selectedSort %>" class="pagination-item">
                        <i class="fas fa-chevron-left"></i>
                    </a>
                    <% } %>
                    
                    <% 
                    int startPage = Math.max(1, currentPage - 2);
                    int endPage = Math.min(totalPages, startPage + 4);
                    
                    if (endPage - startPage < 4) {
                        startPage = Math.max(1, endPage - 4);
                    }
                    
                    for (int i = startPage; i <= endPage; i++) { 
                    %>
                    <a href="?page=<%= i %>&bookId=<%= selectedBookId %>&rating=<%= selectedRating %>&sortBy=<%= selectedSort %>" 
                       class="pagination-item <%= i == currentPage ? "active" : "" %>">
                        <%= i %>
                    </a>
                    <% } %>
                    
                    <% if (currentPage < totalPages) { %>
                    <a href="?page=<%= currentPage + 1 %>&bookId=<%= selectedBookId %>&rating=<%= selectedRating %>&sortBy=<%= selectedSort %>" class="pagination-item">
                        <i class="fas fa-chevron-right"></i>
                    </a>
                    <% } %>
                </div>
                <% } %>
            </div>
        </main>
    </div>
    
    <!-- View Review Modal -->
    <div id="viewReviewModal" class="modal">
        <div class="modal-content">
            <span class="close-modal">&times;</span>
            <div class="modal-header">
                <h2 class="modal-title">Review Details</h2>
            </div>
            <div class="modal-body" id="reviewDetailsContent">
                <!-- Review details will be loaded here -->
            </div>
            <div class="modal-footer">
                <button class="btn-secondary close-modal-btn">Close</button>
            </div>
        </div>
    </div>
    
    <!-- Reply to Review Modal -->
    <div id="replyReviewModal" class="modal">
        <div class="modal-content">
            <span class="close-modal">&times;</span>
            <div class="modal-header">
                <h2 class="modal-title">Reply to Review</h2>
            </div>
            <div class="modal-body">
                <div id="replyReviewContent">
                    <!-- Review content will be loaded here -->
                </div>
                <form id="replyForm" action="../ReviewServlet" method="post">
                    <input type="hidden" name="action" value="replyToReview">
                    <input type="hidden" id="reviewId" name="reviewId" value="">
                    
                    <div class="form-group">
                        <label for="replyText">Your Reply</label>
                        <textarea id="replyText" name="replyText" class="form-control" rows="5" required></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button class="btn-secondary close-modal-btn">Cancel</button>
                <button class="btn-primary" id="submitReplyBtn">Submit Reply</button>
            </div>
        </div>
    </div>

    <script>
        // Mobile menu toggle
        document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
            document.querySelector('.main-nav').classList.toggle('active');
        });
        
        // Update filters
        function updateFilters() {
            const bookId = document.getElementById('bookFilter').value;
            const rating = document.getElementById('ratingFilter').value;
            const sortBy = document.getElementById('sortBy').value;
            
            window.location.href = 'reviews.jsp?bookId=' + bookId + '&rating=' + rating + '&sortBy=' + sortBy;
        }
        
        // Modal functions
        function openModal(modalId) {
            document.getElementById(modalId).style.display = 'block';
            document.body.style.overflow = 'hidden';
        }
        
        function closeModal(modalId) {
            document.getElementById(modalId).style.display = 'none';
            document.body.style.overflow = 'auto';
        }
        
        // Close modals when clicking on X or close button
        document.querySelectorAll('.close-modal, .close-modal-btn').forEach(function(element) {
            element.addEventListener('click', function() {
                document.querySelectorAll('.modal').forEach(function(modal) {
                    modal.style.display = 'none';
                });
                document.body.style.overflow = 'auto';
            });
        });
        
        // Close modals when clicking outside the modal content
        window.addEventListener('click', function(event) {
            document.querySelectorAll('.modal').forEach(function(modal) {
                if (event.target === modal) {
                    modal.style.display = 'none';
                    document.body.style.overflow = 'auto';
                }
            });
        });
        
        // View review details
        function viewReview(reviewId) {
            // In a real implementation, you would fetch review details from the server
            // For now, we'll just show a placeholder
            
            const reviewDetailsContent = document.getElementById('reviewDetailsContent');
            reviewDetailsContent.innerHTML = '<p>Loading review details...</p>';
            
            // Simulate loading review details
            setTimeout(function() {
                <% for (Review review : reviews) { %>
                if (reviewId === <%= review.getReviewId() %>) {
                    reviewDetailsContent.innerHTML = `
                        <div class="review-card">
                            <div class="review-card-header">
                                <div class="review-book"><%= review.getBookTitle() %></div>
                                <div class="review-rating">
                                    <%= review.getStarsHtml() %>
                                    <%= String.format("%.1f", review.getRating()) %>
                                </div>
                            </div>
                            
                            <div class="review-user">
                                <img src="../images/default-avatar.png" alt="User Avatar" class="review-user-avatar">
                                <div>
                                    <div class="review-user-name"><%= review.getUserName() %></div>
                                    <div class="review-date">
                                        <%= dateFormat.format(review.getReviewDate()) %> at <%= timeFormat.format(review.getReviewDate()) %>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="review-content">
                                <%= review.getComment() %>
                            </div>
                        </div>
                    `;
                }
                <% } %>
            }, 500);
            
            openModal('viewReviewModal');
        }
        
        // Reply to review
        function replyToReview(reviewId) {
            document.getElementById('reviewId').value = reviewId;
            
            const replyReviewContent = document.getElementById('replyReviewContent');
            replyReviewContent.innerHTML = '<p>Loading review...</p>';
            
            // Simulate loading review
            setTimeout(function() {
                <% for (Review review : reviews) { %>
                if (reviewId === <%= review.getReviewId() %>) {
                    replyReviewContent.innerHTML = `
                        <div class="review-card" style="margin-bottom: 20px;">
                            <div class="review-card-header">
                                <div class="review-book"><%= review.getBookTitle() %></div>
                                <div class="review-rating">
                                    <%= review.getStarsHtml() %>
                                    <%= String.format("%.1f", review.getRating()) %>
                                </div>
                            </div>
                            
                            <div class="review-user">
                                <img src="../images/default-avatar.png" alt="User Avatar" class="review-user-avatar">
                                <div>
                                    <div class="review-user-name"><%= review.getUserName() %></div>
                                </div>
                            </div>
                            
                            <div class="review-content">
                                <%= review.getComment() %>
                            </div>
                        </div>
                    `;
                }
                <% } %>
            }, 500);
            
            openModal('replyReviewModal');
        }
        
        // Submit reply
        document.getElementById('submitReplyBtn').addEventListener('click', function() {
            const replyForm = document.getElementById('replyForm');
            
            // Check if form is valid
            if (replyForm.checkValidity()) {
                // In a real implementation, you would submit the form
                // For now, we'll just show an alert
                alert('Reply submitted successfully!');
                closeModal('replyReviewModal');
            } else {
                replyForm.reportValidity();
            }
        });
    </script>
</body>
</html>
