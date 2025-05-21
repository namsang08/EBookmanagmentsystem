<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="mode.Book"%>
<%@ page import="mode.User"%>
<%@ page import="mode.Review"%>
<%@ page import="dao.BookDAO"%>
<%@ page import="dao.ReviewDAO"%>
<%@ page import="dao.UserHistoryDAO"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Dashboard - E-Library Hub</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #4a6da7;
            --secondary-color: #f0f2f5;
            --accent-color: #3a5f8a;
            --text-color: #333;
            --text-light: #6c757d;
            --border-color: #e9ecef;
            --border-radius: 8px;
            --shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            --transition: all 0.3s ease;
        }
        
        .dashboard-container {
            display: grid;
            grid-template-columns: 250px 1fr;
            min-height: calc(100vh - 60px);
        }
        
        .sidebar {
            background-color: #2c3e50;
            color: white;
            padding: 20px 0;
            position: sticky;
            top: 60px;
            height: calc(100vh - 60px);
            overflow-y: auto;
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
            padding: 0;
            margin: 0;
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
            text-decoration: none;
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
            overflow-y: auto;
        }
        
        .dashboard-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            background-color: white;
            padding: 15px 20px;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow);
        }
        
        .dashboard-title {
            font-size: 1.5rem;
            margin: 0;
            color: var(--text-color);
        }
        
        .date {
            color: var(--text-light);
            display: flex;
            align-items: center;
        }
        
        .date i {
            margin-right: 5px;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: transform 0.3s ease;
            text-decoration: none;
            color: var(--text-color);
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
        }
        
        .stat-card-content {
            flex: 1;
        }
        
        .stat-card-value {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 5px;
            color: var(--text-color);
        }
        
        .stat-card-label {
            color: var(--text-light);
            font-size: 0.9rem;
        }
        
        .stat-card-icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }
        
        .stat-card-icon.reading {
            background-color: rgba(74, 109, 167, 0.1);
            color: var(--primary-color);
        }
        
        .stat-card-icon.to-read {
            background-color: rgba(40, 167, 69, 0.1);
            color: #28a745;
        }
        
        .stat-card-icon.finished {
            background-color: rgba(255, 193, 7, 0.1);
            color: #ffc107;
        }
        
        .stat-card-icon.bookmarked {
            background-color: rgba(220, 53, 69, 0.1);
            color: #dc3545;
        }
        
        .section {
            margin-bottom: 30px;
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
        }
        
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border-color);
        }
        
        .section-title {
            font-size: 1.2rem;
            font-weight: 600;
            margin: 0;
            color: var(--text-color);
        }
        
        .browse-more {
            color: var(--primary-color);
            font-size: 0.9rem;
            text-decoration: none;
            display: flex;
            align-items: center;
        }
        
        .browse-more:hover {
            text-decoration: underline;
        }
        
        .browse-more i {
            margin-left: 5px;
        }
        
        .books-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 20px;
        }
        
        .book-card {
            background-color: white;
            border-radius: var(--border-radius);
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
            overflow: hidden;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            height: 100%;
            display: flex;
            flex-direction: column;
            border: 1px solid var(--border-color);
        }
        
        .book-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }
        
        .book-cover {
            height: 200px;
            overflow: hidden;
            position: relative;
        }
        
        .book-cover img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.3s ease;
        }
        
        .book-card:hover .book-cover img {
            transform: scale(1.05);
        }
        
        .book-cover .book-progress {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 5px;
            background-color: rgba(0, 0, 0, 0.2);
        }
        
        .book-cover .book-progress-bar {
            height: 100%;
            background-color: var(--primary-color);
        }
        
        .book-info {
            padding: 15px;
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        .book-title {
            font-weight: 600;
            margin-bottom: 5px;
            font-size: 1rem;
            color: var(--text-color);
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            text-overflow: ellipsis;
            height: 2.4rem;
        }
        
        .book-author {
            color: var(--text-light);
            font-size: 0.9rem;
            margin-bottom: 10px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        
        .book-rating {
            margin-bottom: 10px;
            color: #ffc107;
            display: flex;
            align-items: center;
        }
        
        .book-rating span {
            margin-left: 5px;
            font-size: 0.85rem;
        }
        
        .book-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 5px;
            margin-bottom: 15px;
        }
        
        .book-tag {
            background-color: var(--secondary-color);
            color: var(--text-color);
            font-size: 0.8rem;
            padding: 3px 8px;
            border-radius: 20px;
        }
        
        .book-actions {
            margin-top: auto;
            display: flex;
            flex-direction: column;
            gap: 5px;
        }
        
        .btn-continue-reading {
            width: 100%;
            padding: 8px;
            background-color: var(--primary-color);
            color: white;
            border: none;
            border-radius: var(--border-radius);
            cursor: pointer;
            transition: background-color 0.3s ease;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .btn-continue-reading i {
            margin-right: 5px;
        }
        
        .btn-continue-reading:hover {
            background-color: var(--accent-color);
        }
        
        .btn-view-details {
            width: 100%;
            padding: 8px;
            background-color: var(--secondary-color);
            color: var(--text-color);
            border: none;
            border-radius: var(--border-radius);
            cursor: pointer;
            transition: background-color 0.3s ease;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .btn-view-details i {
            margin-right: 5px;
        }
        
        .btn-view-details:hover {
            background-color: #e2e6ea;
        }
        
        .activity-section {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
            margin-bottom: 30px;
        }
        
        .activity-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        
        .activity-item {
            padding: 15px;
            border-bottom: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            transition: background-color 0.3s ease;
        }
        
        .activity-item:last-child {
            border-bottom: none;
        }
        
        .activity-item:hover {
            background-color: var(--secondary-color);
        }
        
        .activity-icon {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 15px;
            flex-shrink: 0;
        }
        
        .activity-icon.download {
            background-color: rgba(74, 109, 167, 0.1);
            color: var(--primary-color);
        }
        
        .activity-icon.read {
            background-color: rgba(40, 167, 69, 0.1);
            color: #28a745;
        }
        
        .activity-icon.bookmark {
            background-color: rgba(220, 53, 69, 0.1);
            color: #dc3545;
        }
        
        .activity-icon.review {
            background-color: rgba(255, 193, 7, 0.1);
            color: #ffc107;
        }
        
        .activity-content {
            flex: 1;
        }
        
        .activity-text {
            margin-bottom: 5px;
            color: var(--text-color);
        }
        
        .activity-text strong {
            font-weight: 600;
        }
        
        .activity-time {
            font-size: 0.8rem;
            color: var(--text-light);
        }
        
        .activity-category {
            font-size: 0.8rem;
            padding: 3px 8px;
            border-radius: 20px;
            background-color: var(--secondary-color);
            margin-left: auto;
            flex-shrink: 0;
            color: var(--text-color);
        }
        
        .activity-actions {
            margin-left: 10px;
        }
        
        .activity-actions a {
            color: var(--primary-color);
            text-decoration: none;
            font-size: 0.9rem;
            padding: 5px 10px;
            border-radius: var(--border-radius);
            background-color: var(--secondary-color);
            transition: background-color 0.3s ease;
        }
        
        .activity-actions a:hover {
            background-color: #e2e6ea;
        }
        
        .empty-state {
            text-align: center;
            padding: 30px;
            color: var(--text-light);
        }
        
        .empty-state i {
            font-size: 3rem;
            color: #ddd;
            margin-bottom: 15px;
        }
        
        .empty-state p {
            margin-bottom: 15px;
        }
        
        .empty-state .btn-primary {
            display: inline-block;
            padding: 8px 16px;
            background-color: var(--primary-color);
            color: white;
            border-radius: var(--border-radius);
            text-decoration: none;
            transition: background-color 0.3s ease;
        }
        
        .empty-state .btn-primary:hover {
            background-color: var(--accent-color);
        }
        
        .progress-indicator {
            display: flex;
            align-items: center;
            margin-top: 10px;
            font-size: 0.8rem;
            color: var(--text-light);
        }
        
        .progress-bar {
            flex: 1;
            height: 5px;
            background-color: var(--secondary-color);
            border-radius: 5px;
            overflow: hidden;
            margin: 0 10px;
        }
        
        .progress-bar-fill {
            height: 100%;
            background-color: var(--primary-color);
        }
        
        .book-bookmark {
            position: absolute;
            top: 10px;
            right: 10px;
            background-color: rgba(255, 255, 255, 0.8);
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s ease;
            z-index: 1;
        }
        
        .book-bookmark:hover {
            transform: scale(1.1);
        }
        
        .book-bookmark i {
            color: #dc3545;
        }
        
        .toast {
            position: fixed;
            bottom: 20px;
            right: 20px;
            background-color: rgba(40, 167, 69, 0.9);
            color: white;
            padding: 10px 20px;
            border-radius: var(--border-radius);
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
            z-index: 1000;
            opacity: 0;
            transition: opacity 0.3s ease;
        }
        
        .toast.show {
            opacity: 1;
        }
        
        .toast.error {
            background-color: rgba(220, 53, 69, 0.9);
        }
        
        @media (max-width: 992px) {
            .dashboard-container {
                grid-template-columns: 1fr;
            }
            
            .sidebar {
                display: none;
                position: fixed;
                top: 60px;
                left: 0;
                right: 0;
                bottom: 0;
                z-index: 100;
            }
            
            .sidebar.active {
                display: block;
            }
            
            .mobile-sidebar-toggle {
                display: block;
                position: fixed;
                bottom: 20px;
                right: 20px;
                width: 50px;
                height: 50px;
                border-radius: 50%;
                background-color: var(--primary-color);
                color: white;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 1.5rem;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
                z-index: 101;
                cursor: pointer;
            }
            
            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .books-grid {
                grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
            }
        }
        
        @media (max-width: 576px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }
            
            .dashboard-header {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .date {
                margin-top: 10px;
            }
            
            .activity-item {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .activity-icon {
                margin-bottom: 10px;
            }
            
            .activity-category {
                margin-left: 0;
                margin-top: 10px;
            }
            
            .activity-actions {
                margin-left: 0;
                margin-top: 10px;
                width: 100%;
            }
            
            .activity-actions a {
                display: block;
                text-align: center;
            }
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
    
    // Initialize DAOs
    BookDAO bookDAO = new BookDAO();
    ReviewDAO reviewDAO = new ReviewDAO();
    UserHistoryDAO userHistoryDAO = new UserHistoryDAO();
    
    // Get user's reading statistics
    int currentlyReading = 0;
    int toRead = 0;
    int finished = 0;
    int bookmarked = 0;
    
    try {
        Map<String, Integer> stats = bookDAO.getUserReadingStats(user.getUserId());
        currentlyReading = stats.getOrDefault("currentlyReading", 0);
        toRead = stats.getOrDefault("toRead", 0);
        finished = stats.getOrDefault("finished", 0);
        bookmarked = stats.getOrDefault("bookmarked", 0);
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    // Get currently reading books
    List<Book> currentlyReadingBooks = new ArrayList<>();
    try {
        currentlyReadingBooks = bookDAO.getCurrentlyReadingBooks(user.getUserId());
        // Limit to 4 books for display
        if (currentlyReadingBooks.size() > 4) {
            currentlyReadingBooks = currentlyReadingBooks.subList(0, 4);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    // Get recommended books
    List<Book> recommendedBooks = new ArrayList<>();
    try {
        recommendedBooks = bookDAO.getRecommendedBooks(user.getUserId(), 4);
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    // Get recent activity
    List<Map<String, Object>> recentActivity = new ArrayList<>();
    try {
        recentActivity = bookDAO.getUserRecentActivity(user.getUserId(), 5);
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    // Format date
    SimpleDateFormat dateFormat = new SimpleDateFormat("EEEE, MMMM d, yyyy");
    String currentDate = dateFormat.format(new Date());
    
    // Function to get time ago
    java.util.function.Function<Date, String> getTimeAgo = (date) -> {
        if (date == null) return "Unknown time";
        
        long diff = new Date().getTime() - date.getTime();
        long seconds = diff / 1000;
        long minutes = seconds / 60;
        long hours = minutes / 60;
        long days = hours / 24;
        
        if (days > 0) {
            return days + (days == 1 ? " day" : " days") + " ago";
        } else if (hours > 0) {
            return hours + (hours == 1 ? " hour" : " hours") + " ago";
        } else if (minutes > 0) {
            return minutes + (minutes == 1 ? " minute" : " minutes") + " ago";
        } else {
            return "Just now";
        }
    };
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
                <li><a href="dashboard.jsp" class="active"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="my-books.jsp"><i class="fas fa-book"></i> My Books</a></li>
                <li><a href="reading-list.jsp"><i class="fas fa-list"></i> Reading List</a></li>
                <li><a href="bookmarks.jsp"><i class="fas fa-bookmark"></i> Bookmarks</a></li>
                <li><a href="history.jsp"><i class="fas fa-history"></i> History</a></li>
                <li><a href="my-reviews.jsp"><i class="fas fa-star"></i> My Reviews</a></li>
                <li><a href="profile.jsp"><i class="fas fa-user"></i> Profile</a></li>
                <li><a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>
        
        <main class="main-content">
            <div class="dashboard-header">
                <h1 class="dashboard-title">My Dashboard</h1>
                <div class="date">
                    <i class="far fa-calendar-alt"></i> <%= currentDate %>
                </div>
            </div>
            
            <div class="stats-grid">
                <a href="my-books.jsp?filter=reading" class="stat-card">
                    <div class="stat-card-content">
                        <div class="stat-card-value"><%= currentlyReading %></div>
                        <div class="stat-card-label">Currently Reading</div>
                    </div>
                    <div class="stat-card-icon reading">
                        <i class="fas fa-book-reader"></i>
                    </div>
                </a>
                
                <a href="reading-list.jsp" class="stat-card">
                    <div class="stat-card-content">
                        <div class="stat-card-value"><%= toRead %></div>
                        <div class="stat-card-label">To Read</div>
                    </div>
                    <div class="stat-card-icon to-read">
                        <i class="fas fa-list"></i>
                    </div>
                </a>
                
                <a href="my-books.jsp?filter=finished" class="stat-card">
                    <div class="stat-card-content">
                        <div class="stat-card-value"><%= finished %></div>
                        <div class="stat-card-label">Finished</div>
                    </div>
                    <div class="stat-card-icon finished">
                        <i class="fas fa-check-circle"></i>
                    </div>
                </a>
                
                <a href="bookmarks.jsp" class="stat-card">
                    <div class="stat-card-content">
                        <div class="stat-card-value"><%= bookmarked %></div>
                        <div class="stat-card-label">Bookmarked</div>
                    </div>
                    <div class="stat-card-icon bookmarked">
                        <i class="fas fa-bookmark"></i>
                    </div>
                </a>
            </div>
            
            <div class="section">
                <div class="section-header">
                    <h2 class="section-title">Currently Reading</h2>
                    <a href="my-books.jsp?filter=reading" class="browse-more">View All <i class="fas fa-chevron-right"></i></a>
                </div>
                
                <div class="books-grid">
                    <% if (currentlyReadingBooks.isEmpty()) { %>
                    <div class="empty-state" style="grid-column: 1 / -1;">
                        <i class="fas fa-book"></i>
                        <p>You're not reading any books right now.</p>
                        <a href="../browsebook.jsp" class="btn-primary">Browse Books</a>
                    </div>
                    <% } else { %>
                        <% for (Book book : currentlyReadingBooks) { 
                            int progress = book.getReadingProgress();
                        %>
                        <div class="book-card">
                            <div class="book-cover">
                                <img src="../<%= book.getCoverImagePath() %>" alt="<%= book.getTitle() %>">
                                <div class="book-progress">
                                    <div class="book-progress-bar" style="width: <%= progress %>%;"></div>
                                </div>
                                <div class="book-bookmark" onclick="toggleBookmark(<%= book.getBookId() %>, this)">
                                    <% if (bookDAO.isBookmarked(user.getUserId(), book.getBookId())) { %>
                                        <i class="fas fa-bookmark"></i>
                                    <% } else { %>
                                        <i class="far fa-bookmark"></i>
                                    <% } %>
                                </div>
                            </div>
                            <div class="book-info">
                                <h3 class="book-title"><%= book.getTitle() %></h3>
                                <p class="book-author">by <%= book.getAuthorName() %></p>
                                <div class="book-rating">
                                    <% 
                                    double rating = book.getRating();
                                    for (int i = 1; i <= 5; i++) {
                                        if (i <= Math.floor(rating)) {
                                    %>
                                        <i class="fas fa-star"></i>
                                    <% } else if (i == Math.ceil(rating) && rating % 1 != 0) { %>
                                        <i class="fas fa-star-half-alt"></i>
                                    <% } else { %>
                                        <i class="far fa-star"></i>
                                    <% } } %>
                                    <span><%= String.format("%.1f", rating) %></span>
                                </div>
                                <div class="book-tags">
                                    <span class="book-tag"><%= book.getCategoryName() %></span>
                                    <% 
                                    if (book.getTags() != null && !book.getTags().isEmpty()) {
                                        String[] tags = book.getTags().split(",");
                                        for (int i = 0; i < Math.min(2, tags.length); i++) {
                                    %>
                                        <span class="book-tag"><%= tags[i].trim() %></span>
                                    <% } } %>
                                </div>
                                <div class="progress-indicator">
                                    <span><%= progress %>%</span>
                                    <div class="progress-bar">
                                        <div class="progress-bar-fill" style="width: <%= progress %>%;"></div>
                                    </div>
                                    <span>Page <%= Math.round(book.getPages() * (book.getReadingProgress() / 100.0)) %>/<%= book.getPages() %></span>
                                </div>
                                <div class="book-actions">
                                    <button class="btn-continue-reading" onclick="continueReading(<%= book.getBookId() %>)">
                                        <i class="fas fa-book-open"></i> Continue Reading
                                    </button>
                                    <button class="btn-view-details" onclick="location.href='../bookdetails.jsp?id=<%= book.getBookId() %>'">
                                        <i class="fas fa-info-circle"></i> View Details
                                    </button>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
