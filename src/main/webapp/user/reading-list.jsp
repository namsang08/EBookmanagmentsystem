<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="mode.Book"%>
<%@ page import="mode.User"%>
<%@ page import="dao.BookDAO"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Date"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reading List - E-Library Hub</title>
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
        
        .reading-list-container {
            background-color: white;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow);
            overflow: hidden;
        }
        
        .reading-list-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .reading-list-table th, .reading-list-table td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
        }
        
        .reading-list-table th {
            background-color: var(--secondary-color);
            font-weight: 600;
            color: var(--text-color);
        }
        
        .reading-list-table tr:hover {
            background-color: rgba(0, 0, 0, 0.02);
        }
        
        .book-cover-small {
            width: 60px;
            height: 90px;
            object-fit: cover;
            border-radius: var(--border-radius);
        }
        
        .book-info-cell {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .book-details {
            flex: 1;
        }
        
        .book-title-link {
            font-weight: 600;
            color: var(--text-color);
            text-decoration: none;
            transition: color 0.3s ease;
        }
        
        .book-title-link:hover {
            color: var(--primary-color);
        }
        
        .book-author {
            color: var(--text-light);
            font-size: 0.9rem;
            margin-top: 5px;
        }
        
        .book-rating {
            color: gold;
            margin-top: 5px;
        }
        
        .priority-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        
        .priority-high {
            background-color: rgba(220, 53, 69, 0.1);
            color: #dc3545;
        }
        
        .priority-medium {
            background-color: rgba(255, 193, 7, 0.1);
            color: #ffc107;
        }
        
        .priority-low {
            background-color: rgba(40, 167, 69, 0.1);
            color: #28a745;
        }
        
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        
        .action-btn {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: var(--secondary-color);
            color: var(--text-color);
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .action-btn:hover {
            background-color: var(--primary-color);
            color: white;
        }
        
        .action-btn.start-reading {
            background-color: #28a745;
            color: white;
        }
        
        .action-btn.start-reading:hover {
            background-color: #218838;
        }
        
        .action-btn.remove {
            background-color: #dc3545;
            color: white;
        }
        
        .action-btn.remove:hover {
            background-color: #c82333;
        }
        
        .empty-state {
            text-align: center;
            padding: 50px 20px;
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
            
            .book-info-cell {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
            
            .book-cover-small {
                width: 50px;
                height: 75px;
            }
            
            .reading-list-table th:nth-child(3),
            .reading-list-table td:nth-child(3) {
                display: none;
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
    String priorityFilter = request.getParameter("priority");
    if (priorityFilter == null) {
        priorityFilter = "all";
    }
    
    String sortBy = request.getParameter("sort");
    if (sortBy == null) {
        sortBy = "priority";
    }
    
    String searchQuery = request.getParameter("search");
    if (searchQuery == null) {
        searchQuery = "";
    }
    
    // Initialize BookDAO
    BookDAO bookDAO = new BookDAO();
    
    // Get user's reading list books
    List<Book> readingListBooks = new ArrayList<>();
    try {
        readingListBooks = bookDAO.getReadingListBooks(user.getUserId());
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    // Create a list of maps to hold book and reading list info
    List<Map<String, Object>> readingList = new ArrayList<>();
    
    // Filter and sort the reading list
    for (Book book : readingListBooks) {
        // Skip if not matching priority filter
        if (!priorityFilter.equals("all")) {
            String bookPriority = "";
            int priority = book.getReadingPriority();
            
            if (priority <= 3) {
                bookPriority = "high";
            } else if (priority <= 7) {
                bookPriority = "medium";
            } else {
                bookPriority = "low";
            }
            
            if (!priorityFilter.equals(bookPriority)) {
                continue;
            }
        }
        
        // Skip if not matching search query
        if (!searchQuery.isEmpty()) {
            boolean matchesSearch = book.getTitle().toLowerCase().contains(searchQuery.toLowerCase()) ||
                                   book.getAuthorName().toLowerCase().contains(searchQuery.toLowerCase());
            if (!matchesSearch) {
                continue;
            }
        }
        
        // Create map with book and reading list info
        Map<String, Object> item = new HashMap<>();
        item.put("book", book);
        
        // Convert priority number to string
        String priority = "medium";
        int priorityNum = book.getReadingPriority();
        if (priorityNum <= 3) {
            priority = "high";
        } else if (priorityNum <= 7) {
            priority = "medium";
        } else {
            priority = "low";
        }
        item.put("priority", priority);
        
        // Add date (using book's upload date as a placeholder)
        item.put("dateAdded", book.getUploadDate());
        
        readingList.add(item);
    }
    
    // Sort the reading list
    if (sortBy.equals("priority")) {
        readingList.sort((a, b) -> {
            Book bookA = (Book) a.get("book");
            Book bookB = (Book) b.get("book");
            return Integer.compare(bookA.getReadingPriority(), bookB.getReadingPriority());
        });
    } else if (sortBy.equals("date_added")) {
        readingList.sort((a, b) -> {
            Date dateA = (Date) a.get("dateAdded");
            Date dateB = (Date) b.get("dateAdded");
            return dateB.compareTo(dateA); // Newest first
        });
    } else if (sortBy.equals("title")) {
        readingList.sort((a, b) -> {
            Book bookA = (Book) a.get("book");
            Book bookB = (Book) b.get("book");
            return bookA.getTitle().compareTo(bookB.getTitle());
        });
    } else if (sortBy.equals("author")) {
        readingList.sort((a, b) -> {
            Book bookA = (Book) a.get("book");
            Book bookB = (Book) b.get("book");
            return bookA.getAuthorName().compareTo(bookB.getAuthorName());
        });
    } else if (sortBy.equals("rating")) {
        readingList.sort((a, b) -> {
            Book bookA = (Book) a.get("book");
            Book bookB = (Book) b.get("book");
            return Double.compare(bookB.getRating(), bookA.getRating()); // Highest first
        });
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
                <li><a href="my-books.jsp"><i class="fas fa-book"></i> My Books</a></li>
                <li><a href="reading-list.jsp" class="active"><i class="fas fa-list"></i> Reading List</a></li>
                <li><a href="bookmarks.jsp"><i class="fas fa-bookmark"></i> Bookmarks</a></li>
                <li><a href="history.jsp"><i class="fas fa-history"></i> History</a></li>
                <li><a href="my-reviews.jsp"><i class="fas fa-star"></i> My Reviews</a></li>
                <li><a href="profile.jsp"><i class="fas fa-user"></i> Profile</a></li>
                <li><a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>
        
        <main class="main-content">
            <div class="dashboard-header">
                <h1 class="dashboard-title">Reading List</h1>
                <button class="btn-primary" onclick="openModal('addToReadingListModal')">
                    <i class="fas fa-plus"></i> Add Book
                </button>
            </div>
            
            <div class="filter-container">
                <form action="reading-list.jsp" method="get" id="filterForm">
                    <div class="filter-row">
                        <div class="filter-group">
                            <label for="priority">Priority</label>
                            <select id="priority" name="priority" class="form-control">
                                <option value="all" <%= priorityFilter.equals("all") ? "selected" : "" %>>All Priorities</option>
                                <option value="high" <%= priorityFilter.equals("high") ? "selected" : "" %>>High Priority</option>
                                <option value="medium" <%= priorityFilter.equals("medium") ? "selected" : "" %>>Medium Priority</option>
                                <option value="low" <%= priorityFilter.equals("low") ? "selected" : "" %>>Low Priority</option>
                            </select>
                        </div>
                        
                        <div class="filter-group">
                            <label for="sort">Sort By</label>
                            <select id="sort" name="sort" class="form-control">
                                <option value="priority" <%= sortBy.equals("priority") ? "selected" : "" %>>Priority</option>
                                <option value="date_added" <%= sortBy.equals("date_added") ? "selected" : "" %>>Date Added</option>
                                <option value="title" <%= sortBy.equals("title") ? "selected" : "" %>>Title</option>
                                <option value="author" <%= sortBy.equals("author") ? "selected" : "" %>>Author</option>
                                <option value="rating" <%= sortBy.equals("rating") ? "selected" : "" %>>Rating</option>
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
            
            <div class="reading-list-container">
                <% if (readingList.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-list"></i>
                    <h3>Your reading list is empty</h3>
                    <% if (!searchQuery.isEmpty() || !priorityFilter.equals("all")) { %>
                        <p>No books match your search criteria. Try different filters.</p>
                    <% } else { %>
                        <p>Add books to your reading list to keep track of what you want to read next.</p>
                    <% } %>
                    <a href="../browsebook.jsp" class="btn-primary">Browse Books</a>
                </div>
                <% } else { %>
                <table class="reading-list-table">
                    <thead>
                        <tr>
                            <th>Book</th>
                            <th>Added On</th>
                            <th>Priority</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> item : readingList) { 
                            Book book = (Book) item.get("book");
                            Date dateAdded = (Date) item.get("dateAdded");
                            String priority = (String) item.get("priority");
                            String priorityClass = "";
                            
                            if (priority.equals("high")) {
                                priorityClass = "priority-high";
                            } else if (priority.equals("medium")) {
                                priorityClass = "priority-medium";
                            } else {
                                priorityClass = "priority-low";
                            }
                        %>
                        <tr>
                            <td>
                                <div class="book-info-cell">
                                    <img src="../<%= book.getCoverImagePath() %>" alt="<%= book.getTitle() %>" class="book-cover-small">
                                    <div class="book-details">
                                        <a href="../bookdetails.jsp?id=<%= book.getBookId() %>" class="book-title-link"><%= book.getTitle() %></a>
                                        <div class="book-author">by <%= book.getAuthorName() %></div>
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
                                        </div>
                                    </div>
                                </div>
                            </td>
                            <td><%= dateFormat.format(dateAdded) %></td>
                            <td>
                                <span class="priority-badge <%= priorityClass %>">
                                    <%= priority.substring(0, 1).toUpperCase() + priority.substring(1) %>
                                </span>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <button class="action-btn start-reading" title="Start Reading" onclick="startReading(<%= book.getBookId() %>)">
                                        <i class="fas fa-book-reader"></i>
                                    </button>
                                    <button class="action-btn" title="Change Priority" onclick="openChangePriorityModal(<%= book.getBookId() %>, '<%= priority %>')">
                                        <i class="fas fa-flag"></i>
                                    </button>
                                    <button class="action-btn remove" title="Remove from Reading List" onclick="confirmRemoveFromList(<%= book.getBookId() %>, '<%= book.getTitle() %>')">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>
        </main>
    </div>
    
    <!-- Add to Reading List Modal -->
    <div id="addToReadingListModal" class="modal">
        <div class="modal-content">
            <span class="close-modal">&times;</span>
            <div class="modal-header">
                <h2 class="modal-title">Add to Reading List</h2>
            </div>
            <div class="modal-body">
                <form id="addToReadingListForm">
                    <div class="form-group">
                        <label for="bookSearch">Search for a book</label>
                        <input type="text" id="bookSearch" class="form-control" placeholder="Enter book title or author">
                        <div id="searchResults" style="margin-top: 10px;"></div>
                    </div>
                    
                    <div class="form-group">
                        <label for="bookPriority">Priority</label>
                        <select id="bookPriority" class="form-control">
                            <option value="high">High</option>
                            <option value="medium" selected>Medium</option>
                            <option value="low">Low</option>
                        </select>
                    </div>
                    
                    <input type="hidden" id="selectedBookId">
                </form>
            </div>
            <div class="modal-footer">
                <button class="btn-secondary close-modal-btn">Cancel</button>
                <button class="btn-primary" id="addToListBtn" disabled>Add to List</button>
            </div>
        </div>
    </div>
    
    <!-- Change Priority Modal -->
    <div id="changePriorityModal" class="modal">
        <div class="modal-content">
            <span class="close-modal">&times;</span>
            <div class="modal-header">
                <h2 class="modal-title">Change Priority</h2>
            </div>
            <div class="modal-body">
                <form id="changePriorityForm">
                    <div class="form-group">
                        <label for="newPriority">Select Priority</label>
                        <select id="newPriority" class="form-control">
                            <option value="high">High</option>
                            <option value="medium">Medium</option>
                            <option value="low">Low</option>
                        </select>
                    </div>
                    
                    <input type="hidden" id="priorityBookId">
                </form>
            </div>
            <div class="modal-footer">
                <button class="btn-secondary close-modal-btn">Cancel</button>
                <button class="btn-primary" id="changePriorityBtn">Save Changes</button>
            </div>
        </div>
    </div>
    
    <!-- Remove from Reading List Modal -->
    <div id="removeFromListModal" class="modal">
        <div class="modal-content">
            <span class="close-modal">&times;</span>
            <div class="modal-header">
                <h2 class="modal-title">Remove from Reading List</h2>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to remove <strong id="removeBookTitle"></strong> from your reading list?</p>
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
            document.getElementById('priority').value = 'all';
            document.getElementById('sort').value = 'priority';
            document.getElementById('search').value = '';
            document.getElementById('filterForm').submit();
        }
        
        // Start reading function
        function startReading(bookId) {
            // Update reading status to "reading"
            fetch('../UserBookServlet?action=updateReadingStatus&bookId=' + bookId + '&status=reading', {
                method: 'POST'
            })
            .then(response => {
                if (response.ok) {
                    // Remove from reading list
                    return fetch('../UserBookServlet?action=removeFromReadingList&bookId=' + bookId, {
                        method: 'POST'
                    });
                }
                throw new Error('Failed to update reading status');
            })
            .then(response => {
                if (response.ok) {
                    // Redirect to book reader page
                    window.location.href = '../reader.jsp?id=' + bookId;
                }
            })
            .catch(error => console.error('Error:', error));
        }
        
        // Open change priority modal
        function openChangePriorityModal(bookId, currentPriority) {
            document.getElementById('priorityBookId').value = bookId;
            document.getElementById('newPriority').value = currentPriority;
            openModal('changePriorityModal');
        }
        
        // Confirm remove from reading list
        function confirmRemoveFromList(bookId, bookTitle) {
            document.getElementById('removeBookTitle').textContent = bookTitle;
            document.getElementById('confirmRemoveBtn').onclick = function() {
                removeFromReadingList(bookId);
            };
            openModal('removeFromListModal');
        }
        
        // Remove from reading list function
        function removeFromReadingList(bookId) {
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
        
        // Book search for add to reading list
        document.getElementById('bookSearch').addEventListener('input', function() {
            const query = this.value.trim();
            
            if (query.length < 2) {
                document.getElementById('searchResults').innerHTML = '';
                document.getElementById('selectedBookId').value = '';
                document.getElementById('addToListBtn').disabled = true;
                return;
            }
            
            fetch('../BookServlet?action=searchBooks&query=' + encodeURIComponent(query))
                .then(response => response.json())
                .then(data => {
                    const resultsDiv = document.getElementById('searchResults');
                    resultsDiv.innerHTML = '';
                    
                    if (data.length === 0) {
                        resultsDiv.innerHTML = '<p>No books found</p>';
                        return;
                    }
                    
                    const ul = document.createElement('ul');
                    ul.style.listStyle = 'none';
                    ul.style.padding = '0';
                    ul.style.maxHeight = '200px';
                    ul.style.overflowY = 'auto';
                    
                    data.forEach(book => {
                        const li = document.createElement('li');
                        li.style.padding = '10px';
                        li.style.borderBottom = '1px solid #eee';
                        li.style.cursor = 'pointer';
                        
                        li.innerHTML = `
                            <div style="display: flex; align-items: center; gap: 10px;">
                                <img src="../${book.coverImagePath}" alt="${book.title}" style="width: 40px; height: 60px; object-fit: cover;">
                                <div>
                                    <div style="font-weight: 600;">${book.title}</div>
                                    <div style="font-size: 0.8rem; color: #6c757d;">by ${book.authorName}</div>
                                </div>
                            </div>
                        `;
                        
                        li.addEventListener('click', function() {
                            document.getElementById('bookSearch').value = book.title;
                            document.getElementById('selectedBookId').value = book.bookId;
                            document.getElementById('addToListBtn').disabled = false;
                            resultsDiv.innerHTML = '';
                        });
                        
                        ul.appendChild(li);
                    });
                    
                    resultsDiv.appendChild(ul);
                })
                .catch(error => console.error('Error:', error));
        });
        
        // Add to reading list
        document.getElementById('addToListBtn').addEventListener('click', function() {
            const bookId = document.getElementById('selectedBookId').value;
            const priorityText = document.getElementById('bookPriority').value;
            
            if (!bookId) {
                return;
            }
            
            // Convert priority text to number
            let priorityNum = 5; // Default medium
            if (priorityText === 'high') {
                priorityNum = 1;
            } else if (priorityText === 'low') {
                priorityNum = 9;
            }
            
            fetch('../UserBookServlet?action=addToReadingList&bookId=' + bookId + '&priority=' + priorityNum, {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Close modal and reload page
                    closeAllModals();
                    window.location.reload();
                } else {
                    alert(data.message || 'Failed to add book to reading list.');
                }
            })
            .catch(error => console.error('Error:', error));
        });
        
        // Change priority
        document.getElementById('changePriorityBtn').addEventListener('click', function() {
            const bookId = document.getElementById('priorityBookId').value;
            const priorityText = document.getElementById('newPriority').value;
            
            // Convert priority text to number
            let priorityNum = 5; // Default medium
            if (priorityText === 'high') {
                priorityNum = 1;
            } else if (priorityText === 'low') {
                priorityNum = 9;
            }
            
            fetch('../UserBookServlet?action=updateReadingListPriority&bookId=' + bookId + '&priority=' + priorityNum, {
                method: 'POST'
            })
            .then(response => {
                if (response.ok) {
                    // Close modal and reload page
                    closeAllModals();
                    window.location.reload();
                }
            })
            .catch(error => console.error('Error:', error));
        });
        
        // Modal functions
        function openModal(modalId) {
            document.getElementById(modalId).style.display = 'block';
            document.body.style.overflow = 'hidden';
        }
        
        function closeAllModals() {
            document.querySelectorAll('.modal').forEach(function(modal) {
                modal.style.display = 'none';
            });
            document.body.style.overflow = 'auto';
        }
        
        // Close modals when clicking on X or close button
        document.querySelectorAll('.close-modal, .close-modal-btn').forEach(function(element) {
            element.addEventListener('click', closeAllModals);
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
