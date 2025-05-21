<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="mode.Book" %>
<%@ page import="mode.User" %>
<%@ page import="mode.Category" %>
<%@ page import="dao.BookDAO" %>
<%@ page import="dao.UserBookDAO" %>
<%@ page import="dao.CategoryDAO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.sql.Timestamp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Featured Books - E-Library Hub</title>
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
            z-index: 10;
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
        
        .section-title {
            position: relative;
            display: inline-block;
            margin-bottom: 30px;
        }
        
        .section-title::after {
            content: '';
            position: absolute;
            left: 0;
            bottom: -10px;
            width: 50px;
            height: 3px;
            background-color: var(--primary-color);
        }
        
        .featured-badge {
            position: absolute;
            top: 10px;
            left: 10px;
            background-color: var(--primary-color);
            color: white;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
            z-index: 10;
        }
        
        .new-badge {
            position: absolute;
            top: 10px;
            left: 10px;
            background-color: #10B981;
            color: white;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
            z-index: 10;
        }
        
        .bestseller-badge {
            position: absolute;
            top: 10px;
            left: 10px;
            background-color: #F59E0B;
            color: white;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
            z-index: 10;
        }
        
        .category-filter {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 30px;
        }
        
        .category-filter button {
            background-color: white;
            border: 1px solid #E5E7EB;
            color: var(--dark-color);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.9rem;
            transition: all 0.3s;
        }
        
        .category-filter button:hover, .category-filter button.active {
            background-color: var(--primary-color);
            color: white;
            border-color: var(--primary-color);
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
        String section = request.getParameter("section");
        
        if (section == null) {
            section = "featured"; // Default section
        }
        
        // Create sample books if they don't exist in the database
        // In a real application, these would be fetched from the database
        List<Book> allBooks = new ArrayList<>();
        
        // Sample book data - in a real app, this would come from the database
        String[][] sampleBooks = {
            // title, author, category, description, cover image, rating
            {"The Art of Programming", "John Smith", "Programming", "A comprehensive guide to programming concepts and practices.", "https://images.unsplash.com/photo-1517694712202-14dd9538aa97", "4.8"},
            {"Data Structures and Algorithms", "Jane Doe", "Programming", "Learn essential data structures and algorithms for efficient coding.", "https://images.unsplash.com/photo-1515879218367-8466d910aaa4", "4.7"},
            {"Machine Learning Basics", "Robert Johnson", "Data Science", "An introduction to machine learning concepts and applications.", "https://images.unsplash.com/photo-1620712943543-bcc4688e7485", "4.6"},
            {"The History of Science", "Emily Williams", "Science", "Explore the fascinating history of scientific discoveries.", "https://images.unsplash.com/photo-1532094349884-543bc11b234d", "4.5"},
            {"Modern Physics", "David Brown", "Science", "Understanding the principles of modern physics.", "https://images.unsplash.com/photo-1635070041078-e363dbe005cb", "4.4"},
            {"World Literature Classics", "Sarah Miller", "Literature", "A collection of classic literature from around the world.", "https://images.unsplash.com/photo-1544947950-fa07a98d237f", "4.9"},
            {"The Art of Fiction", "Michael Wilson", "Literature", "Learn the craft of fiction writing from a master storyteller.", "https://images.unsplash.com/photo-1512820790803-83ca734da794", "4.7"},
            {"Economic Principles", "Jennifer Lee", "Business", "Understanding the fundamental principles of economics.", "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3", "4.3"},
            {"Strategic Management", "Thomas Anderson", "Business", "Develop effective strategies for business management and growth.", "https://images.unsplash.com/photo-1542744094-3a31f272c490", "4.6"},
            {"Digital Marketing", "Lisa Taylor", "Marketing", "Master the art of digital marketing in the modern age.", "https://images.unsplash.com/photo-1460925895917-afdab827c52f", "4.5"},
            {"Social Media Strategy", "Kevin Martin", "Marketing", "Building effective social media strategies for businesses.", "https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7", "4.4"},
            {"Healthy Living", "Amanda Clark", "Health", "A guide to maintaining a healthy lifestyle in the modern world.", "https://images.unsplash.com/photo-1505576399279-565b52d4ac71", "4.8"}
        };
        
        // Create Book objects from sample data
        for (int i = 0; i < sampleBooks.length; i++) {
            Book book = new Book();
            book.setBookId(i + 1);
            book.setTitle(sampleBooks[i][0]);
            book.setAuthorName(sampleBooks[i][1]);
            book.setCategoryName(sampleBooks[i][2]);
            book.setDescription(sampleBooks[i][3]);
            book.setCoverImagePath(sampleBooks[i][4]);
            book.setRating(Double.parseDouble(sampleBooks[i][5]));
            book.setPages(300 + (i * 20)); // Random page count
            book.setViews(100 + (i * 15)); // Random view count
            book.setDownloads(50 + (i * 10)); // Random download count
            
            // Set publication date (random within last 3 years)
            long now = System.currentTimeMillis();
            long threeYearsAgo = now - (3L * 365 * 24 * 60 * 60 * 1000);
            long randomTime = threeYearsAgo + (long)(Math.random() * (now - threeYearsAgo));
            book.setPublicationDate(new Date(randomTime));
            
            // Set upload date (random within last year)
            long oneYearAgo = now - (1L * 365 * 24 * 60 * 60 * 1000);
            randomTime = oneYearAgo + (long)(Math.random() * (now - oneYearAgo));
            book.setUploadDate(new Timestamp(randomTime));
            
            allBooks.add(book);
        }
        
        // Filter books based on search query or category
        List<Book> displayBooks = new ArrayList<>();
        
        if (searchQuery != null && !searchQuery.isEmpty()) {
            // Filter by search query
            for (Book book : allBooks) {
                if (book.getTitle().toLowerCase().contains(searchQuery.toLowerCase()) || 
                    book.getAuthorName().toLowerCase().contains(searchQuery.toLowerCase()) ||
                    book.getDescription().toLowerCase().contains(searchQuery.toLowerCase()) ||
                    book.getCategoryName().toLowerCase().contains(searchQuery.toLowerCase())) {
                    displayBooks.add(book);
                }
            }
        } else if (categoryParam != null && !categoryParam.isEmpty()) {
            // Filter by category
            for (Book book : allBooks) {
                if (book.getCategoryName().equalsIgnoreCase(categoryParam)) {
                    displayBooks.add(book);
                }
            }
        } else {
            // Filter by section
            if ("featured".equals(section)) {
                // Featured books (first 6)
                displayBooks = allBooks.subList(0, Math.min(6, allBooks.size()));
            } else if ("new".equals(section)) {
                // New arrivals (sort by upload date)
                List<Book> newBooks = new ArrayList<>(allBooks);
                newBooks.sort((b1, b2) -> b2.getUploadDate().compareTo(b1.getUploadDate()));
                displayBooks = newBooks.subList(0, Math.min(6, newBooks.size()));
            } else if ("bestsellers".equals(section)) {
                // Bestsellers (sort by downloads)
                List<Book> bestsellerBooks = new ArrayList<>(allBooks);
                bestsellerBooks.sort((b1, b2) -> Integer.compare(b2.getDownloads(), b1.getDownloads()));
                displayBooks = bestsellerBooks.subList(0, Math.min(6, bestsellerBooks.size()));
            } else {
                // Default to all books
                displayBooks = allBooks;
            }
        }
        
        // Get unique categories from all books
        List<String> categories = new ArrayList<>();
        for (Book book : allBooks) {
            if (!categories.contains(book.getCategoryName())) {
                categories.add(book.getCategoryName());
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
                        <a class="nav-link" href="browse-books.jsp">Browse Books</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="book-section.jsp">Featured Books</a>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                            Categories
                        </a>
                        <ul class="dropdown-menu">
                            <% for (String category : categories) { %>
                                <li><a class="dropdown-item" href="book-section.jsp?category=<%= category %>"><%= category %></a></li>
                            <% } %>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="book-section.jsp">All Categories</a></li>
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
                        <input type="text" class="form-control" placeholder="Search books..." name="query" value="<%= searchQuery != null ? searchQuery : "" %>">
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
                    <% if (searchQuery != null && !searchQuery.isEmpty()) { %>
                        Search Results for "<%= searchQuery %>"
                    <% } else if (categoryParam != null && !categoryParam.isEmpty()) { %>
                        <%= categoryParam %> Books
                    <% } else { %>
                        <% if ("featured".equals(section)) { %>
                            Featured Books
                        <% } else if ("new".equals(section)) { %>
                            New Arrivals
                        <% } else if ("bestsellers".equals(section)) { %>
                            Bestsellers
                        <% } else { %>
                            All Books
                        <% } %>
                    <% } %>
                </h1>
                <p class="text-muted">
                    <% if (searchQuery != null && !searchQuery.isEmpty()) { %>
                        Found <%= displayBooks.size() %> books matching your search
                    <% } else if (categoryParam != null && !categoryParam.isEmpty()) { %>
                        Browse our collection of <%= displayBooks.size() %> <%= categoryParam %> books
                    <% } else { %>
                        Discover and bookmark your favorite books from our collection
                    <% } %>
                </p>
            </div>
            <div class="col-md-4 d-flex justify-content-md-end align-items-center">
                <div class="btn-group" role="group">
                    <a href="book-section.jsp?section=featured" class="btn btn-outline-primary <%= "featured".equals(section) ? "active" : "" %>">
                        Featured
                    </a>
                    <a href="book-section.jsp?section=new" class="btn btn-outline-primary <%= "new".equals(section) ? "active" : "" %>">
                        New Arrivals
                    </a>
                    <a href="book-section.jsp?section=bestsellers" class="btn btn-outline-primary <%= "bestsellers".equals(section) ? "active" : "" %>">
                        Bestsellers
                    </a>
                </div>
            </div>
        </div>

        <!-- Category Filter -->
        <% if (searchQuery == null && categoryParam == null) { %>
        <div class="category-filter">
            <button class="active" data-filter="all">All</button>
            <% for (String category : categories) { %>
                <button data-filter="<%= category.toLowerCase().replace(" ", "-") %>"><%= category %></button>
            <% } %>
        </div>
        <% } %>

        <!-- Books Grid -->
        <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
            <% if (displayBooks.isEmpty()) { %>
                <div class="col-12">
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle me-2"></i>
                        No books found. Try adjusting your search criteria.
                    </div>
                </div>
            <% } else { %>
                <% for (Book book : displayBooks) { %>
                    <div class="col book-item" data-category="<%= book.getCategoryName().toLowerCase().replace(" ", "-") %>">
                        <div class="card h-100">
                            <div class="book-cover">
                                <% if ("featured".equals(section) || (searchQuery == null && categoryParam == null)) { %>
                                    <span class="featured-badge">Featured</span>
                                <% } else if ("new".equals(section)) { %>
                                    <span class="new-badge">New</span>
                                <% } else if ("bestsellers".equals(section)) { %>
                                    <span class="bestseller-badge">Bestseller</span>
                                <% } %>
                                
                                <img src="<%= book.getCoverImagePath() %>" class="card-img-top" alt="<%= book.getTitle() %>">
                                
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
                                    <%= book.getDescription().length() > 100 ? book.getDescription().substring(0, 100) + "..." : book.getDescription() %>
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
            <% } %>
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
                        <li><a href="book-section.jsp">Featured Books</a></li>
                        <li><a href="about.jsp">About Us</a></li>
                        <li><a href="contact.jsp">Contact</a></li>
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
        // Category filter functionality
        document.addEventListener('DOMContentLoaded', function() {
            const filterButtons = document.querySelectorAll('.category-filter button');
            const bookItems = document.querySelectorAll('.book-item');
            
            filterButtons.forEach(button => {
                button.addEventListener('click', function() {
                    // Remove active class from all buttons
                    filterButtons.forEach(btn => btn.classList.remove('active'));
                    
                    // Add active class to clicked button
                    this.classList.add('active');
                    
                    const filter = this.getAttribute('data-filter');
                    
                    // Show/hide books based on filter
                    bookItems.forEach(item => {
                        if (filter === 'all') {
                            item.style.display = 'block';
                        } else {
                            if (item.getAttribute('data-category') === filter) {
                                item.style.display = 'block';
                            } else {
                                item.style.display = 'none';
                            }
                        }
                    });
                });
            });
        });
        
        // Toggle bookmark function
        function toggleBookmark(bookId) {
            <% if (currentUser == null) { %>
                // Redirect to login if not logged in
                window.location.href = 'login.jsp?redirect=book-section.jsp';
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
                        const bookmarkBtn = document.querySelector(`.bookmark-btn[data-book-id="${bookId}"]`);
                        if (bookmarkBtn) {
                            if (result.success) {
                                if (result.bookmarked) {
                                    bookmarkBtn.classList.add('bookmarked');
                                    bookmarkBtn.querySelector('i').classList.remove('far');
                                    bookmarkBtn.querySelector('i').classList.add('fas');
                                    bookmarkBtn.title = "Remove from bookmarks";
                                } else {
                                    bookmarkBtn.classList.remove('bookmarked');
                                    bookmarkBtn.querySelector('i').classList.remove('fas');
                                    bookmarkBtn.querySelector('i').classList.add('far');
                                    bookmarkBtn.title = "Add to bookmarks";
                                }
                            }
                        }
                        
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
