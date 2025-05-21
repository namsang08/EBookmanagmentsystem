<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="mode.Book"%>
<%@ page import="mode.User"%>
<%@ page import="dao.BookDAO"%>
<%@ page import="dao.UserHistoryDAO"%>
<%@ page import="java.text.SimpleDateFormat"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reading History - E-Library Hub</title>
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
        
        .history-list {
            background-color: white;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow);
            overflow: hidden;
        }
        
        .history-list-header {
            display: grid;
            grid-template-columns: 80px 3fr 2fr 1fr 1fr 120px;
            padding: 15px;
            background-color: #f8f9fa;
            border-bottom: 1px solid var(--border-color);
            font-weight: 600;
        }
        
        .history-item {
            display: grid;
            grid-template-columns: 80px 3fr 2fr 1fr 1fr 120px;
            padding: 15px;
            border-bottom: 1px solid var(--border-color);
            align-items: center;
        }
        
        .history-item:last-child {
            border-bottom: none;
        }
        
        .history-item:hover {
            background-color: #f8f9fa;
        }
        
        .book-cover {
            width: 60px;
            height: 80px;
            object-fit: cover;
            border-radius: 4px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }
        
        .book-info {
            padding-right: 15px;
        }
        
        .book-title {
            font-weight: 600;
            margin-bottom: 5px;
            font-size: 1rem;
        }
        
        .book-author {
            color: var(--text-light);
            font-size: 0.9rem;
        }
        
        .action-type {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
            text-align: center;
        }
        
        .action-view {
            background-color: rgba(74, 109, 167, 0.1);
            color: var(--primary-color);
        }
        
        .action-download {
            background-color: rgba(40, 167, 69, 0.1);
            color: #28a745;
        }
        
        .action-bookmark {
            background-color: rgba(220, 53, 69, 0.1);
            color: #dc3545;
        }
        
        .action-review {
            background-color: rgba(255, 193, 7, 0.1);
            color: #ffc107;
        }
        
        .timestamp {
            color: var(--text-light);
            font-size: 0.9rem;
        }
        
        .item-actions {
            display: flex;
            gap: 5px;
        }
        
        .item-action-btn {
            width: 30px;
            height: 30px;
            border: none;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .btn-view {
            background-color: var(--primary-color);
            color: white;
        }
        
        .btn-view:hover {
            background-color: #3a5f8a;
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
            
            .history-list-header {
                display: none;
            }
            
            .history-item {
                grid-template-columns: 80px 1fr;
                grid-template-rows: auto auto auto;
                gap: 10px;
                padding: 15px;
            }
            
            .book-cover {
                grid-row: span 3;
            }
            
            .book-info {
                grid-column: 2;
                grid-row: 1;
            }
            
            .action-type {
                grid-column: 2;
                grid-row: 2;
                justify-self: start;
            }
            
            .timestamp {
                grid-column: 2;
                grid-row: 2;
                justify-self: end;
            }
            
            .item-actions {
                grid-column: 2;
                grid-row: 3;
                justify-content: flex-end;
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
    
    // Get filter parameters
    String actionFilter = request.getParameter("action");
    if (actionFilter == null) {
        actionFilter = "all";
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
    BookDAO bookDAO = new BookDAO();
    UserHistoryDAO userHistoryDAO = new UserHistoryDAO();
    
    // Get user's history
    List<Map<String, Object>> userHistory = new ArrayList<>();
    try {
        userHistory = bookDAO.getUserRecentActivity(user.getUserId(), 100); // Get up to 100 recent activities
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    // Filter history based on action type and search query
    List<Map<String, Object>> filteredHistory = new ArrayList<>();
    for (Map<String, Object> activity : userHistory) {
        String activityType = (String) activity.get("activityType");
        String bookTitle = (String) activity.get("bookTitle");
        
        // Apply action filter
        if (actionFilter.equals("all") || 
            (actionFilter.equals("view") && activityType.equals("VIEW")) ||
            (actionFilter.equals("download") && activityType.equals("DOWNLOAD")) ||
            (actionFilter.equals("bookmark") && (activityType.equals("BOOKMARK_ADDED") || activityType.equals("BOOKMARK_REMOVED"))) ||
            (actionFilter.equals("reading") && (activityType.equals("STARTED_READING") || activityType.equals("FINISHED_READING")))) {
            
            // Apply search filter
            if (searchQuery.isEmpty() || bookTitle.toLowerCase().contains(searchQuery.toLowerCase())) {
                filteredHistory.add(activity);
            }
        }
    }
    
    // Format date
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm");
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
                <li><a href="history.jsp" class="active"><i class="fas fa-history"></i> History</a></li>
                <li><a href="my-reviews.jsp"><i class="fas fa-star"></i> My Reviews</a></li>
                <li><a href="profile.jsp"><i class="fas fa-user"></i> Profile</a></li>
                <li><a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>
        
        <main class="main-content">
            <div class="dashboard-header">
                <h1 class="dashboard-title">Reading History</h1>
            </div>
            
            <div class="filter-container">
                <form action="history.jsp" method="get" id="filterForm">
                    <div class="filter-row">
                        <div class="filter-group">
                            <label for="action">Action Type</label>
                            <select id="action" name="action" class="form-control">
                                <option value="all" <%= actionFilter.equals("all") ? "selected" : "" %>>All Actions</option>
                                <option value="view" <%= actionFilter.equals("view") ? "selected" : "" %>>Views</option>
                                <option value="download" <%= actionFilter.equals("download") ? "selected" : "" %>>Downloads</option>
                                <option value="bookmark" <%= actionFilter.equals("bookmark") ? "selected" : "" %>>Bookmarks</option>
                                <option value="reading" <%= actionFilter.equals("reading") ? "selected" : "" %>>Reading</option>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label for="sort">Sort By</label>
                            <select id="sort" name="sort" class="form-control">
                                <option value="recent" <%= sortBy.equals("recent") ? "selected" : "" %>>Most Recent</option>
                                <option value="oldest" <%= sortBy.equals("oldest") ? "selected" : "" %>>Oldest First</option>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label for="search">Search</label>
                            <input type="text" id="search" name="search" class="form-control" placeholder="Search by book title" value="<%= searchQuery %>">
                        </div>
                    </div>
                    
                    <div class="filter-actions">
                        <button type="button" class="filter-btn filter-btn-reset" onclick="resetFilters()">Reset</button>
                        <button type="submit" class="filter-btn filter-btn-apply">Apply Filters</button>
                    </div>
                </form>
            </div>
            
            <% if (filteredHistory.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-history"></i>
                <h3>No history found</h3>
                <% if (!searchQuery.isEmpty() || !actionFilter.equals("all")) { %>
                    <p>No history matches your search criteria. Try different filters.</p>
                <% } else { %>
                    <p>Your reading history will appear here as you interact with books.</p>
                <% } %>
                <a href="../browsebook.jsp" class="btn-primary">Browse Books</a>
            </div>
            <% } else { %>
            <div class="history-list">
                <div class="history-list-header">
                    <div>Cover</div>
                    <div>Book</div>
                    <div>Action</div>
                    <div>Date</div>
                    <div>Time</div>
                    <div>Actions</div>
                </div>
                
                <% for (Map<String, Object> activity : filteredHistory) { 
                    int bookId = (int) activity.get("bookId");
                    String bookTitle = (String) activity.get("bookTitle");
                    String activityType = (String) activity.get("activityType");
                    java.sql.Timestamp timestamp = (java.sql.Timestamp) activity.get("timestamp");
                    
                    // Get book details
                    Book book = null;
                    try {
                        book = bookDAO.getBookById(bookId);
                    } catch (Exception e) {
                        e.printStackTrace();
                        continue; // Skip this activity if book can't be loaded
                    }
                    
                    if (book == null) continue;
                    
                    // Format action type
                    String actionDisplay = "View";
                    String actionClass = "action-view";
                    
                    if (activityType.equals("DOWNLOAD")) {
                        actionDisplay = "Download";
                        actionClass = "action-download";
                    } else if (activityType.equals("BOOKMARK_ADDED") || activityType.equals("BOOKMARK_REMOVED")) {
                        actionDisplay = activityType.equals("BOOKMARK_ADDED") ? "Bookmarked" : "Unbookmarked";
                        actionClass = "action-bookmark";
                    } else if (activityType.equals("STARTED_READING") || activityType.equals("FINISHED_READING")) {
                        actionDisplay = activityType.equals("STARTED_READING") ? "Started Reading" : "Finished Reading";
                        actionClass = "action-view";
                    }
                    
                    // Format date and time
                    String dateStr = dateFormat.format(timestamp);
                    String[] dateTimeParts = dateStr.split(" ");
                    String date = dateTimeParts[0] + " " + dateTimeParts[1];
                    String time = dateTimeParts[2];
                %>
                <div class="history-item">
                    <div>
                        <img src="../<%= book.getCoverImagePath() %>" alt="<%= book.getTitle() %>" class="book-cover">
                    </div>
                    <div class="book-info">
                        <h3 class="book-title"><%= book.getTitle() %></h3>
                        <p class="book-author">by <%= book.getAuthorName() %></p>
                    </div>
                    <div>
                        <span class="action-type <%= actionClass %>"><%= actionDisplay %></span>
                    </div>
                    <div class="timestamp">
                        <%= date %>
                    </div>
                    <div class="timestamp">
                        <%= time %>
                    </div>
                    <div class="item-actions">
                        <button class="item-action-btn btn-view" title="View Book" onclick="location.href='../bookdetails.jsp?id=<%= book.getBookId() %>'">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>
        </main>
    </div>

    <script>
        // Mobile menu toggle
        document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
            document.querySelector('.main-nav').classList.toggle('active');
        });
        
        // Reset filters
        function resetFilters() {
            document.getElementById('action').value = 'all';
            document.getElementById('sort').value = 'recent';
            document.getElementById('search').value = '';
            document.getElementById('filterForm').submit();
        }
    </script>
</body>
</html>
