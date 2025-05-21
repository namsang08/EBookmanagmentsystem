<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Comparator"%>
<%@ page import="java.util.Collections"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="mode.Book"%>
<%@ page import="mode.User"%>
<%@ page import="mode.Review"%>
<%@ page import="mode.Category"%>
<%@ page import="dao.BookDAO"%>
<%@ page import="dao.ReviewDAO"%>
<%@ page import="dao.CategoryDAO"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Reviews - E-Library Hub</title>
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
        
        .filter-container {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
            margin-bottom: 20px;
        }
        
        .filter-row {
            display: flex;
            gap: 15px;
            margin-bottom: 15px;
        }
        
        .filter-group {
            flex: 1;
        }
        
        .filter-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
            font-size: 0.9rem;
        }
        
        .filter-group select, .filter-group input {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
        }
        
        .filter-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        
        .filter-btn {
            padding: 8px 15px;
            border: none;
            border-radius: var(--border-radius);
            cursor: pointer;
            font-size: 0.9rem;
        }
        
        .filter-btn-apply {
            background-color: var(--primary-color);
            color: white;
        }
        
        .filter-btn-reset {
            background-color: var(--secondary-color);
            color: var(--text-color);
        }
        
        .reviews-container {
            display: grid;
            grid-template-columns: 1fr;
            gap: 20px;
        }
        
        .review-card {
            background-color: white;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow);
            overflow: hidden;
            transition: transform 0.3s ease;
        }
        
        .review-card:hover {
            transform: translateY(-5px);
        }
        
        .review-header {
            display: flex;
            padding: 15px;
            border-bottom: 1px solid var(--border-color);
        }
        
        .book-cover {
            width: 80px;
            height: 120px;
            overflow: hidden;
            border-radius: var(--border-radius);
            margin-right: 15px;
        }
        
        .book-cover img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .book-info {
            flex: 1;
        }
        
        .book-title {
            font-weight: 600;
            margin-bottom: 5px;
            font-size: 1.1rem;
        }
        
        .book-author {
            color: var(--text-light);
            font-size: 0.9rem;
            margin-bottom: 10px;
        }
        
        .book-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            font-size: 0.85rem;
            color: var(--text-light);
        }
        
        .book-meta-item {
            display: flex;
            align-items: center;
        }
        
        .book-meta-item i {
            margin-right: 5px;
        }
        
        .review-content {
            padding: 15px;
        }
        
        .review-rating {
            margin-bottom: 10px;
            color: gold;
        }
        
        .review-text {
            margin-bottom: 15px;
            line-height: 1.5;
        }
        
        .review-date {
            font-size: 0.85rem;
            color: var(--text-light);
            text-align: right;
        }
        
        .review-actions {
            display: flex;
            justify-content: flex-end;
            padding: 10px 15px;
            background-color: #f8f9fa;
            border-top: 1px solid var(--border-color);
        }
        
        .review-action-btn {
            padding: 6px 12px;
            border: none;
            border-radius: var(--border-radius);
            cursor: pointer;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            margin-left: 10px;
        }
        
        .review-action-btn i {
            margin-right: 5px;
        }
        
        .btn-edit {
            background-color: var(--primary-color);
            color: white;
        }
        
        .btn-delete {
            background-color: #dc3545;
            color: white;
        }
        
        .empty-state {
            text-align: center;
            padding: 50px 20px;
            background-color: white;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow);
        }
        
        .empty-state i {
            font-size: 3rem;
            color: #ddd;
            margin-bottom: 15px;
        }
        
        .empty-state h3 {
            font-size: 1.2rem;
            margin-bottom: 10px;
        }
        
        .empty-state p {
            color: var(--text-light);
            margin-bottom: 20px;
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            margin-top: 20px;
        }
        
        .pagination-btn {
            padding: 8px 15px;
            border: 1px solid var(--border-color);
            background-color: white;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .pagination-btn:first-child {
            border-radius: var(--border-radius) 0 0 var(--border-radius);
        }
        
        .pagination-btn:last-child {
            border-radius: 0 var(--border-radius) var(--border-radius) 0;
        }
        
        .pagination-btn.active {
            background-color: var(--primary-color);
            color: white;
            border-color: var(--primary-color);
        }
        
        .pagination-btn:hover:not(.active) {
            background-color: var(--secondary-color);
        }
        
        @media (max-width: 992px) {
            .dashboard-container {
                grid-template-columns: 1fr;
            }
            
            .sidebar {
                display: none;
            }
            
            .filter-row {
                flex-direction: column;
                gap: 10px;
            }
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
            background-color: rgba(0, 0, 0, 0.5);
        }
        
        .modal-content {
            background-color: white;
            margin: 10% auto;
            padding: 20px;
            border-radius: var(--border-radius);
            width: 80%;
            max-width: 600px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        }
        
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .modal-title {
            font-size: 1.2rem;
            font-weight: 600;
        }
        
        .modal-close {
            font-size: 1.5rem;
            cursor: pointer;
        }
        
        .modal-body {
            margin-bottom: 20px;
        }
        
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        
        .star-rating {
            display: flex;
            margin-bottom: 15px;
        }
        
        .star-rating input {
            display: none;
        }
        
        .star-rating label {
            cursor: pointer;
            font-size: 1.5rem;
            color: #ddd;
            padding: 0 2px;
        }
        
        .star-rating label:hover,
        .star-rating label:hover ~ label,
        .star-rating input:checked ~ label {
            color: gold;
        }
    </style>
</head>
<body>
    <%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get filter parameters
    String ratingFilter = request.getParameter("rating");
    if (ratingFilter == null) {
        ratingFilter = "all";
    }
    
    String categoryFilter = request.getParameter("category");
    if (categoryFilter == null) {
        categoryFilter = "all";
    }
    
    String sortBy = request.getParameter("sort");
    if (sortBy == null) {
        sortBy = "recent";
    }
    
    String searchQuery = request.getParameter("search");
    if (searchQuery == null) {
        searchQuery = "";
    }
    
    // Initialize DAOs
    ReviewDAO reviewDAO = new ReviewDAO();
    BookDAO bookDAO = new BookDAO();
    CategoryDAO categoryDAO = new CategoryDAO();
    
    // Get categories for filter dropdown
    List<Category> categories = new ArrayList<>();
    try {
        categories = categoryDAO.getAllCategories();
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    // Get user's reviews
    List<Review> allReviews = new ArrayList<>();
    
    try {
        allReviews = reviewDAO.getReviewsByUser(user.getUserId());
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    // Filter reviews
    List<Review> filteredReviews = new ArrayList<>();
    for (Review review : allReviews) {
        Book book = null;
        try {
            book = bookDAO.getBookById(review.getBookId());
        } catch (Exception e) {
            e.printStackTrace();
            continue;
        }
        
        if (book == null) continue;
        
        // Filter by rating
        boolean ratingMatch = ratingFilter.equals("all") || 
                             (ratingFilter.equals("5") && review.getRating() == 5) ||
                             (ratingFilter.equals("4") && review.getRating() == 4) ||
                             (ratingFilter.equals("3") && review.getRating() == 3) ||
                             (ratingFilter.equals("2") && review.getRating() == 2) ||
                             (ratingFilter.equals("1") && review.getRating() == 1);
        
        // Filter by category
        boolean categoryMatch = categoryFilter.equals("all") || 
                               String.valueOf(book.getCategoryId()).equals(categoryFilter);
        
        // Filter by search query
        boolean searchMatch = searchQuery.isEmpty() || 
                             book.getTitle().toLowerCase().contains(searchQuery.toLowerCase()) ||
                             book.getAuthorName().toLowerCase().contains(searchQuery.toLowerCase()) ||
                             review.getComment().toLowerCase().contains(searchQuery.toLowerCase());
        
        if (ratingMatch && categoryMatch && searchMatch) {
            filteredReviews.add(review);
        }
    }
    
    // Sort reviews
    if (sortBy.equals("recent")) {
        Collections.sort(filteredReviews, new Comparator<Review>() {
            public int compare(Review r1, Review r2) {
                return r2.getReviewDate().compareTo(r1.getReviewDate());
            }
        });
    } else if (sortBy.equals("rating_high")) {
        Collections.sort(filteredReviews, new Comparator<Review>() {
            public int compare(Review r1, Review r2) {
                if (r2.getRating() > r1.getRating()) return 1;
                if (r2.getRating() < r1.getRating()) return -1;
                return 0;
            }
        });
    } else if (sortBy.equals("rating_low")) {
        Collections.sort(filteredReviews, new Comparator<Review>() {
            public int compare(Review r1, Review r2) {
                if (r1.getRating() > r2.getRating()) return 1;
                if (r1.getRating() < r2.getRating()) return -1;
                return 0;
            }
        });
    } else if (sortBy.equals("book_title")) {
        Collections.sort(filteredReviews, new Comparator<Review>() {
            public int compare(Review r1, Review r2) {
                try {
                    Book b1 = bookDAO.getBookById(r1.getBookId());
                    Book b2 = bookDAO.getBookById(r2.getBookId());
                    if (b1 != null && b2 != null) {
                        return b1.getTitle().compareTo(b2.getTitle());
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                return 0;
            }
        });
    } else if (sortBy.equals("category")) {
        Collections.sort(filteredReviews, new Comparator<Review>() {
            public int compare(Review r1, Review r2) {
                try {
                    Book b1 = bookDAO.getBookById(r1.getBookId());
                    Book b2 = bookDAO.getBookById(r2.getBookId());
                    if (b1 != null && b2 != null) {
                        return b1.getCategoryName().compareTo(b2.getCategoryName());
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                return 0;
            }
        });
    }
    
    // Pagination
    int currentPage = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        try {
            currentPage = Integer.parseInt(pageParam);
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
    }
    
    int reviewsPerPage = 5;
    int totalReviews = filteredReviews.size();
    int totalPages = (int) Math.ceil((double) totalReviews / reviewsPerPage);
    
    if (currentPage < 1) {
        currentPage = 1;
    } else if (currentPage > totalPages) {
        currentPage = totalPages;
    }
    
    int startIndex = (currentPage - 1) * reviewsPerPage;
    int endIndex = Math.min(startIndex + reviewsPerPage, totalReviews);
    
    List<Review> paginatedReviews = new ArrayList<>();
    if (startIndex < totalReviews) {
        paginatedReviews = filteredReviews.subList(startIndex, endIndex);
    }
    
    // Date formatter
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
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
                <h2>User Dashboard</h2>
                <p>Welcome, <%= user.getFirstName() %></p>
            </div>
            <ul class="sidebar-menu">
                <li><a href="dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="my-books.jsp"><i class="fas fa-book"></i> My Books</a></li>
                <li><a href="reading-list.jsp"><i class="fas fa-list"></i> Reading List</a></li>
                <li><a href="bookmarks.jsp"><i class="fas fa-bookmark"></i> Bookmarks</a></li>
                <li><a href="history.jsp"><i class="fas fa-history"></i> History</a></li>
                <li><a href="my-reviews.jsp" class="active"><i class="fas fa-star"></i> My Reviews</a></li>
                <li><a href="profile.jsp"><i class="fas fa-user"></i> Profile</a></li>
                <li><a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>
        
        <main class="main-content">
            <div class="dashboard-header">
                <h1 class="dashboard-title">My Reviews</h1>
            </div>
            
            <div class="filter-container">
                <form action="my-reviews.jsp" method="get" id="filterForm">
                    <div class="filter-row">
                        <div class="filter-group">
                            <label for="rating">Rating</label>
                            <select id="rating" name="rating" class="form-control">
                                <option value="all" <%= ratingFilter.equals("all") ? "selected" : "" %>>All Ratings</option>
                                <option value="5" <%= ratingFilter.equals("5") ? "selected" : "" %>>5 Stars</option>
                                <option value="4" <%= ratingFilter.equals("4") ? "selected" : "" %>>4 Stars</option>
                                <option value="3" <%= ratingFilter.equals("3") ? "selected" : "" %>>3 Stars</option>
                                <option value="2" <%= ratingFilter.equals("2") ? "selected" : "" %>>2 Stars</option>
                                <option value="1" <%= ratingFilter.equals("1") ? "selected" : "" %>>1 Star</option>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label for="category">Category</label>
                            <select id="category" name="category" class="form-control">
                                <option value="all" <%= categoryFilter.equals("all") ? "selected" : "" %>>All Categories</option>
                                <% for (Category category : categories) { %>
                                <option value="<%= category.getCategoryId() %>" <%= categoryFilter.equals(String.valueOf(category.getCategoryId())) ? "selected" : "" %>>
                                    <%= category.getName() %>
                                </option>
                                <% } %>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label for="sort">Sort By</label>
                            <select id="sort" name="sort" class="form-control">
                                <option value="recent" <%= sortBy.equals("recent") ? "selected" : "" %>>Most Recent</option>
                                <option value="rating_high" <%= sortBy.equals("rating_high") ? "selected" : "" %>>Highest Rating</option>
                                <option value="rating_low" <%= sortBy.equals("rating_low") ? "selected" : "" %>>Lowest Rating</option>
                                <option value="book_title" <%= sortBy.equals("book_title") ? "selected" : "" %>>Book Title</option>
                                <option value="category" <%= sortBy.equals("category") ? "selected" : "" %>>Category</option>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label for="search">Search</label>
                            <input type="text" id="search" name="search" class="form-control" placeholder="Search by title, author, or review content" value="<%= searchQuery %>">
                        </div>
                    </div>
                    
                    <div class="filter-actions">
                        <button type="button" class="filter-btn filter-btn-reset" onclick="resetFilters()">Reset</button>
                        <button type="submit" class="filter-btn filter-btn-apply">Apply Filters</button>
                    </div>
                </form>
            </div>
            
            <% if (paginatedReviews.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-star"></i>
                <h3>No reviews found</h3>
                <% if (!searchQuery.isEmpty() || !ratingFilter.equals("all") || !categoryFilter.equals("all")) { %>
                    <p>No reviews match your search criteria. Try different filters.</p>
                <% } else { %>
                    <p>You haven't written any reviews yet. Start reading books and share your thoughts!</p>
                <% } %>
                <a href="../browsebook.jsp" class="btn-primary">Browse Books</a>
            </div>
            <% } else { %>
            <div class="reviews-container">
                <% for (Review review : paginatedReviews) {
                    Book book = null;
                    try {
                        book = bookDAO.getBookById(review.getBookId());
                    } catch (Exception e) {
                        e.printStackTrace();
                        continue;
                    }
                    
                    if (book == null) continue;
                    
                    // Get category name
                    String categoryName = book.getCategoryName();
                    if (categoryName == null || categoryName.isEmpty()) {
                        try {
                            Category category = categoryDAO.getCategoryById(book.getCategoryId());
                            if (category != null) {
                                categoryName = category.getName();
                            } else {
                                categoryName = "Uncategorized";
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                            categoryName = "Uncategorized";
                        }
                    }
                %>
                <div class="review-card">
                    <div class="review-header">
                        <div class="book-cover">
                            <img src="../<%= book.getCoverImagePath() %>" alt="<%= book.getTitle() %>">
                        </div>
                        <div class="book-info">
                            <h3 class="book-title"><%= book.getTitle() %></h3>
                            <p class="book-author">by <%= book.getAuthorName() %></p>
                            <div class="book-meta">
                                <div class="book-meta-item">
                                    <i class="fas fa-calendar-alt"></i>
                                    <span>Reviewed on <%= dateFormat.format(review.getReviewDate()) %></span>
                                </div>
                                <div class="book-meta-item">
                                    <i class="fas fa-folder"></i>
                                    <span><%= categoryName %></span>
                                </div>
                                <div class="book-meta-item">
                                    <i class="fas fa-book-reader"></i>
                                    <span>
                                        <%
                                        int progress = bookDAO.getReadingProgress(user.getUserId(), book.getBookId());
                                        int readPages = Math.round(book.getPages() * (progress / 100.0f));
                                        %>
                                        Page <%= readPages %> of <%= book.getPages() %>
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="review-content">
                        <div class="review-rating">
                            <% for (int i = 1; i <= 5; i++) { %>
                                <% if (i <= review.getRating()) { %>
                                    <i class="fas fa-star"></i>
                                <% } else { %>
                                    <i class="far fa-star"></i>
                                <% } %>
                            <% } %>
                        </div>
                        <div class="review-text">
                            <%= review.getComment() %>
                        </div>
                    </div>
                    <div class="review-actions">
                        <button class="review-action-btn btn-edit" onclick="openEditModal(<%= review.getReviewId() %>, <%= review.getRating() %>, '<%= review.getComment().replace("'", "\\'").replace("\n", "\\n") %>', <%= review.getBookId() %>)">
                            <i class="fas fa-edit"></i> Edit
                        </button>
                        <button class="review-action-btn btn-delete" onclick="confirmDeleteReview(<%= review.getReviewId() %>)">
                            <i class="fas fa-trash-alt"></i> Delete
                        </button>
                    </div>
                </div>
                <% } %>
            </div>
            
            <% if (totalPages > 1) { %>
            <div class="pagination">
                <% if (currentPage > 1) { %>
                <button class="pagination-btn" onclick="goToPage(<%= currentPage - 1 %>)">
                    <i class="fas fa-chevron-left"></i>
                </button>
                <% } %>
                
                <% 
                int startPage = Math.max(1, currentPage - 2);
                int endPage = Math.min(totalPages, startPage + 4);
                
                if (endPage - startPage < 4 && startPage > 1) {
                    startPage = Math.max(1, endPage - 4);
                }
                
                for (int i = startPage; i <= endPage; i++) { 
                %>
                <button class="pagination-btn <%= i == currentPage ? "active" : "" %>" onclick="goToPage(<%= i %>)">
                    <%= i %>
                </button>
                <% } %>
                
                <% if (currentPage < totalPages) { %>
                <button class="pagination-btn" onclick="goToPage(<%= currentPage + 1 %>)">
                    <i class="fas fa-chevron-right"></i>
                </button>
                <% } %>
            </div>
            <% } %>
            <% } %>
        </main>
    </div>
    
    <!-- Edit Review Modal -->
    <div id="editReviewModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title">Edit Review</h2>
                <span class="modal-close" onclick="closeEditModal()">&times;</span>
            </div>
            <div class="modal-body">
                <form id="editReviewForm" action="../ReviewServlet" method="post">
                    <input type="hidden" name="action" value="updateReview">
                    <input type="hidden" id="editReviewId" name="reviewId">
                    <input type="hidden" id="editBookId" name="bookId">
                    
                    <div class="form-group">
                        <label>Rating</label>
                        <div class="star-rating">
                            <input type="radio" id="star5" name="rating" value="5">
                            <label for="star5"><i class="fas fa-star"></i></label>
                            <input type="radio" id="star4" name="rating" value="4">
                            <label for="star4"><i class="fas fa-star"></i></label>
                            <input type="radio" id="star3" name="rating" value="3">
                            <label for="star3"><i class="fas fa-star"></i></label>
                            <input type="radio" id="star2" name="rating" value="2">
                            <label for="star2"><i class="fas fa-star"></i></label>
                            <input type="radio" id="star1" name="rating" value="1">
                            <label for="star1"><i class="fas fa-star"></i></label>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="editComment">Review</label>
                        <textarea id="editComment" name="comment" rows="5" class="form-control" required></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="filter-btn filter-btn-reset" onclick="closeEditModal()">Cancel</button>
                <button type="button" class="filter-btn filter-btn-apply" onclick="submitEditForm()">Save Changes</button>
            </div>
        </div>
    </div>

    <script>
        // Mobile menu toggle
        document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
            document.querySelector('.main-nav').classList.toggle('active');
        });
        
        // Reset filters
        function resetFilters() {
            document.getElementById('rating').value = 'all';
            document.getElementById('category').value = 'all';
            document.getElementById('sort').value = 'recent';
            document.getElementById('search').value = '';
            document.getElementById('filterForm').submit();
        }
        
        // Pagination
        function goToPage(page) {
            const urlParams = new URLSearchParams(window.location.search);
            urlParams.set('page', page);
            window.location.search = urlParams.toString();
        }
        
        // Edit review modal
        function openEditModal(reviewId, rating, comment, bookId) {
            document.getElementById('editReviewId').value = reviewId;
            document.getElementById('editBookId').value = bookId;
            document.getElementById('editComment').value = comment;
            
            // Set rating
            document.getElementById('star' + rating).checked = true;
            
            document.getElementById('editReviewModal').style.display = 'block';
        }
        
        function closeEditModal() {
            document.getElementById('editReviewModal').style.display = 'none';
        }
        
        function submitEditForm() {
            document.getElementById('editReviewForm').submit();
        }
        
        // Delete review
        function confirmDeleteReview(reviewId) {
            if (confirm('Are you sure you want to delete this review? This action cannot be undone.')) {
                window.location.href = '../ReviewServlet?action=deleteReview&reviewId=' + reviewId;
            }
        }
        
        // Close modal when clicking outside
        window.onclick = function(event) {
            const modal = document.getElementById('editReviewModal');
            if (event.target == modal) {
                closeEditModal();
            }
        }
    </script>
</body>
</html>
