<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="mode.User, java.util.List, dao.BookDAO, mode.Book, dao.CategoryDAO, mode.Category, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Books - E-Library Hub</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="../css/admin-styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.19/dist/sweetalert2.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.19/dist/sweetalert2.all.min.js"></script>
    <style>
        .books-container {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
        }
        
        .search-filter-container {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        
        .search-box {
            flex: 1;
            position: relative;
            min-width: 200px;
        }
        
        .search-box input {
            width: 100%;
            padding: 10px 15px 10px 40px;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
        }
        
        .search-box i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-light);
        }
        
        .filter-dropdown select {
            padding: 10px 15px;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            background-color: white;
        }
        
        .books-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .books-table th, .books-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
        }
        
        .books-table th {
            font-weight: 600;
            color: var(--text-light);
        }
        
        .books-table tbody tr:hover {
            background-color: rgba(0, 0, 0, 0.02);
        }
        
        .status-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
        }
        
        .status-badge.approved {
            background-color: rgba(40, 167, 69, 0.1);
            color: #28a745;
        }
        
        .status-badge.pending {
            background-color: rgba(255, 193, 7, 0.1);
            color: #ffc107;
        }
        
        .status-badge.rejected {
            background-color: rgba(220, 53, 69, 0.1);
            color: #dc3545;
        }
        
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        
        .action-btn {
            width: 30px;
            height: 30px;
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
        
        .action-btn.view:hover {
            background-color: #17a2b8;
        }
        
        .action-btn.edit:hover {
            background-color: #ffc107;
        }
        
        .action-btn.delete:hover {
            background-color: #dc3545;
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            margin-top: 20px;
        }
        
        .pagination-btn {
            padding: 5px 10px;
            margin: 0 5px;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            background-color: white;
            cursor: pointer;
        }
        
        .pagination-btn.active {
            background-color: var(--primary-color);
            color: white;
            border-color: var(--primary-color);
        }
        
        .pagination-btn:hover:not(.active) {
            background-color: var(--secondary-color);
        }
        
        .book-cover {
            width: 50px;
            height: 70px;
            object-fit: cover;
            border-radius: 4px;
        }
        
        .book-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .book-title {
            font-weight: 500;
            margin-bottom: 3px;
        }
        
        .book-author {
            font-size: 0.8rem;
            color: var(--text-light);
        }
        
        .rating-stars {
            color: #ffc107;
            font-size: 0.8rem;
        }
        
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .stat-card {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 15px;
            box-shadow: var(--shadow);
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
        }
        
        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 10px;
            font-size: 1.5rem;
        }
        
        .stat-icon.total {
            background-color: rgba(13, 110, 253, 0.1);
            color: #0d6efd;
        }
        
        .stat-icon.approved {
            background-color: rgba(40, 167, 69, 0.1);
            color: #28a745;
        }
        
        .stat-icon.pending {
            background-color: rgba(255, 193, 7, 0.1);
            color: #ffc107;
        }
        
        .stat-icon.rejected {
            background-color: rgba(220, 53, 69, 0.1);
            color: #dc3545;
        }
        
        .stat-value {
            font-size: 1.8rem;
            font-weight: 600;
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: var(--text-light);
            font-size: 0.9rem;
        }
        
        @media (max-width: 992px) {
            .search-filter-container {
                flex-direction: column;
            }
            
            .stats-container {
                grid-template-columns: 1fr 1fr;
            }
        }
        
        @media (max-width: 576px) {
            .stats-container {
                grid-template-columns: 1fr;
            }
            
            .books-table {
                font-size: 0.9rem;
            }
            
            .action-btn {
                width: 25px;
                height: 25px;
            }
        }
    </style>
</head>
<body>
    <%
        // Check if user is logged in and is an admin
        User user = (User) session.getAttribute("user");
        if (user == null || user.getRole() != User.Role.ADMIN) {
            response.sendRedirect("../login.jsp?error=unauthorized");
            return;
        }
        
        // Get books from DAO
        BookDAO bookDAO = new BookDAO();
        CategoryDAO categoryDAO = new CategoryDAO();
        
        // Pagination parameters
        int currentPage = 1;
        int recordsPerPage = 10;
        if (request.getParameter("page") != null) {
            currentPage = Integer.parseInt(request.getParameter("page"));
        }
        
        // Search and filter parameters
        String searchQuery = request.getParameter("search") != null ? request.getParameter("search") : "";
        String statusFilter = request.getParameter("status") != null ? request.getParameter("status") : "all";
        String categoryFilter = request.getParameter("category") != null ? request.getParameter("category") : "all";
        
        // Get all books
        List<Book> allBooks = bookDAO.getAllBooks();
        
        // Filter books based on search and filters
        List<Book> filteredBooks = new java.util.ArrayList<>();
        
        for (Book book : allBooks) {
            boolean matchesSearch = searchQuery.isEmpty() || 
                                   book.getTitle().toLowerCase().contains(searchQuery.toLowerCase()) ||
                                   book.getDescription().toLowerCase().contains(searchQuery.toLowerCase()) ||
                                   book.getAuthorName().toLowerCase().contains(searchQuery.toLowerCase()) ||
                                   book.getCategoryName().toLowerCase().contains(searchQuery.toLowerCase());
            
            boolean matchesStatus = "all".equals(statusFilter) || 
                                   book.getStatus().toString().equalsIgnoreCase(statusFilter);
            
            boolean matchesCategory = "all".equals(categoryFilter) || 
                                     String.valueOf(book.getCategoryId()).equals(categoryFilter);
            
            if (matchesSearch && matchesStatus && matchesCategory) {
                filteredBooks.add(book);
            }
        }
        
        // Calculate pagination
        int totalBooks = filteredBooks.size();
        int totalPages = (int) Math.ceil((double) totalBooks / recordsPerPage);
        
        // Get books for current page
        int startIdx = (currentPage - 1) * recordsPerPage;
        int endIdx = Math.min(startIdx + recordsPerPage, totalBooks);
        List<Book> booksForPage = filteredBooks.subList(startIdx, endIdx);
        
        // Get categories for filter dropdown
        List<Category> categories = categoryDAO.getAllCategories();
        
        // Calculate statistics
        int totalBooksCount = allBooks.size();
        int approvedBooksCount = 0;
        int pendingBooksCount = 0;
        int rejectedBooksCount = 0;
        
        for (Book book : allBooks) {
            if (book.getStatus() == Book.Status.APPROVED) {
                approvedBooksCount++;
            } else if (book.getStatus() == Book.Status.PENDING) {
                pendingBooksCount++;
            } else if (book.getStatus() == Book.Status.REJECTED) {
                rejectedBooksCount++;
            }
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
                <h2>Admin Dashboard</h2>
                <p>Welcome, <%= user.getFirstName() %></p>
            </div>
            <ul class="sidebar-menu">
                <li><a href="dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="books.jsp" class="active"><i class="fas fa-book"></i> Books</a></li>
                <li><a href="users.jsp"><i class="fas fa-users"></i> Users</a></li>
                <li><a href="authors.jsp"><i class="fas fa-user-edit"></i> Authors</a></li>
                <li><a href="categories.jsp"><i class="fas fa-tags"></i> Categories</a></li>
                <li><a href="reports.jsp"><i class="fas fa-chart-bar"></i> Reports</a></li>
                <li><a href="settings.jsp"><i class="fas fa-cog"></i> Settings</a></li>
                <li><a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>
        
        <main class="main-content">
            <div class="page-header">
                <h1 class="page-title">Manage Books</h1>
                <a href="add-book.jsp" class="btn-primary"><i class="fas fa-plus"></i> Add New Book</a>
            </div>
            
            <div class="stats-container">
                <div class="stat-card">
                    <div class="stat-icon total">
                        <i class="fas fa-book"></i>
                    </div>
                    <div class="stat-value"><%= totalBooksCount %></div>
                    <div class="stat-label">Total Books</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon approved">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <div class="stat-value"><%= approvedBooksCount %></div>
                    <div class="stat-label">Approved Books</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon pending">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="stat-value"><%= pendingBooksCount %></div>
                    <div class="stat-label">Pending Books</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon rejected">
                        <i class="fas fa-times-circle"></i>
                    </div>
                    <div class="stat-value"><%= rejectedBooksCount %></div>
                    <div class="stat-label">Rejected Books</div>
                </div>
            </div>
            
            <div class="books-container">
                <div class="search-filter-container">
                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" id="searchInput" placeholder="Search books..." value="<%= searchQuery %>">
                    </div>
                    <div class="filter-dropdown">
                        <select id="statusFilter">
                            <option value="all" <%= "all".equals(statusFilter) ? "selected" : "" %>>All Status</option>
                            <option value="APPROVED" <%= "APPROVED".equals(statusFilter) ? "selected" : "" %>>Approved</option>
                            <option value="PENDING" <%= "PENDING".equals(statusFilter) ? "selected" : "" %>>Pending</option>
                            <option value="REJECTED" <%= "REJECTED".equals(statusFilter) ? "selected" : "" %>>Rejected</option>
                        </select>
                    </div>
                    <div class="filter-dropdown">
                        <select id="categoryFilter">
                            <option value="all" <%= "all".equals(categoryFilter) ? "selected" : "" %>>All Categories</option>
                            <% for (Category category : categories) { %>
                                <option value="<%= category.getCategoryId() %>" <%= String.valueOf(category.getCategoryId()).equals(categoryFilter) ? "selected" : "" %>><%= category.getName() %></option>
                            <% } %>
                        </select>
                    </div>
                    <button class="btn-primary" id="applyFilters">Apply Filters</button>
                </div>
                
                <table class="books-table">
                    <thead>
                        <tr>
                            <th>Book</th>
                            <th>Category</th>
                            <th>Status</th>
                            <th>Rating</th>
                            <th>Views</th>
                            <th>Downloads</th>
                            <th>Date Added</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (booksForPage != null && !booksForPage.isEmpty()) {
                            for (Book book : booksForPage) {
                        %>
                        <tr>
                            <td>
                                <div class="book-info">
                                    <img src="<%= book.getCoverImagePath() != null ? book.getCoverImagePath() : "../images/default-cover.jpg" %>" alt="<%= book.getTitle() %>" class="book-cover">
                                    <div>
                                        <div class="book-title"><%= book.getTitle() %></div>
                                        <div class="book-author">by <%= book.getAuthorName() %></div>
                                    </div>
                                </div>
                            </td>
                            <td><%= book.getCategoryName() %></td>
                            <td>
                                <% if (book.getStatus() == Book.Status.APPROVED) { %>
                                    <span class="status-badge approved">Approved</span>
                                <% } else if (book.getStatus() == Book.Status.PENDING) { %>
                                    <span class="status-badge pending">Pending</span>
                                <% } else { %>
                                    <span class="status-badge rejected">Rejected</span>
                                <% } %>
                            </td>
                            <td>
                                <div class="rating-stars">
                                    <% 
                                    double rating = book.getRating();
                                    for (int i = 1; i <= 5; i++) {
                                        if (i <= rating) {
                                    %>
                                        <i class="fas fa-star"></i>
                                    <% } else if (i <= rating + 0.5) { %>
                                        <i class="fas fa-star-half-alt"></i>
                                    <% } else { %>
                                        <i class="far fa-star"></i>
                                    <% } } %>
                                    (<%= String.format("%.1f", rating) %>)
                                </div>
                            </td>
                            <td><%= book.getViews() %></td>
                            <td><%= book.getDownloads() %></td>
                            <td><%= dateFormat.format(book.getUploadDate()) %></td>
                            <td>
                                <div class="action-buttons">
                                    <button class="action-btn view" onclick="viewBook(<%= book.getBookId() %>)">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <button class="action-btn edit" onclick="editBook(<%= book.getBookId() %>)">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="action-btn delete" onclick="confirmDeleteBook(<%= book.getBookId() %>, '<%= book.getTitle().replace("'", "\\'") %>')">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <% 
                            }
                        } else { 
                        %>
                        <tr>
                            <td colspan="8" style="text-align: center;">No books found</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                
                <% if (totalPages > 1) { %>
                <div class="pagination">
                    <% if (currentPage > 1) { %>
                        <button class="pagination-btn" onclick="goToPage(<%= currentPage - 1 %>)"><i class="fas fa-chevron-left"></i></button>
                    <% } %>
                    
                    <% 
                    int startPage = Math.max(1, currentPage - 2);
                    int endPage = Math.min(totalPages, currentPage + 2);
                    
                    for (int i = startPage; i <= endPage; i++) { 
                    %>
                        <button class="pagination-btn <%= i == currentPage ? "active" : "" %>" onclick="goToPage(<%= i %>)"><%= i %></button>
                    <% } %>
                    
                    <% if (currentPage < totalPages) { %>
                        <button class="pagination-btn" onclick="goToPage(<%= currentPage + 1 %>)"><i class="fas fa-chevron-right"></i></button>
                    <% } %>
                </div>
                <% } %>
            </div>
        </main>
    </div>

    <script>
        // Mobile menu toggle
        document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
            document.querySelector('.main-nav').classList.toggle('active');
        });
        
        // Apply filters
        document.getElementById('applyFilters').addEventListener('click', function() {
            applyFilters();
        });
        
        // Search on enter key
        document.getElementById('searchInput').addEventListener('keyup', function(event) {
            if (event.key === 'Enter') {
                applyFilters();
            }
        });
        
        function applyFilters() {
            const searchQuery = document.getElementById('searchInput').value;
            const statusFilter = document.getElementById('statusFilter').value;
            const categoryFilter = document.getElementById('categoryFilter').value;
            
            window.location.href = 'books.jsp?search=' + encodeURIComponent(searchQuery) + 
                                  '&status=' + statusFilter + 
                                  '&category=' + categoryFilter;
        }
        
        function goToPage(page) {
            const searchQuery = '<%= searchQuery %>';
            const statusFilter = '<%= statusFilter %>';
            const categoryFilter = '<%= categoryFilter %>';
            
            window.location.href = 'books.jsp?page=' + page + 
                                  '&search=' + encodeURIComponent(searchQuery) + 
                                  '&status=' + statusFilter + 
                                  '&category=' + categoryFilter;
        }
        
        // Book actions
        function viewBook(bookId) {
            window.location.href = 'book-details.jsp?id=' + bookId;
        }
        
        function editBook(bookId) {
            window.location.href = 'edit-book.jsp?id=' + bookId;
        }
        
        function confirmDeleteBook(bookId, bookTitle) {
            Swal.fire({
                title: 'Delete Book',
                text: 'Are you sure you want to delete "' + bookTitle + '"?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#dc3545',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Yes, delete it!'
            }).then((result) => {
                if (result.isConfirmed) {
                    deleteBook(bookId);
                }
            });
        }
        
        function deleteBook(bookId) {
            fetch('../AdminBookServlet?action=delete&id=' + bookId, {
                method: 'POST'
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.text();
            })
            .then(text => {
                let data;
                try {
                    data = JSON.parse(text);
                } catch (e) {
                    // If the response is not JSON, create a default response
                    data = { success: text.includes('success'), message: text };
                }
                
                if (data.success) {
                    Swal.fire({
                        title: 'Deleted!',
                        text: data.message || 'Book has been deleted successfully.',
                        icon: 'success'
                    }).then(() => {
                        window.location.reload();
                    });
                } else {
                    Swal.fire({
                        title: 'Error!',
                        text: data.message || 'An error occurred while deleting the book.',
                        icon: 'error'
                    });
                }
            })
            .catch(error => {
                console.error('Error:', error);
                Swal.fire({
                    title: 'Error!',
                    text: 'An error occurred while deleting the book.',
                    icon: 'error'
                });
            });
        }
        
        // Approve or reject book
        function updateBookStatus(bookId, status) {
            fetch('../AdminBookServlet?action=updateStatus&id=' + bookId + '&status=' + status, {
                method: 'POST'
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.text();
            })
            .then(text => {
                let data;
                try {
                    data = JSON.parse(text);
                } catch (e) {
                    // If the response is not JSON, create a default response
                    data = { success: text.includes('success'), message: text };
                }
                
                if (data.success) {
                    Swal.fire({
                        title: 'Updated!',
                        text: data.message || 'Book status has been updated successfully.',
                        icon: 'success'
                    }).then(() => {
                        window.location.reload();
                    });
                } else {
                    Swal.fire({
                        title: 'Error!',
                        text: data.message || 'An error occurred while updating the book status.',
                        icon: 'error'
                    });
                }
            })
            .catch(error => {
                console.error('Error:', error);
                Swal.fire({
                    title: 'Error!',
                    text: 'An error occurred while updating the book status.',
                    icon: 'error'
                });
            });
        }
    </script>
</body>
</html>
