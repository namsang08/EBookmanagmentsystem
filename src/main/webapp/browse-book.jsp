<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="mode.Book" %>
<%@ page import="mode.User" %>
<%@ page import="mode.Category" %>
<%@ page import="dao.BookDAO" %>
<%@ page import="dao.UserBookDAO" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Books - E-Library Hub</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Custom CSS -->
    <style>
        :root {
            --primary-color: #6366F1;
            --secondary-color: #4F46E5;
            --accent-color: #818CF8;
            --light-color: #F3F4F6;
            --dark-color: #1F2937;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #F9FAFB;
            color: #333;
        }
        
        .navbar {
            background-color: white;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.04);
        }
        
        .navbar-brand {
            font-weight: 700;
            color: var(--primary-color);
        }
        
        .nav-link {
            color: var(--dark-color);
            font-weight: 500;
        }
        
        .nav-link:hover, .nav-link.active {
            color: var(--primary-color);
        }
        
        .dropdown-item:active {
            background-color: var(--primary-color);
        }
        
        .btn-primary {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }
        
        .btn-primary:hover {
            background-color: var(--secondary-color);
            border-color: var(--secondary-color);
        }
        
        .btn-outline-primary {
            color: var(--primary-color);
            border-color: var(--primary-color);
        }
        
        .btn-outline-primary:hover {
            background-color: var(--primary-color);
            color: white;
        }
        
        .card {
            border-radius: 10px;
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
            height: 100%;
        }
        
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
        }
        
        .card-img-top {
            height: 250px;
            object-fit: cover;
        }
        
        .book-cover {
            position: relative;
            overflow: hidden;
        }
        
        .book-actions {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            background: rgba(0, 0, 0, 0.7);
            padding: 10px;
            opacity: 0;
            transition: opacity 0.3s;
            display: flex;
            justify-content: space-around;
        }
        
        .book-cover:hover .book-actions {
            opacity: 1;
        }
        
        .book-actions a {
            color: white;
            text-decoration: none;
        }
        
        .book-actions a:hover {
            color: var(--accent-color);
        }
        
        .badge-category {
            background-color: var(--accent-color);
            color: white;
        }
        
        .rating {
            color: #FFD700;
        }
        
        .bookmark-btn {
            position: absolute;
            top: 10px;
            right: 10px;
            background: rgba(255, 255, 255, 0.8);
            border-radius: 50%;
            width: 36px;
            height: 36px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s;
            border: none;
        }
        
        .bookmark-btn:hover {
            background: white;
            transform: scale(1.1);
        }
        
        .bookmark-btn i {
            color: var(--primary-color);
            font-size: 18px;
        }
        
        .bookmarked i {
            color: #FFD700;
        }
        
        footer {
            background-color: var(--dark-color);
            color: white;
            padding: 40px 0 20px;
        }
        
        footer a {
            color: #CCC;
            text-decoration: none;
        }
        
        footer a:hover {
            color: white;
            text-decoration: underline;
        }
        
        .social-icons a {
            display: inline-block;
            width: 36px;
            height: 36px;
            background-color: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            text-align: center;
            line-height: 36px;
            margin-right: 10px;
            transition: all 0.3s;
        }
        
        .social-icons a:hover {
            background-color: var(--primary-color);
            transform: translateY(-3px);
        }
        
        .footer-bottom {
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            padding-top: 20px;
            margin-top: 40px;
        }
        
        /* Filter sidebar */
        .filter-section {
            background-color: white;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.04);
        }
        
        .filter-section h5 {
            color: var(--dark-color);
            font-weight: 600;
            margin-bottom: 15px;
        }
        
        .form-check-input:checked {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
        }
        
        /* Toast notification */
        .toast-container {
            position: fixed;
            bottom: 20px;
            right: 20px;
            z-index: 1050;
        }
        
        .custom-toast {
            background-color: white;
            color: var(--dark-color);
            border-left: 4px solid var(--primary-color);
        }
    </style>
</head>
<body>
    <%
        // Get current user from session
        User currentUser = (User) session.getAttribute("user");
        
        // Initialize DAOs
        BookDAO bookDAO = new BookDAO();
        UserBookDAO userBookDAO = new UserBookDAO();
        CategoryDAO categoryDAO = new CategoryDAO();
        
        // Get parameters
        String categoryParam = request.getParameter("category");
        String searchQuery = request.getParameter("query");
        String sortBy = request.getParameter("sort");
        
        // Check if we need to redirect to book-section.jsp
        if (searchQuery != null && !searchQuery.isEmpty()) {
            response.sendRedirect("book-section.jsp?query=" + searchQuery);
            return;
        }
        
        int categoryId = 0;
        if (categoryParam != null && !categoryParam.isEmpty()) {
            try {
                categoryId = Integer.parseInt(categoryParam);
            } catch (NumberFormatException e) {
                // Invalid category ID, ignore
            }
        }
        
        // Get books based on filters
        List<Book> books;
        if (categoryId > 0) {
            books = bookDAO.getBooksByCategory(categoryId);
        } else {
            books = bookDAO.getPublicBooks();
        }
        
        // Sort books if needed
        if (sortBy != null) {
            switch (sortBy) {
                case "title":
                    books.sort((b1, b2) -> b1.getTitle().compareTo(b2.getTitle()));
                    break;
                case "author":
                    books.sort((b1, b2) -> b1.getAuthorName().compareTo(b2.getAuthorName()));
                    break;
                case "rating":
                    books.sort((b1, b2) -> Double.compare(b2.getRating(), b1.getRating()));
                    break;
                case "newest":
                    books.sort((b1, b2) -> b2.getPublicationDate().compareTo(b1.getPublicationDate()));
                    break;
                default:
                    // Default sort by upload date (newest first)
                    books.sort((b1, b2) -> b2.getUploadDate().compareTo(b1.getUploadDate()));
            }
        }
        
        // Format dates
        SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    %>

    <!-- Header/Navbar -->
    <nav class="navbar navbar-expand-lg sticky-top">
        <div class="container">
            <a class="navbar-brand" href="index.jsp">
                <i class="fas fa-book-open me-2"></i>E-Library Hub
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="index.jsp">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="browse-books.jsp">Browse Books</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="book-section.jsp">Featured Books</a>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                            Categories
                        </a>
                        <ul class="dropdown-menu">
                            <% 
                                try {
                                    for (Category category : categoryDAO.getAllCategories()) {
                            %>
                                <li><a class="dropdown-item" href="browse-books.jsp?category=<%= category.getCategoryId() %>"><%= category.getName() %></a></li>
                            <%
                                    }
                                } catch (Exception e) {
                                    // Handle exception
                                }
                            %>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="browse-books.jsp">All Categories</a></li>
                        </ul>
                    </li>
                    <% if (currentUser != null) { %>
                    <li class="nav-item">
                        <a class="nav-link" href="user/dashboard.jsp">My Dashboard</a>
                    </li>
                    <% } %>
                </ul>
                
                <form class="d-flex me-2" action="book-section.jsp" method="get">
                    <div class="input-group">
                        <input type="text" class="form-control" placeholder="Search books..." name="query">
                        <button class="btn btn-outline-primary" type="submit">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </form>
                
                <% if (currentUser != null) { %>
                <div class="d-flex align-items-center">
                    <div class="dropdown me-3">
                        <a href="#" class="position-relative text-dark" role="button" data-bs-toggle="dropdown">
                            <i class="fas fa-bell fs-5"></i>
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                                3
                                <span class="visually-hidden">unread notifications</span>
                            </span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li><h6 class="dropdown-header">Notifications</h6></li>
                            <li><a class="dropdown-item" href="#">New book added in your favorite category</a></li>
                            <li><a class="dropdown-item" href="#">Your book request was approved</a></li>
                            <li><a class="dropdown-item" href="#">Author replied to your review</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item text-center" href="user/notifications.jsp">See all notifications</a></li>
                        </ul>
                    </div>
                    
                    <div class="dropdown">
                        <a href="#" class="d-flex align-items-center text-decoration-none dropdown-toggle" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                            <img src="<%= currentUser.getProfileImage() != null ? currentUser.getProfileImage() : "https://ui-avatars.com/api/?name=" + currentUser.getFirstName() + "+" + currentUser.getLastName() + "&background=6366F1&color=fff" %>" 
                                 alt="Profile" width="32" height="32" class="rounded-circle me-2">
                            <span><%= currentUser.getFirstName() %></span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end text-small" aria-labelledby="userDropdown">
                            <li><a class="dropdown-item" href="user/dashboard.jsp">Dashboard</a></li>
                            <li><a class="dropdown-item" href="user/bookmarks.jsp">My Bookmarks</a></li>
                            <li><a class="dropdown-item" href="user/reading-list.jsp">Reading List</a></li>
                            <li><a class="dropdown-item" href="user/profile.jsp">Profile</a></li>
                            <li><a class="dropdown-item" href="user/settings.jsp">Settings</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="logout.jsp">Sign out</a></li>
                        </ul>
                    </div>
                </div>
                <% } else { %>
                <div class="d-flex">
                    <a href="login.jsp" class="btn btn-outline-primary me-2">Login</a>
                    <a href="register.jsp" class="btn btn-primary">Register</a>
                </div>
                <% } %>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="container py-5">
        <!-- Page Header -->
        <div class="row mb-4">
            <div class="col-md-8">
                <h1 class="fw-bold">
                    <% if (categoryId > 0) { %>
                        <% 
                            Category currentCategory = categoryDAO.getCategoryById(categoryId);
                            if (currentCategory != null) {
                        %>
                            <%= currentCategory.getName() %> Books
                        <% } else { %>
                            Browse Books
                        <% } %>
                    <% } else { %>
                        Browse Books
                    <% } %>
                </h1>
                <p class="text-muted">
                    Discover and bookmark your favorite books from our collection of <%= books.size() %> titles
                </p>
            </div>
            <div class="col-md-4 d-flex justify-content-md-end align-items-center">
                <div class="dropdown">
                    <button class="btn btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                        <i class="fas fa-sort me-1"></i> Sort by
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item <%= "newest".equals(sortBy) ? "active" : "" %>" href="?<%= categoryId > 0 ? "category=" + categoryId + "&" : "" %>sort=newest">Newest</a></li>
                        <li><a class="dropdown-item <%= "title".equals(sortBy) ? "active" : "" %>" href="?<%= categoryId > 0 ? "category=" + categoryId + "&" : "" %>sort=title">Title</a></li>
                        <li><a class="dropdown-item <%= "author".equals(sortBy) ? "active" : "" %>" href="?<%= categoryId > 0 ? "category=" + categoryId + "&" : "" %>sort=author">Author</a></li>
                        <li><a class="dropdown-item <%= "rating".equals(sortBy) ? "active" : "" %>" href="?<%= categoryId > 0 ? "category=" + categoryId + "&" : "" %>sort=rating">Rating</a></li>
                    </ul>
                </div>
                <div class="btn-group ms-2" role="group">
                    <button type="button" class="btn btn-outline-secondary active" id="gridViewBtn">
                        <i class="fas fa-th-large"></i>
                    </button>
                    <button type="button" class="btn btn-outline-secondary" id="listViewBtn">
                        <i class="fas fa-list"></i>
                    </button>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Sidebar Filters -->
            <div class="col-lg-3 mb-4">
                <div class="filter-section">
                    <h5>Categories</h5>
                    <div class="mb-3">
                        <% 
                            try {
                                for (Category category : categoryDAO.getAllCategories()) {
                        %>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="categoryFilter" id="category<%= category.getCategoryId() %>" 
                                       <%= categoryId == category.getCategoryId() ? "checked" : "" %>
                                       onchange="window.location.href='browse-books.jsp?category=<%= category.getCategoryId() %>'">
                                <label class="form-check-label" for="category<%= category.getCategoryId() %>">
                                    <%= category.getName() %> (<%= category.getBookCount() %>)
                                </label>
                            </div>
                        <%
                                }
                            } catch (Exception e) {
                                // Handle exception
                            }
                        %>
                        <div class="form-check">
                            <input class="form-check-input" type="radio" name="categoryFilter" id="categoryAll" 
                                   <%= categoryId == 0 ? "checked" : "" %>
                                   onchange="window.location.href='browse-books.jsp'">
                            <label class="form-check-label" for="categoryAll">
                                All Categories
                            </label>
                        </div>
                    </div>
                </div>
                
                <div class="filter-section">
                    <h5>Rating</h5>
                    <div class="mb-3">
                        <div class="form-check">
                            <input class="form-check-input" type="radio" name="ratingFilter" id="rating4plus">
                            <label class="form-check-label" for="rating4plus">
                                <div class="rating">
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star"></i>
                                    <i class="far fa-star"></i>
                                </div>
                                & up
                            </label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="radio" name="ratingFilter" id="rating3plus">
                            <label class="form-check-label" for="rating3plus">
                                <div class="rating">
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star"></i>
                                    <i class="far fa-star"></i>
                                    <i class="far fa-star"></i>
                                </div>
                                & up
                            </label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="radio" name="ratingFilter" id="rating2plus">
                            <label class="form-check-label" for="rating2plus">
                                <div class="rating">
                                    <i class="fas fa-star"></i>
                                    <i class="fas fa-star"></i>
                                    <i class="far fa-star"></i>
                                    <i class="far fa-star"></i>
                                    <i class="far fa-star"></i>
                                </div>
                                & up
                            </label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="radio" name="ratingFilter" id="ratingAll" checked>
                            <label class="form-check-label" for="ratingAll">
                                All Ratings
                            </label>
                        </div>
                    </div>
                </div>
                
                <div class="filter-section">
                    <h5>Language</h5>
                    <div class="mb-3">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="langEnglish" checked>
                            <label class="form-check-label" for="langEnglish">
                                English
                            </label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="langSpanish">
                            <label class="form-check-label" for="langSpanish">
                                Spanish
                            </label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="langFrench">
                            <label class="form-check-label" for="langFrench">
                                French
                            </label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="langGerman">
                            <label class="form-check-label" for="langGerman">
                                German
                            </label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="langOther">
                            <label class="form-check-label" for="langOther">
                                Other
                            </label>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Book Grid -->
            <div class="col-lg-9">
                <% if (books.isEmpty()) { %>
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle me-2"></i>
                        No books found. Try adjusting your search criteria.
                    </div>
                <% } else { %>
                    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4" id="booksGrid">
                        <% for (Book book : books) { %>
                            <div class="col">
                                <div class="card h-100">
                                    <div class="book-cover">
                                        <img src="<%= book.getCoverImagePath() != null && !book.getCoverImagePath().isEmpty() ? book.getCoverImagePath() : "assets/images/default-cover.jpg" %>" 
                                             class="card-img-top" alt="<%= book.getTitle() %>">
                                        
                                        <% if (currentUser != null) { %>
                                            <button class="bookmark-btn <%= userBookDAO.isBookmarked(currentUser.getUserId(), book.getBookId()) ? "bookmarked" : "" %>"
                                                    onclick="toggleBookmark(<%= book.getBookId() %>)" 
                                                    data-book-id="<%= book.getBookId() %>"
                                                    title="<%= userBookDAO.isBookmarked(currentUser.getUserId(), book.getBookId()) ? "Remove from bookmarks" : "Add to bookmarks" %>">
                                                <i class="<%= userBookDAO.isBookmarked(currentUser.getUserId(), book.getBookId()) ? "fas" : "far" %> fa-bookmark"></i>
                                            </button>
                                        <% } %>
                                        
                                        <div class="book-actions">
                                            <a href="bookdetails.jsp?id=<%= book.getBookId() %>" title="View Details">
                                                <i class="fas fa-info-circle"></i> Details
                                            </a>
                                            <a href="reader.jsp?id=<%= book.getBookId() %>" title="Read Book">
                                                <i class="fas fa-book-reader"></i> Read
                                            </a>
                                        </div>
                                    </div>
                                    <div class="card-body">
                                        <h5 class="card-title"><%= book.getTitle() %></h5>
                                        <p class="card-text text-muted mb-1">by <%= book.getAuthorName() %></p>
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <span class="badge badge-category"><%= book.getCategoryName() %></span>
                                            <div class="rating">
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
                                                <small class="text-muted ms-1">(<%= String.format("%.1f", rating) %>)</small>
                                            </div>
                                        </div>
                                        <p class="card-text small">
                                            <%= book.getDescription() != null ? (book.getDescription().length() > 100 ? book.getDescription().substring(0, 100) + "..." : book.getDescription()) : "No description available." %>
                                        </p>
                                    </div>
                                    <div class="card-footer bg-white">
                                        <div class="d-flex justify-content-between align-items-center">
                                            <small class="text-muted">
                                                <i class="far fa-calendar-alt me-1"></i> <%= dateFormat.format(book.getPublicationDate()) %>
                                            </small>
                                            <small class="text-muted">
                                                <i class="fas fa-eye me-1"></i> <%= book.getViews() %>
                                            </small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    </div>
                    
                    <!-- Book List View (hidden by default) -->
                    <div class="d-none" id="booksList">
                        <% for (Book book : books) { %>
                            <div class="card mb-3">
                                <div class="row g-0">
                                    <div class="col-md-3 position-relative">
                                        <img src="<%= book.getCoverImagePath() != null && !book.getCoverImagePath().isEmpty() ? book.getCoverImagePath() : "assets/images/default-cover.jpg" %>" 
                                             class="img-fluid rounded-start h-100 w-100" style="object-fit: cover;" alt="<%= book.getTitle() %>">
                                        
                                        <% if (currentUser != null) { %>
                                            <button class="bookmark-btn <%= userBookDAO.isBookmarked(currentUser.getUserId(), book.getBookId()) ? "bookmarked" : "" %>"
                                                    onclick="toggleBookmark(<%= book.getBookId() %>)" 
                                                    data-book-id="<%= book.getBookId() %>"
                                                    title="<%= userBookDAO.isBookmarked(currentUser.getUserId(), book.getBookId()) ? "Remove from bookmarks" : "Add to bookmarks" %>">
                                                <i class="<%= userBookDAO.isBookmarked(currentUser.getUserId(), book.getBookId()) ? "fas" : "far" %> fa-bookmark"></i>
                                            </button>
                                        <% } %>
                                    </div>
                                    <div class="col-md-9">
                                        <div class="card-body">
                                            <div class="d-flex justify-content-between align-items-start">
                                                <h5 class="card-title"><%= book.getTitle() %></h5>
                                                <span class="badge badge-category"><%= book.getCategoryName() %></span>
                                            </div>
                                            <p class="card-text text-muted">by <%= book.getAuthorName() %></p>
                                            <div class="rating mb-2">
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
                                                <small class="text-muted ms-1">(<%= String.format("%.1f", rating) %>)</small>
                                            </div>
                                            <p class="card-text">
                                                <%= book.getDescription() != null ? (book.getDescription().length() > 200 ? book.getDescription().substring(0, 200) + "..." : book.getDescription()) : "No description available." %>
                                            </p>
                                            <div class="d-flex justify-content-between align-items-center">
                                                <div>
                                                    <small class="text-muted me-3">
                                                        <i class="far fa-calendar-alt me-1"></i> <%= dateFormat.format(book.getPublicationDate()) %>
                                                    </small>
                                                    <small class="text-muted me-3">
                                                        <i class="fas fa-eye me-1"></i> <%= book.getViews() %>
                                                    </small>
                                                    <small class="text-muted">
                                                        <i class="fas fa-download me-1"></i> <%= book.getDownloads() %>
                                                    </small>
                                                </div>
                                                <div>
                                                    <a href="bookdetails.jsp?id=<%= book.getBookId() %>" class="btn btn-sm btn-outline-primary me-2">
                                                        <i class="fas fa-info-circle me-1"></i> Details
                                                    </a>
                                                    <a href="reader.jsp?id=<%= book.getBookId() %>" class="btn btn-sm btn-primary">
                                                        <i class="fas fa-book-reader me-1"></i> Read
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } %>
                
                <!-- Pagination -->
                <nav aria-label="Page navigation" class="mt-4">
                    <ul class="pagination justify-content-center">
                        <li class="page-item disabled">
                            <a class="page-link" href="#" tabindex="-1" aria-disabled="true">Previous</a>
                        </li>
                        <li class="page-item active"><a class="page-link" href="#">1</a></li>
                        <li class="page-item"><a class="page-link" href="#">2</a></li>
                        <li class="page-item"><a class="page-link" href="#">3</a></li>
                        <li class="page-item">
                            <a class="page-link" href="#">Next</a>
                        </li>
                    </ul>
                </nav>
            </div>
        </div>
    </div>

    <!-- Toast Notification Container -->
    <div class="toast-container"></div>

    <!-- Footer -->
    <footer class="mt-5">
        <div class="container">
            <div class="row">
                <div class="col-lg-4 mb-4">
                    <h5 class="mb-3">E-Library Hub</h5>
                    <p>Your digital gateway to a world of knowledge. Discover, read, and expand your horizons with our vast collection of e-books.</p>
                    <div class="social-icons">
                        <a href="#"><i class="fab fa-facebook-f"></i></a>
                        <a href="#"><i class="fab fa-twitter"></i></a>
                        <a href="#"><i class="fab fa-instagram"></i></a>
                        <a href="#"><i class="fab fa-linkedin-in"></i></a>
                    </div>
                </div>
                <div class="col-lg-2 col-md-4 mb-4">
                    <h5 class="mb-3">Quick Links</h5>
                    <ul class="list-unstyled">
                        <li><a href="index.jsp">Home</a></li>
                        <li><a href="browse-books.jsp">Browse Books</a></li>
                        <li><a href="about.jsp">About Us</a></li>
                        <li><a href="contact.jsp">Contact</a></li>
                        <li><a href="faq.jsp">FAQ</a></li>
                    </ul>
                </div>
                <div class="col-lg-2 col-md-4 mb-4">
                    <h5 class="mb-3">User</h5>
                    <ul class="list-unstyled">
                        <% if (currentUser != null) { %>
                            <li><a href="user/dashboard.jsp">Dashboard</a></li>
                            <li><a href="user/bookmarks.jsp">My Bookmarks</a></li>
                            <li><a href="user/reading-list.jsp">Reading List</a></li>
                            <li><a href="user/profile.jsp">Profile</a></li>
                            <li><a href="logout.jsp">Logout</a></li>
                        <% } else { %>
                            <li><a href="login.jsp">Login</a></li>
                            <li><a href="register.jsp">Register</a></li>
                        <% } %>
                    </ul>
                </div>
                <div class="col-lg-4 col-md-4 mb-4">
                    <h5 class="mb-3">Contact Us</h5>
                    <ul class="list-unstyled">
                        <li><i class="fas fa-map-marker-alt me-2"></i> 123 Library Street, Book City</li>
                        <li><i class="fas fa-phone me-2"></i> (123) 456-7890</li>
                        <li><i class="fas fa-envelope me-2"></i> info@elibraryhub.com</li>
                    </ul>
                    <a href="contact.jsp" class="btn btn-outline-light mt-2">Send Message</a>
                </div>
            </div>
            <div class="footer-bottom text-center">
                <p class="mb-0">&copy; 2023 E-Library Hub. All rights reserved.</p>
                <div class="mt-2">
                    <a href="terms.jsp" class="me-3">Terms of Service</a>
                    <a href="privacy.jsp" class="me-3">Privacy Policy</a>
                    <a href="faq.jsp">FAQ</a>
                </div>
            </div>
        </div>
    </footer>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <script>
        // Toggle between grid and list view
        document.getElementById('gridViewBtn').addEventListener('click', function() {
            document.getElementById('booksGrid').classList.remove('d-none');
            document.getElementById('booksList').classList.add('d-none');
            this.classList.add('active');
            document.getElementById('listViewBtn').classList.remove('active');
        });
        
        document.getElementById('listViewBtn').addEventListener('click', function() {
            document.getElementById('booksGrid').classList.add('d-none');
            document.getElementById('booksList').classList.remove('d-none');
            this.classList.add('active');
            document.getElementById('gridViewBtn').classList.remove('active');
        });
        
        // Toggle bookmark function
        function toggleBookmark(bookId) {
            <% if (currentUser == null) { %>
                // Redirect to login if not logged in
                window.location.href = 'login.jsp?redirect=browse-books.jsp';
                return;
            <% } %>
            
            // Send AJAX request to toggle bookmark
            $.ajax({
                url: 'UserBookServlet',
                type: 'POST',
                data: {
                    action: 'toggleBookmark',
                    bookId: bookId
                },
                success: function(response) {
                    try {
                        const result = JSON.parse(response);
                        
                        // Update bookmark button appearance
                        const bookmarkBtns = document.querySelectorAll(`.bookmark-btn[data-book-id="${bookId}"]`);
                        bookmarkBtns.forEach(btn => {
                            if (result.success) {
                                if (result.bookmarked) {
                                    btn.classList.add('bookmarked');
                                    btn.querySelector('i').classList.remove('far');
                                    btn.querySelector('i').classList.add('fas');
                                    btn.title = "Remove from bookmarks";
                                } else {
                                    btn.classList.remove('bookmarked');
                                    btn.querySelector('i').classList.remove('fas');
                                    btn.querySelector('i').classList.add('far');
                                    btn.title = "Add to bookmarks";
                                }
                            }
                        });
                        
                        // Show toast notification
                        showToast(result.message, result.success ? 'success' : 'danger');
                    } catch (e) {
                        console.error('Error parsing response:', e);
                        showToast('An error occurred while processing your request.', 'danger');
                    }
                },
                error: function() {
                    showToast('Failed to communicate with the server.', 'danger');
                }
            });
        }
        
        // Show toast notification
        function showToast(message, type = 'success') {
            const toastContainer = document.querySelector('.toast-container');
            
            const toastEl = document.createElement('div');
            toastEl.className = `toast custom-toast show align-items-center border-0 mb-2`;
            toastEl.setAttribute('role', 'alert');
            toastEl.setAttribute('aria-live', 'assertive');
            toastEl.setAttribute('aria-atomic', 'true');
            
            const iconClass = type === 'success' ? 'fas fa-check-circle text-success' : 'fas fa-exclamation-circle text-danger';
            
            toastEl.innerHTML = `
                <div class="d-flex">
                    <div class="toast-body">
                        <i class="${iconClass} me-2"></i> ${message}
                    </div>
                    <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
            `;
            
            toastContainer.appendChild(toastEl);
            
            // Auto-remove toast after 3 seconds
            setTimeout(() => {
                toastEl.classList.remove('show');
                setTimeout(() => {
                    toastContainer.removeChild(toastEl);
                }, 300);
            }, 3000);
        }
    </script>
</body>
</html>
