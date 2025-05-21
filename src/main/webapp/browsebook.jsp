<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.BookDAO, dao.CategoryDAO, mode.Book, mode.Category, java.util.List, java.util.ArrayList" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Books | E-Library Hub</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Browse Books Specific Styles */
        .browse-container {
            padding: 40px 0;
        }
        
        .browse-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        
        .browse-title {
            font-size: 2rem;
            color: #333;
        }
        
        .browse-controls {
            display: flex;
            gap: 15px;
            align-items: center;
        }
        
        .sort-select {
            padding: 8px 12px;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            background-color: white;
            font-size: 0.9rem;
        }
        
        .view-toggle {
            display: flex;
            gap: 5px;
        }
        
        .view-toggle button {
            background: none;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            padding: 8px 12px;
            cursor: pointer;
            color: #6b7280;
            transition: all 0.2s;
        }
        
        .view-toggle button.active {
            background-color: #4f46e5;
            color: white;
            border-color: #4f46e5;
        }
        
        .filters-sidebar {
            background-color: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
            height: fit-content;
        }
        
        .filter-section {
            margin-bottom: 25px;
        }
        
        .filter-title {
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 15px;
            color: #333;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .filter-title button {
            background: none;
            border: none;
            font-size: 0.9rem;
            color: #4f46e5;
            cursor: pointer;
        }
        
        .filter-options {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        
        .filter-checkbox {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .filter-checkbox input {
            width: 16px;
            height: 16px;
        }
        
        .filter-checkbox label {
            font-size: 0.95rem;
            color: #4b5563;
        }
        
        .filter-range {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        
        .range-slider {
            width: 100%;
        }
        
        .range-values {
            display: flex;
            justify-content: space-between;
            font-size: 0.9rem;
            color: #6b7280;
        }
        
        .browse-layout {
            display: grid;
            grid-template-columns: 250px 1fr;
            gap: 30px;
        }
        
        @media (max-width: 768px) {
            .browse-layout {
                grid-template-columns: 1fr;
            }
            
            .browse-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
            
            .browse-controls {
                width: 100%;
                justify-content: space-between;
            }
        }
        
        .books-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 30px;
        }
        
        .books-list {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }
        
        .book-list-item {
            display: grid;
            grid-template-columns: 120px 1fr;
            gap: 20px;
            background-color: white;
            border-radius: 8px;
            padding: 15px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
        }
        
        .book-list-cover img {
            width: 100%;
            height: auto;
            border-radius: 4px;
        }
        
        .book-list-info {
            display: flex;
            flex-direction: column;
        }
        
        .book-list-title {
            font-size: 1.2rem;
            margin-bottom: 5px;
            color: #333;
        }
        
        .book-list-author {
            font-size: 0.95rem;
            color: #6b7280;
            margin-bottom: 10px;
        }
        
        .book-list-rating {
            display: flex;
            align-items: center;
            gap: 5px;
            margin-bottom: 10px;
        }
        
        .book-list-rating .stars {
            color: #f59e0b;
        }
        
        .book-list-rating .count {
            font-size: 0.85rem;
            color: #6b7280;
        }
        
        .book-list-description {
            font-size: 0.95rem;
            color: #4b5563;
            margin-bottom: 15px;
            display: -webkit-box;
            -webkit-line-clamp: 3;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        
        .book-list-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-bottom: 15px;
        }
        
        .book-list-tag {
            background-color: #e0e7ff;
            color: #4f46e5;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
        }
        
        .book-list-actions {
            margin-top: auto;
            display: flex;
            gap: 10px;
        }
        
        .pagination {
            display: flex;
            justify-content: center;
            gap: 5px;
            margin-top: 40px;
        }
        
        .pagination-item {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            color: #4b5563;
            font-size: 0.95rem;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .pagination-item:hover {
            border-color: #4f46e5;
            color: #4f46e5;
        }
        
        .pagination-item.active {
            background-color: #4f46e5;
            color: white;
            border-color: #4f46e5;
        }
        
        .pagination-item.disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        .no-results {
            text-align: center;
            padding: 40px 0;
        }
        
        .no-results i {
            font-size: 3rem;
            color: #d1d5db;
            margin-bottom: 20px;
        }
        
        .no-results h3 {
            font-size: 1.5rem;
            color: #4b5563;
            margin-bottom: 10px;
        }
        
        .no-results p {
            color: #6b7280;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <%
        // Initialize DAOs
        BookDAO bookDAO = new BookDAO();
        CategoryDAO categoryDAO = new CategoryDAO();
        
        // Get parameters
        String categoryParam = request.getParameter("category");
        String searchParam = request.getParameter("search");
        String sortParam = request.getParameter("sort");
        String pageParam = request.getParameter("page");
        
        // Set defaults
        int categoryId = (categoryParam != null && !categoryParam.isEmpty()) ? Integer.parseInt(categoryParam) : 0;
        String search = (searchParam != null) ? searchParam : "";
        String sort = (sortParam != null) ? sortParam : "newest";
        int currentPage = (pageParam != null && !pageParam.isEmpty()) ? Integer.parseInt(pageParam) : 1;
        int booksPerPage = 12;
        
        // Get all books based on filters
        List<Book> allBooks = new ArrayList<>();
        
        if (categoryId > 0) {
            allBooks = bookDAO.getBooksByCategory(categoryId);
        } else if (!search.isEmpty()) {
            allBooks = bookDAO.searchBooks(search);
        } else {
            allBooks = bookDAO.getPublicBooks();
        }
        
        // Sort the books based on the sort parameter
        if (sort.equals("oldest")) {
            // Sort by publication date (oldest first)
            allBooks.sort((b1, b2) -> {
                try {
                    return b1.getPublicationDate().compareTo(b2.getPublicationDate());
                } catch (Exception e) {
                    return 0;
                }
            });
        } else if (sort.equals("rating")) {
            // Sort by rating (highest first)
            allBooks.sort((b1, b2) -> {
                try {
                    return Double.compare(b2.getRating(), b1.getRating());
                } catch (Exception e) {
                    return 0;
                }
            });
        } else if (sort.equals("popular")) {
            // Sort by views + downloads (most popular first)
            allBooks.sort((b1, b2) -> {
                try {
                    return Integer.compare(b2.getViews() + b2.getDownloads(), b1.getViews() + b1.getDownloads());
                } catch (Exception e) {
                    return 0;
                }
            });
        } else if (sort.equals("title_asc")) {
            // Sort by title (A-Z)
            allBooks.sort((b1, b2) -> {
                try {
                    return b1.getTitle().compareTo(b2.getTitle());
                } catch (Exception e) {
                    return 0;
                }
            });
        } else if (sort.equals("title_desc")) {
            // Sort by title (Z-A)
            allBooks.sort((b1, b2) -> {
                try {
                    return b2.getTitle().compareTo(b1.getTitle());
                } catch (Exception e) {
                    return 0;
                }
            });
        } else {
            // Default: sort by publication date (newest first)
            allBooks.sort((b1, b2) -> {
                try {
                    return b2.getPublicationDate().compareTo(b1.getPublicationDate());
                } catch (Exception e) {
                    return 0;
                }
            });
        }
        
        // Calculate total books and pages
        int totalBooks = allBooks.size();
        int totalPages = (int) Math.ceil((double) totalBooks / booksPerPage);
        
        // Get the books for the current page
        int startIndex = (currentPage - 1) * booksPerPage;
        int endIndex = Math.min(startIndex + booksPerPage, totalBooks);
        List<Book> books = (startIndex < totalBooks) ? allBooks.subList(startIndex, endIndex) : new ArrayList<>();
        
        // Get all categories for filter
        List<Category> categories = categoryDAO.getAllCategories();
        
        // Check if user is logged in
        boolean isLoggedIn = session.getAttribute("user") != null;
        
        // Get view preference (grid or list)
        String viewMode = request.getParameter("view");
        if (viewMode == null) {
            viewMode = "grid"; // Default view mode
        }
    %>

    <header class="main-header">
        <div class="container">
            <div class="logo">
                <i class="fas fa-book-open"></i>
                <h1>E-Library Hub</h1>
            </div>
            <nav class="main-nav">
                <ul>
                    <li><a href="index.jsp">Home</a></li>
                    <li class="active"><a href="browsebook.jsp">Browse Books</a></li>
                    <% if (isLoggedIn) { %>
                        <li><a href="dashboard.jsp">Dashboard</a></li>
                        <li><a href="logout.jsp">Logout</a></li>
                    <% } else { %>
                        <li><a href="login.jsp">Login</a></li>
                        <li><a href="register.jsp" class="btn-primary">Register</a></li>
                    <% } %>
                </ul>
            </nav>
            <button class="mobile-menu-toggle">
                <i class="fas fa-bars"></i>
            </button>
        </div>
    </header>

    <div class="search-container">
        <div class="container">
            <form class="search-form" action="browsebook.jsp" method="get">
                <input type="text" name="search" placeholder="Search by title, author, or tags..." value="<%= search %>">
                <button type="submit">
                    <i class="fas fa-search"></i>
                </button>
            </form>
        </div>
    </div>

    <main>
        <div class="container">
            <div class="browse-container">
                <div class="browse-header">
                    <h1 class="browse-title">
                        <% if (categoryId > 0) { %>
                            <%= categoryDAO.getCategoryById(categoryId).getName() %> Books
                        <% } else if (!search.isEmpty()) { %>
                            Search Results for "<%= search %>"
                        <% } else { %>
                            All Books
                        <% } %>
                    </h1>
                    <div class="browse-controls">
                        <form id="sortForm" action="browsebook.jsp" method="get">
                            <% if (categoryId > 0) { %>
                                <input type="hidden" name="category" value="<%= categoryId %>">
                            <% } %>
                            <% if (!search.isEmpty()) { %>
                                <input type="hidden" name="search" value="<%= search %>">
                            <% } %>
                            <input type="hidden" name="view" value="<%= viewMode %>">
                            <select name="sort" class="sort-select" onchange="document.getElementById('sortForm').submit()">
                                <option value="newest" <%= sort.equals("newest") ? "selected" : "" %>>Newest First</option>
                                <option value="oldest" <%= sort.equals("oldest") ? "selected" : "" %>>Oldest First</option>
                                <option value="rating" <%= sort.equals("rating") ? "selected" : "" %>>Highest Rated</option>
                                <option value="popular" <%= sort.equals("popular") ? "selected" : "" %>>Most Popular</option>
                                <option value="title_asc" <%= sort.equals("title_asc") ? "selected" : "" %>>Title (A-Z)</option>
                                <option value="title_desc" <%= sort.equals("title_desc") ? "selected" : "" %>>Title (Z-A)</option>
                            </select>
                        </form>
                        <div class="view-toggle">
                            <form id="viewForm" action="browsebook.jsp" method="get">
                                <% if (categoryId > 0) { %>
                                    <input type="hidden" name="category" value="<%= categoryId %>">
                                <% } %>
                                <% if (!search.isEmpty()) { %>
                                    <input type="hidden" name="search" value="<%= search %>">
                                <% } %>
                                <input type="hidden" name="sort" value="<%= sort %>">
                                <button type="submit" name="view" value="grid" class="<%= viewMode.equals("grid") ? "active" : "" %>">
                                    <i class="fas fa-th"></i>
                                </button>
                                <button type="submit" name="view" value="list" class="<%= viewMode.equals("list") ? "active" : "" %>">
                                    <i class="fas fa-list"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
                
                <div class="browse-layout">
                    <div class="filters-sidebar">
                        <form action="browsebook.jsp" method="get">
                            <% if (!search.isEmpty()) { %>
                                <input type="hidden" name="search" value="<%= search %>">
                            <% } %>
                            <input type="hidden" name="sort" value="<%= sort %>">
                            <input type="hidden" name="view" value="<%= viewMode %>">
                            
                            <div class="filter-section">
                                <div class="filter-title">
                                    <span>Categories</span>
                                    <button type="button" onclick="clearCategoryFilters()">Clear</button>
                                </div>
                                <div class="filter-options">
                                    <% for (Category category : categories) { %>
                                        <div class="filter-checkbox">
                                            <input type="radio" id="category<%= category.getCategoryId() %>" name="category" 
                                                value="<%= category.getCategoryId() %>" 
                                                <%= (categoryId == category.getCategoryId()) ? "checked" : "" %>>
                                            <label for="category<%= category.getCategoryId() %>"><%= category.getName() %></label>
                                        </div>
                                    <% } %>
                                </div>
                            </div>
                            
                            <button type="submit" class="btn-primary" style="width: 100%;">Apply Filters</button>
                        </form>
                    </div>
                    
                    <div class="books-container">
                        <% if (books.isEmpty()) { %>
                            <div class="no-results">
                                <i class="fas fa-search"></i>
                                <h3>No books found</h3>
                                <p>Try adjusting your search or filter criteria</p>
                                <a href="browsebook.jsp" class="btn-primary">View All Books</a>
                            </div>
                        <% } else { %>
                            <% if (viewMode.equals("grid")) { %>
                                <div class="books-grid">
                                    <% for (Book book : books) { %>
                                        <div class="book-card">
                                            <div class="book-cover">
                                                <img src="<%= book.getCoverImagePath() != null ? book.getCoverImagePath() : "css/images/default-cover.jpg" %>" alt="<%= book.getTitle() %>">
                                                <div class="book-rating">
                                                    <i class="fas fa-star"></i>
                                                    <span><%= String.format("%.1f", book.getRating()) %></span>
                                                </div>
                                            </div>
                                            <div class="book-info">
                                                <h3><%= book.getTitle() %></h3>
                                                <p class="book-author">By <%= book.getAuthorName() %></p>
                                                <div class="book-tags">
                                                    <span><%= book.getCategoryName() %></span>
                                                    <% if (book.getTags() != null && !book.getTags().isEmpty()) { 
                                                        String[] tags = book.getTags().split(",");
                                                        if (tags.length > 0) { %>
                                                            <span><%= tags[0].trim() %></span>
                                                        <% } 
                                                    } %>
                                                </div>
                                                <a href="bookdetails.jsp?id=<%= book.getBookId() %>" class="btn-view">View Details</a>
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                            <% } else { %>
                                <div class="books-list">
                                    <% for (Book book : books) { %>
                                        <div class="book-list-item">
                                            <div class="book-list-cover">
                                                <img src="<%= book.getCoverImagePath() != null ? book.getCoverImagePath() : "css/images/default-cover.jpg" %>" alt="<%= book.getTitle() %>">
                                            </div>
                                            <div class="book-list-info">
                                                <h3 class="book-list-title"><%= book.getTitle() %></h3>
                                                <p class="book-list-author">By <%= book.getAuthorName() %></p>
                                                <div class="book-list-rating">
                                                    <div class="stars">
                                                        <% for (int i = 1; i <= 5; i++) { %>
                                                            <% if (i <= book.getRating()) { %>
                                                                <i class="fas fa-star"></i>
                                                            <% } else if (i - 0.5 <= book.getRating()) { %>
                                                                <i class="fas fa-star-half-alt"></i>
                                                            <% } else { %>
                                                                <i class="far fa-star"></i>
                                                            <% } %>
                                                        <% } %>
                                                    </div>
                                                    <span class="count">(0 reviews)</span>
                                                </div>
                                                <p class="book-list-description"><%= book.getDescription() %></p>
                                                <div class="book-list-tags">
                                                    <span class="book-list-tag"><%= book.getCategoryName() %></span>
                                                    <% if (book.getTags() != null && !book.getTags().isEmpty()) { 
                                                        String[] tags = book.getTags().split(",");
                                                        for (int i = 0; i < Math.min(3, tags.length); i++) { %>
                                                            <span class="book-list-tag"><%= tags[i].trim() %></span>
                                                        <% } 
                                                    } %>
                                                </div>
                                                <div class="book-list-actions">
                                                    <a href="bookdetails.jsp?id=<%= book.getBookId() %>" class="btn-primary">View Details</a>
                                                    <% if (isLoggedIn) { %>
                                                        <a href="reader.jsp?id=<%= book.getBookId() %>" class="btn-secondary">Read Online</a>
                                                    <% } %>
                                                </div>
                                            </div>
                                        </div>
                                    <% } %>
                                </div>
                            <% } %>
                            
                            <!-- Pagination -->
                            <% if (totalPages > 1) { %>
                                <div class="pagination">
                                    <a href="browsebook.jsp?<%= categoryId > 0 ? "category=" + categoryId + "&" : "" %><%= !search.isEmpty() ? "search=" + search + "&" : "" %>sort=<%= sort %>&view=<%= viewMode %>&page=<%= Math.max(1, currentPage - 1) %>" 
                                       class="pagination-item <%= currentPage == 1 ? "disabled" : "" %>">
                                        <i class="fas fa-chevron-left"></i>
                                    </a>
                                    
                                    <% 
                                    int startPage = Math.max(1, currentPage - 2);
                                    int endPage = Math.min(totalPages, startPage + 4);
                                    
                                    if (startPage > 1) { %>
                                        <a href="browsebook.jsp?<%= categoryId > 0 ? "category=" + categoryId + "&" : "" %><%= !search.isEmpty() ? "search=" + search + "&" : "" %>sort=<%= sort %>&view=<%= viewMode %>&page=1" class="pagination-item">1</a>
                                        <% if (startPage > 2) { %>
                                            <span class="pagination-item disabled">...</span>
                                        <% } %>
                                    <% } %>
                                    
                                    <% for (int i = startPage; i <= endPage; i++) { %>
                                        <a href="browsebook.jsp?<%= categoryId > 0 ? "category=" + categoryId + "&" : "" %><%= !search.isEmpty() ? "search=" + search + "&" : "" %>sort=<%= sort %>&view=<%= viewMode %>&page=<%= i %>" 
                                           class="pagination-item <%= i == currentPage ? "active" : "" %>"><%= i %></a>
                                    <% } %>
                                    
                                    <% if (endPage < totalPages) { %>
                                        <% if (endPage < totalPages - 1) { %>
                                            <span class="pagination-item disabled">...</span>
                                        <% } %>
                                        <a href="browsebook.jsp?<%= categoryId > 0 ? "category=" + categoryId + "&" : "" %><%= !search.isEmpty() ? "search=" + search + "&" : "" %>sort=<%= sort %>&view=<%= viewMode %>&page=<%= totalPages %>" class="pagination-item"><%= totalPages %></a>
                                    <% } %>
                                    
                                    <a href="browsebook.jsp?<%= categoryId > 0 ? "category=" + categoryId + "&" : "" %><%= !search.isEmpty() ? "search=" + search + "&" : "" %>sort=<%= sort %>&view=<%= viewMode %>&page=<%= Math.min(totalPages, currentPage + 1) %>" 
                                       class="pagination-item <%= currentPage == totalPages ? "disabled" : "" %>">
                                        <i class="fas fa-chevron-right"></i>
                                    </a>
                                </div>
                            <% } %>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <footer class="main-footer">
        <div class="container">
            <div class="footer-grid">
                <div class="footer-about">
                    <div class="logo">
                        <i class="fas fa-book-open"></i>
                        <h2>E-Library Hub</h2>
                    </div>
                    <p>A platform for readers and authors to share knowledge through e-books.</p>
                </div>
                <div class="footer-links">
                    <h3>Quick Links</h3>
                    <ul>
                        <li><a href="index.jsp">Home</a></li>
                        <li><a href="browsebook.jsp">Browse Books</a></li>
                        <li><a href="login.jsp">Login</a></li>
                        <li><a href="register.jsp">Register</a></li>
                    </ul>
                </div>
                <div class="footer-links">
                    <h3>Information</h3>
                    <ul>
                        <li><a href="about_us.jsp">About Us</a></li>
                        <li><a href="contact_us.jsp">Contact Us</a></li>
                        <li><a href="privacy.html">Privacy Policy</a></li>
                        <li><a href="terms.html">Terms of Service</a></li>
                    </ul>
                </div>
                <div class="footer-contact">
                    <h3>Contact Us</h3>
                    <p><i class="fas fa-envelope"></i> info@elibraryhub.com</p>
                    <p><i class="fas fa-phone"></i> +1 (555) 123-4567</p>
                    <div class="social-links">
                        <a href="#"><i class="fab fa-facebook"></i></a>
                        <a href="#"><i class="fab fa-twitter"></i></a>
                        <a href="#"><i class="fab fa-instagram"></i></a>
                        <a href="#"><i class="fab fa-linkedin"></i></a>
                    </div>
                </div>
            </div>
            <div class="footer-bottom">
                <p>&copy; 2023 E-Library Hub. All rights reserved.</p>
            </div>
        </div>
    </footer>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Mobile menu toggle
            const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
            const mainNav = document.querySelector('.main-nav');
            
            if (mobileMenuToggle) {
                mobileMenuToggle.addEventListener('click', function() {
                    mainNav.classList.toggle('active');
                    this.classList.toggle('active');
                });
            }
        });
        
        // Clear category filters
        function clearCategoryFilters() {
            const categoryInputs = document.querySelectorAll('input[name="category"]');
            categoryInputs.forEach(input => {
                input.checked = false;
            });
            
            // Submit the form after clearing filters
            document.querySelector('.filters-sidebar form').submit();
        }
    </script>
</body>
</html>
