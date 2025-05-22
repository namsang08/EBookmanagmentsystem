<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.BookDAO, dao.ReviewDAO, dao.UserDAO, dao.CategoryDAO, mode.Book, mode.Review, mode.User, java.util.List, java.util.Date, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Details | E-Library</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="css/styles.css">
    <style>
        :root {
            --primary: #4f46e5;
            --primary-dark: #4338ca;
            --secondary: #6b7280;
            --success: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --info: #3b82f6;
            --light: #f9fafb;
            --dark: #111827;
            --gray-100: #f3f4f6;
            --gray-200: #e5e7eb;
            --gray-300: #d1d5db;
            --gray-400: #9ca3af;
            --gray-500: #6b7280;
            --gray-600: #4b5563;
            --gray-700: #374151;
            --gray-800: #1f2937;
            --gray-900: #111827;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--light);
            color: var(--gray-800);
            line-height: 1.6;
        }
        
        .navbar {
            background-color: white;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .navbar-brand {
            font-weight: 700;
            color: var(--primary);
        }
        
        .nav-link {
            color: var(--gray-600);
            font-weight: 500;
            padding: 0.5rem 1rem;
        }
        
        .nav-link:hover, .nav-link.active {
            color: var(--primary);
        }
        
        .btn-primary {
            background-color: var(--primary);
            border-color: var(--primary);
        }
        
        .btn-primary:hover {
            background-color: var(--primary-dark);
            border-color: var(--primary-dark);
        }
        
        .btn-outline-primary {
            color: var(--primary);
            border-color: var(--primary);
        }
        
        .btn-outline-primary:hover {
            background-color: var(--primary);
            border-color: var(--primary);
            color: white;
        }
        
        .container {
            max-width: 1200px;
        }
        
        .breadcrumb {
            background-color: transparent;
            padding: 0;
            margin-bottom: 1.5rem;
        }
        
        .breadcrumb-item a {
            color: var(--primary);
            text-decoration: none;
        }
        
        .breadcrumb-item.active {
            color: var(--gray-600);
        }
        
        .book-cover {
            width: 100%;
            border-radius: 8px;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }
        
        .book-title {
            font-size: 2rem;
            font-weight: 700;
            color: var(--gray-900);
            margin-bottom: 0.5rem;
        }
        
        .book-author {
            font-size: 1.25rem;
            color: var(--gray-700);
            margin-bottom: 1rem;
        }
        
        .book-author a {
            color: var(--primary);
            text-decoration: none;
        }
        
        .book-author a:hover {
            text-decoration: underline;
        }
        
        .badge {
            font-weight: 500;
            padding: 0.5rem 1rem;
            border-radius: 9999px;
            font-size: 0.875rem;
        }
        
        .badge-category {
            background-color: #e0e7ff;
            color: var(--primary);
        }
        
        .badge-status-approved {
            background-color: #d1fae5;
            color: var(--success);
        }
        
        .badge-status-pending {
            background-color: #fef3c7;
            color: var(--warning);
        }
        
        .badge-status-rejected {
            background-color: #fee2e2;
            color: var(--danger);
        }
        
        .stars {
            color: var(--warning);
            font-size: 1.25rem;
        }
        
        .rating-count {
            color: var(--gray-500);
            font-size: 0.875rem;
        }
        
        .book-meta {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 1rem;
            margin: 1.5rem 0;
        }
        
        .meta-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--gray-700);
        }
        
        .meta-item i {
            color: var(--primary);
            width: 20px;
            text-align: center;
        }
        
        .action-buttons {
            display: flex;
            flex-wrap: wrap;
            gap: 0.75rem;
            margin: 1.5rem 0;
        }
        
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1.5rem;
            font-weight: 500;
            border-radius: 0.375rem;
        }
        
        .btn-lg {
            padding: 0.75rem 2rem;
            font-size: 1.125rem;
        }
        
        .section-title {
            font-size: 1.5rem;
            font-weight: 600;
            color: var(--gray-900);
            margin-bottom: 1.5rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid var(--gray-200);
        }
        
        .tags {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
        }
        
        .tag {
            background-color: var(--gray-200);
            color: var(--gray-700);
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-size: 0.875rem;
            text-decoration: none;
            transition: background-color 0.2s ease-in-out;
        }
        
        .tag:hover {
            background-color: var(--gray-300);
        }
        
        .book-description {
            line-height: 1.8;
            color: var(--gray-700);
            margin-bottom: 2rem;
        }
        
        .card {
            border: none;
            border-radius: 0.5rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
            height: 100%;
        }
        
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }
        
        .card-img-top {
            height: 250px;
            object-fit: cover;
            border-top-left-radius: 0.5rem;
            border-top-right-radius: 0.5rem;
        }
        
        .card-body {
            padding: 1.5rem;
        }
        
        .card-title {
            font-weight: 600;
            color: var(--gray-900);
            margin-bottom: 0.5rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        .card-text {
            color: var(--gray-600);
            font-size: 0.875rem;
            margin-bottom: 1rem;
        }
        
        .review {
            background-color: white;
            border-radius: 0.5rem;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .review-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
        }
        
        .reviewer {
            font-weight: 600;
            color: var(--gray-900);
        }
        
        .review-date {
            color: var(--gray-500);
            font-size: 0.875rem;
        }
        
        .review-rating {
            margin-bottom: 0.5rem;
        }
        
        .review-content {
            color: var(--gray-700);
        }
        
        .progress-container {
            background-color: white;
            border-radius: 0.5rem;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .progress-bar-container {
            height: 8px;
            background-color: var(--gray-200);
            border-radius: 9999px;
            margin: 1rem 0;
            overflow: hidden;
        }
        
        .progress-bar {
            height: 100%;
            background-color: var(--primary);
            border-radius: 9999px;
        }
        
        .progress-stats {
            display: flex;
            justify-content: space-between;
            font-size: 0.875rem;
            color: var(--gray-500);
        }
        
        .social-share {
            display: flex;
            gap: 0.75rem;
            margin-top: 1rem;
        }
        
        .share-button {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            text-decoration: none;
            transition: transform 0.2s ease-in-out;
        }
        
        .share-button:hover {
            transform: scale(1.1);
        }
        
        .share-facebook {
            background-color: #1877f2;
        }
        
        .share-twitter {
            background-color: #1da1f2;
        }
        
        .share-linkedin {
            background-color: #0077b5;
        }
        
        .share-email {
            background-color: #ea4335;
        }
        
        .btn-bookmark {
            transition: transform 0.2s ease;
        }
        
        .btn-bookmark:active {
            transform: scale(1.2);
        }
        
        .btn-bookmark.active i {
            color: var(--danger);
        }
        
        .rating-input {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 1rem;
        }
        
        .rating-input label {
            cursor: pointer;
            font-size: 1.5rem;
            color: var(--gray-300);
        }
        
        .rating-input input {
            display: none;
        }
        
        .rating-input label.active {
            color: var(--warning);
        }
        
        footer {
            background-color: white;
            padding: 3rem 0;
            margin-top: 3rem;
            border-top: 1px solid var(--gray-200);
        }
        
        .footer-title {
            font-weight: 700;
            margin-bottom: 1rem;
            color: var(--gray-900);
        }
        
        .footer-links {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        
        .footer-link {
            margin-bottom: 0.5rem;
        }
        
        .footer-link a {
            color: var(--gray-600);
            text-decoration: none;
            transition: color 0.2s ease-in-out;
        }
        
        .footer-link a:hover {
            color: var(--primary);
        }
        
        .footer-bottom {
            border-top: 1px solid var(--gray-200);
            padding-top: 1.5rem;
            margin-top: 1.5rem;
            text-align: center;
            color: var(--gray-500);
        }
        
        @media (max-width: 768px) {
            .book-meta {
                grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .action-buttons .btn {
                width: 100%;
            }
        }
        
        /* Toast notification styles */
        .toast-container {
            position: fixed;
            bottom: 20px;
            right: 20px;
            z-index: 1000;
        }
        
        .toast {
            background-color: white;
            color: var(--gray-800);
            border-radius: 0.5rem;
            padding: 1rem;
            margin-bottom: 0.75rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            display: flex;
            align-items: center;
            gap: 0.75rem;
            min-width: 300px;
            max-width: 400px;
            animation: slideIn 0.3s ease-out forwards;
        }
        
        .toast.success {
            border-left: 4px solid var(--success);
        }
        
        .toast.error {
            border-left: 4px solid var(--danger);
        }
        
        .toast-icon {
            width: 24px;
            height: 24px;
            flex-shrink: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
        }
        
        .toast.success .toast-icon {
            background-color: rgba(16, 185, 129, 0.1);
            color: var(--success);
        }
        
        .toast.error .toast-icon {
            background-color: rgba(239, 68, 68, 0.1);
            color: var(--danger);
        }
        
        .toast-content {
            flex: 1;
        }
        
        .toast-title {
            font-weight: 600;
            margin-bottom: 0.25rem;
        }
        
        .toast-message {
            font-size: 0.875rem;
            color: var(--gray-600);
        }
        
        .toast-close {
            background: none;
            border: none;
            color: var(--gray-400);
            cursor: pointer;
            padding: 0;
            font-size: 1.25rem;
            line-height: 1;
        }
        
        .toast-close:hover {
            color: var(--gray-600);
        }
        
        @keyframes slideIn {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        
        @keyframes slideOut {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(100%);
                opacity: 0;
            }
        }
    </style>
</head>
<body>
    <%
        // Get book ID from request parameter
        int bookId = 0;
        try {
            bookId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        // Initialize DAOs
        BookDAO bookDAO = new BookDAO();
        ReviewDAO reviewDAO = new ReviewDAO();
        UserDAO userDAO = new UserDAO();
        CategoryDAO categoryDAO = new CategoryDAO();
        
        // Get book details
        Book book = bookDAO.getBookById(bookId);
        if (book == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        
        // Increment view count
        bookDAO.incrementViews(bookId);
        
        // Get reviews for this book
        List<Review> reviews = reviewDAO.getReviewsByBook(bookId);
        
        // Get average rating
        double averageRating = reviewDAO.getAverageRatingForBook(bookId);
        
        // Get related books
        List<Book> relatedBooks = bookDAO.getRelatedBooks(bookId, book.getCategoryId(), book.getAuthorId(), 4);
        
        // Check if user is logged in
        User currentUser = null;
        boolean isLoggedIn = false;
        boolean hasReviewed = false;
        boolean isBookmarked = false;
        String readingStatus = null;
        int readingProgress = 0;
        
        Object userObj = session.getAttribute("user");
        if (userObj != null && userObj instanceof User) {
            currentUser = (User) userObj;
            isLoggedIn = true;
            
            // Check if user has already reviewed this book
            hasReviewed = reviewDAO.hasUserReviewedBook(currentUser.getUserId(), bookId);
            
            // Check if book is bookmarked
            isBookmarked = bookDAO.isBookmarked(currentUser.getUserId(), bookId);
            
            // Get reading status and progress
            readingStatus = bookDAO.getReadingStatus(currentUser.getUserId(), bookId);
            readingProgress = bookDAO.getReadingProgress(currentUser.getUserId(), bookId);
        }
        
        // Format dates
        SimpleDateFormat dateFormat = new SimpleDateFormat("MMMM d, yyyy");
        String publicationDate = book.getPublicationDate() != null ? dateFormat.format(book.getPublicationDate()) : "Unknown";
        String uploadDate = book.getUploadDate() != null ? dateFormat.format(book.getUploadDate()) : "Unknown";
    %>

    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-light sticky-top">
        <div class="container">
            <a class="navbar-brand" href="index.jsp">E-Library</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="index.jsp">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="catalog.jsp">Browse</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="about.jsp">About</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="contact.jsp">Contact</a>
                    </li>
                </ul>
                <div class="d-flex">
                    <% if (isLoggedIn) { %>
                        <div class="dropdown">
                            <button class="btn btn-outline-primary dropdown-toggle" type="button" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-user me-1"></i> <%= currentUser.getFirstName() %>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
                                <li><a class="dropdown-item" href="user/dashboard.jsp"><i class="fas fa-tachometer-alt me-2"></i> Dashboard</a></li>
                                <li><a class="dropdown-item" href="user/profile.jsp"><i class="fas fa-user-circle me-2"></i> Profile</a></li>
                                <li><a class="dropdown-item" href="user/my-books.jsp"><i class="fas fa-book me-2"></i> My Books</a></li>
                                <li><a class="dropdown-item" href="user/bookmarks.jsp"><i class="fas fa-bookmark me-2"></i> Bookmarks</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="logout.jsp"><i class="fas fa-sign-out-alt me-2"></i> Logout</a></li>
                            </ul>
                        </div>
                    <% } else { %>
                        <a href="login.jsp" class="btn btn-outline-primary me-2">Login</a>
                        <a href="register.jsp" class="btn btn-primary">Register</a>
                    <% } %>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main class="container py-5">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="index.jsp">Home</a></li>
                <li class="breadcrumb-item"><a href="catalog.jsp">Books</a></li>
                <li class="breadcrumb-item"><a href="catalog.jsp?category=<%= book.getCategoryId() %>"><%= book.getCategoryName() %></a></li>
                <li class="breadcrumb-item active" aria-current="page"><%= book.getTitle() %></li>
            </ol>
        </nav>

        <!-- Book Details -->
        <div class="row g-5">
            <!-- Left Column - Book Cover and Actions -->
            <div class="col-md-4">
                <img src="<%= book.getCoverImagePath() != null ? book.getCoverImagePath() : "images/default-cover.jpg" %>" alt="<%= book.getTitle() %>" class="book-cover mb-4">
                
                <div class="d-grid gap-2 mb-4">
                    <% if (isLoggedIn) { %>
                        <button id="bookmarkBtn" class="btn btn-outline-primary btn-bookmark <%= isBookmarked ? "active" : "" %>" onclick="toggleBookmark(<%= book.getBookId() %>)">
                            <i class="<%= isBookmarked ? "fas" : "far" %> fa-heart"></i> 
                            <span><%= isBookmarked ? "Bookmarked" : "Add to Bookmarks" %></span>
                        </button>
                        
                        <div class="dropdown">
                            <button class="btn btn-outline-primary dropdown-toggle w-100" type="button" id="readingListDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-list"></i> Add to Reading List
                            </button>
                            <ul class="dropdown-menu w-100" aria-labelledby="readingListDropdown">
                                <li><a class="dropdown-item" href="javascript:void(0)" onclick="updateReadingStatus(<%= book.getBookId() %>, 'READING', 0)">
                                    <i class="fas fa-book-open me-2"></i> Currently Reading
                                </a></li>
                                <li><a class="dropdown-item" href="javascript:void(0)" onclick="updateReadingStatus(<%= book.getBookId() %>, 'TO_READ', 0)">
                                    <i class="fas fa-clock me-2"></i> Want to Read
                                </a></li>
                                <li><a class="dropdown-item" href="javascript:void(0)" onclick="updateReadingStatus(<%= book.getBookId() %>, 'FINISHED', 100)">
                                    <i class="fas fa-check me-2"></i> Finished Reading
                                </a></li>
                            </ul>
                        </div>
                    <% } else { %>
                        <a href="login.jsp?redirect=bookdetails.jsp?id=<%= book.getBookId() %>" class="btn btn-outline-primary">
                            <i class="far fa-heart"></i> Add to Bookmarks
                        </a>
                        <a href="login.jsp?redirect=bookdetails.jsp?id=<%= book.getBookId() %>" class="btn btn-outline-primary">
                            <i class="fas fa-list"></i> Add to Reading List
                        </a>
                    <% } %>
                </div>
                
                <div class="card mb-4">
                    <div class="card-body">
                        <h5 class="card-title">Share this book</h5>
                        <div class="social-share">
                            <a href="https://www.facebook.com/sharer/sharer.php?u=<%= request.getRequestURL().toString() %>?id=<%= book.getBookId() %>" target="_blank" class="share-button share-facebook">
                                <i class="fab fa-facebook-f"></i>
                            </a>
                            <a href="https://twitter.com/intent/tweet?text=Check out this book: <%= book.getTitle() %>&url=<%= request.getRequestURL().toString() %>?id=<%= book.getBookId() %>" target="_blank" class="share-button share-twitter">
                                <i class="fab fa-twitter"></i>
                            </a>
                            <a href="https://www.linkedin.com/shareArticle?mini=true&url=<%= request.getRequestURL().toString() %>?id=<%= book.getBookId() %>&title=<%= book.getTitle() %>" target="_blank" class="share-button share-linkedin">
                                <i class="fab fa-linkedin-in"></i>
                            </a>
                            <a href="mailto:?subject=Check out this book: <%= book.getTitle() %>&body=I found this interesting book: <%= request.getRequestURL().toString() %>?id=<%= book.getBookId() %>" class="share-button share-email">
                                <i class="fas fa-envelope"></i>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Right Column - Book Info -->
            <div class="col-md-8">
                <h1 class="book-title"><%= book.getTitle() %></h1>
                <p class="book-author">By <a href="author.jsp?id=<%= book.getAuthorId() %>"><%= book.getAuthorName() %></a></p>
                
                <div class="d-flex align-items-center mb-3">
                    <span class="badge badge-category me-2"><%= book.getCategoryName() %></span>
                    <% if (book.getStatus() == Book.Status.APPROVED) { %>
                        <span class="badge badge-status-approved">Approved</span>
                    <% } else if (book.getStatus() == Book.Status.PENDING) { %>
                        <span class="badge badge-status-pending">Pending</span>
                    <% } else { %>
                        <span class="badge badge-status-rejected">Rejected</span>
                    <% } %>
                </div>
                
                <div class="d-flex align-items-center mb-3">
                    <div class="stars me-2">
                        <% for (int i = 1; i <= 5; i++) { %>
                            <% if (i <= averageRating) { %>
                                <i class="fas fa-star"></i>
                            <% } else if (i - 0.5 <= averageRating) { %>
                                <i class="fas fa-star-half-alt"></i>
                            <% } else { %>
                                <i class="far fa-star"></i>
                            <% } %>
                        <% } %>
                    </div>
                    <span class="rating-count"><%= String.format("%.1f", averageRating) %> (<%= reviews.size() %> reviews)</span>
                </div>
                
                <div class="book-meta">
                    <div class="meta-item">
                        <i class="fas fa-calendar-alt"></i>
                        <span>Published: <%= publicationDate %></span>
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-language"></i>
                        <span>Language: <%= book.getLanguage() %></span>
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-file-alt"></i>
                        <span>Pages: <%= book.getPages() %></span>
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-eye"></i>
                        <span>Views: <%= book.getViews() %></span>
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-download"></i>
                        <span>Downloads: <%= book.getDownloads() %></span>
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-upload"></i>
                        <span>Added: <%= uploadDate %></span>
                    </div>
                </div>
                
                <% if (book.getTags() != null && !book.getTags().isEmpty()) { %>
                    <div class="tags">
                        <% for (String tag : book.getTags().split(",")) { %>
                            <a href="catalog.jsp?tag=<%= tag.trim() %>" class="tag"><%= tag.trim() %></a>
                        <% } %>
                    </div>
                <% } %>
                
                <% if (isLoggedIn && "READING".equals(readingStatus)) { %>
                    <div class="progress-container">
                        <h5>Your Reading Progress</h5>
                        <div class="progress-bar-container">
                            <div class="progress-bar" style="width: <%= readingProgress %>%;"></div>
                        </div>
                        <div class="progress-stats">
                            <span><%= readingProgress %>% complete</span>
                            <span>Estimated time to finish: <%= book.getFormattedEstimatedTime() %></span>
                        </div>
                        <div class="mt-3">
                            <button class="btn btn-sm btn-primary" onclick="updateProgress(<%= book.getBookId() %>)">
                                Update Progress
                            </button>
                        </div>
                    </div>
                <% } %>
                
                <div class="book-description">
                    <h3 class="section-title">Description</h3>
                    <p><%= book.getDescription() %></p>
                </div>
                
                <!-- Reviews Section -->
                <div class="reviews-section">
                    <h3 class="section-title">Reviews</h3>
                    
                    <% if (reviews.isEmpty()) { %>
                        <div class="alert alert-info">
                            <i class="fas fa-info-circle me-2"></i> No reviews yet. Be the first to review this book!
                        </div>
                    <% } else { %>
                        <div class="reviews-container mb-4">
                            <% for (Review review : reviews) { %>
                                <div class="review">
                                    <div class="review-header">
                                        <span class="reviewer"><%= review.getUserName() %></span>
                                        <span class="review-date"><%= dateFormat.format(review.getReviewDate()) %></span>
                                    </div>
                                    <div class="review-rating">
                                        <div class="stars">
                                            <% for (int i = 1; i <= 5; i++) { %>
                                                <i class="<%= i <= review.getRating() ? "fas" : "far" %> fa-star"></i>
                                            <% } %>
                                        </div>
                                    </div>
                                    <div class="review-content">
                                        <%= review.getComment() %>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                    
                    <% if (isLoggedIn && !hasReviewed) { %>
                        <div class="card mb-4">
                            <div class="card-body">
                                <h4 class="card-title">Write a Review</h4>
                                <form id="reviewForm" action="ReviewServlet" method="post">
                                    <input type="hidden" name="bookId" value="<%= book.getBookId() %>">
                                    <input type="hidden" name="userId" value="<%= currentUser.getUserId() %>">
                                    
                                    <div class="mb-3">
                                        <label class="form-label">Rating</label>
                                        <div class="rating-input">
                                            <% for (int i = 1; i <= 5; i++) { %>
                                                <label for="star<%= i %>" class="<%= i == 5 ? "active" : "" %>">
                                                    <i class="<%= i == 5 ? "fas" : "far" %> fa-star"></i>
                                                    <input type="radio" name="rating" id="star<%= i %>" value="<%= i %>" <%= i == 5 ? "checked" : "" %>>
                                                </label>
                                            <% } %>
                                        </div>
                                    </div>
                                    
                                    <div class="mb-3">
                                        <label for="comment" class="form-label">Your Review</label>
                                        <textarea id="comment" name="comment" class="form-control" rows="4" required></textarea>
                                    </div>
                                    
                                    <button type="submit" class="btn btn-primary">Submit Review</button>
                                </form>
                            </div>
                        </div>
                    <% } else if (!isLoggedIn) { %>
                        <div class="alert alert-warning">
                            <i class="fas fa-user-lock me-2"></i> Please <a href="login.jsp">login</a> to write a review.
                        </div>
                    <% } else { %>
                        <div class="alert alert-info">
                            <i class="fas fa-check-circle me-2"></i> You have already reviewed this book.
                        </div>
                    <% } %>
                </div>
                
                <!-- Related Books Section -->
                <% if (!relatedBooks.isEmpty()) { %>
                    <div class="related-books mt-5">
                        <h3 class="section-title">Related Books</h3>
                        <div class="row row-cols-1 row-cols-md-2 g-4">
                            <% for (Book relatedBook : relatedBooks) { %>
                                <div class="col">
                                    <div class="card h-100">
                                        <img src="<%= relatedBook.getCoverImagePath() != null ? relatedBook.getCoverImagePath() : "images/default-cover.jpg" %>" class="card-img-top" alt="<%= relatedBook.getTitle() %>">
                                        <div class="card-body">
                                            <h5 class="card-title"><%= relatedBook.getTitle() %></h5>
                                            <p class="card-text">By <%= relatedBook.getAuthorName() %></p>
                                            <div class="stars mb-3">
                                                <% double bookRating = relatedBook.getRating(); %>
                                                <% for (int i = 1; i <= 5; i++) { %>
                                                    <% if (i <= bookRating) { %>
                                                        <i class="fas fa-star"></i>
                                                    <% } else if (i - 0.5 <= bookRating) { %>
                                                        <i class="fas fa-star-half-alt"></i>
                                                    <% } else { %>
                                                        <i class="far fa-star"></i>
                                                    <% } %>
                                                <% } %>
                                                <span class="ms-1"><%= String.format("%.1f", bookRating) %></span>
                                            </div>
                                            <a href="book-details.jsp?id=<%= relatedBook.getBookId() %>" class="btn btn-primary w-100">View Details</a>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </main>
    
    <!-- Toast notification container -->
    <div class="toast-container" id="toastContainer"></div>
    
    <!-- Footer -->
    <footer>
        <div class="container">
            <div class="row">
                <div class="col-md-4 mb-4 mb-md-0">
                    <h5 class="footer-title">E-Library</h5>
                    <p>Your gateway to knowledge and entertainment. Discover, read, and download books from our vast collection.</p>
                    <div class="social-share mt-3">
                        <a href="#" class="share-button share-facebook">
                            <i class="fab fa-facebook-f"></i>
                        </a>
                        <a href="#" class="share-button share-twitter">
                            <i class="fab fa-twitter"></i>
                        </a>
                        <a href="#" class="share-button share-linkedin">
                            <i class="fab fa-linkedin-in"></i>
                        </a>
                        <a href="#" class="share-button share-email">
                            <i class="fab fa-instagram"></i>
                        </a>
                    </div>
                </div>
                <div class="col-md-2 mb-4 mb-md-0">
                    <h5 class="footer-title">Explore</h5>
                    <ul class="footer-links">
                        <li class="footer-link"><a href="index.jsp">Home</a></li>
                        <li class="footer-link"><a href="catalog.jsp">Browse</a></li>
                        <li class="footer-link"><a href="about.jsp">About</a></li>
                        <li class="footer-link"><a href="contact.jsp">Contact</a></li>
                    </ul>
                </div>
                <div class="col-md-2 mb-4 mb-md-0">
                    <h5 class="footer-title">Categories</h5>
                    <ul class="footer-links">
                        <% 
                            List<mode.Category> footerCategories = categoryDAO.getAllCategories();
                            int catCount = 0;
                            for (mode.Category cat : footerCategories) {
                                if (catCount++ < 5) {
                        %>
                            <li class="footer-link"><a href="catalog.jsp?category=<%= cat.getCategoryId() %>"><%= cat.getName() %></a></li>
                        <% 
                                }
                            } 
                        %>
                    </ul>
                </div>
                <div class="col-md-4">
                    <h5 class="footer-title">Newsletter</h5>
                    <p>Subscribe to our newsletter to get updates on new books and features.</p>
                    <form class="mt-3">
                        <div class="input-group mb-3">
                            <input type="email" class="form-control" placeholder="Your email" aria-label="Your email">
                            <button class="btn btn-primary" type="button">Subscribe</button>
                        </div>
                    </form>
                </div>
            </div>
            <div class="footer-bottom">
                <p>&copy; 2023 E-Library. All rights reserved.</p>
            </div>
        </div>
    </footer>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Custom JS -->
    <script>
        // Rating stars functionality
        document.addEventListener('DOMContentLoaded', function() {
            const ratingLabels = document.querySelectorAll('.rating-input label');
            
            ratingLabels.forEach(label => {
                label.addEventListener('click', function() {
                    const value = this.querySelector('input').value;
                    
                    ratingLabels.forEach(l => {
                        if (l.querySelector('input').value <= value) {
                            l.classList.add('active');
                            l.querySelector('i').className = 'fas fa-star';
                        } else {
                            l.classList.remove('active');
                            l.querySelector('i').className = 'far fa-star';
                        }
                    });
                });
                
                // Hover effect
                label.addEventListener('mouseenter', function() {
                    const value = this.querySelector('input').value;
                    
                    ratingLabels.forEach(l => {
                        if (l.querySelector('input').value <= value) {
                            l.querySelector('i').className = 'fas fa-star';
                        } else {
                            l.querySelector('i').className = 'far fa-star';
                        }
                    });
                });
                
                label.addEventListener('mouseleave', function() {
                    ratingLabels.forEach(l => {
                        if (l.classList.contains('active')) {
                            l.querySelector('i').className = 'fas fa-star';
                        } else {
                            l.querySelector('i').className = 'far fa-star';
                        }
                    });
                });
            });
        });
        
        // Show toast notification
        function showToast(type, title, message) {
            const toastContainer = document.getElementById('toastContainer');
            
            const toast = document.createElement('div');
            toast.className = `toast ${type}`;
            
            const toastContent = `
                <div class="toast-icon">
                    <i class="fas fa-${type == 'success' ? 'check' : 'exclamation-triangle'}"></i>
                </div>
                <div class="toast-content">
                    <div class="toast-title">${title}</div>
                    <div class="toast-message">${message}</div>
                </div>
                <button class="toast-close" onclick="this.parentElement.remove()">
                    <i class="fas fa-times"></i>
                </button>
            `;
            
            toast.innerHTML = toastContent;
            toastContainer.appendChild(toast);
            
            // Auto remove after 5 seconds
            setTimeout(() => {
                toast.style.animation = 'slideOut 0.3s ease-in forwards';
                setTimeout(() => {
                    toast.remove();
                }, 300);
            }, 5000);
        }
        
        // Toggle bookmark
        function toggleBookmark(bookId) {
            <% if (isLoggedIn) { %>
                fetch('UserBookServlet', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'action=toggleBookmark&bookId=' + bookId + '&userId=<%= currentUser != null ? currentUser.getUserId() : 0 %>'
                })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    if (data.success) {
                        const bookmarkBtn = document.getElementById('bookmarkBtn');
                        const bookmarkIcon = bookmarkBtn.querySelector('i');
                        const bookmarkText = bookmarkBtn.querySelector('span');
                        
                        if (data.bookmarked) {
                            bookmarkBtn.classList.add('active');
                            bookmarkIcon.className = 'fas fa-heart';
                            bookmarkText.textContent = 'Bookmarked';
                            showToast('success', 'Success', 'Book added to your bookmarks. View in your dashboard.');
                        } else {
                            bookmarkBtn.classList.remove('active');
                            bookmarkIcon.className = 'far fa-heart';
                            bookmarkText.textContent = 'Add to Bookmarks';
                            showToast('success', 'Success', 'Book removed from your bookmarks.');
                        }
                    } else {
                        showToast('error', 'Error', data.message || 'Failed to update bookmark status');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showToast('error', 'Error', 'An error occurred while updating bookmark status');
                });
            <% } else { %>
                window.location.href = 'login.jsp?redirect=bookdetails.jsp?id=' + bookId;
            <% } %>
        }
        
        // Update reading status
        function updateReadingStatus(bookId, status, progress) {
            <% if (isLoggedIn) { %>
                fetch('UserBookServlet', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'action=updateStatus&bookId=' + bookId + '&userId=<%= currentUser != null ? currentUser.getUserId() : 0 %>&status=' + status + '&progress=' + progress
                })
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    if (data.success) {
                        // Show success message
                        let message = '';
                        if (status === 'READING') {
                            message = 'Book added to your "Currently Reading" list.';
                        } else if (status === 'TO_READ') {
                            message = 'Book added to your "Want to Read" list.';
                        } else if (status === 'FINISHED') {
                            message = 'Book marked as finished.';
                        }
                        
                        showToast('success', 'Success', message);
                        
                        // Reload the page after a short delay to show updated status
                        setTimeout(() => {
                            window.location.reload();
                        }, 1500);
                    } else {
                        showToast('error', 'Error', data.message || 'Failed to update reading status');
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showToast('error', 'Error', 'An error occurred while updating reading status');
                });
            <% } else { %>
                window.location.href = 'login.jsp?redirect=bookdetails.jsp?id=' + bookId;
            <% } %>
        }
        
        // Update reading progress
        function updateProgress(bookId) {
            const currentProgress = <%= readingProgress %>;
            const newProgress = prompt('Enter your reading progress (0-100%):', currentProgress);
            
            if (newProgress !== null) {
                const progress = parseInt(newProgress);
                
                if (!isNaN(progress) && progress >= 0 && progress <= 100) {
                    updateReadingStatus(bookId, 'READING', progress);
                } else {
                    showToast('error', 'Invalid Input', 'Please enter a valid number between 0 and 100.');
                }
            }
        }
        
        // Form submission
        document.addEventListener('DOMContentLoaded', function() {
            const reviewForm = document.getElementById('reviewForm');
            
            if (reviewForm) {
                reviewForm.addEventListener('submit', function(e) {
                    e.preventDefault();
                    
                    const formData = new FormData(this);
                    const searchParams = new URLSearchParams();
                    
                    for (const pair of formData) {
                        searchParams.append(pair[0], pair[1]);
                    }
                    
                    fetch('ReviewServlet', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: searchParams
                    })
                    .then(response => {
                        if (!response.ok) {
                            throw new Error('Network response was not ok');
                        }
                        return response.json();
                    })
                    .then(data => {
                        if (data.success) {
                            showToast('success', 'Success', 'Your review has been submitted successfully.');
                            
                            // Reload the page after a short delay to show the new review
                            setTimeout(() => {
                                window.location.reload();
                            }, 1500);
                        } else {
                            showToast('error', 'Error', data.message || 'Failed to submit review');
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        showToast('error', 'Error', 'An error occurred while submitting your review');
                    });
                });
            }
        });
    </script>
</body>
</html>
