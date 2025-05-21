<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="mode.Book" %>
<%@ page import="mode.User" %>
<%@ page import="dao.UserBookDAO" %>
<%@ page import="dao.BookDAO" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Bookmarks - E-Library Hub</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="../css/styles.css">
    <style>
        .bookmark-card {
            transition: transform 0.3s ease;
            height: 100%;
        }
        .bookmark-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
        }
        .book-cover {
            height: 200px;
            object-fit: cover;
        }
        .bookmark-date {
            font-size: 0.8rem;
            color: #6c757d;
        }
        .empty-bookmarks {
            min-height: 300px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }
        .rating-stars {
            color: #ffc107;
        }
        .category-badge {
            background-color: #e9ecef;
            color: #495057;
            font-size: 0.8rem;
        }
        .sidebar {
            background-color: #f8f9fa;
            border-radius: 0.25rem;
        }
        .sidebar .nav-link {
            color: #495057;
            border-radius: 0;
            padding: 0.5rem 1rem;
        }
        .sidebar .nav-link:hover {
            background-color: #e9ecef;
        }
        .sidebar .nav-link.active {
            background-color: #0d6efd;
            color: white;
        }
        .sidebar .nav-link i {
            width: 20px;
            text-align: center;
            margin-right: 8px;
        }
        .footer {
            background-color: #343a40;
            color: #f8f9fa;
            padding: 2rem 0;
        }
        .footer a {
            color: #f8f9fa;
            text-decoration: none;
        }
        .footer a:hover {
            color: #0d6efd;
        }
        .footer-heading {
            font-size: 1.2rem;
            font-weight: 600;
            margin-bottom: 1rem;
        }
        .social-icons a {
            display: inline-block;
            width: 36px;
            height: 36px;
            background-color: rgba(255,255,255,0.1);
            border-radius: 50%;
            text-align: center;
            line-height: 36px;
            margin-right: 8px;
            transition: all 0.3s ease;
        }
        .social-icons a:hover {
            background-color: #0d6efd;
            transform: translateY(-3px);
        }
        .navbar-brand {
            font-weight: 700;
            font-size: 1.5rem;
        }
        .navbar {
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .search-form {
            width: 300px;
        }
        .notification-badge {
            position: absolute;
            top: 0;
            right: 0;
            font-size: 0.6rem;
        }
    </style>
</head>
<body>
    <%
        // Check if user is logged in
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            response.sendRedirect("../login.jsp");
            return;
        }
    %>
    
    <!-- Header/Navbar -->
    <nav class="navbar navbar-expand-lg navbar-light bg-white sticky-top">
        <div class="container">
            <a class="navbar-brand" href="../index.jsp">
                <i class="fas fa-book-open text-primary me-2"></i>E-Library Hub
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <div class="collapse navbar-collapse" id="navbarContent">
                <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                    <li class="nav-item">
                        <a class="nav-link" href="../index.jsp">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../catalog.jsp">Browse</a>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="categoriesDropdown" role="button" data-bs-toggle="dropdown">
                            Categories
                        </a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="../catalog.jsp?category=fiction">Fiction</a></li>
                            <li><a class="dropdown-item" href="../catalog.jsp?category=non-fiction">Non-Fiction</a></li>
                            <li><a class="dropdown-item" href="../catalog.jsp?category=science">Science</a></li>
                            <li><a class="dropdown-item" href="../catalog.jsp?category=technology">Technology</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="../categories.jsp">All Categories</a></li>
                        </ul>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../about.jsp">About</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="../contact.jsp">Contact</a>
                    </li>
                </ul>
                
                <form class="d-flex search-form me-3" action="../search.jsp" method="GET">
                    <div class="input-group">
                        <input class="form-control" type="search" name="query" placeholder="Search books..." aria-label="Search">
                        <button class="btn btn-outline-primary" type="submit">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </form>
                
                <div class="d-flex align-items-center">
                    <div class="dropdown">
                        <a href="#" class="position-relative me-3 text-dark" id="notificationsDropdown" data-bs-toggle="dropdown">
                            <i class="fas fa-bell fa-lg"></i>
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger notification-badge">
                                3
                            </span>
                        </a>
                        <div class="dropdown-menu dropdown-menu-end p-0" style="width: 320px;">
                            <div class="p-2 border-bottom d-flex justify-content-between align-items-center">
                                <h6 class="mb-0">Notifications</h6>
                                <a href="notifications.jsp" class="text-decoration-none small">View All</a>
                            </div>
                            <div class="notification-list" style="max-height: 300px; overflow-y: auto;">
                                <a href="#" class="dropdown-item p-2 border-bottom">
                                    <div class="d-flex">
                                        <div class="flex-shrink-0">
                                            <i class="fas fa-book-open text-primary"></i>
                                        </div>
                                        <div class="ms-2">
                                            <p class="mb-0 small">New book added to your favorite category</p>
                                            <small class="text-muted">2 hours ago</small>
                                        </div>
                                    </div>
                                </a>
                                <a href="#" class="dropdown-item p-2 border-bottom">
                                    <div class="d-flex">
                                        <div class="flex-shrink-0">
                                            <i class="fas fa-star text-warning"></i>
                                        </div>
                                        <div class="ms-2">
                                            <p class="mb-0 small">Your review was approved</p>
                                            <small class="text-muted">1 day ago</small>
                                        </div>
                                    </div>
                                </a>
                                <a href="#" class="dropdown-item p-2">
                                    <div class="d-flex">
                                        <div class="flex-shrink-0">
                                            <i class="fas fa-heart text-danger"></i>
                                        </div>
                                        <div class="ms-2">
                                            <p class="mb-0 small">Author published a new book</p>
                                            <small class="text-muted">3 days ago</small>
                                        </div>
                                    </div>
                                </a>
                            </div>
                        </div>
                    </div>
                    
                    <div class="dropdown">
                        <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                            <img src="../images/avatars/default-avatar.png" alt="User Avatar" width="32" height="32" class="rounded-circle me-2">
                            <span><%= currentUser.getFirstName() %></span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
                            <li><a class="dropdown-item" href="dashboard.jsp"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</a></li>
                            <li><a class="dropdown-item" href="profile.jsp"><i class="fas fa-user me-2"></i>My Profile</a></li>
                            <li><a class="dropdown-item" href="my-books.jsp"><i class="fas fa-book me-2"></i>My Books</a></li>
                            <li><a class="dropdown-item active" href="bookmarks.jsp"><i class="fas fa-bookmark me-2"></i>Bookmarks</a></li>
                            <li><a class="dropdown-item" href="reading-list.jsp"><i class="fas fa-list me-2"></i>Reading List</a></li>
                            <li><a class="dropdown-item" href="history.jsp"><i class="fas fa-history me-2"></i>History</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="settings.jsp"><i class="fas fa-cog me-2"></i>Settings</a></li>
                            <li><a class="dropdown-item" href="../logout.jsp"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </nav>
    
    <!-- Main Content -->
    <div class="container my-4">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-lg-3 mb-4">
                <div class="card sidebar">
                    <div class="card-body p-0">
                        <div class="p-3 border-bottom">
                            <div class="d-flex align-items-center">
                                <img src="../images/avatars/default-avatar.png" alt="User Avatar" width="50" height="50" class="rounded-circle me-3">
                                <div>
                                    <h6 class="mb-0"><%= currentUser.getFirstName() + " " + currentUser.getLastName() %></h6>
                                    <small class="text-muted">Reader</small>
                                </div>
                            </div>
                        </div>
                        <div class="list-group list-group-flush">
                            <a href="dashboard.jsp" class="list-group-item list-group-item-action">
                                <i class="fas fa-tachometer-alt me-2"></i> Dashboard
                            </a>
                            <a href="my-books.jsp" class="list-group-item list-group-item-action">
                                <i class="fas fa-book me-2"></i> My Books
                            </a>
                            <a href="bookmarks.jsp" class="list-group-item list-group-item-action active">
                                <i class="fas fa-bookmark me-2"></i> Bookmarks
                            </a>
                            <a href="reading-list.jsp" class="list-group-item list-group-item-action">
                                <i class="fas fa-list me-2"></i> Reading List
                            </a>
                            <a href="history.jsp" class="list-group-item list-group-item-action">
                                <i class="fas fa-history me-2"></i> Reading History
                            </a>
                            <a href="my-reviews.jsp" class="list-group-item list-group-item-action">
                                <i class="fas fa-star me-2"></i> My Reviews
                            </a>
                            <a href="profile.jsp" class="list-group-item list-group-item-action">
                                <i class="fas fa-user me-2"></i> Profile
                            </a>
                            <a href="settings.jsp" class="list-group-item list-group-item-action">
                                <i class="fas fa-cog me-2"></i> Settings
                            </a>
                        </div>
                    </div>
                </div>
                
                <div class="card mt-4">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0">Reading Stats</h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <h6 class="mb-2">Books Read</h6>
                            <div class="progress" style="height: 10px;">
                                <div class="progress-bar bg-success" role="progressbar" style="width: 65%"></div>
                            </div>
                            <small class="text-muted">13 of 20 books this year</small>
                        </div>
                        <div class="mb-3">
                            <h6 class="mb-2">Reading Goal</h6>
                            <div class="progress" style="height: 10px;">
                                <div class="progress-bar bg-info" role="progressbar" style="width: 40%"></div>
                            </div>
                            <small class="text-muted">8 of 20 hours this week</small>
                        </div>
                        <a href="statistics.jsp" class="btn btn-sm btn-outline-primary w-100">View All Stats</a>
                    </div>
                </div>
            </div>
            
            <!-- Main Content -->
            <div class="col-lg-9">
                <div class="card shadow-sm">
                    <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center">
                        <h5 class="mb-0"><i class="fas fa-bookmark me-2"></i> My Bookmarks</h5>
                        <div>
                            <button class="btn btn-sm btn-light" id="gridViewBtn" title="Grid View">
                                <i class="fas fa-th"></i>
                            </button>
                            <button class="btn btn-sm btn-outline-light" id="listViewBtn" title="List View">
                                <i class="fas fa-list"></i>
                            </button>
                        </div>
                    </div>
                    <div class="card-body">
                        <%
                            UserBookDAO userBookDAO = new UserBookDAO();
                            List<Book> bookmarkedBooks = userBookDAO.getBookmarkedBooks(currentUser.getUserId());
                            
                            SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
                        %>
                        
                        <% if (bookmarkedBooks.isEmpty()) { %>
                            <div class="empty-bookmarks text-center">
                                <i class="fas fa-bookmark fa-4x text-muted mb-3"></i>
                                <h4 class="text-muted">No Bookmarked Books</h4>
                                <p class="text-muted">You haven't bookmarked any books yet.</p>
                                <a href="../catalog.jsp" class="btn btn-primary mt-2">
                                    <i class="fas fa-search me-1"></i> Browse Books
                                </a>
                            </div>
                        <% } else { %>
                            <div class="row" id="bookmarksGrid">
                                <% for (Book book : bookmarkedBooks) { %>
                                    <div class="col-md-4 mb-4">
                                        <div class="card bookmark-card h-100">
                                            <img src="<%= book.getCoverImagePath() != null ? book.getCoverImagePath() : "../images/default-cover.jpg" %>" class="card-img-top book-cover" alt="<%= book.getTitle() %>">
                                            <div class="card-body d-flex flex-column">
                                                <h5 class="card-title text-truncate"><%= book.getTitle() %></h5>
                                                <p class="card-text text-muted mb-1">by <%= book.getAuthorName() %></p>
                                                <div class="mb-2">
                                                    <span class="badge category-badge"><%= book.getCategoryName() %></span>
                                                </div>
                                                <div class="rating-stars mb-2">
                                                    <% 
                                                        double rating = book.getRating();
                                                        for (int i = 1; i <= 5; i++) {
                                                            if (i <= rating) {
                                                    %>
                                                        <i class="fas fa-star"></i>
                                                    <% } else if (i - 0.5 <= rating) { %>
                                                        <i class="fas fa-star-half-alt"></i>
                                                    <% } else { %>
                                                        <i class="far fa-star"></i>
                                                    <% } } %>
                                                    <small class="text-muted ms-1">(<%= String.format("%.1f", rating) %>)</small>
                                                </div>
                                                <div class="mt-auto">
                                                    <a href="../book-details.jsp?id=<%= book.getBookId() %>" class="btn btn-sm btn-outline-primary w-100 mb-2">
                                                        <i class="fas fa-info-circle me-1"></i> Details
                                                    </a>
                                                    <a href="../reader.jsp?id=<%= book.getBookId() %>" class="btn btn-sm btn-primary w-100">
                                                        <i class="fas fa-book-reader me-1"></i> Read Now
                                                    </a>
                                                </div>
                                            </div>
                                            <div class="card-footer bg-white">
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <button class="btn btn-sm btn-danger remove-bookmark" data-book-id="<%= book.getBookId() %>">
                                                        <i class="fas fa-bookmark me-1"></i> Remove
                                                    </button>
                                                    <% 
                                                        int progress = userBookDAO.getReadingProgress(currentUser.getUserId(), book.getBookId());
                                                        if (progress > 0) {
                                                    %>
                                                    <div class="progress" style="width: 60%; height: 10px;" title="<%= progress %>% completed">
                                                        <div class="progress-bar bg-success" role="progressbar" style="width: <%= progress %>%"></div>
                                                    </div>
                                                    <% } %>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                            
                            <div class="d-none" id="bookmarksList">
                                <div class="table-responsive">
                                    <table class="table table-hover">
                                        <thead>
                                            <tr>
                                                <th>Book</th>
                                                <th>Author</th>
                                                <th>Category</th>
                                                <th>Rating</th>
                                                <th>Progress</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for (Book book : bookmarkedBooks) { %>
                                                <tr>
                                                    <td>
                                                        <div class="d-flex align-items-center">
                                                            <img src="<%= book.getCoverImagePath() != null ? book.getCoverImagePath() : "../images/default-cover.jpg" %>" alt="<%= book.getTitle() %>" class="me-2" style="width: 40px; height: 60px; object-fit: cover;">
                                                            <a href="../book-details.jsp?id=<%= book.getBookId() %>"><%= book.getTitle() %></a>
                                                        </div>
                                                    </td>
                                                    <td><%= book.getAuthorName() %></td>
                                                    <td><span class="badge category-badge"><%= book.getCategoryName() %></span></td>
                                                    <td>
                                                        <div class="rating-stars">
                                                            <% 
                                                                double rating = book.getRating();
                                                                for (int i = 1; i <= 5; i++) {
                                                                    if (i <= rating) {
                                                            %>
                                                                <i class="fas fa-star"></i>
                                                            <% } else if (i - 0.5 <= rating) { %>
                                                                <i class="fas fa-star-half-alt"></i>
                                                            <% } else { %>
                                                                <i class="far fa-star"></i>
                                                            <% } } %>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <% 
                                                            int progress = userBookDAO.getReadingProgress(currentUser.getUserId(), book.getBookId());
                                                        %>
                                                        <div class="progress" style="height: 10px;" title="<%= progress %>% completed">
                                                            <div class="progress-bar bg-success" role="progressbar" style="width: <%= progress %>%"></div>
                                                        </div>
                                                        <small class="text-muted"><%= progress %>%</small>
                                                    </td>
                                                    <td>
                                                        <div class="btn-group">
                                                            <a href="../reader.jsp?id=<%= book.getBookId() %>" class="btn btn-sm btn-primary">
                                                                <i class="fas fa-book-reader"></i>
                                                            </a>
                                                            <button class="btn btn-sm btn-danger remove-bookmark" data-book-id="<%= book.getBookId() %>">
                                                                <i class="fas fa-bookmark"></i>
                                                            </button>
                                                        </div>
                                                    </td>
                                                </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Footer -->
    <footer class="footer mt-5">
        <div class="container">
            <div class="row">
                <div class="col-lg-3 col-md-6 mb-4 mb-md-0">
                    <h5 class="footer-heading">E-Library Hub</h5>
                    <p class="text-muted">Your digital gateway to a world of knowledge and literary adventures.</p>
                    <div class="social-icons mt-3">
                        <a href="#"><i class="fab fa-facebook-f"></i></a>
                        <a href="#"><i class="fab fa-twitter"></i></a>
                        <a href="#"><i class="fab fa-instagram"></i></a>
                        <a href="#"><i class="fab fa-linkedin-in"></i></a>
                    </div>
                </div>
                
                <div class="col-lg-3 col-md-6 mb-4 mb-md-0">
                    <h5 class="footer-heading">Quick Links</h5>
                    <ul class="list-unstyled">
                        <li class="mb-2"><a href="../index.jsp"><i class="fas fa-home me-2"></i>Home</a></li>
                        <li class="mb-2"><a href="../catalog.jsp"><i class="fas fa-book me-2"></i>Browse Books</a></li>
                        <li class="mb-2"><a href="../categories.jsp"><i class="fas fa-list me-2"></i>Categories</a></li>
                        <li class="mb-2"><a href="../authors.jsp"><i class="fas fa-user-edit me-2"></i>Authors</a></li>
                        <li class="mb-2"><a href="../about.jsp"><i class="fas fa-info-circle me-2"></i>About Us</a></li>
                    </ul>
                </div>
                
                <div class="col-lg-3 col-md-6 mb-4 mb-md-0">
                    <h5 class="footer-heading">User Links</h5>
                    <ul class="list-unstyled">
                        <li class="mb-2"><a href="dashboard.jsp"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</a></li>
                        <li class="mb-2"><a href="bookmarks.jsp"><i class="fas fa-bookmark me-2"></i>Bookmarks</a></li>
                        <li class="mb-2"><a href="reading-list.jsp"><i class="fas fa-list me-2"></i>Reading List</a></li>
                        <li class="mb-2"><a href="history.jsp"><i class="fas fa-history me-2"></i>History</a></li>
                        <li class="mb-2"><a href="settings.jsp"><i class="fas fa-cog me-2"></i>Settings</a></li>
                    </ul>
                </div>
                
                <div class="col-lg-3 col-md-6 mb-4 mb-md-0">
                    <h5 class="footer-heading">Contact Us</h5>
                    <ul class="list-unstyled">
                        <li class="mb-2"><i class="fas fa-map-marker-alt me-2"></i>123 Library Street, Booktown</li>
                        <li class="mb-2"><i class="fas fa-phone me-2"></i>(123) 456-7890</li>
                        <li class="mb-2"><i class="fas fa-envelope me-2"></i>contact@elibraryhub.com</li>
                    </ul>
                    <div class="mt-3">
                        <a href="../contact.jsp" class="btn btn-outline-light btn-sm">Send Message</a>
                    </div>
                </div>
            </div>
            
            <hr class="my-4 bg-light">
            
            <div class="row align-items-center">
                <div class="col-md-6 text-center text-md-start">
                    <p class="mb-0">&copy; 2023 E-Library Hub. All rights reserved.</p>
                </div>
                <div class="col-md-6 text-center text-md-end">
                    <ul class="list-inline mb-0">
                        <li class="list-inline-item"><a href="../terms.jsp">Terms of Service</a></li>
                        <li class="list-inline-item">•</li>
                        <li class="list-inline-item"><a href="../privacy.jsp">Privacy Policy</a></li>
                        <li class="list-inline-item">•</li>
                        <li class="list-inline-item"><a href="../faq.jsp">FAQ</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </footer>
    
    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <script>
        $(document).ready(function() {
            // Toggle between grid and list view
            $('#gridViewBtn').click(function() {
                $(this).removeClass('btn-outline-light').addClass('btn-light');
                $('#listViewBtn').removeClass('btn-light').addClass('btn-outline-light');
                $('#bookmarksGrid').removeClass('d-none');
                $('#bookmarksList').addClass('d-none');
            });
            
            $('#listViewBtn').click(function() {
                $(this).removeClass('btn-outline-light').addClass('btn-light');
                $('#gridViewBtn').removeClass('btn-light').addClass('btn-outline-light');
                $('#bookmarksList').removeClass('d-none');
                $('#bookmarksGrid').addClass('d-none');
            });
            
            // Remove bookmark functionality
            $('.remove-bookmark').click(function() {
                const bookId = $(this).data('book-id');
                const bookElement = $(this).closest('.col-md-4, tr');
                
                if (confirm('Are you sure you want to remove this bookmark?')) {
                    $.ajax({
                        url: '../UserBookServlet',
                        type: 'POST',
                        data: {
                            action: 'toggleBookmark',
                            bookId: bookId,
                            userId: <%= currentUser.getUserId() %>
                        },
                        success: function(response) {
                            try {
                                const result = JSON.parse(response);
                                if (result.success) {
                                    bookElement.fadeOut(300, function() {
                                        $(this).remove();
                                        
                                        // Check if there are no more bookmarks
                                        if ($('#bookmarksGrid .col-md-4').length === 0) {
                                            location.reload(); // Reload to show empty state
                                        }
                                    });
                                } else {
                                    alert('Error: ' + result.message);
                                }
                            } catch (e) {
                                console.error('Error parsing JSON response:', e);
                            }
                        },
                        error: function(xhr, status, error) {
                            alert('An error occurred while removing the bookmark. Please try again.');
                            console.error(error);
                        }
                    });
                }
            });
        });
    </script>
</body>
</html>
