<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="mode.User, mode.Book, dao.BookDAO, dao.ReviewDAO, mode.Review, java.util.List, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Details - E-Library Hub</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.19/dist/sweetalert2.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.19/dist/sweetalert2.all.min.js"></script>
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
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .page-title {
            font-size: 1.5rem;
        }
        
        .book-details-container {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
            margin-bottom: 20px;
        }
        
        .book-header {
            display: flex;
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .book-cover {
            flex: 0 0 200px;
        }
        
        .book-cover img {
            width: 100%;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow);
        }
        
        .book-info {
            flex: 1;
        }
        
        .book-title {
            font-size: 1.8rem;
            margin-bottom: 10px;
        }
        
        .book-meta {
            margin-bottom: 15px;
        }
        
        .book-meta p {
            margin: 5px 0;
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
        
        .book-actions {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }
        
        .book-description {
            margin-bottom: 20px;
        }
        
        .book-stats {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .stat-card {
            background-color: #f8f9fa;
            border-radius: var(--border-radius);
            padding: 15px;
            text-align: center;
        }
        
        .stat-value {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 5px;
        }
        
        .stat-label {
            color: var(--text-light);
            font-size: 0.9rem;
        }
        
        .book-tabs {
            display: flex;
            border-bottom: 1px solid var(--border-color);
            margin-bottom: 20px;
        }
        
        .book-tab {
            padding: 10px 20px;
            cursor: pointer;
            border-bottom: 2px solid transparent;
            transition: all 0.3s ease;
        }
        
        .book-tab.active {
            border-bottom-color: var(--primary-color);
            color: var(--primary-color);
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }
        
        .reviews-list {
            margin-top: 20px;
        }
        
        .review-item {
            border-bottom: 1px solid var(--border-color);
            padding: 15px 0;
        }
        
        .review-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }
        
        .reviewer-info {
            font-weight: 600;
        }
        
        .review-date {
            color: var(--text-light);
            font-size: 0.9rem;
        }
        
        .review-rating {
            color: gold;
            margin-bottom: 10px;
        }
        
        .review-content {
            margin-bottom: 10px;
        }
        
        .review-actions {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }
        
        @media (max-width: 992px) {
            .dashboard-container {
                grid-template-columns: 1fr;
            }
            
            .sidebar {
                display: none;
            }
            
            .book-header {
                flex-direction: column;
            }
            
            .book-cover {
                flex: 0 0 auto;
                max-width: 200px;
                margin: 0 auto 20px;
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
        
        // Get book ID from request parameter
        int bookId = 0;
        try {
            bookId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect("books.jsp?error=invalid_id");
            return;
        }
        
        // Get book details
        BookDAO bookDAO = new BookDAO();
        Book book = null;
        try {
            book = bookDAO.getBookById(bookId);
            if (book == null) {
                response.sendRedirect("books.jsp?error=book_not_found");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("books.jsp?error=database_error");
            return;
        }
        
        // Get book reviews
        ReviewDAO reviewDAO = new ReviewDAO();
        List<Review> reviews = null;
        try {
            reviews = reviewDAO.getReviewsByBook(bookId);
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // Format dates
        SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
        String uploadDate = dateFormat.format(book.getUploadDate());
        String publicationDate = dateFormat.format(book.getPublicationDate());
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
                <li><a href="dashboard.jsp" class="active"><i class="fas fa-book"></i> Books</a></li>
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
                <h1 class="page-title">Book Details</h1>
                <div>
                    <a href="dashboard.jsp" class="btn-secondary"><i class="fas fa-arrow-left"></i> Back to Dashboard</a>
                </div>
            </div>
            
            <div class="book-details-container">
                <div class="book-header">
                    <div class="book-cover">
                        <img src="<%= book.getCoverImagePath() %>" alt="<%= book.getTitle() %>">
                    </div>
                    <div class="book-info">
                        <h1 class="book-title"><%= book.getTitle() %></h1>
                        <div class="book-meta">
                            <p><strong>Author:</strong> <%= book.getAuthorName() %></p>
                            <p><strong>Category:</strong> <%= book.getCategoryName() %></p>
                            <p><strong>Publication Date:</strong> <%= publicationDate %></p>
                            <p><strong>Upload Date:</strong> <%= uploadDate %></p>
                            <p><strong>Language:</strong> <%= book.getLanguage() %></p>
                            <p><strong>Pages:</strong> <%= book.getPages() %></p>
                            <p><strong>Status:</strong> 
                                <% if (book.getStatus() == Book.Status.APPROVED) { %>
                                    <span class="status-badge approved">Approved</span>
                                <% } else if (book.getStatus() == Book.Status.PENDING) { %>
                                    <span class="status-badge pending">Pending</span>
                                <% } else { %>
                                    <span class="status-badge rejected">Rejected</span>
                                <% } %>
                            </p>
                        </div>
                        <div class="book-actions">
                            <a href="../DownloadServlet?id=<%= book.getBookId() %>" class="btn-primary"><i class="fas fa-download"></i> Download</a>
                            <a href="edit-book.jsp?id=<%= book.getBookId() %>" class="btn-secondary"><i class="fas fa-edit"></i> Edit</a>
                            <% if (book.getStatus() == Book.Status.PENDING) { %>
                                <button class="btn-success" onclick="approveBook(<%= book.getBookId() %>)"><i class="fas fa-check"></i> Approve</button>
                                <button class="btn-danger" onclick="rejectBook(<%= book.getBookId() %>)"><i class="fas fa-times"></i> Reject</button>
                            <% } %>
                            <button class="btn-danger" onclick="confirmDeleteBook(<%= book.getBookId() %>, '<%= book.getTitle() %>')"><i class="fas fa-trash"></i> Delete</button>
                        </div>
                    </div>
                </div>
                
                <div class="book-stats">
                    <div class="stat-card">
                        <div class="stat-value"><%= book.getViews() %></div>
                        <div class="stat-label">Views</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><%= book.getDownloads() %></div>
                        <div class="stat-label">Downloads</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value">
                            <% if (reviews != null && !reviews.isEmpty()) { %>
                                <%= String.format("%.1f", book.getRating()) %> <i class="fas fa-star"></i>
                            <% } else { %>
                                N/A
                            <% } %>
                        </div>
                        <div class="stat-label">Average Rating</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><%= reviews != null ? reviews.size() : 0 %></div>
                        <div class="stat-label">Reviews</div>
                    </div>
                </div>
                
                <div class="book-tabs">
                    <div class="book-tab active" data-tab="description">Description</div>
                    <div class="book-tab" data-tab="reviews">Reviews</div>
                    <div class="book-tab" data-tab="file-info">File Information</div>
                </div>
                
                <div class="tab-content active" id="description-tab">
                    <div class="book-description">
                        <h3>Book Description</h3>
                        <p><%= book.getDescription() %></p>
                    </div>
                </div>
                
                <div class="tab-content" id="reviews-tab">
                    <h3>Reviews</h3>
                    <div class="reviews-list">
                        <% if (reviews != null && !reviews.isEmpty()) {
                            for (Review review : reviews) {
                        %>
                        <div class="review-item">
                            <div class="review-header">
                                <div class="reviewer-info"><%= review.getUserName() %></div>
                                <div class="review-date"><%= dateFormat.format(review.getReviewDate()) %></div>
                            </div>
                            <div class="review-rating">
                                <% for (int i = 0; i < review.getRating(); i++) { %>
                                    <i class="fas fa-star"></i>
                                <% } %>
                                <% for (int i = (int)review.getRating(); i < 5; i++) { %>
                                    <i class="far fa-star"></i>
                                <% } %>
                            </div>
                            <div class="review-content">
                                <%= review.getComment() %>
                            </div>
                            <div class="review-actions">
                                <button class="btn-danger btn-sm" onclick="deleteReview(<%= review.getReviewId() %>)"><i class="fas fa-trash"></i> Delete</button>
                            </div>
                        </div>
                        <% 
                            }
                        } else { 
                        %>
                        <p>No reviews yet.</p>
                        <% } %>
                    </div>
                </div>
                
                <div class="tab-content" id="file-info-tab">
                    <h3>File Information</h3>
                    <div class="file-info">
                        <p><strong>File Path:</strong> <%= book.getFilePath() %></p>
                        <p><strong>Cover Image:</strong> <%= book.getCoverImagePath() %></p>
                        <% 
                        String fileSize = book.getFileSize();
                        if (fileSize == null) {
                            fileSize = "Unknown";
                        }
                        %>
                        <p><strong>File Size:</strong> <%= fileSize %></p>
                        <p><strong>Format:</strong> <%= book.getFilePath().substring(book.getFilePath().lastIndexOf(".") + 1).toUpperCase() %></p>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Mobile menu toggle
        document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
            document.querySelector('.main-nav').classList.toggle('active');
        });
        
        // Tabs functionality
        document.querySelectorAll('.book-tab').forEach(tab => {
            tab.addEventListener('click', function() {
                // Remove active class from all tabs and content
                document.querySelectorAll('.book-tab').forEach(t => t.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
                
                // Add active class to clicked tab and corresponding content
                this.classList.add('active');
                document.getElementById(this.dataset.tab + '-tab').classList.add('active');
            });
        });
        
        // Book actions
        function approveBook(bookId) {
            Swal.fire({
                title: 'Approve Book',
                text: 'Are you sure you want to approve this book?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#28a745',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Yes, approve it!'
            }).then((result) => {
                if (result.isConfirmed) {
                    fetch('../AdminBookServlet?action=approve&id=' + bookId, {
                        method: 'POST'
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            Swal.fire({
                                title: 'Approved!',
                                text: data.message,
                                icon: 'success'
                            }).then(() => {
                                window.location.reload();
                            });
                        } else {
                            Swal.fire({
                                title: 'Error!',
                                text: data.message,
                                icon: 'error'
                            });
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        Swal.fire({
                            title: 'Error!',
                            text: 'An error occurred while approving the book.',
                            icon: 'error'
                        });
                    });
                }
            });
        }
        
        function rejectBook(bookId) {
            Swal.fire({
                title: 'Reject Book',
                text: 'Are you sure you want to reject this book?',
                input: 'textarea',
                inputLabel: 'Reason for rejection (optional)',
                inputPlaceholder: 'Enter reason for rejection...',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#dc3545',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Yes, reject it!'
            }).then((result) => {
                if (result.isConfirmed) {
                    const reason = result.value || '';
                    
                    fetch('../AdminBookServlet?action=reject&id=' + bookId, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: 'reason=' + encodeURIComponent(reason)
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            Swal.fire({
                                title: 'Rejected!',
                                text: data.message,
                                icon: 'success'
                            }).then(() => {
                                window.location.reload();
                            });
                        } else {
                            Swal.fire({
                                title: 'Error!',
                                text: data.message,
                                icon: 'error'
                            });
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        Swal.fire({
                            title: 'Error!',
                            text: 'An error occurred while rejecting the book.',
                            icon: 'error'
                        });
                    });
                }
            });
        }
        
        function confirmDeleteBook(bookId, bookTitle) {
            Swal.fire({
                title: 'Delete Book',
                text: 'Are you sure you want to delete "' + bookTitle + '"? This action cannot be undone.',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#dc3545',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Yes, delete it!'
            }).then((result) => {
                if (result.isConfirmed) {
                    fetch('../AdminBookServlet?action=delete&id=' + bookId, {
                        method: 'POST'
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            Swal.fire({
                                title: 'Deleted!',
                                text: data.message,
                                icon: 'success'
                            }).then(() => {
                                window.location.href = 'dashboard.jsp';
                            });
                        } else {
                            Swal.fire({
                                title: 'Error!',
                                text: data.message,
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
            });
        }
        
        function deleteReview(reviewId) {
            Swal.fire({
                title: 'Delete Review',
                text: 'Are you sure you want to delete this review?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#dc3545',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Yes, delete it!'
            }).then((result) => {
                if (result.isConfirmed) {
                    fetch('../AdminReviewServlet?action=delete&id=' + reviewId, {
                        method: 'POST'
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            Swal.fire({
                                title: 'Deleted!',
                                text: data.message,
                                icon: 'success'
                            }).then(() => {
                                window.location.reload();
                            });
                        } else {
                            Swal.fire({
                                title: 'Error!',
                                text: data.message,
                                icon: 'error'
                            });
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        Swal.fire({
                            title: 'Error!',
                            text: 'An error occurred while deleting the review.',
                            icon: 'error'
                        });
                    });
                }
            });
        }
    </script>
</body>
</html>
