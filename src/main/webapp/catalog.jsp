<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.BookDAO, dao.CategoryDAO, mode.Book, mode.Category, mode.User, java.util.List, java.util.ArrayList, java.text.SimpleDateFormat" %>

<%
    // Initialize DAOs
    BookDAO bookDAO = new BookDAO();
    CategoryDAO categoryDAO = new CategoryDAO();
    
    // Get all categories
    List<Category> categories = categoryDAO.getAllCategories();
    
    // Get filter parameters
    String searchQuery = request.getParameter("search");
    String categoryParam = request.getParameter("category");
    String tagParam = request.getParameter("tag");
    String sortParam = request.getParameter("sort");
    
    int categoryId = 0;
    if (categoryParam != null && !categoryParam.isEmpty()) {
        try {
            categoryId = Integer.parseInt(categoryParam);
        } catch (NumberFormatException e) {
            // Invalid category ID, ignore
        }
    }
    
    // Get books based on filters
    List<Book> books = new ArrayList<>();
    
    if (searchQuery != null && !searchQuery.isEmpty()) {
        // Search for books
        books = bookDAO.searchBooks(searchQuery);
        request.setAttribute("searchQuery", searchQuery);
    } else if (categoryId > 0) {
        // Get books by category
        books = bookDAO.getBooksByCategory(categoryId);
        
        // Get category name for display
        Category selectedCategory = categoryDAO.getCategoryById(categoryId);
        if (selectedCategory != null) {
            request.setAttribute("categoryName", selectedCategory.getName());
        }
    } else if (tagParam != null && !tagParam.isEmpty()) {
        // Get books by tag (using search as a workaround)
        books = bookDAO.searchBooks(tagParam);
        request.setAttribute("tagName", tagParam);
    } else {
        // Get all public books
        books = bookDAO.getPublicBooks();
    }
    
    // Sort books if needed
    if (sortParam != null && !sortParam.isEmpty()) {
        switch (sortParam) {
            case "newest":
                // Already sorted by publication date in DAO
                break;
            case "title":
                books.sort((b1, b2) -> b1.getTitle().compareToIgnoreCase(b2.getTitle()));
                break;
            case "rating":
                books.sort((b1, b2) -> Double.compare(b2.getRating(), b1.getRating()));
                break;
            case "popular":
                books.sort((b1, b2) -> Integer.compare(b2.getViews() + b2.getDownloads(), b1.getViews() + b1.getDownloads()));
                break;
            default:
                // Default sort by publication date
                break;
        }
    }
    
    // Pagination
    int currentPage = 1;
    int recordsPerPage = 12;
    int start = 0;
    int end = 0;
    int totalPages = 0;
    
    try {
        String pageParam = request.getParameter("page");
        if (pageParam != null) {
            currentPage = Integer.parseInt(pageParam);
            if (currentPage < 1) {
                currentPage = 1;
            }
        }
    } catch (NumberFormatException e) {
        currentPage = 1;
    }
    
    if (books != null && !books.isEmpty()) {
        totalPages = (int) Math.ceil(books.size() * 1.0 / recordsPerPage);
        if (currentPage > totalPages) {
            currentPage = totalPages;
        }
        
        start = (currentPage - 1) * recordsPerPage;
        end = Math.min(start + recordsPerPage, books.size());
        
        // Subset of books for current page
        books = books.subList(start, end);
    }
    
    // Check if user is logged in
    User currentUser = null;
    boolean isLoggedIn = false;
    
    Object userObj = session.getAttribute("user");
    if (userObj != null && userObj instanceof User) {
        currentUser = (User) userObj;
        isLoggedIn = true;
    }
    
    // Format dates
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM d, yyyy");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Books | E-Library</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #4f46e5;
            --secondary-color: #818cf8;
            --accent-color: #c7d2fe;
            --text-color: #1f2937;
            --light-bg: #f9fafb;
            --dark-bg: #111827;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: var(--text-color);
            background-color: var(--light-bg);
            line-height: 1.6;
        }
        
        .navbar {
            background-color: white;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        .navbar-brand {
            font-weight: 700;
            color: var(--primary-color);
        }
        
        .catalog-container {
            max-width: 1200px;
            margin: 2rem auto;
            padding: 0 1rem;
        }
        
        .catalog-header {
            margin-bottom: 2rem;
        }
        
        .catalog-title {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }
        
        .catalog-subtitle {
            color: #6b7280;
            margin-bottom: 1.5rem;
        }
        
        .filters-container {
            background-color: white;
            border-radius: 0.5rem;
            padding: 1.5rem;
            margin-bottom: 2rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .filter-row {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
            margin-bottom: 1rem;
        }
        
        .filter-group {
            flex: 1;
            min-width: 200px;
        }
        
        .filter-label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
        }
        
        .filter-select {
            width: 100%;
            padding: 0.5rem;
            border: 1px solid #d1d5db;
            border-radius: 0.375rem;
            font-size: 0.875rem;
        }
        
        .search-form {
            display: flex;
            gap: 0.5rem;
        }
        
        .search-input {
            flex: 1;
            padding: 0.5rem 1rem;
            border: 1px solid #d1d5db;
            border-radius: 0.375rem;
            font-size: 0.875rem;
        }
        
        .search-input:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.2);
        }
        
        .search-button {
            background-color: var(--primary-color);
            color: white;
            border: none;
            border-radius: 0.375rem;
            padding: 0.5rem 1rem;
            font-weight: 500;
            cursor: pointer;
        }
        
        .search-button:hover {
            background-color: var(--secondary-color);
        }
        
        .categories-list {
            display: flex;
            flex-wrap: wrap;
            gap: 0.5rem;
            margin-bottom: 1.5rem;
        }
        
        .category-pill {
            background-color: white;
            border: 1px solid #d1d5db;
            border-radius: 9999px;
            padding: 0.25rem 0.75rem;
            font-size: 0.875rem;
            text-decoration: none;
            color: var(--text-color);
            transition: all 0.2s ease;
        }
        
        .category-pill:hover {
            background-color: var(--accent-color);
            border-color: var(--primary-color);
            color: var(--primary-color);
        }
        
        .category-pill.active {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
            color: white;
        }
        
        .books-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .book-card {
            background-color: white;
            border-radius: 0.5rem;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            transition: transform 0.2s ease-in-out;
            height: 100%;
            display: flex;
            flex-direction: column;
        }
        
        .book-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }
        
        .book-card-cover {
            height: 250px;
            overflow: hidden;
        }
        
        .book-card-cover img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .book-card-info {
            padding: 1rem;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
        }
        
        .book-card-title {
            font-weight: 600;
            margin-bottom: 0.5rem;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            font-size: 1rem;
        }
        
        .book-card-author {
            color: #6b7280;
            font-size: 0.875rem;
            margin-bottom: 0.5rem;
        }
        
        .book-card-category {
            color: var(--primary-color);
            font-size: 0.75rem;
            margin-bottom: 0.5rem;
        }
        
        .book-card-rating {
            color: #f59e0b;
            font-size: 0.875rem;
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
        }
        
        .book-card-rating .rating-text {
            margin-left: 0.25rem;
            color: #6b7280;
        }
        
        .book-card-meta {
            display: flex;
            justify-content: space-between;
            font-size: 0.75rem;
            color: #6b7280;
            margin-bottom: 0.5rem;
        }
        
        .book-card-actions {
            margin-top: auto;
        }
        
        .book-card-button {
            display: block;
            text-align: center;
            background-color: var(--primary-color);
            color: white;
            padding: 0.5rem;
            border-radius: 0.375rem;
            text-decoration: none;
            font-weight: 500;
            font-size: 0.875rem;
            margin-bottom: 0.5rem;
        }
        
        .book-card-button:hover {
            background-color: var(--secondary-color);
            color: white;
        }
        
        .book-card-button.secondary {
            background-color: transparent;
            border: 1px solid var(--primary-color);
            color: var(--primary-color);
        }
        
        .book-card-button.secondary:hover {
            background-color: var(--accent-color);
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            gap: 0.5rem;
            margin-top: 2rem;
        }
        
        .pagination-button {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 36px;
            height: 36px;
            border-radius: 0.375rem;
            background-color: white;
            color: var(--text-color);
            text-decoration: none;
            font-weight: 500;
            border: 1px solid #d1d5db;
        }
        
        .pagination-button:hover {
            background-color: var(--accent-color);
            border-color: var(--primary-color);
            color: var(--primary-color);
        }
        
        .pagination-button.active {
            background-color: var(--primary-color);
            border-color: var(--primary-color);
            color: white;
        }
        
        .pagination-button.disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        .no-results {
            background-color: white;
            border-radius: 0.5rem;
            padding: 2rem;
            text-align: center;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .no-results h3 {
            font-size: 1.25rem;
            font-weight: 600;
            margin-bottom: 1rem;
        }
        
        .no-results p {
            color: #6b7280;
            margin-bottom: 1.5rem;
        }
        
        footer {
            background-color: white;
            padding: 2rem 0;
            margin-top: 3rem;
            border-top: 1px solid #e5e7eb;
        }
        
        .footer-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 1rem;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
        }
        
        .footer-links {
            display: flex;
            gap: 1.5rem;
            margin-bottom: 1rem;
        }
        
        .footer-link {
            color: var(--text-color);
            text-decoration: none;
        }
        
        .footer-link:hover {
            color: var(--primary-color);
        }
        
        .footer-copyright {
            color: #6b7280;
            font-size: 0.875rem;
        }
        
        @media (max-width: 768px) {
            .filter-row {
                flex-direction: column;
                gap: 1rem;
            }
            
            .filter-group {
                width: 100%;
            }
            
            .books-grid {
                grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            }
            
            .book-card-cover {
                height: 200px;
            }
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-light">
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
                            <button class="btn btn-outline-primary dropdown-toggle" type="button">
                                <i class="fas fa-user"></i> <%= currentUser.getFirstName() %>
                            </button>
                            <div class="dropdown-content">
                                <a class="dropdown-item" href="dashboard.jsp">Dashboard</a>
                                <a class="dropdown-item" href="profile.jsp">Profile</a>
                                <a class="dropdown-item" href="my-books.jsp">My Books</a>
                                <a class="dropdown-item" href="logout.jsp">Logout</a>
                            </div>
                        </div>
                    <% } else { %>
                        <a href="login.jsp" class="btn btn-outline-primary me-2">Login</a>
                        <a href="register.jsp" class="btn btn-primary">Register</a>
                    <% } %>
                </div>
            </div>
        </div>
    </nav>

    <!-- Catalog Content -->
    <div class="catalog-container">
        <div class="catalog-header">
            <% if (request.getAttribute("searchQuery") != null) { %>
                <h1 class="catalog-title">Search Results for "<%= request.getAttribute("searchQuery") %>"</h1>
                <p class="catalog-subtitle">Found <%= books.size() > 0 ? books.size() : "no" %> books matching your search.</p>
            <% } else if (request.getAttribute("categoryName") != null) { %>
                <h1 class="catalog-title"><%= request.getAttribute("categoryName") %> Books</h1>
                <p class="catalog-subtitle">Browse our collection of <%= request.getAttribute("categoryName") %> books.</p>
            <% } else if (request.getAttribute("tagName") != null) { %>
                <h1 class="catalog-title">Books Tagged with "<%= request.getAttribute("tagName") %>"</h1>
                <p class="catalog-subtitle">Browse books related to <%= request.getAttribute("tagName") %>.</p>
            <% } else { %>
                <h1 class="catalog-title">Browse Books</h1>
                <p class="catalog-subtitle">Discover our collection of books across various categories.</p>
            <% } %>
        </div>
        
        <div class="filters-container">
            <div class="filter-row">
                <div class="filter-group">
                    <form action="catalog.jsp" method="get" class="search-form">
                        <input type="text" name="search" placeholder="Search by title, author, or keyword" class="search-input" value="<%= searchQuery != null ? searchQuery : "" %>">
                        <button type="submit" class="search-button">
                            <i class="fas fa-search"></i>
                        </button>
                    </form>
                </div>
            </div>
            
            <div class="filter-row">
                <div class="filter-group">
                    <label class="filter-label">Sort By</label>
                    <select id="sortSelect" class="filter-select" onchange="updateSort(this.value)">
                        <option value="newest" <%= "newest".equals(sortParam) || sortParam == null ? "selected" : "" %>>Newest</option>
                        <option value="title" <%= "title".equals(sortParam) ? "selected" : "" %>>Title (A-Z)</option>
                        <option value="rating" <%= "rating".equals(sortParam) ? "selected" : "" %>>Highest Rated</option>
                        <option value="popular" <%= "popular".equals(sortParam) ? "selected" : "" %>>Most Popular</option>
                    </select>
                </div>
                
                <div class="filter-group">
                    <label class="filter-label">Category</label>
                    <select id="categorySelect" class="filter-select" onchange="updateCategory(this.value)">
                        <option value="">All Categories</option>
                        <% for (Category category : categories) { %>
                            <option value="<%= category.getCategoryId() %>" <%= category.getCategoryId() == categoryId ? "selected" : "" %>>
                                <%= category.getName() %> (<%= category.getBookCount() %>)
                            </option>
                        <% } %>
                    </select>
                </div>
            </div>
        </div>
        
        <div class="categories-list">
            <a href="catalog.jsp" class="category-pill <%= categoryId == 0 && tagParam == null ? "active" : "" %>">All</a>
            <% for (Category category : categories) { %>
                <a href="catalog.jsp?category=<%= category.getCategoryId() %>" class="category-pill <%= category.getCategoryId() == categoryId ? "active" : "" %>">
                    <%= category.getName() %>
                </a>
            <% } %>
        </div>
        
        <% if (books.isEmpty()) { %>
            <div class="no-results">
                <h3>No Books Found</h3>
                <p>We couldn't find any books matching your criteria. Try adjusting your filters or search terms.</p>
                <a href="catalog.jsp" class="btn btn-primary">View All Books</a>
            </div>
        <% } else { %>
            <div class="books-grid">
                <% for (Book book : books) { %>
                    <div class="book-card">
                        <div class="book-card-cover">
                            <a href="book-details.jsp?id=<%= book.getBookId() %>">
                                <img src="<%= book.getCoverImagePath() != null ? book.getCoverImagePath() : "images/default-cover.jpg" %>" alt="<%= book.getTitle() %>">
                            </a>
                        </div>
                        <div class="book-card-info">
                            <h3 class="book-card-title">
                                <a href="book-details.jsp?id=<%= book.getBookId() %>" style="text-decoration: none; color: inherit;">
                                    <%= book.getTitle() %>
                                </a>
                            </h3>
                            <p class="book-card-author">By <a href="author.jsp?id=<%= book.getAuthorId() %>" style="text-decoration: none; color: var(--primary-color);"><%= book.getAuthorName() %></a></p>
                            <p class="book-card-category"><%= book.getCategoryName() %></p>
                            <div class="book-card-rating">
                                <% for (int i = 1; i <= 5; i++) { %>
                                    <% if (i <= book.getRating()) { %>
                                        <i class="fas fa-star"></i>
                                    <% } else if (i - 0.5 <= book.getRating()) { %>
                                        <i class="fas fa-star-half-alt"></i>
                                    <% } else { %>
                                        <i class="far fa-star"></i>
                                    <% } %>
                                <% } %>
                                <span class="rating-text"><%= String.format("%.1f", book.getRating()) %></span>
                            </div>
                            <div class="book-card-meta">
                                <span><i class="fas fa-eye"></i> <%= book.getViews() %></span>
                                <span><i class="fas fa-download"></i> <%= book.getDownloads() %></span>
                                <span><i class="fas fa-calendar"></i> <%= book.getPublicationDate() != null ? dateFormat.format(book.getPublicationDate()) : "Unknown" %></span>
                            </div>
                            <div class="book-card-actions">
                                <a href="book-details.jsp?id=<%= book.getBookId() %>" class="book-card-button">View Details</a>
                                <a href="DownloadServlet?id=<%= book.getBookId() %>" class="book-card-button secondary">Download</a>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
            
            <!-- Pagination -->
            <% if (totalPages > 1) { %>
                <div class="pagination">
                    <% if (currentPage > 1) { %>
                        <a href="<%= getPageUrl(currentPage - 1, request) %>" class="pagination-button">
                            <i class="fas fa-chevron-left"></i>
                        </a>
                    <% } else { %>
                        <span class="pagination-button disabled">
                            <i class="fas fa-chevron-left"></i>
                        </span>
                    <% } %>
                    
                    <% 
                    int startPage = Math.max(1, currentPage - 2);
                    int endPage = Math.min(startPage + 4, totalPages);
                    
                    if (startPage > 1) { %>
                        <a href="<%= getPageUrl(1, request) %>" class="pagination-button">1</a>
                        <% if (startPage > 2) { %>
                            <span class="pagination-button disabled">...</span>
                        <% } %>
                    <% } %>
                    
                    <% for (int i = startPage; i <= endPage; i++) { %>
                        <a href="<%= getPageUrl(i, request) %>" class="pagination-button <%= i == currentPage ? "active" : "" %>">
                            <%= i %>
                        </a>
                    <% } %>
                    
                    <% if (endPage < totalPages) { %>
                        <% if (endPage < totalPages - 1) { %>
                            <span class="pagination-button disabled">...</span>
                        <% } %>
                        <a href="<%= getPageUrl(totalPages, request) %>" class="pagination-button"><%= totalPages %></a>
                    <% } %>
                    
                    <% if (currentPage < totalPages) { %>
                        <a href="<%= getPageUrl(currentPage + 1, request) %>" class="pagination-button">
                            <i class="fas fa-chevron-right"></i>
                        </a>
                    <% } else { %>
                        <span class="pagination-button disabled">
                            <i class="fas fa-chevron-right"></i>
                        </span>
                    <% } %>
                </div>
            <% } %>
        <% } %>
    </div>
    
    <!-- Footer -->
    <footer>
        <div class="footer-content">
            <div class="footer-links">
                <a href="about.jsp" class="footer-link">About Us</a>
                <a href="contact.jsp" class="footer-link">Contact</a>
                <a href="privacy.jsp" class="footer-link">Privacy Policy</a>
                <a href="terms.jsp" class="footer-link">Terms of Service</a>
            </div>
            <p class="footer-copyright">&copy; 2023 E-Library. All rights reserved.</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Helper function to update URL parameters
        function updateUrlParameter(url, param, value) {
            var pattern = new RegExp('(\\?|&)' + param + '=[^&]*');
            var newUrl = url.replace(pattern, '$1' + param + '=' + value);
            
            if (newUrl === url) {
                newUrl = url + (url.indexOf('?') > 0 ? '&' : '?') + param + '=' + value;
            }
            
            return newUrl;
        }
        
        // Update sort parameter
        function updateSort(value) {
            var url = window.location.href;
            url = updateUrlParameter(url, 'sort', value);
            
            // Reset page parameter
            var pattern = new RegExp('(\\?|&)page=[^&]*');
            url = url.replace(pattern, '');
            
            window.location.href = url;
        }
        
        // Update category parameter
        function updateCategory(value) {
            if (value === '') {
                // Redirect to catalog without category parameter
                var url = 'catalog.jsp';
                
                // Preserve sort parameter if exists
                var sortParam = '<%= sortParam %>';
                if (sortParam && sortParam !== 'null') {
                    url += '?sort=' + sortParam;
                }
                
                window.location.href = url;
            } else {
                window.location.href = 'catalog.jsp?category=' + value;
            }
        }
    </script>
    
    <%!
        // Helper method to generate pagination URLs
        private String getPageUrl(int page, HttpServletRequest request) {
            StringBuilder url = new StringBuilder("catalog.jsp?page=").append(page);
            
            // Add other parameters if they exist
            String search = request.getParameter("search");
            if (search != null && !search.isEmpty()) {
                url.append("&search=").append(search);
            }
            
            String category = request.getParameter("category");
            if (category != null && !category.isEmpty()) {
                url.append("&category=").append(category);
            }
            
            String tag = request.getParameter("tag");
            if (tag != null && !tag.isEmpty()) {
                url.append("&tag=").append(tag);
            }
            
            String sort = request.getParameter("sort");
            if (sort != null && !sort.isEmpty()) {
                url.append("&sort=").append(sort);
            }
            
            return url.toString();
        }
    %>
</body>
</html>
