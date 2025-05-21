<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Comparator"%>
<%@ page import="java.util.Collections"%>
<%@ page import="mode.Book"%>
<%@ page import="mode.User"%>
<%@ page import="dao.BookDAO"%>
<%@ page import="java.text.SimpleDateFormat"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Books - E-Library Hub</title>
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
        
        .books-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 20px;
        }
        
        .book-card {
            background-color: white;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow);
            overflow: hidden;
            transition: transform 0.3s ease;
            height: 100%;
            display: flex;
            flex-direction: column;
            position: relative;
        }
        
        .book-card:hover {
            transform: translateY(-5px);
        }
        
        .book-status {
            position: absolute;
            top: 10px;
            right: 10px;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
            z-index: 1;
        }
        
        .status-reading {
            background-color: rgba(74, 109, 167, 0.9);
            color: white;
        }
        
        .status-to-read {
            background-color: rgba(40, 167, 69, 0.9);
            color: white;
        }
        
        .status-finished {
            background-color: rgba(255, 193, 7, 0.9);
            color: black;
        }
        
        .book-cover {
            height: 200px;
            overflow: hidden;
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
        }
        
        .book-author {
            color: var(--text-light);
            font-size: 0.9rem;
            margin-bottom: 10px;
        }
        
        .book-rating {
            margin-bottom: 10px;
            color: gold;
        }
        
        .book-progress {
            margin-bottom: 15px;
        }
        
        .progress-bar {
            height: 6px;
            background-color: var(--secondary-color);
            border-radius: 3px;
            overflow: hidden;
        }
        
        .progress-fill {
            height: 100%;
            background-color: var(--primary-color);
        }
        
        .progress-text {
            font-size: 0.8rem;
            color: var(--text-light);
            margin-top: 5px;
            text-align: right;
        }
        
        .book-actions {
            margin-top: auto;
            display: flex;
            flex-direction: column;
            gap: 5px;
        }
        
        .book-action-btn {
            width: 100%;
            padding: 8px;
            border: none;
            border-radius: var(--border-radius);
            cursor: pointer;
            transition: background-color 0.3s ease;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .book-action-btn i {
            margin-right: 5px;
        }
        
        .btn-continue {
            background-color: var(--primary-color);
            color: white;
        }
        
        .btn-continue:hover {
            background-color: #3a5f8a;
        }
        
        .btn-start {
            background-color: #28a745;
            color: white;
        }
        
        .btn-start:hover {
            background-color: #218838;
        }
        
        .btn-reread {
            background-color: #ffc107;
            color: black;
        }
        
        .btn-reread:hover {
            background-color: #e0a800;
        }
        
        .btn-details {
            background-color: var(--secondary-color);
            color: var(--text-color);
        }
        
        .btn-details:hover {
            background-color: #d1d1d1;
        }
        
        .btn-remove {
            background-color: #dc3545;
            color: white;
        }
        
        .btn-remove:hover {
            background-color: #c82333;
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
            max-width: 500px;
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
            
            .filter-row {
                flex-direction: column;
                gap: 10px;
            }
            
            .books-grid {
                grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
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
    String statusFilter = request.getParameter("filter");
    if (statusFilter == null) {
        statusFilter = "all";
    }
    
    String sortBy = request.getParameter("sort");
    if (sortBy == null) {
        sortBy = "recent";
    }
    
    String searchQuery = request.getParameter("search");
    if (searchQuery == null) {
        searchQuery = "";
    }
    
    // Initialize BookDAO
    BookDAO bookDAO = new BookDAO();
    
    // Get user's books based on filters
    List<Book> userBooks = new ArrayList<>();
    
    try {
        // Get books based on status filter
        if (statusFilter.equals("all") || statusFilter.isEmpty()) {
            // Combine books from all statuses
            userBooks.addAll(bookDAO.getCurrentlyReadingBooks(user.getUserId()));
            userBooks.addAll(bookDAO.getReadingListBooks(user.getUserId()));
            userBooks.addAll(bookDAO.getFinishedBooks(user.getUserId()));
        } else if (statusFilter.equals("reading")) {
            userBooks = bookDAO.getCurrentlyReadingBooks(user.getUserId());
        } else if (statusFilter.equals("to_read")) {
            userBooks = bookDAO.getReadingListBooks(user.getUserId());
        } else if (statusFilter.equals("finished")) {
            userBooks = bookDAO.getFinishedBooks(user.getUserId());
        }
        
        // Apply search filter if provided
        if (searchQuery != null && !searchQuery.isEmpty()) {
            String searchLower = searchQuery.toLowerCase();
            List<Book> filteredBooks = new ArrayList<>();
            
            for (Book book : userBooks) {
                if (book.getTitle().toLowerCase().contains(searchLower) || 
                    book.getAuthorName().toLowerCase().contains(searchLower)) {
                    filteredBooks.add(book);
                }
            }
            
            userBooks = filteredBooks;
        }
        
        // Sort books based on sort parameter
        if (sortBy.equals("title")) {
            Collections.sort(userBooks, Comparator.comparing(Book::getTitle));
        } else if (sortBy.equals("author")) {
            Collections.sort(userBooks, Comparator.comparing(Book::getAuthorName));
        } else if (sortBy.equals("rating")) {
            Collections.sort(userBooks, Comparator.comparing(Book::getRating).reversed());
        } else if (sortBy.equals("progress")) {
            Collections.sort(userBooks, Comparator.comparing(Book::getReadingProgress).reversed());
        } else {
            // Default: sort by recent (last read time for reading books, or added time for others)
            Collections.sort(userBooks, (b1, b2) -> {
                if (b1.getLastReadTime() != null && b2.getLastReadTime() != null) {
                    return b2.getLastReadTime().compareTo(b1.getLastReadTime());
                } else if (b1.getLastReadTime() != null) {
                    return -1;
                } else if (b2.getLastReadTime() != null) {
                    return 1;
                } else {
                    return 0;
                }
            });
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    // Format date
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
                <li><a href="my-books.jsp" class="active"><i class="fas fa-book"></i> My Books</a></li>
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
                <h1 class="dashboard-title">My Books</h1>
            </div>
            
            <div class="filter-container">
                <form action="my-books.jsp" method="get" id="filterForm">
                    <div class="filter-row">
                        <div class="filter-group">
                            <label for="filter">Status</label>
                            <select id="filter" name="filter" class="form-control">
                                <option value="all" <%= statusFilter.equals("all") ? "selected" : "" %>>All Books</option>
                                <option value="reading" <%= statusFilter.equals("reading") ? "selected" : "" %>>Currently Reading</option>
                                <option value="to_read" <%= statusFilter.equals("to_read") ? "selected" : "" %>>To Read</option>
                                <option value="finished" <%= statusFilter.equals("finished") ? "selected" : "" %>>Finished</option>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label for="sort">Sort By</label>
                            <select id="sort" name="sort" class="form-control">
                                <option value="recent" <%= sortBy.equals("recent") ? "selected" : "" %>>Recently Added</option>
                                <option value="title" <%= sortBy.equals("title") ? "selected" : "" %>>Title</option>
                                <option value="author" <%= sortBy.equals("author") ? "selected" : "" %>>Author</option>
                                <option value="rating" <%= sortBy.equals("rating") ? "selected" : "" %>>Rating</option>
                                <option value="progress" <%= sortBy.equals("progress") ? "selected" : "" %>>Reading Progress</option>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label for="search">Search</label>
                            <input type="text" id="search" name="search" class="form-control" placeholder="Search by title or author" value="<%= searchQuery %>">
                        </div>
                    </div>
                    
                    <div class="filter-actions">
                        <button type="button" class="filter-btn filter-btn-reset" onclick="resetFilters()">Reset</button>
                        <button type="submit" class="filter-btn filter-btn-apply">Apply Filters</button>
                    </div>
                </form>
            </div>
            
            <% if (userBooks.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-book"></i>
                <h3>No books found</h3>
                <% if (!searchQuery.isEmpty()) { %>
                    <p>No books match your search criteria. Try different keywords.</p>
                <% } else if (!statusFilter.equals("all")) { %>
                    <p>You don't have any books with the selected status.</p>
                <% } else { %>
                    <p>You haven't added any books to your collection yet.</p>
                <% } %>
                <a href="../browsebook.jsp" class="btn-primary">Browse Books</a>
            </div>
            <% } else { %>
            <div class="books-grid">
                <% for (Book book : userBooks) { 
                    String statusClass = "";
                    String statusText = "";
                    String readingStatus = "";
                    
                    // Determine reading status
                    if (book.getLastReadTime() != null) {
                        readingStatus = "reading";
                        statusClass = "status-reading";
                        statusText = "Reading";
                    } else if (book.getReadingPriority() > 0) {
                        readingStatus = "to_read";
                        statusClass = "status-to-read";
                        statusText = "To Read";
                    } else if (book.getCompletedDate() != null) {
                        readingStatus = "finished";
                        statusClass = "status-finished";
                        statusText = "Finished";
                    }
                    
                    // Get progress percentage
                    int progress = book.getReadingProgress();
                %>
                <div class="book-card">
                    <span class="book-status <%= statusClass %>"><%= statusText %></span>
                    <div class="book-cover">
                        <img src="../<%= book.getCoverImagePath() %>" alt="<%= book.getTitle() %>">
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
                            <span style="color: var(--text-color); margin-left: 5px;">
                                <%= String.format("%.1f", rating) %>
                            </span>
                        </div>
                        
                        <% if (readingStatus.equals("reading")) { %>
                        <div class="book-progress">
                            <div class="progress-bar">
                                <div class="progress-fill" style="width: <%= progress %>%;"></div>
                            </div>
                            <div class="progress-text">
                                <%= Math.round(book.getPages() * (progress / 100.0)) %> / <%= book.getPages() %> pages (<%= progress %>% completed)
                            </div>
                        </div>
                        <% } %>
                        
                        <div class="book-actions">
                            <% if (readingStatus.equals("reading")) { %>
                                <button class="book-action-btn btn-continue" onclick="continueReading(<%= book.getBookId() %>)">
                                    <i class="fas fa-book-reader"></i> Continue Reading
                                </button>
                            <% } else if (readingStatus.equals("to_read")) { %>
                                <button class="book-action-btn btn-start" onclick="startReading(<%= book.getBookId() %>)">
                                    <i class="fas fa-play"></i> Start Reading
                                </button>
                            <% } else if (readingStatus.equals("finished")) { %>
                                <button class="book-action-btn btn-reread" onclick="rereadBook(<%= book.getBookId() %>)">
                                    <i class="fas fa-redo"></i> Read Again
                                </button>
                            <% } %>
                            
                            <button class="book-action-btn btn-details" onclick="location.href='../bookdetails.jsp?id=<%= book.getBookId() %>'">
                                <i class="fas fa-info-circle"></i> View Details
                            </button>
                            
                            <button class="book-action-btn btn-remove" onclick="confirmRemoveBook(<%= book.getBookId() %>, '<%= book.getTitle() %>')">
                                <i class="fas fa-trash"></i> Remove from My Books
                            </button>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>
        </main>
    </div>
    
    <!-- Remove Book Confirmation Modal -->
    <div id="removeBookModal" class="modal">
        <div class="modal-content">
            <span class="close-modal">&times;</span>
            <div class="modal-header">
                <h2 class="modal-title">Remove Book</h2>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to remove <strong id="removeBookTitle"></strong> from your books?</p>
                <p>This will not delete the book from the library, but it will remove it from your collection and reset your reading progress.</p>
            </div>
            <div class="modal-footer">
                <button class="btn-secondary close-modal-btn">Cancel</button>
                <button class="btn-danger" id="confirmRemoveBtn">Remove</button>
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
            document.getElementById('filter').value = 'all';
            document.getElementById('sort').value = 'recent';
            document.getElementById('search').value = '';
            document.getElementById('filterForm').submit();
        }
        
        // Continue reading function
        function continueReading(bookId) {
            // Record the view action
            fetch('../BookServlet?action=recordView&bookId=' + bookId, {
                method: 'POST'
            })
            .then(response => {
                if (response.ok) {
                    // Redirect to book reader page
                    window.location.href = '../reader.jsp?id=' + bookId;
                }
            })
            .catch(error => console.error('Error:', error));
        }
        
        // Start reading function
        function startReading(bookId) {
            // Update reading status to "reading"
            fetch('../UserBookServlet?action=updateReadingStatus&bookId=' + bookId + '&status=READING', {
                method: 'POST'
            })
            .then(response => {
                if (response.ok) {
                    // Redirect to book reader page
                    window.location.href = '../reader.jsp?id=' + bookId;
                }
            })
            .catch(error => console.error('Error:', error));
        }
        
        // Reread book function
        function rereadBook(bookId) {
            // Update reading status to "reading" and reset progress
            fetch('../UserBookServlet?action=updateReadingStatus&bookId=' + bookId + '&status=READING&resetProgress=true', {
                method: 'POST'
            })
            .then(response => {
                if (response.ok) {
                    // Redirect to book reader page
                    window.location.href = '../reader.jsp?id=' + bookId;
                }
            })
            .catch(error => console.error('Error:', error));
        }
        
        // Confirm remove book
        function confirmRemoveBook(bookId, bookTitle) {
            document.getElementById('removeBookTitle').textContent = bookTitle;
            document.getElementById('confirmRemoveBtn').onclick = function() {
                removeBook(bookId);
            };
            openModal('removeBookModal');
        }
        
        // Remove book function
        function removeBook(bookId) {
            fetch('../UserBookServlet?action=removeFromReadingList&bookId=' + bookId, {
                method: 'POST'
            })
            .then(response => {
                if (response.ok) {
                    // Reload the page to reflect changes
                    window.location.reload();
                }
            })
            .catch(error => console.error('Error:', error));
        }
        
        // Modal functions
        function openModal(modalId) {
            document.getElementById(modalId).style.display = 'block';
            document.body.style.overflow = 'hidden';
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
    </script>
</body>
</html>
